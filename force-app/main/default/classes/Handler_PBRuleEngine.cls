public class Handler_PBRuleEngine {
    Public static void ProductbundleruleEnginePump(List<Product_Bundle_Rule_Engine__c> pbRuleList){
        Map<String, Id> pumpNameToIdMap = new Map<String, Id>();
        List<Product_Bundle__c> productBundleList =[SELECT Id, Name FROM Product_Bundle__c];
    for (Product_Bundle__c bundle : productBundleList) {
        pumpNameToIdMap.put(bundle.Name, bundle.Id);
    }
    for (Product_Bundle_Rule_Engine__c rule : pbRuleList) {
        if (pumpNameToIdMap.containsKey(rule.Pump__c)) {
            rule.Product_Bundle__c = pumpNameToIdMap.get(rule.Pump__c);
        }
    }
    }
    
    }