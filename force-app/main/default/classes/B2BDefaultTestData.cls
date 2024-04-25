/**
 * Add only common initial B2B Test Data to this class like init Account, Contact, Community User, Product etc.
 */

public without sharing virtual class B2BDefaultTestData {
    private static final Map<String, Object> TEST_DATA_MAP = new Map<String, Object>();

    public static final String WEB_STORE = 'WebStore';

    public static final String CUSTOMER_ACCOUNT = 'Account';
    public static final String CUSTOMER_CONTACT = 'Contact';
    public static final String COMMUNITY_USER_NAME = 'TestUserName@test.com';
    public static final String COMMUNITY_USER = 'CommunityUser';
    public static final String USER_ROLE = 'UserRole';

    public static final String CATALOG = 'Catalog';
    public static final String STORE_CATALOG = 'WebStoreCatalog';
    public static final String PRODUCT_CATEGORY = 'ProductCategory';
    public static final String PRODUCT = 'Product';
    public static final String PRODUCT_CATEGORY_PRODUCT = 'ProductCategoryProduct';
    public static final String PRICE_BOOK = 'PriceBook';
    public static final String PRICE_BOOK_ENTRY = 'PriceBookEntry';
    public static final String WEB_STORE_PRICE_BOOK = 'WebStorePriceBook';

    public static final String BUYER_GROUP = 'BuyerGroup';
    public static final String STORE_BUYER_GROUP = 'WebStoreBuyerGroup';
    public static final String BUYER_GROUP_ACCOUNT = 'BuyerGroupAccount';
    public static final String BUYER_GROUP_MEMBER = 'BuyerGroupMember';
    public static final String BUYER_GROUP_PRICE_BOOK = 'BuyerGroupPriceBook';

    public static final String CART = 'Cart';
    public static final String CART_DELIVERY_GROUP = 'CartDeliveryGroup';
    public static final String CART_ITEM = 'CartItem';
    public static final String SHIPPING_PRODUCT = 'ShippingProduct';
    public static final String CART_SHIPPING_ITEM = 'CartShippingItem';
    public static final String CART_TAX = 'CartTax';

    public static final String ORDER = 'Order';
    public static final String ORDER_DELLIVERY_METHOD = 'OrderDeliveryMethod';
    public static final String ORDER_DELLIVERY_GROUP = 'OrderDeliveryGroup';
    public static final String ORDER_ITEM = 'OrderItem';
    public static final String ORDER_SUMMARY = 'OrderSummary';

    public static final String WEB_STORE_TEST_NAME = 'testWebStore';

    public static final String CEO_ROLE_NAME = 'CEO';

    public static final String SHIPPING = 'Shipping';
    public static final String BILLING = 'Billing';

    //Configure these values according to your store Profiles/Perm Set namings
    public static final String COMMUNITY_PROFILE = 'B2B Commerce User';
    public static final String COMMUNITY_PERM_SET = 'B2B_Commerce_User';

    //Configure this value according to your org System Admin Profile
    public static final String SYSTEM_ADMINISTRATOR_PROFILE = 'System Administrator';

    public virtual Map<String, Object> initAllData() {
        initWebStore();

        initCustomerUserData();
        initProductData();
        initBuyerGroupsData();
        initCartData(true, true);


        return TEST_DATA_MAP;
    }

    public virtual Map<String, Object> initCustomerUserData() {
        initWebStore();

        initAccount();
        initContact();
        initCommunityUser();

        return TEST_DATA_MAP;
    }

    public virtual Map<String, Object> initProductData() {
        initWebStore();

        initCatalog();
        initWebStoreCatalog();
        initCategory();
        initProduct();

        addProductsToPriceBook(new List<Id>{
                ((Product2) TEST_DATA_MAP.get(PRODUCT)).Id
        }, Test.getStandardPricebookId(), 10);

        initProductCategoryProduct();
        initPriceBook();
        initPriceBookEntry();
        initWebStorePricebook();

        return TEST_DATA_MAP;
    }

    public virtual Map<String, Object> initBuyerGroupsData() {
        initWebStore();
        initAccount();
        initPriceBook();

        initBuyerGroup();
        initStoreBuyerGroup();
        initBuyerAccount();
        initBuyerGroupMember();
        initBuyerGroupPricebook();

        return TEST_DATA_MAP;
    }

    public virtual Map<String, Object> initCartData(Boolean includeTax, Boolean includeShipping) {
        initCustomerUserData();
        initProduct();
        initCart();
        initCartDeliveryGroup();
        initCartItem();

        if (includeTax) {
            initCartTax();
        }

        if (includeShipping) {
            initShippingProduct();
            initShippingItem();
        }

        return TEST_DATA_MAP;
    }

    public virtual Map<String, Object> initOrderData() {
        initCustomerUserData();
        initProduct();
        initCart();
        initCartDeliveryGroup();
        initCartItem();

        initOrder();
        initOrderDeliveryMethod();
        initOrderDeliveryGroup();
        initOrderItem();
        initOrderSummary();

        return TEST_DATA_MAP;
    }

    private void initWebStore() {
        if (((WebStore) TEST_DATA_MAP.get(WEB_STORE)) != null) {
            return;
        }
        WebStore webStore = new WebStore(Name = WEB_STORE_TEST_NAME);

        insert webStore;

        TEST_DATA_MAP.put(WEB_STORE, webStore);
    }

    private void initAccount() {
        if (((Account) TEST_DATA_MAP.get(CUSTOMER_ACCOUNT)) != null) {
            return;
        }

        if (Test.isRunningTest()) {
            Test.setMock(HttpCalloutMock.class, new B2BDefaultTestMock());
        }
        Account account = new Account(
                Name = 'testCustomerAccount',
                BillingCity = 'Chicago',
                BillingCountry = 'United States'
        );

        insert account;

        TEST_DATA_MAP.put(CUSTOMER_ACCOUNT, account);
    }

    public class B2BDefaultTestMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            return new HttpResponse();
        }
    }

    private void initContact() {
        if (((Contact) TEST_DATA_MAP.get(CUSTOMER_CONTACT)) != null) {
            return;
        }

        Contact contact = new Contact(
                LastName = 'testCustomerContact',
                AccountId = ((Account) TEST_DATA_MAP.get(CUSTOMER_ACCOUNT)).Id
        );

        insert contact;

        TEST_DATA_MAP.put(CUSTOMER_CONTACT, contact);
    }

    //Use this method after Community Profile provided
    private void initCommunityUser() {
        User communityUser = ((User) TEST_DATA_MAP.get(COMMUNITY_USER));
        if (communityUser != null) {
            return;
        }

        List<User> usersToUpdate = new List<User>();
        UserRole ceoRole = getCeoRole();
        List<User> users = [SELECT Id, Username, UserRole.Name, UserRoleId FROM User WHERE Profile.Name = :SYSTEM_ADMINISTRATOR_PROFILE AND IsActive = TRUE LIMIT 1];
        if (users[0].UserRoleId == null) {
            users[0].UserRoleId = ceoRole.Id;
            usersToUpdate.add(users[0]);
        }
        
        Contact customerContact = (Contact)TEST_DATA_MAP.get(CUSTOMER_CONTACT);
        Id accountId = customerContact.AccountId;
        Account portalAccount = [SELECT Id, Owner.Id FROM Account WHERE Id = :accountId LIMIT 1];
        User ownerToUpdate = [SELECT Id, UserRoleId FROM User WHERE Id = :portalAccount.Owner.Id LIMIT 1];
        if(ownerToUpdate.UserRoleId == NULL) {
            ownerToUpdate.UserRoleId = ceoRole.Id;
            usersToUpdate.add(ownerToUpdate);
        }
                
        System.runAs(users[0]) {           
       		update usersToUpdate;

            Profile profile = [SELECT Id, Name FROM Profile WHERE Name = :COMMUNITY_PROFILE LIMIT 1];

            User testUser = new User();
            testUser.Email = 'TestEmail@test.coom';
            testUser.Username = COMMUNITY_USER_NAME;
            testUser.Alias = 'alias';
            testUser.TimeZoneSidKey = System.UserInfo.getTimeZone().getID();
            testUser.EmailEncodingKey = 'ISO-8859-1';
            testUser.LocaleSidKey = 'en_US';
            testUser.LanguageLocaleKey = 'en_US';
            testUser.FirstName = 'Ivan';
            testUser.LastName = 'Ivanov';
            testUser.IsActive = true;
            testUser.UserRole = getCeoRole();
            testUser.ContactId = ((Contact) TEST_DATA_MAP.get(CUSTOMER_CONTACT)).Id;
            testUser.ProfileId = profile.Id;
            insert testUser;
            communityUser = testUser;

            TEST_DATA_MAP.put(COMMUNITY_USER, communityUser);
            assignPermissionSet(communityUser);
        }

        TEST_DATA_MAP.put(COMMUNITY_USER, communityUser);
    }

    private void assignPermissionSet(User comUser) {
        List<PermissionSet> b2bPermSet = [SELECT Id FROM PermissionSet WHERE Name = :COMMUNITY_PERM_SET];
        if (b2bPermSet.isEmpty()) {
            return;
        }

        PermissionSetAssignment b2bPermSetAssignment = new PermissionSetAssignment(
                AssigneeId = comUser.Id,
                PermissionSetId = b2bPermSet[0].Id
        );

        insert b2bPermSetAssignment;
    }

    private UserRole getCeoRole() {
        UserRole ceoRole = ((UserRole) TEST_DATA_MAP.get(USER_ROLE));
        if (ceoRole != null) {
            return ceoRole;
        }

        List<UserRole> ceoRoles = [SELECT Id FROM UserRole WHERE Name = :CEO_ROLE_NAME LIMIT 1];

        UserRole role;

        if (ceoRoles.isEmpty()) {
            UserRole r = new UserRole(DeveloperName = CEO_ROLE_NAME, Name = CEO_ROLE_NAME);
            List<User> users = [SELECT Id, Username, UserRole.Name, UserRoleId FROM User WHERE Profile.Name = :SYSTEM_ADMINISTRATOR_PROFILE AND IsActive = TRUE LIMIT 1];
            System.runAs(users[0]) {
            	insert r;                
            }

            ceoRole = r;
        } else {
            ceoRole = ceoRoles[0];
        }

        TEST_DATA_MAP.put(USER_ROLE, role);

        return ceoRole;
    }

    private void initCatalog() {
        if (((ProductCatalog) TEST_DATA_MAP.get(CATALOG)) != null) {
            return;
        }

        ProductCatalog testCatalog = new ProductCatalog(Name = 'TestCatalog');

        insert testCatalog;

        TEST_DATA_MAP.put(CATALOG, testCatalog);
    }

    private void initWebStoreCatalog() {
        if (((WebStoreCatalog) TEST_DATA_MAP.get(STORE_CATALOG)) != null) {
            return;
        }

        WebStoreCatalog testStoreCatalog = new WebStoreCatalog(
            ProductCatalogId = ((ProductCatalog) TEST_DATA_MAP.get(CATALOG)).Id,
            SalesStoreId = ((WebStore) TEST_DATA_MAP.get(WEB_STORE)).Id
        );

        insert testStoreCatalog;

        TEST_DATA_MAP.put(STORE_CATALOG, testStoreCatalog);
    }

    private void initCategory() {
        if (((ProductCategory) TEST_DATA_MAP.get(PRODUCT_CATEGORY)) != null) {
            return;
        }

        ProductCategory category = new ProductCategory(
                Name = 'TestCategory',
                CatalogId = ((ProductCatalog) TEST_DATA_MAP.get(CATALOG)).Id
        );

        insert category;

        TEST_DATA_MAP.put(PRODUCT_CATEGORY, category);
    }

    private void initProduct() {
        if (((Product2) TEST_DATA_MAP.get(PRODUCT)) != null) {
            return;
        }

        Product2 testProduct = new Product2(
                Name = 'Test Product',
                IsActive = true,
                ProductCode = 'TEST-CODE'
        );

        insert testProduct;

        TEST_DATA_MAP.put(PRODUCT, testProduct);
    }

    public virtual List<PricebookEntry> addProductsToPriceBook(List<Id> productsIds, Id priceBookId, Decimal price) {
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();

        for (Id productId : productsIds) {
            pricebookEntries.add(new PricebookEntry(
                    Product2Id = productId,
                    Pricebook2Id = priceBookId,
                    IsActive = true,
                    UnitPrice = price
            ));
        }

        insert pricebookEntries;
        return pricebookEntries;
    }

    private void initProductCategoryProduct() {
        if (((ProductCategoryProduct) TEST_DATA_MAP.get(PRODUCT_CATEGORY_PRODUCT)) != null) {
            return;
        }

        ProductCategoryProduct testProductCategoryProduct = new ProductCategoryProduct(
                ProductCategoryId = ((ProductCategory) TEST_DATA_MAP.get(PRODUCT_CATEGORY)).Id,
                ProductId = ((Product2) TEST_DATA_MAP.get(PRODUCT)).Id
        );

        insert testProductCategoryProduct;

        TEST_DATA_MAP.put(PRODUCT_CATEGORY_PRODUCT, testProductCategoryProduct);
    }

    private void initPriceBook() {
        if (((Pricebook2) TEST_DATA_MAP.get(PRICE_BOOK)) != null) {
            return;
        }

        Pricebook2 pricebook = new Pricebook2(
                Name = 'Test Customer Price Book',
                IsActive = true
        );

        insert pricebook;

        TEST_DATA_MAP.put(PRICE_BOOK, pricebook);
    }

    private void initPriceBookEntry() {
        if (((PricebookEntry) TEST_DATA_MAP.get(PRICE_BOOK_ENTRY)) != null) {
            return;
        }

        PricebookEntry pricebookEntry = new PricebookEntry(
                Product2Id = ((Product2) TEST_DATA_MAP.get(PRODUCT)).Id,
                Pricebook2Id = ((Pricebook2) TEST_DATA_MAP.get(PRICE_BOOK)).Id,
                IsActive = true,
                UnitPrice = 20.00
        );

        insert pricebookEntry;

        TEST_DATA_MAP.put(PRICE_BOOK_ENTRY, pricebookEntry);
    }

    private void initWebStorePricebook() {
        if (((WebStorePricebook) TEST_DATA_MAP.get(WEB_STORE_PRICE_BOOK)) != null) {
            return;
        }

        WebStorePricebook webStorePricebook = new WebStorePricebook(
                IsActive = true,
                Pricebook2Id = ((Pricebook2) TEST_DATA_MAP.get(PRICE_BOOK)).Id,
                WebStoreId = ((WebStore) TEST_DATA_MAP.get(WEB_STORE)).Id
        );

        insert webStorePricebook;

        TEST_DATA_MAP.put(WEB_STORE_PRICE_BOOK, webStorePricebook);
    }

    private void initBuyerGroup() {
        if (((BuyerGroup) TEST_DATA_MAP.get(BUYER_GROUP)) != null) {
            return;
        }

        BuyerGroup buyerGroup = new BuyerGroup(
                Name = 'Test Buyer Group'
        );

        insert buyerGroup;

        TEST_DATA_MAP.put(BUYER_GROUP, buyerGroup);
    }

    //This was needed due to the secod store creation. Darley Store => Enhanced Darley Store
    private void initStoreBuyerGroup() {
        if (((WebStoreBuyerGroup) TEST_DATA_MAP.get(STORE_BUYER_GROUP)) != null) {
            return;
        }

        WebStoreBuyerGroup storeBuyerGroup = new WebStoreBuyerGroup(
                WebStoreId = ((WebStore) TEST_DATA_MAP.get(WEB_STORE)).Id,
                BuyerGroupId = ((BuyerGroup)TEST_DATA_MAP.get(BUYER_GROUP)).Id
        );

        insert storeBuyerGroup;

        TEST_DATA_MAP.put(STORE_BUYER_GROUP, storeBuyerGroup);
    }

    private void initBuyerAccount() {
        if (((BuyerAccount) TEST_DATA_MAP.get(BUYER_GROUP_ACCOUNT)) != null) {
            return;
        }

        BuyerAccount buyerAccount = new BuyerAccount(
                Name = 'Test Buyer Account Name',
                CommerceType = 'Buyer',
                BuyerId = ((Account) TEST_DATA_MAP.get(CUSTOMER_ACCOUNT)).Id,
                IsActive = true
        );

        insert buyerAccount;

        TEST_DATA_MAP.put(BUYER_GROUP_ACCOUNT, buyerAccount);
    }

    private void initBuyerGroupMember() {
        if (((BuyerGroupMember) TEST_DATA_MAP.get(BUYER_GROUP_MEMBER)) != null) {
            return;
        }

        BuyerGroupMember buyerGroupMember = new BuyerGroupMember(
                BuyerGroupId = ((BuyerGroup) TEST_DATA_MAP.get(BUYER_GROUP)).Id,
                BuyerId = ((Account) TEST_DATA_MAP.get(CUSTOMER_ACCOUNT)).Id
        );

        insert buyerGroupMember;

        TEST_DATA_MAP.put(BUYER_GROUP_MEMBER, buyerGroupMember);
    }

    private void initBuyerGroupPricebook() {
        if (((BuyerGroupPricebook) TEST_DATA_MAP.get(BUYER_GROUP_PRICE_BOOK)) != null) {
            return;
        }

        BuyerGroupPricebook BuyerGroupPricebook = new BuyerGroupPricebook(
                BuyerGroupId = ((BuyerGroup) TEST_DATA_MAP.get(BUYER_GROUP)).Id,
                Pricebook2Id = ((Pricebook2) TEST_DATA_MAP.get(PRICE_BOOK)).Id,
                IsActive = true
        );

        insert BuyerGroupPricebook;

        TEST_DATA_MAP.put(BUYER_GROUP_PRICE_BOOK, BuyerGroupPricebook);
    }

    private void initCart() {
        if (((WebCart) TEST_DATA_MAP.get(CART)) != null) {
            return;
        }

        WebCart testCart = new WebCart(
                WebStoreId = ((WebStore)TEST_DATA_MAP.get(WEB_STORE)).Id,
                Name = 'Cart',
                AccountId = ((Account) TEST_DATA_MAP.get(CUSTOMER_ACCOUNT)).Id,
                Status = 'Active',
                OwnerId = ((User) TEST_DATA_MAP.get(COMMUNITY_USER)).Id
        );

        insert testCart;

        TEST_DATA_MAP.put(CART, testCart);
    }

    private void initCartDeliveryGroup() {
        if (((CartDeliveryGroup) TEST_DATA_MAP.get(CART_DELIVERY_GROUP)) != null) {
            return;
        }

        CartDeliveryGroup grp = new CartDeliveryGroup(
                Name = 'Cart Delivery Group',
                CartId = ((WebCart) TEST_DATA_MAP.get(CART)).Id,
                DeliverToPostalCode = '606060',
                DeliverToState = 'Illinois',
                DeliverToStateCode = 'IL',
                DeliverToStreet = 'mail street',
                DeliverToCity = 'Chicago',
                DeliverToCountry = 'United States',
                DeliverToCountryCode = 'US'
        );

        insert grp;

        TEST_DATA_MAP.put(CART_DELIVERY_GROUP, grp);
    }

    private void initCartItem() {
        if (((CartItem) TEST_DATA_MAP.get(CART_ITEM)) != null) {
            return;
        }

        CartItem cartItem = new CartItem();
        cartItem.Product2Id = ((Product2) TEST_DATA_MAP.get(PRODUCT)).Id;
        cartItem.Quantity = 10;
        cartItem.SalesPrice = 100;
        cartItem.ListPrice = 100;
        cartItem.CartId = ((WebCart) TEST_DATA_MAP.get(CART)).Id;
        cartItem.CartDeliveryGroupId = ((CartDeliveryGroup) TEST_DATA_MAP.get(CART_DELIVERY_GROUP)).Id;
        cartItem.Name = 'CartItem';
        cartItem.Type = 'Product';

        insert cartItem;

        TEST_DATA_MAP.put(CART_ITEM, cartItem);
    }

    private void initShippingProduct() {
        if (((Product2) TEST_DATA_MAP.get(SHIPPING_PRODUCT)) != null) {
            return;
        }

        Product2 shippingProduct = new Product2(
                Name = 'Shipping Product',
                IsActive = false,
                ProductCode = 'SHIP'
        );

        insert shippingProduct;

        TEST_DATA_MAP.put(SHIPPING_PRODUCT, shippingProduct);
    }

    private void initShippingItem() {
        if (((CartItem) TEST_DATA_MAP.get(CART_SHIPPING_ITEM)) != null) {
            return;
        }

        CartItem deliveryCharge = new CartItem(
                Type = 'Charge',
                Product2Id = ((Product2) TEST_DATA_MAP.get(SHIPPING_PRODUCT)).Id,
                Quantity = 1.0,
                TotalPrice = 100,
                ListPrice = 100,
                SalesPrice = 100,
                TotalListPrice = 100,
                TotalLineAmount = 100,
                AdjustmentAmount = 0.0,
                CartId = ((WebCart) TEST_DATA_MAP.get(CART)).Id,
                CartDeliveryGroupId = ((CartDeliveryGroup) TEST_DATA_MAP.get(CART_DELIVERY_GROUP)).Id,
                Name = 'Shipping Cost'
        );

        insert deliveryCharge;

        TEST_DATA_MAP.put(CART_SHIPPING_ITEM, deliveryCharge);
    }

    private void initCartTax() {
        if (((CartTax) TEST_DATA_MAP.get(CART_TAX)) != null) {
            return;
        }

        CartTax tax = new CartTax(
                Amount = 10,
                CartItemId = ((CartItem) TEST_DATA_MAP.get(CART_ITEM)).Id,
                Name = 'Cart Tax',
                TaxCalculationDate = Date.today(),
                TaxRate = 1,
                TaxType = 'Actual'
        );

        insert tax;

        TEST_DATA_MAP.put(CART_TAX, tax);
    }

    private void initOrder() {
        if (((Order) TEST_DATA_MAP.get(ORDER)) != null) {
            return;
        }

        Order orderOne = new Order(
            AccountId = ((WebCart) TEST_DATA_MAP.get(CART)).AccountId,
            OwnerId = ((WebCart) TEST_DATA_MAP.get(CART)).OwnerId,
            SalesStoreId = ((WebCart) TEST_DATA_MAP.get(CART)).WebStoreId,
            PoNumber = '34234',
            BillingStreet = '222 S. Riverside Plaza, Suite 2800',
            BillingCity = 'Portsmouth',
            BillingState = 'Illinois',
            BillingPostalCode = '03801',
            BillingCountry = 'United States',
            EffectiveDate = Date.today(),
            OrderedDate = Datetime.now(),
            Status = 'Draft',
            Payment_Type__c = 'Invoice'
        );

        insert orderOne;

        TEST_DATA_MAP.put(ORDER, orderOne);

    }

    private void initOrderDeliveryMethod() {
        if (((OrderDeliveryMethod) TEST_DATA_MAP.get(ORDER_DELLIVERY_METHOD)) != null) {
            return;
        }

        OrderDeliveryMethod orderDeliveryMethod = new OrderDeliveryMethod(Name = 'Test Order Delivery Method');

        insert orderDeliveryMethod;

        TEST_DATA_MAP.put(ORDER_DELLIVERY_METHOD, orderDeliveryMethod);
    }

    private void initOrderDeliveryGroup() {
        if (((OrderDeliveryGroup) TEST_DATA_MAP.get(ORDER_DELLIVERY_GROUP)) != null) {
            return;
        }
        CartDeliveryGroup cartDeliveryGroup = (CartDeliveryGroup) TEST_DATA_MAP.get(CART_DELIVERY_GROUP);
        OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup(
            DesiredDeliveryDate = Date.today() + 5,
            DeliverToName = 'Deliver To Name',
            DeliveryInstructions = 'Some instructions',
            DeliverToStreet = cartDeliveryGroup.DeliverToStreet,
            DeliverToCity = cartDeliveryGroup.DeliverToCity,
            DeliverToState = cartDeliveryGroup.DeliverToState,
            DeliverToPostalCode = cartDeliveryGroup.DeliverToPostalCode,
            DeliverToCountry = cartDeliveryGroup.DeliverToCountry,
            OrderDeliveryMethodId = ((OrderDeliveryMethod) TEST_DATA_MAP.get(ORDER_DELLIVERY_METHOD)).Id,
            OrderId = ((Order) TEST_DATA_MAP.get(ORDER)).Id
        );

        insert orderDeliveryGroup;

        TEST_DATA_MAP.put(ORDER_DELLIVERY_GROUP, orderDeliveryGroup);
    }

    private void initOrderItem() {
        if (((OrderItem) TEST_DATA_MAP.get(ORDER_ITEM)) != null) {
            return;
        }
        CartItem cartItemNew = (CartItem) TEST_DATA_MAP.get(CART_ITEM);
        OrderItem orderItem = new OrderItem(
            Product2Id = cartItemNew.Product2Id,
            Quantity = 1,
            ListPrice = cartItemNew.ListPrice,
            UnitPrice = cartItemNew.SalesPrice,
            OrderId = ((Order) TEST_DATA_MAP.get(ORDER)).Id,
            OrderDeliveryGroupId = ((OrderDeliveryGroup) TEST_DATA_MAP.get(ORDER_DELLIVERY_GROUP)).Id,
            TotalLineAmount = cartItemNew.TotalLineAmount
        );
        insert orderItem;

        TEST_DATA_MAP.put(ORDER_ITEM, orderItem);
    }

    private void initOrderSummary() {
        if (((OrderSummary) TEST_DATA_MAP.get(ORDER_SUMMARY)) != null) {
            return;
        }
        
        Order order = ((Order) TEST_DATA_MAP.get(ORDER));
        order.Status = 'Activated';
        update order;

        ConnectApi.OrderSummaryInputRepresentation orderSummaryInputRepresentation = new ConnectApi.OrderSummaryInputRepresentation();
        orderSummaryInputRepresentation.orderId = order.Id;
        orderSummaryInputRepresentation.orderLifeCycleType = 'UNMANAGED';
        ConnectApi.OrderSummaryOutputRepresentation orderSummaryOutputRepresentation = ConnectApi.OrderSummaryCreation.createOrderSummary(orderSummaryInputRepresentation);
        
        OrderSummary orderSummary = [
            SELECT
                Id,
                OrderNumber
            FROM OrderSummary
            WHERE Id = :orderSummaryOutputRepresentation.orderSummaryId
            LIMIT 1
        ];

        TEST_DATA_MAP.put(ORDER_SUMMARY, orderSummary);
    }
}