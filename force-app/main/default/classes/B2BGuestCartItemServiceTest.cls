/**
 * Created by IrinaSakovich on 26.07.22.
 */

@IsTest
public with sharing class B2BGuestCartItemServiceTest {
    @IsTest
    private static void addItemToCartPriceTest() {
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initAllData();
        WebStore testStore = (WebStore)testData.get(B2BGuestCheckoutDefaultTestData.WEB_STORE);
        Product2 testProduct = (Product2)testData.get(B2BGuestCheckoutDefaultTestData.PRODUCT);
        WebCart testCart = (WebCart)testData.get(B2BGuestCheckoutDefaultTestData.CART);
        CartItem cartItem = (CartItem)testData.get(B2BGuestCheckoutDefaultTestData.CART_ITEM);
        delete cartItem;
        PricebookEntry testPricebookEntry = (PricebookEntry)testData.get(B2BGuestCheckoutDefaultTestData.PRICE_BOOK_ENTRY);
        User user = (User)testData.get(B2BGuestCheckoutDefaultTestData.GUEST_USER);
        B2BGuestCartItemService.ProductInfo productInfo = initProductInfo(testProduct.Id, 13, true, 30);

        B2BGuestCartItemService.AddItemResponse response;
        System.runAs(user) {
            response = B2BGuestCartItemService.addItemToCart(null, productInfo, testStore.Id, null, testCart.Id);
        }

        System.assertEquals(testCart.Id, response.guestCartId);
        System.assertEquals(false, response.showWarning);

        CartItem item = [SELECT Id, Quantity, SalesPrice, TotalLineAmount FROM CartItem WHERE CartId = :testCart.Id];
        System.assertEquals(13, item.Quantity);
        System.assertEquals(testPricebookEntry.UnitPrice, item.SalesPrice);
        System.assertEquals((testPricebookEntry.UnitPrice*13).setScale(2), item.TotalLineAmount);
    }

    @IsTest
    private static void addItemToCartMaxQtyTest() {
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initAllData();
        WebStore testStore = (WebStore)testData.get(B2BGuestCheckoutDefaultTestData.WEB_STORE);
        Product2 testProduct = (Product2)testData.get(B2BGuestCheckoutDefaultTestData.PRODUCT);
        WebCart testCart = (WebCart)testData.get(B2BGuestCheckoutDefaultTestData.CART);
        CartItem testCartItem = (CartItem)testData.get(B2BGuestCheckoutDefaultTestData.CART_ITEM);
        PricebookEntry testPricebookEntry = (PricebookEntry)testData.get(B2BGuestCheckoutDefaultTestData.PRICE_BOOK_ENTRY);
        User user = (User)testData.get(B2BGuestCheckoutDefaultTestData.GUEST_USER);
        B2BGuestCartItemService.ProductInfo productInfo = initProductInfo(testProduct.Id, 25, true, 30);

        B2BGuestCartItemService.AddItemResponse response;
        System.runAs(user) {
            response = B2BGuestCartItemService.addItemToCart(new List<CartItem>{testCartItem}, productInfo, testStore.Id, null, testCart.Id);
        }

        System.assertEquals(testCart.Id, response.guestCartId);
        System.assertEquals(true, response.showWarning);

        CartItem item = [SELECT Id, Quantity, SalesPrice, TotalLineAmount FROM CartItem WHERE CartId = :testCart.Id];
        System.assertEquals(30, item.Quantity);
        System.assertEquals(testPricebookEntry.UnitPrice, item.SalesPrice);
        System.assertEquals((testPricebookEntry.UnitPrice*30).setScale(2), item.TotalLineAmount);
    }

    @IsTest
    private static void addItemToCartMaxQtyReachedTest() {
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initAllData();
        WebStore testStore = (WebStore)testData.get(B2BGuestCheckoutDefaultTestData.WEB_STORE);
        Product2 testProduct = (Product2)testData.get(B2BGuestCheckoutDefaultTestData.PRODUCT);
        WebCart testCart = (WebCart)testData.get(B2BGuestCheckoutDefaultTestData.CART);
        CartItem testCartItem = (CartItem)testData.get(B2BGuestCheckoutDefaultTestData.CART_ITEM);
        User user = (User)testData.get(B2BGuestCheckoutDefaultTestData.GUEST_USER);
        B2BGuestCartItemService.ProductInfo productInfo = initProductInfo(testProduct.Id, 25, true, 10);

        B2BGuestCartItemService.AddItemResponse response;
        System.runAs(user) {
            response = B2BGuestCartItemService.addItemToCart(new List<CartItem>{testCartItem}, productInfo, testStore.Id, null, testCart.Id);
        }

        System.assertEquals(testCart.Id, response.guestCartId);
        System.assertEquals(true, response.showWarning);

        CartItem item = [SELECT Id, Quantity, SalesPrice, TotalLineAmount FROM CartItem WHERE CartId = :testCart.Id];
        System.assertEquals(testCartItem.Quantity, item.Quantity);
        System.assertEquals(testCartItem.SalesPrice, item.SalesPrice);
        System.assertEquals(testCartItem.TotalLineAmount, item.TotalLineAmount);
    }

    @IsTest
    private static void checkQtyRulesTest1() {
        Decimal qty = B2BGuestCartItemService.checkQtyRules(5, 10, 5, true);
        System.assertEquals(10, qty);
        System.assertEquals(false, B2BGuestCartItemService.isShowWarning);
    }

    @IsTest
    private static void checkQtyRulesTest2() {
        Decimal qty = B2BGuestCartItemService.checkQtyRules(7, 10, 5, true);
        System.assertEquals(10, qty);
        System.assertEquals(true, B2BGuestCartItemService.isShowWarning);
    }

    @IsTest
    private static void checkQtyRulesTest3() {
        Decimal qty = B2BGuestCartItemService.checkQtyRules(2, 10, 5, true);
        System.assertEquals(7, qty);
        System.assertEquals(false, B2BGuestCartItemService.isShowWarning);
    }

    @IsTest
    private static void checkQtyRulesTest4() {
        Decimal qty = B2BGuestCartItemService.checkQtyRules(5, 10, 5, false);
        System.assertEquals(5, qty);
        System.assertEquals(false, B2BGuestCartItemService.isShowWarning);
    }

    @IsTest
    private static void checkQtyRulesTest5() {
        Decimal qty = B2BGuestCartItemService.checkQtyRules(17, 10, 5, false);
        System.assertEquals(10, qty);
        System.assertEquals(true, B2BGuestCartItemService.isShowWarning);
    }

    @IsTest
    private static void checkQtyRulesTest6() {
        Decimal qty = B2BGuestCartItemService.checkQtyRules(2, 10, 10, false);
        System.assertEquals(2, qty);
        System.assertEquals(false, B2BGuestCartItemService.isShowWarning);
    }

    private static B2BGuestCartItemService.ProductInfo initProductInfo(Id productId, Decimal quantity, Boolean addToQuantity, Decimal maxQty) {
        B2BGuestCartItemService.ProductInfo productInfo = new B2BGuestCartItemService.ProductInfo();
        productInfo.productId = productId;
        productInfo.quantity = quantity;
        productInfo.maxQty = maxQty;
        productInfo.addToQuantity = addToQuantity;

        return productInfo;
    }

    @IsTest
    public static void checkGettingGuestCartItems() {
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initAllData();
        Product2 testProduct = B2BGuestCheckoutTestDataFactory.createProduct(true, 'QtyTestProduct', 'QtyTestCose');
        WebStore testStore = (WebStore)testData.get(B2BGuestCheckoutDefaultTestData.WEB_STORE);
        WebCart testCart = (WebCart)testData.get(B2BGuestCheckoutDefaultTestData.CART);
        User user = (User)testData.get(B2BGuestCheckoutDefaultTestData.GUEST_USER);

        List<String> fieldSetNames = new List<String>(Schema.getGlobalDescribe().get('Product2').getDescribe().fieldSets.getMap()?.keySet());
        String fieldSetName = fieldSetNames == null || fieldSetNames.isEmpty() ? null : fieldSetNames[0];

        List<CartItem> cartItems = [SELECT Id, Product2Id, CartId, Name, Sku, Product2.ProductClass, Quantity, TotalPrice FROM CartItem WHERE CartId = :testCart.Id];
        List<B2BGuestCartItemService.GuestCartItem> guestCartItems;
        System.runAs(user) {
            guestCartItems = B2BGuestCartItemService.getGuestCartItems(testStore, testCart.AccountId, cartItems, fieldSetName);
            B2BGuestCartItemService.deleteGuestCartItem(cartItems);
        }

        System.assert(!guestCartItems.isEmpty(), 'Cart Items is not existed.');
        List<CartItem> deletedCartItems = [SELECT Id FROM CartItem WHERE CartId = :testCart.Id];
        System.assert(deletedCartItems.isEmpty(), 'Cart Items were not deleted.');
    }
}