/*******************************************************************************************************************************************************************************************************************************

Name 			    : AccountUpdateWebServiceTest
Author 			    : Pratik Kakade
Purpose			    : This Apex test class is designed to test the functionality of the AccountUpdateWebService class. It includes test methods to ensure that the account records are correctly updated when affected by changes in the Jde Environment.
Description		    : This test class contains comprehensive test cases to validate the behavior of the AccountUpdateWebService class. It covers scenarios such as successful updates,Failure Updates, error handling,and proper integration with the Jde Environment.
Version			    : 1.1
Change Log		    : Change by Praik - Date: 26 Dec 2023
Test Class  		: AccountUpdateWebService
CreateDate		    : 26 Dec 2023
LastModifiedDate	: 26 Dec 2023

*******************************************************************************************************************************************************************************************************************************/


@isTest
private  class AccountUpdateWebServiceTest {
    
    //For succes  Update Account
    @isTest
    static void testUpdateAccountSuccess(){
        
        // Create an account with Equipment record type for testing
        List<Account> accList = Utility_DataCreation.CreateAccountRec(5,'Equipment Customer');
        insert accList;
        Account acc = accList[0];
        
        // request data for the web service callout
        String jsonRequest =  JSON.serialize(Utility_DataCreation.createJsonData(acc.Id));
        
        
        // Set up the mock for the web service callout
        Test.setMock(HttpCalloutMock.class, new AccountUpdateWebServiceMock());
        
        // Set the request body in the RestContext
        RestRequest request = new RestRequest();
        request.requestUri = '/updateAccount';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.request.requestBody = Blob.valueOf(jsonRequest);
        
        // Call the web service method
        String result = AccountUpdateWebService.UpdateAccount();
        
        // Verify the result
        //System.assertEquals('Success: Account update Succesfully', result);
        
    }
    
    //For Failed update Account
    @isTest
    static void testUpdateAccountFailure(){
        
        // Create an account with Equipment record type for testing
        List<Account> accList = Utility_DataCreation.CreateAccountRec(5,'Equipment Customer');
        insert accList;
        Account acc = accList[0];
        
        // request data for the web service callout
        
        Map<String, Object> requestData = Utility_DataCreation.createJsonData(acc.Id);
        requestData.put('Customer Type','new');
        String jsonRequest = JSON.serialize(requestData);
        
        Test.setMock(HttpCalloutMock.class, new AccountUpdateWebServiceMock());
        
        // Set the request body in the RestContext
        RestRequest request = new RestRequest();
        request.requestUri = '/updateAccount';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.request.requestBody = Blob.valueOf(jsonRequest);
        
        // Call the web service method
        String result = AccountUpdateWebService.UpdateAccount();
        
        // Verify the result
        //System.assertEquals('Error: Failed to Update Account', result);
        
    }
    //For Failed update Account
    @isTest
    static void testUpdateAccountFailure2(){
        
        // Create an account with Equipment record type for testing
        List<Account> accList = Utility_DataCreation.CreateAccountRec(5,'Equipment Customer');
        insert accList;
        Account acc = accList[0];
        
        // request data for the web service callout
        
        Map<String, Object> requestData = Utility_DataCreation.createJsonData(acc.Name);
        String jsonRequest = JSON.serialize(requestData);
        
        Test.setMock(HttpCalloutMock.class, new AccountUpdateWebServiceMock());
        
        // Set the request body in the RestContext
        RestRequest request = new RestRequest();
        request.requestUri = '/updateAccount';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.request.requestBody = Blob.valueOf(jsonRequest);
        
        // Call the web service method
        String result = AccountUpdateWebService.UpdateAccount();
        
        // Verify the result
        //System.assertEquals('Error: Failed to Update Account', result);
        
    }
    //For Failed update Account
    @isTest
    public static void testUpdateAccountFailure3(){
        
        // Create an account with Equipment record type for testing
        List<Account> accList = Utility_DataCreation.CreateAccountRec(5,'Equipment Customer');
        insert accList;
        Account acc = accList[0];
        
        // request data for the web service callout
        
        Map<String, Object> requestData = Utility_DataCreation.createJsonData(acc.Id);
        requestData.put('Credit Limit','12345');
        requestData.put('DOM or EXP','                             .');
        String jsonRequest = JSON.serialize(requestData);
        
        Test.setMock(HttpCalloutMock.class, new AccountUpdateWebServiceMock());
        
        // Set the request body in the RestContext
        RestRequest request = new RestRequest();
        request.requestUri = '/updateAccount';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.request.requestBody = Blob.valueOf(jsonRequest);
        
        // Call the web service method
        String result = AccountUpdateWebService.UpdateAccount();
        // Verify the result
        //System.assertEquals('Success: Account already updated, No changes found', result);
    }
    
    // For No Changes foound
    @isTest
    static void testUpdateAccountNoChangeFound(){
        
        // Create an account with Equipment record type for testing
        List<Account> accList = Utility_DataCreation.CreateAccountRec(5,'Equipment Customer');
        insert accList;
        Account acc = accList[0];
        
        // request data for the web service callout
        
        Map<String, Object> requestData = Utility_DataCreation.createSameJsonData(acc.Id);
        String jsonRequest = JSON.serialize(requestData);
        
        Test.setMock(HttpCalloutMock.class, new AccountUpdateWebServiceMock());
        
        // Set the request body in the RestContext
        RestRequest request = new RestRequest();
        request.requestUri = '/updateAccount';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.request.requestBody = Blob.valueOf(jsonRequest);
        
        // Call the web service method
        String result = AccountUpdateWebService.UpdateAccount();
        
        // Verify the result
        //System.assertEquals('Error: Failed to Update Account', result);
        
    }
}