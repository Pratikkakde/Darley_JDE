@isTest
public class IntegrationLogDataControllerTest {
    @isTest
    //For CalloutToRestAPI
    public static void CalloutToRestAPITest(){
        
        
        API_Integration_Log__c AIL = new API_Integration_Log__c();
        AIL.status__c = 'Failed';
        AIL.Endpoint__c = 'callout:JDE_Integration/ACBM_ORCH_GetItem';
        AIL.Response_Body__c = '{"Stocking Type":"Phantom","ACBM_ORCH_SendItemInformationToSF":{"Second Item Number":"AF032","Third Item Number":"C-2","Cat Code 8":"WEB","Cost Meth":"22","Unit Cost":400,"Stocking Type":"Phantom","Unit Price":603,"markupDISTI":"1.28","markupDISTII":"1.25","markupDISTIII":"1.23","markupDISTIV":"1.20","markupDISTV":"1.18","markupDISTVI":"1.15","baseDISTI":"771.84","baseDISTII":"753.75","baseDISTIII":"741.69","baseDISTIV":"723.6","baseDISTV":"711.54","baseDISTVI":"693.45","Available":-38,"On Hand":0,"Committed":38,"Backorder":38}}';
        AIL.JSON_Body__c = '{"2nd Item Number": "AF032"}';
        AIL.Request_Type__c = 'GET';
        
        
        insert AIL;
        
        List< API_Integration_Log__c> apiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                      Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c  limit 1 ];
        
        
        // Create a test record
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.JDE_Part_Number__c = 'AF032';
        p.ProductCode = 'AF032';
        p.isActive=true;
        
        insert p;
        
        id pricebookId = Test.getStandardPricebookId();
        
        List<Pricebook2> pricebookList = new List<Pricebook2>();
        pricebookList.add(new pricebook2(Name ='Equipment Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist I Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist II Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist III Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist IV Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist V Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist VI Price Book', IsActive = true ));
        
        
        insert pricebookList;
        
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        
        pbeList.add(new PricebookEntry(Product2Id = p.Id,  Pricebook2Id = pricebookId, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = p.Id,  Pricebook2Id = pricebookList[0].Id, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = p.Id,  Pricebook2Id = pricebookList[1].Id, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = p.Id, Pricebook2Id = pricebookList[2].Id, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = p.Id, Pricebook2Id = pricebookList[3].Id, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = p.Id, Pricebook2Id = pricebookList[4].Id, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = p.Id, Pricebook2Id = pricebookList[5].Id, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = p.Id, Pricebook2Id = pricebookList[6].Id, UnitPrice = 600, IsActive = true));
        
        
        insert pbeList;
        system.debug('Pbe list'+pbeList);
        
        List<PricebookEntry> priceBookEntries = [SELECT Pricebook2Id, Pricebook2.Name, Pricebook2.isActive, ProductCode, UnitPrice, product2Id,product2.JDE_Part_Number__c, IsActive FROM PricebookEntry  where product2.JDE_Part_Number__c = 'AF032'];
        
        
        
        // Create a mock response for successful callout
        String mockSuccessResponseBody = '{"Stocking Type":"Phantom","ACBM_ORCH_SendItemInformationToSF":{"Second Item Number":"AF032","Third Item Number":"C-2","Cat Code 8":"WEB","Cost Meth":"22","Unit Cost":400,"Stocking Type":"Phantom","Unit Price":603,"markupDISTI":"1.28","markupDISTII":"1.25","markupDISTIII":"1.23","markupDISTIV":"1.20","markupDISTV":"1.18","markupDISTVI":"1.15","baseDISTI":"771.84","baseDISTII":"753.75","baseDISTIII":"741.69","baseDISTIV":"723.6","baseDISTV":"711.54","baseDISTVI":"693.45","Available":-38,"On Hand":0,"Committed":38,"Backorder":38}}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_GetItem';
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        
        test.startTest();
        IntegrationLogDataController.processData(AIL.Id);
        test.stopTest();
        
        List< API_Integration_Log__c> updatedApiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                             Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c where status__c= 'Success'  limit 1 ];
        System.assertEquals(1, updatedApiLogRecord.size());
        system.assertEquals('Success', updatedApiLogRecord[0].Status__c);
        //system.assertEquals(mockSuccessResponseBody, updatedApiLogRecord[0].Response_Body__c);
        
    }
    
    @isTest
    //For CalloutToRestAPI else Condition
    public static void CalloutToRestAPIElseConditionTest(){
        
        
        API_Integration_Log__c AIL = new API_Integration_Log__c();
        AIL.status__c = 'Failed';
        AIL.Endpoint__c = 'callout:JDE_Integration/ACBM_ORCH_GetItem';
        AIL.Response_Body__c = '{"Animal":"Dog"}';
        AIL.JSON_Body__c = '{"2nd Item Number": "AF032"}';
        AIL.Request_Type__c = 'GET';
        
        
        insert AIL;
        
        List< API_Integration_Log__c> apiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                      Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c  limit 1 ];
        
        
        // Create a mock response for failed callout
        String mockFailedResponseBody = 'Callout failed';
        String mockFailedEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_GetItem';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockFailedResponseBody, mockFailedEndpoint, 500));
        
        test.startTest();
        IntegrationLogDataController.processData(AIL.Id);
        test.stopTest();
        
        List< API_Integration_Log__c> updatedApiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                             Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c where status__c = 'Failed'  limit 1 ];
        
        System.assertEquals(1, updatedApiLogRecord.size());
        system.assertEquals('Failed', updatedApiLogRecord[0].Status__c);
        system.assertEquals(mockFailedResponseBody, updatedApiLogRecord[0].Response_Body__c);
    }
    
    
    @isTest
    //For CalloutRestAPiRetriveAB
    public static void CalloutRestAPiRetriveABTest(){
        
        Account acc = new Account();
        acc.Name = 'KANE WILLIAMSONS';
        acc.Primary_Division__c = 'Equipment';
        acc.BillingStreet  = '77 NARROW STREET';
        acc.BillingCity = 'HOUSTON';
        acc.BillingState = 'Texas';
        acc.BillingPostalCode = '77084';
        acc.Customer_Distribution_Channel__c = 'Export';
        acc.Primary_POC_Email__c = 'test@test.com';
        acc.Phone = '7346498567'; 
        acc.Payment_Terms2__c = 'Net 30';
        acc.ShippingStreet  = '77 NARROW STREET';
        acc.ShippingCity = 'HOUSTON';
        acc.ShippingState = 'Texas';
        acc.ShippingPostalCode = '77084';
        acc.ShippingPostalCode = '77084';
        
        acc.Adjustment_Schedule__c = 'Darley';
        acc.Credit_Limit__c = 1 ;
        
        insert acc;
        
        API_Integration_Log__c AIL = new API_Integration_Log__c();
        AIL.status__c = 'Failed';
        AIL.Endpoint__c = 'callout:JDE_Integration/ACBM_ORCH_GetABWhosWhoCustomerInformation';
        AIL.Response_Body__c = '{"Address Number":40927071,"Alpha Name":"KANE WILLIAMSONS","Business Unit Code":" 400","Search Type":"C","Sold_Bill_To":40927071,"Division Code":"400","DOM or EXP Code":"DOM","Customer Type Code":"IND","Category Code_15":"WEB","Equipment Customer Type Code":"IND","Address Line 1":"110 SUTTER STREET WEST","Address Line 2":" ","Address Line 3":" ","Address Line 4":" ","Postal Code":"94104","City":"SAN FRANCISCO","County":" ","Line_Number_Phone":1,"Phone Number":"7394756936","Credit Limit":1,"Payment Instrument":"!","Related Address Number":1,"Billing Address Type":"X","Business Unit":"Equipment","DOM or EXP":"Domestic Export","Customer Type":"*Blanks","Division":"Equipment","Adjustment Schedule":"*Blanks","State":"California","Customer Price Group":"*Blanks","Country":"United States","Payment Terms":"NET 10"}';
        AIL.JSON_Body__c = '{"Account id": "'+acc.id+'"}';
        AIL.Request_Type__c = 'GET';
        
        
        insert AIL;
        
        
        List< API_Integration_Log__c> apiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                      Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c  limit 1 ];
        
        // Create a mock response for successful callout
        String mockSuccessResponseBody = '{"Address Number":40927071,"Alpha Name":"KANE WILLIAMSONS","Business Unit Code":" 400","Search Type":"C","Sold_Bill_To":40927071,"Division Code":"400","DOM or EXP Code":"DOM","Customer Type Code":"IND","Category Code_15":"WEB","Equipment Customer Type Code":"IND","Address Line 1":"110 SUTTER STREET WEST","Address Line 2":" ","Address Line 3":" ","Address Line 4":" ","Postal Code":"94104","City":"SAN FRANCISCO","County":" ","Line_Number_Phone":1,"Phone Number":"7394756936","Credit Limit":1,"Payment Instrument":"!","Related Address Number":1,"Billing Address Type":"X","Business Unit":"Equipment","DOM or EXP":"Domestic Export","Customer Type":"*Blanks","Division":"Equipment","Adjustment Schedule":"*Blanks","State":"California","Customer Price Group":"*Blanks","Country":"United States","Payment Terms":"NET 10"}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_GetABWhosWhoCustomerInformation';
        
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        
        test.startTest();
        IntegrationLogDataController.processData(AIL.Id);
        test.stopTest();
        
        List< API_Integration_Log__c> updatedApiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                             Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c where status__c= 'Success' limit 1 ];
        System.assertEquals(1, updatedApiLogRecord.size());
        system.assertEquals('Success', updatedApiLogRecord[0].Status__c);
        //system.assertEquals(mockSuccessResponseBody, updatedApiLogRecord[0].Response_Body__c);
        
    }
    
    
    @isTest
    //For CalloutRestAPiRetriveAB else Condition.
    public static void CalloutRestAPiRetriveABElseConditionTest(){
        
        
        API_Integration_Log__c AIL = new API_Integration_Log__c();
        AIL.status__c = 'Failed';
        AIL.Endpoint__c = 'callout:JDE_Integration/ACBM_ORCH_GetABWhosWhoCustomerInformation';
        AIL.Response_Body__c = '{"Animal":"Dog"}';
        AIL.JSON_Body__c = '{"Account id": "0015500001avlQWAAY"}';
        AIL.Request_Type__c = 'GET';
        
        
        insert AIL;
        
        List< API_Integration_Log__c> apiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                      Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c  limit 1 ];
        
        // Create a mock response for Failed callout
        String mockFailedResponseBody = 'Callout Failed';
        String mockFailedEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_GetABWhosWhoCustomerInformation';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockFailedResponseBody, mockFailedEndpoint, 500));
        
        test.startTest();
        IntegrationLogDataController.processData(AIL.Id);
        test.stopTest();
        
        List< API_Integration_Log__c> updatedApiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                             Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c  limit 1 ];
        System.assertEquals(1, updatedApiLogRecord.size());
        system.assertEquals('Failed', updatedApiLogRecord[0].Status__c);
        system.assertEquals(mockFailedResponseBody, updatedApiLogRecord[0].Response_Body__c);
        
    }
    
    
    @isTest
    //For calloutOrderStatus
    public static void calloutOrderStatusTest(){
        
        Account acc = new Account();
        acc.name='Test123';
        insert acc;
        
        Order od1 = new Order();
        od1.AccountId = acc.id;
        od1.EffectiveDate= system.today();
        od1.JDE_Order_Number__c = 366944;
        od1.Status='Draft';
        od1.JDE_Order_Type__c='S5';
        
        insert od1; 
        
        API_Integration_Log__c AIL = new API_Integration_Log__c();
        AIL.status__c = 'Failed';
        AIL.Endpoint__c = 'callout:JDE_Integration/ACBM_ORCH_SendSalesOrderToSF';
        AIL.Response_Body__c = '{"Order Number":"366944","orderStatus":"Open"}';
        AIL.JSON_Body__c = '{"Order Number": "366944","Order Type": "S5" }';
        AIL.Request_Type__c = 'GET';
        
        
        insert AIL;
        
        
        List< API_Integration_Log__c> apiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                      Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c  limit 1 ];
        
        // Create a mock response for successful callout
        String mockSuccessResponseBody = '{"Order Number":"366944","orderStatus":"Open"}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_CheckSalesOrderStatus';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        
        test.startTest();
        IntegrationLogDataController.processData(AIL.Id);
        test.stopTest();
        
        List< API_Integration_Log__c> updatedApiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                             Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c where status__c= 'Success'  limit 1 ];
        
        System.assertEquals(1, updatedApiLogRecord.size());
        system.assertEquals('Success', updatedApiLogRecord[0].Status__c);
        //system.assertEquals(mockSuccessResponseBody, updatedApiLogRecord[0].Response_Body__c);
    }
    
    @isTest
    //For calloutOrderStatus
    public static void calloutOrderStatusTest1(){
        
        Account acc = new Account();
        acc.name='Test123';
        insert acc;
        
        Order od1 = new Order();
        od1.AccountId = acc.id;
        od1.EffectiveDate= system.today();
        od1.JDE_Order_Number__c = 366944;
        od1.Status='Draft';
        od1.JDE_Order_Type__c='S5';
        
        insert od1; 
        
        API_Integration_Log__c AIL = new API_Integration_Log__c();
        AIL.status__c = 'Failed';
        AIL.Endpoint__c = 'callout:JDE_Integration/ACBM_ORCH_SendSalesOrderToSF';
        AIL.Response_Body__c = '{"Order Number":"366944","orderStatus":"Cancelled"}';
        AIL.JSON_Body__c = '{"Order Number": "366944","Order Type": "S5" }';
        AIL.Request_Type__c = 'GET';
        
        
        insert AIL;
        
        
        List< API_Integration_Log__c> apiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                      Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c  limit 1 ];
        
        // Create a mock response for successful callout
        String mockSuccessResponseBody = '{"Order Number":"366944","orderStatus":"Cancelled"}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_CheckSalesOrderStatus';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        
        test.startTest();
        IntegrationLogDataController.processData(AIL.Id);
        test.stopTest();
        
        List< API_Integration_Log__c> updatedApiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                             Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c where status__c= 'Success'  limit 1 ];
        
        System.assertEquals(1, updatedApiLogRecord.size());
        system.assertEquals('Success', updatedApiLogRecord[0].Status__c);
        //system.assertEquals(mockSuccessResponseBody, updatedApiLogRecord[0].Response_Body__c);
    }
    
    @isTest
    //For calloutOrderStatus
    public static void calloutOrderStatusTest2(){
        
        Account acc = new Account();
        acc.name='Test123';
        insert acc;
        
        Order od1 = new Order();
        od1.AccountId = acc.id;
        od1.EffectiveDate= system.today();
        od1.JDE_Order_Number__c = 366944;
        od1.Status='Draft';
        od1.JDE_Order_Type__c='S5';
        
        insert od1; 
        
        API_Integration_Log__c AIL = new API_Integration_Log__c();
        AIL.status__c = 'Failed';
        AIL.Endpoint__c = 'callout:JDE_Integration/ACBM_ORCH_SendSalesOrderToSF';
        AIL.Response_Body__c = '{"Order Number":"366944","orderStatus":"Shipped"}';
        AIL.JSON_Body__c = '{"Order Number": "366944","Order Type": "S5" }';
        AIL.Request_Type__c = 'GET';
        
        
        insert AIL;
        
        
        List< API_Integration_Log__c> apiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                      Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c  limit 1 ];
        
        // Create a mock response for successful callout
        String mockSuccessResponseBody = '{"Order Number":"366944","orderStatus":"Shipped"}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_CheckSalesOrderStatus';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        
        test.startTest();
        IntegrationLogDataController.processData(AIL.Id);
        test.stopTest();
        
        List< API_Integration_Log__c> updatedApiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                             Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c where status__c= 'Success'  limit 1 ];
        
        System.assertEquals(1, updatedApiLogRecord.size());
        system.assertEquals('Success', updatedApiLogRecord[0].Status__c);
        //system.assertEquals(mockSuccessResponseBody, updatedApiLogRecord[0].Response_Body__c);
    }
    
    
    @isTest
    //For calloutOrderStatus else condition
    public static void calloutOrderStatusElseConditionTest(){
        
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
        API_Integration_Log__c AIL = new API_Integration_Log__c();
        AIL.status__c = 'Failed';
        AIL.Endpoint__c = 'callout:JDE_Integration/ACBM_ORCH_SendSalesOrderToSF';
        AIL.Response_Body__c = '{"Order Number":"00000129","orderStatus":"Cancelled"}';
        AIL.JSON_Body__c = '{"Order Number": "8374656","Order Type": "S5" }';
        AIL.Request_Type__c = 'GET';
        
        
        insert AIL;
             
        List< API_Integration_Log__c> apiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                      Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c  limit 1 ];
        
        // Create a mock response for Failed callout
        String mockFailedResponseBody = 'Callout Failed';
        String mockFailedEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_CheckSalesOrderStatus';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockFailedResponseBody, mockFailedEndpoint, 500));
        
        test.startTest();
        IntegrationLogDataController.processData(AIL.Id);
        test.stopTest();
        
        List< API_Integration_Log__c> updatedApiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                             Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c  limit 1 ];
        
        System.assertEquals(1, updatedApiLogRecord.size());
        system.assertEquals('Failed', updatedApiLogRecord[0].Status__c);
        system.assertEquals(mockFailedResponseBody, updatedApiLogRecord[0].Response_Body__c);
    }
    
    
    
    @isTest
    //For CalloutToRestInsertAccountContact
    public static void CalloutToRestInsertAccountContactTest(){
        
        
        API_Integration_Log__c AIL = new API_Integration_Log__c();
        AIL.status__c = 'Failed';
        AIL.Endpoint__c = 'callout:JDE_Integration/ACBM_ORCH_AddAB';
        AIL.Response_Body__c = '{"Address Number":40924726}';
        AIL.JSON_Body__c = '{"Order Number": "00000129","Order Type": "null" }';
        AIL.Request_Type__c = 'GET';
        
        
        insert AIL;
        
        
        List< API_Integration_Log__c> apiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                      Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c  limit 1 ];
        
        // Create a mock response for successful callout
        String mockSuccessResponseBody= '{"Address Number":40924726}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_AddAB';
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        
        test.startTest();
        IntegrationLogDataController.processData(AIL.Id);
        test.stopTest();
        
        List< API_Integration_Log__c> updatedApiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                             Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c where status__c= 'Success'  limit 1 ];
        
        System.assertEquals(1, updatedApiLogRecord.size());
        system.assertEquals('Success', updatedApiLogRecord[0].Status__c);
        system.assertEquals(mockSuccessResponseBody, updatedApiLogRecord[0].Response_Body__c);
        
    }
    
    
    @isTest
    //For CalloutToRestInsertAccountContact for else condition.
    public static void CalloutToRestInsertAccountContactElseConditionTest(){
             
        API_Integration_Log__c AIL = new API_Integration_Log__c();
        AIL.status__c = 'Failed';
        AIL.Endpoint__c = 'callout:JDE_Integration/ACBM_ORCH_AddAB';
        AIL.Response_Body__c = '{"Address Number":40924726}';
        AIL.JSON_Body__c = '{"Order Number": "00000129","Order Type": "null" }';
        AIL.Request_Type__c = 'GET';
        
        
        insert AIL;
         
        List< API_Integration_Log__c> apiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                      Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c  limit 1 ];
        
        // Create a mock response for Failed callout
        String mockFailedResponseBody= 'Callout Failed';
        String mockFailedEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_AddAB';
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockFailedResponseBody, mockFailedEndpoint, 500));
        
        
        
        test.startTest();
        IntegrationLogDataController.processData(AIL.Id);
        test.stopTest();
        
        List< API_Integration_Log__c> updatedApiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                             Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c where status__c= 'Failed'  limit 1 ];
        
        System.assertEquals(1, updatedApiLogRecord.size());
        system.assertEquals('Failed', updatedApiLogRecord[0].Status__c);
        system.assertEquals(mockFailedResponseBody, updatedApiLogRecord[0].Response_Body__c);
        
    }
    
    
    @isTest
    //For CalloutToOrderItemInsert
    public static void CalloutToOrderItemInsertTest(){
        
        Account acc= new account();
        acc.Name='Test';
        insert acc;
        
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
        
        update oi1;
        
        API_Integration_Log__c AIL = new API_Integration_Log__c();
        AIL.status__c = 'Failed';
        AIL.Endpoint__c = 'callout:JDE_Integration/ACBM_ORCH_AddSalesOrder';
        AIL.Response_Body__c = '{"OrderNumber": 366788}';
        AIL.JSON_Body__c = '{"SalesForce Order Number": "00000129","Order Type": "null" }';
        AIL.Request_Type__c = 'GET';
        
        
        insert AIL;
        
        
        List< API_Integration_Log__c> apiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                      Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c  limit 1 ];
        
        // Create a mock response for successful callout
        String mockSuccessResponseBody= '{"Order Number":366788}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_AddAB';
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        
        test.startTest();
        IntegrationLogDataController.processData(AIL.Id);
        test.stopTest();
        
        List< API_Integration_Log__c> updatedApiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                             Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c where status__c= 'Success'  limit 1 ];
        
        System.assertEquals(1, updatedApiLogRecord.size());
        system.assertEquals('Success', updatedApiLogRecord[0].Status__c);
        system.assertEquals(mockSuccessResponseBody, updatedApiLogRecord[0].Response_Body__c);
        
    }
    
    
    @isTest
    //For CalloutToOrderItemInsert for else condition.
    public static void CalloutToOrderItemInsertElseConditionTest(){
        
        Account acc= new account();
        acc.Name='Test';
        insert acc;
        
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
        
        update oi1;
        
        API_Integration_Log__c AIL = new API_Integration_Log__c();
        AIL.status__c = 'Failed';
        AIL.Endpoint__c = 'callout:JDE_Integration/ACBM_ORCH_AddSalesOrder';
        AIL.Response_Body__c = '{"OrderNumber": 366788}';
        AIL.JSON_Body__c = '{"Order Number": "00000129","Order Type": "null" }';
        AIL.Request_Type__c = 'GET';
        
        
        insert AIL;
        
        
        List< API_Integration_Log__c> apiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                      Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c  limit 1 ];
        
        // Create a mock response for Failed callout
        String mockFailedResponseBody= 'Callout Failed';
        String mockFailedEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_AddAB';
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockFailedResponseBody, mockFailedEndpoint, 500));
        
        
        test.startTest();
        IntegrationLogDataController.processData(AIL.Id);
        test.stopTest();
        
        List< API_Integration_Log__c> updatedApiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                             Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c where status__c= 'Failed'  limit 1 ];
        
        System.assertEquals(1, updatedApiLogRecord.size());
        system.assertEquals('Failed', updatedApiLogRecord[0].Status__c);
        system.assertEquals(mockFailedResponseBody, updatedApiLogRecord[0].Response_Body__c);
        
    }
    
    @isTest
    //For UpdateOrderItem
    public static void UpdateOrderItemTest(){
        
        
        API_Integration_Log__c AIL = new API_Integration_Log__c();
        AIL.status__c = 'Failed';
        AIL.Endpoint__c = 'callout:JDE_Integration/ACBM_ORCH_UpdateSalesOrder';
        AIL.Response_Body__c = '{"Address Number":40924726}';
        AIL.JSON_Body__c = '{"Order Number": "00000129","Order Type": "null" }';
        AIL.Request_Type__c = 'GET';
             
        insert AIL;
        
        List< API_Integration_Log__c> apiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                      Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c  limit 1 ];
        
        // Create a mock response for successful callout
        String mockSuccessResponseBody= '{"Address Number":40924726}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_AddAB';
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        
        test.startTest();
        IntegrationLogDataController.processData(AIL.Id);
        test.stopTest();
        
        List< API_Integration_Log__c> updatedApiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                             Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c where status__c= 'Success'  limit 1 ];
        
        System.assertEquals(1, updatedApiLogRecord.size());
        system.assertEquals('Success', updatedApiLogRecord[0].Status__c);
        system.assertEquals(mockSuccessResponseBody, updatedApiLogRecord[0].Response_Body__c);    
    }
    
    
    @isTest
    //For UpdateOrderItem for else condition.
    public static void UpdateOrderItemElseConditionTest(){
               
        API_Integration_Log__c AIL = new API_Integration_Log__c();
        AIL.status__c = 'Failed';
        AIL.Endpoint__c = 'callout:JDE_Integration/ACBM_ORCH_UpdateSalesOrder';
        AIL.Response_Body__c = '{"Address Number":40924726}';
        AIL.JSON_Body__c = '{"Order Number": "00000129","Order Type": "null" }';
        AIL.Request_Type__c = 'GET';
               
        insert AIL;
              
        List< API_Integration_Log__c> apiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                      Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c  limit 1 ];
        
        // Create a mock response for Failed callout
        String mockFailedResponseBody= 'Callout Failed';
        String mockFailedEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_AddAB';
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockFailedResponseBody, mockFailedEndpoint, 500));
        
     
        test.startTest();
        IntegrationLogDataController.processData(AIL.Id);
        test.stopTest();
        
        List< API_Integration_Log__c> updatedApiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                             Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c where status__c= 'Failed'  limit 1 ];
        
        System.assertEquals(1, updatedApiLogRecord.size());
        system.assertEquals('Failed', updatedApiLogRecord[0].Status__c);
        system.assertEquals(mockFailedResponseBody, updatedApiLogRecord[0].Response_Body__c);
        
    }
    
    @isTest
    //For UpdateOrderItem
    public static void sendCreditCardTest(){
        
        
        API_Integration_Log__c AIL = new API_Integration_Log__c();
        AIL.status__c = 'Failed';
        AIL.Endpoint__c = 'callout:JDE_Integration/ACBM_ORCH_autoCreateCCPrepaymentRecord';
        AIL.Response_Body__c = '{"Address Number":40924726}';
        AIL.JSON_Body__c = '{"Order Number": "00000129","Order Type": "null" }';
        AIL.Request_Type__c = 'GET';
             
        insert AIL;
        
        List< API_Integration_Log__c> apiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                      Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c  limit 1 ];
        
        // Create a mock response for successful callout
        String mockSuccessResponseBody= '{"Address Number":40924726}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_AddAB';
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        
        test.startTest();
        IntegrationLogDataController.processData(AIL.Id);
        test.stopTest();
        
        List< API_Integration_Log__c> updatedApiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                             Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c where status__c= 'Success'  limit 1 ];
        
        System.assertEquals(1, updatedApiLogRecord.size());
        system.assertEquals('Success', updatedApiLogRecord[0].Status__c);
        system.assertEquals(mockSuccessResponseBody, updatedApiLogRecord[0].Response_Body__c);    
    }
    
    
    @isTest
    //For UpdateOrderItem for else condition.
    public static void sendCreditCardElseConditionTest(){
               
        API_Integration_Log__c AIL = new API_Integration_Log__c();
        AIL.status__c = 'Failed';
        AIL.Endpoint__c = 'callout:JDE_Integration/ACBM_ORCH_autoCreateCCPrepaymentRecord';
        AIL.Response_Body__c = '{"Address Number":40924726}';
        AIL.JSON_Body__c = '{"Order Number": "00000129","Order Type": "null" }';
        AIL.Request_Type__c = 'GET';
               
        insert AIL;
              
        List< API_Integration_Log__c> apiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                      Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c  limit 1 ];
        
        // Create a mock response for Failed callout
        String mockFailedResponseBody= 'Callout Failed';
        String mockFailedEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_AddAB';
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockFailedResponseBody, mockFailedEndpoint, 500));
        
     
        test.startTest();
        IntegrationLogDataController.processData(AIL.Id);
        test.stopTest();
        
        List< API_Integration_Log__c> updatedApiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                             Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c where status__c= 'Failed'  limit 1 ];
        
        System.assertEquals(1, updatedApiLogRecord.size());
        system.assertEquals('Failed', updatedApiLogRecord[0].Status__c);
        system.assertEquals(mockFailedResponseBody, updatedApiLogRecord[0].Response_Body__c);
        
    }
   
}