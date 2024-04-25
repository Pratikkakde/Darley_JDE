@IsTest
public without sharing class B2BAuthorizeNetTest {

    @IsTest
    private static void updateCardTest() {
        B2BAuthorizeNetTestMock.mock();
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initCustomerUserData();

        User commUser = ((User) initData.get(B2BDefaultTestData.COMMUNITY_USER));
        Contact contact = (Contact) initData.get(B2BDefaultTestData.CUSTOMER_CONTACT);
        contact.Authorize_Profile_Id__c = '190178';
        update contact;

        B2BAuthorizeNetWrapper.CreditCardObject card = new B2BAuthorizeNetWrapper.CreditCardObject();
        card.cardNumber = '4444111122223333';
        card.isDefault = true;
        card.cvvNumber = '817';
        card.expiryMonth = '04';
        card.expiryYear = '2023';
        card.customerPaymentProfileId = '157497';

        Test.startTest();
        System.runAs(commUser) {
            card.cardNumber = '4444111122221111';

            B2BAuthorizeNet service = new B2BAuthorizeNet(null);
            service.setPaymentMethodAsDefault(card);

            String profileId = [SELECT Authorize_Profile_Id__c FROM Contact WHERE Authorize_Profile_Id__c != NULL LIMIT 1].Authorize_Profile_Id__c;
            System.assertEquals(profileId, '190178');
        }
        Test.stopTest();
    }

    @IsTest
    private static void addNewCardAndProfile() {
        B2BAuthorizeNetTestMock.mock();
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initCustomerUserData();

        User commUser = ((User) initData.get(B2BDefaultTestData.COMMUNITY_USER));
        Contact contact = (Contact) initData.get(B2BDefaultTestData.CUSTOMER_CONTACT);
        contact.Authorize_Profile_Id__c = null;
        update contact;

        B2BAuthorizeNetWrapper.CreditCardObject card = new B2BAuthorizeNetWrapper.CreditCardObject();
        card.cardNumber = '4444111122223333';
        card.isDefault = true;
        card.cvvNumber = '817';
        card.expiryMonth = '04';
        card.expiryYear = '2023';

        Test.startTest();
        System.runAs(commUser) {
            B2BAuthorizeNet service = new B2BAuthorizeNet(null);
            service.createPaymentMethod(card);

            String profileId = [SELECT Authorize_Profile_Id__c FROM Contact WHERE Authorize_Profile_Id__c != NULL LIMIT 1].Authorize_Profile_Id__c;
            System.assertEquals(profileId, '190178');
        }
        Test.stopTest();
    }

    @IsTest
    private static void addNewACHAndProfile() {
        B2BAuthorizeNetTestMock.mock();
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initCustomerUserData();

        User commUser = ((User) initData.get(B2BDefaultTestData.COMMUNITY_USER));
        Contact contact = (Contact) initData.get(B2BDefaultTestData.CUSTOMER_CONTACT);
        contact.Authorize_Profile_Id__c = null;
        update contact;

        B2BAuthorizeNetWrapper.ACHObject ach = new B2BAuthorizeNetWrapper.ACHObject();
        ach.routingNumber = '4444111122223333';
        ach.accountNumber = 'test';
        ach.bankName = 'pko';
        ach.nameOnAccount = 'test name';


        Test.startTest();
        System.runAs(commUser) {
            B2BAuthorizeNet service = new B2BAuthorizeNet(null);
            service.createPaymentMethod(ach);

            String profileId = [SELECT Authorize_Profile_Id__c FROM Contact WHERE Authorize_Profile_Id__c != NULL LIMIT 1].Authorize_Profile_Id__c;
            System.assertEquals(profileId, '190178');
        }
        Test.stopTest();
    }

    @IsTest
    private static void addNewCardToExistingProfile() {
        B2BAuthorizeNetTestMock.mock();
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initCustomerUserData();

        User commUser = ((User) initData.get(B2BDefaultTestData.COMMUNITY_USER));
        Contact contact = (Contact) initData.get(B2BDefaultTestData.CUSTOMER_CONTACT);
        contact.Authorize_Profile_Id__c = '190178';
        update contact;

        B2BAuthorizeNetWrapper.CreditCardObject card = new B2BAuthorizeNetWrapper.CreditCardObject();
        card.cardNumber = '4444111122223333';
        card.isDefault = true;
        card.cvvNumber = '817';
        card.expiryMonth = '04';
        card.expiryYear = '2023';

        Test.startTest();
        System.runAs(commUser) {
            B2BAuthorizeNet service = new B2BAuthorizeNet(null);
            service.createPaymentMethod(card);

            String profileId = [SELECT Authorize_Profile_Id__c FROM Contact WHERE Authorize_Profile_Id__c != NULL LIMIT 1].Authorize_Profile_Id__c;
            System.assertEquals(profileId, '190178');
        }
        Test.stopTest();
    }

    @IsTest
    private static void addNewACHToExistingProfile() {
        B2BAuthorizeNetTestMock.mock();
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initCustomerUserData();

        User commUser = ((User) initData.get(B2BDefaultTestData.COMMUNITY_USER));
        Contact contact = (Contact) initData.get(B2BDefaultTestData.CUSTOMER_CONTACT);
        contact.Authorize_Profile_Id__c = '190178';
        update contact;

        B2BAuthorizeNetWrapper.ACHObject ach = new B2BAuthorizeNetWrapper.ACHObject();
        ach.routingNumber = '4444111122223333';
        ach.accountNumber = 'test';
        ach.bankName = 'pko';
        ach.nameOnAccount = 'test name';

        Test.startTest();
        System.runAs(commUser) {
            B2BAuthorizeNet service = new B2BAuthorizeNet(null);
            service.createPaymentMethod(ach);

            String profileId = [SELECT Authorize_Profile_Id__c FROM Contact WHERE Authorize_Profile_Id__c != NULL LIMIT 1].Authorize_Profile_Id__c;
            System.assertEquals(profileId, '190178');
        }
        Test.stopTest();
    }

    @IsTest
    private static void getPaymentMethods() {
        B2BAuthorizeNetTestMock.mock();
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initCustomerUserData();

        User commUser = ((User) initData.get(B2BDefaultTestData.COMMUNITY_USER));
        Contact contact = (Contact) initData.get(B2BDefaultTestData.CUSTOMER_CONTACT);
        contact.Authorize_Profile_Id__c = '190178';
        update contact;

        Test.startTest();
        System.runAs(commUser) {
            B2BAuthorizeNet service = new B2BAuthorizeNet(null);
            List<Object> paymentMethods = (List<Object>) service.getPaymentMethods();
            System.assertEquals(paymentMethods.size(), 2);
            System.assertEquals(((B2BAuthorizeNetWrapper.CreditCardObject) paymentMethods.get(0)).customerPaymentProfileId, '157497');
            System.assertEquals(((B2BAuthorizeNetWrapper.ACHObject) paymentMethods.get(1)).customerPaymentProfileId, '157497');
        }
        Test.stopTest();
    }

    @IsTest
    private static void getCards() {
        B2BAuthorizeNetTestMock.mock();
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initCustomerUserData();

        User commUser = ((User) initData.get(B2BDefaultTestData.COMMUNITY_USER));
        Contact contact = (Contact) initData.get(B2BDefaultTestData.CUSTOMER_CONTACT);
        contact.Authorize_Profile_Id__c = '190178';
        update contact;

        Test.startTest();
        System.runAs(commUser) {
            B2BAuthorizeNet service = new B2BAuthorizeNet(null);
            List<B2BAuthorizeNetWrapper.CreditCardObject> cards = (List<B2BAuthorizeNetWrapper.CreditCardObject>) service.getPaymentCards();
            System.assertEquals(cards.size(), 1);
            System.assertEquals(cards.get(0).customerPaymentProfileId, '157497');
        }
        Test.stopTest();
    }

    @IsTest
    private static void getACHes() {
        B2BAuthorizeNetTestMock.mock();
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initCustomerUserData();

        User commUser = ((User) initData.get(B2BDefaultTestData.COMMUNITY_USER));
        Contact contact = (Contact) initData.get(B2BDefaultTestData.CUSTOMER_CONTACT);
        contact.Authorize_Profile_Id__c = '190178';
        update contact;

        Test.startTest();
        System.runAs(commUser) {
            B2BAuthorizeNet service = new B2BAuthorizeNet(null);
            List<B2BAuthorizeNetWrapper.ACHObject> achList = (List<B2BAuthorizeNetWrapper.ACHObject>) service.getPaymentACHs();
            System.assertEquals(achList.size(), 1);
            System.assertEquals(achList.get(0).customerPaymentProfileId, '157497');
        }
        Test.stopTest();
    }

    @IsTest
    private static void deleteCard() {
        B2BAuthorizeNetTestMock.mock();
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initCustomerUserData();

        User commUser = ((User) initData.get(B2BDefaultTestData.COMMUNITY_USER));
        Contact contact = (Contact) initData.get(B2BDefaultTestData.CUSTOMER_CONTACT);
        contact.Authorize_Profile_Id__c = '190178';
        update contact;

        B2BAuthorizeNetWrapper.CreditCardObject card = new B2BAuthorizeNetWrapper.CreditCardObject();
        card.cardNumber = '4444111122223333';
        card.isDefault = true;
        card.cvvNumber = '817';
        card.expiryMonth = '04';
        card.expiryYear = '2023';
        card.customerPaymentProfileId = '157497';

        Test.startTest();
        System.runAs(commUser) {
            B2BAuthorizeNet service = new B2BAuthorizeNet(null);
            service.deletePaymentMethod(card);
        }
        Test.stopTest();
    }

    @IsTest
    private static void deleteACH() {
        B2BAuthorizeNetTestMock.mock();
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initCustomerUserData();

        User commUser = ((User) initData.get(B2BDefaultTestData.COMMUNITY_USER));
        Contact contact = (Contact) initData.get(B2BDefaultTestData.CUSTOMER_CONTACT);
        contact.Authorize_Profile_Id__c = '190178';
        update contact;

        B2BAuthorizeNetWrapper.ACHObject ach = new B2BAuthorizeNetWrapper.ACHObject();
        ach.routingNumber = '4444111122223333';
        ach.accountNumber = 'test';
        ach.bankName = 'pko';
        ach.nameOnAccount = 'test name';
        ach.customerPaymentProfileId = '157497';

        Test.startTest();
        System.runAs(commUser) {
            B2BAuthorizeNet service = new B2BAuthorizeNet(null);
            service.deletePaymentMethod(ach);
        }
        Test.stopTest();
    }

    @IsTest
    private static void runUnimplementedMethods() {
        try {
            new B2BAuthorizeNet(null).createCustomer();
        } catch (B2BPaymentGatewayService.MethodNotImplementedException e) {
            System.assert(true);
        }
        try {
            new B2BAuthorizeNet(null).confirmPayment(null, null);
        } catch (B2BPaymentGatewayService.MethodNotImplementedException e) {
            System.assert(true);
        }
        try {
            new B2BAuthorizeNet(null).cancelPayment(null);
        } catch (B2BPaymentGatewayService.MethodNotImplementedException e) {
            System.assert(true);
        }
        try {
            new B2BAuthorizeNet(null).refundPayment(null, null);
        } catch (B2BPaymentGatewayService.MethodNotImplementedException e) {
            System.assert(true);
        }
        try {
            new B2BAuthorizeNet(null).getAdditionalData(null);
        } catch (B2BPaymentGatewayService.MethodNotImplementedException e) {
            System.assert(true);
        }
    }
}