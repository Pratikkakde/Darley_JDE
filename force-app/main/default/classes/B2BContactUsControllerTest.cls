@IsTest
private class B2BContactUsControllerTest {

    private static String SUBJECT = 'Test Subject';
    private static String DESCRIPTION = 'Test Description';

    @IsTest
    private static void createCaseTest_GuestUser() {
        User guestUser = B2BTestDataFactory.createGuestUser(true,'testGuestUser@email.com');
        Map<String,Object> request = new Map<String,Object>();
        request.put('firstName', 'firstName');
        request.put('lastName', 'lastName');
        request.put('email', 'email@email.com');
        request.put('companyName', 'companyName');
        request.put('phoneNumber', 'phoneNumber');
        request.put('subject', SUBJECT);
        request.put('description', DESCRIPTION);
        request.put('isGuestUser', true);
        request.put('contactMethod', 'Phone');
        request.put('contactTime', 'Afternoon');
        request.put('country', 'US');
        request.put('state', 'AK');
        request.put('contactReason', 'Product research question');

        Test.startTest();
        System.runAs(guestUser) {
            B2BResponse response = B2BContactUsController.createCase(request);
            System.assertEquals(true, response.isSuccess, 'Expected Success response');
        }
        Test.stopTest();
        List<Case> casesList = [SELECT Id, Subject, Description FROM Case];
        System.assertEquals(1, casesList.size(), 'Expected cases list size 1');
        System.assertEquals(SUBJECT, casesList[0].Subject, 'Expected same subject');
        System.assertEquals(DESCRIPTION, casesList[0].Description, 'Expected same description');
    }

    @IsTest
    private static void createCaseTest_LogedUser() {
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initCustomerUserData();
        User commUser = ((User) initData.get(B2BDefaultTestData.COMMUNITY_USER));
        Map<String,Object> request = new Map<String,Object>();
        request.put('subject', SUBJECT);
        request.put('description', DESCRIPTION);
        request.put('isGuestUser', false);
        System.runAs(commUser) {
            B2BResponse response = B2BContactUsController.createCase(request);
            System.assertEquals(true, response.isSuccess, 'Expected Success reponse');
        }
        List<Case> casesList = [SELECT Id, Subject, Description, ContactId FROM Case];
        System.assertEquals(1, casesList.size(), 'Expected cases list size 1');
        System.assertEquals(SUBJECT, casesList[0].Subject, 'Expected same subject');
        System.assertEquals(DESCRIPTION, casesList[0].Description, 'Expected same description');
        System.assertEquals(commUser.ContactId, casesList[0].ContactId, 'Expected same ContactId');
    }

    @IsTest
    private static void createCaseTest_Exception() {
        User guestUser = B2BTestDataFactory.createGuestUser(true,'testGuestUser@email.com');
        Map<String,Object> request = new Map<String,Object>();
        request.put('email', 'someInvalidEmail');
        request.put('subject', SUBJECT);
        request.put('description', DESCRIPTION);
        request.put('isGuestUser', true);

        Test.startTest();
        System.runAs(guestUser) {
            B2BResponse response = B2BContactUsController.createCase(request);
            System.assertEquals(false, response.isSuccess, 'Expected Error reponse');
        }
        Test.stopTest();
        List<Case> casesList = [SELECT Id, Subject, Description FROM Case];
        System.assertEquals(0, casesList.size(), 'Expected cases list size 0');
    }

    @IsTest
    private static void testCaseFieldsPicklistOptions() {

        Test.startTest();
        Map<String, Object> result = B2BContactUsController.getCaseFieldsPicklistOptions();

        System.assertNotEquals((List<B2BUtils.PicklistEntry>)result.get('storeContactMethodOptions'), null, 'storeContactMethodOptions picklists should exist.');
        System.assertNotEquals((List<B2BUtils.PicklistEntry>)result.get('storeContactTimeOptions'), null, 'storeContactTimeOptions picklists should exist.');
        System.assertNotEquals((Map<String, List<String>>)result.get('countriesAndStates'), null, 'countriesAndStates picklists should exist.');
        System.assertNotEquals((Map<String, String>)result.get('countriesCode'), null, 'countriesCode picklists should exist.');
        System.assertNotEquals((Map<String, List<Map<String, String>>>)result.get('countriesStatesCode'), null, 'countriesStatesCode picklists should exist.');
        System.assertNotEquals((List<B2BUtils.PicklistEntry>)result.get('storeContactReasonOptions'), null, 'storeContactReasonOptions picklists should exist.');
        System.assertNotEquals((List<B2BUtils.PicklistEntry>)result.get('storeLastFiveOrders'), null, 'storeLastFiveOrders picklists should exist.');
        Test.stopTest();
    }

}