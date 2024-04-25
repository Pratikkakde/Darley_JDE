public without sharing class B2BSearchRecordController {

    @AuraEnabled(Cacheable=true)
    public static B2BResponse getRecordsWithInitialSearchString(String searchString)
    {
        try {
            RecordsWithInitialSearchStringWrapper recordsWrapper = new RecordsWithInitialSearchStringWrapper();
            recordsWrapper.records = getProductData(searchString);
            recordsWrapper.searchString = searchString;

            return new B2BResponse (true, recordsWrapper, '');
        } catch (Exception ex) {
            return new B2BResponse(false, ex.getStackTraceString(), ex.getMessage());
        }
    }

    private static List<B2BQuickOrderProductService.ProductData> getProductData(String searchString) {
        List<B2BQuickOrderProductService.ProductData> productDataList = new List<B2BQuickOrderProductService.ProductData>();
        List<Product2> productRecords = getRecords(searchString);
        if (productRecords == null || productRecords.isEmpty()) {
            return productDataList;
        }

        Set<Id> productIds = new Map<Id, Product2>(productRecords).keySet();
        Map<Id, B2BQuickOrderProductService.QtyRule> productQtyRules = B2BQuickOrderProductService.getProductsQtyRulesById(productIds);

        for (Product2 product : productRecords) {
            B2BQuickOrderProductService.ProductData productData = new B2BQuickOrderProductService.ProductData();
            productData.id = product.Id;
            productData.name = product.Name;
            productData.sku = product.StockKeepingUnit;
            productData.qtyRule = productQtyRules.get(product.Id);

            productDataList.add(productData);
        }

        return productDataList;
    }

    public static List<Product2> getRecords(String searchString) {
        String accountId = getCurrentUserAccountId();
        Set<Id> policyIds = B2BQuickOrderProductService.getListOfEntitlementPoliciesOfAccount(accountId);
        Set<Id> availableProductIds = getAvailableProductIds(policyIds);
        searchString = '%' + searchString + '%';

        List<Product2> productRecords = [
            SELECT
                Id,
                StockKeepingUnit,
                Name
            FROM Product2
            WHERE IsActive = TRUE
                AND Id IN :availableProductIds
                AND (StockKeepingUnit LIKE :searchString
                    OR Name LIKE :searchString)
                AND ProductClass != 'VariationParent'
            LIMIT 200
        ];
        
        return productRecords;
    }

    public class RecordsWithInitialSearchStringWrapper {
        @AuraEnabled public List<B2BQuickOrderProductService.ProductData> records {get;set;}
        @AuraEnabled public String searchString {get;set;}
    }

    private static Set<Id> getAvailableProductIds(Set<Id> policyIds) {
        Set<Id> availableProductIds = new Set<Id>();
        List<CommerceEntitlementProduct> commerceEntitlementProducts = [
            SELECT ProductId
            FROM CommerceEntitlementProduct
            WHERE Policy.IsActive = TRUE
            AND PolicyId IN :policyIds
        ];

        for (CommerceEntitlementProduct item : commerceEntitlementProducts) {
            availableProductIds.add(item.ProductId);
        }

        return B2BQuickOrderProductService.getAvailableProductIdsFromCategories(availableProductIds);
    }

    public static String getCurrentUserAccountId() {
        User oUser = B2BQuickOrderController.getCurrentUser();
        return oUser == null
            ? null
            : oUser.AccountId;
    }
}