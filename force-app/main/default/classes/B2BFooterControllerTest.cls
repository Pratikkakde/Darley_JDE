@IsTest
public with sharing class B2BFooterControllerTest {

    @IsTest
    public static void getMenuItemComponentsTest(){
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initCustomerUserData = factory.initCustomerUserData();
        User commUser = ((User) initCustomerUserData.get(B2BDefaultTestData.COMMUNITY_USER));

        B2BResponse response;
        System.runAs(commUser) {
            Test.startTest();
            response = B2BFooterController.getNavigationMenuItems( 'Default Navigation', 'Default Navigation','Default Navigation');
            Test.stopTest();
        }
        System.assertEquals(true, response.isSuccess, 'response to get navigation menu item is not success');
    }

}