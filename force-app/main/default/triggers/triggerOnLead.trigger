trigger triggerOnLead on Lead (before insert) {
    if(trigger.isInsert)
    {
        if(trigger.isBefore)
        {
            LeadRecordTypeAssingmentTriggerHandler.RecordTypeAssignment(trigger.new);
        } 
    }
   }