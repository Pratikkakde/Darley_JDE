public without sharing class B2BFavoriteListController {
    
    private static final String SOMETHING_WENT_WRONG_MESSAGE = System.Label.Something_Went_Wrong_Please_contact_your_System_Administrator;

    @AuraEnabled
    public static B2BResponse getFavoriteList(Id effectiveAccountId) {
        try {
            return new B2BResponse(true, B2BFavoriteListService.getFavoriteList(effectiveAccountId), 'Success');
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage() + ' ' + e.getLineNumber(), SOMETHING_WENT_WRONG_MESSAGE);
        }
    }

    @AuraEnabled
    public static B2BResponse upsertFavoriteList(Id favoriteListId, String favoriteListName, Id effectiveAccountId) {
        try {
            if (String.isBlank(favoriteListId)) {
                if (String.isBlank(effectiveAccountId)) {
                    return new B2BResponse(false, 'ACCOUNT_IS_EMPTY');
                }
                if (String.isBlank(favoriteListName)) {
                    return new B2BResponse(false, 'FAVORITE_NAME_IS_EMPTY');
                }
            }
            B2BFavoriteListService.upsertFavoriteList(favoriteListId, favoriteListName, effectiveAccountId);

            return new B2BResponse(true, 'Success');
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage() + ' ' + e.getLineNumber(), SOMETHING_WENT_WRONG_MESSAGE);
        }
    }

    @AuraEnabled
    public static B2BResponse deleteFavoriteList(Id favoriteListId) {
        try {
            delete new Favorite_List__c(Id = favoriteListId);

            return new B2BResponse(true, 'Success');
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage() + ' ' + e.getLineNumber(), SOMETHING_WENT_WRONG_MESSAGE);
        }
    }
}