public class quoteLineItem_Handler {
  
    
    
    public static void sumOfCost22New(List<QuoteLineItem> QuoteLineItemlist){
        //list<Quote>Quotelist=new list <Quote>();
        set<id> quoteIdset = new set<id>();
        for(QuoteLineItem qli: QuoteLineItemlist){
            if(qli.QuoteId!=null){
                quoteIdset.add(qli.QuoteId);
            }
        }
        
        List<Quote> quotelist = new List<Quote>();
        for(AggregateResult aRes : [SELECT QuoteId, SUM(Cost_22_Total__c) Total FROM QuoteLineItem WHERE QuoteId IN :quoteIdset GROUP BY QuoteId]) {
            quotelist.add(new quote(Id = (Id)aRes.get('QuoteId'), Cost_22_Total_QLI__c = (Decimal)aRes.get('Total')));
        }
        if(quotelist.size() >0){
            update quotelist;
        }
        
    }
    
    public static void sumOfCost22Old(List<QuoteLineItem> QuoteLineItemlist){
        //list<Quote>Quotelist=new list <Quote>();
        set<id> quoteIdset = new set<id>();
        for(QuoteLineItem qli: QuoteLineItemlist){
            if(qli.QuoteId!=null){
                quoteIdset.add(qli.QuoteId);
            }
        }
        
        List<Quote> quotelist = new List<Quote>();
        for(AggregateResult aRes : [SELECT QuoteId, SUM(Cost_22_Total__c) Total FROM QuoteLineItem WHERE QuoteId IN :quoteIdset GROUP BY QuoteId]) {
            quotelist.add(new quote(Id = (Id)aRes.get('QuoteId'), Cost_22_Total_QLI__c = (Decimal)aRes.get('Total')));
        }
        if(quotelist.size()>0){
            update quotelist;
        }
   
        
    }
    public static void salespriceInsert(List<QuoteLineItem> newlist){
         Id quoteId = newlist[0].QuoteId;
         system.debug('quoteId '+quoteId);
        List<Quote> quotes = [select id, recordTypeId from Quote where id =: quoteId]; 
         system.debug('quotes '+quotes);
       Id EquipRecordTypeId = quotes[0].recordTypeId;
        system.debug('EquipRecordTypeId -  '+EquipRecordTypeId);
       
      
           // if(qli1.Mark_Up__c!=null && qli1.Clone_quote__c!=true){
                 list<recordType>reclist=[select id , name from recordtype where id=:EquipRecordTypeId];
        string recordTypeName = reclist[0].name;
        system.debug('RecordTypeName - ' + recordTypeName);
        if(recordTypeName == 'Equipment'){
            system.debug('in if condition');
            List<id>quotelist=new List<id>();
            for(QuoteLineItem qli: newlist){
             if( qli.Clone_quote__c!=true && qli.Mark_Up__c!= null){
           qli.UnitPrice=qli.Cost_22__c*(1+(qli.Mark_Up__c/100));
            system.debug('UnitPrice'+qli.UnitPrice);
			}
				}
        }
           
    }
    
    
    public static void salespriceUpdate(List<QuoteLineItem> newlist, Map<Id,QuotelineItem> oldaccMap){
       
       // Id EquipRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
        Id quoteId = newlist[0].QuoteId;
         system.debug('quoteId '+quoteId);
        List<Quote> quotes = [select id, recordTypeId from Quote where id =: quoteId]; 
         system.debug('quotes '+quotes);
       Id EquipRecordTypeId = quotes[0].recordTypeId;
        system.debug('EquipRecordTypeId -  '+EquipRecordTypeId);
       
   
        list<recordType>reclist=[select id , name from recordtype where id=:EquipRecordTypeId];
        string recordTypeName = reclist[0].name;
        system.debug('RecordTypeName - ' + recordTypeName);
        if(recordTypeName == 'Equipment'){
            system.debug('in if condition');
            List<id>quotelist=new List<id>();
            for(QuoteLineItem qli: newlist){
             if( qli.Mark_Up__c!=oldaccMap.get(qli.id).Mark_Up__c && qli.Mark_Up__c!= null){
           qli.UnitPrice=qli.Cost_22__c*(1+(qli.Mark_Up__c/100));
            system.debug('UnitPrice'+qli.UnitPrice);
			}
				}
        }


        }  }