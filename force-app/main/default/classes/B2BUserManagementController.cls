public without sharing class B2BUserManagementController {

    @AuraEnabled
    public static B2BResponse getCommunityMembers() {
        try {
            User currentUser = getCurrentUserInfo();

            Boolean hasUserManagerPermission = FeatureManagement.checkPermission('B2B_User_Manager');

            if (!hasUserManagerPermission) {
                return new B2BResponse(false, 'NOT_HAVE_PERMISSION', System.Label.B2B_Access_User_Manager);
            }

            List<CommunityMember> listMembers = new List<CommunityMember>();

            List<Contact> listContact = [
                SELECT
                    Id,
                    Name, 
                    Email, 
                    AccountId, 
                    FirstName, 
                    LastName,
                    Phone,
                    (
                        SELECT 
                            Id, 
                            Email, 
                            Title, 
                            FirstName, 
                            LastName, 
                            Username, 
                            Name, 
                            isActive, 
                            AccountId,
                            Phone,
                            SmallPhotoUrl
                        FROM Users
                    )
                FROM Contact 
                WHERE AccountId = :currentUser.AccountId
            ];

            for (Contact rec : listContact) {
                Boolean isUserExist = rec.Users.size() > 0;
                if (isUserExist) { // remove this condition if you want to get contacts without users
                    User contUser = isUserExist ? rec.Users[0] : new User();

                    CommunityMember itemMember = new CommunityMember();
                    itemMember.contactId = rec.Id;
                    itemMember.userId = isUserExist ? contUser.Id : '';
                    itemMember.firstName = isUserExist ? contUser.FirstName : rec.FirstName;
                    itemMember.lastName = isUserExist ? contUser.LastName : rec.LastName;
                    itemMember.username = isUserExist ? contUser.Username : rec.Name;
                    itemMember.email = isUserExist ? contUser.Email : rec.Email;
                    itemMember.photoUrl = isUserExist ? contUser.SmallPhotoUrl : '';
                    itemMember.title = isUserExist ? contUser.Title : '';
                    itemMember.isActive = isUserExist ? contUser.isActive : false;
                    itemMember.accountId = isUserExist ? contUser.AccountId : rec.AccountId;
                    itemMember.phone = isUserExist ? contUser.Phone : rec.Phone;
                    itemMember.isCurrentUser = isUserExist && contUser.Id == currentUser.Id;

                    listMembers.add(itemMember);
                }
            }

            return new B2BResponse(true, listMembers, 'Success');
        } catch (Exception ex) {
            String errorMessage = ex.getMessage() + ' On:' + ex.getStackTraceString();
            System.debug(errorMessage);
            return new B2BResponse(false, errorMessage);
        }
    }

    private static User getCurrentUserInfo() {
        return [
            SELECT
                Id,
                AccountId,
                ContactId
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
    }

    @AuraEnabled
    public static B2BResponse resetUserPassword(Id userId) {
        try {
            System.resetPassword(userId, true);

            return new B2BResponse(true, 'Success');
        } catch (Exception ex) {
            String errorMessage = ex.getMessage() + ' On:' + ex.getStackTraceString();
            System.debug(errorMessage);
            return new B2BResponse(false, errorMessage);
        }
    }

    @AuraEnabled
    public static B2BResponse activateUser(Id userId, Boolean active) {
        try {
            User recUser = new User(
                Id = userId,
                IsActive = active
            );

            update recUser;

            return new B2BResponse(true, 'Success');
        } catch (Exception ex) {
            String errorMessage = ex.getMessage() + ' On:' + ex.getStackTraceString();
            System.debug(errorMessage);
            return new B2BResponse(false, errorMessage);
        }
    }

    @AuraEnabled
    public static B2BResponse getDelegatedPermissions(Id userId) {
        Map<String, Object> mapSettings = getCommerceSettings();

        if (!mapSettings.containsKey('Default_User_Profile_Name')) {
            return new B2BResponse(false, 'Metadata Default User Profile Name is not found');
        }
        
        String userProfileName = (String)mapSettings.get('Default_User_Profile_Name');

        List<PortalDelegablePermissionSet> delegatedPermissions = [
            SELECT
                Id,
                ProfileId,
                PermissionSetId,
                PermissionSet.Name,
                PermissionSet.Label,
                Profile.Name
            FROM PortalDelegablePermissionSet
            WHERE Profile.Name = :userProfileName
        ];

        return new B2BResponse(true, delegatedPermissions, 'Success'); 
    }

    @AuraEnabled
    public static B2BResponse getPermissionSetAssignment(Id userId) {
        List<PermissionSetAssignment> userPermissions = [
            SELECT
                PermissionSetId, 
                AssigneeId, 
                PermissionSet.Name, 
                PermissionSet.Label
            FROM PermissionSetAssignment
            WHERE AssigneeId = :userId
        ];

        return new B2BResponse(true, userPermissions, 'Success'); 
    }

    @AuraEnabled
    public static B2BResponse editPermissionSets(List<String> newPermssionIds, List<String> deletePermssionIds, Id userId) {
        try {
            B2BResponse responseExistPermissions = getPermissionSetAssignment(userId);
            List<PermissionSetAssignment> existUserPermissions = (List<PermissionSetAssignment>)responseExistPermissions.responseData;

            Map<Id, PermissionSetAssignment> existUserPermissionsSets = new Map<Id, PermissionSetAssignment>();
            for (PermissionSetAssignment rec : existUserPermissions) {
                existUserPermissionsSets.put(rec.PermissionSetId, rec);
            }

            List<PermissionSetAssignment> newPermissionSetAssignmentList = new List<PermissionSetAssignment>();
            for (Id recId : newPermssionIds) {
                if (!existUserPermissionsSets.containsKey(recId)) {
                    PermissionSetAssignment newPermissionSetAssignment = new PermissionSetAssignment(
                        PermissionSetId = recId,
                        AssigneeId = userId
                    );

                    newPermissionSetAssignmentList.add(newPermissionSetAssignment);
                }
            }

            List<PermissionSetAssignment> deletePermissionSetAssignmentList = new List<PermissionSetAssignment>();
            for (Id recId : deletePermssionIds) {
                if (existUserPermissionsSets.containsKey(recId)) {
                    deletePermissionSetAssignmentList.add(existUserPermissionsSets.get(recId));
                }
            }

            if (!newPermissionSetAssignmentList.isEmpty()) {
                insert newPermissionSetAssignmentList;
            }

            if (!deletePermissionSetAssignmentList.isEmpty()) {
                delete deletePermissionSetAssignmentList;
            }

            return new B2BResponse(true, 'Success');
        } catch (Exception ex) {
            String errorMessage = ex.getMessage() + ' On:' + ex.getStackTraceString();
            System.debug(errorMessage);

            if (errorMessage.contains('FIELD_INTEGRITY_EXCEPTION')) {
                return new B2BResponse(false, 'FIELD_INTEGRITY_EXCEPTION', errorMessage.substringBetween('FIELD_INTEGRITY_EXCEPTION,', ': ['));
            }

            return new B2BResponse(false, errorMessage);
        }
    }

    public static Map<String, Object> getCommerceSettings() {

        Map<String, Object> result = new Map<String, Object>();

        for (B2B_Commerce_Setting__mdt itemRec : [
            SELECT
                DeveloperName, 
                Value__c
            FROM B2B_Commerce_Setting__mdt
        ]) {
            result.put(itemRec.DeveloperName, itemRec.Value__c);
        }

        return result;
    }

    public class CommunityMember {
        @AuraEnabled public String contactId { get; set; }
        @AuraEnabled public String userId { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String phone { get; set; }
        @AuraEnabled public Boolean isActive { get; set; }
        @AuraEnabled public String firstName { get; set; }
        @AuraEnabled public String lastName { get; set; }
        @AuraEnabled public String username { get; set; }
        @AuraEnabled public String accountId { get; set; }
        @AuraEnabled public String photoUrl { get; set; }
        @AuraEnabled public Boolean isCurrentUser { get; set; }

        public CommunityMember() {}
    }
    
}