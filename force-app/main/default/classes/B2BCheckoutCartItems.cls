public without sharing class B2BCheckoutCartItems {

    @AuraEnabled public List<CartItemDto> cartItems { get; set; }
    @AuraEnabled public Boolean isCartSecondary { get; set; }

    public B2BCheckoutCartItems(Id cartId) {
        WebCart webCart = B2BCheckoutService.getWebCartById(cartId);
        isCartSecondary = webCart.IsSecondary;

        String webStoreId = B2BUtils.getStoreIdRelatedToCurrentUser();
        initCartItems(webStoreId, webCart.Id);
    }

    private void initCartItems(Id webStoreId, Id webCartId) {
        cartItems = new List<CartItemDto>();
        for (ConnectApi.CartItemResult cartItemResult : B2BCheckoutService.getCartItems(webStoreId, webCartId)) {
            cartItems.add(new CartItemDto((ConnectApi.CartItem)cartItemResult.cartItem));
        }
    }

    public class CartItemDto {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String image;

        @AuraEnabled public String sku;
        @AuraEnabled public List<Map<String, String>> productVariant;
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public Decimal totalPrice;

        public CartItemDto(ConnectApi.CartItem cartItem) {
            id = cartItem.productId;
            name = cartItem.name;
            image = cartItem.productDetails.thumbnailImage.url;
            sku = cartItem.productDetails.sku;
            productVariant = convertProductAttributes(cartItem.productDetails.variationAttributes);
            quantity = cartItem.quantity == null ? 0 : Decimal.valueOf(cartItem.quantity);
            totalPrice = cartItem.totalPrice == null ? 0 : Decimal.valueOf(cartItem.totalPrice);
        }

        private List<Map<String, String>> convertProductAttributes(Map<String, ConnectApi.CartProductAttribute> productVariantAttributes){
            List<Map<String, String>> collectionProductAttributes = new List<Map<String, String>>();
            for(String cartProductAttributeKey : productVariantAttributes.keySet()){
                Map<String, String> attributeLabelToValue = new Map<String, String>();
                ConnectApi.CartProductAttribute productAttribute = productVariantAttributes.get(cartProductAttributeKey);
                attributeLabelToValue.put('label', productAttribute.label);
                attributeLabelToValue.put('value', productAttribute.value);
                collectionProductAttributes.add(attributeLabelToValue);
            }

            return collectionProductAttributes;
        }
    }

}