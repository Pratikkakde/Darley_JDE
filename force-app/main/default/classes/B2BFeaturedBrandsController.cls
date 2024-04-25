public without sharing class B2BFeaturedBrandsController {
    private static final String DEFAULT_IMAGE = '/img/b2b/default-product-image.svg';
    
    @AuraEnabled
    public static B2BResponse getFeaturedBrands(String effectiveAccountId) {
        try {
            effectiveAccountId = effectiveAccountId == '000000000000000' ? null : effectiveAccountId;
            List<CategoryData> categoryDatas = new List<CategoryData>();
            Id webStoreId = B2BUtils.getStoreIdRelatedToCurrentUser();
            for (ProductCategory category  : [SELECT Id, Name FROM  ProductCategory
                                                    WHERE Featured_Brand__c = true AND CatalogId IN (SELECT ProductCatalogId FROM WebStoreCatalog WHERE SalesStoreId =: webStoreId)
                                                    ORDER BY Featured_Brand_Sort_Order__c ASC NULLS LAST]) {
                ConnectApi.ProductCategoryDetail categoryDetail;
                CategoryData categoryData = new CategoryData();
                categoryData.categoryName = category.Name;
                categoryData.categoryId = category.Id;
                if(!Test.isRunningTest()){
                    categoryDetail = webStoreId != null ? ConnectApi.CommerceCatalog.getProductCategory( webStoreId, category.Id, effectiveAccountId, null, true, null, false) :  new ConnectApi.ProductCategoryDetail();
                    categoryData.image = categoryDetail.tileImage != null ? (categoryDetail.tileImage.url) : (DEFAULT_IMAGE);
                }
                categoryDatas.add(categoryData);

            }
            return new B2BResponse(true, categoryDatas, '');
        } catch (Exception ex) {
            return new B2BResponse(false, ex.getStackTraceString(), ex.getMessage());
        }
    }

    public class CategoryData{
        @AuraEnabled public String categoryName{get; set;}
        @AuraEnabled public String categoryId{get; set;}
        @AuraEnabled public String image{get; set;}

    }
}