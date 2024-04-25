@istest
public class Subscription_Handler_test {
    
    @istest
    public static void testmethod2()
    {
        Account acc=new account();
        acc.Name='test'; 
        insert acc;   
        
        contact con = new contact();
        con.LastName='melonleaf';
        con.Primary__c= true;
        con.AccountId= acc.Id;
        insert con;
        
        list<Subscription__c>subslist=new  list<Subscription__c>();
        Subscription__c subs = new Subscription__c();
        subs.Name= 'melon';
        subs.Invoice_sent__c= true;
        subs.Overwrite_Payment_Reminder_Date__c=false;
        subs.Invoice_Paid__c=false;
        subs.Subscription_contracts_start_date__c= Date.today();
        subs.Subscription_contracts_end_date__c=Date.today()+30;
        subs.Account__c= acc.id;
        insert subs;
        subslist.add(subs);
        
        Subscription__c subsupdate = new Subscription__c();
        subsupdate.Id=subs.id;
        subsupdate.Subscription_contracts_start_date__c= Date.today()-5;
        subsupdate.Invoice_Paid__c= true;
        update subsupdate;
          
       
        test.startTest();
   
       Subscription_Handler.updateDate(subslist);
 
        test.stopTest();
        
    }
    
}