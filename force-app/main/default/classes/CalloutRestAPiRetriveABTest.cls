/******************************************************************************************************************************************************
Name 			    : CalloutRestAPiRetriveABTest
Author 			    : Pratik Kakade
Purpose			    : This Apex test class is designed to test the functionality of the CalloutRestAPiRetriveAB class.
Description		    : This class contains test methods to validate the behavior of the CalloutRestAPiRetriveAB class under different scenarios, including successful callouts, failed callouts, and error handling.
Version			    : 1.2
Change Log		    : Changed by Pratik on 13-Feb-24
Test Class for 		: CalloutRestAPiRetriveAB
CreateDate		    : 23 Nov 2023
LastModifiedDate	: 13-Feb-24
******************************************************************************************************************************************************/

@isTest
public class CalloutRestAPiRetriveABTest {
    
    @istest
    // for successful Callout
    static void makeCalloutTestSuccess(){
        List<account> accList = Utility_DataCreation.CreateAccountRec(5,'Equipment Customer');
        insert accList;
        
        List<Pricebook2> pricebookList = new List<Pricebook2>();
        pricebookList.add(new pricebook2(Name ='Equipment Price Book', IsActive = true ));
        Insert pricebookList;
        
        List<order> orderList = Utility_DataCreation.createOrder(accList[0].id, 2,pricebookList[0].id);
        insert orderList;
        
        Account accRecord = [Select Id, Name, Primary_Division__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, Customer_Distribution_Channel__c,
                             Primary_POC_Email__c, Phone, Payment_Terms2__c, ShippingPostalCode, JDE_Address_Number__c, Customer_Price_Group__c, RecordTypeId,
                             Adjustment_Schedule__c, Credit_Limit__c from Account where name = 'Test120' Limit 1];
        
        // Create a mock response for successful callout
        String mockSuccessResponseBody = '{"Address Number":40925391,"Alpha Name":"Test120","Business Unit Code":" 400","Search Type":"C","Sold_Bill_To":40925391,"Division Code":"400","DOM or EXP Code":"EXP","Customer Type Code":"IND","Category Code_15":"WEB","Equipment Customer Type Code":"IND","Address Line 1":"112 OCEAN AVENUE","Address Line 2":" ","Address Line 3":" ","Address Line 4":" ","Postal Code":"11701","City":"AMITYVILLE","County":" ","State":"NY","Line_Number_Phone":1,"Phone Number":"8542345797","Credit Limit":1,"Payment Instrument":"!","Related Address Number":1,"Billing Address Type":"X","Business Unit":"Equipment","DOM or EXP":"Export","Customer Type":"*Blanks","Division":"Equipment","Adjustment Schedule":"*Blanks","Customer Price Group":"*Blanks","Country":"United States","Payment Terms":"NET 45"}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_GetABWhosWhoCustomerInformation';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        
        test.startTest();
        CalloutRestAPiRetriveAB.makeCallout(accRecord.Id);
        test.stopTest();
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Success' Limit 1];
        System.assertEquals(1, integrationLogs.size());
        System.assertEquals('Success', integrationLogs[0].Status__c);
        
    }
    
    @isTest
    // for Failed Callout.
    static void makeCalloutTestFail(){
        List<account> accList = Utility_DataCreation.CreateAccountRec(5,'Equipment Customer');
        insert accList;
        
        
        Account accRecord = [Select Id, Name from Account where name = 'Test120' Limit 1];
        
        // Create a mock response for Failed callout.
        String mockFailedResponseBody = 'Callout Failed';
        String mockFailedEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_GetABWhosWhoCustomerInformation';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockFailedResponseBody, mockFailedEndpoint, 500));
        
        test.startTest();
        CalloutRestAPiRetriveAB.makeCallout(accRecord.Id);
        test.stopTest();
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Failed' Limit 1];
        System.assertEquals(1, integrationLogs.size());
        System.assertEquals('Failed', integrationLogs[0].Status__c);
        
    }
    
    //Test class to cover Catch Block By testing
    @istest
    static void makeCalloutTestCatchBlock(){
        List<account> accList = Utility_DataCreation.CreateAccountRec(5,'Equipment Customer');
        insert accList;
        
        
        Account accRecord = [Select Id, Name from Account where name = 'Test120' Limit 1];
        
        // Create a mock response for Failed callout.
        String mockFailedResponseBody = 'Callout Failed';
        String mockFailedEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_GetABWhosWhoCustomerInformation';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockFailedResponseBody, mockFailedEndpoint, 500));
        
        test.startTest();
        CalloutRestAPiRetriveAB.makeCallout(accRecord.Id);
        test.stopTest();
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Failed' Limit 1];
        System.assertEquals(1, integrationLogs.size());
        System.assertEquals('Failed', integrationLogs[0].Status__c);
        
    }
    
}