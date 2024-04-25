@isTest
public class Test_Batch_UpdateOpportunityContactRole {
    @isTest
    public static void testmethod6(){
        //Forte: set Test Mock
        Test.setMock(HttpCalloutMock.class, new DefaultTestMock());
        
        Account acc=new account();
        acc.name='test';
        insert acc; 
        
        contact con=new contact();
        con.lastname='symond';

        //Forte: added AccountId
        con.AccountId = acc.Id;

        insert con;
        
       //list<opportunity> opplist=new list <opportunity>();
        opportunity opp=new opportunity();
        opp.name='test';
        opp.AccountId=acc.id;
        opp.CloseDate=system.today();
        opp.StageName='Awarded Won';
        insert opp;
        
        //Forte: create OpportunityContactRole record
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.OpportunityId = opp.Id;
        ocr.ContactId = con.Id;
        insert ocr;
        
        SBQQ__Quote__c q=new SBQQ__Quote__c();
        q.SBQQ__Account__c=acc.id;
        q.SBQQ__Opportunity2__c=opp.id;
        q.SBQQ__PrimaryContact__c=con.id;
        q.Kitting_Picklist__c='yes';
        insert q;
        
        test.startTest();
        Batch_UpdateOpportunityContactRole ocr2 =new Batch_UpdateOpportunityContactRole();
        Database.executeBatch(ocr2);
        test.stopTest();
    }

    //Forte: added CalloutMock class
    public class DefaultTestMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            return new HttpResponse();
        }
    }

}