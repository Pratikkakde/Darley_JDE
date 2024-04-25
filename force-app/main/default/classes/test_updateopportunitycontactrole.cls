@istest
public class test_updateopportunitycontactrole {
    @istest
    public static void testmethod6(){
        Account acc=new account();
        acc.name='test';
        insert acc;
        system.debug('acc');
        contact con=new contact();
        con.lastname='symond';
        insert con;
        opportunity opp=new opportunity();
        opp.name='test';
        opp.AccountId=acc.id;
        opp.CloseDate=system.today();
        opp.StageName='Awarded Won';
        insert opp;
        
        list< RecordType> RecType = [Select Id From RecordType  Where SobjectType = 'Quote' and DeveloperName = 'Pump'];
        quote qu=new quote();
        qu.name='test';
        qu.RecordTypeId=RecType[0].id;
        qu.OpportunityId=opp.id;
     
        qu.ContactId=con.id;
        insert qu;
        test.startTest();
        updateopportunitycontactrole ocr2 =new updateopportunitycontactrole();
        Database.executeBatch(ocr2);
        test.stopTest();
        
    }
    
}