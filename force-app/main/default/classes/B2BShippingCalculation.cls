public class B2BShippingCalculation {
    private static final String CART_ITEM_DELIVERY_NAME = 'Delivery Cart Item';
    private static final Decimal SHIPPING_COST_PERCENTAGE =  0.03;
    
    public static void calculateShipping(String cartId){
        WebCart cart = [SELECT Id, IsSecondary, (SELECT Product2Id FROM CartItems WHERE Type NOT IN ('Charge') LIMIT 1) FROM WebCart WHERE Id=: cartId ];
        if (!cart.IsSecondary) {
            removeExistingShipping(cartId);
            Decimal subtotal = getSubTotal(cartId);
            List<B2BFreightTableForShippingCost__mdt>  freightShippingRecords = getFreightShippingTable(subtotal);
            Decimal shippingCost = freightShippingRecords.isEmpty()? subtotal * SHIPPING_COST_PERCENTAGE : freightShippingRecords.get(0).ShippingCost__c ;
            createDeliveryItem(cartId, shippingCost, cart.CartItems.get(0).Product2Id);
        }
    }


    private static void createDeliveryItem(Id cartId, Decimal shippingCost, Id productId) {
        if (shippingCost > 0) {

            Id cartDeliveryGroupId = getCartDeliveryGroupId(cartId);
            Product2 shippingProduct = getShippingProductId();
            insert new CartItem(
                Type = 'Charge',
                Quantity = 1.0,
                TotalPrice = shippingCost,
                ListPrice = shippingCost,
                TotalListPrice = shippingCost,
                TotalLineAmount = shippingCost,
                AdjustmentAmount = 0.0,
                CartId = cartId,
                CartDeliveryGroupId = cartDeliveryGroupId,
                Name = shippingProduct != null ? shippingProduct.Name : CART_ITEM_DELIVERY_NAME,
                Product2Id = shippingProduct != null ? shippingProduct.Id : productId
            );        
        }
    }

    public static Product2 getShippingProductId () {
        String shippingProductSku = [SELECT DeveloperName, Value__c 
            FROM B2B_Commerce_Setting__mdt 
            WHERE DeveloperName = 'Shipping_Product_Sku' LIMIT 1].Value__c;
        List<Product2> shippingProd = [SELECT Id, Name FROM Product2 WHERE StockKeepingUnit =: shippingProductSku];
        
        return shippingProd.isEmpty() ? null : shippingProd[0];
    }

   public static void removeExistingShipping(Id cartId){
        List<CartItem> cartItems = [SELECT Id FROM CartItem WHERE CartId =: cartId AND Name =:CART_ITEM_DELIVERY_NAME ];
        if (!cartItems.isEmpty()) {
            delete cartItems;
        }
    }

    private static Id getCartDeliveryGroupId(Id cartId) {
        List<CartDeliveryGroup> cartDeliveryGroups = [
            SELECT Id
            FROM CartDeliveryGroup
            WHERE CartId = :cartId
        ];

        if (cartDeliveryGroups.isEmpty()) {
            throw new ShippingCalculationException(Label.B2B_Something_went_wrong_Please_try_again_or_contact_us);
        }

        return cartDeliveryGroups[0].Id;
    }

    private static List<B2BFreightTableForShippingCost__mdt> getFreightShippingTable( Decimal subTotal){
        return [
            SELECT Id, ShippingCost__c
            FROM B2BFreightTableForShippingCost__mdt
            WHERE OrderSubtotalLowerLimit__c <=: subTotal AND OrderSubtotalUpperLimit__c >=: subTotal
        ];
    }

    private static Decimal getSubTotal(String cartId){
        AggregateResult ar = [SELECT SUM(TotalLineAmount) subTotal FROM CartItem WHERE CartId =:cartId AND Product2.B2BFreeShipping__c = false];
        return (Decimal) ar.get('subTotal');
    }
    

    public class ShippingCalculationException extends Exception{}
}