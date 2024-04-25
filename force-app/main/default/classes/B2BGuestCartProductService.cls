/**
 * Created by IrinaSakovich on 27.07.22.
 */

public without sharing class B2BGuestCartProductService {
    private static final List<String> EXCLUDE_FIELD_TYPES = new List<String>{'BOOLEAN','ANYTYPE','TEXTAREA','LOCATION'};
    private static final List<String> DATE_TIME_TYPES = new List<String>{'DATE','DATETIME','TIME'};

    public static Map<Id, ConnectApi.ProductOverview> getProducts(Id webStoreId, String effectiveAccountId, List<Id> productIds, String fieldSetName, Boolean includeDateTimeFields) {
        ConnectApi.ProductOverviewCollection productsData = (Test.isRunningTest())
            ? mockProducts(productIds, fieldSetName)
            : ConnectApi.CommerceCatalog.getProducts(
                webStoreId,
                effectiveAccountId,
                productIds,
                null,
                getFieldsFromProductFieldSet(fieldSetName, includeDateTimeFields),
                false,
                false
            );

        return getProductIdToProductOverviewMap(productsData);
    }

    public static Map<Id, ProductQuantityRule> getQtyRulesMap(List<Id> productIds) {
        List<ProductQuantityRule> qtyRules = getQtyRules(productIds);

        if (qtyRules == null) {
            return null;
        }

        Map<Id, ProductQuantityRule> qtyRulesMap = new Map<Id, ProductQuantityRule>();
        for (ProductQuantityRule qtyRule : qtyRules) {
            qtyRulesMap.put(qtyRule.ProductId, qtyRule);
        }

        return qtyRulesMap;
    }

    public static List<ProductQuantityRule> getQtyRules(List<Id> productIds) {
        List<ProductQuantityRule> qtyRules = [
            SELECT
                Product.Name,
                ProductId,
                PurchaseQuantityRuleId,
                PurchaseQuantityRule.Increment,
                PurchaseQuantityRule.Minimum,
                PurchaseQuantityRule.Maximum
            FROM ProductQuantityRule
            WHERE ProductId IN :productIds
        ];

        return qtyRules.isEmpty() ? null : qtyRules;
    }

    public static Map<Id, PricebookEntry> getProductPricesMap(List<Id> productIds, String effectiveAccountId, Id webStoreId) {
        Map<Id, PricebookEntry> prices = getProductToPriceBookEntryMap(getAssignedPricebookEntries(productIds, effectiveAccountId, webStoreId));

        List<Id> productsWithoutPriceIds = new List<Id>();
        if (prices != null) {
            for (Id productId : productIds) {
                if (!prices.containsKey(productId)) {
                    productsWithoutPriceIds.add(productId);
                }
            }
        }

        if (productsWithoutPriceIds.isEmpty()) {
            return prices;
        }

        prices.putAll(getProductToPriceBookEntryMap(getStorePricebookEntries(productIds, webStoreId)));

        return prices;
    }

    public static List<Id> getProductIdsByCartItems(List<CartItem> cartItems) {
        if (cartItems == null) return null;

        List<Id> ids = new List<Id>();
        for (CartItem item : cartItems) {
            if (ids.contains(item.Product2Id)) continue;

            ids.add(item.Product2Id);
        }

        return ids;
    }

    private static Set<Id> getPriceBookIdsFromBuyerGroupPriceBooks(List<BuyerGroupPricebook> priceBooks) {
        Set<Id> priceBookIds = new Set<Id>();

        if (priceBooks == null || priceBooks.isEmpty()) {
            return priceBookIds;
        }

        for (BuyerGroupPricebook priceBook : priceBooks) {
            priceBookIds.add(priceBook.Pricebook2Id);
        }

        return priceBookIds;
    }

    private static List<PricebookEntry> getAssignedPricebookEntries(List<Id> productIds, String effectiveAccountId, String webStoreId) {
        List<BuyerGroupPricebook> priceBooks = [
            SELECT Pricebook2Id
            FROM BuyerGroupPricebook
            WHERE BuyerGroupId IN (
                    SELECT
                        BuyerGroupId
                    FROM BuyerGroupMember
                    WHERE BuyerId = :effectiveAccountId
                        OR Buyer.Name LIKE '%Guest Buyer%'
                )
                AND IsActive = TRUE
        ];

        Set<Id> buyerGroupPriceBooksAndStorePriceBooks = getPriceBookIdsFromBuyerGroupPriceBooks(priceBooks);

        List<WebStorePricebook> webStorePriceBooks = [
            SELECT
                IsActive,
                Name,
                Pricebook2Id,
                WebStoreId
            FROM WebStorePricebook
            WHERE IsActive = TRUE
                AND WebStoreId = :webStoreId
        ];

        if (webStorePriceBooks.isEmpty() == false) {
            for (WebStorePricebook pricebook : webStorePriceBooks) {
                buyerGroupPriceBooksAndStorePriceBooks.add(pricebook.Pricebook2Id);
            }
        }

        List<PricebookEntry> prices = [
            SELECT
                Id,
                UnitPrice,
                Product2Id,
                Product2.Name,
                Product2.StockKeepingUnit
            FROM PricebookEntry
            WHERE Product2Id IN :productIds
                AND Pricebook2Id IN :buyerGroupPriceBooksAndStorePriceBooks
                AND IsActive = TRUE
            ORDER BY UnitPrice
        ];

        return prices.isEmpty() ? null : prices;
    }

    private static List<PricebookEntry> getStorePricebookEntries(List<Id> productIds, Id webStoreId) {
        List<PricebookEntry> standardPrice = [
            SELECT
                Id,
                UnitPrice,
                Product2Id,
                Product2.Name
            FROM PricebookEntry
            WHERE Product2Id IN :productIds
                AND Pricebook2Id IN (
                    SELECT Pricebook2Id
                    FROM WebStorePricebook
                    WHERE WebStoreId = :webStoreId
                        AND IsActive = TRUE
                )
                AND IsActive = TRUE
            ORDER BY UnitPrice
        ];

        return standardPrice.isEmpty() ? null : standardPrice;
    }

    public static Map<Id, PricebookEntry> getProductToPriceBookEntryMap(List<PricebookEntry> pricebookEntries) {
        Map<Id, PricebookEntry> productToPriceBookEntryMap = new Map<Id, PricebookEntry>();

        if (pricebookEntries == null) {
            return productToPriceBookEntryMap;
        }

        for (PricebookEntry pricebookEntry : pricebookEntries) {
            if (!productToPriceBookEntryMap.containsKey(pricebookEntry.Product2Id)) {
                productToPriceBookEntryMap.put(pricebookEntry.Product2Id, pricebookEntry);
            }
        }

        return productToPriceBookEntryMap;
    }

    private static Map<Id, ConnectApi.ProductOverview> getProductIdToProductOverviewMap(ConnectApi.ProductOverviewCollection  productsData) {
        Map<Id, ConnectApi.ProductOverview> productsDataMap = new Map<Id, ConnectApi.ProductOverview>();

        if (productsData.products == null || ((List<ConnectApi.ProductOverview>)productsData.products).isEmpty()) {
            return null;
        }

        for (ConnectApi.ProductOverview productOverview : (List<ConnectApi.ProductOverview>)productsData.products) {
            if ((Boolean)productOverview.success) {
                productsDataMap.put(Id.valueOf((String)productOverview.id), productOverview);
            } else {
                System.debug(productOverview.error);
            }
        }

        return productsDataMap;
    }

    public static List<String> getFieldsFromProductFieldSet(String fieldSetName, Boolean includeDateTime) {
        List<Schema.FieldSetMember> fields = getFieldsFromFieldset('Product2', fieldSetName);
        if (fields == null) {
            return null;
        }

        List<String> includeFields = new List<String>();
        for (Schema.FieldSetMember field: fields) {
            Schema.DisplayType fieldType = field.getType();

            if (EXCLUDE_FIELD_TYPES.contains(String.valueOf(fieldType))
                || DATE_TIME_TYPES.contains(String.valueOf(fieldType)) && !includeDateTime
            ) {
                continue;
            }

            includeFields.add(field.getFieldPath());
        }

        return includeFields;
    }

    public static List<Schema.FieldSetMember> getFieldsFromFieldset(String typeName, String fieldSetName) {
        Schema.FieldSet fieldSet = Schema.getGlobalDescribe().get(typeName).getDescribe().fieldSets.getMap().get(fieldSetName);
        if (fieldSet == null) {
            return null;
        }
        List<Schema.FieldSetMember> fields = fieldSet.getFields();

        return fields.isEmpty() ? null : fields;
    }

    private static Map<String, Schema.DisplayType> getFieldsToFormatFromFieldSet(String fieldSetName) {
        Map<String, Schema.DisplayType> fieldsToFormat = new Map<String, Schema.DisplayType>();
        List<Schema.FieldSetMember> fields = getFieldsFromFieldset('Product2', fieldSetName);

        if (fields == null) {
            return Test.isRunningTest()
                ? mockFieldsToFormat()
                : fieldsToFormat;
        }

        for (Schema.FieldSetMember field: fields) {
            Schema.DisplayType fieldType = field.getType();

            if (DATE_TIME_TYPES.contains(String.valueOf(fieldType))) {
                fieldsToFormat.put(field.getFieldPath(), fieldType);
            }
        }

        return Test.isRunningTest()
            ? mockFieldsToFormat()
            : fieldsToFormat;
    }

    public static Map<String,String> formatDateTimeFields(Map<String,String> fields, String fieldSetName) {
        if (fields == null) {
            return null;
        }

        Map<String, Schema.DisplayType> fieldsToFormat = getFieldsToFormatFromFieldSet(fieldSetName);
        if (fieldsToFormat.isEmpty()) {
            return fields;
        }

        Map<String, String> resultMap = new Map<String, String>();

        for (String fieldName : fields.keySet()) {
            String field = fields.get(fieldName);

            if (field != null && fieldsToFormat.containsKey(fieldName)) {
                Schema.DisplayType fieldType = fieldsToFormat.get(fieldName);
                if (fieldType == Schema.DisplayType.DATETIME) {
                    field = formatDateString(field) + ' ' + field.substring(11, 19);
                } else if(fieldType == Schema.DisplayType.DATE) {
                    field = formatDateString(field);
                } else if(fieldType == Schema.DisplayType.TIME) {
                    field = field.substring(0, 8);
                }
            }

            resultMap.put(fieldName, field);
        }

        return resultMap;
    }

    private static String formatDateString(String dateStr) {
        return Datetime.newInstance(Date.valueOf(dateStr.substring(0, 10)), Time.newInstance(0, 0, 0, 0)).format('MM/dd/yyyy');
    }

    @TestVisible
    private static ConnectApi.ProductOverviewCollection mockProducts(List<Id> productIds, String fieldSetName) {
        List<Product2> products = [
            SELECT
                Id,
                Name,
                StockKeepingUnit
            FROM Product2
            WHERE Id IN :productIds
        ];

        List<String> fields = getFieldsFromProductFieldSet(fieldSetName, true);
        ConnectApi.ProductOverviewCollection collection = new ConnectApi.ProductOverviewCollection();
        collection.total = productIds.size();
        collection.products = new List<ConnectApi.ProductOverview>();

        for (Product2 product : products) {
            ConnectApi.ProductOverview productOverview = new ConnectApi.ProductOverview();
            productOverview.id = product.Id;
            productOverview.sku = product.StockKeepingUnit;
            productOverview.success = true;

            productOverview.fields = new Map<String, String>{
                'Name' => 'TestName',
                'CreatedDate' => '2022-01-24T10:03:40Z',
                'CreatedById' => 'TestId',
                'LastModifiedDate' => '2022-01-24T10:03:40Z'
            };
            productOverview.defaultImage = new ConnectApi.ProductMedia();

            productOverview.prices = new ConnectApi.PricingResultLineItem();
            productOverview.prices.UnitPrice = '100';
            productOverview.prices.ListPrice = '100';

            collection.products.add(productOverview);
        }

        return collection;
    }

    @TestVisible
    private static Map<String, Schema.DisplayType> mockFieldsToFormat() {
        return new Map<String, Schema.DisplayType>{
            'CreatedDate' => Schema.DisplayType.DATETIME,
            'LastModifiedDate' => Schema.DisplayType.DATETIME,
            'TestTime' => Schema.DisplayType.TIME,
            'TestDate' => Schema.DisplayType.DATE
        };
    }
}