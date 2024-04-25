/**
 * Created by IrinaSakovich on 30/11/2022.
 */

@IsTest
public with sharing class B2BQuickOrderTestData {
    public static final String SYSTEM_ADMINISTRATOR_PROFILE = 'System Administrator';
    public static final String COMMUNITY_PROFILE = 'B2B Commerce User';
    public static final String COMMUNITY_PERM_SET = 'B2B_Commerce_User';
    public static final String TEST_USER_NAME = 'TestUserName@test.com';
    public static final String TEST_CSV_DATA = 'SKU' + ',' + 'Quantity' + '\n';

    public static void setupQuickOrderTestData() {
        ContentVersion cv = new ContentVersion();
        cv.Title = 'testSample';
        cv.PathOnClient = 'test';
        cv.VersionData = Blob.valueOf(TEST_CSV_DATA);
        insert cv;

        List<Product2> product2s = new List<Product2>();
        product2s.add(new Product2(Name = 'TestProduct', StockKeepingUnit = '10000-min', IsActive = true));
        product2s.add(new Product2(Name = 'Test2Product', StockKeepingUnit = '10000-max'));
        product2s.add(new Product2(Name = 'Test3Product', StockKeepingUnit = '10000-px'));
        product2s.add(new Product2(Name = 'Test4Product', StockKeepingUnit = '10000-ss', IsActive = true));
        product2s.add(new Product2(Name = 'Test5Product', StockKeepingUnit = '10001', IsActive = true));
        insert product2s;

        PurchaseQuantityRule rule = new PurchaseQuantityRule(
            Name = 'test',
            Increment = 11,
            Minimum = 11,
            Maximum = 1100
        );
        insert rule;

        ProductQuantityRule productRule = new ProductQuantityRule(
            ProductId = [SELECT Id FROM Product2 WHERE Name = 'TestProduct' LIMIT 1]?.Id,
            PurchaseQuantityRuleId = rule.Id
        );
        insert productRule;

        PurchaseQuantityRule rule2 = new PurchaseQuantityRule(
            Name = 'test2',
            Increment = 2,
            Minimum = 2,
            Maximum = 600
        );
        insert rule2;

        Product2 validProduct = [SELECT Id FROM Product2 WHERE Name = 'Test4Product' LIMIT 1];

        ProductQuantityRule productRule2 = new ProductQuantityRule(
            ProductId = validProduct?.Id,
            PurchaseQuantityRuleId = rule2.Id
        );
        insert productRule2;

        ProductCatalog testCatalog = new ProductCatalog(Name = 'TestCatalog');
        insert testCatalog;

        ProductCategory category = new ProductCategory(
            Name = 'TestCategory',
            CatalogId = testCatalog.Id,
            IsNavigational = true
        );
        insert category;

        ProductCategoryProduct testProductCategoryProduct = new ProductCategoryProduct(
            ProductCategoryId = category.Id,
            ProductId = validProduct?.Id
        );
        insert testProductCategoryProduct;

        Account account = B2BTestDataFactory.createAccount(false, 'testCustomerAccount');
        account.BillingCity = 'Chicago';
        account.BillingCountry = 'United States';
        insert account;

        Contact contact = new Contact(
            LastName = 'testCustomerContact',
            AccountId = account.Id
        );
        insert contact;

        List<User> users = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = :SYSTEM_ADMINISTRATOR_PROFILE AND IsActive = TRUE AND UserRoleId != NULL LIMIT 1];
        if (users[0].UserRoleId == null) {
            users[0].UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1].Id;
            update users[0];
        }

        User testUser;
        System.runAs(users[0]) {
            Profile profile = [SELECT Id, Name FROM Profile WHERE Name = :COMMUNITY_PROFILE LIMIT 1];

            testUser = new User();
            testUser.Email = 'TestEmail@test.coom';
            testUser.Username = TEST_USER_NAME;
            testUser.Alias = 'alias';
            testUser.TimeZoneSidKey = System.UserInfo.getTimeZone().getID();
            testUser.EmailEncodingKey = 'ISO-8859-1';
            testUser.LocaleSidKey = 'en_US';
            testUser.LanguageLocaleKey = 'en_US';
            testUser.FirstName = 'Ivan';
            testUser.LastName = 'Ivanov';
            testUser.IsActive = true;
            testUser.ContactId = contact.Id;
            testUser.ProfileId = profile.Id;
            insert testUser;

            List<PermissionSet> b2bPermSet = [SELECT Id FROM PermissionSet WHERE Name = :COMMUNITY_PERM_SET];
            if (b2bPermSet.isEmpty()) {
                return;
            }

            PermissionSetAssignment b2bPermSetAssignment = new PermissionSetAssignment(
                AssigneeId = testUser.Id,
                PermissionSetId = b2bPermSet[0].Id
            );
            insert b2bPermSetAssignment;
        }

        Pricebook2 pricebook = new Pricebook2(
            Name = 'Test Customer Price Book',
            IsActive = true
        );
        insert pricebook;

        PricebookEntry pricebookEntry = new PricebookEntry(
            Product2Id = validProduct.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            IsActive = true,
            UnitPrice = 100
        );
        insert pricebookEntry;

        pricebookEntry = new PricebookEntry(
            Product2Id = validProduct.Id,
            Pricebook2Id = pricebook.Id,
            IsActive = true,
            UnitPrice = 100
        );
        insert pricebookEntry;

        BuyerGroup buyerGroup = new BuyerGroup(
            Name = 'Test Buyer Group'
        );
        insert buyerGroup;

        BuyerAccount buyerAccount = new BuyerAccount(
            Name = 'Test Buyer Account Name',
            CommerceType = 'Buyer',
            BuyerId = account.Id,
            IsActive = true
        );
        insert buyerAccount;

        BuyerGroupMember buyerGroupMember = new BuyerGroupMember(
            BuyerGroupId = buyerGroup.Id,
            BuyerId = account.Id
        );
        insert buyerGroupMember;

        BuyerGroupPricebook BuyerGroupPricebook = new BuyerGroupPricebook(
            BuyerGroupId = buyerGroup.Id,
            Pricebook2Id = pricebook.Id,
            IsActive = true
        );
        insert BuyerGroupPricebook;

        CommerceEntitlementPolicy entitlementPolicy = new CommerceEntitlementPolicy(
            Name = 'Test Entitlement Policy',
            IsActive = true
        );
        insert entitlementPolicy;

        CommerceEntitlementBuyerGroup entitlementBuyerGroup = new CommerceEntitlementBuyerGroup(
            BuyerGroupId = buyerGroup.Id,
            PolicyId = entitlementPolicy.Id
        );
        insert entitlementBuyerGroup;

        CommerceEntitlementProduct entitlementProduct = new CommerceEntitlementProduct(
            ProductId = validProduct.Id,
            PolicyId = entitlementPolicy.Id
        );
        insert entitlementProduct;
    }
}