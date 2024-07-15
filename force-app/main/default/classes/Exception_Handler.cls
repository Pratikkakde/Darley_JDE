/******************************************************************************************************************************************************

Name                : Exception_Handler
Author              : Pratik Kakade
Purpose             : This Apex class is designed to log API integration events for updating Account records in Salesforce based on data received 
                      from the JDE Environment. It captures and records both successful updates and failures for audit and debugging purposes.

Description         : The Exception_Handler class provides utility methods to create log records for API integration events related to Account updates.
					  It logs JSON request and response bodies, endpoint URLs, request types, event names, object types, and any errors encountered 
					  during the process. The class contains two methods: createAilRecordonSuccess, which logs successful events, and createAilRecordonFail, 
					  which logs failed events. These logs assist in tracking the integration process, identifying issues, and ensuring data consistency 
					  between Salesforce and the JDE Environment.

Version             : 1.2
Change Log          : Change by Pratik - 19-Feb-24
Test Class          : Exception_HandlerTest
CreateDate          : 12 Jan 2024
LastModifiedDate    : 12 Jan 2024

******************************************************************************************************************************************************/

public  class Exception_Handler {
    /**
* Method to handle Success Api log
* 
* @param body String Accepept Json Body
* @param endpoint String of Endpoint
* @param requestType String of RequestType
* @param Event String of Event which is Insert Or Update
* @param Obj String of for Which Obj it is triggering
* @param requestType String of RetMessage rturnMessage
*/
    
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
    
    /**
* Method to handle Failed Api log
* 
* @param body String Accepept Json Body
* @param endpoint String of Endpoint
* @param requestType String of RequestType
* @param Event String of Event which is Insert Or Update
* @param Obj String of for Which Obj it is triggering
* @param requestType String of RetMessage rturnMessage
* @param Error String of Error Message
*/
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