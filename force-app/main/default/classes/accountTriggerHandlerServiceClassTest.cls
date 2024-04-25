/******************************************************************************************************************************************************
Name                    : AccountTriggerHandlerServiceClassTest
Author                  : Pratik Kakade
Purpose                 : This Apex class is designed to test the functionality of the AccountTriggerHandlerServiceClass, which handles callouts for inserting and updating sales orders, as well as contacts. 
                          It facilitates communication with an external system (JDE_Integration) to perform operations related to sales orders and contact information.
Description             : This test class verifies the behavior of methods in the AccountTriggerHandlerServiceClass by simulating different scenarios such as successful and unsuccessful callouts, and updating 
                          account details. It creates test data, mocks callout responses, and asserts the expected outcomes.
Version                 : 1.2
Change Log              : Modified by Pratik Kakade on 23 April 2024
Test Class for          : AccountTriggerHandlerServiceClass, AccountTriggerHandler
CreateDate              : 14 Oct 2023
LastModifiedDate        : 23 April 2024
******************************************************************************************************************************************************/

@isTest
public class accountTriggerHandlerServiceClassTest {
    
    @isTest
    Public static void syncOrderToJde1(){
        //insert account from utility class
        Account acc = Utility_DataCreation.CreateAccountRec(1,'Equipment Customer')[0];
        insert acc;
        
        //insert Contact accocitsed with the contact
        contact con1= Utility_DataCreation.createCotactAccoCiatedWithAccount(3,acc.Id)[0];
        insert con1;
        
        //insert Products 
        List<Product2> prdList = Utility_DataCreation.CreteProducts(5);
        insert prdList;
        
        id pricebookId = Test.getStandardPricebookId();
        List<Pricebook2> pricebookList = new List<Pricebook2>();
        pricebookList.add(new pricebook2(Name ='Equipment Price Book', IsActive = true ));
        
        Insert pricebookList;
        
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        
        pbeList.add(new PricebookEntry(Product2Id = prdList[0].Id,  Pricebook2Id = pricebookId, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = prdList[0].Id,  Pricebook2Id = pricebookList[0].Id, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = prdList[1].Id,  Pricebook2Id = pricebookId, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = prdList[1].Id,  Pricebook2Id = pricebookList[0].Id, UnitPrice = 600, IsActive = true));
        
        Insert pbeList;
        
        //insert ordder
        List<order> odList = Utility_DataCreation.createOrder(acc.id, 5, pricebookList[0].id);
        insert odList;
        
        //insert tOrderItem
        List<orderitem> ordItemList = Utility_DataCreation.createOrderItem(5, odList, prdList, pbeList[1].id);
        insert ordItemList; 
        
        List<Account> accList = [SELECT Id, Name, Primary_Division__c, JDE_Address_Number__c,Payment_Terms2__c, RecordTypeId FROM Account];
        
        // Create a mock response for successful callout
        String mockSuccessResponseBody = '{"Order Number":366788}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_AddSalesOrder';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        // System.enqueueJob(new CalloutToRestOrderAddressUpdateQue(newList, oldList ), 1);        
        
        test.startTest();
        //CalloutToRestOrderItem.makeCalloutSalesOrder('{"Name":"order"}', 'Order Product', 'Order Product Insert'); 
        accountTriggerHandlerServiceClass.sendOrderToJde(accList);
        test.stopTest();
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Success' Limit 1];
        System.assertEquals(1, integrationLogs.size());
        System.assertEquals('Success', integrationLogs[0].Status__c);
    }
    
    @isTest
    Public static void syncOrderToJde2(){
        //insert account from utility class
        Account acc = Utility_DataCreation.CreateAccountRec(1,'Equipment Customer')[0];
        insert acc;
        
        //insert Contact accocitsed with the contact
        contact con1= Utility_DataCreation.createCotactAccoCiatedWithAccount(3,acc.Id)[0];
        insert con1;
        
        //insert Products 
        List<Product2> prdList = Utility_DataCreation.CreteProducts(5);
        insert prdList;
        
        id pricebookId = Test.getStandardPricebookId();
        List<Pricebook2> pricebookList = new List<Pricebook2>();
        pricebookList.add(new pricebook2(Name ='Equipment Price Book', IsActive = true ));
        
        Insert pricebookList;
        
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        
        pbeList.add(new PricebookEntry(Product2Id = prdList[0].Id,  Pricebook2Id = pricebookId, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = prdList[0].Id,  Pricebook2Id = pricebookList[0].Id, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = prdList[1].Id,  Pricebook2Id = pricebookId, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = prdList[1].Id,  Pricebook2Id = pricebookList[0].Id, UnitPrice = 600, IsActive = true));
        
        Insert pbeList;
        
        //insert ordder
        List<order> odList = Utility_DataCreation.createOrderwithDarleyDollers(acc.id, 5, pricebookList[0].id);
        insert odList;
        
        //insert tOrderItem
        List<orderitem> ordItemList = Utility_DataCreation.createOrderItem(5, odList, prdList, pbeList[1].id);
        insert ordItemList; 
        
        List<Account> accList = [SELECT Id, Name, Primary_Division__c, JDE_Address_Number__c,Payment_Terms2__c, RecordTypeId FROM Account];
        
        // Create a mock response for successful callout
        String mockSuccessResponseBody = '{"Order Number":366788}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_AddSalesOrder';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        // System.enqueueJob(new CalloutToRestOrderAddressUpdateQue(newList, oldList ), 1);        
        
        test.startTest();
        //CalloutToRestOrderItem.makeCalloutSalesOrder('{"Name":"order"}', 'Order Product', 'Order Product Insert'); 
        accountTriggerHandlerServiceClass.sendOrderToJde(accList);
        test.stopTest();
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Success' Limit 1];
        System.assertEquals(1, integrationLogs.size());
        System.assertEquals('Success', integrationLogs[0].Status__c);
    }
    
    @isTest
    Public static void syncOrderToJde3(){
        //insert account from utility class
        Account acc = Utility_DataCreation.CreateAccountRec(1,'Equipment Customer')[0];
        insert acc;
        
        //insert Contact accocitsed with the contact
        contact con1= Utility_DataCreation.createCotactAccoCiatedWithAccount(3,acc.Id)[0];
        insert con1;
        
        //insert Products 
        List<Product2> prdList = Utility_DataCreation.CreteProducts2(5);
        insert prdList;
        
        id pricebookId = Test.getStandardPricebookId();
        List<Pricebook2> pricebookList = new List<Pricebook2>();
        pricebookList.add(new pricebook2(Name ='Equipment Price Book', IsActive = true ));
        
        Insert pricebookList;
        
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        
        pbeList.add(new PricebookEntry(Product2Id = prdList[0].Id,  Pricebook2Id = pricebookId, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = prdList[0].Id,  Pricebook2Id = pricebookList[0].Id, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = prdList[1].Id,  Pricebook2Id = pricebookId, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = prdList[1].Id,  Pricebook2Id = pricebookList[0].Id, UnitPrice = 600, IsActive = true));
        
        Insert pbeList;
        
        //insert ordder
        List<order> odList = Utility_DataCreation.createOrderwithDarleyDollers(acc.id, 5, pricebookList[0].id);
        insert odList;
        
        //insert tOrderItem
        List<orderitem> ordItemList = Utility_DataCreation.createOrderItem(5, odList, prdList, pbeList[1].id);
        insert ordItemList; 
        
        List<Account> accList = [SELECT Id, Name, Primary_Division__c, JDE_Address_Number__c,Payment_Terms2__c, RecordTypeId FROM Account];
        
        // Create a mock response for successful callout
        String mockSuccessResponseBody = '{"Order Number":366788}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_AddSalesOrder';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        // System.enqueueJob(new CalloutToRestOrderAddressUpdateQue(newList, oldList ), 1);        
        
        test.startTest();
        //CalloutToRestOrderItem.makeCalloutSalesOrder('{"Name":"order"}', 'Order Product', 'Order Product Insert'); 
        accountTriggerHandlerServiceClass.sendOrderToJde(accList);
        test.stopTest();
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Success' Limit 1];
        System.assertEquals(1, integrationLogs.size());
        System.assertEquals('Success', integrationLogs[0].Status__c);
    }
    
    @isTest
    public static void syncContactToJde(){
        String EdarleyRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('EDarley New Registrant').getRecordTypeId();
        
        Account acc = Utility_DataCreation.CreateAccountRec(1, 'EDarley New Registrant')[0];
        insert acc;
        
        string Customer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        string Equipment_Customer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Equipment Customer').getRecordTypeId();
        string Pump_Customer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Pump Customer').getRecordTypeId();
        
        account acc1 = new account();
        acc1.name = 'orio';
        acc1.ShippingPostalCode = '553991';
        acc1.JDE_Address_Number__c = '40930587';
        acc1.RecordTypeId = Equipment_Customer;   
        acc1.Id = acc.id;
        update acc1;
        
        contact con =  Utility_DataCreation.createCotactAccoCiatedWithAccount(1, acc1.id)[0];     
        insert con;
        
        List<Account> accList = [Select Id, Name,  BillingStreet,  BillingState, BillingCity, BillingPostalCode, BillingCountry, Primary_Division__c, JDE_Address_Number__c, recordTypeId,
                                 Primary_POC_Email__c, Phone ,Payment_Terms2__c, ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, 
                                 Region__c, Adjustment_Schedule__c, Credit_Limit__c, Customer_Distribution_Channel__c,Customer_Price_Group__c,JDE_Guest_Account__c from Account ];
        
        
        // Create a mock response for successful callout
        String mockSuccessResponseBody = '{"Order Number":366788}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_AddSalesOrder';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        // System.enqueueJob(new CalloutToRestOrderAddressUpdateQue(newList, oldList ), 1);        
        
        test.startTest();
        //CalloutToRestOrderItem.makeCalloutSalesOrder('{"Name":"order"}', 'Order Product', 'Order Product Insert'); 
        accountTriggerHandlerServiceClass.sendContactToJde(accList);
        test.stopTest();
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Success' Limit 1];
        System.assertEquals(1, integrationLogs.size());
        System.assertEquals('Success', integrationLogs[0].Status__c);
    }
    @isTest
    public static void updateJdeAddNum_test() {
        Account acc = Utility_DataCreation.CreateAccountRec(1, 'Equipment Customer')[0];
        acc.Sync_with_JDE__c = false;
        acc.JDE_Guest_Account__c = true;
        insert acc;
    }
    @isTest
    public static void updateJdeAddNum_testElse() {
        Account acc = Utility_DataCreation.CreateAccountRec(1, 'Equipment Customer')[0];
        acc.Sync_with_JDE__c = false;
        acc.JDE_Guest_Account__c = true;
        insert acc;
        
        Account acc1 = new Account ();
        acc1.id = acc.id;
        acc1.JDE_Guest_Account__c = false;
        update acc1;
    }

   }