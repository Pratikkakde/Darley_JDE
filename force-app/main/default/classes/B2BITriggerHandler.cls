public interface B2BITriggerHandler {
    
    void beforeInsert(List<sObject> newList);
    void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap);
    void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap);
    void afterInsert(List<sObject> newList, Map<Id, sObject> newMap);
    void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap);
    void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap);
    void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap);
    Boolean isDisabled();
    
}