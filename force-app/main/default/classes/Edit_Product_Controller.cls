public class Edit_Product_Controller {
    @AuraEnabled
    public static List<editProductWrapper> getQuoteLineItemList(string recordId) {
        system.debug('recordId'+recordId);
        List<QuoteLineItem> qliList= new List<QuoteLineItem>();   
       
        qliList= [select id,product2.name,Product2Id, Cost_22__c ,Mark_Up__c,Temp_Item_Description__c ,Temp_Product_Code__c,Internal_Notes__c,	LineNumber, Quantity, ListPrice,Discount, UnitPrice from QuotelineItem Where QuoteId=:recordId];
       system.debug(' qliList+++++++++'+qliList);
        List<editProductWrapper> qliWrapperList= new List<editProductWrapper>();
        for(QuotelineItem qli : qliList){
            editProductWrapper epWrapper = new editProductWrapper();
            epWrapper.ProductId=qli.Product2Id;
            epWrapper.Id=qli.id;
             epWrapper.product=qli.product2.name;
            epWrapper.LineNumber=qli.LineNumber;
            epWrapper.markup=qli.Mark_Up__c;
            epWrapper.tempItemDesc=qli.Temp_Item_Description__c;
            epWrapper.tempProductCode=qli.Temp_Product_Code__c;
            epWrapper.cost22 = qli.Cost_22__c;
            epWrapper.quantity=qli.Quantity;
            epWrapper.ListPrice=qli.ListPrice;
            epWrapper.salesPrice=qli.UnitPrice;
            epWrapper.Discount=qli.Discount;
            epWrapper.internalNotes=qli.Internal_Notes__c;
            qliWrapperList.add(epWrapper);
        }
        system.debug(' quote line wrapper List'+qliWrapperList);
        return qliWrapperList;
    }
    
    public class editProductWrapper{
        @AuraEnabled
        public String ProductId{get;set;}
        @AuraEnabled
        public String Id{get;set;}
        @AuraEnabled
        public String tempItemDesc{get;set;}
        @AuraEnabled
        public String internalNotes{get;set;}
         @AuraEnabled
        public String LineNumber{get;set;}
          @AuraEnabled
        public Decimal markup{get;set;}
         @AuraEnabled
        public String product{get;set;}
        @AuraEnabled
        public String tempProductCode{get;set;}
        @AuraEnabled
        public Decimal cost22{get;set;}
        @AuraEnabled
        public Decimal quantity{get;set;}
        @AuraEnabled
        public Decimal ListPrice{get;set;}
        @AuraEnabled
        public Decimal Discount{get;set;}
        @AuraEnabled
        public Decimal salesPrice{get;set;}
    } 
    
    @AuraEnabled
      public static boolean updateQliDetails(Object QliData){
      system.debug('QliData**************:'+QliData);
      //system.debug('expsForUpdate:'+expsForUpdate);

      List < editProductWrapper > qliUpdate = ( List < editProductWrapper > ) JSON.deserialize(
      JSON.serialize( QliData ),
      List < editProductWrapper >.class 

        );
       system.debug('qliUpdate:'+qliUpdate);
          
               
      List<QuoteLineItem> QliList = new  List<QuoteLineItem>();
       for(editProductWrapper epWrapper:qliUpdate){
       QuoteLineItem qli=new QuoteLineItem();
       if(epWrapper.markup!=Null){
        qli.Mark_Up__c=epWrapper.markup;
        system.debug('markupcheck'+qli.Mark_Up__c);
            }
            if(epWrapper.tempItemDesc!=Null){
                qli.Temp_Item_Description__c=epWrapper.tempItemDesc;
            }
      // qli.Mark_Up__c=epWrapper.markup;
      if(epWrapper.tempProductCode!=Null){
        qli.Temp_Product_Code__c=epWrapper.tempProductCode;
    }
       if(epWrapper.quantity!=Null){
       qli.Quantity=epWrapper.quantity;
           }
           if(epWrapper.internalNotes!=Null){
            qli.Internal_Notes__c=epWrapper.internalNotes;
                }
       qli.id=epWrapper.Id;


       QliList.add(qli);
       system.debug('QliList*********************:'+QliList);
        }
        if(QliList.size()>0){
         system.debug('QliList:'+QliList);
         update QliList;
         }
          return true;

          }
          
          @AuraEnabled
    
          public static void deleteQli(String qliId){
              system.debug('qliId'+qliId);
              
              delete [SELECT Id from QuotelineItem WHERE id=:qliId];
          } 
        
    
    
    
}