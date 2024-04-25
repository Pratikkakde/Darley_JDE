/**
 * Created by IrinaSakovich on 1.08.22.
 */

@IsTest
public with sharing class B2BGuestCartProductServiceTest {

    @IsTest
    public static void formatDateTimeFieldsTest() {
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initGuestUserData();
        User user = (User)testData.get(B2BGuestCheckoutDefaultTestData.GUEST_USER);
        List<String> fieldSetNames = new List<String>(Schema.getGlobalDescribe().get('Product2').getDescribe().fieldSets.getMap()?.keySet());
        String fieldSetName = fieldSetNames == null || fieldSetNames.isEmpty() ? null : fieldSetNames[0];

        Map<String,String> fieldsMap;
        System.runAs(user) {
            fieldsMap = B2BGuestCartProductService.formatDateTimeFields(getFieldsMap(), fieldSetName);
        }

        System.assertEquals('01/24/2022 10:03:40', fieldsMap.get('CreatedDate'));
        System.assertEquals('01/24/2022 10:03:40', fieldsMap.get('CreatedDate'));
        System.assertEquals('00:45:00', fieldsMap.get('TestTime'));
        System.assertEquals('01/24/2022', fieldsMap.get('TestDate'));
    }

    private static Map<String,String> getFieldsMap() {
        return new Map<String,String>{
            'Name' => 'TestName',
            'CreatedDate' => '2022-01-24T10:03:40Z',
            'CreatedById' => 'TestId',
            'LastModifiedDate' => '2022-01-24T10:03:40Z',
            'TestTime' => '00:45:00.000Z',
            'TestDate' => '2022-01-24'
        };
    }

    @IsTest
    public static void checkGettingProducts() {
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initAllData();
        Product2 testProduct = B2BGuestCheckoutTestDataFactory.createProduct(true, 'QtyTestProduct', 'QtyTestCose');
        WebStore testStore = (WebStore)testData.get(B2BGuestCheckoutDefaultTestData.WEB_STORE);
        WebCart testCart = (WebCart)testData.get(B2BGuestCheckoutDefaultTestData.CART);
        User user = (User)testData.get(B2BGuestCheckoutDefaultTestData.GUEST_USER);

        List<Id> productIds = new List<Id> { testProduct.Id };
        List<String> fieldSetNames = new List<String>(Schema.getGlobalDescribe().get('Product2').getDescribe().fieldSets.getMap()?.keySet());
        String fieldSetName = fieldSetNames == null || fieldSetNames.isEmpty() ? null : fieldSetNames[0];

        Map<Id, ConnectApi.ProductOverview> productMap;
        System.runAs(user) {
            productMap = B2BGuestCartProductService.getProducts(testStore.Id, testCart.AccountId, productIds, fieldSetName, true);
        }

        System.assert(!productMap.isEmpty(), 'Product map is empty');
    }

    @IsTest
    public static void checkGettingQtyRulesMap() {
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initAllData();
        Product2 testProduct = B2BGuestCheckoutTestDataFactory.createProduct(true, 'QtyTestProduct', 'QtyTestCose');
        WebStore testStore = (WebStore)testData.get(B2BGuestCheckoutDefaultTestData.WEB_STORE);
        WebCart testCart = (WebCart)testData.get(B2BGuestCheckoutDefaultTestData.CART);

        PurchaseQuantityRule rule = new PurchaseQuantityRule(
            Name = 'test',
            Increment = 11,
            Minimum = 11,
            Maximum = 1100
        );
        insert rule;

        ProductQuantityRule productRule = new ProductQuantityRule(
                ProductId = testProduct.Id,
                PurchaseQuantityRuleId = rule.Id
        );
        insert productRule;

        User user = (User)testData.get(B2BGuestCheckoutDefaultTestData.GUEST_USER);

        List<Id> productIds = new List<Id> { testProduct.Id };
        Map<Id, ProductQuantityRule> productQuantityRule;
        System.runAs(user) {
            productQuantityRule = B2BGuestCartProductService.getQtyRulesMap(productIds);
        }

        System.assert(productQuantityRule != null, 'Product Rule should not be null.');
    }

    @IsTest
    public static void checkGettingProductPricesMap() {
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initAllData();
        Product2 testProduct = B2BGuestCheckoutTestDataFactory.createProduct(true, 'QtyTestProduct', 'QtyTestCose');
        WebStore testStore = (WebStore)testData.get(B2BGuestCheckoutDefaultTestData.WEB_STORE);
        WebCart testCart = (WebCart)testData.get(B2BGuestCheckoutDefaultTestData.CART);
        User user = (User)testData.get(B2BGuestCheckoutDefaultTestData.GUEST_USER);

        Map<Id, PricebookEntry> prices;
        List<Id> productIds = new List<Id> { testProduct.Id };
        System.runAs(user) {
            prices = B2BGuestCartProductService.getProductPricesMap(productIds, testCart.AccountId, testStore.Id);
        }

        System.assert(prices.isEmpty(), 'Prices map is not empty');
    }

}