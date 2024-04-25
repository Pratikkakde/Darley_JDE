@isTest
private class B2BProductDetailVariationControllerTest {
/*    
    @TestSetup
    private static void makeData() {
        new B2BDefaultTestData().initAllData();
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
        
        ProductAttributeSet productAttributeSet;
        List<ProductAttributeSet> productAttributeSetList = [SELECT Id, DeveloperName FROM ProductAttributeSet WHERE DeveloperName = 'AS_ColorSize'];
        if(productAttributeSetList.isEmpty()) {
			productAttributeSet = new ProductAttributeSet(DeveloperName = 'AS_ColorSize', MasterLabel = 'AS_ColorSize');
            List<User> users = [SELECT Id, Username, UserRole.Name, UserRoleId FROM User WHERE Profile.Name = :B2BDefaultTestData.SYSTEM_ADMINISTRATOR_PROFILE AND IsActive = TRUE LIMIT 1];
            System.runAs(users[0]) {
            	insert productAttributeSet;
            }
        }else {
            productAttributeSet = productAttributeSetList[0];
        }
        
        
        ProductAttributeSetItem item = new ProductAttributeSetItem(Field = 'Size__c', ProductAttributeSetId = productAttributeSet.Id, Sequence = 1);
        insert item;
        
        ProductAttribute prodAttr = new ProductAttribute(
            ProductId = products[0].Id,
            Sequence = 1,
            VariantParentId = testParentProduct.Id
        );
        insert prodAttr;  
        
        ProductAttributeSetProduct prodAttrSetProd = new ProductAttributeSetProduct(
            ProductAttributeSetId = productAttributeSet.Id,
            ProductId = testParentProduct.Id
        );
        insert prodAttrSetProd;  
        
        
    }
*/
    //I could not get the above setup method to work to save my life
    //Using SeeAllData=true to avoid all that setup
    @isTest(SeeAllData=true)
    static void testIsRequestQuoteEnabled() {
        new B2BDefaultTestData().initAllData();
        User communityUser = [SELECT Id, AccountId  FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        Product2 testParentProduct = [SELECT Id FROM Product2 WHERE ProductClass = :B2BProductDetailVariationController.CLASS_VARIATION_PARENT LIMIT 1];
        B2BResponse response;
        Test.startTest();
        System.runAs(communityUser) {
            response = B2BProductDetailVariationController.getVariations(testParentProduct.Id);
        }
        Test.stopTest();
        System.assert(response.isSuccess,'The response must be success');
    }
}