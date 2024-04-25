@IsTest
public without sharing class B2BAuthorizeNetWrapperTest {

    private static final String BILL_TO_EXPECTED = '{\n' +
        '  "billTo" : {\n' +
        '    "firstName" : "' + UserInfo.getFirstName() + '",\n' +
        '    "lastName" : "' + UserInfo.getLastName() + '",\n' +
        '    "company" : "' + UserInfo.getOrganizationName() + '",\n' +
        '    "address" : "testStreet",\n' +
        '    "city" : "Chicago",\n' +
        '    "state" : "Alaska",\n' +
        '    "zip" : "100000",\n';

    private static final String TRANSACTION_REQUEST_EXPECTED = '{\n' +
        '  "createTransactionRequest" : {\n' +
        '    "merchantAuthentication" : {\n' +
        '      "name" : "testName",\n' +
        '      "transactionKey" : "testKey"\n' +
        '    },\n' +
        '    "transactionRequest" : {\n' +
        '      "transactionType" : "authOnlyTransaction",\n' +
        '      "amount" : "100",\n' +
        '      "profile" : {\n' +
        '        "customerProfileId" : "-100",\n' +
        '        "paymentProfile" : {\n' +
        '          "paymentProfileId" : "-100"\n' +
        '        }\n' +
        '      }\n' +
        '    }\n' +
        '  }\n' +
        '}';

    private static final String UPDATE_CUSTOMER_PROFILE_EXPECTED = '{\n' +
        '  "updateCustomerPaymentProfileRequest" : {\n' +
        '    "merchantAuthentication" : {\n' +
        '      "name" : "testName",\n' +
        '      "transactionKey" : "testKey"\n' +
        '    },\n' +
        '    "customerProfileId" : "-100",\n' +
        '    "paymentProfile" : {\n' +
        '      "customerType" : "individual",\n' +
        '      "payment" : {\n' +
        '        "creditCard" : {\n' +
        '          "cardNumber" : "4444111122223333",\n' +
        '          "expirationDate" : "2023-04",\n' +
        '          "cardCode" : "817"\n' +
        '        }\n' +
        '      },\n' +
        '      "defaultPaymentProfile" : true\n' +
        '    }\n' +
        '  }\n' +
        '}';

    @IsTest
    private static void createCustomerProfileRequest() {
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initCustomerUserData();
        Contact contact = (Contact) initData.get(B2BDefaultTestData.CUSTOMER_CONTACT);

        B2BAuthorizeNetWrapper.CreditCardObject card = new B2BAuthorizeNetWrapper.CreditCardObject();
        card.cardNumber = '4444111122223333';
        card.isDefault = true;
        card.cvvNumber = '817';
        card.expiryMonth = '04';
        card.expiryYear = '2023';

        String result = B2BAuthorizeNetWrapper.createCustomerProfileRequest(contact.Id, card, '', '');

        System.assertEquals(result, '{\n' +
            '  "createCustomerProfileRequest" : {\n' +
            '    "merchantAuthentication" : {\n' +
            '      "name" : "",\n' +
            '      "transactionKey" : ""\n' +
            '    },\n' +
            '    "profile" : {\n' +
            '      "merchantCustomerId" : "' + contact.Id + '",\n' +
            '      "paymentProfiles" : {\n' +
            '        "customerType" : "individual",\n' +
            '        "payment" : {\n' +
            '          "creditCard" : {\n' +
            '            "cardNumber" : "4444111122223333",\n' +
            '            "expirationDate" : "2023-04",\n' +
            '            "cardCode" : "817"\n' +
            '          }\n' +
            '        },\n' +
            '        "defaultPaymentProfile" : true\n' +
            '      }\n' +
            '    }\n' +
            '  }\n' +
            '}');
    }

    @IsTest
    private static void createPaymentProfileRequest() {
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initCustomerUserData();
        Contact contact = (Contact) initData.get(B2BDefaultTestData.CUSTOMER_CONTACT);
        contact.Authorize_Profile_Id__c = '1234';
        update contact;

        B2BAuthorizeNetWrapper.CreditCardObject card = new B2BAuthorizeNetWrapper.CreditCardObject();
        card.cardNumber = '4444111122223333';
        card.isDefault = true;
        card.cvvNumber = '817';
        card.expiryMonth = '04';
        card.expiryYear = '2023';

        String result = B2BAuthorizeNetWrapper.createPaymentProfileRequest(contact.Authorize_Profile_Id__c, card, '', '');

        System.assertEquals(result, '{\n' +
            '  "createCustomerPaymentProfileRequest" : {\n' +
            '    "merchantAuthentication" : {\n' +
            '      "name" : "",\n' +
            '      "transactionKey" : ""\n' +
            '    },\n' +
            '    "customerProfileId" : "1234",\n' +
            '    "paymentProfile" : {\n' +
            '      "customerType" : "individual",\n' +
            '      "payment" : {\n' +
            '        "creditCard" : {\n' +
            '          "cardNumber" : "4444111122223333",\n' +
            '          "expirationDate" : "2023-04",\n' +
            '          "cardCode" : "817"\n' +
            '        }\n' +
            '      },\n' +
            '      "defaultPaymentProfile" : true\n' +
            '    }\n' +
            '  }\n' +
            '}');
    }

    @IsTest
    private static void getCustomerProfileRequest() {
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initCustomerUserData();
        Contact contact = (Contact) initData.get(B2BDefaultTestData.CUSTOMER_CONTACT);
        contact.Authorize_Profile_Id__c = '1234';
        update contact;

        String result = B2BAuthorizeNetWrapper.getCustomerProfileRequest(contact.Authorize_Profile_Id__c, '', '');

        System.assertEquals(result, '{\n' +
            '  "getCustomerProfileRequest" : {\n' +
            '    "merchantAuthentication" : {\n' +
            '      "name" : "",\n' +
            '      "transactionKey" : ""\n' +
            '    },\n' +
            '    "customerProfileId" : "1234",\n' +
            '    "unmaskExpirationDate" : "true"\n' +
            '  }\n' +
            '}');
    }

    @IsTest
    private static void deleteCustomerPaymentProfileRequest() {
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initCustomerUserData();
        Contact contact = (Contact) initData.get(B2BDefaultTestData.CUSTOMER_CONTACT);
        contact.Authorize_Profile_Id__c = '1234';
        update contact;

        B2BAuthorizeNetWrapper.CreditCardObject card = new B2BAuthorizeNetWrapper.CreditCardObject();

        card.customerPaymentProfileId = '12345';

        String result = B2BAuthorizeNetWrapper.deleteCustomerPaymentProfileRequest(contact.Authorize_Profile_Id__c, card.customerPaymentProfileId, '', '');

        System.assertEquals(result, '{\n' +
            '  "deleteCustomerPaymentProfileRequest" : {\n' +
            '    "merchantAuthentication" : {\n' +
            '      "name" : "",\n' +
            '      "transactionKey" : ""\n' +
            '    },\n' +
            '    "customerProfileId" : "1234",\n' +
            '    "customerPaymentProfileId" : "12345"\n' +
            '  }\n' +
            '}');
    }

    @IsTest
    public static void billToTest() {
        ContactPointAddress address = new ContactPointAddress(
            Name = 'testName',
            Street = 'testStreet',
            City = 'Chicago',
            State = 'Alaska',
            PostalCode = '100000',
            CountryCode = 'US',
            AddressType = 'Billing'
        );
        insert address;

        B2BAuthorizeNetWrapper.CreditCardObject card = new B2BAuthorizeNetWrapper.CreditCardObject();
        card.cardNumber = '4444111122223333';
        card.isDefault = true;
        card.cvvNumber = '817';
        card.expiryMonth = '04';
        card.expiryYear = '2023';
        card.billingAddressId = address.Id;

        JSONGenerator generator = JSON.createGenerator(true);
        B2BAuthorizeNetWrapper.billTo(generator, card);

        System.assert(generator.getAsString().containsIgnoreCase(BILL_TO_EXPECTED), 'Wrong data returned');
    }

    @IsTest
    public static void updateCustomerProfileTest() {
        B2BAuthorizeNetWrapper.CreditCardObject card = new B2BAuthorizeNetWrapper.CreditCardObject();
        card.cardNumber = '4444111122223333';
        card.isDefault = true;
        card.cvvNumber = '817';
        card.expiryMonth = '04';
        card.expiryYear = '2023';

        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initCustomerUserData();
        Contact testContact = (Contact) initData.get(B2BDefaultTestData.CUSTOMER_CONTACT);
        testContact.Authorize_Profile_Id__c = '-100';

        String result = B2BAuthorizeNetWrapper.updateCustomerPaymentProfileRequest(testContact.Authorize_Profile_Id__c, card, 'testName', 'testKey');
        System.assertEquals(result, UPDATE_CUSTOMER_PROFILE_EXPECTED);
    }

    @IsTest
    public static void transactionRequestTest() {
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initAllData();

        Contact testContact = (Contact) initData.get(B2BDefaultTestData.CUSTOMER_CONTACT);
        testContact.Authorize_Profile_Id__c = '190178';
        update testContact;

        WebCart testCart = (WebCart) initData.get(B2BDefaultTestData.CART);

        String result = B2BAuthorizeNetWrapper.createTransactionRequest(testContact.Authorize_Profile_Id__c, '-100', '100', 'testName', 'testKey');
        System.assert(String.isNotBlank(result));
    }
}