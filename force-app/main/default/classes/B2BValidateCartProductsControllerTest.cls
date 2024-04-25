@IsTest
private  class B2BValidateCartProductsControllerTest {
    @TestSetup
    private static void makeData() {
        new B2BDefaultTestData().initAllData();

        List<Product2> newProducts = new List<Product2>();

        newProducts.add(new Product2 (
            Name = 'Parent Product',
            IsActive = true,
            ProductCode = 'PAReNT-CODE',
            Type = 'Base'
        ));

        newProducts.add(new Product2 (
            Name = 'Quote Only Product',
            IsActive = true,
            ProductCode = 'QUOTEe-CODE'
        ));

        insert newProducts;

        List<Product2> products = [SELECT Id, Type, Name, ProductClass FROM Product2 WHERE Name = 'Test Product'];

        ProductCategory prodCat = [SELECT Id FROM ProductCategory LIMIT 1];
        ProductCategoryProduct testProductCategoryProduct = new ProductCategoryProduct(
            ProductCategoryId = prodCat.Id,
            ProductId = newProducts.get(0).Id
        );
        insert testProductCategoryProduct;

        List<CommerceEntitlementPolicy> newEntitlementPolicies = new List<CommerceEntitlementPolicy>();

        newEntitlementPolicies.add(new CommerceEntitlementPolicy(
            Name = 'Test Ent Policy1',
            IsActive = TRUE,
            CanViewPrice = TRUE,
            CanViewProduct = TRUE
        ));

        newEntitlementPolicies.add(new CommerceEntitlementPolicy(
            Name = 'Quote Only',
            IsActive = true,
            CanViewPrice = true,
            CanViewProduct = true
        ));

        insert newEntitlementPolicies;

        List<CommerceEntitlementProduct> newCommerceEntitlementProducts = new List<CommerceEntitlementProduct>();

        newCommerceEntitlementProducts.add(new CommerceEntitlementProduct(
            ProductId = newProducts.get(0).Id,
            PolicyId = newEntitlementPolicies.get(0).Id
        ));

        newCommerceEntitlementProducts.add(new CommerceEntitlementProduct(
            ProductId = newProducts.get(1).Id,
            PolicyId = newEntitlementPolicies.get(1).Id
        ));

        insert newCommerceEntitlementProducts;

        ProductAttributeSet productAttributeSet = [SELECT Id, DeveloperName FROM ProductAttributeSet WHERE DeveloperName = 'AS_ColorSize'];

        ProductAttributeSetProduct prodAttrSetProd = new ProductAttributeSetProduct(
            ProductAttributeSetId = productAttributeSet.Id,
            ProductId = newProducts.get(0).Id
        );
        insert prodAttrSetProd;

        ProductAttribute prodAttr = new ProductAttribute(
            ProductId = products[0].Id,
            VariantParentId = newProducts.get(0).Id,
            Color__c = 'Blue',
            Size__c = 'L'
        );
        insert prodAttr;
    }

    @IsTest
    static void validateCartProductsTest() {
        User communityUser = [SELECT Id, AccountId  FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        B2BResponse response;
        Test.startTest();
        System.runAs(communityUser) {
            response = B2BValidateCartProductsController.validateCartProducts(communityUser.AccountId);
        }
        Test.stopTest();
        System.assert(response.isSuccess,'The reponse must be success');
        List<CartItem> cartItemsDelete = (List<CartItem>) response.responseData;
        System.assertEquals(2, cartItemsDelete.size(), '2 products must be invalid');
    }

    @IsTest
    static void validateCartProductsByCartTest() {
        User communityUser = [SELECT Id, AccountId  FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        WebCart cart = [SELECT Id FROM WebCart LIMIT 1];
        B2BResponse response;
        Test.startTest();
        System.runAs(communityUser) {
            response = B2BValidateCartProductsController.validateCartProductsByCart(cart.Id);
        }
        Test.stopTest();
        System.assert(response.isSuccess,'The reponse must be success');
        List<CartItem> cartItemsDelete = (List<CartItem>) response.responseData;
        System.assertEquals(2, cartItemsDelete.size(), '2 products must be invalid');
    }

    @IsTest
    static void validateCartProductByCartTest() {
        User communityUser = [SELECT Id, AccountId  FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        CartItem item = [SELECT Id, cartId, Product2Id FROM CartItem LIMIT 1];
        B2BResponse response;
        Test.startTest();
        System.runAs(communityUser) {
            response = B2BValidateCartProductsController.validateCartProductByCart(item.cartId, item.Product2Id );
        }
        Test.stopTest();
        System.assert(response.isSuccess,'The reponse must be success');
        List<CartItem> cartItemsDelete = (List<CartItem>) response.responseData;
        System.assertEquals(1, cartItemsDelete.size(), '1 product must be invalid');
    }

    @IsTest
    static void thereAreQuoteOnlyProductsTest() {
        User communityUser = [SELECT Id, AccountId  FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        
        List<Product2> products = [SELECT Id, Name FROM Product2 WHERE Name = 'Quote Only Product'];
        
        List<WebCart> cart = [
            SELECT Id
            FROM WebCart
            ORDER BY CreatedDate DESC 
            LIMIT 1
        ];

        Id cartId = cart[0].Id;

        List<CartDeliveryGroup> cartDeliveryGroups= [
            SELECT Id
            FROM CartDeliveryGroup
            WHERE Name = 'Cart Delivery Group'
            LIMIT 1
        ];

        cartItem newCartItem = new cartItem(
            Product2Id = products.get(0).Id,
            Quantity = 10,
            SalesPrice = 100,
            ListPrice = 100,
            CartId = cartId,
            CartDeliveryGroupId = cartDeliveryGroups.get(0).Id,
            Name = 'CartItem',
            Type = 'Product'
        );
       
        insert newCartItem;

        Boolean response;
        Test.startTest();
        System.runAs(communityUser) {
            response = B2BValidateCartProductsController.thereAreQuoteOnlyProducts(cartId);
        }
        Test.stopTest();

        System.assertEquals(true, response, 'Response is true for items in Quote Only Entitlement Policy');
    }

    @IsTest
    static void thereAreQuoteOnlyProductsNegativeTest() {
        User communityUser = [SELECT Id, AccountId  FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        
        List<WebCart> cart = [
            SELECT Id
            FROM WebCart
            ORDER BY CreatedDate DESC 
            LIMIT 1
        ];

        Id cartId = cart[0].Id;

        Boolean response;
        Test.startTest();
        System.runAs(communityUser) {
            response = B2BValidateCartProductsController.thereAreQuoteOnlyProducts(cartId);
        }
        Test.stopTest();

        System.assertEquals(false, response, 'Response is false for items outside Quote Only Entitlement Policy');
    }
}