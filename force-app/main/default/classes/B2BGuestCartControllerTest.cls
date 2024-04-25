/**
 * Created by IrinaSakovich on 25.07.22.
 */

@IsTest
public without sharing class B2BGuestCartControllerTest {
    @IsTest
    public static void getProductQtyDetailsTest() {
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initGuestUserData();
        Product2 testProduct = B2BGuestCheckoutTestDataFactory.createProduct(true, 'QtyTestProduct', 'QtyTestCose');
        PurchaseQuantityRule qtyRule = initQtyRule(testProduct.Id);
        User user = (User)testData.get(B2BGuestCheckoutDefaultTestData.GUEST_USER);

        B2BResponse response;
        System.runAs(user) {
            response = B2BGuestCartController.getProductQtyDetails(new List<Id>{testProduct.Id});
        }

        System.assertEquals(true, response.isSuccess);
        System.assertEquals(qtyRule.Maximum, ((List<B2BGuestCartController.ProductQtyData>)response.responseData)[0].qtyRule.max);
        System.assertEquals(qtyRule.Minimum, ((List<B2BGuestCartController.ProductQtyData>)response.responseData)[0].qtyRule.min);
        System.assertEquals(qtyRule.Increment, ((List<B2BGuestCartController.ProductQtyData>)response.responseData)[0].qtyRule.inc);
    }

    @IsTest
    public static void getProductQtyDetailsNoRulesTest() {
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initGuestUserData();
        Product2 testProduct = B2BGuestCheckoutTestDataFactory.createProduct(true, 'QtyTestProduct', 'QtyTestCose');
        User user = (User)testData.get(B2BGuestCheckoutDefaultTestData.GUEST_USER);

        B2BResponse response;
        System.runAs(user) {
            response = B2BGuestCartController.getProductQtyDetails(new List<Id>{testProduct.Id});
        }

        System.assertEquals(true, response.isSuccess);
        System.assertEquals(0, ((List<B2BGuestCartController.ProductQtyData>)response.responseData).size());
    }

    @IsTest
    public static void addToCartTest() {
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initGuestUserData();
        testData.putAll(factory.initProductData());
        Product2 testProduct = (Product2)testData.get(B2BGuestCheckoutDefaultTestData.PRODUCT);
        User user = (User)testData.get(B2BGuestCheckoutDefaultTestData.GUEST_USER);
        String productInfo = '{"productId":"' + testProduct.Id + '","quantity":1,"addToQuantity":true,"maxQty":30}';

        B2BResponse response;
        System.runAs(user) {
            Test.setMock(HttpCalloutMock.class, new B2BDefaultTestData.B2BDefaultTestMock());
            response = B2BGuestCartController.addToCart(productInfo, null, null);
        }

        System.assertEquals(true, response.isSuccess);
        System.assertEquals(false, response.responseData == null);
    }

    @IsTest
    public static void addToCartFailTest() {
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initGuestUserData();
        User user = (User)testData.get(B2BGuestCheckoutDefaultTestData.GUEST_USER);

        B2BResponse response;
        System.runAs(user) {
            response = B2BGuestCartController.addToCart(null, null, null);
        }

        System.assertEquals(false, response.isSuccess);
        System.assertEquals(false, response.responseData == null);
        System.assertEquals(false, response.responseMessage == null);
    }

    @IsTest
    public static void getCartDataTest() {
        Guest_Cart_Expiration__c cartSettings = new Guest_Cart_Expiration__c(Expire_In__c = 2);
        insert cartSettings;

        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initAllData();
        WebCart testCart = (WebCart)testData.get(B2BGuestCheckoutDefaultTestData.CART);
        User user = (User)testData.get(B2BGuestCheckoutDefaultTestData.GUEST_USER);

        B2BResponse response;
        System.runAs(user) {
            response = B2BGuestCartController.getCartData(testCart.AccountId, testCart.Id);
        }

        System.assertEquals(true, response.isSuccess);
        System.assertEquals(testCart.Id, ((B2BGuestCartService.CartData)response.responseData).cartId);
        System.assertEquals(1, ((B2BGuestCartService.CartData)response.responseData).cartProductsQuantity);
        System.assertEquals(10, ((B2BGuestCartService.CartData)response.responseData).cartItemsQuantitySum);
    }

    @IsTest
    public static void getInitialGuestCartTest() {
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initAllData();
        WebCart testCart = (WebCart)testData.get(B2BGuestCheckoutDefaultTestData.CART);
        Product2 testProduct = (Product2)testData.get(B2BGuestCheckoutDefaultTestData.PRODUCT);
        User user = (User)testData.get(B2BGuestCheckoutDefaultTestData.GUEST_USER);
        PurchaseQuantityRule qtyRule = initQtyRule(testProduct.Id);
        List<String> fieldSetNames = new List<String>(Schema.getGlobalDescribe().get('Product2').getDescribe().fieldSets.getMap()?.keySet());
        String fieldSetName = fieldSetNames == null || fieldSetNames.isEmpty() ? null : fieldSetNames[0];

        B2BResponse response;
        System.runAs(user) {
            response = B2BGuestCartController.getInitialGuestCart(null, testCart.Id, 'CreatedDate DESC', fieldSetName);
        }

        System.assertEquals(true, response.isSuccess);
        System.assertEquals(false, response.responseData == null);
        System.assertEquals(1, ((B2BGuestCartService.GuestCart)response.responseData).items.size());
    }

    @IsTest
    public static void getInitialGuestCartWithoutQtyRulesTest() {
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initAllData();
        WebCart testCart = (WebCart)testData.get(B2BGuestCheckoutDefaultTestData.CART);
        CartDeliveryGroup testDelGr = (CartDeliveryGroup)testData.get(B2BGuestCheckoutDefaultTestData.CART_DELIVERY_GROUP);
        User user = (User)testData.get(B2BGuestCheckoutDefaultTestData.GUEST_USER);
        Product2 testProduct2 = B2BGuestCheckoutTestDataFactory.createProduct(true, 'Test2 Product', 'Test2 Code');
        CartItem testCartItem2 = B2BGuestCheckoutTestDataFactory.createCartItem(true, testProduct2.Id, testCart.Id, testDelGr.Id);

        B2BResponse response;
        System.runAs(user) {
            response = B2BGuestCartController.getInitialGuestCart(null, testCart.Id, null, null);
        }

        System.assertEquals(true, response.isSuccess);
        System.assertEquals(false, response.responseData == null);
        System.assertEquals(2, ((B2BGuestCartService.GuestCart)response.responseData).items.size());
    }

    @IsTest
    public static void clearGuestCartTest() {
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initAllData();
        WebCart testCart = (WebCart)testData.get(B2BGuestCheckoutDefaultTestData.CART);
        User user = (User)testData.get(B2BGuestCheckoutDefaultTestData.GUEST_USER);

        B2BResponse response;
        System.runAs(user) {
            response = B2BGuestCartController.clearGuestCart(null, testCart.Id);
        }

        System.assertEquals(true, response.isSuccess);
        System.assertEquals(false, response.responseData == null);
        System.assertNotEquals(testCart.Id, ((B2BGuestCartService.GuestCart)response.responseData).id);
        System.assertEquals(0, ((B2BGuestCartService.GuestCart)response.responseData).items.size());
    }

    @IsTest
    public static void deleteGuestCartItemTest() {
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initAllData();
        WebCart testCart = (WebCart)testData.get(B2BGuestCheckoutDefaultTestData.CART);
        CartDeliveryGroup testDelGr = (CartDeliveryGroup)testData.get(B2BGuestCheckoutDefaultTestData.CART_DELIVERY_GROUP);
        Product2 testProduct = (Product2)testData.get(B2BGuestCheckoutDefaultTestData.PRODUCT);
        User user = (User)testData.get(B2BGuestCheckoutDefaultTestData.GUEST_USER);
        Product2 testProduct2 = B2BGuestCheckoutTestDataFactory.createProduct(true, 'Test2 Product', 'Test2 Code');
        CartItem testCartItem2 = B2BGuestCheckoutTestDataFactory.createCartItem(true, testProduct2.Id, testCart.Id, testDelGr.Id);

        B2BResponse response;
        System.runAs(user) {
            response = B2BGuestCartController.deleteGuestCartItem(null, testCart.Id, testProduct2.Id, null, null);
        }

        System.assertEquals(true, response.isSuccess);
        System.assertEquals(false, response.responseData == null);
        System.assertEquals(1, ((B2BGuestCartService.GuestCart)response.responseData).items.size());
        System.assertEquals(testProduct.Id, ((B2BGuestCartService.GuestCart)response.responseData).items[0].productId);
    }

    @IsTest
    public static void changeQtyGuestCartItemTest() {
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initAllData();
        WebCart testCart = (WebCart)testData.get(B2BGuestCheckoutDefaultTestData.CART);
        Product2 testProduct = (Product2)testData.get(B2BGuestCheckoutDefaultTestData.PRODUCT);
        User user = (User)testData.get(B2BGuestCheckoutDefaultTestData.GUEST_USER);

        B2BResponse response;
        System.runAs(user) {
            response = B2BGuestCartController.changeQtyGuestCartItem(null, testCart.Id, testProduct.Id, 15, null, null);
        }

        System.assertEquals(true, response.isSuccess);
        System.assertEquals(false, response.responseData == null);
        System.assertEquals(1, ((B2BGuestCartService.GuestCart)response.responseData).items.size());
        System.assertEquals(testProduct.Id, ((B2BGuestCartService.GuestCart)response.responseData).items[0].productId);
        System.assertEquals(15, ((B2BGuestCartService.GuestCart)response.responseData).items[0].quantity);
    }

    private static PurchaseQuantityRule initQtyRule(Id productId) {
        PurchaseQuantityRule purchaseQtyRule = new PurchaseQuantityRule(
            Name = 'TestRule',
            Maximum = 100,
            Minimum = 1,
            Increment = 1
        );
        insert purchaseQtyRule;

        ProductQuantityRule productQtyRule = new ProductQuantityRule(
            ProductId = productId,
            PurchaseQuantityRuleId = purchaseQtyRule.Id
        );
        insert productQtyRule;

        return purchaseQtyRule;
    }
}