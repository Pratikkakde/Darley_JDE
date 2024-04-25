/**
 * Created by IrinaSakovich on 29/11/2022.
 */

public without sharing class B2BCsvUploadService {
    private class UploadCsvControllerException extends Exception {}
    public class MaxRowsQtyException extends Exception {}

    @TestVisible
    private final static String SOMETHING_WENT_WRONG_DURING_UPLOAD = 'Something went wrong. Please check the CSV file';
    private final static String MAX_ROWS_QTY_ERROR = 'Maximum quantity of rows for upload is ';

    private final static String SKU_NOT_FOUND = System.Label.SKU_Not_Found;
    private final static String SKU_VARIANT_REQUIRED = System.Label.SKU_of_Variation_Parent;
    private final static String UPDATED_TO_MIN = System.Label.Updated_to_min;
    private final static String UPDATED_TO_MAXIMUM = System.Label.Updated_to_max;
    private final static String UPDATED_TO_INCREMENT = System.Label.Updated_to_increment;
    private final static String MAXIMUM_QUANTITY_EXCEEDED = System.Label.Maximum_quantity_exceeded;
    private final static String VARIATION_PARENT = 'VariationParent';
    private final static String ERROR = 'error';
    private final static String WARNING = 'warning';
    private final static String SUCCESS = 'success';
    private final static Integer MAX_ROWS_QTY = 500;

    private static Map<String,Integer> maxQuantityAvailable;
    private static Map<String,Integer> maxQuantityUsed;

    public static List<B2BQuickOrderProductService.ProductData> parseUploadedCSV(String csvString, String accountId) {
        List<B2BQuickOrderProductService.ProductData> parsedProducts = new List<B2BQuickOrderProductService.ProductData>();

        if (String.isBlank(csvString)) {
            throw new UploadCsvControllerException(SOMETHING_WENT_WRONG_DURING_UPLOAD);
        }

        Blob csvBlob = Blob.valueOf(csvString);
        List<B2BQuickOrderProductService.ProductData> parseResult = parseCSVData(csvBlob, accountId);

        if (parseResult == null) {
            throw new UploadCsvControllerException(SOMETHING_WENT_WRONG_DURING_UPLOAD);
        }

        parsedProducts.addAll(parseResult);

        return parsedProducts;
    }

    private static List<B2BQuickOrderProductService.ProductData> parseCSVData(Blob csvFileBody, String accountId) {
        List<B2BQuickOrderProductService.ProductData> productsDataList = new List<B2BQuickOrderProductService.ProductData>();
        List<Map<String, String>> fieldsMap = getFieldsMap(csvFileBody, accountId);
        if (fieldsMap.isEmpty()) {
            return productsDataList;
        }
        List<String> fieldNames = new List<String>(fieldsMap[0].keySet());
        String skuLabel = fieldNames[0];
        String quantityLabel = fieldNames[1];

        Set<String> skus = new Set<String>();
        for (Map<String, String> fieldMap : fieldsMap) {
            skus.add(fieldMap.get(skuLabel));
        }

        Map<String, Product2> skuToProduct = getValidProducts(new List<String>(skus), accountId);
        Map<String, ProductQuantityRule> productSkuToRuleMap = B2BQuickOrderProductService.getProductSkuQuantityRuleMap(skuToProduct.keySet());
        
        maxQuantityAvailable = new Map<String, Integer>();
        maxQuantityUsed = new Map<String, Integer>();
        for ( String skey : productSkuToRuleMap.keySet()) {
            maxQuantityAvailable.put(skey, Integer.valueOf(productSkuToRuleMap.get(skey).PurchaseQuantityRule.Maximum));
            maxQuantityUsed.put(skey, 0);
        }
        for (Map<String, String> fieldMap : fieldsMap) {
            String sku = fieldMap.get(skuLabel);
            B2BQuickOrderProductService.ProductData item = getProductData(sku, fieldMap.get(quantityLabel), skuToProduct.get(sku), productSkuToRuleMap.get(sku));
            productsDataList.add(item);
        }

        return productsDataList;
    }

    private static B2BQuickOrderProductService.ProductData getProductData(String sku, String currentQuantity, Product2 product, ProductQuantityRule rule) {
        B2BQuickOrderProductService.ProductData productData = new B2BQuickOrderProductService.ProductData();
        productData.sku = sku;
        productData.status = SUCCESS;

        if (String.isNotBlank(currentQuantity) && Integer.valueOf(currentQuantity) > 0) {
            productData.quantity = Integer.valueOf(currentQuantity);
        } else {
            productData.quantity = null;
        }

        if (product == null) {
            productData.status = ERROR;
            productData.errorMsg = SKU_NOT_FOUND;
            return productData;
        }

        if (product.ProductClass == VARIATION_PARENT) {
            productData.status = ERROR;
            productData.errorMsg = SKU_VARIANT_REQUIRED;
            return productData;
        }
        if (rule != null) {
            if (maxQuantityAvailable.containsKey(sku) && maxQuantityAvailable.get(sku) < rule.PurchaseQuantityRule.Minimum) {
                productData.status = ERROR;
                productData.errorMsg =  MAXIMUM_QUANTITY_EXCEEDED;
                return productData;
            }
            
            Integer nextQuantity = productData.quantity != null ? maxQuantityUsed.get(sku) + productData.quantity  : Integer.valueOf(maxQuantityUsed.get(sku) + rule.PurchaseQuantityRule.Minimum);
            if (maxQuantityUsed.containsKey(sku) && nextQuantity > rule.PurchaseQuantityRule.Maximum &&  maxQuantityAvailable.get(sku) != rule.PurchaseQuantityRule.Maximum) {
                productData.status = ERROR;
                productData.errorMsg =  MAXIMUM_QUANTITY_EXCEEDED;
                return productData;
            }
        }

        productData.id = product.Id;
        productData.name = product.Name;

        if (rule == null) {
            productData.finalQuantity = productData.quantity == null ? 1 : productData.quantity;
            productData.status = productData.quantity == null ? WARNING : SUCCESS;
            productData.qtyTooltip = productData.quantity == null ? UPDATED_TO_MIN : null;
            return productData;
        }

        if (productData.quantity == null || productData.quantity < rule.PurchaseQuantityRule.Minimum) {
            productData.finalQuantity = Integer.valueOf(rule.PurchaseQuantityRule.Minimum);
            productData.status = WARNING;
            productData.qtyTooltip = UPDATED_TO_MIN;
            maxQuantityAvailable.put(sku,maxQuantityAvailable.get(sku) - productData.finalQuantity);
            maxQuantityUsed.put(sku,maxQuantityUsed.get(sku) + productData.finalQuantity);
        } else if (productData.quantity > rule.PurchaseQuantityRule.Maximum) {
            productData.finalQuantity = Integer.valueOf(rule.PurchaseQuantityRule.Maximum);
            productData.status = WARNING;
            productData.qtyTooltip = UPDATED_TO_MAXIMUM;
            maxQuantityAvailable.put(sku,maxQuantityAvailable.get(sku) - productData.finalQuantity);
            maxQuantityUsed.put(sku,maxQuantityUsed.get(sku) + productData.finalQuantity);
        } else {
            Integer difference = Math.mod(productData.quantity - Integer.valueOf(rule.PurchaseQuantityRule.Minimum), Integer.valueOf(rule.PurchaseQuantityRule.Increment));

            if (difference != 0) {
                productData.finalQuantity = (productData.quantity - difference) + Integer.valueOf(rule.PurchaseQuantityRule.Increment);
                productData.status = WARNING;
                productData.qtyTooltip = UPDATED_TO_INCREMENT;
            } else {
                productData.finalQuantity = productData.quantity;
            }
            
            maxQuantityAvailable.put(sku,maxQuantityAvailable.get(sku) - productData.finalQuantity);
            maxQuantityUsed.put(sku,maxQuantityUsed.get(sku) + productData.finalQuantity);
        }

        return productData;
    }

    private static Map<String, Product2> getValidProducts(List<String> productSkus, String accountId) {
        Map<String, Product2> skuToProduct = new Map<String, Product2>();

        List<Product2> products = [
            SELECT
                Id,
                StockKeepingUnit,
                Name,
                ProductClass,
                IsActive
            FROM Product2
            WHERE StockKeepingUnit IN :productSkus
                AND IsActive = TRUE
        ];

        if (products == null || products.isEmpty()) {
            return skuToProduct;
        }

        Set<Id> productIds = new Set<Id>();
        for (Product2 product : products) {
            productIds.add(product.Id);
        }

        List<ProductAttribute> productAttributes = [
            SELECT
                Id,
                ProductId,
                VariantParentId
            FROM ProductAttribute
            WHERE ProductId IN :productIds
                AND VariantParent.IsActive = FALSE
        ];

        Set<Id> inactiveProductIds = new Set<Id>();
        for (ProductAttribute productAttribute : productAttributes) {
            inactiveProductIds.add(productAttribute.ProductId);
        }

        Set<Id> availableProductIds = B2BQuickOrderProductService.getAvailableProductIds(
            B2BQuickOrderProductService.getListOfEntitlementPoliciesOfAccount(accountId),
            B2BQuickOrderProductService.getEntitlementPoliciesByProductMap(productIds)
        );

        for (Product2 product : products) {
            if (product.StockKeepingUnit != null && !inactiveProductIds.contains(product.Id) && availableProductIds.contains(product.Id)) {
                skuToProduct.put(product.StockKeepingUnit.toLowerCase(), product);
            }
        }

        return skuToProduct;
    }

    private static List<Map<String, String>> getFieldsMap(Blob csvFileBody, String accountId) {
        B2BCsvParser parser = new B2BCsvParser(csvFileBody);
        List<List<String>> rows = parser.getCSVData();

        Integer maxRowsQty = MAX_ROWS_QTY - getExistedItemsQty(accountId);

        if (rows.size() > maxRowsQty+1) {
            throw new MaxRowsQtyException(MAX_ROWS_QTY_ERROR + maxRowsQty);
        }

        List<Map<String, String>> recordMaps = new List<Map<String, String>>();
        List<String> titles = rows[0];
        if (titles == null || titles.size() != 2) {
            throw new UploadCsvControllerException(SOMETHING_WENT_WRONG_DURING_UPLOAD);
        }

        for (Integer i = 1; i < rows.size(); i++) {
            Map<String, String> fieldsMap = new Map<String, String>();
            List<String> lineValues = rows[i];

            for (Integer j = 0; j < titles.size(); j++) {
                String fieldValue = lineValues[j];
                if (String.isBlank(fieldValue)) {
                    fieldValue = null;
                } else if (j == 1 && !fieldValue.isNumeric()) {
                    throw new UploadCsvControllerException(SOMETHING_WENT_WRONG_DURING_UPLOAD);
                }

                String fieldTitle = titles[j];
                fieldsMap.put(fieldTitle, fieldValue);
            }
            recordMaps.add(fieldsMap);
        }
        return recordMaps;
    }

    private static Integer getExistedItemsQty(String accountId) {
        Id webStoreId = B2BUtils.getStoreIdRelatedToCurrentUser();
        if (accountId == null) {
            User user = B2BQuickOrderController.getCurrentUser();
            accountId = user.AccountId;
        }

        String shoppingCartId;
        Integer qtyInCart = 0;
        if (!Test.isRunningTest()) {
            ConnectApi.CartSummary cartSummary = ConnectApi.CommerceCart.getOrCreateActiveCartSummary(
                webStoreId, accountId, 'active'
            );
            shoppingCartId = cartSummary.cartId;
            qtyInCart = cartSummary.uniqueProductCount == null ? 0 : Integer.valueOf(cartSummary.uniqueProductCount);
        } else {
            List<WebCart> cart = [SELECT Id, AccountId, Status, UniqueProductCount FROM WebCart LIMIT 1];
            if (!cart.isEmpty()) {
                shoppingCartId = cart[0]?.Id;
                qtyInCart = cart[0]?.UniqueProductCount == null ? 0 : Integer.valueOf(cart[0]?.UniqueProductCount);
            }
        }

        return qtyInCart;
    }
}