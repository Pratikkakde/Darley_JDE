/******************************************************************************************************************************************************
Name                    : CalloutToRestOrderItem
Author                  : Pratik Kakade
Purpose                 : This Apex class is designed to handle callouts for inserting and updating sales orders. It facilitates communication with an external system (JDE_Integration) 
                          to perform operations related to sales orders.
Description             : This class provides methods for making callouts to external REST APIs to insert or update sales orders. It includes two main methods: 
                          makeCalloutSalesOrder for inserting sales orders and makeUpdateCallout for updating existing sales orders. These methods handle the communication 
                          with the external system, manage request and response payloads, and update Salesforce records accordingly. Additionally, the class logs integration 
                          requests and responses in the API_Integration_Log__c object for monitoring and troubleshooting purposes.
Version                 : 1.2
Version                 : 1.2
Change Log              : Modified by Pratik Kakade on 14 March 2024
Test Class              : CalloutToRestOrderItemTest
CreateDate              : 26 Sept 2023
LastModifiedDate        : 14 March 2024
******************************************************************************************************************************************************/
public class CalloutToRestOrderItem {
    
        
    // Method for making callouts to insert sales orders
    //@future (callout=true)
    // Parameters:
    // - wrapperList: JSON string containing the data to be sent in the request
    // - ObjectName: The name of the Salesforce object related to the operation
    // - ObjOpperation: The operation being performed on the Salesforce object

    @future (callout=true)
    //Callout for Order Product Insert.
    public static void makeCalloutSalesOrder(String wrapperList, String ObjectName, String ObjOpperation) { 
        
        // Define the endpoint URL
        //String endpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_AddSalesOrder'; 
        String endpoint = 'callout:JDE_Integration/ACBM_ORCH_AddSalesOrder';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setTimeout(90000);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        
        // Define the request body 
        req.setBody(wrapperList);
        system.debug('wrapperList'+wrapperList);
        
        // Create the HTTP object and make the callout
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('res'+res);
        system.debug('res2'+res.getStatusCode());
        String responseBody = res.getBody();
        
        Map<String, Object> reqdata = (Map<String, Object>) JSON.deserializeUntyped(wrapperList);
        string sf_order_number = (string)reqdata.get('SalesForce Order Number');
        system.debug('Salesforce Order Number: '+sf_order_number);
        
        // Handle the response
        if (res.getStatusCode() == 200) {
            // Successful callout
            //API Integration Log Generation on success           
            Exception_Handler.createAilRecordonSuccess(JSON.serializePretty(reqdata), endpoint, 'POST', ObjOpperation, ObjectName, responseBody);
            
            system.debug('responseBody'+responseBody);
            // Process the response body here
            Map<String, Object> resdata = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            Integer order_number = (Integer)resdata.get('Order Number');
            //String order_status = (string)resdata.get('status');
            system.debug('order_number: '+order_number);
            List<order> odList = [SELECT id, name, status, OrderNumber FROM order WHERE OrderNumber =: sf_order_number];
            List<order> odUpdateList = new List<order>();
            for (order od : odList) {
                od.JDE_Order_Number__c = decimal.valueOf(order_number);
                odUpdateList.add(od);
            }
            
            try{
                update odUpdateList;
            } catch (exception ex) {
                system.debug('Error: '+ex.getMessage());
            }                       
        } else {
            
            // Error handling            
            //API Integration Log Generation on Fail
            String callOutError = 'StatusCode: '+ res.getStatusCode() + '\n '+ 'Status: '+res.getStatus();
            System.debug('Callout error: ' + res.getStatusCode() + '\n ' + res.getStatus());
            Exception_Handler.createAilRecordonFail(JSON.serializePretty(reqdata), endpoint, 'POST', ObjOpperation, ObjectName, responseBody, callOutError);
        }
    }
    
    // Method for making callouts to update existing sales orders
    // @future (callout=true)
    // Parameters:
    // - wrapperList: JSON string containing the data to be sent in the request
    // - ObjectName: The name of the Salesforce object related to the operation
    // - ObjOpperation: The operation being performed on the Salesforce object
    
    @future (callout=true)
    public static void makeUpdateCallout(String wrapperList, String ObjectName, String ObjOpperation){
        // Define the endpoint URL
        //String endpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_UpdateSalesOrder'; 
        String endpoint = 'callout:JDE_Integration/ACBM_ORCH_UpdateSalesOrder'; 
        HttpRequest req = new HttpRequest();
        req.setTimeout(85000);
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        //req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf('SFAPI:SFAPI123')));
        
        // Define the request body 
        system.debug('wrapperList'+ wrapperList);
        system.debug('wrapperList'+ JSON.serialize(wrapperList));
        //req.setBody('{"Alpha Name":"Batman2","Business Unit":"Equipment","Billing Address 1":"555 easy rd","Billing City":"Houston","Billing State":"TX","Billing Postal Code":"77089","Division":"Equipment","DOM or EXP":"Domestic Export","Customer Type":"Individuals","Equipment Customer Type":"Individuals","Phone Number":"9998887456","Electronic Address Type":"","Electronic Address":"test@test.com","Contact Information": "", "Account_id":"Newtest11","Contact_id":"Newtest22","First Name":"First","Last Name":"Last","Middle Name":"Middle","Shipping Address 1":"654 northgate","Shipping City":"Alvin","Shipping State":"TX","Contact Address 1":"777 vegas","Contact City":"Las Vegas","Contact State":"NV","Contact Postal Code":"32156","Contact Title":"CEO","Payment Terms":"Net 30","Shipping Postal Code":"77388"}');
        req.setBody(wrapperList);
        
        // Create the HTTP object and make the callout
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('Response Status: '+res);
        system.debug('Response StatusCode: '+res.getStatusCode()); 
        String responseBody = res.getBody();
        Map<String,Object> reqBody = (Map<String,Object>)JSON.deserializeUntyped(wrapperList);
        // Handle the response
        if (res.getStatusCode() == 200) {
            // Successful callout
            system.debug('responseBody'+responseBody);
            // Process the response body here
            //API Integration Log Generation on success    
            Exception_Handler.createAilRecordonSuccess(JSON.serializePretty(reqBody), endpoint, 'POST', ObjOpperation, ObjectName, responseBody);
            
            
        } else {
            // Error handling          
            //API Integration Log Generation on Failure
            String callOutError = 'StatusCode: '+ res.getStatusCode() + '\n '+ 'Status: '+res.getStatus();
            System.debug('Callout error: ' + res.getStatusCode() + ' ' + res.getStatus());
            Exception_Handler.createAilRecordonFail(JSON.serializePretty(reqBody), endpoint, 'POST', ObjOpperation, ObjectName, responseBody, callOutError);

        }   
    }
}