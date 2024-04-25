@isTest
public class CalloutToRestInsertUpdateAccountTest {
    @isTest
    //This test method tests Account Insert/Update.
    public static void handleAfterInsertTest(){
        Account acc = new Account();
        acc.Name = 'Andy';
        acc.Primary_Division__c = 'Equipment';
        acc.BillingStreet = '113 North Gessner Road, Rajiv Nagar Near Hanuman Gargh Mandir, Rajiv Chauk Metro station, Kashmiri gate';
        acc.BillingCity = 'Houston';
        acc.BillingState = 'Texas';
        acc.BillingCountry = 'United States';
        acc.BillingPostalCode = '77388';
        acc.Customer_Distribution_Channel__c = 'Domestic Export';
        acc.Cusomer_Type__c = 'Individuals';  
        acc.Primary_POC_Email__c = 'test@test.com';
        acc.Phone = '8976323265';
        acc.Payment_Terms2__c = 'Net 30';
        acc.ShippingStreet = '113 North Gessner Road, Rajiv Nagar Near Hanuman Gargh Mandir, Rajiv Chauk Metro station, Kashmiri gate';
        acc.ShippingCity = 'Houston';
        acc.ShippingState = 'Texas';
        acc.ShippingCountry = 'United States';
        acc.ShippingPostalCode = '77388';
        acc.Adjustment_Schedule__c = 'Darley';
        acc.Credit_Limit__c = 1 ;
        
        
        insert acc;
        
        // Create a mock response for successful callout
        String mockSuccessResponseBody= '{"Address Number":40924726}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_AddAB';
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        
        test.startTest();
        
        test.stopTest();
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Success' Limit 1];
        System.assertEquals(1, integrationLogs.size());
        System.assertEquals('Success', integrationLogs[0].Status__c);
    }
    
    @isTest
    public static void handleAfterInsertFailedTest(){
        
        
        Account acc = new Account();
        acc.Name = 'Andreew';
        acc.Primary_Division__c = 'Equipment';
        acc.BillingStreet = '115 North Gessner Road, Rajiv Nagar Near Hanuman Gargh Mandir, Rajiv';
        acc.BillingCity = 'Houston';
        acc.BillingState = 'Texas';
        acc.BillingCountry = 'United States';
        acc.BillingPostalCode = '66388';
        acc.Customer_Distribution_Channel__c = 'Domestic Export';
        acc.Cusomer_Type__c = 'Individuals';  
        acc.Primary_POC_Email__c = 'test@test.com';
        acc.Phone = '9076323265';
        acc.Payment_Terms2__c = 'Net 30';
        acc.ShippingStreet = '115 North Gessner Road, Rajiv Nagar Near Hanuman Gargh Mandir, Rajiv ';
        acc.ShippingCity = 'Houston';
        acc.ShippingState = 'Texas';
        acc.ShippingCountry = 'United States';
        acc.ShippingPostalCode = '77388';
        acc.Adjustment_Schedule__c = 'Darley';
        acc.Credit_Limit__c = 1 ;
        
        insert acc; 
        
        
        
        // Create a mock response for Failed callout
        String mockFailedResponseBody= 'CallOut Failed';
        String mockFailedEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_AddAB';
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockFailedResponseBody, mockFailedEndpoint, 500));
        
        test.startTest();
        
        //CalloutToRestInsertAccountContact.makeCalloutInsert('{"Name":"Ron"}', 'Acount', 'Account Insert');
        test.stopTest();
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Failed' Limit 1];
        System.assertEquals(1, integrationLogs.size());
        System.assertEquals('Failed', integrationLogs[0].Status__c);
    }
    
    @isTest
    //This test method tests Accoun Insert/Update.
    public static void handleAfterUpdateTest(){
        String EdarleyRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('EDarley New Registrant').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Randy';
        acc.Primary_Division__c = 'Equipment';
        acc.BillingStreet = '111 North Gessner Road, Rajiv Nagar Near Hanuman Mandir';
        acc.BillingCity = 'Houston';
        acc.BillingState = 'Texas';
        acc.BillingCountry = 'United States';
        acc.BillingPostalCode = '553881';
        acc.Customer_Distribution_Channel__c = 'Domestic Export';
        acc.Cusomer_Type__c = 'Individuals';  
        acc.Primary_POC_Email__c = 'test@test.com';
        acc.Phone = '9076323265';
        acc.Payment_Terms2__c = 'Net 30';
        acc.ShippingStreet = '111 North Gessner Road, Rajiv Nagar Near Hanuman Mandir';
        acc.ShippingCity = 'Houston';
        acc.ShippingState = 'Texas';
        acc.ShippingCountry = 'United States';
        acc.ShippingPostalCode = '553881';
        acc.Adjustment_Schedule__c = 'Darley';
        acc.Credit_Limit__c = 1 ;
        acc.RecordTypeId = EdarleyRecordType;
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
        
        // Create a mock response for successful callout
        String mockSuccessResponseBody= '{"Address Number":40924726}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_UpdateAB';
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        
        test.startTest();
        
        test.stopTest();
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Success' Limit 1];
        System.assertEquals(1, integrationLogs.size());
        System.assertEquals('Success', integrationLogs[0].Status__c);
    }
    
    @isTest
    //This test method tests Account-Contact Insert/Update.
    public static void handleAfterUpdateFailedTest(){
        string Equipment_Customer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Equipment Customer').getRecordTypeId();
        String EdarleyRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('EDarley New Registrant').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Sofia';
        acc.Primary_Division__c = 'Equipment';
        acc.BillingStreet = '222 North Gessner Road';
        acc.BillingCity = 'Houston';
        acc.BillingState = 'Texas';
        acc.BillingCountry = 'United States';
        acc.BillingPostalCode = '663881';
        acc.Customer_Distribution_Channel__c = 'Domestic Export';
        acc.Cusomer_Type__c = 'Individuals';  
        acc.Primary_POC_Email__c = 'test@test.com';
        acc.Phone = '9076323265';
        acc.Payment_Terms2__c = 'Net 30';
        acc.ShippingStreet = '222 North Gessner Road';
        acc.ShippingCity = 'Houston';
        acc.ShippingState = 'Texas';
        acc.ShippingCountry = 'United States';
        acc.ShippingPostalCode = '663881';
        acc.Adjustment_Schedule__c = 'Darley';
        acc.Credit_Limit__c = 1 ;
        acc.RecordTypeId = EdarleyRecordType;
        
        insert acc;
        
        account acc1 = new account();
        acc1.name = 'Sonika';
        acc1.ShippingPostalCode = '553991';
        acc1.JDE_Address_Number__c = '40930587';
        acc1.RecordTypeId = Equipment_Customer;
        acc1.Id = acc.id;
        
        
        update acc1;
        
        // Create a mock response for Failed callout
        String mockFailedResponseBody= 'CallOut Failed';
        String mockFailedEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_UpdateAB';
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockFailedResponseBody, mockFailedEndpoint, 500));
        
        test.startTest();
        
        //CalloutToRestInsertAccountContact.makeCalloutInsert('{"Name":"Ron"}', 'Acount', 'Account Insert');
        test.stopTest();
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Failed' Limit 1];
        System.assertEquals(1, integrationLogs.size());
        System.assertEquals('Failed', integrationLogs[0].Status__c);
    }
    
    @isTest
    public static void handleBeforeInsertUpdate(){
        string Customer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        string Equipment_Customer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Equipment Customer').getRecordTypeId();
        string Pump_Customer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Pump Customer').getRecordTypeId();
        
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.Name= 'Guest Account';
        acc.JDE_Guest_Account__c = true;
        acc.Primary_Division__c = 'Equipment';
        accList.add(acc);
        
        Account acc1 = new Account();
        acc1.Name= 'Guest Account';
        acc1.JDE_Guest_Account__c = true;
        acc1.Primary_Division__c = 'Defense';
        accList.add(acc1);
        
        Account acc2 = new Account();
        acc2.Name= 'Guest Account';
        acc2.JDE_Guest_Account__c = true;
        acc2.Primary_Division__c = 'Pump';
        accList.add(acc2);
        
        insert accList;
        
        
    }
    
    
}