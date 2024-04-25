@isTest
public class ProductUpdateLookupTest {
    @isTest 
    public static void ProductUpdateLookupTest1(){
        List<Product2> pList = new List<Product2>();
        	pList.add(new Product2(Name='Sample Product',ProductCode='STH108'));
        insert pList;
        
        Product_Bundle__c pBundle= new Product_Bundle__c(name='HE PORT 2023');
        insert pBundle;
        List<Product_Bundle_Rule_Engine__c> ruleEngineQuery = new List<Product_Bundle_Rule_Engine__c>();
        Product_Bundle_Rule_Engine__c pbRuleEngine = new Product_Bundle_Rule_Engine__c(Bundle_Sequence__c=5, 
                                                                                       Product_Bundle__c=pBundle.Id, 
                                                                                       JDE_Component__c='STH108', 
                                                                                       Product__c=NULL);
        ruleEngineQuery.add(pbRuleEngine);
        insert ruleEngineQuery;
        
        List<Rule_Picklist__c> rulePicklistQuery = new List<Rule_Picklist__c>();
        Rule_Picklist__c rulePick = new Rule_Picklist__c(Component__c='STH108', Product__c=null, Pump_Bundle__c='HE PORT 2023');
        rulePicklistQuery.add(rulePick);
        insert rulePicklistQuery;
        
        test.startTest();
        	ProductUpdateLookup batchInstance = new ProductUpdateLookup();
        	Database.executeBatch(batchInstance);        
         test.stopTest(); 
    }
}