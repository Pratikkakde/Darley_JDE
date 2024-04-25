public without sharing class B2BQuotePrintController {

    public Id recordId { get; set; }
    public Date requestedDate { get; private set; }
    public Date expirationDate { get; private set; }
    public String quoteNumber { get; private set; }
    public String quoteStatus { get; private set; }
    public String billingAddressStreet { get; private set; }
    public String billingAddressCity { get; private set; }
    public String billingAddressPostalCode { get; private set; }
    public String billingAddressCountryCode { get; private set; } 
    public String billingAddressState { get; private set; }
    public String shippingAddressStreet { get; private set; }
    public String shippingAddressCity { get; private set; }
    public String shippingAddressState { get; private set; }
    public String shippingAddressPostalCode { get; private set; }
    public String shippingAddressCountryCode { get; private set; }
    public Decimal quoteSubtotal { get; private set; }
    public Decimal estimatedTax { get; private set; }
    public Decimal estimatedShipping { get; private set; }
    public Decimal estimatedQuoteTotal { get; private set; }
    public Decimal promotions { get; private set; }

    public Boolean showProducts {
        get { return products != null && !products.isEmpty(); }
        set;
    }
    public List<QuoteProduct> products { get; private set; }
    public Decimal total { get; private set; }

    public B2BQuotePrintController() {
        recordId = ApexPages.currentPage().getParameters().get('id');

        B2BResponse responseResult = B2BQuoteDetailController.initQuote(recordId, null);
        if (responseResult.isSuccess) {
            Map<String, Object> quoteMap = (Map<String, Object>)responseResult.responseData;
            B2BQuoteDetailController.QuoteDto quoteData = (B2BQuoteDetailController.QuoteDto)quoteMap.get('quote');
            requestedDate = quoteData.requestedDate;
            expirationDate = quoteData.expirationDate;
            quoteNumber = quoteData.quoteNumber;
            quoteStatus = quoteData.status;
            total = quoteData.total;
            billingAddressStreet = quoteData.billingAddressStreet;
            billingAddressCity = quoteData.billingAddressCity;
            billingAddressState = quoteData.billingAddressState;
            billingAddressPostalCode = quoteData.billingAddressPostalCode;
            billingAddressCountryCode = quoteData.billingAddressCountryCode;
            shippingAddressStreet = quoteData.shippingAddressStreet;
            shippingAddressCity = quoteData.shippingAddressCity;
            shippingAddressState = quoteData.shippingAddressState;
            shippingAddressPostalCode = quoteData.shippingAddressPostalCode;
            shippingAddressCountryCode = quoteData.shippingAddressCountryCode;
            quoteSubtotal = quoteData.quoteSubtotal;
            estimatedTax = quoteData.estimatedTax;
            estimatedShipping = quoteData.estimatedShipping;
            estimatedQuoteTotal = quoteData.estimatedQuoteTotal;
            promotions = quoteData.promotions;

            List<QuoteProduct> newProductsList = new List<QuoteProduct>();
            for (B2BQuoteDetailController.QuoteItemDto rec: quoteData.items) {
                QuoteProduct newProduct = new QuoteProduct();
                newProduct.name = rec.productName;
                newProduct.sku = rec.SKU;
                newProduct.quantity = Integer.valueOf(rec.quantity);
                newProduct.unitPrice = rec.unitPrice;
                newProduct.total = rec.total;
                newProductsList.add(newProduct); 
            }

            products = newProductsList;
        }
    }

    private class QuoteProduct {
        public String name { get; set; }
        public String sku { get; set; }
        public Integer quantity { get; set; }
        public Decimal unitPrice { get; set; }
        public Decimal total { get; set; }
    }

}