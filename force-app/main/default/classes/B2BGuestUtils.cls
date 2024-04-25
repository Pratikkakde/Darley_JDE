/**
 * Created by IrinaSakovich on 26.07.22.
 */

public without sharing class B2BGuestUtils {
    private static final String GUEST_ACCOUNT = 'GuestAccount';
    private static final String BUYER_GROUP_NAME = Guest_Buyer_Group__c.getInstance()?.Buyer_Group_Name__c;
    public static Boolean isCurrentUserGuest() {
        String userType = UserInfo.getUserType();

        return 'Guest'.equals(userType);
    }

    /**
     * Returns WebStore (null if not found) based on current community Id.
     * In test mode returned value is one of created WebStores or null.
     *
     * @return WebStore - the current Web Store or null
     */
    public static WebStore getStoreRelatedToCurrentUser() {
        String communityName;

        if (!Test.isRunningTest()) {
            String communityId = Network.getNetworkId();
            if (String.isBlank(communityId)) {
                return null;
            }
            communityName = ConnectApi.Communities.getCommunity(communityId).name;
        }

        String webStoreQuery = 'SELECT Id, GuestBuyerProfileId FROM WebStore ';
        webStoreQuery += !Test.isRunningTest() ? 'WHERE Name = :communityName ' : '';
        webStoreQuery += 'LIMIT 1';

        List<WebStore> webStores = Database.query(webStoreQuery);

        return webStores.isEmpty()
            ? null
            : webStores[0];
    }

    public static Account getDefaultGuestAccount() {
        List<Account> guestAccount = [
            SELECT Id
            FROM Account
            WHERE Name = :GUEST_ACCOUNT
            LIMIT 1
        ];

        if (guestAccount.isEmpty()) {
            Account newGuestAccount = B2BTestDataFactory.createAccount(false, GUEST_ACCOUNT);
            insert newGuestAccount;

            return newGuestAccount;
        } else {
            return guestAccount[0];
        }
    }

    public static Account getUniqueGuestAccount() {
        Account newGuestAccount = new Account(
            Name = GUEST_ACCOUNT + System.now()
        );
        insert newGuestAccount;
        BuyerAccount buyerAccount = enableAccountAsBuyer(newGuestAccount.Id);
        assignAccountToBuyerGroup(buyerAccount, BUYER_GROUP_NAME);

        return newGuestAccount;
    }

    private static BuyerAccount enableAccountAsBuyer(String accountId) {
        List<BuyerAccount> buyerAccounts = [
            SELECT Id, BuyerId
            FROM BuyerAccount
            WHERE BuyerId = :accountId
        ];

        String buyerAccountId = buyerAccounts.isEmpty()
            ? null
            : buyerAccounts[0].Id;

        BuyerAccount buyerAccount = new BuyerAccount(
            Id = buyerAccountId,
            Name = 'Guest Buyer Account',
            CommerceType = 'Buyer',
            BuyerId = accountId,
            IsActive = true
        );

        upsert buyerAccount;

        return buyerAccount;
    }

    private static void assignAccountToBuyerGroup(BuyerAccount buyerAccount, String buyerGroupName) {
        List<BuyerGroup> buyerGroups = [
            SELECT Id
            FROM BuyerGroup
            WHERE Name = :buyerGroupName
            LIMIT 1
        ];

        if (!buyerGroups.isEmpty()) {
            BuyerGroupMember buyerGroupMember = new BuyerGroupMember(
                BuyerGroupId = buyerGroups[0].Id,
                BuyerId = buyerAccount.BuyerId
            );

            insert buyerGroupMember;
        }
    }
}