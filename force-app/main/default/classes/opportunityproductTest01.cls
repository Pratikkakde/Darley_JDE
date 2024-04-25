@isTest
public class opportunityproductTest01 {
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
        Product_Bundle__c bundle = new Product_Bundle__c(Name = 'Test Bundle');
        insert bundle;
        //string bundleID = '1234567890';
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
            Required__c = 'R');
        insert bundleAttribute;
        
        
        Bundle_Attributes__c bundleAttribute2 = new Bundle_Attributes__c(
            Name = 'Test2 Bundle Attribute',
            Bundle_Sequence__c = 200,
            Default_Product__c = 'default product2',
            Attributes__c = attributename2.Id,
            Product_Bundle__c = bundle.Id,
            Is_Numeric__c = 'Y',
            Required__c = 'R');
        insert bundleAttribute2;
        
        system.debug('bundleAttribute2...'+bundleAttribute2);
        Default_products__c testDefaultProduct = new Default_products__c(
            Name = 'Test Bundle',
            Product_name__c = 'Test Default Product',
            Bundle_Sequence__c = 100,
            JDE_component__c = 'Test Component'
        );
        insert testDefaultProduct;
        
        Default_products__c testDefaultProduct2 = new Default_products__c(
            Name = 'Test Bundle',
            Product_name__c = 'Test Default Product',
            Bundle_Sequence__c = 200,
            JDE_component__c = 'Test Component2'
        );
        insert testDefaultProduct2;
        
        test.startTest();
        opportunityProduct.reqBundle(bundle.Id);
        test.stopTest();
    }
    // for main optional Bundle........................................................................................
    @isTest
    public static void optBundleTest(){
        Product_Bundle__c bundle = new Product_Bundle__c(Name = 'Test Bundle');
        insert bundle;
        //string bundleID = '1234567890';
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
            Required__c = 'R');
        insert bundleAttribute2;
        
        system.debug('bundleAttribute2...'+bundleAttribute2);
        Default_products__c testDefaultProduct = new Default_products__c(
            Name = 'Test Bundle',
            Product_name__c = 'Test Default Product',
            Bundle_Sequence__c = 100,
            JDE_component__c = 'Test Component'
        );
        insert testDefaultProduct;
        
        Default_products__c testDefaultProduct2 = new Default_products__c(
            Name = 'Test Bundle',
            Product_name__c = 'Test Default Product',
            Bundle_Sequence__c = 200,
            JDE_component__c = 'Test Component2'
        );
        insert testDefaultProduct2;
        
        test.startTest();
        opportunityProduct.OptBundle(bundle.Id);
        test.stopTest();
    }
    //forThenLogic method................................................................................
    @isTest
    public static void forThenLogicTest(){
        Product_Bundle__c testProductBundle = new Product_Bundle__c(Name = 'Test Pump');
        insert testProductBundle;
        Product2 p = new Product2(Name='STD ASSY 11/4AGE13V-TWIN Configurator');//,RecordTypeId='Equipment Products'
        insert p;
        
        Product_Bundle_Rule_Engine__c forAndRule = new Product_Bundle_Rule_Engine__c(
            Rule__c = 2,
            Rule_Seq__c = 1,
            Pump__c = testProductBundle.Name,
            Product__c = p.Id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'Test Component',
            Logic__c = 'if',//or And
            Component_Type__c = 'Test Type',
            Logic_Releationship__c = 'EQ',
            Is_Conditional_List__c = false,
            Is_Blank__c = false
        );
        insert forAndRule;
        
        Rule_Picklist__c testPicklist = new Rule_Picklist__c(
            Rule__c = 2,
            Rule_Seq__c = 1,
            Pump_Bundle__c = 'Test Pump',
            Bundle_Sequence__c = 1,
            Component__c = 'Test Component',
            Component_Type__c = 'Test Type'
        );
        insert testPicklist;
        
        Default_products__c testDefaultProduct = new Default_products__c(
            Name = 'Test Pump',
            Product_name__c = 'Test Default Product',
            Bundle_Sequence__c = 1,
            JDE_component__c = 'Test Component',
            Component_Type__c = 'Test Type'
        );
        insert testDefaultProduct;
        
        Product_Bundle_Rule_Engine__c forNERule = new Product_Bundle_Rule_Engine__c(
            Rule__c = 2,
            Rule_Seq__c = 1,
            Pump__c = testProductBundle.Name,
            Product__c = p.Id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'Test Component',
            Logic__c = 'if',//or And
            Component_Type__c = 'Test Type',
            Logic_Releationship__c = 'NE',
            Is_Conditional_List__c = false,
            Is_Blank__c = false
        );
        insert forNERule;
        //again insert default product
        Default_products__c fromDefault = new Default_products__c(
            Name = 'Test Pump',
            Product_name__c = 'Test Default Product',
            Bundle_Sequence__c = 1,
            JDE_component__c = 'Test Component',
            Component_Type__c = 'Test Type'
        );
        insert fromDefault;
        
        Rule_Picklist__c secondForRule = new Rule_Picklist__c(
            Rule__c = 2,
            Rule_Seq__c = 1,
            Pump_Bundle__c = 'Test Pump',
            product__c = p.id, 
            Bundle_Sequence__c = 1,
            Component__c = 'Test Component',
            Component_Type__c = 'Test Type'
        );
        insert secondForRule;
        
        Product_Bundle_Rule_Engine__c thenList = new Product_Bundle_Rule_Engine__c(
            Rule__c = 2,
            Rule_Seq__c = 1,
            Pump__c = testProductBundle.Name,
            Product__c = p.Id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'Test Component',
            Logic__c = 'And',
            Component_Type__c = 'Test Type',
            Logic_Releationship__c = 'EQ',
            Is_Conditional_List__c = true,
            Is_Blank__c = false
        );
        insert thenList;
        //productBundleName
        Bundle_Attributes__c ProductBundleName = new Bundle_Attributes__c(
            name = 'Bundle Attri', 
            Bundle_Sequence__c = 1, 
            Product_Bundle__c = testProductBundle.Id
        );
        insert ProductBundleName;
        
        String stringBundleCode = '[{"key":"1  REQUIRED PARTS_ 1.5AGE 2023","value":"KD00005"},{"key":"25  WARRANTY_ 1.5AGE 2023","value":"WARR3"}]';
        
        Test.startTest();
        // Call the method to be tested
        opportunityProduct.forThenLogic('Test ComboName','Test Pump','1 TestBundle', stringBundlecode);
        Test.stopTest();  
        
    }    
    //forThenLogictest2 method with else condition
    @isTest
    public static void forThenLogicTest2(){
        Product_Bundle__c testProductBundle = new Product_Bundle__c(Name = 'Test Pump');
        insert testProductBundle;
        Product2 p = new Product2(Name='STD ASSY 11/4AGE13V-TWIN Configurator');//,RecordTypeId='Equipment Products'
        insert p;
        
        Product_Bundle_Rule_Engine__c forAndRule = new Product_Bundle_Rule_Engine__c(
            Rule__c = 2,
            Rule_Seq__c = 1,
            Pump__c = testProductBundle.Name,
            Product__c = p.Id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'KD00005',
            Logic__c = 'if',//or And
            Component_Type__c = 'Product',
            Logic_Releationship__c = 'EQ',
            Is_Conditional_List__c = false,
            Is_Blank__c = false
        );
        insert forAndRule;
        
        Rule_Picklist__c testPicklist = new Rule_Picklist__c(
            Rule__c = 2,
            Rule_Seq__c = 1,
            Pump_Bundle__c = 'Test Pump',
            Bundle_Sequence__c = 1,
            Component__c = 'Test Component',
            Component_Type__c = 'Product'
        );
        insert testPicklist;
        
        Default_products__c testDefaultProduct = new Default_products__c(
            Name = 'Test Pump',
            Product_name__c = 'Test Default Product',
            Bundle_Sequence__c = 1,
            JDE_component__c = 'KD00005',
            Component_Type__c = 'Product'
        );
        insert testDefaultProduct;
        
        Product_Bundle_Rule_Engine__c forNERule = new Product_Bundle_Rule_Engine__c(
            Rule__c = 2,
            Rule_Seq__c = 1,
            Pump__c = testProductBundle.Name,
            Product__c = p.Id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'KD00005',
            Logic__c = 'if',//or And
            Component_Type__c = 'Product',
            Logic_Releationship__c = 'NE',
            Is_Conditional_List__c = false,
            Is_Blank__c = false
        );
        insert forNERule;
        //again insert default product
        Default_products__c fromDefault = new Default_products__c(
            Name = 'Test Pump',
            Product_name__c = 'Test Default Product',
            Bundle_Sequence__c = 1,
            JDE_component__c = 'KD00005',
            Component_Type__c = 'Product'
        );
        insert fromDefault;
        
        Rule_Picklist__c secondForRule = new Rule_Picklist__c(
            Rule__c = 2,
            Rule_Seq__c = 1,
            Pump_Bundle__c = 'Test Pump',
            product__c = p.id, 
            Bundle_Sequence__c = 1,
            Component__c = 'KD00005',
            Component_Type__c = 'Product'
        );
        insert secondForRule;
        
        Product_Bundle_Rule_Engine__c thenList = new Product_Bundle_Rule_Engine__c(
            Rule__c = 2,
            Rule_Seq__c = 1,
            Pump__c = testProductBundle.Name,
            Product__c = p.Id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'KD00005',
            Logic__c = 'Then',
            Component_Type__c = 'Product',
            Logic_Releationship__c = 'NE',
            Is_Conditional_List__c = false,
            Is_Blank__c = false
        );
        insert thenList;
        //productBundleName
        Bundle_Attributes__c ProductBundleName = new Bundle_Attributes__c(
            name = 'Test Pump', 
            Bundle_Sequence__c = 1, 
            Product_Bundle__c = testProductBundle.Id
        );
        insert ProductBundleName;
        
        String stringBundleCode = '[{"key":"1  Test Pump","value":"KD00005"},{"key":"25  WARRANTY_ 1.5AGE 2023","value":"WARR3"}]';
        
        Test.startTest();
        // Call the method to be tested
        opportunityProduct.forThenLogic('Test ComboName','Test Pump','1 TestBundle', stringBundlecode);
        Test.stopTest(); 
    }
    
    //Test method for bundlenamereferesh.......................................................................
    @isTest public static void bundlenameRefreshTest(){
        Product_Bundle__c testProductBundle = new Product_Bundle__c(Name = 'Test Pump');
        insert testProductBundle;
        Product2 p = new Product2(Name='STD ASSY 11/4AGE13V-TWIN Configurator');
        insert p;
        
        Product_Bundle_Rule_Engine__c forandRule = new Product_Bundle_Rule_Engine__c(
            Rule__c = 2,
            Rule_Seq__c = 1,
            Pump__c = testProductBundle.Name,
            Product__c = p.Id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'KD00005',//comboName
            Logic__c = 'if',
            Component_Type__c = 'Product',
            Logic_Releationship__c = 'EQ',
            Is_Conditional_List__c = true,
            Is_Blank__c = false
        );
        insert forandRule;
        
        Rule_Picklist__c secondForRule = new Rule_Picklist__c(
            Rule__c = 2,
            Rule_Seq__c = 1,
            Pump_Bundle__c = 'Test Pump',
            product__c = p.id, 
            Bundle_Sequence__c = 1,
            Component__c = 'KD00005',
            Component_Type__c = 'Product'
        );
        insert secondForRule;
        
        Product_Bundle_Rule_Engine__c forNERule = new Product_Bundle_Rule_Engine__c(
            Rule__c = 2,
            Rule_Seq__c = 1,
            Pump__c = testProductBundle.Name,
            Product__c = p.Id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'KD000051',
            Logic__c = 'if',
            Component_Type__c = 'Product',
            Logic_Releationship__c = 'NE',
            Is_Conditional_List__c = false,
            Is_Blank__c = false
        );
        insert forNERule;
        
        Product_Bundle_Rule_Engine__c togetBS = new Product_Bundle_Rule_Engine__c(
            Rule__c = 2,
            Rule_Seq__c = 1,
            Pump__c = testProductBundle.Name,
            Product__c = p.Id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'KD00005',
            Logic__c = 'Then'
            
        );
        insert togetBS;
        
        test.startTest();
        opportunityProduct.bundlenameRefresh('KD00005', testProductBundle.Name,'1 Test Pump' );
        test.stopTest();
    }
    @isTest public static void bundlenameRefreshTest2(){
        Product_Bundle__c testProductBundle = new Product_Bundle__c(Name = 'Test Pump');
        insert testProductBundle;
        Product2 p = new Product2(Name='STD ASSY 11/4AGE13V-TWIN Configurator');
        insert p;
        
        Product_Bundle_Rule_Engine__c forandRule = new Product_Bundle_Rule_Engine__c(
            Rule__c = 2,
            Rule_Seq__c = 1,
            Pump__c = testProductBundle.Name,
            Product__c = p.Id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'KD00005',//comboName
            Logic__c = 'if',
            Component_Type__c = 'Product',
            Logic_Releationship__c = 'EQ',
            Is_Conditional_List__c = true,
            Is_Blank__c = false
        );
        insert forandRule;
        
        Rule_Picklist__c secondForRule = new Rule_Picklist__c(
            Rule__c = 2,
            Rule_Seq__c = 1,
            Pump_Bundle__c = 'Test Pump1',
            product__c = p.id, 
            Bundle_Sequence__c = 1,
            Component__c = 'KD000051',
            Component_Type__c = 'Product'
        );
        insert secondForRule;
        
        Product_Bundle_Rule_Engine__c forandRuleFromBlank = new Product_Bundle_Rule_Engine__c(
            Rule__c = 2,
            Rule_Seq__c = 1,
            Pump__c = testProductBundle.Name,
            Product__c = p.Id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'KD00005',//comboName
            Logic__c = 'if',
            Component_Type__c = 'Product',
            Logic_Releationship__c = 'NE',
            Is_Conditional_List__c = true,
            Is_Blank__c = true
        );
        insert forandRuleFromBlank;
        
        test.startTest();
        opportunityProduct.bundlenameRefresh('KD00005', testProductBundle.Name,'1 Test Pump' );
        test.stopTest();
    }
    //forThenLogicPriceRule..................................................................................................
    @isTest
    public static void forThenLogicPriceRuleTest(){
        Product2 p = new Product2(Name='TestProduct');
        insert p;
        PriceBook2 pBook = new PriceBook2(Name = 'Pump Price Book');
        insert pBook;
        
        PricebookEntry ruleOnePrice = new PricebookEntry(
            // Product2.Name,
            Product2Id = p.Id, 
            UnitPrice = 12, 
            Pricebook2Id = pBook.Id
            // ProductCode = 'KR00514'
        );
        
        Price_rule_obj__c selectedRule = new Price_rule_obj__c(
            JDE_Component__c = 'KR00514', 
            Rule__c = 2, 
            Bundle_sequence__c =1,
            Pump__c = 'Test Pump'// pumpName
        );
        insert selectedRule;
        
        Price_rule_obj__c accToRule = new Price_rule_obj__c(
            JDE_Component__c = 'KR00514', 
            Rule__c = 2, 
            Bundle_sequence__c =1,
            Logic_Relationship__c ='NE',
            Pump__c = 'Test Pump'// pumpName
        );
        insert accToRule;
        
        Rule_Picklist__c forRuleType = new Rule_Picklist__c(
            //name, 
            Bundle_Sequence__c = 1, 
            Component__c = 'KR00514', 
            Product__c = p.id, 
            //Product__r.name, 
            Pump_Bundle__c = 'Test Pump', 
            Rule__c = 2, 
            Rule_Type__c = 'Rule test', 
            Component_Type__c = 'Product'
        );
        Price_rule_obj__c byPriceRuleIf = new Price_rule_obj__c(
            JDE_Component__c = 'KR00514', 
            Rule__c = 2, 
            Bundle_sequence__c =1,
            Logic_Relationship__c ='NE',
            Logic__c = 'if',
            Product__c =p.Id,
            Pump__c = 'Test Pump',// pumpName
            Component_Type__c='Product'
        );
        insert byPriceRuleIf;
        
        //parameters
        String comboName = 'KR00514';
        String Pumpname = 'Test Pump';
        String stringPriceproduct = '[{"key":"1  Test Pump","value":"KR00514"},{"key":"25  WARRANTY_ 1.5AGE 2023","value":"WARR3"}]';    
        String productBundleNameString = '1 Test Pump';
        test.startTest();
        opportunityProduct.forThenLogicPriceRule(comboName, Pumpname, stringPriceproduct, productBundleNameString);
        test.stopTest();
    }
    
    @isTest
    public static void forThenLogicPriceRuleTest2(){
        Product2 p = new Product2(Name='TestProduct');
        insert p;
        PriceBook2 pBook = new PriceBook2(Name = 'Pump Price Book');
        insert pBook;
        
        PricebookEntry ruleOnePrice = new PricebookEntry(
            // Product2.Name,
            Product2Id = p.Id, 
            UnitPrice = 12, 
            Pricebook2Id = pBook.Id
            // ProductCode = 'KR00514'
        );
        
        Price_rule_obj__c selectedRule = new Price_rule_obj__c(
            JDE_Component__c = '*VALUES', 
            Rule__c = 2, 
            Bundle_sequence__c =1,
            Pump__c = 'Test Pump'// pumpName
        );
        insert selectedRule;
        
        Price_rule_obj__c accToRule = new Price_rule_obj__c(
            JDE_Component__c = '*VALUES', 
            Rule__c = 2, 
            Bundle_sequence__c =1,
            Logic_Relationship__c ='EQ',
            Pump__c = 'Test Pump'// pumpName
        );
        insert accToRule;
        
        Rule_Picklist__c forRuleType = new Rule_Picklist__c(
            //name, 
            Bundle_Sequence__c = 1, 
            Component__c = '*VALUES', 
            Product__c = p.id, 
            //Product__r.name, 
            Pump_Bundle__c = 'Test Pump', 
            Rule__c = 2, 
            Rule_Type__c = 'Rule test', 
            Component_Type__c = 'Product'
        );
        Price_rule_obj__c byPriceRuleIf = new Price_rule_obj__c(
            JDE_Component__c = '*VALUES', 
            Rule__c = 2, 
            Bundle_sequence__c =1,
            Logic_Relationship__c ='NE',
            Logic__c = 'if',
            Product__c =p.Id,
            Pump__c = 'Test Pump',// pumpName
            Component_Type__c='Product'
        );
        insert byPriceRuleIf;
        
        //parameters
        String comboName = '*VALUES';
        String Pumpname = 'Test Pump';
        String stringPriceproduct = '[{"key":"1  Test Pump","value":"*VALUES"},{"key":"25  WARRANTY_ 1.5AGE 2023","value":"WARR3"}]';    
        String productBundleNameString = '1 Test Pump';
        test.startTest();
        opportunityProduct.forThenLogicPriceRule(comboName, Pumpname, stringPriceproduct, productBundleNameString);
        test.stopTest();
    }
    //test method for getAllSummary method
    @isTest
    public static void getAllSummaryTest(){
        Product_Bundle__c testProductBundle = new Product_Bundle__c(Name = 'Test Pump');
        insert testProductBundle;
        
        Bundle_Attributes__c bundleAtt = new Bundle_Attributes__c(
            name = 'Test Pump', 
            Bundle_Sequence__c = 1, 
            Product_Bundle__c = testProductBundle.Id
        );
        insert bundleAtt;
        
        Default_products__c codeNameByDefault = new Default_products__c(
            Name = 'Test Pump',
            Product_name__c = 'Test Default Product',
            Bundle_Sequence__c = 1,
            JDE_component__c = 'KD00005',//codeName
            Component_Type__c = 'Product',
            Price__c = 100
        );
        insert codeNameByDefault;
        Product2 newProduct = new Product2(
            Name = 'Test Product'
        );
        insert newProduct;
        Price_rule_obj__c byPriceRuleOne = new Price_rule_obj__c(
            Pump__c= 'Test Pump', 
            Component_Type__c='Product', 
            Bundle_sequence__c =1, 
            Logic__c = 'if',
            JDE_Component__c = '*VALUES', 
            Logic_Relationship__c = 'EQ', 
            Product__c=newProduct.id, 
            Rule__c = 1       
        );
        insert byPriceRuleOne;
        
        Price_rule_obj__c byPriceRuleIf = new Price_rule_obj__c(
            Pump__c= 'Test Pump', 
            Component_Type__c='Product', 
            Bundle_sequence__c =1, 
            Logic__c = 'if',
            JDE_Component__c = '*VALUES', 
            Logic_Relationship__c = 'EQ', 
            Product__c=newProduct.id, 
            Rule__c = 3        
        );
        insert byPriceRuleIf;
        
        Rule_Picklist__c toGetNamelist = new Rule_Picklist__c(
            //name = 'Rule 1', 
            Bundle_Sequence__c = 1, 
            Component__c = 'KD00005', 
            Product__c = newProduct.id, 
            //Product__r.name, 
            Pump_Bundle__c = 'Test Pump', 
            Rule__c = 3, 
            Rule_Type__c = 'Price', 
            Component_Type__c = 'Product'
        );
        insert toGetNamelist;
        
        //parameter
        String chosenArray = '[{"key":"1  Test Pump","value":"KD00005"},{"key":"25  WARRANTY_ 1.5AGE 2023","value":"WARR3"}]';
        test.startTest();
        opportunityProduct.getAllsummary(testProductBundle.Id,chosenArray);
        test.stopTest();      
        
    }
    @isTest
    public static void getAllSummaryTest2(){
        Product_Bundle__c testProductBundle = new Product_Bundle__c(Name = 'Test Pump');
        insert testProductBundle;
        
        Bundle_Attributes__c bundleAtt = new Bundle_Attributes__c(
            name = 'Test Pump', 
            Bundle_Sequence__c = 1, 
            Product_Bundle__c = testProductBundle.Id
        );
        insert bundleAtt;
        
        Default_products__c codeNameByDefault = new Default_products__c(
            Name = 'Test Pump',
            Product_name__c = 'Test Default Product',
            Bundle_Sequence__c = 1,
            JDE_component__c = 'KD00005',//codeName
            Component_Type__c = 'Product',
            Price__c = 100
        );
        insert codeNameByDefault;
        Product2 newProduct = new Product2(
            Name = 'Test Product'
        );
        insert newProduct;
        Price_rule_obj__c byPriceRuleOne = new Price_rule_obj__c(
            Pump__c= 'Test Pump', 
            Component_Type__c='Product', 
            Bundle_sequence__c =1, 
            Logic__c = 'if',
            JDE_Component__c = '*VALUES', 
            Logic_Relationship__c = 'EQ', 
            Product__c=newProduct.id, 
            Rule__c = 1       
        );
        insert byPriceRuleOne;
        Product_Bundle_Rule_Engine__c forCode = new Product_Bundle_Rule_Engine__c(
            //name, 
            pump__c = 'Test Pump', 
            Product_Bundle__c=testProductBundle.Id, 
            Bundle_Sequence__c = 1, 
            JDE_Component__c = 'KL00987', 
            Logic__c = 'if', 
            Component_Type__c = ' product', 
            Is_Conditional_List__c =true, 
            rule__c = 1
        );
        insert forCode;
        
        Price_rule_obj__c byPriceRuleIf = new Price_rule_obj__c(
            Pump__c= 'Test Pump', 
            Component_Type__c='Product', 
            Bundle_sequence__c =1, 
            Logic__c = 'if',
            JDE_Component__c = '*Values12', 
            Logic_Relationship__c = 'NE', 
            Product__c=newProduct.id, 
            Rule__c = 3        
        );
        insert byPriceRuleIf;
        
        Rule_Picklist__c toGetNamelist3 = new Rule_Picklist__c(
            //name = 'Rule 1', 
            Bundle_Sequence__c = 1, 
            Component__c = 'KD00006', 
            Product__c = newProduct.id, 
            //Product__r.name, 
            Pump_Bundle__c = 'Test Pump'
            /*Rule__c = 3, 
Rule_Type__c = 'Price', 
Component_Type__c = 'Product'*/
        );
        insert toGetNamelist3;
        
        //parameter
        String chosenArray = '[{"key":"1  Test Pump","value":"KD00005"},{"key":"25  WARRANTY_ 1.5AGE 2023","value":"WARR3"}]';
        test.startTest();
        opportunityProduct.getAllsummary(testProductBundle.Id,chosenArray);
        test.stopTest();      
        
    }
    
    @isTest
    public static void getAllSummaryTest3(){
        Product_Bundle__c testProductBundle = new Product_Bundle__c(Name = 'Test Pump');
        insert testProductBundle;
        
        Bundle_Attributes__c bundleAtt = new Bundle_Attributes__c(
            name = 'Test Pump', 
            Bundle_Sequence__c = 1, 
            Product_Bundle__c = testProductBundle.Id
        );
        insert bundleAtt;
        
        Default_products__c codeNameByDefault = new Default_products__c(
            Name = 'Test Pump',
            Product_name__c = 'Test Default Product',
            Bundle_Sequence__c = 1,
            JDE_component__c = 'KD00005',//codeName
            Component_Type__c = 'Product',
            Price__c = 100
        );
        insert codeNameByDefault;
        Product2 newProduct = new Product2(
            Name = 'Test Product'
        );
        insert newProduct;
        Price_rule_obj__c byPriceRuleOne = new Price_rule_obj__c(
            Pump__c= 'Test Pump', 
            Component_Type__c='Product', 
            Bundle_sequence__c =1, 
            Logic__c = 'if',
            JDE_Component__c = '*VALUES', 
            Logic_Relationship__c = 'EQ', 
            Product__c=newProduct.id, 
            Rule__c = 1       
        );
        insert byPriceRuleOne;
        
        Price_rule_obj__c byPriceRuleIf = new Price_rule_obj__c(
            Pump__c= 'Test Pump', 
            Component_Type__c='Product', 
            Bundle_sequence__c =1, 
            Logic__c = 'if',
            JDE_Component__c = '*VALUES', 
            Logic_Relationship__c = 'NE', 
            Product__c=newProduct.id, 
            Rule__c = 3        
        );
        insert byPriceRuleIf;
        
        //parameter
        String chosenArray = '[{"key":"1  Test Pump","value":"KD00005"},{"key":"25  WARRANTY_ 1.5AGE 2023","value":"WARR3"}]';
        test.startTest();
        opportunityProduct.getAllsummary(testProductBundle.Id,chosenArray);
        test.stopTest();      
        
    }
    
    //createQuote.................................................................................................................
    @isTest
    public static void createQuoteTest(){
        //id pricebookId = Test.getStandardPricebookId();
        pricebook2 pumppricebook = new pricebook2(
            IsActive = true ,
            Description = 'Pump Price Book', 
            //IsStandard = false, 
            //Id, 
            Name = 'Pump Price Book'
            // SystemModstamp = '2023-03-13T19:43:47.000+0000'
        );
        insert pumppricebook;
        Product2 newProduct = new Product2(
            Name = '1.25AGE 2023'
        );
        insert newProduct;
        
        /*List<PriceBookEntry> entryList = new List<PriceBookEntry>();
PriceBookEntry pEntries = new PriceBookEntry(product2Id = newProduct.id,pricebook2Id = pricebookId,Unitprice = 3);
entryList.add(pEntries);
entryList.add(new PriceBookEntry(product2Id = newProduct.id,pricebook2Id = pumppricebook.Id,Unitprice = 3));
insert entryList;*/
        //parameters
        String Opportunityid = '0062E00001S5heXQAR';
        String maincmp = '1.25AGE 2023';
        String requireddata ='[{"Bundleattribute":"WARRANTY_ 1.25AGE 2023", "bundleid":"a3B01000001kvGiEAI","productId":"0062E00001S5heXQAR", "productName":"3 YR Std Warranty", "componentType":"Attribute", "discount":"0", "finalprice":"0", "price":"0", "productcode":"WARR3", "quantity":"2"}]' ;
        Decimal totalDiscount = 5;
        Decimal totalPrice = 1260;
        
        test.startTest();
        opportunityProduct.createQuote(Opportunityid, maincmp, requireddata, totalDiscount, totalPrice);
        test.stopTest();
    }
    
}