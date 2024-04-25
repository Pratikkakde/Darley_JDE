public without sharing class B2BCreditCardsController {

    private static Id getContactId(){
        User currentUser = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
        return currentUser.ContactId;
    }

    @AuraEnabled
    public static B2BResponse createPaymentMethod(Card card) {
        try {
            card.decrypt();

            Id contactId = getContactId();
            B2BPayPalWrapper.paymentInfo paymentInfo = new B2BPayPalWrapper.paymentInfo();
            paymentInfo.crediCardNumber = card.cardNumber;
            String expMonth = String.isNotBlank(card.expiryMonth) && card.expiryMonth.length() == 1 ? '0'+ card.expiryMonth : card.expiryMonth;
            String expYear = String.isNotBlank(card.expiryYear) ? card.expiryYear.right(2) : card.expiryYear;
            paymentInfo.crediCardExpirationDate = expMonth + expYear;
            paymentInfo.crediCardCVC = card.cvc;
            B2BPayPal.staticRecordId = contactId;
            B2BPayPalWrapper.PaymentInfoResponse  payFlowResponse =  B2BPayPal.validateCard(paymentInfo);

            if (payFlowResponse.result == '0') {
                List<CustomerCardPayment__c> cards = new List<CustomerCardPayment__c>();
                if (card.isDefault) {
                   cards = [ SELECT Id, Is_Default__c FROM CustomerCardPayment__c WHERE Contact__c =: contactId AND Is_Token_Expired__c = FALSE];
                    for ( CustomerCardPayment__c currentCard: cards) {
                        currentCard.Is_Default__c = false;
                    }
                }

                cards.add(new CustomerCardPayment__c(
                    Name = card.cardName,
                    Card_Type__c = card.cardType,
                    Is_Default__c = card.isDefault,
                    Card_Last_Four__c = card.cardNumber.right(4),
                    Contact__c =  contactId,
                    Expiration_Month__c = expMonth,
                    Expiration_Year__c = card.expiryYear,
                    Token__c = payFlowResponse.pnref
                ));
                upsert cards;
                return new B2BResponse(true, true, '');
            }else{
                return new B2BResponse(false, 'Something went wrong. Please try again later.');
            }
        } catch (Exception e) {
            return new B2BResponse(false, 'Something went wrong. Please try again later.');
        }
    }


    @AuraEnabled
    public static B2BResponse makeCardDefault(Id cardId) {
        try {
            List<CustomerCardPayment__c> cards = [ SELECT Id, Is_Default__c FROM CustomerCardPayment__c
                                                    WHERE Contact__c =: getContactId() AND Is_Token_Expired__c = FALSE AND Id !=: cardId];
            for ( CustomerCardPayment__c  card: cards) {
                card.Is_Default__c = false;
            }

            cards.add(new CustomerCardPayment__c(Id = cardId, Is_Default__c = true));
            update cards;

            return new B2BResponse(true, 'Success');
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage());
        }
    }

    @AuraEnabled
    public static B2BResponse getCreditCards() {
        try {
            
            List<Card> cards = new List<Card>();
            for (CustomerCardPayment__c paymentCard : [ SELECT Card_Last_Four__c, Card_Type__c, Contact__c, Id, Is_Default__c,
                                                        Is_Token_Expired__c, Name, Expiration_Month__c, Expiration_Year__c
                                                        FROM CustomerCardPayment__c
                                                        WHERE Contact__c =: getContactId() AND Is_Token_Expired__c = FALSE]) {
                Card currentCard = new Card();
                currentCard.cardName = paymentCard.Name;
                currentCard.cardNumber = String.isNotBlank(paymentCard.Card_Last_Four__c) ?  paymentCard.Card_Last_Four__c.leftPad(8, '*') : null;
                currentCard.cardType = paymentCard.Card_Type__c;
                currentCard.expiryMonth = paymentCard.Expiration_Month__c;
                currentCard.expiryYear = paymentCard.Expiration_Year__c;
                currentCard.isDefault = paymentCard.Is_Default__c;
                currentCard.paymentMethodId = paymentCard.Id;
                cards.add(currentCard);
            }

            return new B2BResponse(true, new Map<String, Object> {
                'cards' => cards,
                'publicKey' => B2BRSA.MODULE,
                'publicExponent' => B2BRSA.PUBLIC_EXPONENT
            }, '');
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage());
        }
    }

    @AuraEnabled
    public static B2BResponse deleteCreditCardFromCustomer(Id cardId) {
        try {
            delete new CustomerCardPayment__c(Id = cardId);
            return new B2BResponse(true, 'Success');
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage());
        }
    }

    public class Card {
        @AuraEnabled public String cardName {get;set;}
        @AuraEnabled public String paymentMethodId {get;set;}
        @AuraEnabled public String cardNumber {get;set;}
        @AuraEnabled public String cvc {get;set;}
        @AuraEnabled public String cardType {get;set;}
        @AuraEnabled public String expiryMonth {get;set;}
        @AuraEnabled public String expiryYear {get;set;}
        @AuraEnabled public Boolean isDefault {get;set;}

        public void decrypt() {
            B2BRSA rsa = new B2BRSA();
            cardNumber = cardNumber == null ? cardNumber : rsa.decrypt(cardNumber);
            expiryMonth = expiryMonth == null ? expiryMonth : rsa.decrypt(expiryMonth);
            expiryYear = expiryYear == null ? expiryYear : rsa.decrypt(expiryYear);
            cvc = cvc == null ? cvc : rsa.decrypt(cvc);
        }
    }
}