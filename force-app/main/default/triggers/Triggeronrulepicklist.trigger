trigger Triggeronrulepicklist on Rule_Picklist__c (before insert, before update)
{
    Map<String, Id> componentCodeToIdMap = new Map<String, Id>();
    List<Product2> products = [SELECT Id, ProductCode FROM Product2];
    for (Product2 product : products) {
        componentCodeToIdMap.put(product.ProductCode, product.Id);
    }
    for (Rule_Picklist__c rule : Trigger.new) {
        if (componentCodeToIdMap.containsKey(rule.Component__c)) {
            rule.Product__c = componentCodeToIdMap.get(rule.Component__c);
        }
    }
}