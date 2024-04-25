@IsTest
private class B2BRegisterControllerTest {

    private static final String ACCOUNT_NAME = 'Test-Account-Registration';
    private static final String ACCOUNT_NUMBER = 'TAR';

    @TestSetup
    private static void makeData() {
        User guestUser = B2BTestDataFactory.createGuestUser(true,'testGuestUser@email.com');
        new B2BDefaultTestData().initAllData();
        Account newAccount = B2BTestDataFactory.createAccount(false, ACCOUNT_NAME, null, 'Customer', null);
        newAccount.AccountNumber = ACCOUNT_NUMBER;
        insert newAccount;

        B2BTestDataFactory.createBuyerData(newAccount.Id, 'Example Buyer Group');

        List<BuyerGroup> buyerGroups = [SELECT Id FROM BuyerGroup];
        B2BSettings__c b2BSettings = new B2BSettings__c(
            AccountOwnerId__c = UserInfo.getUserId(),
            BuyerGroupId__c = buyerGroups.get(0).Id
        );
        insert b2BSettings;
    }

    @IsTest
    private static void testRegisterInitialization() {
        User guestUser = [SELECT Id FROM User WHERE Username = 'testGuestUser@email.com'];

        Test.startTest();
        System.runAs(guestUser) {
            Map<String, Object> result = B2BRegisterController.initRegisterForm();

            System.assertNotEquals((B2BRegister)result.get('register'), null, 'Register instance should be exist.');
            System.assertNotEquals((Map<String, List<String>>)result.get('countriesAndStates'), null, 'Countries-States picklists should be exist.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void testSignUpForExistedUser() {
        User guestUser = [SELECT Id, Email FROM User WHERE Username = 'testGuestUser@email.com'];
        B2BRegister register = new B2BRegister();
        register.firstName = 'TestRegister1';
        register.lastName = 'TestRegister2';
        register.email = guestUser.email;
        register.companyName = ACCOUNT_NAME;
        register.hasAccount = true;

        Test.startTest();
        System.runAs(guestUser) {
            try {
                B2BRegisterController.signUp(register);
                System.assert(true, 'Catch block should be execute.');
            } catch (B2BRegister.B2BRegisterException ex) {
                System.assertEquals(ex.getMessage(), Label.B2B_A_user_with_this_email_already_exists, 'Error message is not correct');
            }
        }
        Test.stopTest();

        List<User> users = [
            SELECT Id
            FROM User
            WHERE FirstName = :register.firstName
            AND LastName = :register.lastName
        ];
        System.assertEquals(users.size(), 0, 'User was created.');
    }

    @IsTest
    private static void testSignUpForNewAccount() {
        User guestUser = [SELECT Id, Email FROM User WHERE Username = 'testGuestUser@email.com'];
        B2BRegister register = new B2BRegister();
        register.firstName = 'TestRegister1';
        register.lastName = 'TestRegister2';
        register.email = guestUser.Email;
        register.companyName = ACCOUNT_NAME + 'New';
        register.streetAddress = 'Test Street address';
        register.country = 'United States';
        register.state = 'Colorado';
        register.city = 'Colorado';
        register.postalCode = '220000';
        register.hasAccount = false;

        Test.startTest();
        System.runAs(guestUser) {
            try {
                Test.setMock(HttpCalloutMock.class, new B2BDefaultTestData.B2BDefaultTestMock());
                B2BRegisterController.signUp(register);
                System.assert(true, 'Catch block should be execute.');
            } catch (B2BRegister.B2BRegisterException ex) {
                System.assertEquals(ex.getMessage(), Label.B2B_A_user_with_this_email_already_exists, 'Error message is not correct');
            }

            register.email = 'testRegisterEmail@test.com';
            B2BRegisterController.signUp(register);
        }
        Test.stopTest();

        List<User> users = [
            SELECT Id
            FROM User
            WHERE FirstName = :register.firstName
            AND LastName = :register.lastName
        ];
        System.assertEquals(users.size(), 1, 'User was not created.');

        List<Account> accounts = [
            SELECT Id
            FROM Account
            WHERE Name = :register.companyName
        ];
        System.assertEquals(accounts.size(), 1, 'Account was not created.');
    }

}