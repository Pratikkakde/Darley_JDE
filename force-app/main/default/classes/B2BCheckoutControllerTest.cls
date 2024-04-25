@IsTest
private without sharing class B2BCheckoutControllerTest {

    @TestSetup
    private static void makeData() {
        new B2BDefaultTestData().initAllData();
    }

    @IsTest
    private static void initAddresses() {
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        WebCart webCart = [SELECT Id FROM WebCart LIMIT 1];

        Test.startTest();
        System.runAs(communityUser) {
            B2BResponse response = B2BCheckoutController.initAddresses(webCart.Id);
            System.assert(response.isSuccess, 'Response should not contain any error');

            Map<String, Object> responseData = (Map<String, Object>)response.responseData;
            B2BCheckoutAddress addresses = (B2BCheckoutAddress)responseData.get('addresses');
            System.assertEquals(addresses.billingAddresses.size(), 0, 'Billing Addresses should not exist.');
            System.assertEquals(addresses.shippingAddresses.size(), 0, 'Shipping Addresses should not exist.');

            insert new ContactPointAddress(
                AddressType = 'Billing',
                Name = 'Billing Address',
                ParentId = communityUser.AccountId,
                IsDefault = false,
                Country = 'United States',
                State = 'Texas',
                City = 'Austin',
                Street = 'Test Address',
                PostalCode = '73301'
            );

            response = B2BCheckoutController.initAddresses(webCart.Id);
            System.assertEquals(
                [SELECT Id FROM ContactPointAddress WHERE ParentId = :communityUser.AccountId AND AddressType = 'Billing'].size(),
                1,
                'Billing Address was not created.'
            );
            responseData = (Map<String, Object>)response.responseData;
            addresses = (B2BCheckoutAddress)responseData.get('addresses');
            System.assertEquals(addresses.billingAddresses.size(), 1, 'Billing Address should exist.');

            ContactPointAddress currentDefaultShipping = new ContactPointAddress(
                AddressType = 'Shipping',
                Name = 'Shipping Address Default',
                ParentId = communityUser.AccountId,
                IsDefault = true,
                Country = 'United States',
                State = 'Texas',
                City = 'Houston',
                Street = 'Test Address',
                PostalCode = '73301'
            );
            insert currentDefaultShipping;
            response = B2BCheckoutController.initAddresses(webCart.Id);

            responseData = (Map<String, Object>)response.responseData;
            addresses = (B2BCheckoutAddress)responseData.get('addresses');
            System.assertEquals(addresses.billingAddresses.size(), 1, 'Billing Address should exist.');
            System.assertEquals(addresses.shippingAddresses.size(), 1, 'Shipping Address should exist.');

            response = B2BCheckoutController.useAddress(webCart.Id, currentDefaultShipping.Id, addresses.billingAddresses[0].id);
            System.assertEquals(
                [SELECT B2BCheckoutShippingAddress__c FROM WebCart WHERE Id = :webCart.Id].B2BCheckoutShippingAddress__c,
                currentDefaultShipping.Id,
                'Selected Shipping Address is not correct.'
            );

            response = B2BCheckoutController.useAddress(null, null, null);
            System.assert(!response.isSuccess, 'Response should not be success');

            delete [SELECT Id FROM ContactPointAddress WHERE AddressType = 'Billing'];
            response = B2BCheckoutController.initAddresses(webCart.Id);
            System.assertEquals(
                [SELECT Id FROM ContactPointAddress WHERE ParentId = :communityUser.AccountId AND AddressType = 'Billing'].size(),
                0,
                'Billing Address was not deleted.'
            );

            response = B2BCheckoutController.initAddresses(null);
            System.assert(!response.isSuccess, 'Response should not be success');
        }
        Test.stopTest();
    }

    @IsTest
    private static void addAddress() {
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        WebCart webCart = [SELECT Id FROM WebCart LIMIT 1];

        Test.startTest();
        System.runAs(communityUser) {
            B2BCheckoutAddress.AddressDto addressNew = new B2BCheckoutAddress.AddressDto();
            addressNew.addressType = 'Shipping';
            addressNew.name = 'Shipping Address';
            addressNew.parentId = communityUser.AccountId;
            addressNew.country = 'United States';
            addressNew.state = 'Texas';
            addressNew.city = 'Houston';
            addressNew.street = 'Test Address';
            addressNew.postalCode = '73301';
            addressNew.isDefault = false;

            B2BResponse response = B2BCheckoutController.addAddress(addressNew, webCart.Id);
            System.assert(response.isSuccess, 'Response should be success.');
            System.assertEquals(
                [SELECT Id FROM ContactPointAddress WHERE ParentId = :communityUser.AccountId AND AddressType = 'Shipping'].size(),
                1,
                'Address was not created.'
            );

            response = B2BCheckoutController.addAddress(addressNew, null);
            System.assert(!response.isSuccess, 'Response should not be success');
        }
        Test.stopTest();
    }

    @IsTest
    private static void initCartItems() {
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        WebCart webCart = [SELECT Id FROM WebCart LIMIT 1];

        Test.startTest();
        System.runAs(communityUser) {
            B2BResponse response = B2BCheckoutController.initCartItems(webCart.Id);
            Map<String, Object> responseData = (Map<String, Object>)response.responseData;
            List<B2BCheckoutCartItems.CartItemDto> cartItems = (List<B2BCheckoutCartItems.CartItemDto>)responseData.get('cartItems');

            System.assert(response.isSuccess, 'Response should be success.');
            System.assertEquals(cartItems.size(), 1, 'Cart Item records should be return.');

            response = B2BCheckoutController.initCartItems(null);
            System.assert(!response.isSuccess, 'Response should not be success');
        }
        Test.stopTest();
    }

    @IsTest
    private static void testInstruction() {
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        WebCart webCart = [SELECT Id FROM WebCart LIMIT 1];

        Test.startTest();
        System.runAs(communityUser) {
            String instruction = 'Test Instruction';
            B2BResponse response = B2BCheckoutController.updateInstruction(webCart.Id, instruction);

            System.assert(response.isSuccess, 'Response should be success.');
            System.assertEquals(
                [SELECT B2BSpecialInstruction__c FROM WebCart WHERE Id = :webCart.Id].B2BSpecialInstruction__c,
                instruction,
                'Special Instruction was not updated.'
            );

            response = B2BCheckoutController.updateInstruction(null, instruction);
            System.assert(!response.isSuccess, 'Response should not be success.');

            response = B2BCheckoutController.initInstruction(webCart.Id);
            Map<String, Object> responseData = (Map<String, Object>)response.responseData;
            String responseInstruction = (String)responseData.get('instruction');
            System.assertEquals(instruction, responseInstruction, 'Instruction is not corrected.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void updatePONumber() {
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        WebCart webCart = [SELECT Id FROM WebCart LIMIT 1];

        Test.startTest();
        System.runAs(communityUser) {
            String poNumber = 'Test_Number';
            B2BResponse response = B2BCheckoutController.updatePoNumber(webCart.Id, poNumber);

            System.assert(response.isSuccess, 'Response should be success.');
            System.assertEquals(
                [SELECT PoNumber FROM WebCart WHERE Id = :webCart.Id].PoNumber,
                poNumber,
                'PO Number was not updated.'
            );

            response = B2BCheckoutController.updatePoNumber(null, poNumber);
            System.assert(!response.isSuccess, 'Response should not be success.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void initPayment() {
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        WebCart webCart = [SELECT Id FROM WebCart LIMIT 1];

        webCart.B2BCreditCardId__c = 'pm_1M6a4yGtX2332';
        webCart.B2BCreditCardName__c = 'Visa ending in 1111';
        update webCart;

        Test.startTest();
        System.runAs(communityUser) {
            B2BResponse response = B2BCheckoutController.initPayment(webCart.Id);
            Map<String, Object> responseData = (Map<String, Object>)response.responseData;
            B2BCheckoutPayment payment = (B2BCheckoutPayment)responseData.get('payment');
            System.assert(response.isSuccess, 'Response should be success.');
            System.assertNotEquals(payment.metadata, null, 'Metadata should ne exist.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void setPaymentMethod() {
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        WebCart webCart = [SELECT Id FROM WebCart LIMIT 1];

        Test.startTest();
        System.runAs(communityUser) {
            String paymentMethod = 'Credit Card';
            B2BResponse response = B2BCheckoutController.setPaymentMethod(webCart.Id, paymentMethod);
            System.assert(response.isSuccess, 'Response should be success.');
            System.assertEquals(
                [SELECT Payment_Type__c FROM WebCart WHERE Id = :webCart.Id].Payment_Type__c,
                paymentMethod,
                'Payment Method was not updated.'
            );

            response = B2BCheckoutController.setPaymentMethod(null, paymentMethod);
            System.assert(!response.isSuccess, 'Response should not be success.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void useCard() {
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        WebCart webCart = [SELECT Id FROM WebCart LIMIT 1];

        Test.startTest();
        System.runAs(communityUser) {
            String creditCardId = 'testId';
            String creditCardName = 'testName';
            B2BResponse response = B2BCheckoutController.useCard(webCart.Id, creditCardId, creditCardName);
            System.assert(response.isSuccess, 'Response should be success.');

            webCart = [SELECT B2BCreditCardName__c, B2BCreditCardId__c FROM WebCart WHERE Id = :webCart.Id];
            System.assertEquals(webCart.B2BCreditCardName__c, creditCardName, 'Credit Card Name was not updated.');
            System.assertEquals(webCart.B2BCreditCardId__c, creditCardId, 'Credit Card Id was not updated.');

            response = B2BCheckoutController.useCard(null, null, null);
            System.assert(!response.isSuccess, 'Response should not be success.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void initOrderSummary() {
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        WebCart webCart = [SELECT Id, B2BCheckoutBillingAddress__c, B2BCheckoutShippingAddress__c FROM WebCart LIMIT 1];
        List<CartItem> cartItems = [SELECT Id FROM CartItem WHERE CartId = :webCart.Id];

        List<ContactPointAddress> addresses = new List<ContactPointAddress> {
            new ContactPointAddress(
                AddressType = 'Billing',
                Name = 'Billing Address',
                ParentId = communityUser.AccountId,
                IsDefault = false,
                Country = 'United States',
                State = 'Texas',
                City = 'Austin',
                Street = 'Test Address',
                PostalCode = '73301'
            ),
            new ContactPointAddress(
                AddressType = 'Shipping',
                Name = 'Billing Address',
                ParentId = communityUser.AccountId,
                IsDefault = false,
                Country = 'United States',
                State = 'Texas',
                City = 'Austin',
                Street = 'Test Address',
                PostalCode = '73301'
            )
        };
        insert addresses;

        webCart.B2BCheckoutBillingAddress__c = addresses[0].Id;
        webCart.B2BCheckoutShippingAddress__c = addresses[1].Id;
        update webCart;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2BAvalaraTest.B2BAvalaraMock(false, cartItems));

        System.runAs(communityUser) {
            B2BResponse response = B2BCheckoutController.initOrderSummary(webCart.Id);
            System.assert(response.isSuccess, 'Response should be success.');

            response = B2BCheckoutController.initOrderSummary(null);
            System.assert(!response.isSuccess, 'Response should not be success.');
        }
        Test.stopTest();
    }

    /*@IsTest
    private static void placeOrder() {
        WebCart webCart = [SELECT Id, B2BCheckoutBillingAddress__c, B2BCheckoutShippingAddress__c FROM WebCart LIMIT 1];
        webCart.B2BPaymentMethod__c = 'Invoice';
        update webCart;

        Test.startTest();
        B2BResponse response = B2BCheckoutController.placeOrder(webCart.Id, 'Test');
        System.assert(response.isSuccess, 'Response should be success.');

        response = B2BCheckoutController.placeOrder(null, 'Test');
        System.assert(!response.isSuccess, 'Response should not be success.');
        Test.stopTest();
    }*/

    @IsTest
    private static void deleteAllTaxes() {
        WebCart webCart = [SELECT Id FROM WebCart LIMIT 1];
        B2BResponse response = B2BCheckoutController.deleteAllTaxes(webCart.Id);

        System.assertEquals(response.isSuccess, true);
    }

    @IsTest
    private static void calculateTaxes() {
        WebCart webCart = [SELECT Id, AccountId, B2BCheckoutShippingAddress__c FROM WebCart LIMIT 1];
        User communityUser = [SELECT Id, AccountId  FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];

        ContactPointAddress shipToAddress = new ContactPointAddress(
            AddressType = 'Shipping',
            Name = 'Billing Address',
            ParentId = webCart.AccountId,
            IsDefault = false,
            Country = 'United States',
            State = 'Texas',
            City = 'Austin',
            Street = 'Test Address',
            PostalCode = '73301'
        );

        insert shipToAddress;

        webCart.B2BCheckoutShippingAddress__c = shipToAddress.Id;
        update webCart;
        B2BResponse response;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2BAvalaraTest.B2BAvalaraMock(false, [SELECT Id FROM CartItem WHERE CartId = :webCart.Id]));
        System.runAs(communityUser) {
            response = B2BCheckoutController.calculateTaxes(webCart.Id);
        }

        System.assertEquals(response.isSuccess, true);
        Test.stopTest();
    }

    @IsTest
    static void testSaveCreditCard() {
        User communityUser = [SELECT Id, AccountId, ContactId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];

        B2BPayPalWrapper.paymentInfo paymentInfo = new B2BPayPalWrapper.paymentInfo();
        paymentInfo.crediCardNumber = '4012888888881881';// visa
        paymentInfo.crediCardExpirationDate = '1225';
        paymentInfo.crediCardCVC = '123';
        paymentInfo.billtozip = '15544';
        paymentInfo.amount = 0;//  Im setting this in the back
        paymentInfo.savePaymentMethod = true;
        paymentInfo.cartType = 'VISA'; // You need to send  this value
        paymentInfo.cardHolderName = 'Juan T';
        paymentInfo.isDefault = true; // determine if is default

        String contentType = 'application/x-www-form-urlencoded';
        String body = 'RESULT=0&PNREF=A40F1A8F8C8C&RESPMSG=Approved&AUTHCODE=010101&AVSADDR=Y&AVSZIP=Y&HOSTCODE=AA&'
                        +'RESPTEXT=APPROVAL&PROCAVS=Y&VISACARDLEVEL=12&TRANSTIME=2023-04-13 16:38:22&AMT=1.00&'
                        +'ACCT=1881&EXPDATE=1225&CARDTYPE=0&IAVS=N&PREFPSMSG=No Rules Triggered&POSTFPSMSG=No Rules Triggered';

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new B2BPayPalTest.PayPalMockHttpResponseGenerator(contentType, body, 200));
            System.runAs(communityUser) {
//                B2BResponse response = B2BCheckoutController.saveCreditCard(paymentInfo);
//                System.assert(response.isSuccess, 'Response should be success.');
//                List<CustomerCardPayment__c> customerCardPayments =  [SELECT Id
//                                                                        FROM CustomerCardPayment__c
//                                                                        WHERE  Is_Default__c = true
//                                                                            AND Contact__c =: communityUser.ContactId ];
//                System.assertEquals(1, customerCardPayments.size(), 'It must return 1 CustomerCardPayment__c record');
            }
        Test.stopTest();
    }

    @IsTest
    static void testAthorizeCreditCard() {
        User communityUser = [SELECT Id, AccountId, ContactId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];

        CustomerCardPayment__c newCustomerCardPayment = new CustomerCardPayment__c(
            Contact__c = communityUser.ContactId,
            Card_Type__c = 'Visa',
//            Card_Holder_Name__c = 'Test user',
            Card_Last_Four__c = '1234',
            Name = 'Visa ending in 1234',
            Is_Default__c = true,
            Token__c = 'HSLID56DHDIDU'
        );
        insert newCustomerCardPayment;
        
        B2BPayPalWrapper.paymentInfo paymentInfo = new B2BPayPalWrapper.paymentInfo();
        paymentInfo.billtozip = '15544';
        paymentInfo.amount = 10;
        paymentInfo.savePaymentMethod = false;
        paymentInfo.selectedCustomerCardPaymentId = newCustomerCardPayment.Id; 

        String contentType = 'application/x-www-form-urlencoded';
        String body = 'RESULT=0&PNREF=A40F1A8F8C8C&RESPMSG=Approved&AUTHCODE=010101&AVSADDR=Y&AVSZIP=Y&HOSTCODE=AA&'
                        +'RESPTEXT=APPROVAL&PROCAVS=Y&VISACARDLEVEL=12&TRANSTIME=2023-04-13 16:38:22&AMT=1.00&'
                        +'ACCT=1881&EXPDATE=1225&CARDTYPE=0&IAVS=N&PREFPSMSG=No Rules Triggered&POSTFPSMSG=No Rules Triggered';

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new B2BPayPalTest.PayPalMockHttpResponseGenerator(contentType, body, 200));
            System.runAs(communityUser) {
//                B2BResponse response = B2BCheckoutController.authorizeCreditCard(paymentInfo);
//                System.assert(response.isSuccess, 'Response should be success.');
            }
        Test.stopTest();
    }

    @IsTest
    static void testGetAvalaraEcommerceToken() {
        WebCart webCart = [SELECT Id, AccountId, B2BCheckoutShippingAddress__c FROM WebCart LIMIT 1];
        B2BResponse response;
        Map<String, String> responseBodies = new Map<String, String>{B2BAvalaraTest.AVALARA_TOKEN_TEST_ENDPOINT => '{"token":"1234fdsgfd7834"}', B2BAvalaraTest.AVALARA_COMPANY_TEST_ENDPOINT => '{"value":[{"id":22222,"accountId":25878787,"companyCode":"11111"}]}'};
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2BAvalaraTest.MockHttpResponseGenerator(200,responseBodies));
        response = B2BCheckoutController.getAvalaraEcommerceToken(webCart.AccountId);
        Test.stopTest();
        System.assert(response.isSuccess, 'Response should be successful');
    }

    @isTest
    private static void checkPlaceOrder() {
        User communityUser = [SELECT Id, AccountId, ContactId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        B2BRSA rsa = new B2BRSA();

        B2BPayPal.CreditCardDto creditCard = new B2BPayPal.CreditCardDto();
        creditCard.name = 'Test Card';
        creditCard.cardType = 'Visa';
        creditCard.isDefault = false;
        creditCard.cardNumber = rsa.encrypt('4111111111111111');
        creditCard.expirationDate = rsa.encrypt('1224');
        creditCard.cvv = rsa.encrypt('123');
        creditCard.lastFour = '1111';
        creditCard.amount = 50;
        creditCard.isSaveCard = true;

        String contentType = 'application/x-www-form-urlencoded';
        String body = 'RESULT=0&PNREF=A40F1A8F8C8C&RESPMSG=Approved&AUTHCODE=010101&AVSADDR=Y&AVSZIP=Y&HOSTCODE=AA&'
                +'RESPTEXT=APPROVAL&PROCAVS=Y&VISACARDLEVEL=12&TRANSTIME=2023-04-13 16:38:22&AMT=1.00&'
                +'ACCT=1881&EXPDATE=1225&CARDTYPE=0&IAVS=N&PREFPSMSG=No Rules Triggered&POSTFPSMSG=No Rules Triggered';

        WebCart webCart = [SELECT Id FROM WebCart LIMIT 1];
        insert new CartCheckoutSession(
            WebCartId = webCart.Id,
            Name = 'Test',
            State = 'CartToOrder'
        );

        Quote__c quote = new Quote__c(Account__c = communityUser.AccountId);
        insert quote;

        Opportunity opportunity = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId(),
            Name = 'Test',
            AccountId = communityUser.AccountId,
            B2BQuote__c = quote.Id,
            StageName = 'Quoted Opportunity',
            CloseDate = Date.today().addDays(1)
        );
        insert opportunity;

        Test.startTest();
        System.runAs(communityUser) {
            Test.setMock(HttpCalloutMock.class, new B2BPayPalTest.PayPalMockHttpResponseGenerator(contentType, body, 200));

            B2BCheckoutController.placeOrder(webCart.Id, 'testPaymentIntentId', 12, creditCard, '', '12');
            System.assertEquals(1, [SELECT Id FROM CustomerCardPayment__c].size(), 'CustomerCard record was not created.');

            B2BCheckoutPlaceOrder.updateQuote(quote.Id, 100);
            Test.stopTest();
        }
        System.assertEquals('Closed/Won', [SELECT StageName FROM Opportunity WHERE B2BQuote__c = :quote.Id LIMIT 1].StageName, 'Stage Name was not updated.');
        System.assertEquals('Purchased', [SELECT Status__c FROM Quote__c WHERE Id = :quote.Id].Status__c, 'Quote Status was not updated.');
    }

    @isTest
    private static void checkDarleyDollars() {
        User communityUser = [SELECT Id, AccountId, ContactId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        WebCart webCart = [SELECT Id FROM WebCart LIMIT 1];

        Order order = new Order(
                AccountId = communityUser.AccountId,
                Status = 'Draft',
                EffectiveDate = Date.today()
        );
        insert order;

        insert new CartCheckoutSession(
            WebCartId = webCart.Id,
            Name = 'Test',
            State = 'CartToOrder'
        );

        Test.startTest();
        System.runAs(communityUser) {
            B2BCheckoutPlaceOrder placeOrder = new B2BCheckoutPlaceOrder();
            placeOrder.orderSummaryId = null;
            placeOrder.initCurrentUser();
            placeOrder.createDarleyDollars(12, 2, order.Id);
            Test.stopTest();

            System.assertEquals(2, [SELECT Id FROM DarleyDollar__c].size(), 'DarleyDollar record was not created.');
            System.assertEquals(-12, [SELECT Id, Amount__c FROM DarleyDollar__c WHERE Amount__c < 0 LIMIT 1 ].Amount__c, 'Spent DarleyDollar amount is not correct.');
            System.assertEquals(2, [SELECT Id, Amount__c FROM DarleyDollar__c WHERE Amount__c > 0 LIMIT 1].Amount__c, 'Earned DarleyDollar amount is not correct.');

            Decimal earnedDarleyDollar = placeOrder.getEarnedDarleyDollars(149, -19.80, 37);
            System.assertEquals(2, earnedDarleyDollar, 'Earned Darley Dollar is not correct.');

            earnedDarleyDollar = placeOrder.getEarnedDarleyDollars(149, -19.80, null);
            System.assertEquals(0, earnedDarleyDollar, 'Earned Darley Dollar is not correct.');

            earnedDarleyDollar = placeOrder.getEarnedDarleyDollars(149, -149, 300);
            System.assertEquals(0, earnedDarleyDollar, 'Earned Darley Dollar is not correct.');
        }
    }

    @isTest
    private static void calculateShipping() {
        User communityUser = [SELECT Id, AccountId, ContactId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        WebCart webCart = [SELECT Id FROM WebCart LIMIT 1];

        Test.startTest();
        System.runAs(communityUser) {
            B2BCheckoutController.calculateShipping(webCart.Id);
            Test.stopTest();

            List<CartItem> cartItems = [SELECT Id FROM CartItem WHERE CartId =: webCart.Id AND Name = 'Delivery Cart Item' ];
            System.assertEquals(1, cartItems.size(),'One charge item must be created.');
        }
    }

    @IsTest
    private static void checkOrderIdOnLogs() {
        User communityUser = [SELECT Id, AccountId, ContactId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        WebCart webCart = [SELECT Id FROM WebCart LIMIT 1];

        Order order = new Order(
            AccountId = communityUser.AccountId,
            Status = 'Draft',
            EffectiveDate = Date.today()
        );
        insert order;

        Rest_Log__c log = new Rest_Log__c(
            Cart__c = webCart.Id
        );
        insert log;

        Test.startTest();
        System.runAs(communityUser) {
            new B2BCheckoutPlaceOrder().initOrderIdOnLogs(webCart.Id, order.Id);
            Test.stopTest();
        }

        List<Rest_Log__c> logs = [SELECT Id, Order__c FROM Rest_Log__c];
        System.assertEquals(1, logs.size(), 'Log record should exist.');
        System.assertEquals(logs[0].Order__c, order.Id, 'Order Id on log record was not updated.');
    }
}