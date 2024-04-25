public without sharing class B2BFavoriteListAddController {

    private static final String SOMETHING_WENT_WRONG_MESSAGE = System.Label.Something_Went_Wrong_Please_contact_your_System_Administrator;
    
    @AuraEnabled
    public static B2BResponse addFavoriteListItem(Id favoriteListId, String favoriteListName, Id effectiveAccountId, Id productId) {
        try {
            if (String.isBlank(productId)) {
                return new B2BResponse(false, 'PRODUCT_IS_EMPTY');
            }

            if (String.isBlank(favoriteListId)) {
                if (String.isBlank(effectiveAccountId)) {
                    return new B2BResponse(false, 'ACCOUNT_IS_EMPTY');
                }
                if (String.isBlank(favoriteListName)) {
                    return new B2BResponse(false, 'FAVORITE_NAME_IS_EMPTY');
                }
                favoriteListId = B2BFavoriteListService.upsertFavoriteList(favoriteListId, favoriteListName, effectiveAccountId);
            }

            List<Favorite_List_Item__c> recFLI = [
                SELECT Id, ProductId__c
                FROM Favorite_List_Item__c
                WHERE Favorite_List_Id__c = :favoriteListId
                    AND ProductId__c = :productId
            ];

            if (recFLI.size() == 0) {
                Favorite_List_Item__c newRec = new Favorite_List_Item__c();
                newRec.ProductId__c = productId;
                newRec.Favorite_List_Id__c = favoriteListId;

                insert newRec;
                return new B2BResponse(true, 'Success');
            } else {
                return new B2BResponse(false, 'ALREADY_EXIST');
            }
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage() + ' ' + e.getLineNumber(), SOMETHING_WENT_WRONG_MESSAGE);
        }
    }
}