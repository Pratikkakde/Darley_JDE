@isTest
public class OpportunityTriggerTest{
    public static testmethod void OpportunityTriggerMethod(){
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.AccountId = acc.id;
        opp.CloseDate = system.today();
        opp.StageName = 'Customer Contact';
        
        Test.startTest();
            insert opp;
            opp.stageName = 'Awarded Won';
            update opp;
        Test.stopTest();
    }
}