global class ProductUpdateLookup implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, Name, ProductCode FROM Product2 ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Product2> productList) {
        List<Product_Bundle_Rule_Engine__c> ruleEngineList = new List<Product_Bundle_Rule_Engine__c>();
        Map<String, Id> productCodeToIdMap = new Map<String, Id>();
        for (Product2 product : productList) {
            productCodeToIdMap.put(product.ProductCode, product.Id);
        }
        
        List<Product_Bundle_Rule_Engine__c> ruleEngineQuery = [SELECT Id, Bundle_Sequence__c, Product_Bundle__c, JDE_Component__c, Product__c, Pump__c FROM Product_Bundle_Rule_Engine__c WHERE Product__c = NULL AND JDE_Component__c != NULL limit 10000];
        for (Product_Bundle_Rule_Engine__c ruleEngine : ruleEngineQuery) {
            if (productCodeToIdMap.containsKey(ruleEngine.JDE_Component__c)) {
                ruleEngine.Product__c = productCodeToIdMap.get(ruleEngine.JDE_Component__c);
                ruleEngineList.add(ruleEngine);
            }
        }
        update ruleEngineList;
        
        List<Rule_Picklist__c> rulePicklistList = new List<Rule_Picklist__c>();
        List<Rule_Picklist__c> rulePicklistQuery = [SELECT Component__c, Product__c, Pump_Bundle__c FROM Rule_Picklist__c WHERE Product__c = NULL AND Component__c != NULL limit 10000];
        for (Rule_Picklist__c rulePicklist : rulePicklistQuery) {
            if (productCodeToIdMap.containsKey(rulePicklist.Component__c)) {
                rulePicklist.Product__c = productCodeToIdMap.get(rulePicklist.Component__c);
                rulePicklistList.add(rulePicklist);
            }
        }
        update rulePicklistList;
    }
    
    global void finish(Database.BatchableContext BC) {
        // do any post-processing here
    }
}