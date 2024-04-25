public without sharing class B2BCheckoutOrderSummary {

    @AuraEnabled public Decimal items { get; set; }
    @AuraEnabled public Decimal salesTax {get ; set;}
    @AuraEnabled public Decimal promotion { get; set; }
    @AuraEnabled public Decimal orderTotal { get; set; }
    @AuraEnabled public Decimal totalChargeAmount { get; set; }


    public B2BCheckoutOrderSummary(Id cartId) {
        initOrderSummary(cartId);
    }

    private void initOrderSummary(Id cartId) {
        WebCart cart = B2BCheckoutService.getCartTotals(cartId);

        items = cart.TotalProductAmount;
        salesTax = cart.TotalTaxAmount;
        promotion = cart.TotalPromoAdjustmentAmount;
        orderTotal = cart.GrandTotalAmount;
        totalChargeAmount = cart.TotalChargeAmount;
    }

    public static void calculateTaxes(Id cartId) {
        List<Id> cartItemIds = new List<Id>();
        Set<Id> taxableCartItemIds = new Set<Id>();
        Id accountId;
        for (CartItem cartItem : [
            SELECT Id, Sku, TotalPrice, Type, Product2.Name, Product2.B2BTaxExempt__c, Cart.TotalProductAmount, Cart.AccountId
            FROM CartItem
            WHERE CartId = :cartId
            AND Type = 'Product'
            ORDER BY CreatedDate DESC
        ]) {
            accountId = cartItem.Cart.AccountId;
            cartItemIds.add(cartItem.Id);
            if (cartItem.Product2.B2BTaxExempt__c == false) {
                taxableCartItemIds.add(cartItem.Id);
            }
        }

        if (isAccountTaxable(accountId) && !taxableCartItemIds.isEmpty()) {
            createCartTaxes(cartId);
        }

    }

    public static CustomerTaxInformation getCustomerTaxInformation(Id cartId) {
        CustomerTaxInformation taxInformation = new CustomerTaxInformation();
        User currentUserInfo = getCurrentUserInfo();
        taxInformation.avalaraCustomerCode = currentUserInfo.AccountId;
        taxInformation.isNewAvalaraCustomer = String.isBlank(currentUserInfo?.Account?.B2BAvalaraCustomerCode__c);
        taxInformation.isBusinessAccountType = currentUserInfo.Account.AccountType__c == 'Business';
        
        Id contactPointAddressId = getContactPointAddressId(cartId);

        List<ContactPointAddress> shippingAddress = contactPointAddressId == null ? new List<ContactPointAddress>() : getShippinAddress(contactPointAddressId);
        List<ContactPointAddress> billingAddress = getAddresses(currentUserInfo.AccountId, 'Billing');
        List<ContactPointAddress> contactPointAddresses = !shippingAddress.isEmpty() ? shippingAddress: billingAddress;
        taxInformation.shipZone = !contactPointAddresses.isEmpty() ? contactPointAddresses[0].State : null;
        taxInformation.customerInfo = getCustomerInfo(currentUserInfo, contactPointAddresses);

        return taxInformation;
    }    

    private static Boolean isAccountTaxable(Id accountId) {
        List<Account> accounts = [
            SELECT Id, B2BTaxExempt__c
            FROM Account
            WHERE Id = :accountId
        ];

        return accounts.isEmpty() ? false : !accounts[0].B2BTaxExempt__c;
    }

    private static void createCartTaxes(String cartId) {
        // The total tax is automatically rolled up to TotalLineTaxAmount in the corresponding CartItem line.
        List<CartTax> cartTaxes = getCartTaxesFromAvaTaxRatesAndAmounts(cartId);

        if (cartTaxes != null && cartTaxes.isEmpty() == false) {
            insert cartTaxes;
        }
    }

    private static List<CartTax> getCartTaxesFromAvaTaxRatesAndAmounts(Id cartId) {
        List<CartTax> cartTaxes = new List<CartTax>();
        B2BAvalara avaTax = new B2BAvalara();
        B2BAvalaraWrapper.Response avalaraResponse = avaTax.calculateTax(cartId);

        if (avalaraResponse == null || avalaraResponse.error != null) {
            return null;
        }

        for (B2BAvalaraWrapper.ResponseLines line : avalaraResponse.lines) {
            String lineItemId = line.lineNumber;

            // The following fields from CartTax can be filled in:
            // Amount (required): Calculated tax amount.
            // CartItemId (required): ID of the cart item.
            // Description (optional): Description of CartTax.
            // Name (required): Name of the tax.
            // TaxCalculationDate (required): Calculation date for this tax line.
            // TaxRate (optional): The percentage value of the tax. Null if the tax is a flat amount.
            // TaxType (required): The type of tax, e.g. Actual or Estimated.
            CartTax tax = new CartTax(
                Amount = Decimal.valueOf(line.tax),
                CartItemId = lineItemId,
                Name = 'Tax',
                TaxCalculationDate = Date.today(),
                TaxRate = 0,
                TaxType = 'Actual'
            );
            cartTaxes.add(tax);
        }

        return cartTaxes;
    }

    private static User getCurrentUserInfo() {
        List<User> users = [
            SELECT
                Name,
                AccountId,
                Account.Name,
                Account.AccountType__c,
                Account.B2BAvalaraCustomerCode__c,
                Contact.Name,
                Contact.Phone
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];

        return users.isEmpty()
            ? null
            : users[0];
    }

    private static List<ContactPointAddress> getAddresses(Id acountId, String aType) {
        return [
            SELECT
                AddressType,
                City,
                Country,
                CountryCode,
                Id,
                IsDefault,
                IsPrimary,
                Name,
                PostalCode,
                State,
                StateCode,
                Street
            FROM ContactPointAddress
            WHERE Parentid =: acountId AND AddressType =: aType ];
    }

    private static List<ContactPointAddress> getShippinAddress(Id contactPointAddressId) {
        return [
            SELECT
                AddressType,
                City,
                Country,
                CountryCode,
                Id,
                IsDefault,
                IsPrimary,
                Name,
                PostalCode,
                State,
                StateCode,
                Street
            FROM ContactPointAddress
            WHERE Id =: contactPointAddressId
        ];
    }

    private static Id getContactPointAddressId(String cartId) {
        List<WebCart> cart = [
            SELECT B2BCheckoutShippingAddress__c
            FROM WebCart    
            WHERE Id =: cartId
        ];

        return !cart.isEmpty() ? cart[0].B2BCheckoutShippingAddress__c : null;
    }

    private static Map<String, String> getCustomerInfo(User currentUserInfo, List<ContactPointAddress> contactPointAddresses) {
        ContactPointAddress contactAddress = contactPointAddresses.isEmpty() ? null : contactPointAddresses[0];

        return contactAddress == null
            ? new Map<String, String>()
            : new Map<String, String> {
                'name' => currentUserInfo.Name,
                'phone' => currentUserInfo.Contact.Phone,
                'address1' => contactAddress.Street,
                'city' => contactAddress.City,
                'state' => contactAddress.State,
                'country' => contactAddress.Country,
                'zip' => contactAddress.PostalCode
        };
    }

    public class CustomerTaxInformation {
        @AuraEnabled public Map<String, String> customerInfo {get;set;}
        @AuraEnabled public String avalaraCustomerCode {get;set;}
        @AuraEnabled public String shipZone {get;set;}
        @AuraEnabled public Boolean isNewAvalaraCustomer {get;set;}
        @AuraEnabled public Boolean isBusinessAccountType {get;set;}
    }

    public class B2BCheckoutOrderSummaryException extends Exception {}

}