public without sharing class B2BUserUpsertController {

    @AuraEnabled
    public static B2BResponse addNewUser(String userInfo) {
        Contact recContact = new Contact();

        try {
            Map<String, Object> mapSettings = B2BUserManagementController.getCommerceSettings();

            if (!mapSettings.containsKey('Default_User_Profile_Name')) {
                return new B2BResponse(false, 'Metadata Default User Profile Name is not found');
            }

            if (!mapSettings.containsKey('Default_User_PermissionSet_Name')) {
                return new B2BResponse(false, 'Metadata Default User PermissionSet Name is not found');
            }
            
            String userProfileName = (String)mapSettings.get('Default_User_Profile_Name');
            String userPermissionSetName = (String)mapSettings.get('Default_User_PermissionSet_Name');

            UserWrapper userData = (UserWrapper) System.JSON.deserialize(userInfo, UserWrapper.class);

            Profile profile = [SELECT Id, Name FROM Profile WHERE Name = :userProfileName LIMIT 1];
            Account account = [SELECT Id, Name FROM Account WHERE Id = :userData.accountId LIMIT 1];

            recContact.Email = userData.email;
            recContact.FirstName = userData.firstName;
            recContact.LastName = userData.lastName;
            recContact.Title = userData.title;
            recContact.AccountId = userData.accountId;
            recContact.Phone = userData.phone;

            insert recContact;

            User recUser = new User(
                Email = userData.email,
                FirstName = userData.firstName,
                LastName = userData.lastName,
                Username = userData.email,
                Title = userData.title,
                Phone = userData.phone,
                IsActive = userData.isActive,
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'UTF-8',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ProfileId = profile.Id,
                Alias = userData.lastName != null ? (userData.firstName != null ? userData.firstName.left(1) : '') + userData.lastName.left(4) : null,
                ContactId = recContact.Id,
                CompanyName = account.Name,
                CommunityNickname = userData.email
            );

            insert recUser;

            List<PermissionSet> b2bPermSet = [
                SELECT Id 
                FROM PermissionSet 
                WHERE Name = :userPermissionSetName
                    OR Name = :B2BUtils.PIMLY_USER_PERMISSION_SET_NAME
            ];

            if (!b2bPermSet.isEmpty()) {
                assignPermissionSets((new Map<Id, PermissionSet>(b2bPermSet)).keySet(), recUser.Id);
            }

            return new B2BResponse(true, 'Success');
        } catch (Exception ex) {
            String errorMessage = ex.getMessage() + ' On:' + ex.getStackTraceString();
            System.debug(errorMessage);

            if (errorMessage.contains('DUPLICATE_USERNAME') || errorMessage.contains('DUPLICATES_DETECTED')) {
                return new B2BResponse(false, 'DUPLICATE_USERNAME', errorMessage);
            }
            
            return new B2BResponse(false, errorMessage);
        }
    }

    @AuraEnabled
    public static B2BResponse editUser(String userInfo) {
        try {
            UserWrapper userData = (UserWrapper) System.JSON.deserialize(userInfo, UserWrapper.class);

            User recUser = new User(
                Id = userData.userId,
                Email = userData.email,
                FirstName = userData.firstName,
                LastName = userData.lastName,
                Title = userData.title,
                Phone = userData.phone
            );

            update recUser;

            return new B2BResponse(true, 'Success');
        } catch (Exception ex) {
            String errorMessage = ex.getMessage() + ' On:' + ex.getStackTraceString();
            System.debug(errorMessage);
            return new B2BResponse(false, errorMessage);
        }
    }

    @Future
    private static void assignPermissionSets(Set<Id> newPermssionIds, Id userId) {
        List<PermissionSetAssignment> newPermissionSetAssignmentList = new List<PermissionSetAssignment>();
        for (Id recId : newPermssionIds) {
            PermissionSetAssignment newPermissionSetAssignment = new PermissionSetAssignment(
                PermissionSetId = recId,
                AssigneeId = userId
            );

            newPermissionSetAssignmentList.add(newPermissionSetAssignment);
        }

        if (!newPermissionSetAssignmentList.isEmpty()) {
            Database.insert(newPermissionSetAssignmentList, false);
        }
    }

    public class UserWrapper {
        @AuraEnabled public String userId { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String phone { get; set; }
        @AuraEnabled public Boolean isActive { get; set; }
        @AuraEnabled public String firstName { get; set; }
        @AuraEnabled public String lastName { get; set; }
        @AuraEnabled public String username { get; set; }
        @AuraEnabled public String accountId { get; set; }

        public UserWrapper() {}
    }
}