public without sharing class B2BRegisterService {

    private static final Integer COMPANY_NAME_MAX_LENGTH = 80;

    public static Contact createCommerceUser(B2BRegister register, Account account) {
        Contact contact = getContact(register, account);
        insert contact;

        User user = getUser(register, contact.Id);
        insert user;

        createPermissionSetInFuture(user.Id);
        return contact;
    }

    public static Account createCommerceAccount(B2BRegister register) {
        B2BSettings__c b2bSettings = B2BSettings__c.getInstance();

        Account account = getAccount(register, b2bSettings.AccountOwnerId__c);
        insert account;

        ContactPointAddress contactPointAddress = getContactPointAddress(register, account.Id);
        insert contactPointAddress;

        BuyerAccount buyerAccount = getBuyerAccount(account);
        insert buyerAccount;

        BuyerGroupMember buyerGroupMember = getBuyerGroupMember(account.Id, b2bSettings.BuyerGroupId__c);
        insert buyerGroupMember;

        return account;
    }

    @Future
    private static void createPermissionSetInFuture(Id userId) {
        List<PermissionSetAssignment> permissionSetAssignmens = new List<PermissionSetAssignment>{
            B2BUtils.getPermissionSetAssignment(userId),
            B2BUtils.getPimlyPermissionSetAssignment(userId)
        };
        insert permissionSetAssignmens;
    }

    public static List<User> selectUserByEmailOrUsername(String email) {
        return [
            SELECT Id, Username
            FROM User
            WHERE Email = :email
            OR Username = :email
            LIMIT 1
        ];
    }

    private static Contact getContact(B2BRegister register, Account account) {
        return new Contact(
            FirstName = register.firstName,
            LastName = register.lastName,
            Email = register.email,
            AccountId = account.Id,
            OwnerId = account.OwnerId,
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Equipment_Contact').getRecordTypeId()
        );
    }

    private static User getUser(B2BRegister register, Id contactId) {
        return new User(
            ProfileId = B2BUtils.getCommerceUserProfileId(),
            ContactId = contactId,
            Username = register.email,
            Email = register.email,
            FirstName = register.firstName,
            LastName = register.lastName,
            CompanyName = register.companyName == null ? null : register.companyName.left(COMPANY_NAME_MAX_LENGTH),
            Country = register.country,
            City = register.city,
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            IsActive = true,
            Alias = register.firstName != null && register.lastName != null ? register.firstName.left(1) + register.lastName.left(4) : null
        );
    }

    private static Account getAccount(B2BRegister register, Id accountOwnerId) {
        Boolean taxExempt = false;
        if (register.registrationType == 'Federal government') {
            taxExempt = true;
        }
        return new Account(
            Name = register.companyName,
            Phone = register.companyPhoneNumber,
            BillingCountry = register.country,
            BillingState = register.state,
            BillingCity = register.city,
            BillingStreet = register.streetAddress,
            BillingPostalCode = register.postalCode,
            OwnerId = accountOwnerId,
            AccountType__c = register.registrationType,
            B2BTaxExempt__c = taxExempt,
            RecordTypeId = 	Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2B_EDarley_New_Registrant').getRecordTypeId()
        );
    }

    private static ContactPointAddress getContactPointAddress(B2BRegister register, Id accountId) {
        return new ContactPointAddress(
            AddressType = 'Billing',
            Name = 'Billing Address',
            ParentId = accountId,
            IsDefault = true,
            Country = register.country,
            State = register.state,
            City = register.city,
            Street = register.streetAddress,
            PostalCode = register.postalCode
        );
    }

    private static BuyerAccount getBuyerAccount(Account account) {
        return new BuyerAccount(
            BuyerStatus = 'Active',
            CommerceType = 'Buyer',
            BuyerId = account.Id,
            Name = account.Name,
            IsActive = true,
            OwnerId = account.OwnerId
        );
    }

    private static BuyerGroupMember getBuyerGroupMember(Id accountId, Id buyerGroupId) {
        return new BuyerGroupMember(
            BuyerId = accountId,
            BuyerGroupId = buyerGroupId
        );
    }
}