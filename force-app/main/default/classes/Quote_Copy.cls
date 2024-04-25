public class Quote_Copy {
    @AuraEnabled
    public static string selectquote(string quoteId){
        list<Quote> quotelist= [select  id,name FROM Quote where id=:quoteId];
        
        String quote = quotelist[0].name;
        // system.debug('quotelist[0].name'quotelist[0].name);
        return quote;
    }
    @AuraEnabled
    public static list<QuoteLineItem> inactiveProductCheck(string quoteId){
        list<QuoteLineItem> QlInactivelist= new list<QuoteLineItem>();
        
        list<QuoteLineItem> Qltlist=[SELECT  Cost_22__c, TotalPrice,UnitPrice,Description,Discount,Discount_Amount__c, 
                                     Internal_Notes__c,LineNumber,ListPrice,Manufacturer_Item__c,Manufacturer__c,Margin__c
                                     ,Mark_Up__c,Net_Price__c,OpportunityLineItemId,PricebookEntryId,Product2Id,Product2.name,Product_Category_2__c
                                     ,Product_Description__c,Quantity,QuoteId,ServiceDate,SortOrder,Subtotal,Temp_Item_Description__c,
                                     Temp_Product_Code__c, PricebookEntry.IsActive FROM QuoteLineItem where QuoteId=:QuoteId];
        system.debug('Qltlist++'+Qltlist);  
        for(QuoteLineItem qtl:Qltlist){
            if(qtl.PricebookEntry.IsActive==false){
                QlInactivelist.add(qtl);
            }
        }
        return QlInactivelist;
    }
    
    @AuraEnabled
    public static QuoteCloneResult copyquote(string quoteId,string Opportunityid,string name   ){ 
        list<QuoteLineItem> Qlactivelist= new list<QuoteLineItem>();
        list<QuoteLineItem> QlInactivelist= new list<QuoteLineItem>();
        Quote qu=new Quote(); 
        try{
            list< RecordType> RecType = [Select Id From RecordType Where SobjectType = 'Quote' and DeveloperName = 'Defense'];         
            qu=[select  AccountId,Subtotal,TotalPrice,Name,OpportunityId,Status,RecordTypeid,account.name,account.billingstate,account.shippingstate,RecordType.Name,Pricebook2Id,account.BillingCity,account.BillingCountry,account.BillingPostalCode,account.BillingStreet,account.ShippingCity,account.ShippingCountry,account.shippingPostalCode,account.ShippingStreet FROM Quote  where Id =:quoteId];
            system.debug('qu'+qu);
            opportunity accountAddressDetails = [select id,Account.BillingCity,Account.BillingCountry,Account.name,Account.BillingPostalCode,Account.BillingState,Account.BillingStreet,Account.ShippingCity,Account.ShippingCountry,Account.ShippingState,Account.ShippingStreet,Account.ShippingPostalCode from opportunity where id = :Opportunityid];
            list<Quote> qlist=new list<Quote>();
            if(RecType[0].id!=qu.recordtype.id  )
            { 
                Quote qo=new Quote();
                qo.RecordTypeId=qu.RecordTypeid;
                system.debug(' qu.RecordTypeid'+ qu.RecordTypeid);
                qo.Pricebook2Id= qu.Pricebook2Id; 
                system.debug(' qu.Pricebook2Id'+ qu.Pricebook2Id);
                
                qo.OpportunityId=Opportunityid;
                qo.Name=name;
                qo.Status='Draft';
                qo.BillingCity = accountAddressDetails.account.BillingCity ;
                qo.BillingCountry =accountAddressDetails.account.BillingCountry;
                //system.debug(' qu.Pricebook2Id'+ qu.Pricebook2Id);
                qo.BillingName=accountAddressDetails.account.name;
                qo.BillingPostalCode =accountAddressDetails.account.BillingPostalCode;
                qo.BillingState=accountAddressDetails.account.BillingState;
                qo.BillingStreet=accountAddressDetails.account.BillingStreet;
                qo.ShippingCity=accountAddressDetails.account.ShippingCity;
                qo.ShippingCountry=accountAddressDetails.account.ShippingCountry;
                qo.ShippingName=accountAddressDetails.account.name;
                qo.ShippingState=accountAddressDetails.account.ShippingState;
                qo.ShippingStreet=accountAddressDetails.account.ShippingStreet;
                qo.ShippingPostalCode=accountAddressDetails.account.ShippingPostalCode;
                
                
                qlist.add(qo);
                
                insert qlist;
                system.debug('qlist++'+qlist);        
                list<QuoteLineItem> Qltlist=[SELECT  Cost_22__c, TotalPrice,UnitPrice,Description,Discount,Discount_Amount__c, 
                                             Internal_Notes__c,LineNumber,ListPrice,Manufacturer_Item__c,Manufacturer__c,Margin__c
                                             ,Mark_Up__c,Net_Price__c,OpportunityLineItemId,PricebookEntryId,Product2Id,Product_Category_2__c
                                             ,Product_Description__c,Quantity,QuoteId,ServiceDate,SortOrder,Subtotal,Temp_Item_Description__c,
                                             Temp_Product_Code__c , PricebookEntry.IsActive ,Product2.name FROM QuoteLineItem where QuoteId=:QuoteId];
                system.debug('Qltlist++'+Qltlist);  
                for(QuoteLineItem qtl:Qltlist){
                    qtl.id=null;
                    qtl.QuoteId=null;
                    qtl.UnitPrice=qtl.ListPrice;
                    qtl.Mark_Up__c=null;
                    qtl.quoteid=qlist[0].id;       
                    if(qtl.PricebookEntry.IsActive==false){
                        QlInactivelist.add(qtl);
                    }
                    else{
                        Qlactivelist.add(qtl);
                    }
                    system.debug('UnitPrice'+qtl.UnitPrice);
                    system.debug('ListPrice'+qtl.ListPrice);
                    
                }
            }
            list<QuoteLineItem> qtlist=Qlactivelist.clone();
            insert qtlist;
            system.debug('qtlist++'+qtlist);
            QuoteCloneResult result = new QuoteCloneResult(qlist[0].Id, QlInactivelist);
            system.debug('result++'+result);
            //return result;  
            
            return result;
        }
        
        catch (Exception e) {
            
            System.debug('Exception: ' + e.getMessage());
            
            throw new AuraHandledException('Error occurred during quote cloning: ' + e.getMessage());
            
        }
    }
    public class QuoteCloneResult {
        @AuraEnabled
        public Id quoteId;
        @AuraEnabled
        public List<QuoteLineItem> quoteLineItems;
        
        public QuoteCloneResult(Id quoteId, List<QuoteLineItem> quoteLineItems) {
            this.quoteId = quoteId;
            this.quoteLineItems = quoteLineItems;
        }
    }
}