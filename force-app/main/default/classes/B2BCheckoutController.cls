public without sharing class B2BCheckoutController {

    @AuraEnabled
    public static B2BResponse initAddresses(Id cartId) {
        try {
            Map<String, String> countryByCode = B2BCountryStatePicklists.getCountryByCode();

            return new B2BResponse(true, new Map<String, Object>{
                'addresses' => new B2BCheckoutAddress(cartId),
                'countryOptions' => countryByCode,
                'stateOptions' => B2BCountryStatePicklists.getStatesByCountryCode(countryByCode)
            }, '');
        } catch (Exception ex) {
            return new B2BResponse(false, ex.getMessage());
        }
    }

    @AuraEnabled
    public static B2BResponse initCartItems(Id cartId) {
        try {
            B2BCheckoutCartItems cartInfo = new B2BCheckoutCartItems(cartId);

            return new B2BResponse(true, new Map<String, Object>{
                'cartItems' => cartInfo.cartItems,
                'isCartSecondary' => cartInfo.isCartSecondary
            }, '');
        } catch(Exception ex) {
            return new B2BResponse(false, ex.getMessage());
        }
    }

    @AuraEnabled
    public static B2BResponse updateInstruction(Id cartId, String instruction) {
        try {
            B2BCheckoutService.updateInstruction(cartId, instruction);
            return new B2BResponse(true);
        } catch(Exception ex) {
            return new B2BResponse(false, ex.getMessage());
        }
    }

    @AuraEnabled
    public static B2BResponse updatePoNumber(Id cartId, String poNumber) {
        try {
            B2BCheckoutService.updatePoNumber(cartId, poNumber);
            return new B2BResponse(true);
        } catch(Exception ex) {
            return new B2BResponse(false, ex.getMessage());
        }
    }

    @AuraEnabled
    public static B2BResponse saveHasDarleyDollars(Id cartId, Boolean hasDarleyDollars) {
        try {
            B2BCheckoutService.saveHasDarleyDollars(cartId, hasDarleyDollars);
            return new B2BResponse(true);
        } catch(Exception ex) {
            return new B2BResponse(false, ex.getMessage());
        }
    }

    @AuraEnabled
    public static B2BResponse initInstruction(Id cartId) {
        try {
            return new B2BResponse(true, new Map<String, Object> {
                'instruction' => B2BCheckoutService.getSpecialInstruction(cartId)
            }, '');
        } catch(Exception ex) {
            return new B2BResponse(false, ex.getMessage());
        }
    }

    @AuraEnabled
    public static B2BResponse addAddress(B2BCheckoutAddress.AddressDto address, Id cartId) {
        try {
            List<ContactPointAddress> contactPointAddresses = new List<ContactPointAddress>();

            contactPointAddresses.add(address.getContactPointAddress());
            B2BCheckoutService.upsertAddress(contactPointAddresses);

            if (address.id == null) {
                WebCart cart = new WebCart(Id = cartId);

                if (address.addressType == B2BCheckoutAddress.SHIPPING_TYPE) {
                    cart.B2BCheckoutShippingAddress__c = contactPointAddresses[0].Id;
                } else if (address.addressType == B2BCheckoutAddress.BILLING_TYPE) {
                    cart.B2BCheckoutBillingAddress__c = contactPointAddresses[0].Id;
                }

                update cart;
            }

            return new B2BResponse(true, new Map<String, Object>{
                'addresses' => new B2BCheckoutAddress(cartId)
            }, '');
        } catch(Exception ex) {
            return new B2BResponse(false, ex.getMessage());
        }
    }

    @AuraEnabled
    public static B2BResponse useAddress(Id cartId, Id shippingAddressId, Id billingAddressId) {
        try {
            B2BCheckoutService.updateCheckoutAddress(cartId, shippingAddressId, billingAddressId);
            return new B2BResponse(true, new Map<String, Object>{
                'addresses' => new B2BCheckoutAddress(cartId)
            }, '');
        } catch(Exception ex) {
            return new B2BResponse(false, ex.getMessage());
        }
    }

    @AuraEnabled
    public static B2BResponse initPayment(Id cartId) {
        try {
            return new B2BResponse(true, new Map<String, Object>{
                'payment' => new B2BCheckoutPayment(cartId)
            }, '');
        } catch (Exception ex) {
            return new B2BResponse(false, ex.getMessage());
        }
    }

    @AuraEnabled
    public static B2BResponse setPaymentMethod(Id cartId, String paymentMethod) {
        try {
            B2BCheckoutService.updatePaymentMethod(cartId, paymentMethod);
            return new B2BResponse(true);
        } catch(Exception ex) {
            return new B2BResponse(false, ex.getMessage());
        }
    }

    @AuraEnabled
    public static B2BResponse useCard(Id cartId, String creditCardId, String creditCardName) {
        try {
            B2BCheckoutService.updateCard(cartId, creditCardId, creditCardName);
            return new B2BResponse(true);
        } catch(Exception ex) {
            return new B2BResponse(false, ex.getMessage());
        }
    }

    @AuraEnabled
    public static B2BResponse initOrderSummary(Id cartId) {
        try {
            return new B2BResponse(true, new Map<String, Object>{
                'orderSummary' => new B2BCheckoutOrderSummary(cartId)
            }, '');
        } catch(Exception ex) {
            return new B2BResponse(false, ex.getMessage());
        }
    }

    @AuraEnabled
    public static B2BResponse deleteAllTaxes(Id cartId) {
        try {
            List<CartTax> taxesForDelete = [
                SELECT Id
                FROM CartTax
                WHERE CartItem.CartId = :cartId
                    AND CartItem.Cart.IsSecondary = FALSE
            ];

            if (taxesForDelete.isEmpty() == false) {
                delete taxesForDelete;
            }
            return new B2BResponse(true,'');
        } catch(Exception ex) {
            return new B2BResponse(false,  ex.getMessage());
        }
    }

    @AuraEnabled
    public static B2BResponse calculateTaxes(Id cartId) {
        try {
            B2BCheckoutOrderSummary.calculateTaxes(cartId);
            return new B2BResponse(true, new Map<String, Object> {
                'customerTaxInformation' => B2BCheckoutOrderSummary.getCustomerTaxInformation(cartId)
            }, '');
        } catch(Exception ex) {
            System.debug('calculateTaxesError--' + ex.getMessage() + ' -Stacktrace-- ' + ex.getStackTraceString());
            return new B2BResponse(false,  Label.B2B_We_Are_Unable_To_Calculate_The_Taxes);
        }
    }

    @AuraEnabled
    public static B2BResponse placeOrder(
        Id cartId,
        String paymentIntentId,
        Decimal darleyDollarAmount,
        B2BPayPal.CreditCardDto creditCard,
        String amazonCheckoutId,
        String amount
    ) {
        try {
            String paymentTransactionId;

            if (creditCard != null) {
                User userInfo = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
                creditCard.decrypt();
                paymentTransactionId = creditCard.pay(userInfo.ContactId);
                creditCard.saveCard(userInfo.ContactId);
            } else if (amazonCheckoutId != null) {
                B2BAmazonPayment.CheckoutResponse amazonResponse = B2BAmazonPayment.completeCheckout(amazonCheckoutId, amount, cartId);
                if (amazonResponse.success) {
                    paymentTransactionId = amazonResponse.message;
                } else {
                    throw new B2BAmazonPayment.B2BAmazonPaymentException(amazonResponse.message);
                }
            }

            return new B2BResponse(true, new Map<String, Object> {
                'orderSummaryId' => new B2BCheckoutPlaceOrder(cartId, paymentIntentId, darleyDollarAmount, paymentTransactionId, creditCard).orderSummaryId
            }, '');
        } catch(Exception ex) {
            return new B2BResponse(false, ex.getMessage() + ' ' + ex.getStackTraceString());
        }
    }

    @AuraEnabled
    public static B2BResponse getAvalaraEcommerceToken(String avalaraCustomerCode) {
        try {
            B2BAvalara avalara = new B2BAvalara();
            return new B2BResponse(true, new Map<String, Object> {
                'token' => avalara.getEcommerceToken(avalaraCustomerCode)
            }, '');
        } catch (Exception ex) {
            return new B2BResponse(false,  ex.getMessage());
        }
    }

    @AuraEnabled
    public static B2BResponse initCheckoutButton(Id effectiveAccountId, Id cartId) {
        try {
            B2BSettings__c b2BSettings = B2BSettings__c.getInstance();

            return new B2BResponse(true, new Map<String, Object> {
                'isButtonAvailable' => B2BRequestForQuoteController.isCartAvailable(effectiveAccountId, cartId),
                'communityURL' => b2BSettings != null ? b2BSettings.CommunityURL__c : '',
                'isButtonDisabled' => B2BValidateCartProductsController.thereAreQuoteOnlyProducts(cartId)
            }, '');
        } catch (Exception ex) {
            return new B2BResponse(false,  ex.getMessage());
        }
    }

    @AuraEnabled
    public static B2BResponse calculateShipping(Id cartId) {
        try {
            B2BShippingCalculation.calculateShipping(cartId);
            return new B2BResponse(true);
        } catch (Exception ex) {
            return new B2BResponse(false,  ex.getMessage());
        }
    }

}