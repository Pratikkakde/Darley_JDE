@IsTest
private class calloutOrderStatusTest {
    
    
    @isTest
    static void testCallout() {
        
        Account acc = new Account();
        acc.name='Test123';
        insert acc;
        
        Order od1 = new Order();
        od1.AccountId = acc.id;
        od1.EffectiveDate= system.today();
        od1.JDE_Order_Number__c = 8374656;
        od1.Status='Draft';
        od1.JDE_Order_Type__c='S5';
        
        insert od1; 
        
        
        
        // Create a mock response for successful callout
        String mockSuccessResponseBody = '{"Order Number":"00000100","orderStatus":"Open"}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_SendSalesOrderToSF';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        
        
        test.startTest();
        calloutOrderStatus.makeCallout(od1.Id);
       
        test.stopTest();
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Success' Limit 1];
        System.assertEquals(1, integrationLogs.size());
        System.assertEquals('Success', integrationLogs[0].Status__c);  
    }
    
    @isTest
    static void testCallout2() {
        
        Account acc = new Account();
        acc.name='Test123';
        insert acc;
        
        
        
        Order od1 = new Order();
        od1.AccountId = acc.id;
        od1.EffectiveDate= system.today();
        od1.JDE_Order_Number__c = 8374656;
        od1.Status='Draft';
        od1.JDE_Order_Type__c='S5';
        
        insert od1; 
        
        
        // Create a mock response for Failed callout.
        String mockFailedResponseBody = 'Callout Failed';
        String mockFailedEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_SendSalesOrderToSF';
        
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockFailedResponseBody, mockFailedEndpoint, 500));
        
        
        test.startTest();
        calloutOrderStatus.makeCallout(od1.Id);
        test.stopTest();
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Failed' Limit 1 ];
        System.assertEquals(1, integrationLogs.size());
        System.assertEquals('Failed', integrationLogs[0].Status__c);
    }
    
    @isTest
    static void testCallout3() {
        
        Account acc = new Account();
        acc.name='Test123';
        insert acc;
        
        Order od1 = new Order();
        od1.AccountId = acc.id;
        od1.EffectiveDate= system.today();
        od1.JDE_Order_Number__c = 8374656;
        od1.Status='Draft';
        od1.JDE_Order_Type__c='S5';
        
        insert od1; 
        
        
        // Create a mock response for successful callout
        String mockSuccessResponseBody = '{"Order Number":"00000100","orderStatus":"Cancelled"}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_SendSalesOrderToSF';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        
        
        test.startTest();
        calloutOrderStatus.makeCallout(od1.Id);
        test.stopTest();
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Success' Limit 1];
        System.assertEquals(1, integrationLogs.size());
        System.assertEquals('Success', integrationLogs[0].Status__c);  
    }
    
    @isTest
    static void testCallout4() {
        
        Account acc = new Account();
        acc.name='Test123';
        insert acc;
        
        Order od1 = new Order();
        od1.AccountId = acc.id;
        od1.EffectiveDate= system.today();
        od1.JDE_Order_Number__c = 8374656;
        od1.Status='Draft';
        od1.JDE_Order_Type__c='S5';
        
        insert od1; 
        
        
        // Create a mock response for successful callout
        String mockSuccessResponseBody = '{"Order Number":"00000100","orderStatus":"Shipped"}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_SendSalesOrderToSF';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        
        
        test.startTest();
        calloutOrderStatus.makeCallout(od1.Id);
        test.stopTest();
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Success' Limit 1];
        System.assertEquals(1, integrationLogs.size());
        System.assertEquals('Success', integrationLogs[0].Status__c);  
    }
    
    @isTest(SeeAllData=True)
    static void testCallout5() {
       OrderSummary ordSumm = [SELECT Id, OriginalOrderId FROM OrderSummary Limit 1];
        system.debug('ordSumm = '+ordSumm);
        // Create a mock response for successful callout
        String mockSuccessResponseBody = '{"Order Number":"00000100","orderStatus":"Open"}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_SendSalesOrderToSF';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        
        test.startTest();
        calloutOrderStatus.getCalloutOrderStatus(ordSumm.Id);
        test.stopTest();
    }  
    
    @isTest(SeeAllData=True)
    static void testCallout51() {
       OrderSummary ordSumm = [SELECT Id, OriginalOrderId FROM OrderSummary Limit 1];
        system.debug('ordSumm = '+ordSumm);
        // Create a mock response for successful callout
        String mockSuccessResponseBody = '{"Order Number":"00000100","orderStatus":"Cancelled"}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_SendSalesOrderToSF';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        
        test.startTest();
        calloutOrderStatus.getCalloutOrderStatus(ordSumm.Id);
        test.stopTest();
    }  
    
    @isTest(SeeAllData=True)
    static void testCallout52() {
       OrderSummary ordSumm = [SELECT Id, OriginalOrderId FROM OrderSummary Limit 1];
        system.debug('ordSumm = '+ordSumm);
        // Create a mock response for successful callout
        String mockSuccessResponseBody = '{"Order Number":"00000100","orderStatus":"Shipped"}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_SendSalesOrderToSF';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        
        test.startTest();
        calloutOrderStatus.getCalloutOrderStatus(ordSumm.Id);
        test.stopTest();
    }  
    
    
    @isTest(SeeAllData=True)
    static void testCallout6() {
       OrderSummary ordSumm = [SELECT Id, OriginalOrderId FROM OrderSummary where OriginalOrder.Jde_Order_Number__c !=null Limit 1];
        system.debug('ordSumm = '+ordSumm);
        // Create a mock response for successful callout
        String mockSuccessResponseBody = '{"Order Number":"00000100","orderStatus":"cancelled"}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_SendSalesOrderToSF';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 500));
        
        test.startTest();
        calloutOrderStatus.getCalloutOrderStatus(ordSumm.Id);
        test.stopTest();
    }  
    //Test Method for OrderViewMethod success for Open
	@isTest(SeeAllData=True)
    static void testCallOut7(){
    OrderSummary ordSumm = [SELECT Id, OriginalOrderId FROM OrderSummary where OriginalOrder.Jde_Order_Number__c !=null Limit 1];
        
       
        
        String mockSuccessResponseBody = '{"Order Number":"00000100","orderStatus":"Open"}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_SendSalesOrderToSF';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        test.startTest();
        calloutOrderStatus.orderOverViewCallout(ordSumm.id);
        test.stopTest();

    }
        //Test Method for OrderViewMethod success for Cancelled
	@isTest(SeeAllData=True)
    static void testCallOut8(){
    OrderSummary ordSumm = [SELECT Id, OriginalOrderId FROM OrderSummary where OriginalOrder.Jde_Order_Number__c !=null Limit 1];
        
       
        
        String mockSuccessResponseBody = '{"Order Number":"00000100","orderStatus":"Cancelled"}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_SendSalesOrderToSF';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        test.startTest();
        calloutOrderStatus.orderOverViewCallout(ordSumm.id);
        test.stopTest();

    }
           //Test Method for OrderViewMethod success for Cancelled
	@isTest(SeeAllData=True)
    static void testCallOut9(){
    OrderSummary ordSumm = [SELECT Id, OriginalOrderId FROM OrderSummary where OriginalOrder.Jde_Order_Number__c !=null Limit 1];
        
       
        
        String mockSuccessResponseBody = '{"Order Number":"00000100","orderStatus":"Cancelled"}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_SendSalesOrderToSF';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        test.startTest();
        calloutOrderStatus.orderOverViewCallout(ordSumm.id);
        test.stopTest();

    }
    //Test Method for OrderViewMethod Failed
	@isTest(SeeAllData=True)
    static void testCallOut11(){
    OrderSummary ordSumm = [SELECT Id, OriginalOrderId FROM OrderSummary where OriginalOrder.Jde_Order_Number__c !=null Limit 1];
        
       
        
        String mockSuccessResponseBody = '{"Order Number":"00000100","orderStatus":"cancelled"}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_SendSalesOrderToSF';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 500));
        test.startTest();
        calloutOrderStatus.orderOverViewCallout(ordSumm.id);
        test.stopTest();

    }    
}