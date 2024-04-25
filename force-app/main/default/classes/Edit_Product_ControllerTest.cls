@isTest
public class Edit_Product_ControllerTest {
   @isTest
    public static void Editmethodtest()
    {
        //account
        account acc=new account();
        acc.Name='test';
        insert acc;
        //contact
        contact con =new contact();
        con.lastname='tester';
        insert con;
        //Product
     //   Product2 pro = new Product2(Name = 'melon', Family = 'Mobile');
      //  Insert pro;
        //opportunity
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
        //opportunityContactRole
        OpportunityContactRole ocr=new  OpportunityContactRole();
        ocr.opportunityid=opp.id;
        ocr.ContactId=con.Id;
        
        insert ocr;
        
        //quote
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
        
        
        //pricebook
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
           // insert pbe;   
        
        //Quotelineitem
//        List < editProductWrapper > qliUpdate = ( List < editProductWrapper > ) JSON.deserialize(
  //    JSON.serialize( QliData ),
  //    List < editProductWrapper >.class 
    list<QuotelineItem>qliList=new list<QuotelineItem>();
          QuotelineItem quotee = new QuotelineItem();
     quotee.Product2Id= pro.id;
    quotee.Mark_Up__c= 95;
        quotee.Temp_Item_Description__c= 'melonleaf';
        quotee.Temp_Product_Code__c= 'melonleaf';
        quotee.Internal_Notes__c= 'melonleaf 2';
        quotee.Quantity = 7;
        quotee.UnitPrice= 76;
        quotee.QuoteId=qu.id;
        quotee.PricebookEntryId=pbe.id;
       quotee.Discount= 54;
        qliList.add(quotee);
          insert qliList;
     
            
        
          test.startTest();
   
       Edit_Product_Controller.getQuoteLineItemList(qu.id);
         Edit_Product_Controller.updateQliDetails(qliList);
        Edit_Product_Controller.deleteQli(quotee.id);
       
        test.stopTest();
         
}
}