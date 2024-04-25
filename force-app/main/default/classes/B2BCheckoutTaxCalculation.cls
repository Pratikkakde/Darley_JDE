global with sharing class B2BCheckoutTaxCalculation implements sfdc_checkout.CartTaxCalculations {

    global Sfdc_Checkout.IntegrationStatus startCartProcessAsync(Sfdc_Checkout.IntegrationInfo jobInfo, Id cartId) {
        Sfdc_Checkout.IntegrationStatus integrationStatus = new Sfdc_Checkout.IntegrationStatus();
        try {
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

            List<CartTax> taxesForDelete = [
                SELECT Id
                FROM CartTax
                WHERE CartItemId IN :cartItemIds
            ];

            if (isAccountTaxable(accountId) && !taxableCartItemIds.isEmpty()) {
                createCartTaxes(cartId);
            }

            if (taxesForDelete.isEmpty() == false) {
                delete taxesForDelete;
            }

            integrationStatus.status = Sfdc_Checkout.IntegrationStatus.Status.SUCCESS;
        } catch (Exception e) {
            return setFailedIntegrationStatus(
                integrationStatus,
                System.Label.B2B_Unable_To_Calculate_Tax,
                jobInfo,
                cartId
            );
        }

        return integrationStatus;
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

        insert cartTaxes;
    }

    private static List<CartTax> getCartTaxesFromAvaTaxRatesAndAmounts(Id cartId) {
        List<CartTax> cartTaxes = new List<CartTax>();
        B2BAvalara avaTax = new B2BAvalara();
        B2BAvalaraWrapper.Response avalaraResponse = avaTax.calculateTax(cartId);

        if (avalaraResponse == null) {
            return null;
        }

        if (avalaraResponse.error != null) {
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

    /**
     *      Set integration Status as Failed. For the error to be propagated to the user,
     * we need to add a new CartValidationOutput record.
     * @param integrationStatus - Integration Status.
     * @param errorMessage - Message displayed to the user (maximum 255 characters).
     * @param jobInfo - Foreign Info to the BackgroundOperation.
     * @param cartId - Foreign key to the WebCart that this validation line is for.
     * @return Integration Status record.
     */
    private Sfdc_Checkout.IntegrationStatus setFailedIntegrationStatus(
        Sfdc_Checkout.IntegrationStatus integrationStatus,
        String errorMessage,
        Sfdc_Checkout.IntegrationInfo jobInfo,
        Id cartId
    ) {
        integrationStatus.status = Sfdc_Checkout.IntegrationStatus.Status.FAILED;

        CartValidationOutput cartValidationError = new CartValidationOutput(
            BackgroundOperationId = jobInfo.jobId,
            CartId = cartId,
            Level = 'Error', //One of the following - Info, Error, or Warning
            Message = errorMessage.left(255),
            Name = (String) cartId + ':' + jobInfo.jobId,
            RelatedEntityId = cartId,
            Type = 'Taxes' //One of the following - SystemError, Inventory, Taxes, Pricing, Shipping, Entitlement, Other
        );
        insert(cartValidationError);

        return integrationStatus;
    }

}