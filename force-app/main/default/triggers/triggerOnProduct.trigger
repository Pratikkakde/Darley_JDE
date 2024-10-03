trigger triggerOnProduct on Product2 (before insert, before update) {
    switch on Trigger.OperationType  {
        when BEFORE_INSERT{
            productTriggerHandler.handleBeforeInsert(trigger.new);
            productTriggerHandler.changeRecordType(trigger.new);
        }
        when BEFORE_UPDATE{
            productTriggerHandler.changeRecordType(trigger.new);
        }
    
    }
}