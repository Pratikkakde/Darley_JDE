/**
 * Created by IrinaSakovich on 26.07.22.
 */

@IsTest
public with sharing class B2BGuestCartServiceTest {

    @IsTest
    public static void getActiveCartTest() {
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initAllData();
        Product2 testProduct = B2BGuestCheckoutTestDataFactory.createProduct(true, 'QtyTestProduct', 'QtyTestCose');
        WebStore testStore = (WebStore)testData.get(B2BGuestCheckoutDefaultTestData.WEB_STORE);
        WebCart testCart = (WebCart)testData.get(B2BGuestCheckoutDefaultTestData.CART);
        User user = (User)testData.get(B2BGuestCheckoutDefaultTestData.GUEST_USER);

        WebCart activeCart;
        System.runAs(user) {
            activeCart = B2BGuestCartService.getOrCreateActiveCart(testStore.Id, testCart.Id);
        }

        System.assert(activeCart.Id != null, 'Guest Cart should be exist.');
    }

    @IsTest
    public static void createActiveCart1() {
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initAllData();
        WebStore testStore = (WebStore)testData.get(B2BGuestCheckoutDefaultTestData.WEB_STORE);
        WebCart testCart = (WebCart)testData.get(B2BGuestCheckoutDefaultTestData.CART);
        testCart.Status = 'Closed';
        update testCart;
        User user = (User)testData.get(B2BGuestCheckoutDefaultTestData.GUEST_USER);

        WebCart activeCart;
        System.runAs(user) {
            activeCart = B2BGuestCartService.getOrCreateActiveCart(testStore.Id, testCart.Id);
        }

        System.assertNotEquals(testCart.Id, activeCart.Id);
    }

    @IsTest
    public static void createActiveCart2() {
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initGuestUserData();
        WebStore testStore = (WebStore)testData.get(B2BGuestCheckoutDefaultTestData.WEB_STORE);
        User user = (User)testData.get(B2BGuestCheckoutDefaultTestData.GUEST_USER);

        WebCart activeCart;
        System.runAs(user) {
            Test.setMock(HttpCalloutMock.class, new B2BDefaultTestData.B2BDefaultTestMock());
            activeCart = B2BGuestCartService.getOrCreateActiveCart(testStore.Id, null);
        }

        System.assertEquals(false, activeCart == null);
    }

    @IsTest
    public static void deleteExpiredCartTest() {
        Guest_Cart_Expiration__c cartSettings = new Guest_Cart_Expiration__c(Expire_In__c = -2);
        insert cartSettings;
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initAllData();
        WebStore testStore = (WebStore)testData.get(B2BGuestCheckoutDefaultTestData.WEB_STORE);
        WebCart testCart = (WebCart)testData.get(B2BGuestCheckoutDefaultTestData.CART);
        User user = (User)testData.get(B2BGuestCheckoutDefaultTestData.GUEST_USER);

        WebCart activeCart;
        System.runAs(user) {
            B2BGuestCartService.InputVariables cartVariable = new B2BGuestCartService.InputVariables();
            cartVariable.cartId = testCart.Id;

            List<B2BGuestCartService.InputVariables> variables = new List<B2BGuestCartService.InputVariables> { cartVariable };
            B2BGuestCartService.deleteExpiredCart(variables);
        }

        List<WebCart> carts = [SELECT Id FROM WebCart WHERE Id = :testCart.Id];
        System.assert(carts.isEmpty(), 'Cart should be deleted.');

        List<Account> accounts = [SELECT Id FROM Account WHERE Id = :testCart.AccountId];
        System.assertEquals(true, accounts == null || accounts.isEmpty());
    }

    @IsTest
    public static void checkGuestCartDto() {
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initAllData();
        WebCart testCart = (WebCart)testData.get(B2BGuestCheckoutDefaultTestData.CART);
        WebStore testStore = (WebStore)testData.get(B2BGuestCheckoutDefaultTestData.WEB_STORE);
        User user = (User)testData.get(B2BGuestCheckoutDefaultTestData.GUEST_USER);

        System.runAs(user) {
            B2BGuestCartService.GuestCart guestCart = new B2BGuestCartService.GuestCart(testStore, testCart.AccountId, testCart.Id, testCart, '');
            System.assert(guestCart != null, 'Guest Cart should be exist.');
        }
    }

}