@istest
public class test_copy_quote {
    @istest
    public static void testmethod1(){ 
        Pricebook2 pb = new Pricebook2(Name = 'Pump Price Book', IsActive = true );
        insert pb;
        Product2 prod = new Product2(Name = 'SLA: Bronze');
        insert prod;
        //
        PricebookEntry pbe=new PricebookEntry(unitprice=0.01,Product2Id=prod.Id, Pricebook2Id=Test.getStandardPricebookId(), IsActive= true); 
        insert pbe;
        //
        Account acc = new Account (name='Acme');
        insert acc;
        Contact con =new contact();
        con.LastName='testme';
        insert con;
        
        //
        list< RecordType> RecType = [Select Id From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'Pump'];
        Opportunity opp= new Opportunity ();
        opp.name= 'Testopp';
        Opp.Accountid= acc.id;
        opp.RecordTypeId= RecType[0].id;
        opp.CloseDate= system.today();
        opp.StageName= 'Awarded Won';
        opp.Pricebook2id=Test.getStandardPricebookId();        
        insert opp;
        OpportunityContactRole ocr=new OpportunityContactRole();
        ocr.opportunityid=opp.id;
        ocr.ContactId=con.id;
        insert ocr;
        //
        list< RecordType> RecType1 = [Select Id From RecordType  Where SobjectType = 'Quote' and DeveloperName = 'Pump'];
        Quote q= new Quote ();
        q.Name= 'Testq';
        q.OpportunityId= Opp.id;
        q.RecordTypeId=  RecType1[0].id;
        q.Pricebook2Id= Test.getStandardPricebookId();
        q.Status='Draft';        
        insert q;       
        QuoteLineItem qli= new QuoteLineItem(Quoteid=q.id, PricebookEntryid= pbe.Id,  quantity=2, unitprice=10000);
        insert qli;
        
        test.startTest();        
        Quote_Copy.copyquote(q.id,opp.id,'name');
        Quote_Copy.selectquote(q.id); 
        Quote_Copy.inactiveProductCheck(q.id);
        test.stoptest();
        
        
    }
    
    
}