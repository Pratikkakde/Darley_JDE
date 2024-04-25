public without sharing class B2BAvalaraService {

    private static final String CURRENCY_USD = 'USD';

    public static B2BAvalaraWrapper.Request getWebCartRequestData(String cartId, String companyCode) {
        List<CartItem> cartItems = getCartItems(cartId);
        List<B2BAvalaraWrapper.Line> lines = getLines(cartItems);
        B2BAvalaraWrapper.Addresses addresses;
        String customerCode = '';
        if (cartItems[0].Cart.B2BCheckoutShippingAddress__c != null) {
            addresses = getAddresses(cartItems[0].Cart.B2BCheckoutShippingAddress__c);
            Account account = [SELECT Id, B2BAvalaraCustomerCode__c FROM Account WHERE Id = :cartItems[0].Cart.AccountId];
            customerCode = account.B2BAvalaraCustomerCode__c == null ? String.valueOf(account.Id) : account.B2BAvalaraCustomerCode__c;
        } else {
            return null;
        }

        String currencyIsoCode = CURRENCY_USD;

        B2BAvalaraWrapper.Request requestBody = new B2BAvalaraWrapper.Request(
            companyCode,
            customerCode,
            lines,
            addresses,
            currencyIsoCode
        );

        return requestBody;
    }

    public static B2BAvalaraWrapper.Response parseResponse(String json) {
        return (B2BAvalaraWrapper.Response) System.JSON.deserialize(json, B2BAvalaraWrapper.Response.class);
    }

    public static B2BAvalaraWrapper.ResponseCompanies parseCompaniesResponse(String json) {
        return (B2BAvalaraWrapper.ResponseCompanies) System.JSON.deserialize(json, B2BAvalaraWrapper.ResponseCompanies.class);
    }

    private static List<CartItem> getCartItems(String cartId) {
        return  [
            SELECT
                Id,
                Quantity,
                Cart.TotalAmount,
                Cart.AccountId,
                Cart.Account.Name,
                Cart.B2BCheckoutShippingAddress__c,
                Product2Id,
                Product2.Name,
                Product2.TaxCode__c,
                TotalLineAmount,
                SalesPrice
            FROM CartItem
            WHERE CartId = :cartId
                AND Type = 'Product'
                AND Product2.B2BTaxExempt__c = FALSE
        ];
    }

    private static List<CartDeliveryGroup> getCartDeliveryGroup(String cartId) {
        return [
            SELECT
                DeliverToPostalCode,
                DeliverToState,
                DeliverToStreet,
                DeliverToAddress,
                DeliverToCity,
                DeliverToCountry
            FROM CartDeliveryGroup
            WHERE CartId = :cartId
        ];
    }

    private static List<B2BAvalaraWrapper.Line> getLines(List<CartItem> cartItems) {
        List<B2BAvalaraWrapper.Line> lines = new List<B2BAvalaraWrapper.Line>();
        for (CartItem cartItem : cartItems) {
            B2BAvalaraWrapper.Line line = new B2BAvalaraWrapper.Line(
                cartItem.Product2.Name,
                cartItem.Id,
                String.valueOf(cartItem.TotalLineAmount),
                String.valueOf(cartItem.Quantity),
                cartItem.Product2.TaxCode__c
            );

            lines.add(line);
        }
        return lines;
    }

    private static B2BAvalaraWrapper.Addresses getAddresses(Id contactPointAddressId) {
        ContactPointAddress shippingAddress = [
            SELECT
                Id,
                Street,
                City,
                State,
                Country,
                PostalCode
            FROM ContactPointAddress
            WHERE Id = :contactPointAddressId
            LIMIT 1
        ];

        B2BAvalaraWrapper.Ship shipTo = getShipTo(shippingAddress);
        B2BAvalaraWrapper.Addresses addresses = new B2BAvalaraWrapper.Addresses(shipTo);

        return addresses;
    }

    private static B2BAvalaraWrapper.Ship getShipTo(ContactPointAddress contactPointAddress) {
        return new B2BAvalaraWrapper.Ship(
            contactPointAddress.Street,
            contactPointAddress.City,
            contactPointAddress.State,
            contactPointAddress.Country,
            contactPointAddress.PostalCode
        );
    }

}