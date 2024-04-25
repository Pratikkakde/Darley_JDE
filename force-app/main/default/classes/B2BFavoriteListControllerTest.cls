@IsTest
private class B2BFavoriteListControllerTest {

    @TestSetup
    private static void makeData() {
        new B2BDefaultTestData().initAllData();
    }

    @IsTest
    static void upsertFavoriteListTest() {
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];

        Test.startTest();
        System.runAs(communityUser) {
            B2BResponse result = B2BFavoriteListController.upsertFavoriteList(null, '', communityUser.AccountId);
            System.assertEquals(false, result.isSuccess);
            System.assertEquals('FAVORITE_NAME_IS_EMPTY', result.responseMessage);

            result = B2BFavoriteListController.upsertFavoriteList(null, 'favoriteListName', null);
            System.assertEquals(false, result.isSuccess);
            System.assertEquals('ACCOUNT_IS_EMPTY', result.responseMessage);

            result = B2BFavoriteListController.upsertFavoriteList(null, 'favoriteListName', communityUser.AccountId);
            System.assertEquals(true, result.isSuccess);

            List<Favorite_List__c> listFL = [
                SELECT Id
                FROM Favorite_List__c
            ];
            System.assertEquals(1, listFL.size());

            result = B2BFavoriteListController.upsertFavoriteList(listFL[0].Id, 'favoriteListName', null);
            System.assertEquals(true, result.isSuccess);

            listFL = [
                SELECT Id
                FROM Favorite_List__c
            ];
            System.assertEquals(1, listFL.size());
        }
        Test.stopTest();
    }

    @IsTest
    static void getFavoriteListTest() {
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];

        Test.startTest();
        System.runAs(communityUser) {
            B2BResponse result = B2BFavoriteListController.upsertFavoriteList(null, 'favoriteListName', communityUser.AccountId);
            System.assertEquals(true, result.isSuccess);

            result = B2BFavoriteListController.getFavoriteList(communityUser.AccountId);
            System.assertEquals(true, result.isSuccess);
            List<B2BFavoriteListService.FavoriteList> listData = (List<B2BFavoriteListService.FavoriteList>)result.responseData;
            System.assertEquals(1, listData.size());
        }
        Test.stopTest();
    }

    @IsTest
    static void deleteFavoriteListTest() {
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];

        Test.startTest();
        System.runAs(communityUser) {
            B2BResponse result = B2BFavoriteListController.upsertFavoriteList(null, 'favoriteListName', communityUser.AccountId);
            System.assertEquals(true, result.isSuccess);

            result = B2BFavoriteListController.deleteFavoriteList((Id)result.responseData);
            System.assertEquals(false, result.isSuccess);

            List<Favorite_List__c> listFL = [
                SELECT Id
                FROM Favorite_List__c
            ];
            result = B2BFavoriteListController.deleteFavoriteList(listFL[0].Id);
            System.assertEquals(true, result.isSuccess);
        }
        Test.stopTest();
    }
}