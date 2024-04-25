trigger triggerOnQuoteLineItem on QuoteLineItem (before insert, before update , before delete,after insert,after update,after delete) {
  /*  if(trigger.isAfter){
        if(trigger.isInsert || trigger.isUpdate || trigger.isUndelete){
            quoteLineItem_Handler.method1(trigger.new);
        }
        if(trigger.isUpdate || trigger.isDelete){
            quoteLineItem_Handler.method2(trigger.old);
        }
    }*/
     if(Trigger.isAfter){
        if(Trigger.isInsert||Trigger.isUpdate||Trigger.isUndelete){
            quoteLineItem_Handler.sumOfCost22New(Trigger.new);
        }
     }
         if(Trigger.isAfter){
         if( Trigger.isDelete){
           quoteLineItem_Handler.sumOfCost22Old(Trigger.old);
        }
    }
    if(trigger.isBefore){
        if( trigger.isUpdate){
            quoteLineItem_Handler.salespriceUpdate(trigger.new ,Trigger.OldMap);
        }
    
    if(trigger.isInsert){
        quoteLineItem_Handler.salespriceInsert(trigger.new);
    }
}
}