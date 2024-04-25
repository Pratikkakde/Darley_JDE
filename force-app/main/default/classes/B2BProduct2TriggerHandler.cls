public with sharing class B2BProduct2TriggerHandler implements B2BITriggerHandler {
    public static Boolean TriggerDisabled =  false;

    public void beforeInsert(List<sObject> newList) {}
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) {}
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {}

    public void afterInsert(List<sObject> newList, Map<Id, sObject> newMap) {
        scheduleProducts(newList);
    }

    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) {}
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {}
    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {}

    public Boolean isDisabled() {
        return TriggerDisabled;
    }

    private static void scheduleProducts(List<sObject> newList) {
        B2BProductBatch productScheduled = new B2BProductBatch(newList);
        try {
            Id batchJobId = Test.isRunningTest() ? Database.executeBatch(productScheduled, 100) : Database.executeBatch(productScheduled, 50);
            System.debug ('Running B2BProductBatch. Job Id = ' + batchJobId);
        } catch (Exception ex) {
            System.debug('ERROR schedule Product Job: ' + ex.getMessage());
        }
    }
}