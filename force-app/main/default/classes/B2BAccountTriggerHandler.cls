public class B2BAccountTriggerHandler implements B2BITriggerHandler {
    
    public static boolean TriggerDisabled =  false;
    
    public void beforeInsert(List<sObject> newList) {}
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) {}
    
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {}
    
    public void afterInsert(List<sObject> newList, Map<Id, sObject> newMap) {
        
    }
    
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) {
        
        deleteRelatedDarleyDollars((Map<Id, Account>)newMap, (Map<Id, Account>)oldMap);
        
    }
    
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        assignContactPointAddressesAfterMerge(oldList);
    }
    
    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {}
    
    public Boolean isDisabled() {
        
        return TriggerDisabled;
        
    }
    
    private static void deleteRelatedDarleyDollars(Map<Id, Account> newMap, Map<Id, Account> oldMap) {
        
        List<DarleyDollar__c> darleyDollarsToDelete = new List<DarleyDollar__c>();
        
        for (DarleyDollar__c darleyDollarToDelete : [
            SELECT Id, Contact__r.AccountId 
            FROM DarleyDollar__c 
            WHERE Contact__r.AccountId IN :newMap.keySet()
            ]) {            
            Account newAccount = newMap.get(darleyDollarToDelete.Contact__r.AccountId);
            Account oldAccount = oldMap.get(darleyDollarToDelete.Contact__r.AccountId);          
            if (newAccount.OptoutFromDarleyDollars__c == true && oldAccount.OptoutFromDarleyDollars__c == false) {
                darleyDollarsToDelete.add(darleyDollarToDelete);   
            }
        }
    
        if (!darleyDollarsToDelete.isEmpty()) {
            delete darleyDollarsToDelete; 
        }
     
    }

    private static void assignContactPointAddressesAfterMerge(List<Account> oldList) {
        Map<Id, Id> accountIdByMasterRecordId = new Map<Id, Id>();
        for (Account account : oldList) {
            accountIdByMasterRecordId.put(account.Id, account.MasterRecordId);
        }

        List<ContactPointAddress> addresses = [
            SELECT Id, ParentId
            FROM ContactPointAddress
            WHERE ParentId = :accountIdByMasterRecordId.keySet()
        ];

        for (ContactPointAddress address : addresses) {
            address.ParentId = accountIdByMasterRecordId.get(address.ParentId);
        }

        Database.update(addresses, false);
    }
    
}