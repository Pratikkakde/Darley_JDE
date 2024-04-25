@IsTest
public with sharing class B2BTestDataFactoryTest {
    @IsTest
    public static void testInitAllData() {
        B2BTestDataFactory factory = new B2BTestDataFactory();
        factory.initAllData();
        List<Account> acc = [SELECT Id FROM Account];
        System.assertEquals(1, acc.size());
    }

    @IsTest
    public static void testInitPartialData() {
        B2BTestDataFactory factory = new B2BTestDataFactory();
        factory.initCustomerUserData();
        factory.initProductData();
        factory.initBuyerGroupsData();
        List<Account> acc = [SELECT Id FROM Account];
        System.assertEquals(1, acc.size());
    }

    @IsTest
    public static void initCartDataTest() {
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initCartData(true, true);
        System.assert(initData.get(B2BDefaultTestData.CART) != null);
    }

    @IsTest(SeeAllData=true)
    public static void initOrderData() {
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initOrderData();
        System.assert(initData.get(B2BDefaultTestData.ORDER_SUMMARY) != null);
    }

    @IsTest
    public static void checkEntitlement() {
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initAllData();
        BuyerGroup buyerGroup = ((BuyerGroup) initData.get(B2BDefaultTestData.BUYER_GROUP));

        List<Product2> products = [SELECT Id FROM Product2];

        CommerceEntitlementPolicy entitlementPolicy = B2BTestDataFactory.creteEntitlementPolicy(true);
        B2BTestDataFactory.crateCommerceEntitlementProduct(products[0].Id, entitlementPolicy.Id);
        B2BTestDataFactory.assignEntitlementPolicyToBuyerGroup(buyerGroup.Id, entitlementPolicy.Id);

        CommerceEntitlementPolicy entitlementPolicyTest = [SELECT Id FROM CommerceEntitlementPolicy LIMIT 1];
        System.assertEquals(entitlementPolicyTest.Id, entitlementPolicy.Id, 'CommerceEntitlementPolicy record was not created.');
    }

    @IsTest
    public static void checkGuestUser() {
        User guestUser = B2BTestDataFactory.createGuestUser(true, 'testGuestUser@email.com');
        User guestUserTest = [SELECT Id FROM User WHERE Username = 'testGuestUser@email.com' ];
        System.assertEquals(guestUser.Id, guestUserTest.Id, 'User record was not created.');
    }

    @IsTest
    public static void checkOrders() {
        new B2BDefaultTestData().initAllData();
        Account testAccount = B2BTestDataFactory.createAccount(true, 'Test Negative Account', null, 'Customer', null);
        Order newOrder = B2BTestDataFactory.createOrder(true, testAccount.Id, 'Draft');

        Product2 testProduct = [SELECT Id FROM Product2 WHERE Name = 'Test Product' LIMIT 1];
        OrderItem newOrderItem = B2BTestDataFactory.createOrderItem(true, newOrder.Id, testProduct.Id, 200, 2);

        System.assertEquals([SELECT Id FROM Order].size(), 1, 'Order record was not created.');
        System.assertEquals([SELECT Id FROM OrderItem].size(), 1, 'Order Item record was not created.');
    }

    @IsTest
    public static void checkBuyerData() {
        Account newAccount = B2BTestDataFactory.createAccount(false, 'Test_Name', null, 'Customer', null);
        newAccount.AccountNumber = 'Test_Name';
        insert newAccount;
        B2BTestDataFactory.createBuyerData(newAccount.Id, 'Example Buyer Group');

        System.assertEquals([SELECT Id FROM BuyerAccount].size(), 1, 'Buyer Account record was not created.');

    }

    @IsTest
    public static void checkUtilMethods() {
        new B2BDefaultTestData().initAllData();
        Account testAccount = B2BTestDataFactory.createAccount(true, 'Test Negative Account', null, 'Customer', null);
        Product2 testProduct = [SELECT Id FROM Product2 WHERE Name = 'Test Product' LIMIT 1];

        Map<String, String> productIdToQtyMap = new Map<String, String>{
            testProduct.Id => '1'
        };

        B2BUtils.addProductsToCart(productIdToQtyMap, testAccount.Id);

        User testUser = [SELECT Id FROM User LIMIT 1];
        B2BUtils.getPermissionSetAssignment(testUser.Id);

        String validForBits = B2BUtils.base64ToBits('Test String');
        B2BUtils.getCommerceUserProfileId();
        
        String webStoreId = B2BUtils.getStoreIdRelatedToCurrentUser();
        B2BUtils.getDefaultProductImageURLByProductId(testProduct.Id, webStoreId);

        List<B2BUtils.PicklistEntry> entries = new List<B2BUtils.PicklistEntry>();
        entries.addAll(B2BUtils.getPicklistValues(Contact.SObjectType.getDescribe().getName(), Contact.LeadSource.getDescribe().getName()));
        System.assert(!entries.isEmpty(), 'Picklist Entry list should not be empty.');
    }

    @IsTest
    public static void checkCreateMethods() {
        Integer accToCreate = 100;
        Integer ordersToCreate = 4;
        Test.startTest();
            List<Account> accounts = B2BTestDataFactory.createAccounts(accToCreate, true);
            Map<Id, Contact> accContactsMap = B2BTestDataFactory.createContacts(accounts, true);
            Map<Id, Contract> AccContractsMap = B2BTestDataFactory.createContracts(accounts, true);
            Map<Id, List<Order>> accOrdersMap = B2BTestDataFactory.createOrders(AccContractsMap, ordersToCreate, true);
            Map<Id, List<DarleyDollar__c>> AccDarleyDollarMap = B2BTestDataFactory.createDarleyDollars(accOrdersMap, accContactsMap, true);
            Quote__c newQuote = B2BTestDataFactory.createQuote(accounts[0].Id, accContactsMap.get(accounts[0].Id).Id, true, 'Description1');
        Test.stopTest();
        System.assertEquals(accToCreate, [SELECT count() FROM Account WHERE Name LIKE 'AccountTestDD%']);
        System.assertEquals(accToCreate, [SELECT count() FROM Contact WHERE AccountId IN :accOrdersMap.keySet()]);
        System.assertEquals(accToCreate, [SELECT count() FROM Contract WHERE AccountId IN :accOrdersMap.keySet()]);
        System.assertEquals(accToCreate*ordersToCreate, [SELECT count() FROM Order WHERE AccountId IN :accOrdersMap.keySet()]);
        System.assertEquals(accToCreate*ordersToCreate, [SELECT count() FROM DarleyDollar__c WHERE Contact__r.AccountId IN :accOrdersMap.keySet()]);
        System.assertEquals(1, [SELECT Id FROM Quote__c WHERE Id =:newQuote.Id].size());
    }   

    @IsTest
    public static void updateOptoutFromDarleyDollarsAccountTest() {
        Integer accToCreate = 100;
        List<Account> accounts = B2BTestDataFactory.createAccounts(accToCreate, true);
        List<Account> updatedAccounts = B2BTestDataFactory.updateOptoutFromDarleyDollarsAccount(accounts, true, false);
        Integer accBefore = [SELECT count() FROM Account WHERE Name LIKE 'AccountTestDD%' AND OptoutFromDarleyDollars__c = true];
        Test.startTest();
            update updatedAccounts;
        Test.stopTest();
        System.assertEquals(0, accBefore);
        System.assertEquals(accToCreate, [SELECT count() FROM Account WHERE Name LIKE 'AccountTestDD%' AND OptoutFromDarleyDollars__c = true]);   
    }  
    
    @IsTest
    public static void testCreateContactPointAddress() {
        Test.startTest();
            List<Account> accounts = B2BTestDataFactory.createAccounts(1, true);
            Map<String, Object> contactPointAddressMap = B2BTestDataFactory.createContactPointAddress(true, accounts[0].Id, 'Billing', true);
        Test.stopTest();
        List<ContactPointAddress> createdContactPointAddress = [SELECT Name FROM ContactPointAddress WHERE Name = 'Address Name'];
        System.assertEquals(1, createdContactPointAddress.size()); 
    }  

    @IsTest
    public static void testMakeUserSuperUSer() {
        B2BDefaultTestData testData = new B2BDefaultTestData();
        testData.initCustomerUserData();
        User communitySuperUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        List<PermissionSet> b2bPermSet = [SELECT Id FROM PermissionSet WHERE Name = 'B2B_Commerce_Super_User'];
        System.runAs(new User(Id = userinfo.getUserId())){
            Test.startTest();
                B2BTestDataFactory.makeUserSuperUSer(communitySuperUser);
            Test.stopTest();
        }  
        List<PermissionSetAssignment> permissionSetAssignment = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId =: b2bPermSet[0].Id AND AssigneeId =: communitySuperUser.Id];
        System.assertEquals(1, permissionSetAssignment.size()); 
    } 

}