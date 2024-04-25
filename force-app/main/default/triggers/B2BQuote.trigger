trigger B2BQuote on Quote__c (after update) {
    B2BTriggerDispatcher.Run(new B2BQuoteTriggerHandler(), Trigger.operationType);
}