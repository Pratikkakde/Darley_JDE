@istest
public class Test_Batch_on_opportunity_and_forecast {
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
        opp.RecordTypeId = RecType[0].id;
        opp.CloseDate = system.today().addDays(-365);
        opp.Amount=2000;
        insert opp;
        Test.startTest();
        Batch_on_opportunity_and_forecast ocr2 =new Batch_on_opportunity_and_forecast();
        Database.executeBatch(ocr2);
        test.stopTest();
    }  
    
}