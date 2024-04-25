@IsTest
private class B2BFeaturedBrandsControllerTest {
    
    @IsTest
    private static void B2BFeaturedBrandsControllerTest() {
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initCustomerUserData();
        Contact userContact = (Contact) initData.get(B2BDefaultTestData.CUSTOMER_CONTACT);
        userContact.Stripe_Customer_Id__c = 'cus_testCustomer';
        update userContact;
        factory.initProductData();
        ProductCategory pc = [SELECT Id, Featured_Brand__c FROM ProductCategory LIMIT 1];
        pc.Featured_Brand__c = true;
        update pc;

        User commUser = ((User) initData.get(B2BDefaultTestData.COMMUNITY_USER));

        B2BResponse response;

        System.runAs(commUser) {
            Test.startTest();
                response = B2BFeaturedBrandsController.getFeaturedBrands(null);
            Test.stopTest();
            System.assert(response.isSuccess,'The response must be success');
        }
    }
}