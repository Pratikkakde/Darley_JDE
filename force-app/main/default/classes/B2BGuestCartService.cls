/**
 * Created by IrinaSakovich on 22.07.22.
 */

public without sharing class B2BGuestCartService {

    @InvocableMethod
    public static void deleteExpiredCart(List<InputVariables> variables) {
        try {
            List<Id> cartIds = new List<Id>();
            for (InputVariables variable : variables) {
                cartIds.add(variable.cartId);
            }

            List<WebCart> carts = [SELECT Id, AccountId FROM WebCart WHERE Id IN :cartIds];
            if (carts == null || carts.isEmpty()) {
                return;
            }

            List<Id> accIds = new List<Id>();
            for (WebCart cart : carts) {
                accIds.add(cart.AccountId);
                // Delete inside the loop was used because of some salesforce restriction on delete bunch of records
                // which triggered the flow execution
                Database.DeleteResult result = Database.delete(cart, false, AccessLevel.SYSTEM_MODE);
                if (result.success == false) {
                    System.debug(result.errors);
                }
            }

            Database.delete(accIds);
        } catch (Exception ex) {
            System.debug(ex.getMessage() + ex.getStackTraceString());
        }
    }

    public static GuestCart getGuestCart(WebStore webStore, String effectiveAccountId, String cartId, WebCart activeCart, String fieldSetName) {
        return new GuestCart(webStore, effectiveAccountId, cartId, activeCart, fieldSetName);
    }

    public static WebCart getOrCreateActiveCart(String webStoreId, String cartId) {
        return getOrCreateActiveCart(webStoreId, cartId, null, null);
    }

    public static WebCart getOrCreateActiveCart(String webStoreId, String cartId, String productId, String sortOrder) {
        List<WebCart> carts = getCartWithItems(webStoreId, cartId, productId, sortOrder);

        if (carts != null && !carts.isEmpty() && carts[0].Expiration_Date__c >= System.today()) {
            return carts[0];
        }

        if (carts != null && !carts.isEmpty()) {
            Account acc = new Account(Id = carts[0].AccountId);
            delete carts;
            delete acc;
        }

        WebCart currentCart = new WebCart(
            Name = 'GuestCart',
            WebStoreId = webStoreId,
            AccountId = B2BGuestUtils.getUniqueGuestAccount().Id
        );
        insert currentCart;

        return currentCart;
    }

    private static List<WebCart> getCartWithItems(String webStoreId, String cartId, String productId, String sortOrder) {
        sortOrder = String.isBlank(sortOrder) ? 'Name' : sortOrder;
        
        String cartQuery =
        'SELECT\n' +
        '    Id,\n' +
        '    AccountId,\n' +
        '    TotalProductCount,\n' +
        '    UniqueProductCount,\n' +
        '    Expiration_Date__c,\n' +
        '    TotalProductAmount,\n' +
        '    TotalChargeAmount,\n' +
        '    TotalTaxAmount,\n' +
        '    TotalAdjustmentAmount,\n' +
        '    GrandTotalAmount,\n' +
        '    TotalAmountAfterAllAdjustments,\n' +
        '    (SELECT\n' +
        '        Id,\n' +
        '        CartId,\n' +
        '        Name,\n' +
        '        Quantity,\n' +
        '        Product2Id,\n' +
        '        Product2.ProductClass,\n' +
        '        TotalPrice\n' +
        '    FROM CartItems\n';

        if (productId != null) {
            cartQuery += '    WHERE Product2Id = :productId\n';
        }

        cartQuery += '    ORDER BY ' + sortOrder + '\n';

        cartQuery += '   )\n'+
        'FROM WebCart\n' +
        'WHERE Id = :cartId\n' +
        '    AND (Status = \'Active\' OR Status = \'Checkout\')\n' +
        '    AND WebStoreId = :webStoreId\n' +
        'LIMIT 1';
        
        List<WebCart> carts = Database.query(cartQuery);

        return carts;
    }

    public static CartData populateCartData(String cartId, WebCart activeCart) {
        return String.valueOf(activeCart.Id) == cartId
            ? new CartData(activeCart.Id, activeCart.TotalProductCount, activeCart.UniqueProductCount)
            : new CartData(activeCart.Id, 0, 0);
    }

    private static CartTotals populateCartTotals(String cartId, WebCart activeCart) {
        return String.valueOf(activeCart.Id) == cartId
            ? new CartTotals(
                (Double)activeCart.TotalProductAmount,
                (Double)activeCart.TotalChargeAmount,
                (Double)activeCart.TotalTaxAmount,
                (Double)activeCart.TotalAdjustmentAmount,
                (Double)activeCart.TotalAmountAfterAllAdjustments
            )
            : new CartTotals(0, 0, 0, 0, 0);
    }

    public class GuestCart {
        @AuraEnabled public Id id;
        @AuraEnabled public String currencyIsoCode;
        @AuraEnabled public CartData cartData;
        @AuraEnabled public CartTotals totals;
        @AuraEnabled public List<B2BGuestCartItemService.GuestCartItem> items;

        GuestCart() {}

        @TestVisible
        GuestCart(WebStore webStore, String effectiveAccountId, String cartId, WebCart activeCart, String fieldSetName) {
            this.id = activeCart.Id;
            this.currencyIsoCode = UserInfo.getDefaultCurrency();
            this.cartData = populateCartData(cartId, activeCart);
            this.totals = populateCartTotals(cartId, activeCart);
            this.items = B2BGuestCartItemService.getGuestCartItems(
                webStore,
                effectiveAccountId,
                String.valueOf(activeCart.Id) == cartId ? activeCart.CartItems : null,
                fieldSetName
            );
        }
    }

    public class CartTotals {
        @AuraEnabled public Double subtotal;
        @AuraEnabled public Double shipping;
        @AuraEnabled public Double tax;
        @AuraEnabled public Double discount;
        @AuraEnabled public Double total;

        CartTotals(Double subtotal, Double shipping, Double tax, Double discount, Double total) {
            this.subtotal = subtotal;
            this.shipping = null;
            this.tax = null;
            this.discount = discount;
            this.total = total;
        }
    }

    public class CartData {
        @AuraEnabled public Id cartId;
        @AuraEnabled public Decimal cartProductsQuantity;
        @AuraEnabled public Decimal cartItemsQuantitySum;

        CartData(Id cartId, Decimal totalProductCount, Decimal uniqueProductCount) {
            this.cartId = cartId;
            this.cartProductsQuantity = uniqueProductCount;
            this.cartItemsQuantitySum = totalProductCount;
        }
    }

    public class InputVariables {

        @InvocableVariable
        public String cartId;
    }
}