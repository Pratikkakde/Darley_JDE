public without sharing class B2BFavoriteListDetailController {

    private static final String SOMETHING_WENT_WRONG_MESSAGE = System.Label.Something_Went_Wrong_Please_contact_your_System_Administrator;

    @AuraEnabled
    public static B2BResponse getFavoriteListDetail(Id favoriteListId, Id effectiveAccountId) {
        try {
            List<FavoriteListItem> favoriteListItems = new List<FavoriteListItem>();
            List<Id> listProductIds = new List<Id>();
            for (Favorite_List_Item__c recFLI : [
                SELECT Id, Name, ProductId__c, ProductId__r.Name, CreatedDate
                FROM Favorite_List_Item__c
                WHERE Favorite_List_Id__c = :favoriteListId
            ]) {
                FavoriteListItem newRec = new FavoriteListItem();
                newRec.id = recFLI.Id;
                newRec.productId = recFLI.ProductId__c;
                newRec.productName = recFLI.ProductId__r.Name;
                newRec.createdDate = recFLI.CreatedDate;

                favoriteListItems.add(newRec);
                listProductIds.add(recFLI.ProductId__c);
            }

            Map<Id, Decimal> productIdToMinQuantity = new Map<Id, Decimal>();
            for (Product2 product : [
                SELECT
                    Id,
                    (
                        SELECT PurchaseQuantityRule.Minimum
                        FROM ProductQuantityRules
                    )
                FROM Product2
                WHERE Id IN :listProductIds
            ]) {
                Decimal minQuantity = product.ProductQuantityRules.isEmpty() ? 1 : product.ProductQuantityRules[0].PurchaseQuantityRule.Minimum;

                productIdToMinQuantity.put(product.Id, minQuantity);
            }

            List<Id> listActiveProducts = getAvailableProducts(listProductIds, effectiveAccountId);
            Set<Id> setPriceAvailableProducts = getPriceAvailableProducts(listProductIds, effectiveAccountId);
            Set<Id> quoteOnlyProducts = getQuoteOnlyProducts(listProductIds);

            for (FavoriteListItem itemRec : favoriteListItems) {
                itemRec.minQuantity = productIdToMinQuantity.get(itemRec.productId);
                itemRec.isProductAvailable = listActiveProducts.contains(itemRec.productId);
                itemRec.isPriceAvailable = setPriceAvailableProducts.contains(itemRec.productId);
                itemRec.isQuoteOnly = quoteOnlyProducts.contains(itemRec.productId);
            }

            return new B2BResponse(true, favoriteListItems, 'Success');
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage() + ' ' + e.getLineNumber(), SOMETHING_WENT_WRONG_MESSAGE);
        }
    }

    private static List<Id> getAvailableProducts(List<Id> listProductIds, Id effectiveAccountId) {
        List<Id> listActiveProducts = new List<Id>();

        Id currentStoreId = B2BUtils.getStoreIdRelatedToCurrentUser();
        Set<Id> buyers = new Set<Id>();
        for( WebStoreBuyerGroup storeBuyer : [SELECT BuyerGroupId FROM WebStoreBuyerGroup WHERE WebStoreId =: currentStoreId]) {
            buyers.add(storeBuyer.BuyerGroupId);
        }

        List<CommerceEntitlementBuyerGroup> policyForUserBuyerGroup = [
            SELECT BuyerGroupId, PolicyId
            FROM CommerceEntitlementBuyerGroup 
            WHERE BuyerGroupId IN 
                (
                    SELECT BuyerGroupId
                    FROM BuyerGroupMember 
                    WHERE BuyerId = :effectiveAccountId AND BuyerGroupId IN :buyers
                )
        ];

        if (policyForUserBuyerGroup.isEmpty()) {
            return listActiveProducts;
        }

        List<Id> entitlementPolicies = new List<Id>();

        for (CommerceEntitlementBuyerGroup policy : policyForUserBuyerGroup) {
            entitlementPolicies.add(policy.PolicyId);
        }

        List<CommerceEntitlementProduct> commerceEntitlementProducts = [
            SELECT ProductId, Product.ProductClass
            FROM CommerceEntitlementProduct
            WHERE ProductId IN :listProductIds
                AND Policy.IsActive = TRUE
                AND Policy.CanViewProduct = TRUE
                AND Product.IsActive = TRUE
                AND PolicyId IN :entitlementPolicies
        ];

        List<Id> simpleProductIds = new List<Id>();
        List<Id> variantProductIds = new List<Id>();

        for (CommerceEntitlementProduct record : commerceEntitlementProducts) {
            if (record.Product.ProductClass == 'Variation') {
                variantProductIds.add(record.ProductId);
            } else {
                simpleProductIds.add(record.ProductId);
            }
        }

        listActiveProducts = getProductCategory(simpleProductIds);

        if (variantProductIds.size() == 0) {
            return listActiveProducts;
        }
        
        Map<Id, Id> productIdToParentProductIdMap = new Map<Id, Id>();
        for (ProductAttribute record : [
            SELECT Id,
                ProductId,
                VariantParentId
            FROM ProductAttribute
            WHERE ProductId IN :variantProductIds
        ]) {
            productIdToParentProductIdMap.put(record.ProductId, record.VariantParentId);
        }

        Map<Id, Product2> mapIdToProduct = new Map<Id, Product2>([
            SELECT Id, Name, Type, ProductClass,
                (
                    SELECT Id 
                    FROM ProductCategoryProducts
                ),
                (
                    SELECT Id 
                    FROM CommerceEntitlementProducts 
                    WHERE Policy.IsActive = TRUE
                        AND Policy.CanViewProduct = TRUE
                )
            FROM Product2
            WHERE Id IN :productIdToParentProductIdMap.values()
                AND IsActive = TRUE
        ]);

        for (Id varProdId : productIdToParentProductIdMap.keySet()) {
            Id ParentProductId = productIdToParentProductIdMap.get(varProdId);
            if (mapIdToProduct.containsKey(ParentProductId)) {
                Product2 parentProd = mapIdToProduct.get(ParentProductId);
                if (parentProd.ProductCategoryProducts.size() > 0 && parentProd.CommerceEntitlementProducts.size() > 0) {
                    listActiveProducts.add(varProdId);
                }
            }
        }
        
        return listActiveProducts;
    }

    private static List<Id> getProductCategory(List<Id> listProductIds) {
        List<ProductCategoryProduct> productCategoryProductIds = [
            SELECT
                ProductId,
                Product.IsActive
            FROM ProductCategoryProduct
            WHERE ProductId IN :listProductIds
        ];

        Set<Id> setProductCategoryProductIds = new Set<Id>();

        for (ProductCategoryProduct productCategory : productCategoryProductIds) {
            if (productCategory.Product.IsActive) {
                setProductCategoryProductIds.add(productCategory.ProductId);
            }
        }

        return new List<Id>(setProductCategoryProductIds);
    }

    private static Set<Id> getPriceAvailableProducts(List<Id> listProductIds, Id effectiveAccountId) {
        Set<Id> activeProductIds = new Set<Id>();

        Set<Id> setAllActivePricebooks = new Set<Id>();

        for (BuyerGroupPricebook rec : [
            SELECT BuyerGroupId, Pricebook2Id
            FROM BuyerGroupPricebook 
            WHERE BuyerGroupId IN 
                (
                    SELECT BuyerGroupId
                    FROM BuyerGroupMember 
                    WHERE BuyerId = :effectiveAccountId
                )
                AND IsActive = TRUE
        ]) {
            setAllActivePricebooks.add(rec.Pricebook2Id);
        }

        String webStoreId = B2BUtils.getStoreIdRelatedToCurrentUser();
        for (WebStorePricebook rec : [
            SELECT WebStoreId, Pricebook2Id
            FROM WebStorePricebook 
            WHERE WebStoreId = :webStoreId
                AND IsActive = TRUE
        ]) {
            setAllActivePricebooks.add(rec.Pricebook2Id);
        }

        for (PricebookEntry rec : [
            SELECT Pricebook2Id, Product2Id
            FROM PricebookEntry
            WHERE Product2Id IN :listProductIds
                AND Pricebook2Id IN :setAllActivePricebooks
                AND IsActive = TRUE
                AND Pricebook2.IsActive = TRUE
        ]) {
            activeProductIds.add(rec.Product2Id);
        }

        return activeProductIds;
    }

    private static Set<Id> getQuoteOnlyProducts ( List<Id> listProductIds ) {
        Set<Id> quoteOnlyProducts = new Set<Id>();
        if (!listProductIds.isEmpty()) {
            for (CommerceEntitlementProduct policyProduct : [SELECT ProductId 
                FROM CommerceEntitlementProduct 
                WHERE Policy.Name = 'Quote Only' AND ProductId IN :listProductIds ]) 
            {
                quoteOnlyProducts.add(policyProduct.ProductId);
            }
        }
        
        return quoteOnlyProducts;
    }

    @AuraEnabled
    public static B2BResponse deleteAllFavoriteListItems(Id favoriteListId) {
        try {
            List<Favorite_List_Item__c> favoriteListItems = [
                SELECT Id
                FROM Favorite_List_Item__c
                WHERE Favorite_List_Id__c = :favoriteListId
            ];
            
            delete favoriteListItems;

            return new B2BResponse(true, 'Success');
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage() + ' ' + e.getLineNumber(), SOMETHING_WENT_WRONG_MESSAGE);
        }
    }
    
    @AuraEnabled
    public static B2BResponse deleteFavoriteListItems(List<Id> favoriteListItemIds) {
        try {
            List<Favorite_List_Item__c> listRecords = new List<Favorite_List_Item__c>();
            for (Id recId : favoriteListItemIds) {
                listRecords.add(new Favorite_List_Item__c(Id = recId));
            }
            delete listRecords;

            return new B2BResponse(true, 'Success');
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage() + ' ' + e.getLineNumber(), SOMETHING_WENT_WRONG_MESSAGE);
        }
    }

    public class FavoriteListItem {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String productId { get; set; }
        @AuraEnabled public String productName { get; set; }
        @AuraEnabled public Decimal minQuantity { get; set; }
        @AuraEnabled public DateTime createdDate { get; set; }
        @AuraEnabled public Boolean isProductAvailable { get; set; }
        @AuraEnabled public Boolean isPriceAvailable { get; set; }
        @AuraEnabled public Boolean isQuoteOnly { get; set; }
    }
}