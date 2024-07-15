trigger triggerOnSupplierXlat on Supplier_XLAT__c (before insert, before update,after insert) {
    if(trigger.isBefore && trigger.isInsert){
  SupplierXlatTrigger_handler.duplicateChildName(trigger.new,null);
    }
    
    if(trigger.isBefore && trigger.isUpdate){
     SupplierXlatTrigger_handler.duplicateChildName(trigger.new, trigger.oldmap);
    }
    
 
    

}