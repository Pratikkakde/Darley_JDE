@isTest
public class Test_QuoteLineItem_Handler {
    @isTest   
    
    public static void Mymethod12(){
        account acc=new account();
        acc.Name='test';
        insert acc;
        contact con =new contact();
        con.lastname='tester';
        insert con;
        Product2 pro = new Product2(Name = 'iPhone X', Family = 'Mobile');
        Insert pro;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = pro.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        Insert pbe;
        
        list<opportunity> opplist=new list<opportunity>();
        list< RecordType> RecType1 = [Select Id From RecordType  Where SobjectType = 'opportunity' and DeveloperName = 'Pump'];
        opportunity opp= new opportunity();
        opp.name='test';
        opp.RecordTypeId=RecType1[0].id;
        opp.Pricebook2Id=Test.getStandardPricebookId();         
        opp.CloseDate=system.today();
        opp.StageName='Awarded Won';
        opp.AccountId=acc.id;
        opplist.add(opp);
        insert opplist;
        OpportunityContactRole ocr=new  OpportunityContactRole();
        ocr.opportunityid=opp.id;
        ocr.ContactId=con.Id;
        
        insert ocr;
        list<quote> qulist=new list<quote>();
        map<id,quote> quotemap=new map<id,quote>();
        
        list< RecordType> RecType = [Select Id From RecordType  Where SobjectType = 'Quote' and DeveloperName = 'Pump'];
        quote qu=new quote();
        qu.name='test';
        qu.Pricebook2Id = Test.getStandardPricebookId();
        qu.RecordTypeId=RecType[0].id;
        qu.OpportunityId=opp.id;         
        
        qulist.add(qu);
        insert qulist;
        quotemap.put(qulist[0].Id, qulist[0]);
        
        // list<QuoteLineItem>qlilist=[select id,QuoteId,Quantity,UnitPrice,Cost_22_Total__c from QuoteLineItem];
        list<QuoteLineItem>qlilist=new list<QuoteLineItem>();
        QuoteLineItem QLI  = new QuoteLineItem();
        // QLI.Product2Id = pro.Id;
        QLI.QuoteId = qu.Id;
        QLI.PricebookEntryId = pbe.Id;
        QLI.Quantity = 2;
        QLI.UnitPrice = 150000; 
        // qlilist.add(QLI);
        insert QLI;  
        QLI.Quantity = 5;
        update Qli;
        qlilist.add(QLI);
        
        test.startTest();
       quoteLineItem_Handler.sumOfCost22New(qlilist);
         quoteLineItem_Handler.sumOfCost22Old(qlilist);
      //   quoteLineItem_Handler.sumOfCost22New(qlilist);
        test.stopTest();
    }

}









/* Account acc=new Account();
acc.name='test';
insert acc;

opportunity opp=new opportunity();
opp.name='test1';
opp.AccountId=acc.id;
opp.StageName='Quoted Opportunity';
opp.CloseDate=system.today();
insert opp;

contact con=new contact();
con.lastname='test2';
insert con;

OpportunityContactRole ocr=new OpportunityContactRole();
ocr.opportunityid=opp.id;
ocr.ContactId=con.id;
insert ocr;

list< RecordType> RecType = [Select Id From RecordType  Where SobjectType = 'Quote' and DeveloperName = 'Pump'];
quote qu=new quote();
qu.name='test';
qu.RecordTypeId=RecType[0].id;
qu.OpportunityId=opp.id;
qu.ContactId=con.id;
insert qu;

product2 p=new product2();
p.name='test';
insert p;



PricebookEntry pbe = new PricebookEntry(
Pricebook2Id = Test.getStandardPricebookId(),
Product2Id = p.Id,
UnitPrice = 1020,
IsActive = true
insert pbe;
Pricebook2 standardPricebook = new Pricebook2(
Id = Test.getStandardPricebookId(),
IsActive = true
);
PricebookEntry pbe = new PricebookEntry(
Pricebook2Id = Test.getStandardPricebookId(),
Product2Id = p.Id,
UnitPrice = 1020,
IsActive = true
);
Insert pbe;


list<QuoteLineItem>qlilist=new list<QuoteLineItem>();
QuoteLineItem qli=new QuoteLineItem();

qli.Quantity=2;   
qli.QuoteId=qu.id;
qli.Product2Id=p.id;
qli.PricebookEntryId=pbe.id;
qlilist.add(qli);
insert qlilist;*/