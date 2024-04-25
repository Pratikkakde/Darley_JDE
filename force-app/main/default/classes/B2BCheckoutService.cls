public without sharing class B2BCheckoutService {

    public static WebCart getWebCartById(Id cartId) {
        List<WebCart> webCarts = [
            SELECT
                Id,
                AccountId,
                IsSecondary,
                B2BCheckoutBillingAddress__c,
                B2BCheckoutShippingAddress__c
            FROM WebCart
            WHERE Id = :cartId
        ];

        return webCarts.isEmpty() ? null : webCarts[0];
    }

    public static String getSpecialInstruction(Id cartId) {
        List<WebCart> webCarts = [
            SELECT B2BSpecialInstruction__c
            FROM WebCart
            WHERE Id = :cartId
        ];

        return webCarts.isEmpty() ? null : webCarts[0].B2BSpecialInstruction__c;
    }

    public static List<ContactPointAddress> getContactPointAddressesByParentId(Id accountId) {
        return [
            SELECT
                Id,
                Name,
                Street,
                City,
                State,
                PostalCode,
                Country,
                StateCode,
                CountryCode,
                IsDefault,
                AddressType,
                ParentId
            FROM ContactPointAddress
            WHERE ParentId = :accountId
            ORDER BY Name ASC
        ];
    }

    public static List<ContactPointAddress> getBillingAddresses(Id accountId) {
        return [
            SELECT Id
            FROM ContactPointAddress
            WHERE ParentId = :accountId
                AND AddressType = :B2BCheckoutAddress.BILLING_TYPE
            ORDER BY Name ASC
        ];
    }

    public static WebCart getCartTotals(Id cartId) {
        List<WebCart> carts = [
            SELECT
                TotalProductAmount,
                TotalTaxAmount,
                TotalPromoAdjustmentAmount,
                GrandTotalAmount,
                TotalChargeAmount
            FROM WebCart
            WHERE Id = :cartId
        ];

        return carts.isEmpty() ? null : carts[0];
    }

    public static Id getAddressIdByType(List<ContactPointAddress> addresses, String addressType) {
        Id addressId;
        for (ContactPointAddress contactPointAddress : addresses) {
            if (contactPointAddress.AddressType == addressType) {
                addressId = contactPointAddress.Id;
                break;
            }
        }

        return addressId;
    }

    public static List<ConnectApi.CartItemResult> getCartItems(Id webStoreId, Id cartId) {
        ConnectApi.CartItemCollection cartItemsCollectionApi;
        List<ConnectApi.CartItemResult> cartItemResults = new List<ConnectApi.CartItemResult>();

        if (Test.isRunningTest()) {
            cartItemsCollectionApi = new ConnectApi.CartItemCollection();
            List<Product2> prod = [SELECT Id FROM Product2 LIMIT 1];
            ConnectApi.CartItemResult cartItemResult = new ConnectApi.CartItemResult();
            cartItemResult.cartItem = new ConnectApi.CartItem();
            cartItemResult.cartItem.productId = prod[0].Id;
            cartItemResult.cartItem.type = ConnectApi.CartItemType.Product;
            cartItemResult.cartItem.productDetails = new ConnectApi.CartItemProduct();
            cartItemResult.cartItem.productDetails.fields = new Map<String, String>();
            cartItemResult.cartItem.productDetails.thumbnailImage = new ConnectApi.ProductMedia();
            cartItemResult.cartItem.productDetails.thumbnailImage.url = 'url';
            cartItemResult.cartItem.productDetails.sku = 'sku';
            cartItemResult.cartItem.quantity = '10';
            cartItemResult.cartItem.productDetails.variationAttributes = new Map<String, ConnectApi.CartProductAttribute>();

            cartItemsCollectionApi.cartItems = new List<ConnectApi.CartItemResult>{
                cartItemResult
            };

            cartItemsCollectionApi.nextPageToken = null;
        } else {
            cartItemsCollectionApi = ConnectApi.CommerceCart.getCartItems(webStoreId, null, cartId, null, 100);
        }
        String nextPageToken = String.valueOf(cartItemsCollectionApi.nextPageToken);
        cartItemResults = (List<ConnectApi.CartItemResult>) cartItemsCollectionApi.cartItems;

        while (nextPageToken != null) {
            ConnectApi.CartItemCollection anotherCollection = ConnectApi.CommerceCart.getCartItems(webStoreId, null, cartId, nextPageToken, 100);
            nextPageToken = String.valueOf(anotherCollection.nextPageToken);
            cartItemResults.addAll((List<ConnectApi.CartItemResult>) anotherCollection.cartItems);
        }

        return cartItemResults;
    }

    public static void updateCheckoutAddress(Id cartId, Id shippingAddressId, Id billingAddressId) {
        update new WebCart(
            Id = cartId,
            B2BCheckoutBillingAddress__c = billingAddressId,
            B2BCheckoutShippingAddress__c = shippingAddressId
        );
    }

    public static void upsertAddress(List<ContactPointAddress> contactPointAddress) {
        upsert contactPointAddress;
    }

    public static void updateInstruction(Id cartId, String instruction) {
        update new WebCart(
            Id = cartId,
            B2BSpecialInstruction__c = instruction
        );
    }

    public static void updatePaymentMethod(Id cartId, String paymentMethod) {
        update new WebCart(
            Id = cartId,
            Payment_Type__c = paymentMethod
        );
    }

    public static void updateCard(Id cartId, String creditCardId, String creditCardName) {
        update new WebCart(
            Id = cartId,
            B2BCreditCardId__c = creditCardId,
            B2BCreditCardName__c = creditCardName
        );
    }

    public static void updatePoNumber(Id cartId, String poNumber) {
        update new WebCart(
            Id = cartId,
            PoNumber = poNumber
        );
    }

    public static void saveHasDarleyDollars(Id cartId, Boolean hasDarleyDollars) {
        update new WebCart(
            Id = cartId,
            B2BHasDarleyDollars__c = hasDarleyDollars
        );
    }

}