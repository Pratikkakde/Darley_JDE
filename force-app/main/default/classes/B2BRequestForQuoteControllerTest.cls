@IsTest
private class B2BRequestForQuoteControllerTest {
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

        List<WebCart> carts = [SELECT Id, B2BCheckoutShippingAddress__c FROM WebCart];

        ContactPointAddress adrress =  new ContactPointAddress(
                Name = 'testName',
                Street = 'testStreet',
                City = 'Chicago',
                State = 'Alaska',
                PostalCode = '100000',
                CountryCode = 'US',
                AddressType = 'Billing',
                ParentId = [SELECT Id FROM Account].get(0).Id
        );
        insert adrress;
        
        for (WebCart cart : carts) {
            cart.B2BCheckoutShippingAddress__c = adrress.Id;
        }
        update carts;
        
    }

    @IsTest
    static void testIsRequestQuoteEnabled() {
        User communityUser = [SELECT Id, AccountId  FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        Contact contact = [SELECT Id FROM Contact WHERE AccountId = :communityUser.AccountId LIMIT 1];
        B2BResponse response;
        Test.startTest();
        System.runAs(communityUser) {
            response = B2BRequestForQuoteController.isRequestQuoteEnabled(communityUser.AccountId);
        }
        Test.stopTest();
        System.assert(response.isSuccess,'The reponse must be success');
    }

    @IsTest
    static void testGetCartId(){
        User communityUser = [SELECT Id, AccountId  FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        B2BResponse response;
        Test.startTest();
        System.runAs(communityUser) {
            response = B2BRequestForQuoteController.getCartId(communityUser.AccountId);
        }
        Test.stopTest();
        System.assert(response.isSuccess,'The reponse must be success');
        Id cartId = (Id) response.responseData;

        System.assertEquals(WebCart.SObjectType, cartId.getSobjectType(), 'An WebCart Id mut be returned');
    }

    @IsTest
    static void testGetQuoteRequestDetail() {
        User communityUser = [SELECT Id, AccountId  FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        Contact contact = [SELECT Id FROM Contact WHERE AccountId = :communityUser.AccountId LIMIT 1];
        WebCart cart = [SELECT Id ,B2BCheckoutShippingAddress__c FROM WebCart];
        List<CartItem> cartItems = [SELECT Id FROM CartItem WHERE CartId = :cart.Id];

        B2BResponse response;
        Test.startTest();
        System.runAs(communityUser) {
            Test.setMock(HttpCalloutMock.class, new B2BAvalaraTest.B2BAvalaraMock(false, cartItems));
            response = B2BRequestForQuoteController.getQuoteRequestDetail(communityUser.AccountId, cart.Id);
        }
        Test.stopTest();
        System.assert(response.isSuccess,'The reponse must be success');
        B2BRequestForQuoteController.QuoteRequestDetail quoteRequestDetail = (B2BRequestForQuoteController.QuoteRequestDetail) response.responseData;
        System.assertEquals(1,quoteRequestDetail.quoteDetail.quoteLineItemDetails.size(), 'One quote line Item must be returned.');
    }

    @IsTest
    static void testUpdateCartCheckoutShippingAddress() {
        User communityUser = [SELECT Id, AccountId  FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        WebCart cart = [SELECT Id ,B2BCheckoutShippingAddress__c FROM WebCart];
        ContactPointAddress address = [SELECT Id FROM ContactPointAddress];

        B2BResponse response;
        Test.startTest();
        System.runAs(communityUser) {
            response = B2BRequestForQuoteController.updateCartCheckoutShippingAddress(cart.Id, address.Id, address.Id);
        }
        Test.stopTest();
        System.assert(response.isSuccess,'The reponse must be success');
    }

    @IsTest
    static void testSaveQuoteRequest() {
        User communityUser = [SELECT Id, AccountId, ContactId  FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        WebCart cart = [SELECT Id, B2BCheckoutShippingAddress__c  FROM WebCart];
        List<CartItem> cartItems = [SELECT Id FROM CartItem WHERE CartId = :cart.Id];

        B2BResponse response;
        Test.startTest();
        System.runAs(communityUser) {
            B2BRequestForQuoteController.SaveQuoteResquet saveQuoteResquet = new  B2BRequestForQuoteController.SaveQuoteResquet();
            saveQuoteResquet.effectiveAccountId = communityUser.AccountId;
            saveQuoteResquet.cartId = cart.Id;
            saveQuoteResquet.message = 'test message';
            saveQuoteResquet.quoteEstimatedTax = 10;
            saveQuoteResquet.shippingAddressId = cart.B2BCheckoutShippingAddress__c;
            saveQuoteResquet.billingAddressId = cart.B2BCheckoutShippingAddress__c;
            response = B2BRequestForQuoteController.saveQuoteRequest(saveQuoteResquet );
        }

        Test.stopTest();
        System.assert(response.isSuccess,'The reponse must be success');
        List<Quote__c> quotes = [SELECT Id FROM Quote__c]; 
        System.assertEquals(1, quotes.size(), '1 Quote must be created');
        List<QuoteItem__c> quoteItems =  [SELECT Id FROM QuoteItem__c WHERE Quote__c =:quotes.get(0).Id]; 
        System.assertEquals(1, quoteItems.size(), '1 QuoteItem__c must be created');
    }

    @IsTest
    static void testGetCountryStateFieldsPicklistOptions() {
        User communityUser = [SELECT Id, AccountId  FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        Contact contact = [SELECT Id FROM Contact WHERE AccountId = :communityUser.AccountId LIMIT 1];
        B2BResponse response;
        Test.startTest();
        System.runAs(communityUser) {
            response = B2BRequestForQuoteController.getCountryStateFieldsPicklistOptions();
        }
        Test.stopTest();
        System.assert(response.isSuccess,'The reponse must be success');
        Map<String, Object>  mapResponse = (Map<String,Object>) response.responseData;
        System.assertEquals(2,mapResponse.size(),'Must return two elemements');

    }

    @IsTest
    static void testCreateAddress() {
        User communityUser = [SELECT Id, AccountId  FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        Contact contact = [SELECT Id FROM Contact WHERE AccountId = :communityUser.AccountId LIMIT 1];
        delete [SELECT Id FROM ContactPointAddress];
        B2BResponse response;
        Test.startTest();
        System.runAs(communityUser) {
            response = B2BRequestForQuoteController.createAddress(new ContactPointAddress(
                Name = 'testName',
                Street = 'testStreet',
                City = 'Chicago',
                State = 'Alaska',
                PostalCode = '100000',
                CountryCode = 'US',
                AddressType = 'Billing',
                ParentId = communityUser.AccountId
            ) );
        }
        Test.stopTest();
        System.assert(response.isSuccess,'The reponse must be success');
        List<ContactPointAddress> addresses = [SELECT Id FROM ContactPointAddress WHERE ParentId =: communityUser.AccountId];
        System.assertEquals(1, addresses.size(),'Must Create a ContactPointAddress record');
    }

    @IsTest
    static void testGetCustomerTaxInfo() {
        User communityUser = [SELECT Id, AccountId  FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        WebCart cart = [SELECT Id, B2BCheckoutShippingAddress__c  FROM WebCart];
        Contact contact = [SELECT Id FROM Contact WHERE AccountId = :communityUser.AccountId LIMIT 1];
        B2BResponse response;
        Test.startTest();
        System.runAs(communityUser) {
            response = B2BRequestForQuoteController.getCustomerTaxInfo(cart.Id);
        }
        Test.stopTest();
        System.assert(response.isSuccess,'The reponse must be success');
        Map<String, Object>  mapResponse = (Map<String,Object>) response.responseData;
        System.assertEquals(1,mapResponse.size(),'Must return two elemements');
        System.assert(mapResponse.containsKey('customerTaxInformation'), 'Must contain the customerTaxInformation key');
        B2BCheckoutOrderSummary.CustomerTaxInformation customerTaxInfo = (B2BCheckoutOrderSummary.CustomerTaxInformation)mapResponse.get('customerTaxInformation');
        System.assertEquals(communityUser.AccountId, customerTaxInfo.avalaraCustomerCode, 'avalaraCustomerCode should be the same as the user Account Id');
    }
}