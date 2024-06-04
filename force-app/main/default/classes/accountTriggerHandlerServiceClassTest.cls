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
    
    static testMethod void sendEmailOnUpdateAccRecoredTest(){
        //   Account acc = new Account();
        //   acc=TestDataUtilClass.returnAccountRec();
        //   insert acc;
   
           Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
               Account acc = new Account();
                   acc.Name = 'Supplier Name ';
                     acc.Supplier_Rating__c='A+: Strategic Supplier';
                     acc.Email_Address_for_RFQ__c='abc123@gmail.com';
                 //  PDF_Creation__c =true,
                     acc.RecordTypeId=recordTypeId;
              insert acc;
   
   
           Account acc2=new Account();
            acc2.Name = 'Supplier Name 2 ';
                     acc2.Supplier_Rating__c='A+: Strategic Supplier';
                     acc2.Email_Address_for_RFQ__c='abc123@gmail.com';
                     acc2.Email_Address__c='testingEmail@yahoo.com';
                 //  PDF_Creation__c =true,
                     acc2.RecordTypeId=recordTypeId;
              insert acc2;
   
              acc2.Email_Address__c='NewTestingEmail@gmail.com';
             update acc2;
          // Id recordTypeIdd = Schema.SObjectType.Bid_Tracker__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
    
            Bid_Tracker__c BidTracker = new Bid_Tracker__c();
            BidTracker.name='test Name';
           //BidTracker.RecordTypeId=recordTypeIdd;
           insert BidTracker;
            Blob b = Blob.valueOf('Test Data');
           Attachment attachment = new Attachment();
           attachment.ParentId = BidTracker.Id;
           attachment.Name = 'Supplier Name_test value.pdf ';
           attachment.Body = b;
           insert attachment;
   
    
          //Id recordTypeIddLead = Schema.SObjectType.Bid_Tracker__c.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
    
           Lead ld=new Lead();
           ld.FirstName='Test';
           ld.LastName='Name';
          // ld.RecordTypeId=recordTypeIddLead;
           ld.Status='Unqualified';
           ld.Company='test company';
           ld.Email_Address__c='testemail@gmail.com';
           insert ld;
          Id recordTypeIde = Schema.SObjectType.Bid_Line_Item__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
    
          Bid_Line_Item__c bl = new Bid_Line_Item__c();
           bl.RFQ_Number__c=BidTracker.id;
           bl.Bid_Supplier__c=acc.Id;
           bl.Name='Testing';
           bl.Regular_vs_Alternative__c='Regular';
           bl.Supplier_Name_Text__c='huiqwidioq';
           bl.Weeks_ARO__c='3D';
           bl.TLSP_Supplier_Extension__c='WSD';
           bl.Load_Batch_Number__c='2353';
          //bl.Before_due_date__c=system.today()+7;
           bl.RecordTypeId=recordTypeIde;
           bl.Supplier_Part_Number__c='VR-FST-1';	
           bl.Quote_Numbers__c='test value';
           bl.Due_Date__c=system.today()+15;
           bl.Quote_Type__c='Quoted';
           bl.Item_Description__c='bundle';
           bl.Status__c='RFQ Ready for DLA';
           bl.Lead__c=ld.Id;
          insert bl;
        acc.Email_Address__c='testemail@gmail.com';
           test.starttest();
           update acc;
           test.stoptest();
   
              }
   }