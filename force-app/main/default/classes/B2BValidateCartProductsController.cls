public without sharing class B2BValidateCartProductsController {
    private static final String SOMETHING_WENT_WRONG_MESSAGE = System.Label.Something_Went_Wrong_Please_contact_your_System_Administrator;

    @AuraEnabled
    public static B2BResponse validateCartProducts(Id effectiveAccountId) {
        try {
            String webStoreId =  B2BUtils.getStoreIdRelatedToCurrentUser();
            ConnectApi.CartSummary cartSummary =  B2BRequestForQuoteController.getCartSummary(webStoreId,effectiveAccountId);
            
            B2BCheckoutController.deleteAllTaxes( cartSummary.cartId);
            B2BShippingCalculation.removeExistingShipping(cartSummary.cartId);
            
            Set<Id> productIds = new Set<Id>();
            List<CartItem> cartItems = [ SELECT Id, Product2Id FROM CartItem  WHERE CartId =: cartSummary.cartId];
            for (CartItem currentCartItem : cartItems ) {
                productIds.add(currentCartItem.Product2Id);
            }

            Set<Id> validProducts = B2BRequestForQuoteController.getValidProducts(effectiveAccountId, productIds);
            
            List<CartItem> cartItemsDelete = new List<CartItem>();
            for (CartItem currentCartItem : cartItems ) {
                if(!validProducts.contains(currentCartItem.Product2Id)){
                    cartItemsDelete.add(currentCartItem);
                }
            }
            
            return new B2BResponse(true, cartItemsDelete , 'Success');
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage() + ' ' + e.getLineNumber(), SOMETHING_WENT_WRONG_MESSAGE);
        } 
    }

    @AuraEnabled
    public static B2BResponse validateCartProductsByCart(Id cartId) {
        try {
            Set<Id> productIds = new Set<Id>();
            WebCart cart =  [ SELECT AccountId, (SELECT Id, Product2Id  FROM CartItems )  FROM WebCart WHERE Id =:cartId] ;

            for (CartItem currentCartItem : cart.CartItems ) {
                productIds.add(currentCartItem.Product2Id);
            }

            Set<Id> validProducts = B2BRequestForQuoteController.getValidProducts(cart.AccountId, productIds);
            List<CartItem> cartItemsDelete = new List<CartItem>();
            for (CartItem currentCartItem : cart.CartItems ) {
                if(!validProducts.contains(currentCartItem.Product2Id)){
                    cartItemsDelete.add(currentCartItem);
                }
            }
            delete cartItemsDelete;
            return new B2BResponse(true, cartItemsDelete , 'Success');
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage() + ' ' + e.getLineNumber(), SOMETHING_WENT_WRONG_MESSAGE);
        }
    }

    @AuraEnabled
    public static B2BResponse validateCartProductByCart(Id cartId, Id prodId) {
        try {
            Set<Id> productIds = new Set<Id>();
            WebCart cart =  [ SELECT AccountId, (SELECT Id, Product2Id  FROM CartItems WHERE Product2Id =: prodId )  FROM WebCart WHERE Id =:cartId] ;

            for (CartItem currentCartItem : cart.CartItems ) {
                productIds.add(currentCartItem.Product2Id);
            }

            Set<Id> validProducts = B2BRequestForQuoteController.getValidProducts(cart.AccountId, productIds);
            List<CartItem> cartItemsDelete = new List<CartItem>();
            for (CartItem currentCartItem : cart.CartItems ) {
                if(!validProducts.contains(currentCartItem.Product2Id)){
                    cartItemsDelete.add(currentCartItem);
                }
            }
            if(!cartItemsDelete.isEmpty()){
                delete cartItemsDelete;
            }
            return new B2BResponse(true, cartItemsDelete , 'Success');
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage() + ' ' + e.getLineNumber(), SOMETHING_WENT_WRONG_MESSAGE);
        }
    }

    @AuraEnabled
    public static Boolean thereAreQuoteOnlyProducts(Id currentCartId) {
        Integer productsWithQuoteOnly = [
            SELECT COUNT()
            FROM CommerceEntitlementProduct
            WHERE ProductId IN (SELECT Product2Id FROM CartItem WHERE CartId =: currentCartId) 
            AND Policy.Name = 'Quote Only'
        ];

        return productsWithQuoteOnly > 0;
    }
}