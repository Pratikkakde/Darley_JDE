public without sharing class B2BCategoryLandingController {
    private static final String DEFAULT_IMAGE = '/img/b2b/default-product-image.svg';

    @AuraEnabled
    public static B2BResponse getCategory(String effectiveAccountId, String categoryId) {
        try {
            effectiveAccountId = getEffectiveAccountId(effectiveAccountId);
            Id webStoreId = B2BUtils.getStoreIdRelatedToCurrentUser();

            List<ProductCategory> productCategories = [
                SELECT Id, Name, Description, Additional_Description__c, Learn_More__c
                FROM ProductCategory
                WHERE Id = :categoryId
            ];

            CategoryDetail categoryDetail = productCategories.isEmpty() ? null : new CategoryDetail(productCategories[0], effectiveAccountId, webStoreId);
            return new B2BResponse(true, categoryDetail, '');
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage(), Label.Something_Went_Wrong_Please_contact_your_System_Administrator);
        }
    }

    @AuraEnabled
    public static B2BResponse getChildCategories(String effectiveAccountId, String categoryId) {
        try {
            effectiveAccountId = getEffectiveAccountId(effectiveAccountId);
            Id webStoreId = B2BUtils.getStoreIdRelatedToCurrentUser();

            List<CategoryDetail> categoryDetails = new List<CategoryDetail>();
            for (ProductCategory category : [
                SELECT Id, Name, Description, Additional_Description__c, Learn_More__c
                FROM ProductCategory
                WHERE ParentCategoryId = :categoryId
                ORDER BY SortOrder ASC NULLS LAST
            ]) {
                categoryDetails.add(new CategoryDetail(category, effectiveAccountId, webStoreId));
            }
            return new B2BResponse(true, categoryDetails, '');

        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage(), Label.Something_Went_Wrong_Please_contact_your_System_Administrator);
        }
    }

    private static Id getEffectiveAccountId(String effectiveAccountId) {
        return effectiveAccountId == '000000000000000' ? null : effectiveAccountId;
    }

    public class CategoryDetail {
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String image { get; set; }
        @AuraEnabled public String categoryId { get; set; }
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public String additionalDescription { get; set; }
        @AuraEnabled public String learnMoreLink { get; set; }

        public CategoryDetail(ProductCategory category, String effectiveAccountId, Id webStoreId) {
            name = category.Name;
            categoryId = category.Id;
            description = category.Description;
            additionalDescription = category.Additional_Description__c;
            learnMoreLink = category.Learn_More__c;

            ConnectApi.ProductCategoryDetail productCategoryDetail;
            if(!Test.isRunningTest()){
                productCategoryDetail = webStoreId != null ? ConnectApi.CommerceCatalog.getProductCategory( webStoreId, category.Id, effectiveAccountId, null, false, null, false) :  new ConnectApi.ProductCategoryDetail();
                image = productCategoryDetail.tileImage != null ? (productCategoryDetail.tileImage.url) : (DEFAULT_IMAGE);
            }
        }
    }
}