/**
 * Created by IrinaSakovich on 22.07.22.
 */

public without sharing class B2BGuestCartController
{
    @AuraEnabled
    public static B2BResponse getProductQtyDetails(List<Id> productIds) {
        try {
            return new B2BResponse(true, parseProductQtyData(productIds), '');
        } catch (Exception ex) {
            System.debug(ex.getStackTraceString());
            return new B2BResponse(true, ex.getStackTraceString(), ex.getMessage());
        }
    }

    @AuraEnabled
    public static B2BResponse addToCart(String productInfo, String effectiveAccountId, String cartId) {
        try {
            if (B2BGuestUtils.isCurrentUserGuest()) {
                effectiveAccountId = null;
            }

            WebStore webStore = B2BGuestUtils.getStoreRelatedToCurrentUser();
            B2BGuestCartItemService.ProductInfo product = (B2BGuestCartItemService.ProductInfo)JSON.deserialize(productInfo, B2BGuestCartItemService.ProductInfo.class);
            WebCart activeCart = B2BGuestCartService.getOrCreateActiveCart(webStore.Id, cartId, product.productId, null);
            List<CartItem> cartItems = String.valueOf(activeCart.Id) == cartId ? activeCart.CartItems : null;

            return new B2BResponse(true, B2BGuestCartItemService.addItemToCart(cartItems, product, webStore.Id, effectiveAccountId, activeCart.Id), '');
        } catch (Exception ex) {
            System.debug(ex.getStackTraceString());
            return new B2BResponse(false, ex.getStackTraceString(), ex.getMessage());
        }
    }

    @AuraEnabled
    public static B2BResponse getCartData(String effectiveAccountId, String cartId) {
        try {
            if (B2BGuestUtils.isCurrentUserGuest()) {
                effectiveAccountId = null;
            }

            WebStore webStore = B2BGuestUtils.getStoreRelatedToCurrentUser();
            WebCart activeCart = B2BGuestCartService.getOrCreateActiveCart(webStore.Id, cartId);

            return new B2BResponse(true, B2BGuestCartService.populateCartData(cartId, activeCart), '');
        } catch (Exception ex) {
            System.debug(ex.getStackTraceString());
            return new B2BResponse(false, ex.getStackTraceString(), ex.getMessage());
        }
    }

    @AuraEnabled
    public static B2BResponse getInitialGuestCart(String effectiveAccountId, String cartId, String sortOrder, String fieldSet) {
        try {
            if (B2BGuestUtils.isCurrentUserGuest()) {
                effectiveAccountId = null;
            }

            WebStore webStore = B2BGuestUtils.getStoreRelatedToCurrentUser();
            WebCart activeCart = B2BGuestCartService.getOrCreateActiveCart(webStore.Id, cartId, null, sortOrder);

            return new B2BResponse(true, B2BGuestCartService.getGuestCart(webStore, effectiveAccountId, cartId, activeCart, fieldSet), '');
        } catch (Exception ex) {
            System.debug(ex.getStackTraceString());
            return new B2BResponse(false, ex.getStackTraceString(), ex.getMessage());
        }
    }

    @AuraEnabled
    public static B2BResponse clearGuestCart(String effectiveAccountId, String cartId) {
        try {
            if (B2BGuestUtils.isCurrentUserGuest()) {
                effectiveAccountId = null;
            }

            WebStore webStore = B2BGuestUtils.getStoreRelatedToCurrentUser();
            WebCart activeCart = B2BGuestCartService.getOrCreateActiveCart(webStore.Id, cartId);

            if (String.valueOf(activeCart.Id) == cartId) {
                delete activeCart;
                activeCart = B2BGuestCartService.getOrCreateActiveCart(webStore.Id, cartId);
            }

            return new B2BResponse(true, B2BGuestCartService.getGuestCart(webStore, effectiveAccountId, cartId, activeCart, null), '');
        } catch (Exception ex) {
            System.debug(ex.getStackTraceString());
            return new B2BResponse(false, ex.getStackTraceString(), ex.getMessage());
        }
    }

    @AuraEnabled
    public static B2BResponse deleteGuestCartItem(String effectiveAccountId, String cartId, String productId, String sortOrder, String fieldSet) {
        try {
            if (B2BGuestUtils.isCurrentUserGuest()) {
                effectiveAccountId = null;
            }

            WebStore webStore = B2BGuestUtils.getStoreRelatedToCurrentUser();
            WebCart activeCart = B2BGuestCartService.getOrCreateActiveCart(webStore.Id, cartId, productId, sortOrder);

            if (String.valueOf(activeCart.Id) == cartId) {
                B2BGuestCartItemService.deleteGuestCartItem(activeCart.CartItems);
                activeCart = B2BGuestCartService.getOrCreateActiveCart(webStore.Id, cartId, null, sortOrder);
            }

            return new B2BResponse(true, B2BGuestCartService.getGuestCart(webStore, effectiveAccountId, cartId, activeCart, fieldSet), '');
        } catch (Exception ex) {
            System.debug(ex.getStackTraceString());
            return new B2BResponse(false, ex.getStackTraceString(), ex.getMessage());
        }
    }

    @AuraEnabled
    public static B2BResponse changeQtyGuestCartItem(String effectiveAccountId, String cartId, String productId, Decimal quantity, String sortOrder, String fieldSet) {
        try {
            if (B2BGuestUtils.isCurrentUserGuest()) {
                effectiveAccountId = null;
            }

            WebStore webStore = B2BGuestUtils.getStoreRelatedToCurrentUser();
            WebCart activeCart = B2BGuestCartService.getOrCreateActiveCart(webStore.Id, cartId, productId, sortOrder);

            if (String.valueOf(activeCart.Id) == cartId) {
                B2BGuestCartItemService.changeQtyGuestCartItem(webStore.Id, effectiveAccountId, activeCart.CartItems, productId, quantity);
                activeCart = B2BGuestCartService.getOrCreateActiveCart(webStore.Id, cartId, null, sortOrder);
            }

            return new B2BResponse(true, B2BGuestCartService.getGuestCart(webStore, effectiveAccountId, cartId, activeCart, fieldSet), '');
        } catch (Exception ex) {
            System.debug(ex.getStackTraceString());
            return new B2BResponse(false, ex.getStackTraceString(), ex.getMessage());
        }
    }

    private static List<ProductQtyData> parseProductQtyData(List<Id> productIds) {
        List<ProductQtyData> productQtyData = new List<ProductQtyData>();
        List<ProductQuantityRule> qtyRules = B2BGuestCartProductService.getQtyRules(productIds);

        if (qtyRules == null) {
            return productQtyData;
        }

        for (ProductQuantityRule qtyRule : qtyRules) {
            productQtyData.add(new ProductQtyData(qtyRule));
        }

        return productQtyData;
    }

    public class ProductQtyData {
        @AuraEnabled public String id;
        @AuraEnabled public B2BGuestCartItemService.QtyRule qtyRule;

        ProductQtyData() {}

        ProductQtyData(ProductQuantityRule qtyRule) {
            this.id = qtyRule.ProductId;
            this.qtyRule = B2BGuestCartItemService.initQtyRule(qtyRule);
        }
    }
}