@IsTest
public class B2BStripeTest {

    @IsTest
    private static void updateCustomerInfoTest() {
        B2BStripe.Response response;
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new B2BStripeTest.B2BStripeMock(false));
        B2BStripe stripe = new B2BStripe(null);
        Map<String, String> params = new Map<String, String>();
        params.put('invoice_settings[default_payment_method]', 'pm_1234testMethod');

        response = stripe.updateCustomerInfo('cus_test123', params);

        Test.stopTest();

        System.assertEquals(200, response.statusCode);
    }

    @IsTest
    private static void createCustomerTest() {
        B2BStripe.Response response;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new B2BStripeTest.B2BStripeMock(true));
        B2BStripe stripe = new B2BStripe(null);
        try {
            response = (B2BStripe.Response) stripe.createCustomer();
            System.assert(false);
        } catch (B2BStripe.B2BStripeException e) {
            System.assert(true);
        } catch (Exception e) {
            System.assert(false);
        }
        Test.stopTest();
    }

    @IsTest
    private static void getCustomerInfoTest() {
        B2BStripe.Response response;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new B2BStripeTest.B2BStripeMock(true));
        B2BStripe stripe = new B2BStripe(null);
        response = stripe.getCustomerInfo('cus_testCustomer7328');

        Test.stopTest();

        System.assertEquals(500, response.statusCode);
    }

    @IsTest
    private static void retrieveCustomerCreditCardsTest() {
        B2BStripe.Response response;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new B2BStripeTest.B2BStripeMock(false));
        B2BStripe stripe = new B2BStripe(null);
        response = stripe.retrieveCustomerCreditCards('cus_testCustomer7328', '100');

        Test.stopTest();

        System.assertEquals(200, response.statusCode);
    }

    @IsTest
    private static void attachPaymentMethodTest() {
        B2BStripe.Response response;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new B2BStripeTest.B2BStripeMock(false));
        B2BStripe stripe = new B2BStripe(null);
        response = stripe.attachPaymentMethod('cus_testCustomer7328', 'pm_12323232');

        Test.stopTest();

        System.assertEquals(200, response.statusCode);
    }

    @IsTest
    private static void detachPaymentMethodTest() {
        HttpResponse response;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new B2BStripeTest.B2BStripeMock(false));
        B2BStripe stripe = new B2BStripe(null);
        response = stripe.detachPaymentMethod('pm_12323232');

        Test.stopTest();

        System.assertEquals(200, response.getStatusCode());
    }

    @IsTest
    private static void createPaymentIntentTest() {
        B2BStripe.Response response;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new B2BStripeTest.B2BStripeMock(false));
        B2BStripe stripe = new B2BStripe(null);

        Map<String, String> paramsForPaymentIntent = new Map<String, String>{
            'amount' => String.valueOf(Math.roundToLong(10.88 * 100)),
            'customer' => 'cus_123test',
            'currency' => 'usd',
            'payment_method' => 'pm_visaCard',
            'metadata[order_number]' => 'orderNumber123'
        };

        response = stripe.createPaymentIntent(paramsForPaymentIntent);

        Test.stopTest();
    }

    @IsTest
    private static void createPaymentMethodTest(){
       B2BTestDataFactory factory = new B2BTestDataFactory();
       Map<String, Object> initData = factory.initCustomerUserData();
       Contact userContact = (Contact) initData.get(B2BDefaultTestData.CUSTOMER_CONTACT);
       userContact.Stripe_Customer_Id__c = null;
       update userContact;

       User commUser = ((User) initData.get(B2BDefaultTestData.COMMUNITY_USER));
       Map<Object, Object> data = new Map<Object, Object>();
       data.put('paymentMethodId','65456456');
       data.put('creditCardName','VISA');

       System.runAs(commUser) {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new B2BStripeTest.B2BStripeMock(false));
            B2BStripe stripe = new B2BStripe(null);
            stripe.createPaymentMethod(data);

        }
        Test.stopTest();
    }

    @IsTest
    private static void setPaymentMethodAsDefaultTest(){
       B2BTestDataFactory factory = new B2BTestDataFactory();
       Map<String, Object> initData = factory.initCustomerUserData();
       Contact userContact = (Contact) initData.get(B2BDefaultTestData.CUSTOMER_CONTACT);
       userContact.Stripe_Customer_Id__c = 'cus_testCustomer';
       update userContact;

       User commUser = ((User) initData.get(B2BDefaultTestData.COMMUNITY_USER));
       Map<Object, Object> data = new Map<Object, Object>();
       data.put('paymentMethodId','65456456');
       data.put('creditCardName','VISA');

       System.runAs(commUser) {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new B2BStripeTest.B2BStripeMock(false));
            B2BStripe stripe = new B2BStripe(null);
            stripe.setPaymentMethodAsDefault(data);

        }
        Test.stopTest();
    }

    @IsTest
    private static void deletePaymentMethodTest(){
       B2BTestDataFactory factory = new B2BTestDataFactory();
       Map<String, Object> initData = factory.initCustomerUserData();
       Contact userContact = (Contact) initData.get(B2BDefaultTestData.CUSTOMER_CONTACT);
       userContact.Stripe_Customer_Id__c = 'cus_testCustomer';
       update userContact;

       User commUser = ((User) initData.get(B2BDefaultTestData.COMMUNITY_USER));
       Map<Object, Object> data = new Map<Object, Object>();
       data.put('paymentMethodId','65456456');
       data.put('creditCardName','VISA');

       System.runAs(commUser) {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new B2BStripeTest.B2BStripeMock(false));
            B2BStripe stripe = new B2BStripe(null);
            stripe.deletePaymentMethod(data);

        }
        Test.stopTest();
    }

    @IsTest
    private static void getPaymentCardsTest(){
       B2BTestDataFactory factory = new B2BTestDataFactory();
       Map<String, Object> initData = factory.initCustomerUserData();
       Contact userContact = (Contact) initData.get(B2BDefaultTestData.CUSTOMER_CONTACT);
       userContact.Stripe_Customer_Id__c = 'cus_testCustomer';
       update userContact;

       User commUser = ((User) initData.get(B2BDefaultTestData.COMMUNITY_USER));
       System.runAs(commUser) {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new B2BStripeTest.B2BStripeMock(false));
            B2BStripe stripe = new B2BStripe(null);
            Object payment = stripe.getPaymentCards();
        }
        Test.stopTest();
    }

    @IsTest
    private static void getPaymentACHsTest(){
       B2BTestDataFactory factory = new B2BTestDataFactory();
       Map<String, Object> initData = factory.initCustomerUserData();
       Contact userContact = (Contact) initData.get(B2BDefaultTestData.CUSTOMER_CONTACT);
       userContact.Stripe_Customer_Id__c = 'cus_testCustomer';
       update userContact;

       User commUser = ((User) initData.get(B2BDefaultTestData.COMMUNITY_USER));

       System.runAs(commUser) {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new B2BStripeTest.B2BStripeMock(false));
            B2BStripe stripe = new B2BStripe(null);
            Object payment = stripe.getPaymentACHs();
        }
        Test.stopTest();
    }

    @IsTest
    private static void getPaymentMethodsTest(){
       B2BTestDataFactory factory = new B2BTestDataFactory();
       Map<String, Object> initData = factory.initCustomerUserData();
       Contact userContact = (Contact) initData.get(B2BDefaultTestData.CUSTOMER_CONTACT);
       userContact.Stripe_Customer_Id__c = 'cus_testCustomer';
       update userContact;

       User commUser = ((User) initData.get(B2BDefaultTestData.COMMUNITY_USER));

       System.runAs(commUser) {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new B2BStripeTest.B2BStripeMock(false));
            B2BStripe stripe = new B2BStripe(null);
            Object payment = stripe.getPaymentMethods();
        }
        Test.stopTest();
    }

    @IsTest
    private static void createPaymentTest(){
       B2BTestDataFactory factory = new B2BTestDataFactory();
       Map<String, Object> initData = factory.initCustomerUserData();
       factory.initCartData(false,false);
       Contact userContact = (Contact) initData.get(B2BDefaultTestData.CUSTOMER_CONTACT);
       userContact.Stripe_Customer_Id__c = 'cus_testCustomer';
       update userContact;

       User commUser = ((User) initData.get(B2BDefaultTestData.COMMUNITY_USER));
       Map<Object, Object> data = new Map<Object, Object>();
       data.put('paymentMethodId','65456456');
       data.put('creditCardName','VISA');
       WebCart currentWebCart = [SELECT Id FROM webCart];

       System.runAs(commUser) {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new B2BStripeTest.B2BStripeMock(false));
            B2BStripe stripe = new B2BStripe(currentWebCart.Id);
            Object payment = stripe.createPayment(data);

        }
        Test.stopTest();
    }

    public class B2BStripeMock implements HttpCalloutMock {
        public Boolean failCall { get; set; }

        public String failResponse = '{"error": {\n' +
            '    "code": "err",\n' +
            '    "doc_url": "https://stripe.com/docs/error-codes/err",\n' +
            '    "message": "Error",\n' +
            '    "type": "err"\n' +
            '  }' +
            '}';

        public String successResponse = '{' +
            '"id": "pm_1H33TEST332", ' +
            '"card":{"last4":"4444", "brand":"visa"}, ' +
            '"invoice_settings": { "custom_fields": null, "default_payment_method": "pm_1JkNV8S", "footer": null }, ' +
            '"data": [ { "id": "pm_1JkNteSt151", "object": "payment_method", "billing_details": { "address": { "city": null, "country": null, "line1": null, "line2": null, "postal_code": null, "state": null }, "email": null, "name": "union pay", "phone": null }, "card": { "brand": "unionpay", "checks": { "address_line1_check": null, "address_postal_code_check": null, "cvc_check": "pass" }, "country": "CN", "exp_month": 2, "exp_year": 2022, "fingerprint": "MhStestWPLf", "funding": "credit", "generated_from": null, "last4": "0005", "networks": { "available": [ "unionpay" ], "preferred": null }, "three_d_secure_usage": { "supported": false }, "wallet": null }, "created": 1634193216, "customer": "cus_KPtesSt0g7", "livemode": false, "metadata": {}, "type": "card" }]' +
            '}';


        public B2BStripeMock(Boolean failCall) {
            this.failCall = failCall;
        }

        public HTTPResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();

            if (failCall) {
                response.setStatusCode(500);
                response.setStatus('Bad Request');
                response.setBody(failResponse);
            } else {
                response.setStatusCode(200);
                response.setStatus('OK');
                response.setHeader('set-cookie', 'testkey=testvalue');
                response.setBody(successResponse);
            }

            return response;
        }
    }
}