public without sharing class B2BRequestForQuoteController {
    private static final String SOMETHING_WENT_WRONG_MESSAGE = System.Label.Something_Went_Wrong_Please_contact_your_System_Administrator;

    @AuraEnabled
    public static B2BResponse deleteAllTaxes(Id cartId) {
        return B2BCheckoutController.deleteAllTaxes(cartId);
    }

    @AuraEnabled
    public static B2BResponse initAddresses(Id cartId) {
        try {
            return new B2BResponse(true, new Map<String, Object>{
                'addresses' => new B2BCheckoutAddress(cartId)
            }, '');
        } catch (Exception ex) {
            return new B2BResponse(false, ex.getMessage());
        }
    }


    @AuraEnabled
    public static B2BResponse calculateTaxes(Id cartId) {
        return B2BCheckoutController.calculateTaxes(cartId);
    }

    @AuraEnabled
    public static B2BResponse isRequestQuoteEnabled(Id effectiveAccountId) {
        try {
            B2BSettings__c b2BSettings = B2BSettings__c.getInstance();

            return new B2BResponse(true,
                new Map<String, Object> {
                    'isCartAvailable' => isCartAvailable(effectiveAccountId),
                    'communityURL' => b2BSettings != null ? b2BSettings.CommunityURL__c : ''
                }, 'Success');
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage() + ' ' + e.getLineNumber(), SOMETHING_WENT_WRONG_MESSAGE);
        }
    }

    @AuraEnabled
    public static B2BResponse getCartId(Id effectiveAccountId) {
        try {
            String webStoreId =  B2BUtils.getStoreIdRelatedToCurrentUser();
            ConnectApi.CartSummary cartSummary =  getCartSummary(webStoreId,effectiveAccountId);
            return new B2BResponse(true,cartSummary.cartId, 'Success');
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage() + ' ' + e.getLineNumber(), SOMETHING_WENT_WRONG_MESSAGE);
        }
    }

    @AuraEnabled
    public static B2BResponse getQuoteRequestDetail(Id effectiveAccountId, Id cartId) {
        try {
            return new B2BResponse(true, getQuoteDetails(effectiveAccountId, cartId), 'Success');
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage() + ' ' + e.getLineNumber(), SOMETHING_WENT_WRONG_MESSAGE);
        }
    }


    @AuraEnabled
    public static B2BResponse updateCartCheckoutShippingAddress(Id cartId, Id shippingAddressId, Id billingAddressId) {
        try {
            B2BCheckoutService.updateCheckoutAddress(cartId, shippingAddressId, billingAddressId);
            return new B2BResponse(true,'OK', 'Success');
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage() + ' ' + e.getLineNumber(), SOMETHING_WENT_WRONG_MESSAGE);
        }
    }

    @AuraEnabled
    public static B2BResponse saveQuoteRequest(SaveQuoteResquet saveQuoteResquet) {
        try {
            WebCart cart =  getCartDetail(saveQuoteResquet.cartId);

            User currentUser = getCurrentUserInfo();
            Quote__c newQuote = new Quote__c(
                Account__c = saveQuoteResquet.effectiveAccountId,
                Billing_Address__c = saveQuoteResquet.billingAddressId,
                Contact__c = currentUser.ContactId,
                DateRequested__c = System.today(), 
                Description__c = saveQuoteResquet.message,
                Estimated_Shipping__c = 0,
                Estimated_Tax__c = saveQuoteResquet.quoteEstimatedTax,
                Shipping_Address__c = saveQuoteResquet.shippingAddressId,
                Status__c = 'Pending'
            );
            insert newQuote;

            Map<Id, Decimal> darleyCostByProductId = calculateDarleyCost(currentUser.Account, cart.cartItems);

            List<QuoteItem__c> newQuoteItems = new List<QuoteItem__c>();
            for (CartItem cartItemRecord : cart.cartItems) {
                newQuoteItems.add(new QuoteItem__c(
                    Quote__c  = newQuote.Id,
                    Product__c = cartItemRecord.Product2Id,
                    UnitPrice__c = cartItemRecord.SalesPrice,
                    OriginalPrice__c = cartItemRecord.SalesPrice,
                    Promotions__c = cartItemRecord.TotalAdjustmentAmount,
                    Quantity__c = cartItemRecord.Quantity,
                    B2BDarleyCost__c = darleyCostByProductId.containsKey(cartItemRecord.Product2Id) ? darleyCostByProductId.get(cartItemRecord.Product2Id) : 0
                ));
            }

            insert newQuoteItems;
            Quote__c quote = [SELECT Id, Name FROM Quote__c WHERE Id = : newQuote.Id];

            Decimal darleyCostTotal = getDarleyCostTotal(darleyCostByProductId);
            B2BOpportunityService.createOpportunity(currentUser.Account, cart, quote, darleyCostTotal);
            return new B2BResponse(true, new Map<String, String>{'id' => quote.Id, 'name' => quote.Name}, 'Success');
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage() + ' ' + e.getLineNumber(), SOMETHING_WENT_WRONG_MESSAGE);
        }
    }

    private static Decimal getDarleyCostTotal(Map<Id, Decimal> darleyCostByProductId) {
        Decimal darleyCostTotal = 0;
        for (Decimal cost : darleyCostByProductId.values()) {
            darleyCostTotal += cost;
        }

        return darleyCostTotal;
    }

    private static Map<Id, Decimal> calculateDarleyCost(Account account, List<CartItem> cartItems) {
        Id currentStoreId = B2BUtils.getStoreIdRelatedToCurrentUser();
        List<BuyerGroupMember> buyerGroupMembers = [
            SELECT Id, BuyerGroupId
            FROM BuyerGroupMember
            WHERE BuyerId = :account.Id
                AND BuyerGroupId IN (
                    SELECT BuyerGroupId FROM WebStoreBuyerGroup WHERE WebStoreId = :currentStoreId
                )
        ];

        Map<Id, Decimal> darleyCostByProductId = new Map<Id, Decimal>();
        if (!buyerGroupMembers.isEmpty()) {
            Set<Id> pricebook2Ids = new Set<Id>();
            for (BuyerGroupPricebook buyerGroupPricebook: [
                SELECT Id, Pricebook2Id
                FROM BuyerGroupPricebook
                WHERE BuyerGroupId = :buyerGroupMembers[0].BuyerGroupId
                    AND IsActive = TRUE
            ]) {
                pricebook2Ids.add(buyerGroupPricebook.Pricebook2Id);
            }

            if (!pricebook2Ids.isEmpty()) {
                Map<Id, Decimal> productQuantityById = new Map<Id, Decimal>();
                for (CartItem cartItem : cartItems) {
                    productQuantityById.put(cartItem.Product2Id, cartItem.Quantity);
                }

                String productId;
                Decimal darleyCost = 0;
                for (AggregateResult result : [
                    SELECT MAX(Standard_Cost__c), Product2Id
                    FROM PricebookEntry
                    WHERE Pricebook2Id IN :pricebook2Ids
                        AND Product2Id IN :productQuantityById.keySet()
                        AND Standard_Cost__c != NULL
                    GROUP BY Product2Id
                ]) {
                    productId = (String)result.get('Product2Id');
                    darleyCost = result.get('expr0') == null ? 0 : ((Decimal)result.get('expr0')) * productQuantityById.get(productId);

                    darleyCostByProductId.put(productId, darleyCost);
                }
            }
        }

        return darleyCostByProductId;
    }

    @AuraEnabled
    public static B2BResponse getCountryStateFieldsPicklistOptions() {
        try {
            Map<String, Object> responseMap =   new Map<String, Object> { 'contries' => B2BCountryStatePicklists.getCountryByCode(),
            'countriesStatesCode' => B2BCountryStatePicklists.getStatesByCountryCode(B2BCountryStatePicklists.getCountryByCode()) };

            return new B2BResponse(true, responseMap, 'Success');
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage() + ' ' + e.getLineNumber(), SOMETHING_WENT_WRONG_MESSAGE);
        }
    }

    @AuraEnabled
    public static B2BResponse createAddress(ContactPointAddress address) {
        try {
            upsert address;
        return new B2BResponse(true,address , 'Success');
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage() + ' ' + e.getLineNumber(), SOMETHING_WENT_WRONG_MESSAGE);
        }
    }

    @AuraEnabled
    public static B2BResponse saveCusomerNumber(Id effectiveAccountId, String customerNumber) {
        try {
            Account acc = new Account(Id = effectiveAccountId, B2BAvalaraCustomerCode__c = customerNumber);
            update acc;
            return new B2BResponse(true, acc , 'Success');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static B2BResponse getCustomerTaxInfo(Id cartId) {
        try {
            return new B2BResponse(
                true, 
                new Map<String, Object> {'customerTaxInformation' => B2BCheckoutOrderSummary.getCustomerTaxInformation(cartId)},
                ''
            );
        } catch (Exception ex) {
            return new B2BResponse(false,  ex.getMessage());
        }
    }

    public static Set<Id> getValidProducts(String effectiveAccountId, Set<Id> productIds){
        Set<Id> productsData = new Set<Id>();
        List<CommerceEntitlementBuyerGroup> policyForUserBuyerGroup = [
            SELECT BuyerGroupId, PolicyId
            FROM CommerceEntitlementBuyerGroup 
            WHERE BuyerGroupId IN 
                (
                    SELECT BuyerGroupId
                    FROM BuyerGroupMember 
                    WHERE BuyerId = :effectiveAccountId
                )
        ];

        Set<Id> entitlementPolicies = new Set<Id>();

        for (CommerceEntitlementBuyerGroup policy : policyForUserBuyerGroup) {
            entitlementPolicies.add(policy.PolicyId);
        }

        Set<Id> validProducts = new Set<Id>();
        for (CommerceEntitlementProduct cep: [
            SELECT ProductId
                FROM CommerceEntitlementProduct
                WHERE ProductId IN:productIds
                    AND Policy.IsActive = TRUE
                    AND Policy.CanViewProduct = TRUE
                    AND Product.IsActive = TRUE
                    AND PolicyId IN :entitlementPolicies]){
            validProducts.add(cep.ProductId);
        }
        return validProducts;
    }

    private static WebCart getCartDetail(Id cartId){
        return [SELECT
            Id,
            TotalPromoAdjustmentAmount,//quotePromotions
            TotalAmount, //quoteSubtotal
            TotalProductAmount, //Subtotal
            GrandTotalAmount,//quoteTotal,
            TotalTaxAmount,
            B2BCheckoutBillingAddress__c,
            B2BCheckoutShippingAddress__c,
            (
                SELECT
                    Id,
                    Product2Id,
                    Product2.Name,
                    Name,
                    Sku,
                    Quantity,
                    SalesPrice,
                    TotalLineNetAmount,
                    TotalAdjustmentAmount                    
                FROM CartItems 
                WHERE Type NOT IN ('Charge')
            )
            FROM WebCart
            WHERE Id =: cartId ];
    }

    private static List<ContactPointAddress> getAddresses(Id acountId, String aType) {
        return [
            SELECT
                AddressType,
                City,
                Country,
                CountryCode,
                Id,
                IsDefault,
                IsPrimary,
                Name,
                PostalCode,
                State,
                StateCode,
                Street
            FROM ContactPointAddress
            WHERE Parentid =: acountId AND AddressType =: aType ];
    }

    private static User getCurrentUserInfo() {
        List<User> users = [
            SELECT
                Id,
                Name,
                Email,
                ContactId,
                AccountId,
                Account.Name,
                Account.JDE_Address_Number__c,
                Contact.Name
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];

        return users.isEmpty()
            ? null
            : users[0];
    }

    public static ConnectApi.CartSummary getCartSummary(String webStoreId, Id accountId) {
        if (Test.isRunningTest()) {
            List<WebCart> carts = [
                SELECT Id, AccountId 
                FROM WebCart 
                ORDER BY CreatedDate DESC 
                LIMIT 1
            ];
            
            ConnectApi.CartSummary cartSummary = new ConnectApi.CartSummary();
            cartSummary.cartId = carts[0].Id;
            cartSummary.accountId = carts[0].AccountId;
            return cartSummary;
        }
        return ConnectApi.CommerceCart.getOrCreateActiveCartSummary(webStoreId, accountId, 'active');
    }

    private static QuoteRequestDetail getQuoteDetails(Id effectiveAccountId, Id cartId) {
        WebCart cart = getCartDetail(cartId);

        QuoteRequestDetail quoteRequestDetail = new QuoteRequestDetail();
        quoteRequestDetail.quoteDetail = new QuoteDetail();
        quoteRequestDetail.quoteDetail.quoteLineItemDetails = new List<QuoteLineItemDetail>();

        for (CartItem carItemRecord : cart.cartItems) {
            QuoteLineItemDetail quoteLineItemDetail = new QuoteLineItemDetail();
            quoteLineItemDetail.productName = carItemRecord.Name;
            quoteLineItemDetail.quoteLineItemProductId = carItemRecord.Product2Id;
            quoteLineItemDetail.productPromotion = carItemRecord.TotalAdjustmentAmount;
            quoteLineItemDetail.productQuantity = Integer.valueOf(carItemRecord.Quantity);
            quoteLineItemDetail.totalAmount = carItemRecord.TotalLineNetAmount;
            quoteLineItemDetail.productSku = carItemRecord.Sku;
            quoteLineItemDetail.quoteLineItemDetailId = null;
            quoteLineItemDetail.unitPrice = carItemRecord.SalesPrice;
            quoteRequestDetail.quoteDetail.quoteLineItemDetails.add(quoteLineItemDetail);
        }

        quoteRequestDetail.quoteDetail.quoteNumber = null;
        quoteRequestDetail.quoteDetail.quotePromotions = cart.TotalPromoAdjustmentAmount;
        quoteRequestDetail.quoteDetail.quoteSubtotal = cart.TotalProductAmount;
        quoteRequestDetail.quoteDetail.quoteTotal = cart.GrandTotalAmount;
        quoteRequestDetail.quoteDetail.quoteEstimatedShipping = 0;
        quoteRequestDetail.quoteDetail.message = '';
        quoteRequestDetail.quoteDetail.quoteEstimatedTax = cart.TotalTaxAmount;
        quoteRequestDetail.quoteDetail.quoteId = null;
        quoteRequestDetail.availableShippingAddresses = getAddresses(effectiveAccountId, 'Shipping');
        quoteRequestDetail.availableBillingAddresses = getAddresses(effectiveAccountId, 'Billing');
        quoteRequestDetail.selectedBillingAddress = cart.B2BCheckoutBillingAddress__c;
        quoteRequestDetail.selectedShippingAddress = cart.B2BCheckoutShippingAddress__c;

        return quoteRequestDetail;
    }

    public static Boolean isCartAvailable(Id effectiveAccountId) {
        String webStoreId =  B2BUtils.getStoreIdRelatedToCurrentUser();
        ConnectApi.CartSummary cartSummary =  getCartSummary(webStoreId,effectiveAccountId);

        return isCartAvailable(effectiveAccountId, cartSummary.cartId);
    }

    public static Boolean isCartAvailable(Id effectiveAccountId, Id cartId) {
        Set<Id> productIds = new Set<Id>();
        for (CartItem currentCartItem : [ SELECT Id, Product2Id FROM CartItem  WHERE CartId =: cartId]) {
            productIds.add(currentCartItem.Product2Id);
        }

        Set<Id> validProducts = getValidProducts(effectiveAccountId, productIds);
        return !validProducts.isEmpty();
    }

    public class QuoteRequestDetail{
        @auraenabled public QuoteDetail quoteDetail{get;set;}
        @auraenabled public List<ContactPointAddress> availableShippingAddresses{get;set;}
        @auraenabled public List<ContactPointAddress> availableBillingAddresses{get;set;}
        @auraenabled public String selectedBillingAddress{get;set;}
        @auraenabled public String selectedShippingAddress{get;set;}
    }

    public class QuoteDetail{
        @auraenabled public String quoteId{get;set;}
        @auraenabled public String quoteNumber{get;set;}
        @auraenabled public String message{get;set;}
        @auraenabled public Decimal quoteSubtotal{get;set;}
        @auraenabled public Decimal quoteEstimatedTax{get;set;}
        @auraenabled public Decimal quoteEstimatedShipping{get;set;}
        @auraenabled public Decimal quotePromotions{get;set;}
        @auraenabled public Decimal quoteTotal{get;set;}
        @auraenabled public List<QuoteLineItemDetail> quoteLineItemDetails{get;set;}
    }

    public class QuoteLineItemDetail{
        @auraenabled public String quoteLineItemDetailId{get;set;}
        @auraenabled public String quoteLineItemProductId{get;set;}
        @auraenabled public String productName{get;set;}
        @auraenabled public String productSku{get;set;}
        @auraenabled public Integer productQuantity{get;set;}
        @auraenabled public Decimal productPromotion{get;set;}
        @auraenabled public Decimal totalAmount{get;set;}
        @auraenabled public Decimal unitPrice{get;set;}
    }

    public class SaveQuoteResquet{
        @auraenabled public String effectiveAccountId{get;set;}
        @auraenabled public String cartId{get;set;}
        @auraenabled public String message{get;set;}
        @auraenabled public String shippingAddressId{get;set;}
        @auraenabled public String billingAddressId{get;set;}
        @auraenabled public Decimal quoteEstimatedTax{get;set;}
        
    }
}