/**
 * Created by IrinaSakovich on 22.07.22.
 */

public without sharing class B2BGuestCartItemService {
    @TestVisible
    private static Boolean isShowWarning = false;
    private static Boolean includeDateTimeFields = true;
    private static Decimal maxQty = 100000000;

    public static AddItemResponse addItemToCart(List<CartItem> cartItems, ProductInfo product, Id webStoreId, String effectiveAccountId, Id cartId) {
        CartItem activeItem = (cartItems == null || cartItems.isEmpty())
            ? new CartItem(CartId = cartId, Quantity = 0)
            : cartItems[0];

        Decimal quantity = checkQtyRules(product.quantity, product.maxQty, activeItem.Quantity, product.addToQuantity);
        quantity = quantity > maxQty ? maxQty : quantity;

        Map<Id, PricebookEntry> prices = B2BGuestCartProductService.getProductPricesMap(new List<Id>{product.productId}, effectiveAccountId, webStoreId);
        PricebookEntry pricebookEntry = prices.containsKey(product.productId) ? prices.get(product.productId) : null;

        if (quantity != activeItem.Quantity) {
            upsertCartItem(activeItem, product.productId, quantity, pricebookEntry);
        }

        return new AddItemResponse(cartId);
    }

    public static List<GuestCartItem> getGuestCartItems(WebStore webStore, String effectiveAccountId, List<CartItem> cartItems, String fieldSetName) {
        List<GuestCartItem> guestItems = new List<GuestCartItem>();

        if (cartItems == null || cartItems.isEmpty()) return guestItems;

        List<Id> productIds = B2BGuestCartProductService.getProductIdsByCartItems(cartItems);
        Map<Id, ConnectApi.ProductOverview> productDataMap = B2BGuestCartProductService.getProducts(
            webStore.Id,
            B2BGuestUtils.isCurrentUserGuest() ? webStore.GuestBuyerProfileId : effectiveAccountId,
            productIds,
            fieldSetName,
            includeDateTimeFields
        );

        Map<Id, ProductQuantityRule> qtyRulesMap = B2BGuestCartProductService.getQtyRulesMap(productIds);
        Map<Id, List<B2BGuestCartVariationService.Attribute>> variationAttributes = B2BGuestCartVariationService.getAttributesByProductIds(productIds);
        Map<Id, CartItemPriceAdjustment> itemPromotions = getItemPromotions(cartItems[0].CartId);

        guestItems = populateGuestItems(cartItems, productDataMap, qtyRulesMap, fieldSetName, variationAttributes, itemPromotions);

        return guestItems;
    }

    public static void changeQtyGuestCartItem(Id webStoreId, String effectiveAccountId, List<CartItem> cartItems, Id productId, Decimal quantity) {
        if (cartItems == null || cartItems.isEmpty()) {
            return;
        }

        List<ProductQuantityRule> rules = B2BGuestCartProductService.getQtyRules(new List<Id>{productId});
        if (rules != null) {
            quantity = checkQtyRules(quantity, rules[0].PurchaseQuantityRule.Maximum, cartItems[0].Quantity, false);
            System.debug('--quantity--' + quantity);
        }

        Map<Id, PricebookEntry> prices = B2BGuestCartProductService.getProductPricesMap(new List<Id>{productId}, effectiveAccountId, webStoreId);
        PricebookEntry pricebookEntry = prices.containsKey(productId) ? prices.get(productId) : null;

        if (quantity != cartItems[0].Quantity) {
            upsertCartItem(cartItems[0], productId, quantity, pricebookEntry);
        }
    }

    public static QtyRule initQtyRule(ProductQuantityRule qtyRule) {
        return new QtyRule(qtyRule);
    }

    public static void deleteGuestCartItem(List<CartItem> items) {
        if (items != null) {
            delete items;
        }
    }

    private static List<GuestCartItem> populateGuestItems(
        List<CartItem> cartItems,
        Map<Id, ConnectApi.ProductOverview>  productsData,
        Map<Id, ProductQuantityRule> qtyRulesMap,
        String fieldSetName,
        Map<Id, List<B2BGuestCartVariationService.Attribute>> variationAttributes,
        Map<Id, CartItemPriceAdjustment> itemPromotions
    ) {
        List<GuestCartItem> guestItems = new List<GuestCartItem>();

        for (CartItem cartItem: cartItems) {
            guestItems.add(new GuestCartItem(
                cartItem,
                productsData.containsKey(cartItem.Product2Id) ? productsData.get(cartItem.Product2Id) : null,
                qtyRulesMap == null ? null : qtyRulesMap.get(cartItem.Product2Id),
                fieldSetName,
                variationAttributes == null ? null : variationAttributes.get(cartItem.Product2Id),
                itemPromotions == null ? null : itemPromotions.get(cartItem.Id)
            ));
        }

        return guestItems;
    }

    private static Map<String, String> populateFields(Map<String, String> fields, String fieldSetName) {
        if (fields == null) {
            return null;
        }

        fields = includeDateTimeFields
            ? B2BGuestCartProductService.formatDateTimeFields(fields, fieldSetName)
            : fields;

        Map<String, String> resultFields = new Map<String, String>();
        List<Schema.FieldSetMember> fieldsFS = B2BGuestCartProductService.getFieldsFromFieldset('Product2', fieldSetName);

        if (fieldsFS == null) {
            return null;
        }

        for (Schema.FieldSetMember fieldFS : fieldsFS) {
            String value = fields.get(fieldFS.getFieldPath());
            if (value != null) {
                resultFields.put(fieldFS.label, value);
            }
        }

        return resultFields;
    }

    private static void upsertCartItem(CartItem cartItem, Id productId, Decimal quantity, PricebookEntry priceBookEntry) {
        cartItem.Type = 'Product';
        cartItem.Product2Id = productId;
        cartItem.Quantity = quantity;
        cartItem.Name = priceBookEntry?.Product2.Name;
        cartItem.Sku = Test.isRunningTest() ? 'Test-Sku' : priceBookEntry?.Product2.StockKeepingUnit;
        cartItem.ListPrice = priceBookEntry?.UnitPrice;
        cartItem.SalesPrice = priceBookEntry?.UnitPrice;
        cartItem.TotalLineAmount = (Double)((priceBookEntry?.UnitPrice == null ? 0 : priceBookEntry?.UnitPrice) * cartItem.Quantity).setScale(2);
        cartItem.TotalPrice = cartItem.TotalLineAmount;
        cartItem.CartDeliveryGroupId = getOrCreateCartDeliveryGroup(cartItem.CartId).Id;
        cartItem.UnitAdjustedPrice = cartItem.SalesPrice;
        cartItem.UnitAdjustmentAmount = 0;
        cartItem.AdjustmentAmount = 0;
        cartItem.TotalAdjustmentAmount = 0;
        cartItem.TotalListPrice = cartItem.TotalPrice;
        cartItem.TotalPriceAfterAllAdjustments = cartItem.TotalPrice;

        upsert cartItem;
    }

    private static CartDeliveryGroup getOrCreateCartDeliveryGroup(Id webCartId) {
        List<CartDeliveryGroup> cartDeliveryGroups = [
            SELECT Id
            FROM CartDeliveryGroup
            WHERE CartId = :webCartId
        ];

        if (cartDeliveryGroups == null || cartDeliveryGroups.isEmpty()) {
            CartDeliveryGroup deliveryGroup = new CartDeliveryGroup(
                CartId = webCartId,
                Name = 'GuestCartDeliveryGroup'
            );
            insert deliveryGroup;

            return deliveryGroup;
        }

        return cartDeliveryGroups[0];
    }

    private static Map<Id, CartItemPriceAdjustment> getItemPromotions(Id cartId) {
        List<CartItemPriceAdjustment> priceAdjustments = [
            SELECT
                Id,
                AdjustmentBasisReference.CouponCode,
                CartItemId,
                PriceAdjustmentCause.TermsAndConditions,
                TotalAmount
            FROM CartItemPriceAdjustment
            WHERE CartId = :cartId
                AND AdjustmentSource = 'Promotion'
        ];

        if (priceAdjustments == null || priceAdjustments.isEmpty()) {
            return null;
        }

        Map<Id, CartItemPriceAdjustment> itemPromotions = new Map<Id, CartItemPriceAdjustment>();
        for (CartItemPriceAdjustment priceAdjustment : priceAdjustments) {
            if (priceAdjustment.CartItemId != null) {
                itemPromotions.put(priceAdjustment.CartItemId, priceAdjustment);
            }
        }

        return itemPromotions.isEmpty() ? null : itemPromotions;
    }

    @TestVisible
    private static Decimal checkQtyRules(Decimal quantity, Decimal maxQty, Decimal itemQty, Boolean addToQty) {
        if (addToQty && itemQty >= maxQty
            || addToQty && (itemQty + quantity) > maxQty
            || !addToQty && quantity > maxQty
        ) {
            quantity = maxQty;
            isShowWarning = true;
        } else if (addToQty) {
            quantity += itemQty;
        }

        return quantity;
    }

    public class GuestCartItem {
        @AuraEnabled public Id productId;
        @AuraEnabled public Boolean isValid;
        @AuraEnabled public String name;
        @AuraEnabled public String sku;
        @AuraEnabled public String img;
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public Decimal price;
        @AuraEnabled public Decimal originalPrice;
        @AuraEnabled public Double discountAmount;
        @AuraEnabled public String coupon;
        @AuraEnabled public String termsAndConditions;
        @AuraEnabled public Double subtotal;
        @AuraEnabled public Decimal originalSubtotal;
        @AuraEnabled public Map<String,String> fields;
        @AuraEnabled public QtyRule qtyRule;
        @AuraEnabled public String productClass;
        @AuraEnabled public List<B2BGuestCartVariationService.Attribute> attributes;

        GuestCartItem(
            CartItem cartItem,
            ConnectApi.ProductOverview productData,
            ProductQuantityRule qtyRule,
            String fieldSetName,
            List<B2BGuestCartVariationService.Attribute> attributes,
            CartItemPriceAdjustment itemPromotion
        ) {
            this.productId = cartItem.Product2Id;
            this.name = cartItem.Name;
            this.sku = (String)productData?.sku;
            this.productClass = cartItem.Product2.ProductClass;
            this.quantity = cartItem.Quantity;
            this.img = ((ConnectApi.ProductMedia)productData?.defaultImage)?.url;
            this.fields = populateFields((Map<String,String>)productData?.fields, fieldSetName);
            this.price = ((ConnectApi.PricingResultLineItem)productData?.prices)?.unitPrice == null
                ? null
                : Decimal.valueOf(((ConnectApi.PricingResultLineItem)productData?.prices)?.unitPrice);
            this.originalPrice = ((ConnectApi.PricingResultLineItem)productData?.prices)?.listPrice == null
                ? null
                : Decimal.valueOf(((ConnectApi.PricingResultLineItem)productData?.prices)?.listPrice);
            this.originalSubtotal = this.originalPrice == null
                ? null
                : (this.originalPrice * this.quantity).setScale(2);
            this.qtyRule = qtyRule == null ? null : new QtyRule(qtyRule);
            this.isValid = (productData != null) && (this.price != null);
            this.attributes = attributes;
            this.discountAmount = (Double)itemPromotion?.TotalAmount;
            this.subtotal = (cartItem.TotalPrice == null ? 0 : (Double)cartItem.TotalPrice) + (this.discountAmount == null ? 0 : this.discountAmount);
            this.coupon = itemPromotion?.AdjustmentBasisReference?.CouponCode;
            String terms = itemPromotion?.PriceAdjustmentCause?.TermsAndConditions;
            this.termsAndConditions = String.isBlank(terms) ? null : terms;
        }
    }

    public class QtyRule {
        @AuraEnabled public Decimal min;
        @AuraEnabled public Decimal max;
        @AuraEnabled public Decimal inc;

        QtyRule(ProductQuantityRule qtyRule) {
            this.min = qtyRule.PurchaseQuantityRule?.Minimum;
            this.max = qtyRule.PurchaseQuantityRule?.Maximum;
            this.inc = qtyRule.PurchaseQuantityRule?.Increment;
        }
    }

    public class ProductInfo {
        @AuraEnabled public Id productId;
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public Boolean addToQuantity;
        @AuraEnabled public Decimal maxQty;
    }

    public class AddItemResponse {
        @AuraEnabled public Id guestCartId;
        @AuraEnabled public Boolean showWarning;

        AddItemResponse(Id cartId) {
            this.guestCartId = cartId;
            this.showWarning = isShowWarning;
        }
    }
}