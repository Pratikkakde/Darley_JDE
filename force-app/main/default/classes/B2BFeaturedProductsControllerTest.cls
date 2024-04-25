@IsTest
private class B2BFeaturedProductsControllerTest {

    @IsTest
    private static void getProductsTest() {
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initAllData();
        User commUser = ((User) initData.get(B2BDefaultTestData.COMMUNITY_USER));
        Account commUserAccount = ((Account) initData.get(B2BDefaultTestData.CUSTOMER_ACCOUNT));
        BuyerGroup buyerGroup = ((BuyerGroup) initData.get(B2BDefaultTestData.BUYER_GROUP));
        ProductCategory category = ((ProductCategory) initData.get(B2BDefaultTestData.PRODUCT_CATEGORY));

        List<Product2> products = [SELECT Id, Featured_Product__c FROM Product2];
        products[0].Featured_Product__c = true;
        update products[0];

        CommerceEntitlementPolicy entitlementPolicy = B2BTestDataFactory.creteEntitlementPolicy(true);
        B2BTestDataFactory.crateCommerceEntitlementProduct(products[0].Id, entitlementPolicy.Id);
        B2BTestDataFactory.assignEntitlementPolicyToBuyerGroup(buyerGroup.Id, entitlementPolicy.Id);

        System.runAs(commUser) {
            Test.startTest();
            B2BResponse response = B2BFeaturedProductsController.getProducts(commUserAccount.Id, false);
            Test.stopTest();
            System.assertEquals(true, response.isSuccess);
        }
    }
}