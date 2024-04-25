trigger TriggerOnOpportunity on Opportunity (after insert,after update, after delete) { 
    
    if(trigger.isInsert)
    {
        if(trigger.isAfter)
        {
            TriggerOnOpportunityHandler.afterInsert(trigger.new);
        } 
    }
    
    if(trigger.isUpdate){
        if(trigger.isAfter)
        {
            if(TriggerOnOpportunityHandler.firstRun)
            {
                TriggerOnOpportunityHandler.firstRun = false;
                TriggerOnOpportunityHandler.afterupdate(trigger.new,trigger.old,trigger.newmap,trigger.oldMap); 
            }
        }
    }
    
    if(trigger.isDelete)
    {
        TriggerOnOpportunityHandler.afterDelete(trigger.old);
    } 
}