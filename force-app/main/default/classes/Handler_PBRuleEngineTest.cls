@IsTest
public class Handler_PBRuleEngineTest {
    
    @IsTest
    public static void testProductbundleruleEnginePump() {
        // Create test data
        Product_Bundle__c ProductionBundle = new Product_Bundle__c();
    ProductionBundle.Name = '1.25AGE 2023';
    insert ProductionBundle;
        
        Product_Bundle_Rule_Engine__c rule1 = new Product_Bundle_Rule_Engine__c();
           rule1.Pump__c = '1.25AGE 2023';
        rule1.Product_Bundle__c = ProductionBundle.Id;
        insert rule1;
    }
    
}