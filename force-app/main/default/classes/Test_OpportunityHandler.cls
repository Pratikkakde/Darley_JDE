@istest
public class Test_OpportunityHandler {
    
    
    @istest
    public static void testMethod2(){
        
       Account acc=new account();
        acc.Name='test'; 
        insert acc;     
        
        list<opportunity> opplist1= new list<opportunity>();
        list< RecordType> RecType = [Select Id  From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'Pump'];
        Opportunity opp=new opportunity();
        opp.Name='test1';
        opp.AccountId=acc.Id;
        opp.StageName='Closed/Won';
        opp.RecordTypeId=RecType[0].id;
        opp.CloseDate=system.today();
        opp.Amount=2000;
        insert opp;
        opp.StageName='Closed/Won'; 
        update opp;
        list<opportunity> opplist=[select id from opportunity where name like 'test1' ];
        delete opplist;
        
        Forecast__c ft=new Forecast__c();
        ft.Account__c=acc.Id;
        ft.Year__c='2022';
        ft.Forecast_Amount__c=40000;        
        insert ft;
        ft.Year__c='2023';
        update ft;
        
        Test.startTest();
        TriggerOnOpportunityHandler.afterInsert(opplist1);
        test.stopTest();
    }  
    
}