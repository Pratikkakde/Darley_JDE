trigger AddProductBundleLookup on Product_Bundle_Rule_Engine__c (before insert , before update) {
// Get the related parent object IDs
    List<string> mainBundle = new list<string>();
    for (Product_Bundle_Rule_Engine__c pb : Trigger.new) {
        mainBundle.add(pb.Pump__c);
    }
    
    map<string,Id> bundlemap = new map<string,Id>();
      list<Product_Bundle__c> pblist =[SELECT Id, Name FROM Product_Bundle__c WHERE Name IN :mainBundle];
        for (Product_Bundle__c pbundle : pblist) {
      
            bundlemap.put(pbundle.Name,pbundle.id);
        }
    // Query for the related parent objects
   // list<Product_Bundle__c> bundleList = new list<Product_Bundle__c>(
//[SELECT Id, Name FROM Product_Bundle__c WHERE Name IN :mainBundle]
   // );
    for (Product_Bundle_Rule_Engine__c ruleEngine : Trigger.new) {
      
            ruleEngine.Product_Bundle__c = bundlemap.get(ruleEngine.Pump__c);
        }
    }