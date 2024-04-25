@isTest
public class ContactTriggerHandlerTest {
    @isTest
    public static void handleAfterInsertTest(){
        
        Account acc = Utility_DataCreation.CreateAccountRec(5,'EDarley New Registrant')[0];
        acc.BillingStreet = '113 North Gessner Road, Rajiv Nagar Near Hanuman Gargh Mandir, Rajiv Chauk Metro station, Kashmiri gate';
        insert acc;
        
        string Customer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        string Equipment_Customer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Equipment Customer').getRecordTypeId();
        string Pump_Customer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Pump Customer').getRecordTypeId();
        
        account acc1 = new account();
        acc1.name = 'orio';
        acc1.ShippingPostalCode = '553991';
        acc1.JDE_Address_Number__c = '40930587';
        acc1.Sync_with_JDE__c = true;
        acc1.RecordTypeId = Equipment_Customer;
        acc1.Id = acc.id;
        
        update acc1;
        
        Contact con = Utility_DataCreation.createCotactAccoCiatedWithAccount(5,acc1.id)[0];
        Insert con;
        
        contact con1 = new contact();
        con1.FirstName = 'Saky';
        con1.Title = 'Fire Fighter';
        con1.MailingPostalCode = '490735';
        con1.Phone = '8456784637';
        con1.Id = con.Id;
        
        update con1;
        
        // Create a mock response for successful callout
        String mockSuccessResponseBody= '{"Address Number":40924726}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_UpdateAB';
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        
        test.startTest();
        
        test.stopTest();
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Success' Limit 1];
        // System.assertEquals(1, integrationLogs.size());
        // System.assertEquals('Success', integrationLogs[0].Status__c);
    }   
    
    @isTest
    public static void handleAfterInsertTest1(){
        
        Account acc = Utility_DataCreation.CreateAccountRec(5,'EDarley New Registrant')[0];
        acc.BillingStreet = '113 North Gessner Road, Rajiv Nagar Near Hanuman Gargh Mandir, Rajiv Chauk Metro station, Kashmiri gate';
        insert acc;
        
        Contact con = Utility_DataCreation.createCotactAccoCiatedWithAccount(5,acc.id)[0];
        Insert con;
        
        contact con1 = new contact();
        con1.FirstName = 'Sandfield';
        con1.Title = 'Fire Fighter';
        con1.MailingPostalCode = '456435';
        con1.Phone = '8456784677';
        con1.Id = con.Id;
        
        update con1;
        // Create a mock response for successful callout
        String mockSuccessResponseBody= '{"Address Number":40924726}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_UpdateAB';
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Success' Limit 1];
       // System.assertEquals(1, integrationLogs.size());
        //System.assertEquals('Success', integrationLogs[0].Status__c);
    }
    
    @isTest
    public static void handleAfterInsertTest2(){
        Account acc = Utility_DataCreation.CreateAccountRec(5,'EDarley New Registrant')[0];
        acc.BillingStreet = '113 North Gessner Road, Rajiv Nagar Near Hanuman Gargh Mandir, Rajiv Chauk Metro station, Kashmiri gate';
        insert acc;
        
        Contact con = Utility_DataCreation.createCotactAccoCiatedWithAccount(5,acc.id)[0];
        Insert con;
        
        contact con1 = new contact();
        con1.FirstName = 'Saifer';
        con1.Title = 'Fire Fighter';
        con1.MailingPostalCode = '506735';
        con1.Id = con.Id;
        
        update con1;
        // Create a mock response for successful callout
        String mockSuccessResponseBody= '{"Address Number":40924726}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_UpdateAB';
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Success' Limit 1];
        //System.assertEquals(1, integrationLogs.size());
        //System.assertEquals('Success', integrationLogs[0].Status__c);
    }
    
    @isTest
    public static void handleAfterInsertTest3(){
        
        Account acc = Utility_DataCreation.CreateAccountRec(5,'EDarley New Registrant')[0];
        acc.BillingStreet = '113 North Gessner Road, Rajiv Nagar Near Hanuman Gargh Mandir, Rajiv Chauk Metro station, Kashmiri gate';
        insert acc;
        
        Contact con = Utility_DataCreation.createCotactAccoCiatedWithAccount(5,acc.id)[0];
        Insert con;
        
        contact con1 = new contact();
        con1.FirstName = 'Sofia';
        con1.Title = 'Fire Fighter';
        con1.MailingPostalCode = '456735';
        con1.Id = con.Id;
        
        update con1;
        // Create a mock response for successful callout
        String mockSuccessResponseBody= '{"Address Number":40924726}';
        String mockSuccessEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_UpdateAB';
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockSuccessResponseBody, mockSuccessEndpoint, 200));
        
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Success' Limit 1];
       // System.assertEquals(1, integrationLogs.size());
       // System.assertEquals('Success', integrationLogs[0].Status__c);
    }
    
    @isTest
    //This test method tests else condition  Failed callout for Account-Contact Insert/Update.
    public static void handleAfterInsertFailedCalloutTest(){
        
       Account acc = Utility_DataCreation.CreateAccountRec(5,'EDarley New Registrant')[0];
        acc.BillingStreet = '113 North Gessner Road, Rajiv Nagar Near Hanuman Gargh Mandir, Rajiv Chauk Metro station, Kashmiri gate';
        insert acc;

        string Equipment_Customer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Equipment Customer').getRecordTypeId();
        
        Account acc1 = new Account();
        acc1.Name = 'Flintof';
        acc1.Id = acc.Id;
        acc1.RecordTypeId = Equipment_Customer;
        acc1.JDE_Address_Number__c = '40930589';
        
        update acc1;
        
        Contact con = Utility_DataCreation.createCotactAccoCiatedWithAccount(5,acc1.id)[0];
        Insert con;
        
        contact con1 = new contact();
        con1.FirstName = 'Sammy';
        con1.Title = 'Fire Fighter';
        con1.MailingPostalCode = '421735';
        con1.Id = con.Id;
        
        update con1;
        
        // Create a mock response for Failed callout
        String mockFailedResponseBody= 'CallOut Failed';
        String mockFailedEndpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_UpdateAB';
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutGenerator(mockFailedResponseBody, mockFailedEndpoint, 500));
        
   
        List<API_Integration_Log__c> integrationLogs = [SELECT Status__c, createdDate FROM API_Integration_Log__c where createdDate = today AND Status__c = 'Failed' Limit 1];
    
    }
    
}