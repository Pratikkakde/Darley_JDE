@isTest
public class CalloutToRestProductRetrieveTest {
    @isTest
    public static void testMakeCallout() {
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
        
        system.debug('priceBookEntries = '+priceBookEntries);
        system.debug('priceBookEntries Size = '+priceBookEntries.size());
        
        // Create a mock response for successful callout
        String mockSuccessResponseBody = '{"Stocking Type":"Phantom","ACBM_ORCH_SendItemInformationToSF":{"Second Item Number":"AF032","Third Item Number":"C-2","Cat Code 8":"WEB","Cost Meth":"22","Unit Cost":400,"Stocking Type":"Phantom","Unit Price":603,"markupDISTI":"1.28","markupDISTII":"1.25","markupDISTIII":"1.23","markupDISTIV":"1.20","markupDISTV":"1.18","markupDISTVI":"1.15","baseDISTI":"771.84","baseDISTII":"753.75","baseDISTIII":"741.69","baseDISTIV":"723.6","baseDISTV":"711.54","baseDISTVI":"693.45","Available":-38,"On Hand":0,"Committed":38,"Backorder":38}}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_GetItem';
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        
        // Make the successful callout
        Test.startTest();
        CalloutToRestProductRetrieve.makeCallout(p.Id);
        Test.stopTest();
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Success' Limit 1 ];
        System.assertEquals(1, integrationLogs.size());
        System.assertEquals('Success', integrationLogs[0].Status__c);
        
    }
    
    @isTest
    Public static void testMakeCallout2(){
        // Create a test record
        
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
        
        pbeList.add(new PricebookEntry(Product2Id = p.Id, Pricebook2Id = pricebookId, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = p.Id, Pricebook2Id = pricebookList[0].Id, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = p.Id, Pricebook2Id = pricebookList[1].Id, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = p.Id, Pricebook2Id = pricebookList[2].Id, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = p.Id, Pricebook2Id = pricebookList[3].Id, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = p.Id, Pricebook2Id = pricebookList[4].Id, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = p.Id, Pricebook2Id = pricebookList[5].Id, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = p.Id, Pricebook2Id = pricebookList[6].Id, UnitPrice = 600, IsActive = true));
        
        
        insert pbeList;
        system.debug('Pbe list'+pbeList);
        
        List<PricebookEntry> priceBookEntries = [SELECT Pricebook2Id, Pricebook2.Name, Pricebook2.isActive, ProductCode, UnitPrice, product2Id,product2.JDE_Part_Number__c, IsActive FROM PricebookEntry  where product2.JDE_Part_Number__c = 'AF032'];
        
        system.debug('priceBookEntries = '+priceBookEntries);
        
        // Create a mock response for failed callout
        String mockFailedResponseBody = 'Callout failed';
        String mockFailedEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_GetItem';
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockFailedResponseBody, mockFailedEndpoint, 500));
        
        // Make the failed callout
        Test.startTest();
        CalloutToRestProductRetrieve.makeCallout(p.Id);
        Test.stopTest();
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Failed' Limit 1];
        System.assertEquals(1, integrationLogs.size());
        System.assertEquals('Failed', integrationLogs[0].Status__c);
    }
    
    @isTest
    public static void testMakeCallout3() {
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
        
        system.debug('priceBookEntries = '+priceBookEntries);
        system.debug('priceBookEntries Size = '+priceBookEntries.size());
        
        // Create a mock response for successful callout
        String mockSuccessResponseBody = '{"Stocking Type":"Obsolete - Use Up","ACBM_ORCH_SendItemInformationToSF":{"Second Item Number":"AF032","Third Item Number":"C-2","Cat Code 8":"WEB","Cost Meth":"22","Unit Cost":400,"Stocking Type":"Obsolete - Use Up","Unit Price":603,"markupDISTI":"1.28","markupDISTII":"1.25","markupDISTIII":"1.23","markupDISTIV":"1.20","markupDISTV":"1.18","markupDISTVI":"1.15","baseDISTI":"771.84","baseDISTII":"753.75","baseDISTIII":"741.69","baseDISTIV":"723.6","baseDISTV":"711.54","baseDISTVI":"693.45","Available":-38,"On Hand":0,"Committed":38,"Backorder":38}}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_GetItem';
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        
        // Make the successful callout
        Test.startTest();
        CalloutToRestProductRetrieve.makeCallout(p.Id);
        Test.stopTest();
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Success' Limit 1 ];
        System.assertEquals(1, integrationLogs.size());
        System.assertEquals('Success', integrationLogs[0].Status__c);
        
    }
    
    @isTest
    public static void testMakeCallout4() {
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
        
        system.debug('priceBookEntries = '+priceBookEntries);
        system.debug('priceBookEntries Size = '+priceBookEntries.size());
        
        // Create a mock response for successful callout
        String mockSuccessResponseBody = '{"Stocking Type":"Obsolete","ACBM_ORCH_SendItemInformationToSF":{"Second Item Number":"AF032","Third Item Number":"C-2","Cat Code 8":"WEB","Cost Meth":"22","Unit Cost":400,"Stocking Type":"Obsolete","Unit Price":603,"markupDISTI":"1.28","markupDISTII":"1.25","markupDISTIII":"1.23","markupDISTIV":"1.20","markupDISTV":"1.18","markupDISTVI":"1.15","baseDISTI":"771.84","baseDISTII":"753.75","baseDISTIII":"741.69","baseDISTIV":"723.6","baseDISTV":"711.54","baseDISTVI":"693.45","Available":-38,"On Hand":0,"Committed":38,"Backorder":38}}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_GetItem';
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        
        // Make the successful callout
        Test.startTest();
        CalloutToRestProductRetrieve.makeCallout(p.Id);
        Test.stopTest();
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Success' Limit 1 ];
        System.assertEquals(1, integrationLogs.size());
        System.assertEquals('Success', integrationLogs[0].Status__c);
        
    }
    
}