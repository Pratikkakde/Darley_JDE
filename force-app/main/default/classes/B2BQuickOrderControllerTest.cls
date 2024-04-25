@IsTest
public with sharing class B2BQuickOrderControllerTest {

    @TestSetup
    public static void createTestData() {
        B2BQuickOrderTestData.setupQuickOrderTestData();
    }

    @IsTest
    static void getUserProfileTest() {
        User testUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BQuickOrderTestData.TEST_USER_NAME LIMIT 1];

        B2BResponse response;
        System.runAs(testUser) {
            Test.startTest();
            response = B2BQuickOrderController.getUserProfile();
            Test.stopTest();
        }

        System.assertNotEquals(null, response.responseData);
    }

    @IsTest
    private static void parseUploadedCSVTest() {
        User testUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BQuickOrderTestData.TEST_USER_NAME LIMIT 1];

        B2BResponse response;
        System.runAs(testUser) {
            Test.startTest();
            response = B2BQuickOrderController.parseUploadedCSV(B2BCsvUploadServiceTest.TEST_CSV_DATA, null);
            Test.stopTest();
        }

        List<B2BQuickOrderProductService.ProductData> parseCsvData = (List<B2BQuickOrderProductService.ProductData>) response.responseData;
        System.assert(response.isSuccess, 'Response is not success');
        System.assert(!parseCsvData.isEmpty(), 'Response is empty');
    }

    @IsTest
    private static void parseUploadedCSVFailTest() {
        User testUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BQuickOrderTestData.TEST_USER_NAME LIMIT 1];
        B2BCsvUploadServiceTest.TEST_CSV_DATA = null;

        B2BResponse response;
        System.runAs(testUser) {
            Test.startTest();
            response = B2BQuickOrderController.parseUploadedCSV(B2BCsvUploadServiceTest.TEST_CSV_DATA, null);
            Test.stopTest();
        }

        System.assert(!response.isSuccess, 'Response is success');
    }

    @IsTest
    static void addProductsToExistedCartTest() {
        User testUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BQuickOrderTestData.TEST_USER_NAME LIMIT 1];
        List<Product2> products = [SELECT Id FROM Product2 WHERE Name LIKE 'Test4%'];

        WebStore webStore = new WebStore(Name = 'Test Store Name');
        insert webStore;

        WebCart testCart = new WebCart(
            WebStoreId = webStore.Id,
            Name = 'Cart',
            AccountId = testUser.AccountId,
            Status = 'Active',
            OwnerId = testUser.Id
        );
        insert testCart;

        CartDeliveryGroup grp = new CartDeliveryGroup(
            Name = 'Cart Delivery Group',
            CartId = testCart.Id,
            DeliverToPostalCode = '606060',
            DeliverToState = 'Illinois',
            DeliverToStateCode = 'IL',
            DeliverToStreet = 'mail street',
            DeliverToCity = 'Chicago',
            DeliverToCountry = 'United States',
            DeliverToCountryCode = 'US'
        );
        insert grp;

        CartItem cartItem = new CartItem();
        cartItem.Product2Id = products[0].Id;
        cartItem.Quantity = 10;
        cartItem.SalesPrice = 100;
        cartItem.CartId = testCart.Id;
        cartItem.CartDeliveryGroupId = grp.Id;
        cartItem.Name = 'CartItem';
        cartItem.Type = 'Product';
        insert cartItem;

        List<B2BQuickOrderProductService.ProductData> productDataList = new List<B2BQuickOrderProductService.ProductData>();
        B2BQuickOrderProductService.ProductData productData;
        for (Product2 product : products) {
            productData = new B2BQuickOrderProductService.ProductData();
            productData.id = product.Id;
            productData.finalQuantity = 10;
            productDataList.add(productData);
        }
        B2BResponse response;

        System.runAs(testUser) {
            Test.startTest();
            response = B2BQuickOrderController.submitQuickOrder(JSON.serialize(productDataList), null);
            Test.stopTest();
        }

        System.assertEquals(false, response.isSuccess);
        System.assertNotEquals(null, response.responseData);
    }

    @IsTest
    static void addProductsToCartTest() {
        List<Product2> products = new List<Product2>();
        for (Integer i = 0;  i < 100; i++) {
            products.add(new Product2(Name = 'test' + i, StockKeepingUnit = 'sku' + i));
        }

        insert products;

        products = [SELECT Id, StockKeepingUnit FROM Product2 WHERE StockKeepingUnit LIKE 'sku%'];

        Test.startTest();
        List<B2BQuickOrderProductService.ProductData> productDataList = new List<B2BQuickOrderProductService.ProductData>();
        B2BQuickOrderProductService.ProductData productData;
        for (Product2 product : products) {
            productData = new B2BQuickOrderProductService.ProductData();
            productData.id = product.Id;
            productData.sku = product.StockKeepingUnit;
            productData.finalQuantity = 10;
            productDataList.add(productData);
        }

        B2BResponse response = B2BQuickOrderController.submitQuickOrder(JSON.serialize(productDataList), null);
        Test.stopTest();

        System.assertNotEquals(null, response.responseData);
    }

    @IsTest
    static void submitQuickOrderTestException() {
        Product2 product = [SELECT Id, StockKeepingUnit FROM Product2 WHERE Name = 'Test4Product' LIMIT 1];
        List<B2BQuickOrderProductService.ProductData> productDataList = new List<B2BQuickOrderProductService.ProductData>();
        B2BQuickOrderProductService.ProductData productData = new B2BQuickOrderProductService.ProductData();
        productData.id = product.Id;
        productData.sku = product.StockKeepingUnit;
        productData.finalQuantity = 10;
        productDataList.add(productData);
        delete product;

        Test.startTest();
        B2BResponse response = B2BQuickOrderController.submitQuickOrder(JSON.serialize(productDataList), null);
        Test.stopTest();

        System.assertEquals(false, response.isSuccess);
        System.assertNotEquals(null, response.responseData);
    }

    @IsTest
    private static void getSampleFileLinkTest() {
        List<ContentVersion> docVersions = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Title = 'testSample' LIMIT 1];
        String documentId = docVersions == null || docVersions.isEmpty() ? '' : docVersions[0].ContentDocumentId;

        B2BResponse response = B2BQuickOrderController.getSampleFileLink(documentId);
        System.assertEquals(true, response.isSuccess);
        System.assertEquals(false, response.responseData == null);
    }

    @IsTest
    private static void getCartItemsDataTest() {
        Map<String, String> result = B2BQuickOrderController.getCartItemsData(null);
        System.assertEquals(false, result.isEmpty());
        System.assertEquals(null, result.get('cartItemId'));
        System.assertEquals(null, result.get('cartItemQuantity'));
    }
}