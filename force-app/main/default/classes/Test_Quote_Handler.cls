@istest
public class Test_Quote_Handler {
@istest
    public static void testmethod1(){
          account acc=new account();
         acc.Name='test';
         insert acc;
         contact con =new contact();
         con.AccountId=acc.id;
         con.lastname='test';
         insert con;
      list<quote> QouteList=  new  list<quote>();
           list< RecordType> RecType = [Select Id From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'Equipment'];
      list<opportunity> opplist=new list<opportunity>();
         opportunity opp= new opportunity();
          opp.RecordTypeId=RecType[0].id;
         opp.name='test';         
         opp.CloseDate=system.today();
         opp.StageName='Awarded Won';
         opp.AccountId=acc.id;
       opplist.add(opp);
         insert opplist;
         list<OpportunityContactRole> ocrlist=new list<OpportunityContactRole>();
         OpportunityContactRole ocr=new OpportunityContactRole();
           ocr.ContactId=con.id;
            ocr.Role = 'Decision Maker';
            ocr.OpportunityId=opp.id;
            ocrlist.add(ocr);
         insert ocrlist;
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
            map<id,quote> quotemap=new map<id,quote>();
              list< RecordType> RecType1 = [Select Id From RecordType  Where SobjectType = 'Quote' and DeveloperName = 'Equipment'];
           list<quote> qulist=new list<quote>();
         quote qu=new quote();
         qu.name='test';
          qu.Pricebook2Id = Test.getStandardPricebookId();
         qu.RecordTypeId=RecType1[0].id;
         qu.OpportunityId=opp.id;
        
         
         qulist.add(qu);
         insert qulist;
         quotemap.put(qulist[0].Id, qulist[0]);
       
    
       
   
        Test.startTest();
         Quote_Handler.requirecontactrole(qulist);
       //  Quote_Handler.quoteamountupdate(qulist,quotemap);
     //    Quote_Handler.quoteDarleyCostupdate(qulist,quotemap)
      //    Quote_Handler.quoteamountupdate(qulist,quotemap);
        Test.stopTest();
     }
       /* public static void quoteamountupdate1(){
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
         opportunity opp= new opportunity();
         opp.name='test';
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
        
        list< RecordType> RecType = [Select Id From RecordType  Where SobjectType = 'Quote' and DeveloperName = 'Equipment'];
         quote qu=new quote();
         qu.name='test';
          qu.Pricebook2Id = Test.getStandardPricebookId();
         qu.RecordTypeId=RecType[0].id;
         qu.OpportunityId=opp.id;         
         
         qulist.add(qu);
         insert qulist;
         quotemap.put(qulist[0].Id, qulist[0]);
         
         list<QuoteLineItem>qlilist=new list<QuoteLineItem>();
            QuoteLineItem QLI  = new QuoteLineItem();
       // QLI.Product2Id = pro.Id;
        QLI.QuoteId = qu.Id;
        QLI.PricebookEntryId = pbe.Id;
        QLI.Quantity = 2;
        QLI.UnitPrice = 150000.0; 
       insert QLI;  
        QLI.Quantity = 5;
        update Qli;
        qlilist.add(QLI);  
         */
  /*      // Quote_amount_opportunity_Handler.quoteamountupdate(qulist,quotemap);
         
           test.startTest();
      // Quote_Handler.quoteamountupdate(qulist,quotemap);
  //       Quote_Handler.quoteDarleyCostupdate(qulist,quotemap);
      //   quoteLineItem_Handler.sumOfCost22New(qlilist);
        test.stopTest();
         
          } 
         */
 public static void darleyCost(){
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
     
     
      list< RecordType> RecType = [Select Id From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'Equipment'];
  
        
     
        
         list<opportunity> opplist=new list<opportunity>();
         opportunity opp= new opportunity();
         opp.name='test';
       opp.RecordTypeId=RecType[0].id;
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
        
        list< RecordType> RecTypes = [Select Id From RecordType  Where SobjectType = 'Quote' and DeveloperName = 'Equipment'];
         quote qu=new quote();
         qu.name='test';
          qu.Pricebook2Id = Test.getStandardPricebookId();
         qu.RecordTypeId=RecTypes[0].id;
         qu.OpportunityId=opp.id;         
         
         qulist.add(qu);
         insert qulist;
         quotemap.put(qulist[0].Id, qulist[0]);
         
         list<QuoteLineItem>qlilist=new list<QuoteLineItem>();
            QuoteLineItem QLI  = new QuoteLineItem();
       // QLI.Product2Id = pro.Id;
        QLI.QuoteId = qu.Id;
        QLI.PricebookEntryId = pbe.Id;
        QLI.Quantity = 2;
        QLI.UnitPrice = 150000.0; 
       insert QLI;  
        QLI.Quantity = 5;
        update Qli;
        qlilist.add(QLI);  
         
        // Quote_amount_opportunity_Handler.quoteamountupdate(qulist,quotemap);
         
           test.startTest();
    //   Quote_Handler.quoteamountupdate(qulist,quotemap);
     //    Quote_Handler.quoteDarleyCostupdate(qulist,quotemap);
      //   quoteLineItem_Handler.sumOfCost22New(qlilist);
       Quote_Handler.requirecontactrole(qulist);
        test.stopTest();
         
         
         
 }

      
  }