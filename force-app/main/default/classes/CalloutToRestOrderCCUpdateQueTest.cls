@isTest
public class CalloutToRestOrderCCUpdateQueTest {
  
    @istest
    public static void method1(){
        
        string Equipment_Customer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Equipment Customer').getRecordTypeId();
  
        Account acc = new Account();
        acc.Name = 'TestAcc';
        acc.RecordTypeId = Equipment_Customer;
        insert acc;
        
        Contact con = new contact();
        con.AccountId = acc.Id;
        con.LastName= 'TestCon';
        insert con;
        
        CustomerCardPayment__c ccp = new CustomerCardPayment__c();
        ccp.Contact__c = con.Id;
        ccp.Card_Last_Four__c = '1111';
        ccp.Card_Type__c = 'Visa';
        
        insert ccp;
        
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.JDE_Part_Number__c = 'AF032';
        p.ProductCode = 'AF032';
        p.isActive=true;
        
        insert p;
        
        id pricebookId = Test.getStandardPricebookId();
        List<Pricebook2> pricebookList = new List<Pricebook2>();
        pricebookList.add(new pricebook2(Name ='Equipment Price Book', IsActive = true ));
        
        Insert pricebookList;
        
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        
        pbeList.add(new PricebookEntry(Product2Id = p.Id,  Pricebook2Id = pricebookId, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = p.Id,  Pricebook2Id = pricebookList[0].Id, UnitPrice = 600, IsActive = true));
        Insert pbeList;
        
        
        order od = new order();
        od.AccountId = acc.id;
        od.Status='draft';
        
        od.EffectiveDate=system.today();
        od.Pricebook2Id= pricebookList[0].id;
        od.BillingStreet ='123 park evenue';
        od.shippingstreet= '123 Grand Evenue';
        od.Payment_Transaction_Id__c = 'AB1786JKHSDF';
        od.B2BCreditCardName__c = 'Visa ending in 1111';
        
        insert od;
        
        order od1 = new order();
        od1.Id = od.Id;
        od1.StoreStatus__c = 'Open';
        od1.JDE_Order_Number__c = 366788;
        update od1;
        
        orderitem oi = new orderitem();
        oi.OrderId=od.Id;
        oi.Product2Id= p.id;
        oi.Quantity= 2;
        oi.PricebookEntryId = pbeList[1].id;
        oi.UnitPrice = 234;
        
        insert oi;
        
        
        List<order> odList = [SELECT Id, JDE_Order_Number__c, B2BGrandTotal__c,B2BCreditCardId__c, B2BCreditCardName__c, Account.RecordTypeId, Account.Name, Payment_Transaction_Id__c FROM Order];
        
        
        // Create a mock response for successful callout
        String mockSuccessResponseBody = '{"Order Number":366788}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_autoCreateCCPrepaymentRecord';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
       // System.enqueueJob(new CalloutToRestOrderAddressUpdateQue(newList, oldList ), 1);        
        
        test.startTest();
        System.enqueueJob(new CalloutToRestOrderCCUpdateQue(odList, odList)); 
        
        test.stopTest();
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Success' Limit 1];
        System.assertEquals(1, integrationLogs.size());
        System.assertEquals('Success', integrationLogs[0].Status__c);
    }
    
    
      @istest
    public static void method2(){
        
        
        String Equipment_Customer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Equipment Customer').getRecordTypeId();
        system.debug('testclass AccountRecordtypeid'+Equipment_Customer);
        Account acc = new Account();
        acc.Name = 'TestAcc';
        acc.RecordTypeId = '0122E000000KnSsQAK';
        insert acc;
        
        Contact con = new contact();
        con.AccountId = acc.Id;
        con.LastName= 'TestCon';
        insert con;
        
        CustomerCardPayment__c ccp = new CustomerCardPayment__c();
        ccp.Contact__c = con.Id;
        ccp.Card_Last_Four__c = '1111';
        ccp.Card_Type__c = 'Visa';
        
        insert ccp;
        
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.JDE_Part_Number__c = 'AF032';
        p.ProductCode = 'AF032';
        p.isActive=true;
        
        insert p;
        
        id pricebookId = Test.getStandardPricebookId();
        List<Pricebook2> pricebookList = new List<Pricebook2>();
        pricebookList.add(new pricebook2(Name ='Equipment Price Book', IsActive = true ));
        
        Insert pricebookList;
        
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        
        pbeList.add(new PricebookEntry(Product2Id = p.Id,  Pricebook2Id = pricebookId, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = p.Id,  Pricebook2Id = pricebookList[0].Id, UnitPrice = 600, IsActive = true));
        Insert pbeList;
        
        
        order od = new order();
        od.AccountId = acc.id;
        od.Status='draft';
        od.EffectiveDate=system.today();
        od.Pricebook2Id= pricebookList[0].id;
        od.BillingStreet ='123 park evenue';
        od.shippingstreet= '123 Grand Evenue';
        od.B2BCreditCardId__c = ccp.id;
        od.B2BCreditCardName__c = 'Visa ending in 1111';
        
        insert od;
        
         order od1 = new order();
        od1.Id = od.Id;
        od1.StoreStatus__c = 'Open';
        od1.JDE_Order_Number__c = 366789;
        
        update od1;
        
        
        orderitem oi = new orderitem();
        oi.OrderId=od.Id;
        oi.Product2Id= p.id;
        oi.Quantity= 2;
        oi.PricebookEntryId = pbeList[1].id;
        oi.UnitPrice = 234;
        
        insert oi;
        
        
        List<order> odList = [SELECT Id, JDE_Order_Number__c, B2BGrandTotal__c,B2BCreditCardId__c, B2BCreditCardName__c, Account.RecordTypeId, Account.Name, Payment_Transaction_Id__c FROM Order];
        system.debug('Account RecordTypeId: '+odList[0].Account.RecordTypeId);
        List<CustomerCardPayment__c> CCdetail = [Select Id, Contact__c, Contact__r.Name, Card_Type__c, Card_Last_Four__c  from CustomerCardPayment__c where id =: ccp.Id];
        
         // Create a mock response for Failed callout
        String mockFailedResponseBody = 'Callout Failed';
        String mockFailedEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_autoCreateCCPrepaymentRecord';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockFailedResponseBody, mockFailedEndpoint, 500));
        
        
        test.startTest();
         System.enqueueJob(new CalloutToRestOrderCCUpdateQue(odList, odList)); 
        //System.enqueueJob(new CalloutToRestOrderAddressUpdateQue(newList, oldList, false )); 
        test.stopTest();
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Failed' Limit 1];
        System.assertEquals(1, integrationLogs.size());
        System.assertEquals('Failed', integrationLogs[0].Status__c);
    }    
}