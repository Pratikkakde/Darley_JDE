/******************************************************************************************************************************************************
Name                    : CalloutRestAPiRetriveAB
Author                  : Pratik Kakade
Purpose                 : This Apex class facilitates making callouts to retrieve Account data from an external system using REST APIs.
Description             : The CalloutRestAPiRetriveAB class provides methods for making callouts to retrieve Account records from an external system 
                          via REST APIs. It includes a method annotated with @AuraEnabled to enable invocation from Lightning components. This class 
                          specifically targets the retrieval of Account data based on specific criteria, such as matching a certain Record Type and 
                          custom field values. It handles constructing the request, making the callout, and processing the response, including error 
                          handling and logging. This class is typically used within Apex trigger handlers or other Apex classes that require integrating 
                          Salesforce with external systems for retrieving Account data.
Version                 : 1.2
Change Log              : Modified by Pratik Kakade on 26 Feb 2024.
Test Class for          : CalloutRestAPiRetriveABTest
CreateDate              : 1 Sept 2023
LastModifiedDate        : 26 Feb 2024
******************************************************************************************************************************************************/

public without sharing class  CalloutRestAPiRetriveAB {
    @AuraEnabled
    public static void makeCallout(String recordId) {
        
        //Fetch the "Equipment Customer" recordtypeId By name
        Map<String, Schema.RecordTypeInfo> recordTypeMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
        String EquipmentCustomer = recordTypeMap.get('Equipment Customer').getRecordTypeId();
        system.debug('recordId ---> '+recordId);
        Id recordIdAsId = (Id)recordId;
        system.debug('recordIdAsId ---> '+recordIdAsId);
        
        //checks Account recordtypeId is Equipment Customer Id or not if yes then proceed
        if (recordIdAsId.getSObjectType() == Account.sObjectType) {
        List<Account> accList = [SELECT Id, JDE_Address_Number__c, RecordTypeId /*,(SELECT id,StoreStatus__c FROM Orders LIMIT 1) */FROM Account where RecordTypeId = :EquipmentCustomer AND Sync_with_JDE__c = true AND  Id =:recordId];
        system.debug('accList ---> '+accList);
        if(!accList.isEmpty()){
            for (Account acc : accList) {
                
               
                    
                    retrieveAccountFromJDE(recordId,acc.JDE_Address_Number__c);
                    System.debug('2 criteria are match'+'\n'+'Calllout succesfully for account!' );
            }
        } 
    } 
    }
    
    public static void retrieveAccountFromJDE(String accountId, String JdeAddressNo) {
        try {
            
            // Define the endpoint URL for the external service callout
            String endpoint = 'callout:JDE_Integration/ACBM_ORCH_GetABWhosWhoCustomerInformation';
            
            HttpRequest req = new HttpRequest();
            req.setTimeout(30000);
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            
            // Construct the request body with the required parameters
            String requestBody = '{"Account id": "'+accountId+'","Jde Address No": "'+JdeAddressNo+'"}';
            system.debug('Request Body= '+requestBody);
            req.setBody(requestBody);
            
            // Send the HTTP request and get the response
            Http http = new Http();
            HTTPResponse res = http.send(req);
            system.debug('res'+res);
            system.debug('res2'+res.getStatusCode()); 
            String responseBody = res.getBody();
            Map<String, object> reqBody = (map<String, Object>)json.deserializeUntyped(requestBody);

            // Handle the response
            
            if (res.getStatusCode() == 200) {
                
                Map<String, object> responseData = (map<String, Object>)json.deserializeUntyped(responseBody);
                
                // Successful callout
                
                //API Integration Log Generation on success
                Exception_Handler.createAilRecordonSuccess(JSON.serializePretty(reqBody),endpoint,'GET','Account Data Retrieve from JDE','Account',JSON.serializePretty(responseData));
                
            } else {
                
                // Error handling
                String callOutError = 'StatusCode: '+ res.getStatusCode() + '\n '+ 'Status: '+res.getStatus();
                
                System.debug('Callout error --->'+callOutError);
                System.debug('Callout body ---> ' + res.getBody() );
                
                //API Integration Log Generation on fail
                Exception_Handler.createAilRecordonFail(JSON.serializePretty(reqBody),endpoint,'GET','Account Data Retrieve from JDE','Account',JSON.serializePretty(responseBody),callOutError);
                
            } 
        } catch (Exception ex ) {
            
            // handle Any error while execution
            String fatelError = '['+ex.getStackTraceString()+']: ' +ex.getMessage();
            System.debug('Error ---> '+fatelError);
            Exception_Handler.createAilRecordonFail('{"Account id": "'+accountId+'","Jde Address No": "'+JdeAddressNo+'"}','callout:JDE_Integration/ACBM_ORCH_GetABWhosWhoCustomerInformation','GET','Account Data Retrieve from JDE','Account',fatelError,fatelError);
            
        }
    }
}