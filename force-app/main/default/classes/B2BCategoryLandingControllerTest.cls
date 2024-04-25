@IsTest
public class B2BCategoryLandingControllerTest {

    @TestSetup
    static void makeData(){
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initCustomerUserData();
        Contact userContact = (Contact) initData.get(B2BDefaultTestData.CUSTOMER_CONTACT);
        userContact.Stripe_Customer_Id__c = 'cus_testCustomer';
        update userContact;
        factory.initProductData();
        ProductCategory pc = [SELECT Id, Featured_Brand__c,CatalogId FROM ProductCategory LIMIT 1];
        pc.Featured_Brand__c = true;
        update pc;

        insert new ProductCategory(
            CatalogId = pc.CatalogId,
            Name = 'Child Test category',
            ParentCategoryId = pc.Id
        );
    }

    @IsTest
    private static void B2BFeaturedBrandsControllerTest() {
        User commUser = [SELECT Id FROM User WHERE Username =: B2BDefaultTestData.COMMUNITY_USER_NAME];
        List<ProductCategory> productCat = [SELECT Id, ParentCategoryId FROM ProductCategory  WHERE ParentCategoryId != null];
        B2BResponse response;
        System.runAs(commUser) {
            Test.startTest();
                response = B2BCategoryLandingController.getChildCategories('000000000000000', productCat.get(0).ParentCategoryId);
            Test.stopTest();
            System.assert(response.isSuccess, 'The response must be success');
        }

        List<B2BCategoryLandingController.CategoryDetail> categoryDetails = (List<B2BCategoryLandingController.CategoryDetail>) response.responseData;
        System.assertEquals(1, categoryDetails.size(), 'It must return 1 CategoryDetail record.');
    }

    @IsTest
    private static void checkCategory() {
        User commUser = [SELECT Id FROM User WHERE Username =: B2BDefaultTestData.COMMUNITY_USER_NAME];
        List<ProductCategory> productCat = [SELECT Id, ParentCategoryId FROM ProductCategory  WHERE ParentCategoryId != null];
        B2BResponse response;
        System.runAs(commUser) {
            Test.startTest();
            response = B2BCategoryLandingController.getCategory('000000000000000', productCat.get(0).Id);
            Test.stopTest();
            System.assert(response.isSuccess, 'The response must be success');
        }

        B2BCategoryLandingController.CategoryDetail categoryDetail = (B2BCategoryLandingController.CategoryDetail) response.responseData;
        System.assertEquals(productCat[0].Id, categoryDetail.categoryId, 'Category Detail record is not correct.');
    }

    @IsTest
    private static void checkFailedCategory() {
        User commUser = [SELECT Id FROM User WHERE Username =: B2BDefaultTestData.COMMUNITY_USER_NAME];
        B2BResponse response;
        System.runAs(commUser) {
            Test.startTest();
            response = B2BCategoryLandingController.getCategory('test', 'test');
            Test.stopTest();
            System.assert(!response.isSuccess, 'The response must not be success');
        }
    }

}