@IsTest
public class B2BPayPalTest {

    @TestSetup
    private static void makeData() {
        new B2BDefaultTestData().initAllData();
    }

    @IsTest
    private static void paypalSimplePaymentPositiveTest() {
        B2BPayPal payPal = new B2BPayPal();
        String contentType = 'application/x-www-form-urlencoded';
        String body = 'RESULT=0&PNREF=A40F1A8F8C8C&RESPMSG=Approved&AUTHCODE=010101&AVSADDR=Y&AVSZIP=Y&HOSTCODE=AA&'
                        +'RESPTEXT=APPROVAL&PROCAVS=Y&VISACARDLEVEL=12&TRANSTIME=2023-04-13 16:38:22&AMT=1.00&'
                        +'ACCT=1881&EXPDATE=1225&CARDTYPE=0&IAVS=N&PREFPSMSG=No Rules Triggered&POSTFPSMSG=No Rules Triggered';

        B2BPayPalWrapper.PaymentInfoResponse paymentInfoResponse;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new PayPalMockHttpResponseGenerator(contentType, body, 200));
            B2BPayPalWrapper.paymentInfo paymentInfo= new  B2BPayPalWrapper.paymentInfo();
            paymentInfo.amount = 1;
            paymentInfo.crediCardCVC = '123';
            paymentInfo.savePaymentMethod = false;
            paymentInfo.crediCardExpirationDate = '12/26';
            paymentInfo.crediCardNumber = '1234561881';
            
            paymentInfoResponse = payPal.authorize(paymentInfo);
        Test.stopTest();
        System.assertEquals('0', paymentInfoResponse.result);
        System.assertEquals('1881', paymentInfoResponse.acct);
    }

    @IsTest
    private static void paypalSavePaymentPositiveTest() {
        B2BPayPal payPal = new B2BPayPal();
        String contentType = 'application/x-www-form-urlencoded';
        String body = 'RESULT=0&PNREF=A40F1A8F8C8C&RESPMSG=Approved&AUTHCODE=010101&AVSADDR=Y&AVSZIP=Y&HOSTCODE=AA&'
                        +'RESPTEXT=APPROVAL&PROCAVS=Y&VISACARDLEVEL=12&TRANSTIME=2023-04-13 16:38:22&AMT=1.00&'
                        +'ACCT=1881&EXPDATE=1225&CARDTYPE=0&IAVS=N&PREFPSMSG=No Rules Triggered&POSTFPSMSG=No Rules Triggered';

        B2BPayPalWrapper.PaymentInfoResponse paymentInfoResponse;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new PayPalMockHttpResponseGenerator(contentType, body, 200));
            B2BPayPalWrapper.paymentInfo paymentInfo= new  B2BPayPalWrapper.paymentInfo();
            paymentInfo.amount = 1;
            paymentInfo.crediCardCVC = '123';
            paymentInfo.savePaymentMethod = true;
            paymentInfo.crediCardExpirationDate = '12/26';
            paymentInfo.crediCardNumber = '1234561881';
            
            paymentInfoResponse = payPal.authorize(paymentInfo);
        Test.stopTest();
        System.assertEquals('0', paymentInfoResponse.result);
        System.assertEquals('1881', paymentInfoResponse.acct);
    }

    @IsTest
    private static void paypalSavedMethodPaymentPositiveTest() {
        B2BPayPal payPal = new B2BPayPal();
        String contentType = 'application/x-www-form-urlencoded';
        String body = 'RESULT=0&PNREF=A40F1A8F8C8C&RESPMSG=Approved&AUTHCODE=010101&AVSADDR=Y&AVSZIP=Y&HOSTCODE=AA&'
                        +'RESPTEXT=APPROVAL&PROCAVS=Y&VISACARDLEVEL=12&TRANSTIME=2023-04-13 16:38:22&AMT=1.00&'
                        +'ACCT=1881&EXPDATE=1225&CARDTYPE=0&IAVS=N&PREFPSMSG=No Rules Triggered&POSTFPSMSG=No Rules Triggered';

        B2BPayPalWrapper.PaymentInfoResponse paymentInfoResponse;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new PayPalMockHttpResponseGenerator(contentType, body, 200));
            B2BPayPalWrapper.paymentInfo paymentInfo= new  B2BPayPalWrapper.paymentInfo();
            paymentInfo.amount = 1;
            paymentInfo.originalTransactionReferencedId = 'A40F1A8F8C8C';
                        
            paymentInfoResponse = payPal.authorize(paymentInfo);
        Test.stopTest();
        System.assertEquals('0', paymentInfoResponse.result);
        System.assertEquals('1881', paymentInfoResponse.acct);
    }

    @IsTest
    private static void paypalSimplePaymentNegativeTest() {
        User communityUser = [SELECT Id, AccountId, ContactId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        B2BPayPal payPal = new B2BPayPal();
        payPal.setRecordId(communityUser.ContactId);
    
        String contentType = 'application/x-www-form-urlencoded';
        String body = '';

        B2BPayPalWrapper.PaymentInfoResponse paymentInfoResponse;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new PayPalMockHttpResponseGenerator(contentType, body, 404));
            B2BPayPalWrapper.paymentInfo paymentInfo= new  B2BPayPalWrapper.paymentInfo();
            paymentInfo.amount = 1;
            paymentInfo.crediCardCVC = '123';
            paymentInfo.savePaymentMethod = false;
            paymentInfo.crediCardExpirationDate = '12/26';
            paymentInfo.crediCardNumber = '1234561881';
            try {
                paymentInfoResponse = payPal.authorize(paymentInfo);
            } catch (Exception e) {
                System.assertEquals(e.getMessage(), 'Response body is empty. Please check you PayPal configuration settings.');
            }
        
        Test.stopTest();
        List<Rest_Log__c> logs = [SELECT Response_Code__c, Response_Body__c,  Request_Body__c FROM Rest_Log__c];
        System.assertEquals(1, logs.size(), 'It must return 1 Log record');
        System.assert(String.isBlank(logs.get(0).Request_Body__c), 'No request can be saved');

    }

    @IsTest
    private static void checkGettingCards() {
        User communityUser = [SELECT Id, AccountId, ContactId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];

        Contact testContact = new Contact(LastName = 'Test', AccountId = communityUser.AccountId);
        insert testContact;

        insert new List<CustomerCardPayment__c> {
            new CustomerCardPayment__c(
                Contact__c = communityUser.ContactId,
                Name = 'Test Card1',
                Card_Type__c = 'Visa',
                Is_Default__c = false,
                Card_Last_Four__c = '1111',
                Expiration_Month__c = '11',
                Expiration_Year__c = '2026'
            ),
            new CustomerCardPayment__c(
                Contact__c = communityUser.ContactId,
                Name = 'Test Card2',
                Card_Type__c = 'MasterCard',
                Is_Default__c = false,
                Card_Last_Four__c = '2222',
                Expiration_Month__c = '11',
                Expiration_Year__c = '2027'
            ),
            new CustomerCardPayment__c(
                Contact__c = testContact.Id,
                Name = 'Test Card2',
                Card_Type__c = 'MasterCard',
                Is_Default__c = false,
                Card_Last_Four__c = '2222',
                Expiration_Month__c = '11',
                Expiration_Year__c = '2027'
            )
        };
        Test.startTest();
        System.runAs(communityUser) {
            Test.setMock(HttpCalloutMock.class, new B2BDefaultTestData.B2BDefaultTestMock());
            List<B2BPayPal.CreditCardDto> cards = new B2BPayPal().getCustomerCards(communityUser.ContactId);
            Test.stopTest();

            System.assertEquals(2, cards.size(), 'Should be 2 cards records.');
        }
    }

    @IsTest
    public static void checkPayment() {
        User communityUser = [SELECT Id, AccountId, ContactId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];

        B2BPayPal.CreditCardDto creditCard = new B2BPayPal.CreditCardDto();
        creditCard.name = 'Test Card';
        creditCard.cardType = 'Visa';
        creditCard.isDefault = false;
        creditCard.cardNumber = '4111111111111111';
        creditCard.expirationDate = '1224';
        creditCard.cvv = '123';
        creditCard.lastFour = '1111';
        creditCard.amount = 50;
        creditCard.isSaveCard = true;

        String contentType = 'application/x-www-form-urlencoded';
        String body = 'RESULT=0&PNREF=A40F1A8F8C8C&RESPMSG=Approved&AUTHCODE=010101&AVSADDR=Y&AVSZIP=Y&HOSTCODE=AA&'
                +'RESPTEXT=APPROVAL&PROCAVS=Y&VISACARDLEVEL=12&TRANSTIME=2023-04-13 16:38:22&AMT=1.00&'
                +'ACCT=1881&EXPDATE=1225&CARDTYPE=0&IAVS=N&PREFPSMSG=No Rules Triggered&POSTFPSMSG=No Rules Triggered';

        Test.startTest();
        System.runAs(communityUser) {
            Test.setMock(HttpCalloutMock.class, new PayPalMockHttpResponseGenerator(contentType, body, 200));

            creditCard.pay(communityUser.ContactId);
            creditCard.saveCard(communityUser.ContactId);
            Test.stopTest();

            System.assertEquals(1, [SELECT Id FROM CustomerCardPayment__c].size(), 'CustomerCard record was not created.');
        }
    }

    public class PayPalMockHttpResponseGenerator implements HttpCalloutMock {
        private String contentType;
        private String body;
        private Integer statusCode;

        public PayPalMockHttpResponseGenerator(String contentType, String body, Integer statusCode ){
            this.contentType = contentType;
            this.body = body;
            this.statusCode = statusCode;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', contentType);
            res.setBody(body);
            res.setStatusCode(statusCode);
            return res;
        }
    }
}