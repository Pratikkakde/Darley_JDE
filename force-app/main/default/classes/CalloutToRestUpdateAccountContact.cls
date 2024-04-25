/******************************************************************************************************************************************************
Name                    : CalloutToRestUpdateAccountContact
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

public class CalloutToRestUpdateAccountContact {
    
    @future (callout=true)
    //Callout for Account and Contact Update.
/************************************************************************************************************************************************************************************************
      Method- makeCalloutUpdate is an future methos is making an callout to jde to update accout or contact details in jde
      @param- wrapperList contains all the data in wraaper that is used to send to an jde
      @param- ObjectName states object is account or contact
      @param- ObjOpperation states operation is insert or update
************************************************************************************************************************************************************************************************/

    public static void makeCalloutUpdate(String wrapperList, String ObjectName, String ObjOpperation){ 
        
        // Define the endpoint URL
        // String endpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_UpdateAB'; 
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

         Map<string,object> reqsData = (map<string,object>) json.deserializeUntyped(wrapperList);
         Map<String,object> respData = (map<string,object>) json.deserializeuntyped(responseBody);
            // Successful callout
        
        // Handle the response
        if (res.getStatusCode() == 200) {
            
            system.debug('responseBody'+responseBody);
           
            Exception_Handler.createAilRecordonSuccess(JSON.serializePretty(reqsData), endpoint, 'POST', ObjOpperation, ObjectName,JSON.serializePretty(respData));
           
        } else {
            // Error handling
            
            System.debug('Callout error: ' + res.getStatusCode() + ' \n' + res.getStatus());
            String callOutError = 'StatusCode: '+ res.getStatusCode() + '\n '+ 'Status: '+res.getStatus();
            
            Exception_Handler.createAilRecordonFail(JSON.serializePretty(reqsData), endpoint, 'POST', ObjOpperation, ObjectName, JSON.serializePretty(respData), callOutError);

        }
    }
}