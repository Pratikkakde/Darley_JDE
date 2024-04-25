public with sharing class B2BDataCollector {

    private static User prepareCustomerCreationData(Id userId) {
        List<User> users = [
            SELECT
                Id,
                Name,
                Email,
                ContactId,
                AccountId,
                Account.Name,
                Contact.Name,
                Contact.Stripe_Customer_Id__c
            FROM User
            WHERE Id = :userId
        ];

        return users.isEmpty()
            ? null
            : users[0];
    }

    public static String stripePrepareCustomerCreationData(Id userId) {
        User user = prepareCustomerCreationData(userId);
        if (user == null) {
            return null;
        }
        Map<String, String> params = new Map<String, String>();
        params.put('description', user.Contact.Name);
        params.put('name', user.Contact.Name);
        params.put('email', user.Email);
        params.put('metadata[contact_id]', user.ContactId);
        params.put('metadata[account_id]', user.AccountId);

        return getParamsAsString(params);
    }

    private static String getParamsAsString(Map<String, String> params) {
        String customerParams = '';

        for (String paramKey : params.keySet()) {
            String paramValue = params.get(paramKey);
            if (paramValue == null) {
                continue;
            }

            if (customerParams.length() > 1) {
                customerParams += '&';
            }
            customerParams += paramKey + '=' + paramValue;
        }

        return customerParams;
    }

    public class CreditCard {
        @AuraEnabled public Integer indexNumber;
        @AuraEnabled public String cardName;
        @AuraEnabled public String paymentMethodId;
        @AuraEnabled public String cardNumber;
        @AuraEnabled public String cardType;
        @AuraEnabled public String expiryMonth;
        @AuraEnabled public String expiryYear;
        @AuraEnabled public String funding;
        @AuraEnabled public Boolean isDefault;
    }
}