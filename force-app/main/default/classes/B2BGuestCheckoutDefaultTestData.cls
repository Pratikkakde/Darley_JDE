/**
 * Add only common initial B2B Test Data to this class like init Product etc.
 *
 * DEPLOY THIS CLASS WITH B2BGuestCheckoutTestDataFactory
 */

public without sharing abstract class B2BGuestCheckoutDefaultTestData {
    //Configured in B2BGuestCheckoutTestDataFactory. DO NOT CHANGE
    protected String SYSTEM_ADMINISTRATOR_PROFILE {get; set;}
    protected String GUEST_USER_PROFILE {get; set;}

    private static final Map<String, Object> TEST_DATA_MAP = new Map<String, Object>();

    public static final String WEB_STORE = 'WebStore';

    public static final String USER_ROLE = 'UserRole';
    public static final String SYS_ADMIN_USER = 'SysAdminUser';
    public static final String GUEST_USER = 'GuestUser';
    public static final String GUEST_ACCOUNT = 'GuestAccount';

    public static final String CATALOG = 'Catalog';
    public static final String PRODUCT_CATEGORY = 'ProductCategory';
    public static final String PRODUCT = 'Product';
    public static final String PRODUCT_CATEGORY_PRODUCT = 'ProductCategoryProduct';
    public static final String PRICE_BOOK = 'PriceBook';
    public static final String PRICE_BOOK_ENTRY = 'PriceBookEntry';
    public static final String WEB_STORE_PRICE_BOOK = 'WebStorePriceBook';

    public static final String BUYER_GROUP = 'BuyerGroup';
    public static final String BUYER_GROUP_PRICE_BOOK = 'BuyerGroupPriceBook';

    public static final String CART = 'Cart';
    public static final String CART_DELIVERY_GROUP = 'CartDeliveryGroup';
    public static final String CART_DELIVERY_GROUP_METHOD = 'CartDeliveryGroupMethod';
    public static final String CART_ITEM = 'CartItem';

    public static final String WEB_STORE_TEST_NAME = 'testWebStore';

    public static final String CEO_ROLE_NAME = 'CEO';

    public virtual Map<String, Object> initAllData() {
        initWebStore();

        initGuestUserData();
        initProductData();
        initCartData();

        return TEST_DATA_MAP;
    }

    public virtual Map<String, Object> initGuestUserData() {
        getSysAdminUser();
        getGuestUser();
        initWebStore();

        return TEST_DATA_MAP;
    }

    public virtual Map<String, Object> initProductData() {
        initWebStore();
        initCatalog();
        initCategory();
        initProduct();

        addProductsToPriceBook(new List<Id>{
            ((Product2) TEST_DATA_MAP.get(PRODUCT)).Id
        }, System.Test.getStandardPricebookId(), 10);

        initProductCategoryProduct();
        initPriceBook();
        initPriceBookEntry();
        initWebStorePricebook();

        return TEST_DATA_MAP;
    }


    public virtual Map<String, Object> initCartData() {
        getSysAdminUser();
        initWebStore();
        initProduct();
        initDefaultGuestAccount();
        initCart();
        initCartDeliveryGroup();
        initCartDeliveryGroupMethod();
        initCartItem();

        return TEST_DATA_MAP;
    }

    private void initDefaultGuestAccount() {
        if (((Account) TEST_DATA_MAP.get(GUEST_ACCOUNT)) != null) {
            return;
        }

        Account account = B2BTestDataFactory.createAccount(false, 'GuestAccount');
        account.OwnerId = ((User) TEST_DATA_MAP.get(SYS_ADMIN_USER)).Id;

        insert account;

        TEST_DATA_MAP.put(GUEST_ACCOUNT, account);
    }

    private void initWebStore() {
        if (((WebStore) TEST_DATA_MAP.get(WEB_STORE)) != null) {
            return;
        }

        WebStore webStore = new WebStore(
            Name = WEB_STORE_TEST_NAME,
            OptionsGuestBrowsingEnabled = true,
            Type = 'B2B'
        );

        insert webStore;

        TEST_DATA_MAP.put(WEB_STORE, webStore);
    }

    private void getGuestUser() {
        List<User> users = [SELECT Id, Username, UserRoleId FROM User WHERE Name LIKE '%Site Guest User%' AND IsActive = TRUE LIMIT 1];

        TEST_DATA_MAP.put(GUEST_USER, users[0]);
    }

    private void getSysAdminUser() {
        List<User> users = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = :SYSTEM_ADMINISTRATOR_PROFILE AND IsActive = TRUE AND UserRoleId != NULL LIMIT 1];
        
        if (users.isEmpty()) {
            users = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = :SYSTEM_ADMINISTRATOR_PROFILE AND IsActive = TRUE LIMIT 1];
        }

        if (users[0].UserRoleId == null) {
            users[0].UserRoleId = getCeoRole().Id;
            update users[0];
        }

        TEST_DATA_MAP.put(SYS_ADMIN_USER, users[0]);
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
            insert r;

            role = r;
        } else {
            role = ceoRoles[0];
        }

        TEST_DATA_MAP.put(USER_ROLE, role);

        return role;
    }

    private void initCatalog() {
        if (((ProductCatalog) TEST_DATA_MAP.get(CATALOG)) != null) {
            return;
        }

        ProductCatalog testCatalog = new ProductCatalog(Name = 'TestCatalog');

        insert testCatalog;

        TEST_DATA_MAP.put(CATALOG, testCatalog);
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
            Name = 'Test12 Product',
            IsActive = true,
            ProductCode = 'TEST-CODE',
            StockKeepingUnit = 'Test-Sku'
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
            Name = 'Test12 Customer Price Book',
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
            Name = 'Test12 Buyer Group'
        );

        insert buyerGroup;

        TEST_DATA_MAP.put(BUYER_GROUP, buyerGroup);
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
            Name = 'GuestCart',
            AccountId = ((Account) TEST_DATA_MAP.get(GUEST_ACCOUNT)).Id,
            Status = 'Active',
            OwnerId = ((User) TEST_DATA_MAP.get(SYS_ADMIN_USER)).Id
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
            DeliverToPostalCode = '43221',
            DeliverToState = 'Ohio',
            DeliverToStreet = '1285 W Lane Ave',
            DeliverToCity = 'Columbus',
            DeliverToCountryCode = 'US',
            DeliverToStateCode = 'OH',
            DeliverToCountry = 'United States'
        );

        insert grp;

        TEST_DATA_MAP.put(CART_DELIVERY_GROUP, grp);
    }

    private void initCartDeliveryGroupMethod() {
        if (((CartDeliveryGroupMethod) TEST_DATA_MAP.get(CART_DELIVERY_GROUP_METHOD)) != null) {
            return;
        }

        OrderDeliveryMethod dm = new OrderDeliveryMethod(
            Name = 'Order Delivery Method'
        );
        insert dm;

        CartDeliveryGroupMethod grpm = new CartDeliveryGroupMethod(
            Name = 'Cart Delivery Group Method',
            WebCartId = ((WebCart) TEST_DATA_MAP.get(CART)).Id,
            CartDeliveryGroupId = ((CartDeliveryGroup) TEST_DATA_MAP.get(CART_DELIVERY_GROUP)).Id,
            ShippingFee = 100,
            DeliveryMethodId = dm.Id
        );

        insert grpm;

        TEST_DATA_MAP.put(CART_DELIVERY_GROUP_METHOD, grpm);
    }

    private void initCartItem() {
        if (((CartItem) TEST_DATA_MAP.get(CART_ITEM)) != null) {
            return;
        }

        CartItem cartItem = new CartItem();
        cartItem.Product2Id = ((Product2) TEST_DATA_MAP.get(PRODUCT)).Id;
        cartItem.Quantity = 10;
        cartItem.SalesPrice = 100;
        cartItem.AdjustmentAmount = 0;
        cartItem.TotalAdjustmentAmount = 0;
        cartItem.CartId = ((WebCart) TEST_DATA_MAP.get(CART)).Id;
        cartItem.CartDeliveryGroupId = ((CartDeliveryGroup) TEST_DATA_MAP.get(CART_DELIVERY_GROUP)).Id;
        cartItem.Name = 'CartItem';
        cartItem.Type = 'Product';
        cartItem.Sku = ((Product2) TEST_DATA_MAP.get(PRODUCT)).StockKeepingUnit;

        insert cartItem;

        TEST_DATA_MAP.put(CART_ITEM, cartItem);
    }
}