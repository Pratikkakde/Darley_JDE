trigger TriggerOnSupplierCleanup on Supplier_Cleanup__c (before insert, before Update) {
    
    if(trigger.isBefore && trigger.isUpdate){
        SupplierCleanupTrigger_handler.RequireRejectionComment(trigger.new);
        //SupplierCleanupTrigger_handler.RequireRejectionCommentAndApprovalComment(trigger.new);
        SupplierCleanupTrigger_handler.SupplierCleanupStatusUpdate(trigger.new,trigger.oldmap);
    }
    
    // SupplierCleanupLookups.CleanupLookup(Trigger.new);
}