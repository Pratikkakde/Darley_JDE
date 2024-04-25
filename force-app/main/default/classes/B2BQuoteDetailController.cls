public without sharing class B2BQuoteDetailController {

    private static final String SOMETHING_WENT_WRONG_MESSAGE = System.Label.Something_Went_Wrong_Please_contact_your_System_Administrator;
    private static final String CART_ITEM_DELIVERY_NAME = 'Delivery Cart Item';

    @AuraEnabled
    public static B2BResponse initQuote(Id quoteId, Id accountId) {
        Map<String, QuoteDto> result = new Map<String, QuoteDto>();

        String quoteStrId = String.isNotBlank(quoteId) ? String.escapeSingleQuotes(quoteId) : '';
        String query =
            'SELECT Id, Name, DateRequested__c, ExpirationDate__c, Status__c,' +
            '(SELECT Id, Product__c, Product__r.StockKeepingUnit, Product__r.Name, Quantity__c, UnitPrice__c, Total__c, SubTotal__c, Promotions__c FROM QuoteItems__r), ' +
            'Shipping_Address__r.street, Shipping_Address__r.city, Shipping_Address__r.state, Shipping_Address__r.postalCode, ' +
            'Shipping_Address__r.countryCode, Billing_Address__r.street, Billing_Address__r.city, Billing_Address__r.state, ' +
            'Billing_Address__r.postalCode, Billing_Address__r.countryCode, Quote_Subtotal__c, Estimated_Tax__c, Estimated_Shipping__c, ' +
            'Estimated_Quote_Total__c , Promotions__c, Billing_Address__c, Shipping_Address__c ' +
            'FROM Quote__c ' +
            'WHERE Id = :quoteStrId ';
        
        if (String.isNotBlank(accountId)) {
            String accountStrId = String.escapeSingleQuotes(accountId);
            query += ' AND Account__c = :accountStrId';
        }

        List<Quote__c> quotes = Database.query(query);

        if (quotes.size() == 0) {
            return new B2BResponse(false, SOMETHING_WENT_WRONG_MESSAGE);
        }

        result.put('quote', new QuoteDto(quotes[0]));

        return new B2BResponse(true, result, 'Success');
    }

    @AuraEnabled
    public static B2BResponse convertToOrder(QuoteDto quoteDto, Id effectiveAccountId) {
        Map<String, Object> result = new Map<String, Object>();

        String webStoreId = B2BUtils.getStoreIdRelatedToCurrentUser();
        removeSecondaryCarts(webStoreId, effectiveAccountId);

        ConnectApi.CartSummary cartSummary = createSecondaryCart(webStoreId, effectiveAccountId);
        Id cartDeliveryGroupId = getCartDeliveryGroupId(cartSummary.cartId);

        createCartItems(quoteDto, cartSummary.cartId, cartDeliveryGroupId);
        createTax(quoteDto);
        createDeliveryItem(quoteDto, cartSummary.cartId, cartDeliveryGroupId);
        updateWebCart(cartSummary.cartId, quoteDto.id, quoteDto);

        result.put('activeCartId', cartSummary.cartId);

        return new B2BResponse(true, result, 'Success');
    }

    private static Id getCartDeliveryGroupId(Id cartId) {
        List<CartDeliveryGroup> cartDeliveryGroups = [
            SELECT Id
            FROM CartDeliveryGroup
            WHERE CartId = :cartId
        ];

        if (cartDeliveryGroups.size() == 0) {
            throw new B2BQuoteDetailControllerException(Label.B2B_Something_went_wrong_Please_try_again_or_contact_us);
        }

        return cartDeliveryGroups[0].Id;
    }

    @TestVisible
    private static void createCartItems(QuoteDto quoteDto, Id cartId, Id cartDeliveryGroupId) {
        List<CartItem> cartItems = quoteDto.getCartItems(cartId, cartDeliveryGroupId);
        insert cartItems;

        Map<Id, CartItem> cartItemByProductId = new Map<Id, CartItem>();
        for (CartItem cartItem : cartItems) {
            cartItemByProductId.put(cartItem.Product2Id, cartItem);
        }

        for (QuoteItemDto quoteItemDto : quoteDto.items) {
            quoteItemDto.cartItemId = cartItemByProductId.get(quoteItemDto.productId)?.Id;
        }
    }

    private static void createTax(QuoteDto quoteDto) {
        if (quoteDto.items != null && !quoteDto.items.isEmpty()) {
            insert new CartTax(
                Amount = quoteDto.estimatedTax,
                CartItemId = quoteDto.items[0].cartItemId,
                Name = 'Tax',
                TaxCalculationDate = Date.today(),
                TaxRate = 0,
                TaxType = 'Actual'
            );
        }
    }

    private static void createDeliveryItem(QuoteDto quoteDto, Id cartId, Id cartDeliveryGroupId) {
        if (quoteDto.items != null && !quoteDto.items.isEmpty() && quoteDto.estimatedShipping > 0) {
            Product2 shippingProduct = B2BShippingCalculation.getShippingProductId();
            insert new CartItem(
                Type = 'Charge',
                Product2Id = shippingProduct != null ? shippingProduct.Id : quoteDto.items[0].productId,
                Quantity = 1.0,
                TotalPrice = quoteDto.estimatedShipping,
                ListPrice = quoteDto.estimatedShipping,
                TotalListPrice = quoteDto.estimatedShipping,
                TotalLineAmount = quoteDto.estimatedShipping,
                AdjustmentAmount = 0.0,
                CartId = cartId,
                CartDeliveryGroupId = cartDeliveryGroupId,
                Name = shippingProduct != null ? shippingProduct.Name : CART_ITEM_DELIVERY_NAME
            );
        }
    }

    @TestVisible
    private static void updateWebCart(Id webCartId, Id quoteId, QuoteDto quoteDto) {
        update new WebCart(
            Id = webCartId,
            Quote__c = quoteId,
            B2BCheckoutBillingAddress__c = quoteDto.billingAddressId,
            B2BCheckoutShippingAddress__c = quoteDto.shippingAddressId
        );
    }

    @AuraEnabled
    public static B2BResponse getQuotePdf(String recordId) {
        try {
            return new B2BResponse(true, prepareQuotePdf(recordId), '');
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage(), SOMETHING_WENT_WRONG_MESSAGE);
        }
    }

    public static String prepareQuotePdf(String recordId) {
        PageReference pdf = new pagereference('/sfsites/c/apex/b2bQuotePrint?id=' + recordId);
        pdf.getParameters().put('id', recordId);

        Blob body;
        String base64;
        try {
            body = pdf.getContent();
            base64 = EncodingUtil.base64Encode(body);
        } catch (Exception e) {
            throw new quoteException(e.getMessage());
        }

        return base64;
    }

    public static void removeSecondaryCarts(Id webStoreId, Id effectiveAccountId) {
        Id userId = UserInfo.getUserId();

        List<WebCart> secondaryWebCarts = [
            SELECT Id
            FROM WebCart
            WHERE IsSecondary = TRUE
                AND WebStoreId = :webStoreId
                AND AccountId = :effectiveAccountId
                AND Status != 'Closed'
                AND Status != 'Deleted'
                AND CreatedById = :userId
        ];

        if (!secondaryWebCarts.isEmpty()) {
            delete secondaryWebCarts;
        }
    }

    public static ConnectApi.CartSummary createSecondaryCart(Id webStoreId, Id effectiveAccountId) {
        ConnectApi.CartInput secondaryCart = new ConnectApi.CartInput();
        secondaryCart.isSecondary = true;
        secondaryCart.effectiveAccountId = effectiveAccountId;

        return Test.isRunningTest() ? new ConnectApi.CartSummary() : ConnectApi.CommerceCart.createCart(webStoreId, secondaryCart);
    }

    @AuraEnabled
    public static B2BResponse updateMessage(Id quoteId, String description) {
        try {
            Quote__c quote = [
                SELECT Id, ChangeRequest__c
                FROM Quote__c
                WHERE Id = :quoteId
            ];

            if (quote.ChangeRequest__c != description && quote.ChangeRequest__c != null ) {
                String body = quote.ChangeRequest__c;
                ChangeRequestHistory__c newChangeRequest = new ChangeRequestHistory__c();
                newChangeRequest.Quote__c = quoteId;
                newChangeRequest.ChangeRequest__c = body;
                insert newChangeRequest;
            }
            quote.ChangeRequest__c = description;
            quote.CommentAddedFlag__c = true;
            update quote;
            quote.CommentAddedFlag__c = false;
            return new B2BResponse(true, 'Success');
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage(), SOMETHING_WENT_WRONG_MESSAGE);
        }
    }

    public class quoteException extends Exception {}

    public class QuoteDto {
        @AuraEnabled public Id id { get; set; }
        @AuraEnabled public String quoteNumber { get; set; }
        @AuraEnabled public Date requestedDate { get; set; }
        @AuraEnabled public Date expirationDate { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public Decimal total { get; set; }
        @AuraEnabled public List<QuoteItemDto> items { get; set; }

        @AuraEnabled public String shippingAddressStreet { get; set; }
        @AuraEnabled public String shippingAddressCity { get; set; }
        @AuraEnabled public String shippingAddressState { get; set; }
        @AuraEnabled public String shippingAddressPostalCode { get; set; }
        @AuraEnabled public String shippingAddressCountryCode { get; set; }

        @AuraEnabled public String billingAddressStreet { get; set; }
        @AuraEnabled public String billingAddressCity { get; set; }
        @AuraEnabled public String billingAddressState { get; set; }
        @AuraEnabled public String billingAddressPostalCode { get; set; }
        @AuraEnabled public String billingAddressCountryCode { get; set; }

        @AuraEnabled public Decimal quoteSubtotal { get; set; }
        @AuraEnabled public Decimal estimatedTax { get; set; }
        @AuraEnabled public Decimal estimatedShipping { get; set; }
        @AuraEnabled public Decimal estimatedQuoteTotal { get; set; }
        @AuraEnabled public Decimal promotions { get; set; }

        @AuraEnabled public Id billingAddressId { get; set; }
        @AuraEnabled public Id shippingAddressId { get; set; }


        public QuoteDto() {}

        public QuoteDto(Quote__c quote) {
            this.id = quote.Id;
            this.quoteNumber = quote.Name;
            this.requestedDate = quote.DateRequested__c;
            this.expirationDate = quote.ExpirationDate__c;
            this.status = quote.Status__c;
            this.total = quote.Estimated_Quote_Total__c;
            this.shippingAddressStreet = quote.Shipping_Address__r.street;
            this.shippingAddressCity = quote.Shipping_Address__r.city;
            this.shippingAddressState = quote.Shipping_Address__r.state;
            this.shippingAddressPostalCode = quote.Shipping_Address__r.postalCode;
            this.shippingAddressCountryCode = quote.Shipping_Address__r.countryCode;
            this.billingAddressStreet = quote.Billing_Address__r.street;
            this.billingAddressCity = quote.Billing_Address__r.city;
            this.billingAddressState = quote.Billing_Address__r.state;
            this.billingAddressPostalCode = quote.Billing_Address__r.postalCode;
            this.billingAddressCountryCode = quote.Billing_Address__r.countryCode;
            this.quoteSubtotal = quote.Quote_Subtotal__c;
            this.estimatedTax = quote.Estimated_Tax__c;
            this.estimatedShipping = quote.Estimated_Shipping__c;
            this.estimatedQuoteTotal = quote.Estimated_Quote_Total__c;
            this.promotions = quote.promotions__c;

            this.billingAddressId = quote.Billing_Address__c;
            this.shippingAddressId = quote.Shipping_Address__c;

            this.items = new List<QuoteItemDto>();
            for (QuoteItem__c item : quote.QuoteItems__r) {
                items.add(new QuoteItemDto(item));
            }

        }

        private List<CartItem> getCartItems(Id cartId, Id cartDeliveryGroupId) {
            List<CartItem> cartItems = new List<CartItem>();
            for (QuoteItemDto item : this.items) {
                cartItems.add(item.getCartItem(cartId, cartDeliveryGroupId));
            }

            return cartItems;
        }

    }

    public class QuoteItemDto {
        @AuraEnabled public Id id { get; set; }
        @AuraEnabled public Id productId { get; set; }
        @AuraEnabled public Id cartItemId { get; set; }
        @AuraEnabled public String SKU { get; set; }
        @AuraEnabled public String productName { get; set; }
        @AuraEnabled public Decimal quantity { get; set; }
        @AuraEnabled public Decimal unitPrice { get; set; }
        @AuraEnabled public Decimal total { get; set; }
        @AuraEnabled public Decimal promotions { get; set; }

        public QuoteItemDto() {}

        public QuoteItemDto(QuoteItem__c item) {
            this.id = item.Id;
            this.productId = item.Product__c;
            this.SKU = item.Product__r.StockKeepingUnit;
            this.productName = item.Product__r.Name;
            this.quantity = item.Quantity__c;
            this.unitPrice = item.UnitPrice__c != null ? item.UnitPrice__c : 0;
            this.total = item.SubTotal__c;
            this.promotions = item.Promotions__c;
        }

        private CartItem getCartItem(Id cartId, Id cartDeliveryGroupId) {
            return new CartItem(
                Product2Id = this.productId,
                Quantity = this.quantity,
                SalesPrice = this.unitPrice,
                TotalPrice = this.unitPrice * this.quantity,
                TotalLineAmount = this.unitPrice * this.quantity,
                CartId = cartId,
                CartDeliveryGroupId = cartDeliveryGroupId,
                Type = 'Product',
                Name = this.productName,
                Sku = this.SKU,
                TotalPromoAdjustmentAmount = this.promotions
            );
        }
    }

    public class B2BQuoteDetailControllerException extends Exception {}
}