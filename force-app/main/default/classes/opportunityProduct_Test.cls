@isTest
public class opportunityProduct_Test {
	@isTest
    public static void searchProductTest(){
        String key = '%h%';
        test.startTest();
        opportunityProduct.searchProduct(key);
        test.stopTest();
        
    }
    
    @isTest
    public static void searchProductTestforempty(){        
        string key = '';
        Test.startTest();
        OpportunityProduct.searchProduct(key);
        Test.stopTest();
    }
    
    @isTest
    public static void findOpportunityTest(){
        string oppoName = 'oppotest';
        test.startTest();
        opportunityProduct.findOpportunity(oppoName);
        test.stopTest();
    }

    @isTest
    public static void ProductDetailsTest(){
        string name = '1.25AGE 2023';
        string Description = 'model desc';
        string ImageURL = 'www.pic.com';
        list<Product_Bundle__c> pblist = new list<Product_Bundle__c>();
        pblist.add(new Product_Bundle__c(Name='1.25AGE 2023',Description__c='model desc',Pump_Image__c='www.pic.com'));
        test.startTest();
        insert pblist;
        opportunityProduct.ProductDetails(pblist[0].id);
        test.stopTest();
                                                                                                                                                                              
    }
    
        // for main Required Bundle........................................................................................
    @isTest
    public static void reqBundleTest(){
           // Product_Bundle__c bundle = new Product_Bundle__c(Name = 'Test Bundle');
           // insert bundle;
            string bundleID = '1234567890';
            Attributes__c attributename = new Attributes__c(Name = 'test attribute name');
            insert attributename;
        
            Attributes__c attributename2 = new Attributes__c(Name = 'test attribute name2');
            insert attributename2;
            
            Bundle_Attributes__c bundleAttribute = new Bundle_Attributes__c(
            Bundle_Sequence__c = 100,
            Default_Product__c = 'default product',
            Attributes__c = attributename.Id,
            Product_Bundle__c = bundleID,
            Is_Numeric__c = 'N',
            Required__c = 'R');
            insert bundleAttribute;
            

            Bundle_Attributes__c bundleAttribute2 = new Bundle_Attributes__c(
            Name = 'Test2 Bundle Attribute',
            Bundle_Sequence__c = 200,
            Default_Product__c = 'default product2',
            Attributes__c = attributename2.Id,
            Product_Bundle__c = bundleID,
            Is_Numeric__c = 'Y',
            Required__c = 'R');
            insert bundleAttribute2;
        
            system.debug('bundleAttribute2...'+bundleAttribute2);
            Default_products__c testDefaultProduct = new Default_products__c(
            Product_name__c = 'Test Bundle',
            Name = 'Test Default Product',
            Bundle_Sequence__c = 100,
            JDE_component__c = 'Test Component'
            );
            insert testDefaultProduct;
        
            Default_products__c testDefaultProduct2 = new Default_products__c(
            Product_name__c = 'Test Bundle',
            Name = 'Test Default Product',
            Bundle_Sequence__c = 200,
            JDE_component__c = 'Test Component2'
            );
            insert testDefaultProduct2;
            
            system.debug('bundleID-->'+bundleID);
            system.debug('attributename-->'+attributename.name);
            system.debug('attributeID-->'+attributename.id);
            system.debug('bundleAttribute.Attributes__r.Name-->'+bundleAttribute.Attributes__r.name);
      
            test.startTest();
            opportunityProduct.reqBundle(bundleID);
            test.stopTest();
        }
    
    @isTest
    public static void optBundleTest(){
            Product_Bundle__c bundle = new Product_Bundle__c(Name = 'Test Bundle');
            insert bundle;
            
            Attributes__c attributename = new Attributes__c(Name = 'test attribute name');
            insert attributename;
        
            Attributes__c attributename2 = new Attributes__c(Name = 'test attribute name2');
            insert attributename2;
            
            Bundle_Attributes__c bundleAttribute = new Bundle_Attributes__c(
            Bundle_Sequence__c = 100,
            Default_Product__c = 'default product',
            Attributes__c = attributename.Id,
            Product_Bundle__c = bundle.Id,
            Is_Numeric__c = 'N',
            Required__c = 'O');
            insert bundleAttribute;
            

            Bundle_Attributes__c bundleAttribute2 = new Bundle_Attributes__c(
            Name = 'Test2 Bundle Attribute',
            Bundle_Sequence__c = 200,
            Default_Product__c = 'default product2',
            Attributes__c = attributename2.Id,
            Product_Bundle__c = bundle.Id,
            Is_Numeric__c = 'Y',
            Required__c = 'O');
            insert bundleAttribute2;
        
            system.debug('bundleAttribute2...'+bundleAttribute2);
            Default_products__c testDefaultProduct = new Default_products__c(
            Product_name__c = 'Test Bundle',
            Name = 'Test Default Product',
            Bundle_Sequence__c = 100,
            JDE_component__c = 'Test Component'
            );
            insert testDefaultProduct;
        
            Default_products__c testDefaultProduct2 = new Default_products__c(
            Product_name__c = 'Test Bundle',
            Name = 'Test Default Product',
            Bundle_Sequence__c = 200,
            JDE_component__c = 'Test Component2'
            );
            insert testDefaultProduct2;
            
            system.debug('bundle.Id-->'+bundle.Id);
            system.debug('attributename-->'+attributename.name);
            system.debug('attributeID-->'+attributename.id);
            system.debug('bundleAttribute.Attributes__r.Name-->'+bundleAttribute.Attributes__r.name);
      
            test.startTest();
            opportunityProduct.OptBundle(bundle.Id);
            test.stopTest();
        }  
    
    @isTest
    public static void forThenLogicTest(){
            Product_Bundle__c bundle = new Product_Bundle__c(Name = 'Test Bundle');
            insert bundle; 
        
            Bundle_Attributes__c bundleAttribute = new Bundle_Attributes__c(
            Bundle_Sequence__c = 100,
            Default_Product__c = 'default product',
           // Attributes__c = attributename.Id,
            Product_Bundle__c = bundle.Id,
            Is_Numeric__c = 'N',
            Required__c = 'R');
            insert bundleAttribute;
        
            Default_products__c testDefaultProduct = new Default_products__c(
            Product_name__c = 'Test Bundle',
            Name = 'Test Default Product',
            Bundle_Sequence__c = 100,
            JDE_component__c = 'Test Component'
            );
            insert testDefaultProduct;
        
            test.startTest();
            opportunityProduct.forThenLogic('ComboName', 'Test Pump', '1 ABC', '[{"key":"1 ABC","value":"Value1"},{"key":"2 XYZ","value":"Value2"}]');
            test.stopTest();
    }
    
    @isTest
    public static void bundlenameRefreshTest(){
        Product_Bundle__c testProductBundle = new Product_Bundle__c(Name = 'Test Product Bundle');
        insert testProductBundle;

        Product_Bundle_Rule_Engine__c testRule1 = new Product_Bundle_Rule_Engine__c(
            rule__c = 1,
            Rule_Seq__c = 1,
            pump__c = 'Test Pump',
            JDE_Component__c = 'Test Component',
            Logic__c = 'if',
            Component_Type__c = 'Test Type',
            Logic_Releationship__c = 'EQ',
            Is_Conditional_List__c = true
        );
        insert testRule1;

        Rule_Picklist__c testRulePicklist = new Rule_Picklist__c(
            rule__c = 1,
            Rule_Seq__c = 1,
            Pump_Bundle__c = 'Test Pump',
            component__c = 'Test Component'
        );
        insert testRulePicklist;

        Bundle_Attributes__c testBundleAttribute = new Bundle_Attributes__c(
            Name = 'Test Bundle Attribute',
            Bundle_Sequence__c = 1,
            Product_Bundle__c = testProductBundle.Id
        );
        insert testBundleAttribute;
        
        test.startTest();
        opportunityProduct.bundlenameRefresh('Test Combo', 'Test Pump', 'Test Product Bundle 123');
        test.stopTest();

    }
}