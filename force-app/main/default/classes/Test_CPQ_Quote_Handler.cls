@istest
public class Test_CPQ_Quote_Handler {
@istest
     public static void testmethod1(){
         Account acc=new Account();
         acc.name='test';
         insert acc;
         
         contact c=new contact();
         c.accountid=acc.id;
         c.lastname='test';
         insert c;
         
         opportunity opp=new opportunity();
          opp.name='test';         
         opp.CloseDate=system.today();
         opp.StageName='Awarded Won';
         opp.AccountId=acc.id;
        // opplist.add(opp);
         insert opp;
         
         OpportunityContactRole role=new OpportunityContactRole();
         role.OpportunityId=opp.id;
         role.ContactId=c.id;
         insert role;
         
         list<SBQQ__Quote__c>qlist=new list <SBQQ__Quote__c>();
       SBQQ__Quote__c q=new SBQQ__Quote__c();
         	q.SBQQ__Account__c=acc.id;
        q.SBQQ__Opportunity2__c=opp.id;
         q.Kitting_Picklist__c='yes';
         qlist.add(q);
         insert qlist;
         
       Test.StartTest();
           CPQ_Quote_Handler.method1(qlist);
         
         test.stopTest();
         
         
         
     }}