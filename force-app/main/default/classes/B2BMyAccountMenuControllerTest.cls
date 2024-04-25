@IsTest
public without sharing class B2BMyAccountMenuControllerTest {

    @IsTest
    public static void getMyAccountMenuItemTest() {
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initCustomerUserData = factory.initCustomerUserData();
        User commUser = ((User) initCustomerUserData.get(B2BDefaultTestData.COMMUNITY_USER));

        B2BResponse response;
        System.runAs(commUser) {
            Test.startTest();
            response = B2BMyAccountMenuController.getMyAccountMenuItem('Default Navigation');
            Test.stopTest();
        }
        System.assertEquals(true, response.isSuccess, 'response to get my account menu is success');
    }
}