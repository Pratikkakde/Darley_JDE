trigger triggerOnProduct on Product2 (before insert) {
    switch on Trigger.OperationType  {
        when BEFORE_INSERT{
            productTriggerHandler.handleBeforeInsert(trigger.new);
            productTriggerHandler.changeRecordType(trigger.new);
        }
    }
}