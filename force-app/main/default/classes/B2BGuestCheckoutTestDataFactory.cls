/**
 * CONFIGURE THESE VALUES BEFORE USE:
  * GUEST_USER_PROFILE,
  * SYSTEM_ADMINISTRATOR_PROFILE
 */
public without sharing class B2BGuestCheckoutTestDataFactory extends B2BGuestCheckoutDefaultTestData {
    //Configure before use
    public static final String GUEST_USER_PROFILE = 'Guest Checkout Profile';
    public static final String SYSTEM_ADMINISTRATOR_PROFILE = 'System Administrator';

    public B2BGuestCheckoutTestDataFactory() {
        super.GUEST_USER_PROFILE = GUEST_USER_PROFILE;
        super.SYSTEM_ADMINISTRATOR_PROFILE = SYSTEM_ADMINISTRATOR_PROFILE;
    }

    //method inits data from all init methods below
    public override Map<String, Object> initAllData() {
        return super.initAllData();
    }

    //inits WebStore, Catalog, Category, Product, ProductCategoryProduct,
    // PriceBook, PriceBookEntry(Standard and Custom), WebStorePricebook
    public override Map<String, Object> initProductData() {
        return super.initProductData();
    }


    //inits WebStore, Account
    // Product, Cart, CartDeliveryGroup, CartItem
    public override Map<String, Object> initCartData() {
        return super.initCartData();
    }

    public override Map<String, Object> initGuestUserData() {
        return super.initGuestUserData();
    }

    public override List<PricebookEntry> addProductsToPriceBook(List<Id> productsIds, Id priceBookId, Decimal price) {
        return super.addProductsToPriceBook(productsIds, priceBookId, price);
    }

    public static Account createAccount(Boolean toInsert, String accountName) {
        Account acc = B2BTestDataFactory.createAccount(false, accountName);

        if (toInsert) {
            insert acc;
        }

        return acc;
    }

    public static Product2 createProduct(Boolean toInsert, String Name, String productCode) {
        Product2 testProduct = new Product2(
            Name = Name,
            IsActive = true,
            ProductCode = productCode
        );

        if (toInsert) {
            insert testProduct;
        }

        return testProduct;
    }

    public static BuyerGroup createBuyerGroup(Boolean toInsert) {
        BuyerGroup buyerGroup = new BuyerGroup();

        buyerGroup.Name = 'Test12 Buyer Group';

        if (toInsert) {
            insert buyerGroup;
        }

        return buyerGroup;
    }

    public static CartItem createCartItem(Boolean toInsert, String prodId, String cartId, String cartDelGroupId) {
        CartItem cartItem = new CartItem();
        cartItem.Product2Id = prodId;
        cartItem.Quantity = 1;
        cartItem.SalesPrice = 100;
        cartItem.AdjustmentAmount = 0;
        cartItem.TotalAdjustmentAmount = 0;
        cartItem.CartId = cartId;
        cartItem.CartDeliveryGroupId = cartDelGroupId;
        cartItem.Name = 'CartItem';
        cartItem.Type = 'Product';

        if (toInsert) {
            insert cartItem;
        }

        return cartItem;
    }
}