trigger triggerOnLead on Lead (before insert,After Update) {
    if(trigger.isInsert)
    {
        if(trigger.isBefore)
        {
            LeadRecordTypeAssingmentTriggerHandler.RecordTypeAssignment(trigger.new);
        }
    }
         if(trigger.isAfter && trigger.isUpdate) {
            // this method is call when the mail are add to the email fields 
            // we send the rfq pdf to the supplier which due date is greater than today 
            Lead_trigger_Handler.whentheEmailAreAddtotheEmailfield(Trigger.new,Trigger.OldMap);
            
            //when we convert the lead to this is call the xlt record is link to the account record 
            Lead_trigger_Handler.linkAccountTOXLTAfterConveert(Trigger.new,Trigger.OldMap);

        }
}