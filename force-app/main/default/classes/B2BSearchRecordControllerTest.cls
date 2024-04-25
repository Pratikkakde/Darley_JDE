@IsTest
public with sharing class B2BSearchRecordControllerTest {
    private static final String SEARCH_STRING_1 = 'Test4';
    private static final String SEARCH_STRING_2 = 'Test444Product';

    @TestSetup
    static void setup() {
        B2BQuickOrderTestData.setupQuickOrderTestData();
    }

    @IsTest
    public static void getRecordsWithInitialSearchString() {
        User commUser = [SELECT Id FROM User WHERE Username = :B2BQuickOrderTestData.TEST_USER_NAME];
        B2BResponse response;

        System.runAs(commUser) {
            Test.startTest();
            response = B2BSearchRecordController.getRecordsWithInitialSearchString(SEARCH_STRING_1);
            Test.stopTest();
        }

        System.assertEquals(1, ((B2BSearchRecordController.RecordsWithInitialSearchStringWrapper)response.responseData).records.size());
    }

    @IsTest
    public static void getRecordsWhenNoMatchesExists() {
        User commUser = [SELECT Id FROM User WHERE Username = :B2BQuickOrderTestData.TEST_USER_NAME];
        B2BResponse response;

        System.runAs(commUser) {
            Test.startTest();
            response = B2BSearchRecordController.getRecordsWithInitialSearchString(SEARCH_STRING_2);
            Test.stopTest();
        }

        System.assertEquals(0, ((B2BSearchRecordController.RecordsWithInitialSearchStringWrapper)response.responseData).records.size());
    }
}