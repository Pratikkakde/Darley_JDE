@IsTest
private class B2BFavoriteListDetailControllerTest {

    public static String TEST_USER_NAME = 'TestUserName@test.com';

    @TestSetup
    private static void makeData() {
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initAllData();
        User commUser = ((User) initData.get(B2BDefaultTestData.COMMUNITY_USER));
        TEST_USER_NAME = commUser.UserName;
        Account commUserAccount = ((Account) initData.get(B2BDefaultTestData.CUSTOMER_ACCOUNT));
        BuyerGroup buyerGroup = ((BuyerGroup) initData.get(B2BDefaultTestData.BUYER_GROUP));
        ProductCategory category = ((ProductCategory) initData.get(B2BDefaultTestData.PRODUCT_CATEGORY));

        PurchaseQuantityRule rule = new PurchaseQuantityRule(
            Name = 'test',
            Increment = 11,
            Minimum = 11,
            Maximum = 1100
        );
        insert rule;

        ProductQuantityRule productRule = new ProductQuantityRule(
            ProductId = ((Product2) initData.get(B2BDefaultTestData.PRODUCT)).Id,
            PurchaseQuantityRuleId = rule.Id
        );
        insert productRule;

        Product2 testParentProduct = new Product2(
            Name = 'Parent Product',
            IsActive = true,
            ProductCode = 'PARENT-CODE',
            Type = 'Base'
        );
        
        Product2 testChildProduct = new Product2(
            Name = 'Test Product',
            IsActive = true,
            ProductCode = 'CHILD-CODE'
        );
        insert new List<Product2> {testParentProduct, testChildProduct};

        ProductCategoryProduct testProductCategoryProduct2 = new ProductCategoryProduct(
            ProductCategoryId = ((ProductCategory) initData.get(B2BDefaultTestData.PRODUCT_CATEGORY)).Id,
            ProductId = testParentProduct.Id
        );
        insert testProductCategoryProduct2;

        CommerceEntitlementPolicy entitlementPolicy = B2BTestDataFactory.creteEntitlementPolicy(true);
        B2BTestDataFactory.crateCommerceEntitlementProduct(((Product2) initData.get(B2BDefaultTestData.PRODUCT)).Id, entitlementPolicy.Id);
        B2BTestDataFactory.crateCommerceEntitlementProduct(testParentProduct.Id, entitlementPolicy.Id);
        B2BTestDataFactory.crateCommerceEntitlementProduct(testChildProduct.Id, entitlementPolicy.Id);
        B2BTestDataFactory.assignEntitlementPolicyToBuyerGroup(buyerGroup.Id, entitlementPolicy.Id);

        ProductAttributeSet productAttributeSet = [
            SELECT Id, DeveloperName 
            FROM ProductAttributeSet 
            WHERE DeveloperName = 'AS_ColorSize'
        ];

        ProductAttributeSetProduct prodAttrSetProd = new ProductAttributeSetProduct(
            ProductAttributeSetId = productAttributeSet.Id,
            ProductId = testParentProduct.Id
        );
        insert prodAttrSetProd;

        ProductAttribute prodAttr = new ProductAttribute(
            ProductId = testChildProduct.Id,
            VariantParentId = testParentProduct.Id,
            Color__c = 'Blue',
            Size__c = 'L'
        );
        insert prodAttr;

        System.runAs(commUser) {
            Favorite_List__c newList = new Favorite_List__c(
                Name = 'FL01',
                AccountId__c = commUserAccount.Id
            );
            insert newList;

            Favorite_List_Item__c newFLI = new Favorite_List_Item__c(
                ProductId__c = ((Product2) initData.get(B2BDefaultTestData.PRODUCT)).Id,
                Favorite_List_Id__c = newList.Id
            );
            insert newFLI;

            Favorite_List_Item__c newFLIVariation = new Favorite_List_Item__c(
                ProductId__c = testChildProduct.Id,
                Favorite_List_Id__c = newList.Id
            );
            insert newFLIVariation;
        }
    }

    @IsTest
    static void getFavoriteListDetailTest() {
        User commUser =  [SELECT Id, AccountId FROM User WHERE UserName =: TEST_USER_NAME];

        List<Favorite_List__c> listFL = [
            SELECT Id, Name
            FROM Favorite_List__c
            WHERE AccountId__c = :commUser.AccountId
        ];

        Test.startTest();
        System.runAs(commUser) {
            B2BResponse result = B2BFavoriteListDetailController.getFavoriteListDetail(listFL[0].Id, commUser.AccountId);
            System.assertEquals(true, result.isSuccess);
            List<B2BFavoriteListDetailController.FavoriteListItem> listItems = (List<B2BFavoriteListDetailController.FavoriteListItem>)result.responseData;
            System.assertEquals(2, listItems.size());
        }
        Test.stopTest();
    }

    @IsTest
    static void deleteAllFavoriteListItemsTest() {
        User communityUser =  [SELECT Id, AccountId FROM User WHERE UserName =: TEST_USER_NAME];

        List<Favorite_List__c> listFL = [
            SELECT Id, Name
            FROM Favorite_List__c
        ];

        Test.startTest();
        System.runAs(communityUser) {
            B2BResponse result = B2BFavoriteListDetailController.deleteAllFavoriteListItems(listFL[0].Id);
            System.assertEquals(true, result.isSuccess);
        }
        Test.stopTest();
    }

    @IsTest
    static void deleteFavoriteListItemsTest() {
        User communityUser =  [SELECT Id, AccountId FROM User WHERE UserName =: TEST_USER_NAME];

        List<Favorite_List_Item__c> listFLI = [
            SELECT Id, Name
            FROM Favorite_List_Item__c
        ];

        Test.startTest();
        System.runAs(communityUser) {
            B2BResponse result = B2BFavoriteListDetailController.deleteFavoriteListItems(new List<Id>{listFLI[0].Id});
            System.assertEquals(true, result.isSuccess);
        }
        Test.stopTest();
    }
}