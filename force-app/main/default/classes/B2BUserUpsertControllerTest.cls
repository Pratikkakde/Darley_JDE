@IsTest
private class B2BUserUpsertControllerTest {

    @TestSetup
    private static void makeData() {
        new B2BDefaultTestData().initAllData();
    }
        
    @IsTest
    private static void createEditUserTest() {
        User communityUser = [
            SELECT
                Id,
                AccountId 
            FROM User 
            WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME
        ];

        List<PermissionSet> b2bPermSet = [
            SELECT
                Id
            FROM PermissionSet
            WHERE Name = :'B2B_Commerce_User'
        ];

        List<CustomPermission> customPer = [
            SELECT 
                Id,
                DeveloperName
            FROM CustomPermission
            WHERE DeveloperName = 'B2B_User_Manager'
        ];

        SetupEntityAccess sea = new SetupEntityAccess();
        sea.ParentId = b2bPermSet[0].Id;
        sea.SetupEntityId = customPer[0].Id;
        insert sea;

        System.runAs(communityUser) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new B2BDefaultTestData.B2BDefaultTestMock());

            B2BUserUpsertController.UserWrapper newUserData = new B2BUserUpsertController.UserWrapper();
            newUserData.email = 'testUser02@email.com';
            newUserData.title = 'title';
            newUserData.phone = '555-123-23445';
            newUserData.isActive = true;
            newUserData.firstName = 'test02';
            newUserData.lastName = 't02';
            newUserData.username = 'testUser02@email.com';
            newUserData.accountId = communityUser.AccountId;

            B2BResponse responseResult = B2BUserUpsertController.addNewUser(JSON.serialize(newUserData));
            System.assertEquals(true, responseResult.isSuccess);

            responseResult = B2BUserUpsertController.addNewUser(JSON.serialize(newUserData));
            System.assertEquals(false, responseResult.isSuccess);
            System.assertEquals('DUPLICATE_USERNAME', responseResult.responseData);

            Test.stopTest();
            responseResult = B2BUserManagementController.getCommunityMembers();
            System.assertEquals(true, responseResult.isSuccess);

            List<B2BUserManagementController.CommunityMember> listMembers = (List<B2BUserManagementController.CommunityMember>)responseResult.responseData;

            newUserData.userId = listMembers[1].userId;
            newUserData.firstName = 'newtest02';
            newUserData.lastName = 'newt02';

            responseResult = B2BUserUpsertController.editUser(JSON.serialize(newUserData));
            System.assertEquals(true, responseResult.isSuccess);
        }
    }

}