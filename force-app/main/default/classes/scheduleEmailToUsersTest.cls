/*
 * Name - scheduleEmailToUsers
 * Author - Melonleaf Consulting
 * Created Date - 25/08/2022
 * Purpose - Test class of Batch for Sending Emails.
 * -----------Change Log---------
 * Last Modified by - Niketan Singh
 * Last Modified Date -8/11/2022
 */

@isTest
public class scheduleEmailToUsersTest {
    
    public static Id pumpCustomerRecordTypeId = schema.SObjectType.Account.getRecordTypeInfosByName().get('Pump Customer').getRecordTypeId();
    
    @isTest
    public static  void Subtest() 
    {
        Account acc = new Account();
        acc.Name = 'Test'; 
        acc.RecordTypeId = pumpCustomerRecordTypeId;
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'aic';
        con.AccountId = acc.Id;
        con.Email = 'Deepshi8@gmail.com';
        con.FirstName = 'Deepshi';
        con.Primary__c = true;
        insert con ; 
         
        Subscription__c subs = new Subscription__c();
        subs.Name = 'abc';
        subs.Subscription_contracts_start_date__c =System.today();
        subs.Status__c = 'Active-New';
        subs.Account__c = acc.Id;
        subs.Subscription_contracts_end_date__c = Date.newInstance(2022, 11, 23);
       //subs.CX_Survey_Complete__c = true;
       //subs.Customer_Email__c = 'Deepshi8@gmail.com';
        subs.Invoice_Paid__c = false;
        subs.Payment_Reminder_Date_1__c = Date.newInstance(2022, 11, 22);
      //  subs.Contact_First_Name__c = 'Deepshi';
        subs.Subscription_Type__c = 'FLAIM';
        subs.Invoice_sent__c = true;
        insert subs;
        
       
       

        
        
        
        scheduleEmailToUsers scheduleEmail = new scheduleEmailToUsers();
        Database.executebatch(scheduleEmail);
        }
    
    //after 4 weeks
    @isTest
    public static  void Subtest2() 
    {
        Account acc = new Account();
        acc.Name = 'Test'; 
        acc.RecordTypeId = pumpCustomerRecordTypeId;
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'aic';
        con.AccountId = acc.Id;
        con.Email = 'Deepshi8@gmail.com';
        con.FirstName = 'Deepshi';
        con.Primary__c = true;
        insert con ; 
         
        Subscription__c subs = new Subscription__c();
        subs.Name = 'abc';
        subs.Subscription_contracts_start_date__c =System.today()-28;
        subs.Status__c = 'Active-New';
        subs.Account__c = acc.Id;
        subs.Subscription_contracts_end_date__c = Date.newInstance(2022, 11, 23);
       //subs.CX_Survey_Complete__c = true;
       //subs.Customer_Email__c = 'Deepshi8@gmail.com';
        subs.Invoice_Paid__c = false;
        subs.Payment_Reminder_Date_1__c = Date.newInstance(2022, 11, 22);
      //  subs.Contact_First_Name__c = 'Deepshi';
        subs.Subscription_Type__c = 'FLAIM';
        subs.Invoice_sent__c = true;
        insert subs;
        
       
       

        
        
        
        scheduleEmailToUsers scheduleEmail = new scheduleEmailToUsers();
        Database.executebatch(scheduleEmail);
        }
    
    //3 months
     @isTest
    public static  void Subtest3()
    {
        Date myDate = System.today(); //date.newInstance(2022, 11, 22);
        Date newDate = myDate.addmonths(-3);
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId = pumpCustomerRecordTypeId;
        insert acc;
        
        
        Contact con = new Contact();
        con.LastName = 'aic';
        con.AccountId = acc.Id;
        con.Email = 'Deepshi8@gmail.com';
        con.FirstName = 'Deepshi';
        con.Primary__c = true;
        insert con ; 
        
       Subscription__c subs = new Subscription__c();
        subs.Name = 'abc';
        subs.Subscription_contracts_start_date__c =newDate;
        subs.Status__c = 'Active-New';
        subs.Account__c = acc.Id;
        subs.Subscription_contracts_end_date__c = Date.newInstance(2022, 11, 23);
       //subs.CX_Survey_Complete__c = true;
       //subs.Customer_Email__c = 'Deepshi8@gmail.com';
        subs.Invoice_Paid__c = false;
        subs.Payment_Reminder_Date_1__c = Date.newInstance(2022, 11, 22);
      //  subs.Contact_First_Name__c = 'Deepshi';
        subs.Subscription_Type__c = 'FLAIM';
        subs.Invoice_sent__c = true;
        insert subs;
        
        scheduleEmailToUsers scheduleEmail = new scheduleEmailToUsers();
        Database.executebatch(scheduleEmail);
    }
    //6 Months
     @isTest
    public static  void Subtest4()
    {
        Date myDate = System.today(); //date.newInstance(2022, 11, 22);
        Date newDate = myDate.addmonths(-6);
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId = pumpCustomerRecordTypeId;
        insert acc;
        
        
       Contact con = new Contact();
        con.LastName = 'aic';
        con.AccountId = acc.Id;
        con.Email = 'Deepshi8@gmail.com';
        con.FirstName = 'Deepshi';
        con.Primary__c = true;
        insert con ; 

        
       Subscription__c subs = new Subscription__c();
        subs.Name = 'abc';
        subs.Subscription_contracts_start_date__c =newDate;
        subs.Status__c = 'Active-New';
        subs.Account__c = acc.Id;
        subs.Subscription_contracts_end_date__c = Date.newInstance(2022, 11, 23);
       //subs.CX_Survey_Complete__c = true;
       //subs.Customer_Email__c = 'Deepshi8@gmail.com';
        subs.Invoice_Paid__c = false;
        subs.Payment_Reminder_Date_1__c = Date.newInstance(2022, 11, 22);
      //  subs.Contact_First_Name__c = 'Deepshi';
        subs.Subscription_Type__c = 'FLAIM';
        subs.Invoice_sent__c = true;
        insert subs;
        
        
        scheduleEmailToUsers scheduleEmail = new scheduleEmailToUsers();
        Database.executebatch(scheduleEmail);
    }
    
    //9 Months
     @isTest
    public static  void Subtest5()
    {
        Date myDate = System.today(); //date.newInstance(2022, 11, 22);
        Date newDate = myDate.addmonths(-9);
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId = pumpCustomerRecordTypeId;
        insert acc;
        
        
        Contact con = new Contact();
        con.LastName = 'aic';
        con.AccountId = acc.Id;
        con.Email = 'Deepshi8@gmail.com';
        con.FirstName = 'Deepshi';
        con.Primary__c = true;
        insert con ; 
        
        
        Subscription__c subs = new Subscription__c();
        subs.Name = 'abc';
        subs.Subscription_contracts_start_date__c =newDate;
        subs.Status__c = 'Active-New';
        subs.Account__c = acc.Id;
        subs.Subscription_contracts_end_date__c = Date.newInstance(2022, 11, 23);
       //subs.CX_Survey_Complete__c = true;
       //subs.Customer_Email__c = 'Deepshi8@gmail.com';
        subs.Invoice_Paid__c = false;
        subs.Payment_Reminder_Date_1__c = Date.newInstance(2022, 11, 22);
      //  subs.Contact_First_Name__c = 'Deepshi';
        subs.Subscription_Type__c = 'FLAIM';
        subs.Invoice_sent__c = true;
        //insert subs;
        Database.insert(subs, false);
        
        scheduleEmailToUsers scheduleEmail = new scheduleEmailToUsers();
        Database.executebatch(scheduleEmail);
    }
    
    //elseif cx survey
     @isTest
    public static  void Subtest6()
    {
         Account acc = new Account();
        acc.Name = 'Test'; 
        acc.RecordTypeId = pumpCustomerRecordTypeId;
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'aic';
        con.AccountId = acc.Id;
        con.Email = 'Deepshi8@gmail.com';
        con.FirstName = 'Deepshi';
        con.Primary__c = true;
        insert con ; 
         
        Subscription__c subs = new Subscription__c();
        subs.Name = 'abc';
        subs.Subscription_contracts_start_date__c =System.today();
        subs.Status__c = 'Active-New';
        subs.Account__c = acc.Id;
        subs.Subscription_contracts_end_date__c = Date.newInstance(2022, 11, 23);
       subs.CX_Survey_Complete__c = true;
       //subs.Customer_Email__c = 'Deepshi8@gmail.com';
        subs.Invoice_Paid__c = false;
        subs.Payment_Reminder_Date_1__c = Date.newInstance(2022, 11, 22);
        //subs.Payment_Reminder_Date_1__c = Date.today());
        subs.Contact_First_Name__c = 'Deepshi';
        subs.Subscription_Type__c = 'FLAIM';
        subs.Invoice_sent__c = true;
        insert subs;
        
       
       

        
        
        
        scheduleEmailToUsers scheduleEmail = new scheduleEmailToUsers();
        Database.executebatch(scheduleEmail);
    }
    /*
        List<Subscription__c> subsList = [SELECT Id , Subscription_contracts_end_date__c , Subscription_contracts_start_date__c FROM Subscription__c WHERE Id =: subs.Id ];
        subs.Subscription_contracts_end_date__c = Date.newInstance(2022, 12, 21);
        update subsList;
        Database.executebatch(scheduleEmail);
      */
     @isTest
    public static  void Subtest7()
    {
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId = pumpCustomerRecordTypeId;
        insert acc;
        
        
        Contact con = new Contact();
        con.LastName = 'aic';
        con.AccountId = acc.Id;
        con.Email = 'Deepshi8@gmail.com';
        con.FirstName = 'Deepshi';
        con.Primary__c = true;
        insert con ; 
        
        
        Subscription__c subs = new Subscription__c();
        subs.Name = 'abc';
        subs.Subscription_contracts_start_date__c =system.today();
        subs.Status__c = 'Active-New';
        subs.Account__c = acc.Id;
        subs.Subscription_contracts_end_date__c = Date.newInstance(2022, 11, 24);
       //subs.CX_Survey_Complete__c = true;
       //subs.Customer_Email__c = 'Deepshi8@gmail.com';
        subs.Invoice_Paid__c = false;
        subs.Payment_Reminder_Date_1__c = Date.newInstance(2022, 11, 22);
      //  subs.Contact_First_Name__c = 'Deepshi';
        subs.Subscription_Type__c = 'FLAIM';
        subs.Invoice_sent__c = true;
        insert subs;
        
        
        scheduleEmailToUsers scheduleEmail = new scheduleEmailToUsers();
        Database.executebatch(scheduleEmail);
    }
      @isTest
    public static  void Expiry(){
    
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId = pumpCustomerRecordTypeId;
        insert acc;
        
        
        Contact con = new Contact();
        con.LastName = 'aic';
        con.AccountId = acc.Id;
        con.Email = 'Deepshi8@gmail.com';
        con.FirstName = 'Deepshi';
        con.Primary__c = true;
        insert con ; 
        
        
        Subscription__c subs = new Subscription__c();
        subs.Name = 'abc';
        subs.Subscription_contracts_start_date__c =Date.newInstance(2021, 11, 22);
        subs.Status__c = 'Active-New';
        subs.Account__c = acc.Id;
        subs.Subscription_contracts_end_date__c = system.today();
       subs.CX_Survey_Complete__c = true;
       subs.Customer_Email__c = 'Deepshi8@gmail.com';
        subs.Invoice_Paid__c = false;
        subs.Payment_Reminder_Date_1__c = Date.newInstance(2022, 11, 22);
        subs.Contact_First_Name__c = 'Deepshi';
        subs.Subscription_Type__c = 'FLAIM';
        subs.Invoice_sent__c = true;
        insert subs;
        
        
   /*     User owner = new User(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'johndoe@test.com',
            Alias = 'johndoe',
            Username = 'johndoe@test.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User'].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert owner;
        */
        
        scheduleEmailToUsers scheduleEmail = new scheduleEmailToUsers();
        Database.executebatch(scheduleEmail);
    }
  
    
    
    @isTest
    public static  void testschedule(){
        Test.StartTest();
        scheduleEmailToUsers schedule1 = new scheduleEmailToUsers();
        String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, schedule1 );
		Test.stopTest();
  }
}