/**
* Class Name: Exception_Handler
* Purpose:
*   This Apex class is designed to insert Api Intgration log 
*   record  
*    
*   
*
* @author
*   Melonleaf Consulting
*
* @version
*   1.0
*
* @created on
*   Date: 11 jan 2024
* 
* Test class name
* Exception_HandlerTest
*
* Change Log:
*   Pratik kakade - 11 jan 2024 - Developed the first version of the class.
*/

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