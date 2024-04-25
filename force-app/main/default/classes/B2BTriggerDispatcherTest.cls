@isTest
private class B2BTriggerDispatcherTest {
    @isTest static void runTest() {
        B2BTriggerDispatcher.Run(new TriggerHandler(), TriggerOperation.BEFORE_INSERT);
        B2BTriggerDispatcher.Run(new TriggerHandler(), TriggerOperation.BEFORE_UPDATE);
        B2BTriggerDispatcher.Run(new TriggerHandler(), TriggerOperation.BEFORE_DELETE);
        B2BTriggerDispatcher.Run(new TriggerHandler(), TriggerOperation.AFTER_INSERT);
        B2BTriggerDispatcher.Run(new TriggerHandler(), TriggerOperation.AFTER_UPDATE);
        B2BTriggerDispatcher.Run(new TriggerHandler(), TriggerOperation.AFTER_DELETE);
        B2BTriggerDispatcher.Run(new TriggerHandler(), TriggerOperation.AFTER_UNDELETE);
    }

    class TriggerHandler implements B2BITriggerHandler {
        public void beforeInsert(List<sObject> newList){}
        public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap){}
        public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap){}
        public void afterInsert(List<sObject> newList, Map<Id, sObject> newMap){}
        public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap){}
        public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap){}
        public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap){}
        public Boolean isDisabled(){ return false; }
    }
    
}