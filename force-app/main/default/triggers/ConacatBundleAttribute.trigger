trigger ConacatBundleAttribute on Bundle_Attributes__c (after insert) {

    List<Bundle_Attributes__c> newRecords = [SELECT Id,Name, Attributes__r.Name, Product_Bundle__r.Name FROM Bundle_Attributes__c WHERE Id IN :Trigger.newMap.keySet()];
    List<Bundle_Attributes__c> recordsToUpdate = new List<Bundle_Attributes__c>();
    for (Bundle_Attributes__c record : newRecords) {
        if (record.Attributes__r != null && record.Product_Bundle__r != null) {
            record.Name = record.Attributes__r.Name + '_ ' + record.Product_Bundle__r.Name;
            recordsToUpdate.add(record);
        }
    }
    update recordsToUpdate;
}