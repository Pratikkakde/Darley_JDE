public class CalloutToRestInsertUpdateAccount {
    
    @future (callout=true)
    //Callout for Account and Contact Insert.
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