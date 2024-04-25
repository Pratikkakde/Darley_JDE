public class Handler_TriggerOnBundleAttribute {
    
    
    public static void populateProductBundle(List<Bundle_Attributes__c> newAttrs, Map<Id, Bundle_Attributes__c> oldAttrsMap) {

        Map<String, Id> productBundleMap = new Map<String, Id>();
        Map<String, Id> attributeMap = new Map<String, Id>();
        
        // Get all unique product bundle and attribute names from the inserted/updated records
        for (Bundle_Attributes__c newAttr : newAttrs) {
            
            Bundle_Attributes__c oldAttr = new Bundle_Attributes__c(); 
            if(oldAttrsMap!=null)
            {
                oldAttr = oldAttrsMap.get(newAttr.Id); 
            } 
            // Only query for product bundles/attributes that have changed or are new
            
            if (!productBundleMap.containsKey(newAttr.product_Bundle_Text__c)) {
                productBundleMap.put(newAttr.product_Bundle_Text__c, null);
            }
            
            if (!attributeMap.containsKey(newAttr.Attributes_text__c)) {
                attributeMap.put(newAttr.Attributes_text__c, null);
                
            }
        }
        
        system.debug('--'+productBundleMap.keySet());
        // Query for the matching Product Bundle and Attribute records
        List<Product_Bundle__c> productBundles = [ SELECT Id, Name FROM Product_Bundle__c WHERE Name IN :productBundleMap.keySet() ];
        List<Attributes__c > attributes = [ SELECT Id, Name FROM Attributes__c WHERE Name IN :attributeMap.keySet() ];
        
        System.debug('!-->'+productBundles);
        // Build a map of product bundle/attribute name to Id for fast lookup
        for (Product_Bundle__c bundle : productBundles) {
            productBundleMap.put(bundle.Name, bundle.Id);
        }
        for (Attributes__c  attribute : attributes) {
            attributeMap.put(attribute.Name, attribute.Id);
        }
        
        // Update the Bundle Attributes records with the matching Product Bundle and Attribute Ids
        for (Bundle_Attributes__c newAttr : newAttrs) {
            
            System.debug('-->'+productBundleMap.get(newAttr.product_Bundle_Text__c));
            newAttr.Product_Bundle__c = productBundleMap.get(newAttr.product_Bundle_Text__c);
            newAttr.Attributes__c = attributeMap.get(newAttr.Attributes_text__c);
        }

    }
    
    
}