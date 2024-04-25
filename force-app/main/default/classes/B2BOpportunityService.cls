public without sharing class B2BOpportunityService {

    private static final Id RECORD_TYPE_ID_EQUIPMENT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
    private static final String TYPE_EXISTING_BUSINESS = 'Existing Business';
    private static final String TYPE_NEW_BUSINESS = 'New Business';
    private static final String STAGE_QUOTED_OPPORTUNITY = 'Quoted Opportunity';

    public static void createOpportunity(Account account, WebCart cart, Quote__c quote, Decimal darleyCostTotal) {
        Opportunity opportunity = new Opportunity(
            RecordTypeId = RECORD_TYPE_ID_EQUIPMENT,
            Name = getOpportunityName(account.Name, cart.CartItems),
            AccountId = account.Id,
            Type = account.JDE_Address_Number__c == null ? TYPE_NEW_BUSINESS : TYPE_EXISTING_BUSINESS,
            Amount = cart.GrandTotalAmount,
            Darley_Quote__c = quote.Name,
            B2BQuote__c = quote.Id,
            StageName = STAGE_QUOTED_OPPORTUNITY,
            CloseDate = Date.today().addDays(30),
            Darley_Cost__c = darleyCostTotal
        );

        B2BSettings__c b2BSettings = B2BSettings__c.getInstance();
        if (b2BSettings != null && b2BSettings.OpportunityOwner__c != null) {
            List<User> opportunityOwners = [SELECT Id FROM User WHERE Username = :b2BSettings.OpportunityOwner__c];

            if (!opportunityOwners.isEmpty()) {
                opportunity.OwnerId = opportunityOwners[0].Id;
            }
        }

        insert opportunity;
    }

    private static String getOpportunityName(String accountName, List<CartItem> cartItems) {
        String productName = getProductNameWithLargestPrice(cartItems);
        return getOpportunityName(accountName, productName);
    }

    public static String getOpportunityName(String accountName, String productName) {
        return accountName + ' ' + productName + '-Quote';
    }

    private static String getProductNameWithLargestPrice(List<CartItem> cartItems) {
        Decimal maximum = cartItems[0].SalesPrice;
        String productName = cartItems[0].Product2.Name;
        for (CartItem cartItem : cartItems) {
            if (maximum < cartItem.SalesPrice) {
                maximum = cartItem.SalesPrice;
                productName = cartItem.Product2.Name;
            }
        }

        return productName;
    }

}