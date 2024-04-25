@IsTest
private  class B2BCreditCardsControllerTest {
    @TestSetup
    static void makeData(){
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initCustomerUserData();
        Contact userContact = (Contact) initData.get(B2BDefaultTestData.CUSTOMER_CONTACT);
        update userContact;
       
        User commUser = ((User) initData.get(B2BDefaultTestData.COMMUNITY_USER));

        List<CustomerCardPayment__c> cards = new List<CustomerCardPayment__c>();

        cards.add(new CustomerCardPayment__c(
            Name = 'TEST VISA 1',
            Card_Type__c = 'VISA',
            Is_Default__c = true,
            Card_Last_Four__c = '1234',
            Contact__c =  userContact.Id,
            Expiration_Month__c = '10',
            Expiration_Year__c = '29',
            Token__c = '215122'
        ));

        cards.add(new CustomerCardPayment__c(
            Name = 'TEST VISA 2',
            Card_Type__c = 'VISA',
            Is_Default__c = false,
            Card_Last_Four__c = '9876',
            Contact__c =  userContact.Id,
            Expiration_Month__c = '10',
            Expiration_Year__c = '28',
            Token__c = '215128'
        ));

        insert cards;
    }


    @IsTest
    private static void makeCardDefaultTest() {
        User commUser = [SELECT Id FROM User WHERE email = 'TestEmail@test.coom'];
        CustomerCardPayment__c card = [SELECT Id FROM CustomerCardPayment__c WHERE Name = 'TEST VISA 2'] ;
        B2BResponse response;

        System.runAs(commUser) {
            Test.startTest();
               response = B2BCreditCardsController.makeCardDefault(card.Id);

            Test.stopTest();
            System.assertEquals(true, response.isSuccess);
        }
        card = [SELECT Id, Is_Default__c FROM CustomerCardPayment__c WHERE Name = 'TEST VISA 2'] ;
        System.assert(card.Is_Default__c, 'Card must be default');
    }



    @IsTest
    private static void getCreditCardsTest() {
        User commUser = [SELECT Id FROM User WHERE email = 'TestEmail@test.coom'];
        B2BResponse response;

        System.runAs(commUser) {
            Test.startTest();
            response = B2BCreditCardsController.getCreditCards();

            Test.stopTest();

            System.assertEquals(true, response.isSuccess);
        }
        Map<String, Object> responseData = (Map<String, Object>)response.responseData;
        List<B2BCreditCardsController.Card> cards = (List<B2BCreditCardsController.Card>) responseData.get('cards');
        System.assertEquals(2, cards.size(), 'the user has two cards');
    }



    @IsTest
    private static void addCreditCardToCustomerTest() {
        User commUser = [SELECT Id FROM User WHERE email = 'TestEmail@test.coom'];
        String contentType = 'application/x-www-form-urlencoded';
        String body = 'RESULT=0&PNREF=A40F1A8F8C8C&RESPMSG=Approved&AUTHCODE=010101&AVSADDR=Y&AVSZIP=Y&HOSTCODE=AA&'
                        +'RESPTEXT=APPROVAL&PROCAVS=Y&VISACARDLEVEL=12&TRANSTIME=2023-04-13 16:38:22&AMT=1.00&'
                        +'ACCT=1881&EXPDATE=1225&CARDTYPE=0&IAVS=N&PREFPSMSG=No Rules Triggered&POSTFPSMSG=No Rules Triggered';
        B2BResponse response;

        System.runAs(commUser) {
            Test.startTest();

            Test.setMock(HttpCalloutMock.class, new B2BPayPalTest.PayPalMockHttpResponseGenerator(contentType, body, 200));
            B2BRSA rsa = new B2BRSA();

            B2BCreditCardsController.Card newCard  = new B2BCreditCardsController.Card();
            newCard.cardName = 'New MasterCard';
            newCard.cardNumber = rsa.encrypt('5105105105105100');
            newCard.cvc = rsa.encrypt('123');
            newCard.cardType = 'MasterCard';
            newCard.expiryMonth = rsa.encrypt('03');
            newCard.expiryYear  = rsa.encrypt('28');
            newCard.isDefault = true;

            response = B2BCreditCardsController.createPaymentMethod(newCard);

            Test.stopTest();

            System.assertEquals(true, response.isSuccess);
        }

        List<CustomerCardPayment__c> cards = [SELECT Id, Is_Default__c FROM CustomerCardPayment__c ] ;
        System.assertEquals(3, cards.size(), 'The customer must have 3 credit cards');
    }

    @IsTest
    private static void deleteCreditCardFromCustomerTest() {
        User commUser = [SELECT Id FROM User WHERE email = 'TestEmail@test.coom'];
        CustomerCardPayment__c card = [SELECT Id FROM CustomerCardPayment__c WHERE Name = 'TEST VISA 2'] ;
        B2BResponse response;

        System.runAs(commUser) {
            Test.startTest();
               response = B2BCreditCardsController.deleteCreditCardFromCustomer(card.Id);

            Test.stopTest();
            System.assertEquals(true, response.isSuccess);
        }
        List<CustomerCardPayment__c> cards = [SELECT Id, Is_Default__c FROM CustomerCardPayment__c WHERE Name = 'TEST VISA 2'] ;
        System.assertEquals(0, cards.size(), 'Card must be deleted');
    }
}