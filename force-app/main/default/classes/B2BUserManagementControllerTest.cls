@IsTest
private class B2BUserManagementControllerTest {

    @TestSetup
    private static void makeData() {
        new B2BDefaultTestData().initAllData();
    }

    @IsTest
    private static void getCommunityMembersTest() {
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

            Map<String, Object> mapSettings = B2BUserManagementController.getCommerceSettings();
            
            String userProfileName = (String)mapSettings.get('Default_User_Profile_Name');
            String userPermissionSetName = (String)mapSettings.get('Default_User_PermissionSet_Name');

            B2BUserManagementController.CommunityMember newUserData = new B2BUserManagementController.CommunityMember();

            B2BResponse responseResult = B2BUserManagementController.getCommunityMembers();
            System.assertEquals(true, responseResult.isSuccess);

            List<B2BUserManagementController.CommunityMember> listMembers = (List<B2BUserManagementController.CommunityMember>)responseResult.responseData;
            System.assertEquals(1, listMembers.size());

            for (B2BUserManagementController.CommunityMember recItem : listMembers) {
                newUserData = recItem;
            }

            responseResult = B2BUserManagementController.activateUser(newUserData.userId, true);
            System.assertEquals(true, responseResult.isSuccess);

            responseResult = B2BUserManagementController.activateUser(null, true);
            System.assertEquals(false, responseResult.isSuccess);

            responseResult = B2BUserManagementController.resetUserPassword(null);
            System.assertEquals(false, responseResult.isSuccess);

            Test.stopTest();
        }
    }

    @IsTest
    private static void getDelegatedPermissionsTest() {
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];

        System.runAs(communityUser) {
            Test.startTest();
            B2BResponse responseResult = B2BUserManagementController.getDelegatedPermissions(communityUser.Id);

            System.assertEquals(true, responseResult.isSuccess);
            Test.stopTest();
        }
    }

    @IsTest
    private static void setPermissionSetAssignmentTest() {
        User communityUser = [
            SELECT
                Id,
                AccountId 
            FROM User 
            WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME
        ];

        List<PermissionSet> b2bPermSet = [
            SELECT
                Id,
                Name
            FROM PermissionSet
            WHERE Name IN ('B2B_Commerce_User', 'B2B_Commerce_Super_User')
        ];

        Map<String, Id> mapLabelToId = new Map<String, Id>();
        for (PermissionSet rec : b2bPermSet) {
            mapLabelToId.put(rec.Name, rec.Id);
        }

        List<CustomPermission> customPer = [
            SELECT 
                Id,
                DeveloperName
            FROM CustomPermission
            WHERE DeveloperName = 'B2B_User_Manager'
        ];

        SetupEntityAccess sea = new SetupEntityAccess();
        sea.ParentId = mapLabelToId.get('B2B_Commerce_User');
        sea.SetupEntityId = customPer[0].Id;
        insert sea;

        System.runAs(communityUser) {
            Test.startTest();
            B2BUserManagementController.CommunityMember newUserData = new B2BUserManagementController.CommunityMember();

            B2BResponse responseResult = B2BUserManagementController.getCommunityMembers();
            System.assertEquals(true, responseResult.isSuccess);

            List<B2BUserManagementController.CommunityMember> listMembers = (List<B2BUserManagementController.CommunityMember>)responseResult.responseData;
            System.assertEquals(1, listMembers.size());

            for (B2BUserManagementController.CommunityMember recItem : listMembers) {
                newUserData = recItem;
            }

            responseResult = B2BUserManagementController.editPermissionSets(new List<String>{mapLabelToId.get('B2B_Commerce_Super_User')}, new List<String>{mapLabelToId.get('B2B_Commerce_User')}, communityUser.Id);
            System.assertEquals(true, responseResult.isSuccess);
            Test.stopTest();
        }
    } 
}