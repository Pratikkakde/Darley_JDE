trigger B2BProduct2Trigger on Product2 (before insert, before update, before delete, after insert, after update, after delete) {

    B2BTriggerDispatcher.Run(new B2BProduct2TriggerHandler(), Trigger.operationType);

}