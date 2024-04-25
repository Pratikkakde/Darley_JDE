@IsTest
private without sharing class B2BQuoteManagementControllerTest {

    @TestSetup
    private static void makeData() {
        new B2BDefaultTestData().initAllData();
    }

    @IsTest
    static void initData() {
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];

        Test.startTest();
        System.runAs(communityUser) {
            B2BResponse resultResponse = B2BQuoteManagementController.initFilter(communityUser.AccountId);
            Map<String, Object> result = (Map<String, Object>)resultResponse.responseData;

            List<B2BUtils.PicklistEntry> statusOptions = (List<B2BUtils.PicklistEntry>)result.get('statusOptions');
            System.assert(statusOptions.size() > 0, 'Status Options should be exist.');

            List<Quote__c> quotes = (List<Quote__c>)result.get('quotes');
            System.assertEquals(quotes.size(), 0, 'Order Summary records are not existed.');
        }
        Test.stopTest();
    }

    @IsTest
    static void testFilter() {
        User communityUser = [SELECT Id, AccountId  FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        Contact contact = [SELECT Id FROM Contact WHERE AccountId = :communityUser.AccountId LIMIT 1];

        Product2 testParentProduct = new Product2(
            Name = 'Parent Product',
            IsActive = true,
            ProductCode = 'PAReNT-CODE',
            Type = 'Base'
        );
        insert testParentProduct;

        List<Product2> products = [SELECT Id, Type, Name, ProductClass FROM Product2 WHERE Name = 'Test Product'];

        ProductCategory prodCat = [
            SELECT Id
            FROM ProductCategory
            LIMIT 1
        ];
        ProductCategoryProduct testProductCategoryProduct = new ProductCategoryProduct(
            ProductCategoryId = prodCat.Id,
            ProductId = testParentProduct.Id
        );
        insert testProductCategoryProduct;

        CommerceEntitlementPolicy entitlementPolicy = new CommerceEntitlementPolicy(
            Name = 'Test Ent Policy1',
            IsActive = TRUE,
            CanViewPrice = TRUE,
            CanViewProduct = TRUE
        );
        insert entitlementPolicy;

        CommerceEntitlementProduct commerceEntitlementProduct = new CommerceEntitlementProduct(
            ProductId = testParentProduct.Id,
            PolicyId = entitlementPolicy.Id
        );
        insert commerceEntitlementProduct;

        ProductAttributeSet productAttributeSet = [SELECT Id, DeveloperName FROM ProductAttributeSet WHERE DeveloperName = 'AS_ColorSize'];

        ProductAttributeSetProduct prodAttrSetProd = new ProductAttributeSetProduct(
            ProductAttributeSetId = productAttributeSet.Id,
            ProductId = testParentProduct.Id
        );
        insert prodAttrSetProd;

        ProductAttribute prodAttr = new ProductAttribute(
            ProductId = products[0].Id,
            VariantParentId = testParentProduct.Id,
            Color__c = 'Blue',
            Size__c = 'L'
        );
        insert prodAttr;

        System.runAs(communityUser) {
            WebCart webCart = [SELECT Id FROM WebCart LIMIT 1];
            B2BResponse newQuoteResult = B2BQuoteManagementController.createQuote(
                webCart.Id,
                communityUser.AccountId,
                'comment'
            );

            System.assert(true, newQuoteResult.isSuccess);
            Map<String, String> result = (Map<String, String>) newQuoteResult.responseData;

            B2BResponse cartItemResult = B2BQuoteManagementController.getCartItem(result.get('id'));
            System.assert(true, cartItemResult.isSuccess);

            Test.startTest();
            B2BQuoteManagementController.FilterDto filter = new B2BQuoteManagementController.FilterDto();
            filter.accountId = communityUser.AccountId;

            B2BResponse resultResponse = B2BQuoteManagementController.getQuotes(filter);
            List<Quote__c> quotes = (List<Quote__c>)resultResponse.responseData;
            System.assertEquals(quotes.size(), 1, 'Amount of quotes records should be 1.');

            Quote__c testQuote = [SELECT Id, Name, Status__c FROM Quote__c LIMIT 1];
            filter.status = testQuote.Status__c;
            filter.search = testQuote.Name;
            resultResponse = B2BQuoteManagementController.getQuotes(filter);
            quotes = (List<Quote__c>)resultResponse.responseData;
            System.assertEquals(quotes.size(), 1, 'Amount of quotes records should be 1.');

            filter.search = testQuote.Name + 'Test';
            resultResponse = B2BQuoteManagementController.getQuotes(filter);
            quotes = (List<Quote__c>)resultResponse.responseData;
            System.assertEquals(quotes.size(), 0, 'Amount of quotes records should be 0.');
        }
        Test.stopTest();
    }
}