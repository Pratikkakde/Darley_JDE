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
    @isTest
    static void testReqBundle() {
        // Create test data for Product Bundle
        Product_Bundle__c bundle = new Product_Bundle__c(Name = 'Test Bundle');
        insert bundle;
        system.debug('bundle-->'+ bundle);

        Attributes__c attributename = new Attributes__c(Name = 'test attribute name');
        insert attributename;
		system.debug('attributename-->'+ attributename);
        
        List<Attributes__c> attName = [SELECT Id FROM Attributes__c];
        List<Product_Bundle__c> proBundle = [SELECT Id FROM Product_Bundle__c];
        Bundle_Attributes__c bundleAttribute = new Bundle_Attributes__c(
            name = 'test bundle att 01',
            Bundle_Sequence__c = 100,
            Attributes_text__c = 'test attribute name',
            Product_Bundle_Text__c = 'Test Bundle',
            Default_Product__c = 'default product',
            Attributes__c = attName[0].id,
            Product_Bundle__c = bundle.Id,
            Is_Numeric__c = 'N',
            Required__c = 'R'
        );
        insert bundleAttribute;
        system.debug('bundleAttribute-->'+ bundleAttribute);
        
        Bundle_Attributes__c bundleAttribute1 = new Bundle_Attributes__c(
            name = 'test bundle att 0111',
            Bundle_Sequence__c = 5,
            Attributes_text__c = 'test attribute name',
            Product_Bundle_Text__c = 'Test Bundle',
            Default_Product__c = 'default product',
            Attributes__c = attName[0].id,
            Product_Bundle__c = bundle.Id,
            Is_Numeric__c = 'Y',
            Required__c = 'R'
        );
        insert bundleAttribute1;
        system.debug('bundleAttribute1-->'+ bundleAttribute1);
        
         Bundle_Attributes__c bundleAttribute3 = new Bundle_Attributes__c(
            name = 'test bundle att 33',
            Bundle_Sequence__c = 120,
            Attributes_text__c = 'test attribute name',
            Product_Bundle_Text__c = 'Test Bundle',
            Default_Product__c = 'default product',
            Attributes__c = attName[0].id,
            Product_Bundle__c = bundle.Id,
            Is_Numeric__c = 'Y',
            Required__c = 'R'
        );
        insert bundleAttribute3;
        system.debug('bundleAttribute1-->'+ bundleAttribute3);
        
        Default_products__c testDefaultProduct = new Default_products__c(
            Name = 'Test Bundle',
            Product_name__c = 'Test Default Product',
            Bundle_Sequence__c = 100,
            JDE_component__c = 'Test Component'
        );
        insert testDefaultProduct;
        system.debug('testDefaultProduct-->'+ testDefaultProduct);
        
        Id pumpId = proBundle[0].Id;
        System.debug('pumpId --> '+pumpId);
        list<Bundle_Attributes__c>bundleName =[SELECT id, name, Bundle_Sequence__c,Default_Product__c, Product_Bundle__c, Is_Numeric__c 
                                               from Bundle_Attributes__c 
                                                where (NOT Attributes__r.name LIKE '%QTY') AND Product_Bundle__c =: pumpId AND Required__c= 'R' ORDER BY  Bundle_Sequence__c];
        System.debug('bundleName --> '+bundleName[0].Product_Bundle__c);
        
        Test.startTest();
        // Call reqBundle method
        List<opportunityProduct.bundleWrapper> result = opportunityProduct.reqBundle(pumpId);
        Test.stopTest();
    }
         @isTest
    static void testReqBundle2() {
        // Create test data for Product Bundle
        Product_Bundle__c bundle = new Product_Bundle__c(Name = 'Test Bundle');
        insert bundle;
        system.debug('bundle-->'+ bundle);

        Attributes__c attributename = new Attributes__c(Name = 'test attribute name');
        insert attributename;
		system.debug('attributename-->'+ attributename);
        
        List<Attributes__c> attName = [SELECT Id FROM Attributes__c];
        List<Product_Bundle__c> proBundle = [SELECT Id FROM Product_Bundle__c];
        Bundle_Attributes__c bundleAttribute = new Bundle_Attributes__c(
            name = 'test bundle att 01',
            Bundle_Sequence__c = 100,
            Attributes_text__c = 'test attribute name',
            Product_Bundle_Text__c = 'Test Bundle',
            Default_Product__c = 'default product',
            Attributes__c = attName[0].id,
            Product_Bundle__c = bundle.Id,
            Is_Numeric__c = 'Y',
            Required__c = 'R'
        );
        insert bundleAttribute;
        system.debug('bundleAttribute-->'+ bundleAttribute);
        
        Bundle_Attributes__c bundleAttribute1 = new Bundle_Attributes__c(
            name = 'test bundle att 0111',
            Bundle_Sequence__c = 5,
            Attributes_text__c = 'test attribute name',
            Product_Bundle_Text__c = 'Test Bundle2',
            Default_Product__c = 'default product',
            Attributes__c = attName[0].id,
            Product_Bundle__c = bundle.Id,
            Is_Numeric__c = 'N',
            Required__c = 'R'
        );
        insert bundleAttribute1;
        system.debug('bundleAttribute1-->'+ bundleAttribute1);
        
         Bundle_Attributes__c bundleAttribute3 = new Bundle_Attributes__c(
            name = 'test bundle att 33',
            Bundle_Sequence__c = 120,
            Attributes_text__c = 'test attribute name',
            Product_Bundle_Text__c = 'Test Bundle',
            Default_Product__c = 'default product2',
            Attributes__c = attName[0].id,
            Product_Bundle__c = bundle.Id,
            Is_Numeric__c = 'Y',
            Required__c = 'R'
        );
        insert bundleAttribute3;
        system.debug('bundleAttribute1-->'+ bundleAttribute3);
        
        Default_products__c testDefaultProduct = new Default_products__c(
            Name = 'Test Bundle',
            Product_name__c = 'Test Default Product',
            Bundle_Sequence__c = 100,
            JDE_component__c = 'Test Component'
        );
        insert testDefaultProduct;
        Default_products__c testDefaultProduct2 = new Default_products__c(
            Name = 'Test Bundle2',
            Product_name__c = 'Test Default Product',
            Bundle_Sequence__c = 100,
            JDE_component__c = 'Test Component'
        );
        insert testDefaultProduct2;
        system.debug('testDefaultProduct-->'+ testDefaultProduct);
        
        Id pumpId = proBundle[0].Id;
        System.debug('pumpId --> '+pumpId);
        list<Bundle_Attributes__c>bundleName =[SELECT id, name, Bundle_Sequence__c,Default_Product__c, Product_Bundle__c, Is_Numeric__c 
                                               from Bundle_Attributes__c 
                                                where (NOT Attributes__r.name LIKE '%QTY') AND Product_Bundle__c =: pumpId AND Required__c= 'R' ORDER BY  Bundle_Sequence__c];
        System.debug('bundleName --> '+bundleName[0].Product_Bundle__c);
        
        Test.startTest();
        // Call reqBundle method
        List<opportunityProduct.bundleWrapper> result = opportunityProduct.reqBundle(pumpId);
        Test.stopTest();
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
        
        Bundle_Attributes__c bundleAttribute3 = new Bundle_Attributes__c(
            name = 'test bundle att 01',
            Bundle_Sequence__c = 100,
            Attributes_text__c = 'test attribute name',
            Product_Bundle_Text__c = 'Test Bundle',
            Default_Product__c = 'default product',
            Attributes__c = attributename2.Id,
            Product_Bundle__c = bundle.Id,
            Is_Numeric__c = 'Y',
            Required__c = 'O'
        );
        insert bundleAttribute3;
        
        Bundle_Attributes__c bundleAttribute4 = new Bundle_Attributes__c(
            name = 'test bundle att 02',
            Bundle_Sequence__c = 101,
            Attributes_text__c = 'test attribute name',
            Product_Bundle_Text__c = 'Test Bundle',
            Default_Product__c = 'default product',
            Attributes__c = attributename2.Id,
            Product_Bundle__c = bundle.Id,
            Is_Numeric__c = 'N',
            Required__c = 'O'
        );
        insert bundleAttribute4;
        
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
            Component__c = 'KD00005',
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
        
        /*
         * SELECT id,Product_name__c, name, Bundle_Sequence__c, JDE_component__c, Component_Type__c FROM Default_products__c 
                                                  WHERE name =: pumpName ORDER BY JDE_component__c
         */
        Default_products__c fromDefault2 = new Default_products__c(
            Name = 'Test Pump',
            Product_name__c = 'Test Default Product',
            Bundle_Sequence__c = 1,
            JDE_component__c = 'KD00005',
            Component_Type__c = 'Test Type'
        );
        insert fromDefault2;
        
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
        /*SELECT id, name, rule__c, Rule_Seq__c, Pump_Bundle__c ,product__r.name, Bundle_Sequence__c, component__c, Component_Type__c
                                                from rule_picklist__c WHERE Pump_Bundle__c=:Pumpname AND rule__c IN: onlyRule ORDER BY Rule_Seq__c
         */
        Rule_Picklist__c thirdForRule = new Rule_Picklist__c(
            rule__c = 69,
            Rule_Seq__c = 1,
            Pump_Bundle__c = 'Test Pump',
            product__c = p.id,
            Bundle_Sequence__c = 1,
            component__c ='Test ComboName' ,
            Component_Type__c='Test Type'
        );
        insert thirdForRule;
        
        /*
         * SELECT id,rule__c, Rule_Seq__c, Pump_Bundle__c ,product__r.name, Bundle_Sequence__c, component__c, Component_Type__c
                                                 from rule_picklist__c WHERE component__c =:comboName  AND Pump_Bundle__c=:Pumpname AND Bundle_Sequence__c =: bunsequencetoLimit ORDER BY component__c
		*/
        Rule_Picklist__c forthForRule = new Rule_Picklist__c(
            rule__c = 69,
            Rule_Seq__c = 1,
            Pump_Bundle__c = 'Test Pump',
            product__c = p.id,
            Bundle_Sequence__c = 1,
            component__c ='Test Component' ,
            Component_Type__c='Test Type'
        );
        insert forthForRule;
        
        Product_Bundle_Rule_Engine__c thenList = new Product_Bundle_Rule_Engine__c(
            Rule__c = 2,
            Rule_Seq__c = 1,
            Pump__c = testProductBundle.Name,
            Product__c = p.Id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'Test Component1',
            Logic__c = 'And',
            Component_Type__c = 'Test Type',
            Logic_Releationship__c = 'EQ',
            Is_Conditional_List__c = true,
            Is_Blank__c = false
        );
        insert thenList;
        
        
        
        /*SELECT id, name,rule__c, Rule_Seq__c, pump__c, product__r.name, Product_Bundle__c, Bundle_Sequence__c, JDE_Component__c, Logic__c, Component_Type__c, 
                                                       Is_Conditional_List__c, Is_Blank__c, Logic_Releationship__c FROM Product_Bundle_Rule_Engine__c
                                                       WHERE rule__c IN: onlyRule AND pump__c=: Pumpname ORDER BY Rule_Seq__c
        */
        
        Product_Bundle_Rule_Engine__c thenList2 = new Product_Bundle_Rule_Engine__c(
        	rule__c = 69,
            Rule_Seq__c = 1,
            pump__c = 'Test Pump',
            product__c = p.Id,
            Product_Bundle__c = testProductBundle.id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = '*BLANK',
            Logic__c = 'And',
            Component_Type__c = 'Test Type', 
            Is_Conditional_List__c = false,
            Is_Blank__c = true,
            Logic_Releationship__c = 'NE'
        );
        insert thenList2;
        
        Product_Bundle_Rule_Engine__c thenList3 = new Product_Bundle_Rule_Engine__c(
        	rule__c = 69,
            Rule_Seq__c = 1,
            pump__c = 'Test Pump',
            product__c = p.Id,
            Product_Bundle__c = testProductBundle.id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'Test Component',
            Logic__c = 'And',
            Component_Type__c = 'Test Type', 
            Is_Conditional_List__c = false,
            Is_Blank__c = true,
            Logic_Releationship__c = 'EQ'
        );
        insert thenList3;
        
        Product_Bundle_Rule_Engine__c thenList4 = new Product_Bundle_Rule_Engine__c(
        	rule__c = 69,
            Rule_Seq__c = 1,
            pump__c = 'Test Pump',
            product__c = p.Id,
            Product_Bundle__c = testProductBundle.id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'Test Component',
            Logic__c = 'And',
            Component_Type__c = 'Test Type', 
            Is_Conditional_List__c = true,
            Is_Blank__c = true,
            Logic_Releationship__c = 'EQ'
        );
        insert thenList4;
        
        Product_Bundle_Rule_Engine__c thenList5 = new Product_Bundle_Rule_Engine__c(
        	rule__c = 69,
            Rule_Seq__c = 1,
            pump__c = 'Test Pump',
            product__c = p.Id,
            Product_Bundle__c = testProductBundle.id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'Test Component',
            Logic__c = 'And',
            Component_Type__c = 'Test Type', 
            Is_Conditional_List__c = true,
            Is_Blank__c = true,
            Logic_Releationship__c = 'NE'
        );
        insert thenList5;
        
        Product_Bundle_Rule_Engine__c thenList6 = new Product_Bundle_Rule_Engine__c(
        	rule__c = 69,
            Rule_Seq__c = 1,
            pump__c = 'Test Pump',
            product__c = p.Id,
            Product_Bundle__c = testProductBundle.id,
            Bundle_Sequence__c = 1,
            //JDE_Component__c = 'Test Component',
            Logic__c = 'Then',
            Component_Type__c = 'Test Type', 
            Is_Conditional_List__c = true,
            Is_Blank__c = true,
            Logic_Releationship__c = 'NE'
        );
        insert thenList6;
        
        //productBundleName
        Bundle_Attributes__c ProductBundleName1 = new Bundle_Attributes__c(
            name = 'Bundle Attri', 
            Bundle_Sequence__c = 1, 
            Product_Bundle__c = testProductBundle.Id
        );
        insert ProductBundleName1;
        /*
         * SELECT id, name, Bundle_Sequence__c, Product_Bundle__c 
                                                       from Bundle_Attributes__c 
                                                       where Product_Bundle__c =: getProductBundleID And
                                                       Bundle_Sequence__c IN:bundleSequenceSet ORDER BY Bundle_Sequence__c

		*/
       Attributes__c attributename2 = new Attributes__c(Name = 'test attribute name2');
        insert attributename2;
        
        Bundle_Attributes__c ProductBundleName = new Bundle_Attributes__c(
            name = 'Bundle Attri', 
            Bundle_Sequence__c = 1, 
            Product_Bundle__c = testProductBundle.Id,
            Attributes_text__c = 'test attribute name2',
            Product_Bundle_Text__c = 'Test Bundle'
          
        );
        insert ProductBundleName;
          
        Bundle_Attributes__c ProductBundleName2 = new Bundle_Attributes__c(
            name = 'Bundle Attri2', 
            Bundle_Sequence__c = 1, 
            Product_Bundle__c = testProductBundle.Id,
            Attributes_text__c = 'test attribute name2',
            Product_Bundle_Text__c = 'Test Bundle'
        );
        insert ProductBundleName2;
        system.debug('testProductBundle-->'+testProductBundle);
        system.debug('testProductBundle-->'+p);
        
        
        String stringBundleCode = '[{"key":"1  REQUIRED PARTS_ 1.5AGE 2023","value":"Test Component"},{"key":"25  WARRANTY_ 1.5AGE 2023","value":"WARR3"}]';
        
        Test.startTest();
        // Call the method to be tested
        opportunityProduct.forThenLogic('Test ComboName','Test Pump','1 TestBundle', stringBundlecode);
        opportunityProduct.ThenValidate('Test ComboName','Test Pump','1 TestBundle', stringBundlecode);
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
        
         Product_Bundle_Rule_Engine__c thenList6 = new Product_Bundle_Rule_Engine__c(
        	rule__c = 69,
            Rule_Seq__c = 1,
            pump__c = 'Test Pump',
            product__c = p.Id,
            Product_Bundle__c = testProductBundle.id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'Test Component',
            Logic__c = 'Then',
            Component_Type__c = 'Test Type', 
            Is_Conditional_List__c = true,
            Is_Blank__c = true,
            Logic_Releationship__c = 'NE'
        );
        insert thenList6;
        //productBundleName
    Attributes__c attributename2 = new Attributes__c(Name = 'test attribute name2');
        insert attributename2;
        
        Bundle_Attributes__c ProductBundleName = new Bundle_Attributes__c(
            name = 'Bundle Attri', 
            Bundle_Sequence__c = 1, 
            Product_Bundle__c = testProductBundle.Id,
            Attributes_text__c = 'test attribute name2',
            Product_Bundle_Text__c = 'Test Bundle'
          
        );
        insert ProductBundleName;
          
        Bundle_Attributes__c ProductBundleName2 = new Bundle_Attributes__c(
            name = 'Bundle Attri2', 
            Bundle_Sequence__c = 1, 
            Product_Bundle__c = testProductBundle.Id,
            Attributes_text__c = 'test attribute name2',
            Product_Bundle_Text__c = 'Test Bundle'
        );
        insert ProductBundleName2;
        
        String stringBundleCode = '[{"key":"1  Test Pump","value":"KD00005"},{"key":"25  WARRANTY_ 1.5AGE 2023","value":"WARR3"}]';
        
        Test.startTest();
        // Call the method to be tested
        opportunityProduct.forThenLogic('Test ComboName','Test Pump','1 TestBundle', stringBundlecode);
        opportunityProduct.ThenValidate('Test ComboName','Test Pump','1 TestBundle', stringBundlecode);
        Test.stopTest(); 
    }
    
    ////forThenLogictest3 method with else condition------------------------------------------------------------------------------
     @isTest
    public static void forThenLogicTest3(){
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
        
        /*
         * SELECT id,Product_name__c, name, Bundle_Sequence__c, JDE_component__c, Component_Type__c FROM Default_products__c 
                                                  WHERE name =: pumpName ORDER BY JDE_component__c
         */
        Default_products__c fromDefault2 = new Default_products__c(
            Name = 'Test Pump',
            Product_name__c = 'Test Default Product',
            Bundle_Sequence__c = 1,
            JDE_component__c = 'KD00005',
            Component_Type__c = 'Test Type'
        );
        insert fromDefault2;
        
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
        /*SELECT id, name, rule__c, Rule_Seq__c, Pump_Bundle__c ,product__r.name, Bundle_Sequence__c, component__c, Component_Type__c
                                                from rule_picklist__c WHERE Pump_Bundle__c=:Pumpname AND rule__c IN: onlyRule ORDER BY Rule_Seq__c
         */
        Rule_Picklist__c thirdForRule = new Rule_Picklist__c(
            rule__c = 69,
            Rule_Seq__c = 1,
            Pump_Bundle__c = 'Test Pump',
            product__c = p.id,
            Bundle_Sequence__c = 1,
            component__c ='Test Component' ,
            Component_Type__c='Test Type'
        );
        insert thirdForRule;
        
        /*
         * SELECT id,rule__c, Rule_Seq__c, Pump_Bundle__c ,product__r.name, Bundle_Sequence__c, component__c, Component_Type__c
                                                 from rule_picklist__c WHERE component__c =:comboName  AND Pump_Bundle__c=:Pumpname AND Bundle_Sequence__c =: bunsequencetoLimit ORDER BY component__c
		*/
        Rule_Picklist__c forthForRule = new Rule_Picklist__c(
            rule__c = 69,
            Rule_Seq__c = 1,
            Pump_Bundle__c = 'Test Pump',
            product__c = p.id,
            Bundle_Sequence__c = 1,
            component__c ='Test ComboName' ,
            Component_Type__c='Test Type'
        );
        insert forthForRule;
        
        Product_Bundle_Rule_Engine__c thenList = new Product_Bundle_Rule_Engine__c(
            Rule__c = 69,
            Rule_Seq__c = 1,
            Pump__c = testProductBundle.Name,
            Product__c = p.Id,
            Product_Bundle__c = testProductBundle.id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'Test Component1',
            Logic__c = 'then',
            Component_Type__c = 'Test Type',
            Logic_Releationship__c = 'EQ',
            Is_Conditional_List__c = false,
            Is_Blank__c = false
        );
        insert thenList;
        
        
        
        /*SELECT id, name,rule__c, Rule_Seq__c, pump__c, product__r.name, Product_Bundle__c, Bundle_Sequence__c, JDE_Component__c, Logic__c, Component_Type__c, 
                                                       Is_Conditional_List__c, Is_Blank__c, Logic_Releationship__c FROM Product_Bundle_Rule_Engine__c
                                                       WHERE rule__c IN: onlyRule AND pump__c=: Pumpname ORDER BY Rule_Seq__c
        */
        
        Product_Bundle_Rule_Engine__c thenList2 = new Product_Bundle_Rule_Engine__c(
        	rule__c = 69,
            Rule_Seq__c = 1,
            pump__c = 'Test Pump',
            product__c = p.Id,
            Product_Bundle__c = testProductBundle.id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'Test Component',
            Logic__c = 'if',
            Component_Type__c = 'Test Type', 
            Is_Conditional_List__c = false,
            Is_Blank__c = true,
            Logic_Releationship__c = 'NE'
        );
        insert thenList2;
        
        Product_Bundle_Rule_Engine__c thenList3 = new Product_Bundle_Rule_Engine__c(
        	rule__c = 1,
            Rule_Seq__c = 1,
            pump__c = 'Test Pump',
            product__c = p.Id,
            Product_Bundle__c = testProductBundle.id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'Test Component',
            Logic__c = 'And',
            Component_Type__c = 'Test Type', 
            Is_Conditional_List__c = false,
            Is_Blank__c = true,
            Logic_Releationship__c = 'EQ'
        );
        insert thenList3;
        
        Product_Bundle_Rule_Engine__c thenList4 = new Product_Bundle_Rule_Engine__c(
        	rule__c = 1,
            Rule_Seq__c = 1,
            pump__c = 'Test Pump',
            product__c = p.Id,
            Product_Bundle__c = testProductBundle.id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'Test Component',
            Logic__c = 'And',
            Component_Type__c = 'Test Type', 
            Is_Conditional_List__c = true,
            Is_Blank__c = true,
            Logic_Releationship__c = 'EQ'
        );
        insert thenList4;
        
        Product_Bundle_Rule_Engine__c thenList5 = new Product_Bundle_Rule_Engine__c(
        	rule__c = 1,
            Rule_Seq__c = 1,
            pump__c = 'Test Pump',
            product__c = p.Id,
            Product_Bundle__c = testProductBundle.id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'Test Component',
            Logic__c = 'And',
            Component_Type__c = 'Test Type', 
            Is_Conditional_List__c = true,
            Is_Blank__c = true,
            Logic_Releationship__c = 'NE'
        );
        insert thenList5;
        
        Product_Bundle_Rule_Engine__c thenList6 = new Product_Bundle_Rule_Engine__c(
        	rule__c = 69,
            Rule_Seq__c = 1,
            pump__c = 'Test Pump',
            product__c = p.Id,
            Product_Bundle__c = testProductBundle.id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'Test Component',
            Logic__c = 'Then',
            Component_Type__c = 'Test Type', 
            Is_Conditional_List__c = false,
            Is_Blank__c = true,
            Logic_Releationship__c = 'NE'
        );
        insert thenList6;
        
         Product_Bundle_Rule_Engine__c thenList7 = new Product_Bundle_Rule_Engine__c(
        	rule__c = 69,
            Rule_Seq__c = 1,
            pump__c = 'Test Pump',
           // product__c = p.Id,
            Product_Bundle__c = testProductBundle.id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'Test Component',
            Logic__c = 'Then',
            Component_Type__c = 'Test Type', 
            Is_Conditional_List__c = false,
            Is_Blank__c = true,
            Logic_Releationship__c = 'NE'
        );
        insert thenList7;
        
        Product_Bundle_Rule_Engine__c thenList8 = new Product_Bundle_Rule_Engine__c(
        	rule__c = 69,
            Rule_Seq__c = 1,
            pump__c = 'Test Pump',
            product__c = p.Id,
            Product_Bundle__c = testProductBundle.id,
            Bundle_Sequence__c = 1,
           // JDE_Component__c = 'Test Component',
            Logic__c = 'Then',
            Component_Type__c = 'Test Type', 
            Is_Conditional_List__c = true,
            Is_Blank__c = true,
            Logic_Releationship__c = 'NE'
        );
        insert thenList8;

        //productBundleName
        
        Attributes__c attributename2 = new Attributes__c(Name = 'test attribute name2');
        insert attributename2;
        
        Bundle_Attributes__c ProductBundleName = new Bundle_Attributes__c(
            name = 'Bundle Attri', 
            Bundle_Sequence__c = 1, 
            Product_Bundle__c = testProductBundle.Id,
            Attributes_text__c = 'test attribute name2',
            Product_Bundle_Text__c = 'Test Bundle'
          
        );
        insert ProductBundleName;
          
        Bundle_Attributes__c ProductBundleName2 = new Bundle_Attributes__c(
            name = 'Bundle Attri2', 
            Bundle_Sequence__c = 1, 
            Product_Bundle__c = testProductBundle.Id,
            Attributes_text__c = 'test attribute name2',
            Product_Bundle_Text__c = 'Test Bundle'
        );
        insert ProductBundleName2;
        system.debug('testProductBundle-->'+testProductBundle);
        system.debug('testProductBundle-->'+p);
        
        
        String stringBundleCode = '[{"key":"1  REQUIRED PARTS_ 1.5AGE 2023","value":"KD00005"},{"key":"25  WARRANTY_ 1.5AGE 2023","value":"WARR3"}]';
        
        Test.startTest();
        // Call the method to be tested
        opportunityProduct.forThenLogic('Test ComboName','Test Pump','1 TestBundle', stringBundleCode);
        opportunityProduct.ThenValidate('Test ComboName','Test Pump', '1 TestBundle', stringBundlecode);       
        Test.stopTest(); 
    }
      ////forThenLogictest3 method with else condition------------------------------------------------------------------------------
     @isTest
    public static void forThenLogicTest4(){
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
        
        /*
         * SELECT id,Product_name__c, name, Bundle_Sequence__c, JDE_component__c, Component_Type__c FROM Default_products__c 
                                                  WHERE name =: pumpName ORDER BY JDE_component__c
         */
        Default_products__c fromDefault2 = new Default_products__c(
            Name = 'Test Pump',
            Product_name__c = 'Test Default Product',
            Bundle_Sequence__c = 1,
            JDE_component__c = 'KD00005',
            Component_Type__c = 'Test Type'
        );
        insert fromDefault2;
        
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
        /*SELECT id, name, rule__c, Rule_Seq__c, Pump_Bundle__c ,product__r.name, Bundle_Sequence__c, component__c, Component_Type__c
                                                from rule_picklist__c WHERE Pump_Bundle__c=:Pumpname AND rule__c IN: onlyRule ORDER BY Rule_Seq__c
         */
        Rule_Picklist__c thirdForRule = new Rule_Picklist__c(
            rule__c = 69,
            Rule_Seq__c = 1,
            Pump_Bundle__c = 'Test Pump',
            product__c = p.id,
            Bundle_Sequence__c = 1,
            component__c ='Test Component' ,
            Component_Type__c='Test Type'
        );
        insert thirdForRule;
        
        /*
         * SELECT id,rule__c, Rule_Seq__c, Pump_Bundle__c ,product__r.name, Bundle_Sequence__c, component__c, Component_Type__c
                                                 from rule_picklist__c WHERE component__c =:comboName  AND Pump_Bundle__c=:Pumpname AND Bundle_Sequence__c =: bunsequencetoLimit ORDER BY component__c
		*/
        Rule_Picklist__c forthForRule = new Rule_Picklist__c(
            rule__c = 69,
            Rule_Seq__c = 1,
            Pump_Bundle__c = 'Test Pump',
            product__c = p.id,
            Bundle_Sequence__c = 1,
            component__c ='Test ComboName' ,
            Component_Type__c='Test Type'
        );
        insert forthForRule;
        
        Product_Bundle_Rule_Engine__c thenList = new Product_Bundle_Rule_Engine__c(
            Rule__c = 69,
            Rule_Seq__c = 1,
            Pump__c = testProductBundle.Name,
            Product__c = p.Id,
            Product_Bundle__c = testProductBundle.id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'Test Component1',
            Logic__c = 'then',
            Component_Type__c = 'Test Type',
            Logic_Releationship__c = 'EQ',
            Is_Conditional_List__c = true,
            Is_Blank__c = false
        );
        insert thenList;
        
        
        
        /*SELECT id, name,rule__c, Rule_Seq__c, pump__c, product__r.name, Product_Bundle__c, Bundle_Sequence__c, JDE_Component__c, Logic__c, Component_Type__c, 
                                                       Is_Conditional_List__c, Is_Blank__c, Logic_Releationship__c FROM Product_Bundle_Rule_Engine__c
                                                       WHERE rule__c IN: onlyRule AND pump__c=: Pumpname ORDER BY Rule_Seq__c
        */
        
        Product_Bundle_Rule_Engine__c thenList2 = new Product_Bundle_Rule_Engine__c(
        	rule__c = 69,
            Rule_Seq__c = 1,
            pump__c = 'Test Pump',
            product__c = p.Id,
            Product_Bundle__c = testProductBundle.id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'Test Component',
            Logic__c = 'if',
            Component_Type__c = 'Test Type', 
            Is_Conditional_List__c = false,
            Is_Blank__c = true,
            Logic_Releationship__c = 'NE'
        );
        insert thenList2;
        
        Product_Bundle_Rule_Engine__c thenList3 = new Product_Bundle_Rule_Engine__c(
        	rule__c = 1,
            Rule_Seq__c = 1,
            pump__c = 'Test Pump',
            product__c = p.Id,
            Product_Bundle__c = testProductBundle.id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'Test Component',
            Logic__c = 'And',
            Component_Type__c = 'Test Type', 
            Is_Conditional_List__c = false,
            Is_Blank__c = true,
            Logic_Releationship__c = 'EQ'
        );
        insert thenList3;
        
        Product_Bundle_Rule_Engine__c thenList4 = new Product_Bundle_Rule_Engine__c(
        	rule__c = 1,
            Rule_Seq__c = 1,
            pump__c = 'Test Pump',
            product__c = p.Id,
            Product_Bundle__c = testProductBundle.id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'Test Component',
            Logic__c = 'And',
            Component_Type__c = 'Test Type', 
            Is_Conditional_List__c = true,
            Is_Blank__c = true,
            Logic_Releationship__c = 'EQ'
        );
        insert thenList4;
        
        Product_Bundle_Rule_Engine__c thenList5 = new Product_Bundle_Rule_Engine__c(
        	rule__c = 1,
            Rule_Seq__c = 1,
            pump__c = 'Test Pump',
            product__c = p.Id,
            Product_Bundle__c = testProductBundle.id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'Test Component',
            Logic__c = 'And',
            Component_Type__c = 'Test Type', 
            Is_Conditional_List__c = true,
            Is_Blank__c = true,
            Logic_Releationship__c = 'NE'
        );
        insert thenList5;
        
        Product_Bundle_Rule_Engine__c thenList6 = new Product_Bundle_Rule_Engine__c(
        	rule__c = 69,
            Rule_Seq__c = 1,
            pump__c = 'Test Pump',
            product__c = p.Id,
            Product_Bundle__c = testProductBundle.id,
            Bundle_Sequence__c = 1,
            JDE_Component__c = 'Test Component',
            Logic__c = 'Then',
            Component_Type__c = 'Test Type', 
            Is_Conditional_List__c = true,
            Is_Blank__c = true,
            Logic_Releationship__c = 'NE'
        );
        insert thenList6;
        
        //productBundleName
        Bundle_Attributes__c ProductBundleName = new Bundle_Attributes__c(
            name = 'Bundle Attri', 
            Bundle_Sequence__c = 1, 
            Product_Bundle__c = testProductBundle.Id
        );
        insert ProductBundleName;
        /*
         * SELECT id, name, Bundle_Sequence__c, Product_Bundle__c 
                                                       from Bundle_Attributes__c 
                                                       where Product_Bundle__c =: getProductBundleID And
                                                       Bundle_Sequence__c IN:bundleSequenceSet ORDER BY Bundle_Sequence__c

		*/
        Bundle_Attributes__c ProductBundleName2 = new Bundle_Attributes__c(
            name = 'Bundle Attri2', 
            Bundle_Sequence__c = 1, 
            Product_Bundle__c = testProductBundle.Id,
            Attributes_text__c = 'test attribute name',
            Product_Bundle_Text__c = 'Test Bundle',
            Default_Product__c = 'default product'
        );
        insert ProductBundleName2;
        system.debug('testProductBundle-->'+testProductBundle);
        system.debug('testProductBundle-->'+p);
        
        
        String stringBundleCode = '[{"key":"1  REQUIRED PARTS_ 1.5AGE 2023","value":"KD00005"},{"key":"25  WARRANTY_ 1.5AGE 2023","value":"WARR3"}]';
        
        Test.startTest();
        // Call the method to be tested
        opportunityProduct.forThenLogic('Test ComboName','Test Pump','1 TestBundle', stringBundlecode);
        opportunityProduct.ThenValidate('Test ComboName','Test Pump', '1 TestBundle', stringBundlecode);
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
         Attributes__c attributename2 = new Attributes__c(Name = 'test attribute name2');
        insert attributename2;
        
        Bundle_Attributes__c ProductBundleName = new Bundle_Attributes__c(
            name = 'Bundle Attri', 
            Bundle_Sequence__c = 1, 
            Product_Bundle__c = testProductBundle.Id,
            Attributes_text__c = 'test attribute name2',
            Product_Bundle_Text__c = 'Test Bundle'
          
        );
        insert ProductBundleName;
          
        Bundle_Attributes__c ProductBundleName2 = new Bundle_Attributes__c(
            name = 'Bundle Attri2', 
            Bundle_Sequence__c = 1, 
            Product_Bundle__c = testProductBundle.Id,
            Attributes_text__c = 'test attribute name2',
            Product_Bundle_Text__c = 'Test Bundle'
        );
        insert ProductBundleName2;
        
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
            Is_Conditional_List__c = false,
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
        
        Rule_Picklist__c secondForRule1 = new Rule_Picklist__c(
            Rule__c = 2,
            Rule_Seq__c = 1,
            Pump_Bundle__c = 'Test Pump1',
            product__c = p.id, 
            Bundle_Sequence__c = 1,
            Component__c = 'KD000051',
            Component_Type__c = 'Product',
            Rule_Type__c = 'Selection'
        );
        insert secondForRule1;
        
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
        
        Default_products__c fromDefaultList = new Default_products__c(
            Product_name__c = 'test product',
            name = 'test Product2',
            Bundle_Sequence__c = 4,
            JDE_component__c = 'KD00005',
            Component_Type__c = 'Product'
        );
        insert fromDefaultList;
        
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
    public static void getAllSummaryTest4(){
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
            Rule__c = 3       
        );
        insert byPriceRuleOne;
        
        Price_rule_obj__c byPriceRuleIf = new Price_rule_obj__c(
            Pump__c= 'Test Pump', 
            Component_Type__c='Product', 
            Bundle_sequence__c =1, 
            Logic__c = 'Then',
            JDE_Component__c = '*VALUES', 
            Logic_Relationship__c = 'NE', 
            Product__c=newProduct.id, 
            Rule__c = 3        
        );
        insert byPriceRuleIf;
          Price_rule_obj__c byPriceRuleThen = new Price_rule_obj__c(
            Pump__c= 'Test Pump', 
            Component_Type__c='Product', 
            Bundle_sequence__c =1, 
            Logic__c = 'And',
            JDE_Component__c = 'KD00005', 
            Logic_Relationship__c = 'EQ', 
            Product__c=newProduct.id, 
            Rule__c = 3        
        );
        insert byPriceRuleThen;
        
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
        
           //parameters
        String Opportunityid = '0062E00001S5heXQAR';
        String maincmp = '1.25AGE 2023';
        String requireddata ='[{"Bundleattribute":"WIRING HARNESS KEM_HE 2024", "bundleid":"a3IUS0000008LSd2AM","productId":"0062E00001S5heXQAR", "productName":"3 YR Std Warranty", "componentType":"Product", "discount":"0", "finalprice":"0", "price":"0", "productcode":"WARR3", "quantity":"2"}]' ;
        Decimal totalDiscount = 5;
        Decimal totalPrice = 1260;
        
        id pricebookId = Test.getStandardPricebookId();
        pricebook2 pumppricebook = new pricebook2(
            IsActive = true ,
            Description = 'Pump Price Book', 
            //IsStandard = false, 
            //Id, 
            Name = 'Pump Price Book'
            // SystemModstamp = '2023-03-13T19:43:47.000+0000'
        );
        insert pumppricebook;
        pricebook2 pumppricebook1 = new pricebook2(
            IsActive = true ,
            Description = 'Pump Price Book111', 
            //IsStandard = false, 
            //Id, 
            Name = 'Pump Price Book111'
            // SystemModstamp = '2023-03-13T19:43:47.000+0000'
        );
        insert pumppricebook1;
        Product2 newProduct = new Product2(
            Name = '1.25AGE 2023',
            ProductCode = 'WARR3'
        );
        insert newProduct;
    
    	List<PriceBookEntry> entryList = new List<PriceBookEntry>();
        PriceBookEntry pEntries = new PriceBookEntry(product2Id = newProduct.id,pricebook2Id = pricebookId,Unitprice = 3, IsActive = True);
        entryList.add(pEntries);
        entryList.add(new PriceBookEntry(product2Id = newProduct.id,pricebook2Id = pumppricebook.Id,Unitprice = 3, IsActive = True));
        entryList.add(new PriceBookEntry(product2Id = newProduct.id,pricebook2Id = pumppricebook1.Id,Unitprice = 3, IsActive = True));
        insert entryList;
        
        test.startTest();
        opportunityProduct.createQuote(Opportunityid, maincmp, requireddata, totalDiscount, totalPrice);
        test.stopTest();
    }

 @isTest
    public static void createQuoteTest2(){
        
           //parameters
        String Opportunityid = '0062E00001S5heXQAR';
        String maincmp = '1.25AGE 2023';
        String requireddata ='[{"Bundleattribute":"WIRING HARNESS KEM_HE 2024", "bundleid":"a3IUS0000008LSd2AM","productId":"0062E00001S5heXQAR", "productName":"3 YR Std Warranty", "componentType":"Attribute", "discount":"0", "finalprice":"0", "price":"0", "productcode":"WARR3", "quantity":"2"}]' ;
        Decimal totalDiscount = 5;
        Decimal totalPrice = 1260;
        
        id pricebookId = Test.getStandardPricebookId();
        pricebook2 pumppricebook = new pricebook2(
            IsActive = true ,
            Description = 'Pump Price Book', 
            //IsStandard = false, 
            //Id, 
            Name = 'Pump Price Book'
            // SystemModstamp = '2023-03-13T19:43:47.000+0000'
        );
        insert pumppricebook;
        pricebook2 pumppricebook1 = new pricebook2(
            IsActive = true ,
            Description = 'Pump Price Book111', 
            //IsStandard = false, 
            //Id, 
            Name = 'Pump Price Book111'
            // SystemModstamp = '2023-03-13T19:43:47.000+0000'
        );
        insert pumppricebook1;
        Product2 newProduct = new Product2(
            Name = '1.25AGE 2023',
            ProductCode = 'WARR3'
        );
        insert newProduct;
    
    	List<PriceBookEntry> entryList = new List<PriceBookEntry>();
        PriceBookEntry pEntries = new PriceBookEntry(product2Id = newProduct.id,pricebook2Id = pricebookId,Unitprice = 3, IsActive = True);
        entryList.add(pEntries);
        entryList.add(new PriceBookEntry(product2Id = newProduct.id,pricebook2Id = pumppricebook.Id,Unitprice = 3, IsActive = True));
        entryList.add(new PriceBookEntry(product2Id = newProduct.id,pricebook2Id = pumppricebook1.Id,Unitprice = 3, IsActive = True));
        insert entryList;
        
        test.startTest();
        opportunityProduct.createQuote(Opportunityid, maincmp, requireddata, totalDiscount, totalPrice);
        test.stopTest();
    }
    
     
    
}