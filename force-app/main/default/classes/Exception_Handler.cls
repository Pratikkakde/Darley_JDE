/******************************************************************************************************************************************************

Name 			    : Exception_Handler
Author 			    : Pratik Kakade
Purpose			    : This Apex class is designed to insert Api Intgration log record 

Description		    : The AccountUpdateWebService class provides a RESTful web service endpoint for updating Account records in Salesforce. 
			      It receives JSON data containing account information from JDE Environment and updates the corresponding Account records in Salesforce based on the provided data. If the account exists, it checks for any changes in the received data and updates the fields accordingly. If no changes are found, it returns a success message indicating that the account is already updated. If the account does not exist, it returns a failure message. It also logs API integration events for successful updates and failures.

Version			    : 1.1
Change Log		    : Change by Pratik - 19-Feb-24
Test Class  		    : AccountUpdateWebServiceTest
CreateDate		    : Date: 11 jan 2024
LastModifiedDate	    : Date: 11 jan 2024

******************************************************************************************************************************************************/
 

public  class Exception_Handler {
 public static void createAilRecordonSuccess(String body, String endpoint, String requestType, String Event, String obj, String retMsg){

    API_Integration_Log__c ail = new API_Integration_Log__c();
            ail.JSON_Body__c= body;
            ail.Endpoint__c = endpoint;
            ail.Request_Type__c = requestType;
            ail.Name__c = Event;
            ail.Object__c = obj;
            ail.Status__c = 'Success';
            ail.Response_Body__c = retMsg;

           insert ail ;
 
        }
    public static void createAilRecordonFail(String body, String endpoint, String requestType, String Event, String obj, String retMsg, String error){

    API_Integration_Log__c ail = new API_Integration_Log__c();
            ail.JSON_Body__c= body;
            ail.Endpoint__c = endpoint;
            ail.Request_Type__c = requestType;
            ail.Name__c = Event;
            ail.Object__c = obj;
            ail.Status__c = 'Failed';
            ail.Response_Body__c = retMsg;
            ail.Fatal_Errors__c = error;

           insert ail ;
 
        }
}