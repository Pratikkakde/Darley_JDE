/******************************************************************************************************************************************************
Name                    : CalloutToRestOrderItemTest
Author                  : Pratik Kakade
Purpose                 : This Apex class is designed to handle Account triggers, providing methods for after insert and after update operations.
Description             : This class provides methods to process Account records, including splitting address fields, handling record type changes, and syncing data with an external system.
Version                 : 1.2
Change Log              : Modified by Pratik Kakade on 26 Feb 2024.
Test Class for          : CalloutToRestOrderItem, OrderProductTriggerHandler
CreateDate              : 1 Sept 2023
LastModifiedDate        : 26 Feb 2024
******************************************************************************************************************************************************/

@isTest
public class CalloutToRestOrderItemTest {
    @isTest
    //This test method tests OrderItem Insert.
    public static void orderItemInsertTest(){
        String EquipmentCustomer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Equipment Customer').getRecordTypeId();
        
        Account acc = Utility_DataCreation.CreateAccountRec(1,'Equipment Customer')[0];
        insert acc;
        
        Product2 p = Utility_DataCreation.CreteProducts(1)[0];
        insert p;
        
        Product2 p1 = Utility_DataCreation.CreteProducts2(1)[0];
        insert p1;
        
        id pricebookId = Test.getStandardPricebookId();
        List<Pricebook2> pricebookList = new List<Pricebook2>();
        pricebookList.add(new pricebook2(Name ='Equipment Price Book', IsActive = true ));
        
        Insert pricebookList;
        
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        
        pbeList.add(new PricebookEntry(Product2Id = p.Id,  Pricebook2Id = pricebookId, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = p.Id,  Pricebook2Id = pricebookList[0].Id, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = p1.Id,  Pricebook2Id = pricebookId, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = p1.Id,  Pricebook2Id = pricebookList[0].Id, UnitPrice = 600, IsActive = true));
        
        Insert pbeList;
        
        order od = Utility_DataCreation.createOrder(acc.id, 1, pricebookList[0].id)[0];
        insert od;
        
        order od1 = Utility_DataCreation.createOrderwithDarleyDollers(acc.id, 1, pricebookList[0].id)[0];
        insert od1;
        
        order od2 = Utility_DataCreation.createOrderwithDarleyDollers(acc.id, 1, pricebookList[0].id)[0];
        insert od2;
        
        
        orderitem oi = Utility_DataCreation.createOrderItem(1, Utility_DataCreation.createOrder(acc.id, 1, pricebookList[0].id), Utility_DataCreation.CreteProducts(1), pbeList[1].id)[0];
        System.debug('oi ---> '+oi);
        oi.OrderId = od.id;
        oi.Product2Id = p.id;
        insert oi;
        
        orderitem oi1 = new orderitem();
        oi1.OrderId=od.Id;
        oi1.Product2Id= p.id;
        oi1.Id = oi.id;
        oi1.Quantity= 3;
        oi1.UnitPrice = 234;
        //oi1.TypeCode = 'product';
        update oi1;
        
        orderitem oi2 = Utility_DataCreation.createOrderItem(1, Utility_DataCreation.createOrderwithDarleyDollers(acc.id, 1, pricebookList[0].id), Utility_DataCreation.CreteProducts2(1), pbeList[3].id)[0];
        oi2.OrderId = od1.id;
        oi2.Product2Id = p1.id;
        insert oi2;
        
        orderitem oi3 = Utility_DataCreation.createOrderItem(1, Utility_DataCreation.createOrderwithDarleyDollers(acc.id, 1, pricebookList[0].id), Utility_DataCreation.CreteProducts(1), pbeList[1].id)[0];
        oi3.OrderId = od1.id;
        oi3.Product2Id = p.id;
        insert oi3;
        
        // Create a mock response for successful callout
        String mockSuccessResponseBody = '{"Order Number":366788}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_AddSalesOrder';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        // System.enqueueJob(new CalloutToRestOrderAddressUpdateQue(newList, oldList ), 1);        
        
        test.startTest();
        CalloutToRestOrderItem.makeCalloutSalesOrder('{"Name":"order"}', 'Order Product', 'Order Product Insert'); 
        
        test.stopTest();
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Success' Limit 1];
        System.assertEquals(1, integrationLogs.size());
        System.assertEquals('Success', integrationLogs[0].Status__c);
        
    }
    
    @isTest
    //This test method tests OrderItem Insert, for failed callout
    public static void orderItemInsertTest1(){
        Account acc = Utility_DataCreation.CreateAccountRec(1,'Equipment Customer')[0];
        insert acc;
        
        Product2 p = Utility_DataCreation.CreteProducts(1)[0];
        insert p;
        
        id pricebookId = Test.getStandardPricebookId();
        List<Pricebook2> pricebookList = new List<Pricebook2>();
        pricebookList.add(new pricebook2(Name ='Equipment Price Book', IsActive = true ));
        
        Insert pricebookList;
        
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        
        pbeList.add(new PricebookEntry(Product2Id = p.Id,  Pricebook2Id = pricebookId, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = p.Id,  Pricebook2Id = pricebookList[0].Id, UnitPrice = 600, IsActive = true));
        
        Insert pbeList;
        
        order od = Utility_DataCreation.createOrder(acc.id, 1, pricebookList[0].id)[0];
        insert od;
        
        orderitem oi = Utility_DataCreation.createOrderItem(1, Utility_DataCreation.createOrder(acc.id, 1, pricebookList[0].id), Utility_DataCreation.CreteProducts(1), pbeList[1].id)[0];
        oi.OrderId=od.Id;
        oi.Product2Id= p.id;
        
        insert oi;
        
        // Create a mock response for Failed callout
        String mockFailedResponseBody = 'Callout Failed';
        String mockFailedEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_AddSalesOrder';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockFailedResponseBody, mockFailedEndpoint, 500));
        
        test.startTest();
        CalloutToRestOrderItem.makeCalloutSalesOrder('{"Name":"order"}','Order Product', 'Order Product Insert'); 
        test.stopTest();
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Failed' Limit 1];
        System.assertEquals(1, integrationLogs.size());
        System.assertEquals('Failed', integrationLogs[0].Status__c);
        
    }
    
    //This test method tests OrderItem Insert if condition, for success callout
    @isTest
    public static void orderItemInsertTestIf(){
        Account acc = Utility_DataCreation.CreateAccountRec(1,'Equipment Customer')[0];
        insert acc;
        
        Product2 p = Utility_DataCreation.CreteProducts(1)[0];
        insert p;
        
        id pricebookId = Test.getStandardPricebookId();
        List<Pricebook2> pricebookList = new List<Pricebook2>();
        pricebookList.add(new pricebook2(Name ='Equipment Price Book', IsActive = true ));
        
        Insert pricebookList;
        
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        
        pbeList.add(new PricebookEntry(Product2Id = p.Id,  Pricebook2Id = pricebookId, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = p.Id,  Pricebook2Id = pricebookList[0].Id, UnitPrice = 600, IsActive = true));
        Insert pbeList;
        
        order od = Utility_DataCreation.createOrder(acc.id, 1, pricebookList[0].id)[0];
        insert od;
        
        orderitem oi = Utility_DataCreation.createOrderItem(1, Utility_DataCreation.createOrder(acc.id, 1, pricebookList[0].id), Utility_DataCreation.CreteProducts(1), pbeList[1].id)[0];
        oi.OrderId=od.Id;
        oi.Product2Id= p.id;
        insert oi;
        
        orderitem oi1 = new orderitem();
        oi1.Id = oi.id;
        oi1.Quantity= 3;
        
        update oi1;
        
        orderitem oi2 = new orderitem();
        oi2.Id = oi1.id;
        delete oi2;
        
        // Create a mock response for successful callout
        String mockSuccessResponseBody = '{"Order Number":366788}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_AddSalesOrder';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        // System.enqueueJob(new CalloutToRestOrderAddressUpdateQue(newList, oldList ), 1);        
        
        test.startTest();
        CalloutToRestOrderItem.makeCalloutSalesOrder('{"Name":"order"}', 'Order Product', 'Order Product Insert'); 
        
        test.stopTest();
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Success' Limit 1];
        System.assertEquals(1, integrationLogs.size());
        System.assertEquals('Success', integrationLogs[0].Status__c);
    }
    
    ////This test method tests OrderItem Insert if condition, for failed callout
    @isTest
    public Static void orderItemInsertTestIfelse(){
        
        Account acc = Utility_DataCreation.CreateAccountRec(1,'Equipment Customer')[0];
        insert acc;
        
        Product2 p = Utility_DataCreation.CreteProducts(1)[0];
        insert p;
        
        id pricebookId = Test.getStandardPricebookId();
        List<Pricebook2> pricebookList = new List<Pricebook2>();
        pricebookList.add(new pricebook2(Name ='Equipment Price Book', IsActive = true ));
        
        Insert pricebookList;
        
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        
        pbeList.add(new PricebookEntry(Product2Id = p.Id,  Pricebook2Id = pricebookId, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = p.Id,  Pricebook2Id = pricebookList[0].Id, UnitPrice = 600, IsActive = true));
        
        Insert pbeList;
        
        order od = Utility_DataCreation.createOrder(acc.id, 1, pricebookList[0].id)[0];
        od.JDE_Order_Number__c = 366788;
        insert od;
        
        orderitem oi = Utility_DataCreation.createOrderItem(1, Utility_DataCreation.createOrder(acc.id, 1, pricebookList[0].id), Utility_DataCreation.CreteProducts(1), pbeList[1].id)[0];
        oi.OrderId=od.Id;
        oi.Product2Id= p.id;
        insert oi;
        
        // Create a mock response for Failed callout
        String mockFailedResponseBody = 'Callout Failed';
        String mockFailedEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_AddSalesOrder';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockFailedResponseBody, mockFailedEndpoint, 500));
        
        test.startTest();
        CalloutToRestOrderItem.makeCalloutSalesOrder('{"Name":"order"}','Order Product', 'Order Product Insert'); 
        test.stopTest();
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Failed' Limit 1];
        System.assertEquals(1, integrationLogs.size());
        System.assertEquals('Failed', integrationLogs[0].Status__c);
        
    }
    
    @isTest
    public Static void orderItemUpdateTestIfelse(){
        String EquipmentCustomer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Equipment Customer').getRecordTypeId();
        
        Account acc= new account();
        acc.Name='Test';
        acc.RecordTypeId = EquipmentCustomer;
        insert acc;
        
        Product2 p = Utility_DataCreation.CreteProducts(1)[0];
        
        insert p;
        
        id pricebookId = Test.getStandardPricebookId();
        List<Pricebook2> pricebookList = new List<Pricebook2>();
        pricebookList.add(new pricebook2(Name ='Equipment Price Book', IsActive = true ));
        
        Insert pricebookList;
        
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        
        pbeList.add(new PricebookEntry(Product2Id = p.Id,  Pricebook2Id = pricebookId, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = p.Id,  Pricebook2Id = pricebookList[0].Id, UnitPrice = 600, IsActive = true));
        
        Insert pbeList;
        
        order od = Utility_DataCreation.createOrder(acc.id, 1, pricebookList[0].id)[0];
        od.JDE_Order_Number__c = 366788;
        insert od;
        
        orderitem oi = new orderitem();
        oi.OrderId=od.Id;
        oi.Product2Id= p.id;
        oi.Quantity= 2;
        oi.PricebookEntryId = pbeList[1].id;
        oi.UnitPrice = 234;
        
        insert oi;
        orderitem oi1 = new orderitem();
        oi1.OrderId=od.Id;
        oi1.Product2Id= p.id;
        oi1.Id = oi.id;
        oi1.Quantity= 3;
        oi1.UnitPrice = 234;
        //oi1.TypeCode = 'product';
        update oi1;
        
        // Create a mock response for Failed callout
        String mockFailedResponseBody = 'Callout Failed';
        String mockFailedEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_AddSalesOrder';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockFailedResponseBody, mockFailedEndpoint, 200));
        
        test.startTest();
        CalloutToRestOrderItem.makeUpdateCallout('{"Name":"order"}','Order Product', 'Order Product Insert'); 
        test.stopTest();
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Success' Limit 1];
        System.assertEquals(1, integrationLogs.size());
        System.assertEquals('Success', integrationLogs[0].Status__c);
        
    }
    @istest
    public static void InseretOrderTest(){
        test.starttest();
        id pricebookId = Test.getStandardPricebookId();
        Account acc = Utility_DataCreation.CreateAccountRec(2, 'Equipment Customer')[0];
        insert acc;
        Order od = Utility_DataCreation.createOrder(acc.id, 1,pricebookId)[0];
        insert od;
        
        String mockSuccessResponseBody = '{"Order Number":366788}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_AddSalesOrder';
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        CalloutToRestOrderItem.makeCalloutSalesOrder('{"Name":"order"}', 'Order Product', 'Order Product Insert'); 
        
        test.stoptest();
    }
}