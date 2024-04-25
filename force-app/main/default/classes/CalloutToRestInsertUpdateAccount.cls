/******************************************************************************************************************************************************
Name                    : CalloutToRestInsertUpdateAccount
Author                  : Pratik Kakade
Purpose                 : This Apex class is designed to handle Account and Contact triggers, providing methods for after insert and after update operations.
Description             : This class contains a method to perform callouts to an external system (JDE_Integration) for updating Account and Contact records.
                          It prepares and sends JSON data to the specified endpoint, handles the response, and logs integration details.
Version                 : 1.1
Change Log              : Modified by Pratik Kakade on 26 Feb 2024.
Test Class              : 
CreateDate              : 14 Oct 2023
LastModifiedDate        : 14 Oct 2023
******************************************************************************************************************************************************/

public class CalloutToRestInsertUpdateAccount {
    
    @future (callout=true)
    //Callout for Account and Contact Insert.
/************************************************************************************************************************************************************************************************
      Method- makeCalloutInsert is an future methos is making an callout to jde to insert accout or contact details in jde
      @param- wrapperList contains all the data in wraaper that is used to send to an jde
      @param- ObjectName states object is account or contact
      @param- ObjOpperation states operation is insert or update
************************************************************************************************************************************************************************************************/

    public static void makeCalloutInsert(String wrapperList, String ObjectName, String ObjOpperation) {
        
        // Define the endpoint URL
        //String endpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_AddAB'; 
        String endpoint = 'callout:JDE_Integration/ACBM_ORCH_AddAB';
        
        HttpRequest req = new HttpRequest();
        req.setTimeout(85000);
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        //req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf('SFAPI:SFAPI123')));
        
        // Define the request body 
        system.debug('wrapperList'+ JSON.serialize(wrapperList));
        req.setBody(wrapperList);
        
        // Create the HTTP object and make the callout
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('Response Status: '+res);
        system.debug('Response StatusCode: '+res.getStatusCode()); 
        String responseBody = res.getBody();
        
       

        // Handle the response
        if (res.getStatusCode() == 200) {
            // Successful callout
            system.debug('responseBody'+responseBody);
            // Process the response body here if needed           
            //API Integration Log Generation on success
            Map<string,object> reqsData = (map<string,object>) json.deserializeUntyped(wrapperList);
            Map<String,object> respData = (map<string,object>) json.deserializeuntyped(responseBody);
            Exception_Handler.createAilRecordonSuccess(JSON.serializePretty(reqsData), endpoint, 'POST', ObjOpperation, ObjectName,JSON.serializePretty(respData));
            
        }
        else {
            // Error handling
            System.debug('Callout error: ' + res.getStatusCode() + ' \n' + res.getStatus());
            String callOutError = 'StatusCode: '+ res.getStatusCode() + '\n '+ 'Status: '+res.getStatus();
            Map<string,object> reqs1Data = (map<string,object>) json.deserializeUntyped(wrapperList);
            //Map<String,object> resp1Data = (map<string,object>) json.deserializeuntyped(responseBody);
            Exception_Handler.createAilRecordonFail(JSON.serializePretty(reqs1Data), endpoint, 'POST', ObjOpperation, ObjectName, responseBody, callOutError);
        }        
    }
    
/************************************************************************************************************************************************************************************************
      Method- makeCalloutUpdate is an future methos is making an callout to jde to insert accout or contact details in jde
      @param- wrapperList contains all the data in wraaper that is used to send to an jde
      @param- ObjectName states object is account or contact
      @param- ObjOpperation states operation is insert or update
************************************************************************************************************************************************************************************************/
   
    @future (callout=true)
    //Callout for Account and Contact Update.
    public static void makeCalloutUpdate(String wrapperList, String ObjectName, String ObjOpperation) { 
        
        // Define the endpoint URL
        //String endpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_UpdateAB'; 
        String endpoint = 'callout:JDE_Integration/ACBM_ORCH_UpdateAB';
        HttpRequest req = new HttpRequest();
        req.setTimeout(80000);
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        //req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf('SFAPI:SFAPI123')));
        
        system.debug('wrapperList'+wrapperList);
        
        // Define the request body 
        req.setBody(wrapperList);
        
        // Create the HTTP object and make the callout
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('res'+res);
        system.debug('res2'+res.getStatusCode()); 
        String responseBody = res.getBody();
        
        // Handle the response
        if (res.getStatusCode() == 200) {
            // Successful callout
            
            system.debug('responseBody'+responseBody);
            // Process the response body here if needed
            
            //API Integration Log Generation on success
            API_Integration_Log__c ail = new API_Integration_Log__c();
            ail.JSON_Body__c= wrapperList;
            ail.Endpoint__c = endpoint;
            ail.Status__c = 'Success';
            ail.Request_Type__c = 'POST';
            ail.Response_Body__c = responseBody;
            ail.Name__c = ObjOpperation;
            ail.Object__c = ObjectName;
            
            try{
                insert ail;
            } catch(exception ex){
                system.debug('Error : '+ex.getMessage());
            }            
        }
        else {
            // Error handling
            System.debug('Callout error: ' + res.getStatusCode() + ' ' + res.getStatus());
            
            //API Integration Log Generation on Failure
            API_Integration_Log__c ail = new API_Integration_Log__c();
            ail.JSON_Body__c= wrapperList;
            ail.Endpoint__c = endpoint;
            ail.Status__c = 'Failed';
            ail.Request_Type__c = 'POST';
            ail.Response_Body__c = responseBody;
            ail.Name__c = ObjOpperation;
            ail.Object__c = ObjectName;
            
            try{
                insert ail;
            } catch(exception ex){
                system.debug('Error : '+ex.getMessage());
            }
        }
    }    
    
}