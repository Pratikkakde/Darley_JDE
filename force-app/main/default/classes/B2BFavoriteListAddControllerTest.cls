@IsTest
private class B2BFavoriteListAddControllerTest {

    @TestSetup
    private static void makeData() {
        new B2BDefaultTestData().initAllData();

        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];

        System.runAs(communityUser) {
            Favorite_List__c newList = new Favorite_List__c(
                Name = 'FL01',
                AccountId__c = communityUser.AccountId
            );
            insert newList;

            List<Product2> listProd = [
                SELECT Id, Name
                FROM Product2
            ];

            Favorite_List_Item__c newFLI = new Favorite_List_Item__c(
                ProductId__c = listProd[0].Id,
                Favorite_List_Id__c = newList.Id
            );
            insert newFLI;
        }
    }

    @IsTest
    static void addFavoriteListItemTest() {
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];

        List<Favorite_List__c> listFL = [
            SELECT Id, Name
            FROM Favorite_List__c
            WHERE AccountId__c = :communityUser.AccountId
        ];

        List<Product2> listProd = [
            SELECT Id, Name
            FROM Product2
        ];

        Test.startTest();
        System.runAs(communityUser) {
            B2BResponse result = B2BFavoriteListAddController.addFavoriteListItem(null, 'favoriteListName', communityUser.AccountId, null);
            System.assertEquals(false, result.isSuccess);
            System.assertEquals('PRODUCT_IS_EMPTY', (String)result.responseMessage);

            result = B2BFavoriteListAddController.addFavoriteListItem(null, 'favoriteListName', null, listProd[0].Id);
            System.assertEquals(false, result.isSuccess);
            System.assertEquals('ACCOUNT_IS_EMPTY', (String)result.responseMessage);

            result = B2BFavoriteListAddController.addFavoriteListItem(null, '', communityUser.AccountId, listProd[0].Id);
            System.assertEquals(false, result.isSuccess);
            System.assertEquals('FAVORITE_NAME_IS_EMPTY', (String)result.responseMessage);

            result = B2BFavoriteListAddController.addFavoriteListItem(null, 'favoriteListName', communityUser.AccountId, listProd[0].Id);
            System.assertEquals(true, result.isSuccess);

            result = B2BFavoriteListAddController.addFavoriteListItem(listFL[0].Id, '', null, listProd[0].Id);
            System.assertEquals(false, result.isSuccess);
            System.assertEquals('ALREADY_EXIST', (String)result.responseMessage);
        }
        Test.stopTest();
    }

}