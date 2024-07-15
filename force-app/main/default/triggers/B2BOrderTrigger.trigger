trigger B2BOrderTrigger on Order (after update,after insert) {
    
    switch on Trigger.OperationType  {
        
        when Before_Update {
            //B2BUpdateCCExpDate.updateCCInfo(Trigger.new);            
        }
        
        when After_Update{
            B2BOrderTriggerHandler.sendOrderShippedEmail(Trigger.oldMap, Trigger.newMap);
            
            //Handler to update address and credit card data to JDE using Queueable Apex.
            OrderTriggerHandler.address_Cred_CardUpdateToJde(trigger.new, trigger.old);
            
        }
        when After_INSERT {
            
            OrderTriggerHandler.afterinsert(trigger.new);
        }
    }
    
}