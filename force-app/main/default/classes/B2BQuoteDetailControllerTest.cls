@IsTest
private class B2BQuoteDetailControllerTest {

    @TestSetup
    private static void makeData() {
        new B2BDefaultTestData().initAllData();

        User communityUser = [SELECT Id, AccountId  FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        Contact contact = [SELECT Id FROM Contact WHERE AccountId = :communityUser.AccountId LIMIT 1];
        Quote__c testQuote = new Quote__c(
            Contact__c = contact.Id,
            Account__c = communityUser.AccountId,
            DateRequested__c = Date.today(),
            Status__c = 'Pending'
        );

        Quote__c testQuote1 = new Quote__c(
            Contact__c = contact.Id,
            Account__c = communityUser.AccountId,
            DateRequested__c = Date.today(),
            Status__c = 'Approved'
        );
        insert new List<Quote__c>{testQuote, testQuote1};

        Product2 product = [SELECT Id FROM Product2 LIMIT 1];

        insert new QuoteItem__c(
            Quote__c = testQuote.Id,
            Product__c = product.Id,
            UnitPrice__c = 100,
            Quantity__c = 2
        );
    }

    @IsTest
    static void initQuote() {
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        Quote__c quote = [SELECT Id FROM Quote__c WHERE Status__c = 'Pending' LIMIT 1];

        Test.startTest();
        System.runAs(communityUser) {
            B2BResponse resultResponse = B2BQuoteDetailController.initQuote(quote.Id, communityUser.AccountId);
            Map<String, Object> result = (Map<String, Object>)resultResponse.responseData;
            B2BQuoteDetailController.QuoteDto quoteDto = (B2BQuoteDetailController.QuoteDto)result.get('quote');

            System.assertEquals(quoteDto.items.size(), 1, 'Amount of Quote Item records is not correct.');
            System.assertEquals(quoteDto.id, quote.Id, 'QuoteDto record is not correct.');

            try {
                resultResponse = B2BQuoteDetailController.initQuote(null, communityUser.AccountId);
                System.assertEquals(System.Label.Something_Went_Wrong_Please_contact_your_System_Administrator, (String)resultResponse.responseMessage);
            } catch(Exception ex) {
                System.assertEquals(
                    ex.getMessage(),
                    Label.B2B_Something_went_wrong_Please_try_again_or_contact_us,
                    'Error message is not correct.'
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void convertToOrderQuote() {
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];

        Test.startTest();
        System.runAs(communityUser) {
            B2BResponse resultResponse = B2BQuoteDetailController.initQuote(quote.Id, communityUser.AccountId);
            Map<String, Object> result = (Map<String, Object>)resultResponse.responseData;
            B2BQuoteDetailController.QuoteDto quoteDto = (B2BQuoteDetailController.QuoteDto)result.get('quote');

            try {
                resultResponse = B2BQuoteDetailController.convertToOrder(quoteDto, communityUser.AccountId);
                result = (Map<String, Object>)resultResponse.responseData;
                System.assert(false, 'Error should be throw because in test mode CartDeliveryGroup record does not exist.');
            } catch(Exception ex) {
                System.assertEquals(
                    ex.getMessage(),
                    Label.B2B_Something_went_wrong_Please_try_again_or_contact_us,
                    'Error message is not correct.'
                );
            }

            WebCart webCart = [SELECT Id FROM WebCart LIMIT 1];
            B2BQuoteDetailController.updateWebCart(webCart.Id, quote.Id, quoteDto);

            System.assertEquals(
                [SELECT Id, Quote__c FROM WebCart WHERE Id = :webCart.Id].Quote__c,
                quote.Id,
                'Web Cart record was not updated.'
            );

            CartDeliveryGroup cartDeliveryGroup = [SELECT Id FROM CartDeliveryGroup WHERE CartId = :webCart.Id];
            List<CartItem> cartItems = [SELECT Id FROM CartItem WHERE CartId = :webCart.Id];
            B2BQuoteDetailController.createCartItems(quoteDto, webCart.Id, cartDeliveryGroup.Id);

            List<CartItem> cartItemsAfterTest = [SELECT Id FROM CartItem WHERE CartId = :webCart.Id];
            System.assertEquals(cartItemsAfterTest.size(), cartItems.size() + 1, 'Cart Item record was not created.');
        }
        Test.stopTest();
    }

    @IsTest
    static void getQuotePdf() {
        User communityUser = [SELECT Id FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        Quote__c quote = [SELECT Id FROM Quote__c WHERE Status__c = 'Pending' LIMIT 1];

        Test.startTest();
        System.runAs(communityUser) {
            B2BResponse result = B2BQuoteDetailController.getQuotePdf(quote.Id);
            System.assert(true, result.isSuccess);
        }
        Test.stopTest();
    }

    @IsTest
    static void checkSecondaryCart() {
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        Product2 testProduct = [SELECT Id FROM Product2 WHERE Name = 'Test Product'];
        WebStore webStore = [SELECT Id FROM WebStore LIMIT 1];

        Test.startTest();
        System.runAs(communityUser) {
            B2BQuoteDetailController.removeSecondaryCarts(webStore.Id, communityUser.AccountId);
            List<WebCart> secondaryCarts = [SELECT Id FROM WebCart WHERE IsSecondary = TRUE];
            System.assert(secondaryCarts.isEmpty(), 'Secondary Cart should be deleted.');

            ConnectApi.CartSummary cartSummary = B2BQuoteDetailController.createSecondaryCart(webStore.Id, communityUser.AccountId);
            System.assertNotEquals(cartSummary, null, 'Secondary Cart should not be NULL.');
        }
        Test.stopTest();
    }

    @IsTest
    static void updateMessageTest() {
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        Contact contact = [SELECT Id FROM Contact WHERE AccountId = :communityUser.AccountId LIMIT 1];
        Quote__c newQuote = B2BTestDataFactory.createQuote(communityUser.AccountId, contact.Id, true, 'Description1');
        Quote__c newQuoteWithoutDescription = B2BTestDataFactory.createQuote(communityUser.AccountId, contact.Id, true, null);
        B2BResponse result, result2;

        System.runAs(communityUser) {
            Test.startTest();
            result = B2BQuoteDetailController.updateMessage(newQuote.Id, 'Description2');
            result2 = B2BQuoteDetailController.updateMessage(newQuoteWithoutDescription.Id, 'New Description');
            Test.stopTest();
        }

        System.assert(true, result.isSuccess);
        System.assert(true, result2.isSuccess);
        List<Quote__c> createdQuote = [SELECT ChangeRequest__c FROM Quote__c WHERE Id =:newQuote.Id];
        List<Quote__c> createdQuoteWithoutDescription = [SELECT ChangeRequest__c FROM Quote__c WHERE Id =:newQuoteWithoutDescription.Id];
        List<ChangeRequestHistory__c> createdChangeRequest = [SELECT Id FROM ChangeRequestHistory__c WHERE Quote__c =:newQuote.Id];
        List<ChangeRequestHistory__c> createdChangeRequest2 = [SELECT Id FROM ChangeRequestHistory__c WHERE Quote__c =:newQuoteWithoutDescription.Id];

        System.assertEquals('Description2', createdQuote[0].ChangeRequest__c);
        System.assertEquals('New Description', createdQuoteWithoutDescription[0].ChangeRequest__c);
        System.assertEquals(1, createdChangeRequest.size());
        System.assertEquals(0, createdChangeRequest2.size());
    }

    @IsTest
    static void checkCheckoutQuote() {
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];

        WebCart cart = [SELECT Id, Quote__c FROM WebCart LIMIT 1];
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];

        Order order = new Order(
            AccountId = communityUser.AccountId,
            PoNumber = '34234',
            Status = 'Draft',
            Payment_Type__c = 'Invoice',
            EffectiveDate = Date.today()
        );
        insert order;

        insert new Opportunity(
            Name = 'Test',
            B2BQuote__c = quote.Id,
            StageName = 'Quoted Opportunity',
            CloseDate = Date.today().addDays(2)
        );

        System.runAs(communityUser) {
            Test.startTest();
            B2BResponse resultResponse = B2BQuoteDetailController.initQuote(quote.Id, communityUser.AccountId);
            Map<String, Object> result = (Map<String, Object>)resultResponse.responseData;
            B2BQuoteDetailController.QuoteDto quoteDto = (B2BQuoteDetailController.QuoteDto)result.get('quote');

            B2BQuoteDetailController.updateWebCart(cart.Id, quote.Id, quoteDto);

            Test.stopTest();
        }

        System.assertEquals(1, [SELECT Quote__c FROM WebCart WHERE Quote__c = :quote.Id].size(), 'WebCart was not updated.');
    }
}