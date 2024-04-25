@IsTest
public with sharing class B2BGuestCheckoutTestDataFactoryTest {
    @IsTest
    public static void testInitAllData() {
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        factory.initAllData();
        List<Account> acc = [SELECT Id FROM Account];
        System.assertEquals(1, acc.size());
    }

    @IsTest
    public static void createAccountTest() {
        B2BGuestCheckoutTestDataFactory.createAccount(true, 'Test12 Account Name');
        List<Account> acc = [SELECT Id FROM Account];
        System.assertEquals(1, acc.size());
    }

    @IsTest
    public static void createBuyerGroupTest() {
        B2BGuestCheckoutTestDataFactory.createBuyerGroup(true);
        List<BuyerGroup> bgrp = [SELECT Id FROM BuyerGroup];
        System.assertEquals(1, bgrp.size());
    }

    @IsTest
    public static void createProductTest() {
        B2BGuestCheckoutTestDataFactory.createProduct(true, 'Test12 Product Name', 'TEST-CODE');
        List<Product2> products = [SELECT Id FROM Product2 WHERE Name = 'Test12 Product Name'];
        System.assertEquals(1, products.size());
    }

    @IsTest
    public static void createCartItemTest() {
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initCartData();
        Product2 testProduct = B2BGuestCheckoutTestDataFactory.createProduct(true, 'TestProduct', 'testCode');

        CartItem cartItem = B2BGuestCheckoutTestDataFactory.createCartItem(
            true,
            testProduct.Id,
            ((WebCart)testData.get(B2BGuestCheckoutDefaultTestData.CART)).Id,
            ((CartDeliveryGroup)testData.get(B2BGuestCheckoutDefaultTestData.CART_DELIVERY_GROUP)).Id
        );

        List<CartItem> cartItems = [SELECT Id FROM CartItem];
        System.assertEquals(2, cartItems.size());
    }
}