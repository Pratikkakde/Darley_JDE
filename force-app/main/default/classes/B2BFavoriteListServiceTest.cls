@IsTest
private class B2BFavoriteListServiceTest {

    @TestSetup
    private static void makeData() {
        new B2BDefaultTestData().initAllData();
    }

    @IsTest
    static void upsertFavoriteListTest() {
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];

        Test.startTest();
        System.runAs(communityUser) {
            Id newFLId = B2BFavoriteListService.upsertFavoriteList(null, 'favoriteListName', communityUser.AccountId);
            System.assertEquals(true, String.isNotBlank(newFLId));

            newFLId = B2BFavoriteListService.upsertFavoriteList(newFLId, 'New favoriteListName', null);
            System.assertEquals(true, String.isNotBlank(newFLId));
        }
        Test.stopTest();
    }

    @IsTest
    static void getFavoriteListTest() {
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];

        Test.startTest();
        System.runAs(communityUser) {
            Id newFLId = B2BFavoriteListService.upsertFavoriteList(null, 'favoriteListName', communityUser.AccountId);
            System.assertEquals(true, String.isNotBlank(newFLId));

            List<B2BFavoriteListService.FavoriteList> arrFL = B2BFavoriteListService.getFavoriteList(communityUser.AccountId);
            System.assertEquals(1, arrFL.size());
        }
        Test.stopTest();
    }
}