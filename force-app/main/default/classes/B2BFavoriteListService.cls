public without sharing class B2BFavoriteListService {
    
    public static List<FavoriteList> getFavoriteList(Id effectiveAccountId) {
        List<FavoriteList> favoriteLists = new List<FavoriteList>();

        for (Favorite_List__c recFL : [
            SELECT Id, Name, Favorite_List_Product_Count__c, CreatedDate
            FROM Favorite_List__c
            WHERE AccountId__c = :effectiveAccountId
        ]) {
            FavoriteList newRec = new FavoriteList();
            newRec.id = recFL.Id;
            newRec.name = recFL.Name;
            newRec.countOfRecords = recFL.Favorite_List_Product_Count__c;
            newRec.createdDate = recFL.CreatedDate;

            favoriteLists.add(newRec);
        }

        return favoriteLists;
    }

    public static Id upsertFavoriteList(Id favoriteListId, String favoriteListName, Id effectiveAccountId) {
        Favorite_List__c favoriteListRecord = new Favorite_List__c();
        favoriteListRecord.Name = favoriteListName;

        if (String.isNotBlank(favoriteListId)) {
            favoriteListRecord.Id = favoriteListId;
        }

        if (String.isNotBlank(effectiveAccountId)) {
            favoriteListRecord.AccountId__c = effectiveAccountId;
        }

        upsert favoriteListRecord;

        return favoriteListRecord.Id;
    }

    public class FavoriteList {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public Decimal countOfRecords { get; set; }
        @AuraEnabled public DateTime createdDate { get; set; }
    }
}