public without sharing class B2BTestDataFactory extends B2BDefaultTestData {

    //method inits data from all init methods below
    public override Map<String, Object> initAllData() {
        return super.initAllData();
    }

    //inits WebStore, Account, Contact, User
    public override Map<String, Object> initCustomerUserData() {
        return super.initCustomerUserData();
    }

    //inits WebStore, Catalog, Category, Product, ProductCategoryProduct,
    // PriceBook, PriceBookEntry(Standard and Custom), WebStorePricebook
    public override Map<String, Object> initProductData() {
        return super.initProductData();
    }

    //inits WebStore, Account, PriceBook, BuyerGroup
    // BuyerAccount, BuyerGroupMember, BuyerGroupPricebook
    public override Map<String, Object> initBuyerGroupsData() {
        return super.initBuyerGroupsData();
    }

    //inits WebStore, Account, Contact, User
    // Product, Cart, CartDeliveryGroup, CartItem
    // CartTax if initTax - true
    // Product for shipping, Cart Item for Shipping if initShipping - true
    public override Map<String, Object> initCartData(Boolean initTax, Boolean initShipping) {
        return super.initCartData(initTax, initTax);
    }

    //inits Order, OrderDeliveryMethod, OrderDeliveryGroup, OrderItem, OrderSummary (used ConnectApi)
    public override Map<String, Object> initOrderData() {
        return super.initOrderData();
    }

    public static CommerceEntitlementPolicy creteEntitlementPolicy(Boolean toInsert) {
        CommerceEntitlementPolicy entitlementPolicy = new CommerceEntitlementPolicy(
            Name = 'Test Ent Policy',
            IsActive = TRUE,
            CanViewPrice = TRUE,
            CanViewProduct = TRUE
        );

        if (toInsert) {
            insert entitlementPolicy;
        }

        return entitlementPolicy;
    }

    public static void crateCommerceEntitlementProduct(String productId, String EntitlementPolicyId) {
        CommerceEntitlementProduct commerceEntitlementProduct = new CommerceEntitlementProduct(
            ProductId = productId,
            PolicyId = EntitlementPolicyId
        );

        insert commerceEntitlementProduct;
    }

    public static void assignEntitlementPolicyToBuyerGroup(Id buyerGroupId, String entPolicyId) {
        CommerceEntitlementBuyerGroup commerceEntitlementBuyerGroup = new CommerceEntitlementBuyerGroup(
            BuyerGroupId = buyerGroupId,
            PolicyId = entPolicyId
        );

        insert commerceEntitlementBuyerGroup;
    }

    public static User createGuestUser(Boolean toInsert, String userName) {
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Guest%' LIMIT 1].Id;
        User guestUser = new User();
        guestUser.Email = 'TestEmail@test.coom';
        guestUser.Username = userName;
        guestUser.Alias = 'alias';
        guestUser.TimeZoneSidKey = 'America/Los_Angeles';
        guestUser.EmailEncodingKey = 'ISO-8859-1';
        guestUser.LocaleSidKey = 'en_US';
        guestUser.LanguageLocaleKey = 'en_US';
        guestUser.FirstName = 'Ivan';
        guestUser.LastName = 'Ivanov';
        guestUser.IsActive = true;
        guestUser.ProfileId = profileId;

        if (toInsert) {
            insert guestUser;
        }
        return guestUser;
    }

//    public override List<PricebookEntry> addProductsToPriceBook(List<Id> productsIds, Id priceBookId, Decimal price) {
//        return super.addProductsToPriceBook(productsIds, priceBookId, price);
//    }

    public static Account createAccount(Boolean toInsert, String accountName) {
        return createAccount(toInsert, accountName, null, null, null);
    }

    public static Account createAccount(Boolean toInsert, String accountName, String productLine, String type, String customerId) {
        if (Test.isRunningTest()) {
            Test.setMock(HttpCalloutMock.class, new B2BDefaultTestData.B2BDefaultTestMock());
        }
        Account acc = new Account(
            Name = accountName,
            BillingCity = 'Chicago',
            BillingCountry = 'United States',
            Type = type
        );

        if (toInsert) {
            insert acc;
        }

        return acc;
    }

//    public static Contact createContact(Boolean toInsert, Account account, String contactLastName, String contactFirstName, String contactEmail) {
//        Contact buyerContact = new Contact();
//
//        buyerContact.AccountId = account.Id;
//        buyerContact.LastName = contactLastName;
//        buyerContact.FirstName = contactFirstName;
//        buyerContact.Email = contactEmail;
//
//        if (toInsert) {
//            insert buyerContact;
//        }
//
//        return buyerContact;
//    }

//    public static User initCommunityUser(Contact contact, String testEmail, String firstName, String lastName) {
//        List<User> users = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = :B2BDefaultTestData.SYSTEM_ADMINISTRATOR_PROFILE AND IsActive = TRUE LIMIT 1];
//
//        User testUser;
//        System.runAs(users[0]) {
//            Profile profile = [SELECT Id, Name FROM Profile WHERE Name = :B2BDefaultTestData.COMMUNITY_PROFILE LIMIT 1];
//
//            testUser = new User();
//            testUser.Email = testEmail;
//            testUser.Username = 'TestUserName@test.com';
//            testUser.Alias = 'alias';
//            testUser.TimeZoneSidKey = 'America/Los_Angeles';
//            testUser.EmailEncodingKey = 'ISO-8859-1';
//            testUser.LocaleSidKey = 'en_US';
//            testUser.LanguageLocaleKey = 'en_US';
//            testUser.FirstName = firstName;
//            testUser.LastName = lastName;
//            testUser.IsActive = true;
//            testUser.ContactId = contact.Id;
//            testUser.ProfileId = profile.Id;
//            insert testUser;
//
//            //assign permission set
//            List<PermissionSet> b2bPermSet = [SELECT Id FROM PermissionSet WHERE Label = :B2BDefaultTestData.COMMUNITY_PERM_SET];
//            if (b2bPermSet.isEmpty() == false) {
//                PermissionSetAssignment b2bPermSetAssignment = new PermissionSetAssignment(
//                    AssigneeId = testUser.Id,
//                    PermissionSetId = b2bPermSet[0].Id
//                );
//
//                insert b2bPermSetAssignment;
//            }
//
//        }
//
//        return testUser;
//    }

//    public static WebStore createWebStore() {
//        WebStore webStore = new WebStore(Name = 'testWebStore');
//        insert webStore;
//
//        return webStore;
//    }

//    public static WebCart createWebCart(Id webStoreId, Id AccountId, Id ownerId) {
//        WebCart testCart = new WebCart(
//            WebStoreId = webStoreId,
//            Name = 'Cart',
//            AccountId = AccountId,
//            Status = 'Active',
//            OwnerId = ownerId
//        );
//        insert testCart;
//
//        return testCart;
//    }

//    public static Pricebook2 createPricebook2() {
//        Pricebook2 pricebook = new Pricebook2(
//                Name = 'Test Customer Price Book',
//                IsActive = true
//        );
//        insert pricebook;
//
//        return pricebook;
//    }


    public static BuyerGroup createBuyerData(Id accountId, String buyerGroupName) {
        BuyerGroup buyerGroup = new BuyerGroup(
            Name = buyerGroupName
        );
        insert buyerGroup;

        BuyerAccount buyerAccount = new BuyerAccount(
            Name = 'Test Buyer Account Name',
            CommerceType = 'Buyer',
            BuyerId = accountId,
            IsActive = true
        );
        insert buyerAccount;

        BuyerGroupMember buyerGroupMember = new BuyerGroupMember(
            BuyerGroupId = buyerGroup.Id,
            BuyerId = accountId
        );
        insert buyerGroupMember;

        return buyerGroup;
    }

    public static Map<String, Object> createContactPointAddress(Boolean toInsert, String accountId, String addressType, Boolean isDefault) {
        ContactPointAddress newContactPointAddress = new ContactPointAddress(
            ParentId = accountId,
            Name = 'Address Name',
            CountryCode = 'US',
            Street = 'Address Street',
            City = 'Address City',
            StateCode = 'AL',
            PostalCode = '12345',
            AddressType = addressType,
            IsDefault = isDefault
        );
 
         Map<String, Object> contactPointAddressMap = new Map<String, Object>();
         contactPointAddressMap.put('addressType', newContactPointAddress.AddressType);
         contactPointAddressMap.put('name', newContactPointAddress.Name);
         contactPointAddressMap.put('countryCode', newContactPointAddress.CountryCode);
         contactPointAddressMap.put('streetAddress', newContactPointAddress.Street);
         contactPointAddressMap.put('city', newContactPointAddress.City);
         contactPointAddressMap.put('provinceCode', newContactPointAddress.StateCode);
         contactPointAddressMap.put('postalCode', newContactPointAddress.PostalCode);
         contactPointAddressMap.put('isDefault', newContactPointAddress.IsDefault);
 
        if (toInsert) {
            insert newContactPointAddress;
            contactPointAddressMap.put('id', newContactPointAddress.Id);
        }
 
        return contactPointAddressMap;
    }

public static Order createOrder(Boolean toInsert, Id accountId, String status) {
    Order order = new Order(
            AccountId = accountId,
            Status = status,
            EffectiveDate = Date.today()
    );
    if (toInsert) {
        insert order;
    }

    return order;
}

    public static OrderItem createOrderItem(Boolean toInsert, Id orderId, Id productId, Decimal price, Decimal qty) {
        OrderItem orderItem = new OrderItem(
            OrderId = orderId,
            Product2Id = productId,
            UnitPrice = price,
            Quantity = qty,
            ListPrice = price
        );

        if (toInsert) {
            insert orderItem;
        }

        return orderItem;
    }

    //Create Accounts 
    public static List<Account> createAccounts(Integer numAccounts,  boolean isInsert) {
        if (Test.isRunningTest()) {
            Test.setMock(HttpCalloutMock.class, new B2BDefaultTestData.B2BDefaultTestMock());
        }
        List<Account> accounts = new List<Account>();

        for (Integer j = 0; j < numAccounts; j++) {
            Account newAccount = new Account( Name = 'AccountTestDD ' + j );
            accounts.add(newAccount);
        }

        if (isInsert) insert accounts;

        return accounts;

    } 
    
    //Update Accounts 
    public static List<Account> updateOptoutFromDarleyDollarsAccount(List<Account> accountstoUpdate, Boolean value, Boolean isUpdate) {
        for (Account account : accountstoUpdate) {
            account.OptoutFromDarleyDollars__c = value;
        }
        if (isUpdate) Update accountstoUpdate;
        return accountstoUpdate;
    }

    //Create Contacts 
    public static Map<Id, Contact> createContacts(List<Account> accounts, boolean isInsert) {

        List<Contact> contactsToInsert = new List<Contact>();
        Map<Id, Contact> accContactsMap = new Map<Id, Contact>();

        for (Account account : accounts) {
            Contact newContact = new Contact( 
                LastName = 'Contact Last Name', 
                AccountId = account.Id 
            );
            contactsToInsert.add(newContact);
            accContactsMap.put(account.Id, newContact);
        }

        if (isInsert) insert contactsToInsert;

        return AccContactsMap;
    } 

    //Create Contracts 
    public static Map<Id, Contract> createContracts(List<Account> accounts,  boolean isInsert) {

        List<Contract> contractsToInsert = new List<Contract>();
        Map<Id, Contract> AccContractsMap = new Map<Id, Contract>();
        
        for (Account account : accounts) {
            Contract newContract = new Contract( 
                AccountId = account.Id,
                status = 'Draft',
                ContractTerm = 3,
                StartDate = Date.today()
            );
            contractsToInsert.add(newContract);  
            AccContractsMap.put(account.Id, newContract);
        }

        if (isInsert) insert contractsToInsert;

        return AccContractsMap;
    } 

     //Create Orders 
    public static Map<Id, List<Order>>  createOrders(Map<Id, Contract> contracts, Integer numOrders,  boolean isInsert) {

        List<Order> ordersToInsert = new List<Order>();
        Map<Id, List<Order>> accContractsMap = new Map<Id, List<Order>>();
        
        for (Id key : contracts.keySet()) {
            List<Order> orders = new List<Order>();
            for (Integer j = 0; j < numOrders; j++) {
                Order newOrder = new Order( 
                    ContractId = contracts.get(key).Id,
                    AccountId = key,
                    status = 'Draft',
                    EffectiveDate = Date.today()
                );
                ordersToInsert.add(newOrder);
                orders.add(newOrder);
            }
            accContractsMap.put(key, orders);
        }

        if (isInsert) insert ordersToInsert;

        return accContractsMap;
    }    

     //Create DarleyDollars 
     public static Map<Id, List<DarleyDollar__c>>  createDarleyDollars(Map<Id, LIST<Order>> orders, Map<Id, Contact> contacts, boolean isInsert) {
        
        List<DarleyDollar__c> darleyDollarsToInsert = new List<DarleyDollar__c>();
        Map<Id, List<DarleyDollar__c>> accDarleyDollarMap = new Map<Id, List<DarleyDollar__c>>();
        
        for (Id key : orders.keySet()) {
            List<DarleyDollar__c> darleyDollars = new List<DarleyDollar__c>();
            for (Order order : orders.get(key)) {
                DarleyDollar__c newDarleyDollar = new DarleyDollar__c(
                    Amount__c = 5,
                    Contact__c = contacts.get(key).Id,
                    Order__c = order.Id,
                    Origin__c = 'Order'
                );
                darleyDollarsToInsert.add(newDarleyDollar);
                darleyDollars.add(newDarleyDollar);
            }
            accDarleyDollarMap.put(key, darleyDollars);
        }

        if (isInsert) insert darleyDollarsToInsert;

        return accDarleyDollarMap;
    }  

    //Create Quote
    public static Quote__c createQuote(Id accountId, Id contactId, boolean isInsert, String description) {
        Quote__c newQuote = new Quote__c( 
            Account__c = accountId, 
            Contact__c = contactId,
            DateRequested__c = Date.today(),
            ChangeRequest__c = description
        );      
        if (isInsert) insert newQuote;
        return newQuote;
    } 

    //Make communityUser Super User
    public static void makeUserSuperUSer(User user){
        List<PermissionSet> b2bPermSet = [SELECT Id FROM PermissionSet WHERE Name = 'B2B_Commerce_Super_User'];
        if (!b2bPermSet.isEmpty()) {
            PermissionSetAssignment b2bPermSetAssignment = new PermissionSetAssignment(
                    AssigneeId = user.Id,
                    PermissionSetId = b2bPermSet[0].Id
            );
            insert b2bPermSetAssignment;
        }
    } 
    
//    public static ContentVersion createContentDocument() {
//        ContentVersion contentVersion = new ContentVersion(
//                Title = 'Test',
//                PathOnClient = 'Test.jpg',
//                VersionData = Blob.valueOf('Test Content Data'),
//                IsMajorVersion = true
//        );
//        insert contentVersion;
//
//        return contentVersion;
//    }
//
//    public static ProductCategory createCategory(Boolean toInsert, Id catalogId, Id parentCategoryId, String name) {
//        ProductCategory category = new ProductCategory(
//                Name = name,
//                CatalogId = catalogId,
//                ParentCategoryId = parentCategoryId
//        );
//
//        if (toInsert) {
//            insert category;
//        }
//
//        return category;
//    }
//
//    public static Product2 createProduct(Boolean toInsert, String Name, String productCode) {
//        Product2 testProduct = new Product2(
//                Name = Name,
//                IsActive = true,
//                ProductCode = productCode
//        );
//
//        if (toInsert) {
//            insert testProduct;
//        }
//
//        return testProduct;
//    }

//    public static Product_To_Product__c createProductToProduct(Boolean toInsert, Id mainProductId, Id childProductId, String associationType) {
//        Product_To_Product__c prodToProd = new Product_To_Product__c(
//            Association_Type__c = associationType,
//            Main_Product__c = mainProductId,
//            Associated_Product__c = childProductId
//        );
//
//        if (toInsert) {
//            insert prodToProd;
//        }
//
//        return prodToProd;
//    }

//    public static Payment_Method__c createPaymentMethod(Boolean toInsert, String type, String ownerContactId, String billingAddressId, Boolean isDefault) {
//        Payment_Method__c method = new Payment_Method__c(
//            Type__c = type,
//            Holder__c = ownerContactId,
//            Billing_Address__c = billingAddressId,
//            Default__c = isDefault
//        );
//
//        if (toInsert) {
//            insert method;
//        }
//
//        return method;
//    }
}