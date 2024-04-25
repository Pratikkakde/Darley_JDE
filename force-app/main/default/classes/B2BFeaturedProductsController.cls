public without sharing class B2BFeaturedProductsController {
    public static final Integer PRODUCT_TO_SHOW = 20;
    private static final String ERROR_MESSAGE = System.Label.Something_Went_Wrong_Please_contact_your_System_Administrator;
    private static final String ADD_TO_CART_ERROR_MESSAGE = 'Something Went Wrong while adding a product to the cart. Try again later.';
    private static final String ADD_TO_CART_SUCCESS_MESSAGE = System.Label.The_product_was_added_to_your_cart;
    private static final String QUOTE_ONLY_ENTITLEMENT_POLICY = 'Quote Only';

    @AuraEnabled
    public static B2BResponse getProducts(String effectiveAccountId, Boolean isGuest) {
        try {
            if (effectiveAccountId == '000000000000000') {
                effectiveAccountId = null;
            }

            return new B2BResponse(true, getProductsInfo(effectiveAccountId, isGuest), '');
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage(), ERROR_MESSAGE);
        }
    }

    public static List<ProductData> getProductsInfo(String effectiveAccountId, Boolean isGuest) {
        Map<Id, ProductData> products = getFeaturedProducts(effectiveAccountId, isGuest);

        if (products.isEmpty()) {
            return products.values();
        }

        String webStoreId = B2BUtils.getStoreIdRelatedToCurrentUser();

        for (ProductData product : products.values()) {
            product.imageUrl = B2BUtils.getDefaultProductImageURLByProductId(product.id, webStoreId);
        }

        ConnectApi.PricingInput pricingInput = new ConnectApi.PricingInput();
        pricingInput.pricingLineItems = getPricingLineItemInputs(products.keySet());

        ConnectApi.PricingResult pricingResult;
        String isoCode = 'USD';

        if (!Test.isRunningTest()) {
            if (effectiveAccountId != null || isGuest) {
                pricingResult = ConnectApi.CommerceStorePricing.getProductPrices(B2BUtils.getStoreIdRelatedToCurrentUser(), effectiveAccountId, pricingInput);
                isoCode = pricingResult.currencyIsoCode;
            }
        } else {
            pricingResult = new ConnectApi.PricingResult();
            List<ConnectApi.PricingResultLineItem> pricingLineItemResults = new List<ConnectApi.PricingResultLineItem>();

            for (String productId : products.keySet()) {
                ConnectApi.PricingResultLineItem pricingResultLineItem = new ConnectApi.PricingResultLineItem();
                pricingResultLineItem.productId = productId;
                pricingResultLineItem.listPrice = '100';
                pricingResultLineItem.unitPrice = '200';

                pricingLineItemResults.add(pricingResultLineItem);
            }

            pricingResult.pricingLineItemResults = pricingLineItemResults;
        }
        if (effectiveAccountId == null && !isGuest) {
            AggregateResult[] ars = [SELECT Product2Id, MIN(UnitPrice) price 
                FROM PricebookEntry
                WHERE Product2Id IN :products.keySet()
                GROUP BY Product2Id
            ];
            for (AggregateResult ar : ars) {
                ProductData product = products.get((String)ar.get('Product2Id'));
                Decimal prodPrice = (Decimal)ar.get('price');
                product.price = prodPrice != null & prodPrice > 0
                    ? prodPrice
                    : null;
            }
        } else {
            for (ConnectApi.PricingResultLineItem productPrice : pricingResult.pricingLineItemResults) {
                ProductData product = products.get(productPrice.productId);
                product.price = String.isBlank(productPrice.unitPrice) == false
                    ? Decimal.valueOf(productPrice.unitPrice)
                    : null;
                product.currencyIsoCode = isoCode;
            }
        }
        

        return products.values();
    }

    public static Map<Id, ProductData> getFeaturedProducts(String effectiveAccountId, Boolean isGuest) {
        Map<Id, ProductData> productsData = new Map<Id, ProductData>();

        Id currentStoreId = B2BUtils.getStoreIdRelatedToCurrentUser();
        Set<Id> buyers = new Set<Id>();
        for( WebStoreBuyerGroup storeBuyer : [SELECT BuyerGroupId FROM WebStoreBuyerGroup WHERE WebStoreId =: currentStoreId]) {
            buyers.add(storeBuyer.BuyerGroupId);
        }
        
        String strQuery = 'SELECT BuyerGroupId, PolicyId' +
        ' FROM CommerceEntitlementBuyerGroup' +
        ' WHERE PolicyId IN (SELECT Id FROM CommerceEntitlementPolicy WHERE IsActive = true AND CanViewProduct = true)' +
        ' AND BuyerGroupId IN :buyers';
        if (effectiveAccountId != null || isGuest) {
            strQuery = strQuery + ' AND BuyerGroupId IN (SELECT BuyerGroupId FROM BuyerGroupMember WHERE BuyerId = :effectiveAccountId OR Buyer.Name LIKE \'%Guest Buyer%\')';
        }
        
        List<CommerceEntitlementBuyerGroup> policyForUserBuyerGroup = Database.query(strQuery);

        if (policyForUserBuyerGroup.isEmpty()) {
            return productsData;
        }

        List<Id> entitlementPolicies = new List<Id>();

        for (CommerceEntitlementBuyerGroup policy : policyForUserBuyerGroup) {
            entitlementPolicies.add(policy.PolicyId);
        }

        List<CommerceEntitlementProduct> commerceEntitlementProducts = [
            SELECT ProductId
            FROM CommerceEntitlementProduct
            WHERE ProductId != NULL
            AND Policy.IsActive = TRUE
            AND Policy.CanViewProduct = TRUE
            AND Product.IsActive = TRUE
            AND Product.Featured_Product__c = TRUE
            AND Product.ProductClass != 'Variation'
            AND PolicyId IN :entitlementPolicies
        ];

        Set<Id> setCommerceEntitlementProductIds = new Set<Id>();

        for (CommerceEntitlementProduct product : commerceEntitlementProducts) {
            setCommerceEntitlementProductIds.add(product.ProductId);
        }

        List<ProductCategoryProduct> productCategoryProductIds = [
            SELECT ProductId
            FROM ProductCategoryProduct
            WHERE ProductId IN :setCommerceEntitlementProductIds 
                AND CatalogId IN (SELECT ProductCatalogId FROM WebStoreCatalog WHERE SalesStoreId =: currentStoreId)
        ];

        Set<Id> setProductCategoryProductIds = new Set<Id>();

        for (ProductCategoryProduct productCategory : productCategoryProductIds) {
            setProductCategoryProductIds.add(productCategory.ProductId);
        }

        List<Product2> products = [
            SELECT
                Id,
                Name,
                StockKeepingUnit,
                ProductClass,
                (SELECT PurchaseQuantityRule.Minimum FROM ProductQuantityRules),
                (SELECT Policy.Name FROM CommerceEntitlementProducts WHERE Policy.Name =: QUOTE_ONLY_ENTITLEMENT_POLICY)
            FROM Product2
            WHERE Id IN :setProductCategoryProductIds
            ORDER BY Sequence__c NULLS LAST
            LIMIT :PRODUCT_TO_SHOW
        ];

        if (products.isEmpty()) {
            return productsData;
        }

        for (Product2 product : products) {
            Decimal productMinQty = product.ProductQuantityRules.isEmpty() ? 1 : product.ProductQuantityRules[0].PurchaseQuantityRule.Minimum;
            productsData.put(product.Id, new ProductData(product.Id, product.Name, product.ProductClass, product.StockKeepingUnit, null, null, productMinQty, !product.CommerceEntitlementProducts.isEmpty()));
        }

        return productsData;
    }

    public static List<ConnectApi.PricingLineItemInput> getPricingLineItemInputs(Set<Id> productIds) {
        List<ConnectApi.PricingLineItemInput> pricingLineItemInputs = new List<ConnectApi.PricingLineItemInput>();

        for (String productId : productIds) {
            ConnectApi.PricingLineItemInput pricingLineItemInput = new ConnectApi.PricingLineItemInput();
            pricingLineItemInput.productId = productId;

            pricingLineItemInputs.add(pricingLineItemInput);
        }

        return pricingLineItemInputs;
    }

    public class ProductData {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String productClass;
        @AuraEnabled public String currencyIsoCode;
        @AuraEnabled public String imageUrl;
        @AuraEnabled public String code;
        @AuraEnabled public Decimal price;
        @AuraEnabled public Decimal minQuantity;
        @AuraEnabled public Boolean isParent {
            get {
                return productClass.toLowerCase() == 'variationparent';
            }
            set {
            }
        }
        @AuraEnabled public Boolean isQuoteOnly;

        public ProductData(String id, String name, String productClass, String code, String imageUrl, Decimal price, Decimal minQty, Boolean isQuoteOnly) {
            this.id = id;
            this.name = name;
            this.productClass = productClass;
            this.imageUrl = imageUrl;
            this.price = price;
            this.code = code;
            this.minQuantity = minQty;
            this.isQuoteOnly = isQuoteOnly;
        }
    }
}