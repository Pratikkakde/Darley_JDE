public without sharing class B2BCheckoutPlaceOrder {

    private static Decimal EARNED_DARLEY_DOLLAR_PERCENT = 0.03;
    private static final String DARLEY_DOLLAR_ORIGIN_ORDER = 'Order';
    private static final String ORDER_STATUS_WEB_HOLDER = 'Web Hold';
    private static final String ORDER_STATUS_ACTIVATED = 'Activated';

    public Id orderSummaryId { get; set; }
    private User currentUser { get; set; }

    public B2BCheckoutPlaceOrder(Id webCartId, String paymentIntentId, Decimal darleyDollarAmount, String paymentTransactionId, B2BPayPal.CreditCardDto creditCard) {
        convertCartToOrder(webCartId, paymentIntentId, darleyDollarAmount, paymentTransactionId, creditCard);
    }

    public B2BCheckoutPlaceOrder() {}

    public void convertCartToOrder(Id webCartId, String paymentIntentId, Decimal darleyDollarAmount,String paymentTransactionId, B2BPayPal.CreditCardDto creditCard) {

        WebCart webCart = [
            SELECT
                Id,
                B2BSpecialInstruction__c,
                B2BCreditCardName__c,
                B2BCreditCardId__c,
                Payment_Type__c,
                Status,
                BillingStreet,
                BillingCity,
                BillingState,
                BillingPostalCode,
                BillingCountry,
                PaymentIntentId__c,
                B2BDarleyDollars__c,
                TotalProductAmount,
                TotalTaxAmount,
                TotalPromoAdjustmentAmount,
                GrandTotalAmount,
                B2BPromotions__c,
                Quote__c,
                B2BCheckoutShippingAddress__r.Street,
                B2BCheckoutShippingAddress__r.City,
                B2BCheckoutShippingAddress__r.State,
                B2BCheckoutShippingAddress__r.PostalCode,
                B2BCheckoutShippingAddress__r.Country,
                B2BCheckoutBillingAddress__r.Street,
                B2BCheckoutBillingAddress__r.City,
                B2BCheckoutBillingAddress__r.State,
                B2BCheckoutBillingAddress__r.PostalCode,
                B2BCheckoutBillingAddress__r.Country
            FROM WebCart
            WHERE Id = :webCartId
        ];

        webCart.Status = 'Checkout';
        webCart.BillingStreet = webCart.B2BCheckoutBillingAddress__r.Street;
        webCart.BillingCity = webCart.B2BCheckoutBillingAddress__r.City;
        webCart.BillingState = webCart.B2BCheckoutBillingAddress__r.State;
        webCart.BillingPostalCode = webCart.B2BCheckoutBillingAddress__r.PostalCode;
        webCart.BillingCountry = webCart.B2BCheckoutBillingAddress__r.Country;
        webCart.PaymentIntentId__c = paymentIntentId;
        webCart.B2BDarleyDollars__c = (-1) * darleyDollarAmount;
        webCart.B2BPromotions__c = webCart.TotalPromoAdjustmentAmount;
        webCart.Payment_Transaction_Id__c = paymentTransactionId;
        webCart.B2BCreditCardName__c = creditCard == null ? '' : creditCard.getCardName();

        update webCart;

        CartDeliveryGroup cartDeliveryGroup = [
            SELECT
                Id,
                DeliveryMethodId,
                ShippingInstructions,
                DeliverToStreet,
                DeliverToCity,
                DeliverToState,
                DeliverToPostalCode,
                DeliverToCountry
            FROM CartDeliveryGroup
            WHERE CartId = :webCartId
            LIMIT 1
        ];

        if (cartDeliveryGroup.DeliveryMethodId == null) {
            List<OrderDeliveryMethod> orderDeliveryMethods = [SELECT Id FROM OrderDeliveryMethod WHERE IsActive = TRUE LIMIT 1];
            if (orderDeliveryMethods.isEmpty()) {
                OrderDeliveryMethod method = new OrderDeliveryMethod(
                    Name = 'Delivery Method',
                    IsActive = true
                );
                insert method;

                orderDeliveryMethods.add(method);
            }

            cartDeliveryGroup.DeliveryMethodId = orderDeliveryMethods[0].Id;
        }
        cartDeliveryGroup.ShippingInstructions = webCart.B2BSpecialInstruction__c;
        cartDeliveryGroup.DeliverToStreet = webCart.B2BCheckoutShippingAddress__r.Street;
        cartDeliveryGroup.DeliverToCity = webCart.B2BCheckoutShippingAddress__r.City;
        cartDeliveryGroup.DeliverToState = webCart.B2BCheckoutShippingAddress__r.State;
        cartDeliveryGroup.DeliverToPostalCode = webCart.B2BCheckoutShippingAddress__r.PostalCode;
        cartDeliveryGroup.DeliverToCountry = webCart.B2BCheckoutShippingAddress__r.Country;
        update cartDeliveryGroup;

        List<CartCheckoutSession> sessionsForDelete = [
            SELECT Id, State
            FROM CartCheckoutSession
            WHERE WebCartId = :webCartId
        ];

        if (!sessionsForDelete.isEmpty()) {
            delete sessionsForDelete;
        }

        CartCheckoutSession ccs = new CartCheckoutSession(
            WebCartId = webCartId,
            Name = 'Test',
            State = 'CartToOrder'
        );
        insert ccs;

        Map<String, Object> parameters = new Map<String, Object>{
            'cartId' => webCartId,
            'checkoutSessionId' => ccs.Id,
            'currentState' => 'CartToOrder',
            'nextState' => 'ActivateOrder'
        };

        Flow.Interview cartToOrderSubflow = Flow.Interview.createInterview('B2B_Cart_To_Order', parameters);
        cartToOrderSubflow.start();

        String orderId = (String) cartToOrderSubflow.getVariableValue('orderId');

        initOrderIdOnLogs(webCartId, orderId);
        initCurrentUser();

        Order order = new Order(
            Id = orderId,
            StoreStatus__c = currentUser?.Account.JDE_Address_Number__c == null ? ORDER_STATUS_WEB_HOLDER : ORDER_STATUS_ACTIVATED,
            Payment_Type__c = webCart.Payment_Type__c,
            PaymentIntentId__c = paymentIntentId,
            Quote__c = webCart.Quote__c,
            BillingPhoneNumber = currentUser?.Contact.Phone,
            ShippingCity = webCart.B2BCheckoutShippingAddress__r.City,
            ShippingStreet = webCart.B2BCheckoutShippingAddress__r.Street,
            ShippingState = webCart.B2BCheckoutShippingAddress__r.State,
            ShippingPostalCode = webCart.B2BCheckoutShippingAddress__r.PostalCode,
            ShippingCountry = webCart.B2BCheckoutShippingAddress__r.Country
        );
        update order;

        orderSummaryId = [ SELECT Id FROM OrderSummary WHERE OriginalOrderId = :orderId].Id;

        if (order.BillingPhoneNumber != null) {
            update new OrderSummary(
                    Id = orderSummaryId,
                    BillingPhoneNumber = order.BillingPhoneNumber
            );
        }
/* To use subscription functionality uncomment this part */
//        B2BSubscriptionController.createCheckoutSubscription(webCartId, order.Id);
/* ----------------------------------------------------- */

        /* To use Quote functionality uncomment this part */
        updateQuote(webCart.Quote__c, webCart.TotalTaxAmount);
        /* ----------------------------------------------------- */

        try {
            Decimal earnedDarleyDollars = this.getEarnedDarleyDollars(webCart.TotalProductAmount, webCart.TotalPromoAdjustmentAmount, darleyDollarAmount);
            this.createDarleyDollars(darleyDollarAmount, earnedDarleyDollars, orderId);
        } catch (Exception ex) {}
    }

    @TestVisible
    private void createDarleyDollars(Decimal spentDarleyDollars, Decimal earnedDarleyDollars, Id orderId) {
        if (currentUser?.ContactId != null) {
            List<DarleyDollar__c> darleyDollars = new List<DarleyDollar__c>();

            if (spentDarleyDollars != null && spentDarleyDollars > 0) {
                darleyDollars.add(new DarleyDollar__c(
                    Amount__c = (-1) * spentDarleyDollars,
                    Contact__c = currentUser.ContactId,
                    Order__c = orderId,
                    Origin__c = DARLEY_DOLLAR_ORIGIN_ORDER
                ));
            }

            if (earnedDarleyDollars != null && earnedDarleyDollars > 0 && currentUser?.Account?.OptoutFromDarleyDollars__c == false) {
                darleyDollars.add(new DarleyDollar__c(
                    Amount__c = earnedDarleyDollars,
                    Contact__c = currentUser.ContactId,
                    Order__c = orderId,
                    Origin__c = DARLEY_DOLLAR_ORIGIN_ORDER
                ));
            }

            if (!darleyDollars.isEmpty()) {
                insert darleyDollars;
            }
        }
    }

    @TestVisible
    private Decimal getEarnedDarleyDollars(Decimal subtotal, Decimal promotion, Decimal darleyDollars) {
        Decimal earnedDarleyDollars = 0;
        try {
            earnedDarleyDollars = ((subtotal + promotion - darleyDollars) * EARNED_DARLEY_DOLLAR_PERCENT).round(System.RoundingMode.DOWN);
        } catch(Exception ex) {
            return 0;
        }

        return (earnedDarleyDollars == null || earnedDarleyDollars < 0) ? 0 : earnedDarleyDollars;
    }

    @TestVisible
    private void initCurrentUser() {
        List<User> users = [
                SELECT
                    ContactId,
                    Contact.Phone,
                    Account.JDE_Address_Number__c,
                    Account.OptoutFromDarleyDollars__c
                FROM User
                WHERE Id = :UserInfo.getUserId()
                LIMIT 1
        ];
        if (!users.isEmpty()) {
            currentUser = users[0];
        }
    }

    @TestVisible
    private void initOrderIdOnLogs(Id webCartId, Id orderId) {
        List<Rest_Log__c> logs = [
            SELECT Id, Cart__c, Order__c
            FROM Rest_Log__c
            WHERE Cart__c = :webCartId
        ];

        if (!logs.isEmpty()) {
            for (Rest_Log__c log : logs) {
                log.Order__c = orderId;
            }

            Database.update(logs, false);
        }
    }

    @TestVisible
    private static void updateQuote(Id quoteId, Decimal totalTaxAmount) {
        if (quoteId != null) {
            List<Opportunity> opportunities = [SELECT Id, StageName FROM Opportunity WHERE B2BQuote__c = :quoteId];
            if (!opportunities.isEmpty()) {
                opportunities[0].StageName = 'Closed/Won';
                update opportunities[0];
            }

            update new Quote__c(
                Id = quoteId,
                Status__c = 'Purchased',
                Estimated_Tax__c = totalTaxAmount
            );
        }
    }

}