public with sharing class B2BAuthorizeNetWrapper {

    //REQUESTS

    public static String createCustomerProfileRequest(Id contactId, CreditCardObject card, String name, String key) {
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeFieldName('createCustomerProfileRequest');

        generator.writeStartObject();
        merchantAuthentication(generator, name, key);
        profile(generator, contactId, card);
        generator.writeEndObject();

        generator.writeEndObject();
        return generator.getAsString();
    }

    public static String createCustomerProfileRequest(Id contactId, ACHObject ach, String name, String key) {
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeFieldName('createCustomerProfileRequest');

        generator.writeStartObject();
        merchantAuthentication(generator, name, key);
        profile(generator, contactId, ach);
        generator.writeEndObject();

        generator.writeEndObject();
        return generator.getAsString();
    }

    public static String createPaymentProfileRequest(String authorizeProfileId, CreditCardObject card, String name, String key) {
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeFieldName('createCustomerPaymentProfileRequest');

        generator.writeStartObject();
        merchantAuthentication(generator, name, key);
        generator.writeStringField('customerProfileId', authorizeProfileId);
        paymentProfile(generator, card, true);
        generator.writeEndObject();

        generator.writeEndObject();
        return generator.getAsString();
    }

    public static String createPaymentProfileRequest(String authorizeProfileId, ACHObject ach, String name, String key) {
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeFieldName('createCustomerPaymentProfileRequest');

        generator.writeStartObject();
        merchantAuthentication(generator, name, key);
        generator.writeStringField('customerProfileId', authorizeProfileId);
        paymentProfile(generator, ach, true);
        generator.writeEndObject();

        generator.writeEndObject();
        return generator.getAsString();
    }

    public static String getCustomerProfileRequest(String authorizeProfileId, String name, String key) {
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeFieldName('getCustomerProfileRequest');

        generator.writeStartObject();
        merchantAuthentication(generator, name, key);
        generator.writeStringField('customerProfileId', authorizeProfileId);
        generator.writeStringField('unmaskExpirationDate', 'true');

        generator.writeEndObject();

        generator.writeEndObject();
        return generator.getAsString();
    }

    public static String updateCustomerPaymentProfileRequest(String authorizeProfileId, CreditCardObject card, String name, String key) {
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeFieldName('updateCustomerPaymentProfileRequest');

        generator.writeStartObject();
        merchantAuthentication(generator, name, key);
        generator.writeStringField('customerProfileId', authorizeProfileId);

        paymentProfile(generator, card, false);

        generator.writeEndObject();
        return generator.getAsString();
    }

    public static String deleteCustomerPaymentProfileRequest(String authorizeProfileId, String customerPaymentProfileId, String name, String key) {
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeFieldName('deleteCustomerPaymentProfileRequest');

        generator.writeStartObject();
        merchantAuthentication(generator, name, key);
        generator.writeStringField('customerProfileId', authorizeProfileId);
        generator.writeStringField('customerPaymentProfileId', customerPaymentProfileId);
        generator.writeEndObject();

        generator.writeEndObject();
        return generator.getAsString();
    }

    public static String createTransactionRequest(String authorizeProfileId, String paymentProfileId, String amount, String name, String key) {
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeFieldName('createTransactionRequest');

        generator.writeStartObject();
        merchantAuthentication(generator, name, key);
        transactionRequest(generator, authorizeProfileId, paymentProfileId, amount);
        generator.writeEndObject();

        generator.writeEndObject();
        return generator.getAsString();
    }

    public static String getTransactionDetailsRequest(String transactionId, String name, String key) {
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeFieldName('getTransactionDetailsRequest');

        generator.writeStartObject();
        merchantAuthentication(generator, name, key);
        transactionDetailsRequest(generator, transactionId);
        generator.writeEndObject();

        generator.writeEndObject();
        return generator.getAsString();
    }

    public static String createRefundTransactionRequest(String profileId, String cardNumber, String expirationDate, String amount, String refTransId, String name, String key) {
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeFieldName('createTransactionRequest');

        generator.writeStartObject();
        merchantAuthentication(generator, name, key);
        refundTransactionRequest(generator, profileId, cardNumber, expirationDate, amount, refTransId);
        generator.writeEndObject();

        generator.writeEndObject();
        return generator.getAsString();
    }

    private static void merchantAuthentication(JSONGenerator generator, String name, String key) {
        generator.writeFieldName('merchantAuthentication');

        generator.writeStartObject();
        generator.writeStringField('name', name);
        generator.writeStringField('transactionKey', key);

        generator.writeEndObject();
    }

    private static void profile(JSONGenerator generator, Id contactId, CreditCardObject card) {
        generator.writeFieldName('profile');

        generator.writeStartObject();
        generator.writeStringField('merchantCustomerId', contactId);

        paymentProfiles(generator, card);

        generator.writeEndObject();
    }

    private static void profile(JSONGenerator generator, Id contactId, ACHObject ach) {
        generator.writeFieldName('profile');

        generator.writeStartObject();
        generator.writeStringField('merchantCustomerId', contactId);

        paymentProfiles(generator, ach);

        generator.writeEndObject();
    }

    private static void transactionRequest(JSONGenerator generator, String authorizeProfileId, String paymentProfileId, String amount) {
        generator.writeFieldName('transactionRequest');

        generator.writeStartObject();
        generator.writeStringField('transactionType', 'authCaptureTransaction');
        generator.writeStringField('amount', amount);

        generator.writeFieldName('profile');

        generator.writeStartObject();
        generator.writeStringField('customerProfileId', authorizeProfileId);
        generator.writeFieldName('paymentProfile');

        generator.writeStartObject();
        generator.writeStringField('paymentProfileId', paymentProfileId);
        generator.writeEndObject();

        generator.writeEndObject();

        generator.writeEndObject();
    }

    private static void refundTransactionRequest(JSONGenerator generator, String profileId, String cardNumber, String expirationDate, String amount, String refTransId) {
        generator.writeFieldName('transactionRequest');

        generator.writeStartObject();
        generator.writeStringField('transactionType', 'refundTransaction');
        generator.writeStringField('amount', amount);

        generator.writeFieldName('payment');

        generator.writeStartObject();
        generator.writeFieldName('creditCard');
        generator.writeStartObject();
        generator.writeStringField('cardNumber', cardNumber);
        generator.writeStringField('expirationDate', expirationDate);
        generator.writeEndObject();

        generator.writeEndObject();

        generator.writeStringField('refTransId', refTransId);
        generator.writeEndObject();
    }

    private static void transactionDetailsRequest(JSONGenerator generator, String transactionId) {
        generator.writeStringField('transId', transactionId);
    }

    private static void paymentProfiles(JSONGenerator generator, CreditCardObject card) {
        generator.writeFieldName('paymentProfiles');

        generator.writeStartObject();
        generator.writeStringField('customerType', 'individual');

        if (card != null) {
            payment(generator, card);
            generator.writeBooleanField('defaultPaymentProfile', card.isDefault == true);
        }
//        billTo(generator, card);

        generator.writeEndObject();
    }

    private static void paymentProfiles(JSONGenerator generator, ACHObject ach) {
        generator.writeFieldName('paymentProfiles');

        generator.writeStartObject();
        generator.writeStringField('customerType', 'individual');

        if (ach != null) {
            payment(generator, ach);
            generator.writeBooleanField('defaultPaymentProfile', ach.isDefault == true);
        }
//        billTo(generator, card);

        generator.writeEndObject();
    }

    private static void paymentProfile(JSONGenerator generator, CreditCardObject card, Boolean isNew) {
        generator.writeFieldName('paymentProfile');

        generator.writeStartObject();
        generator.writeStringField('customerType', 'individual');

        payment(generator, card);
//        billTo(generator, card);
        generator.writeBooleanField('defaultPaymentProfile', card.isDefault == true);

        if (isNew == false) {
            if (card.customerPaymentProfileId != null) {
                generator.writeStringField('customerPaymentProfileId', card.customerPaymentProfileId);
            } else if (card.customerTeamGearsPaymentProfileId != null) {
                generator.writeStringField('customerPaymentProfileId', card.customerTeamGearsPaymentProfileId);
            }
        }

        generator.writeEndObject();
    }

    private static void paymentProfile(JSONGenerator generator, ACHObject ach, Boolean isNew) {
        generator.writeFieldName('paymentProfile');

        generator.writeStartObject();
        generator.writeStringField('customerType', 'individual');

        payment(generator, ach);
//        billTo(generator, ach);
        generator.writeBooleanField('defaultPaymentProfile', ach.isDefault == true);

        if (isNew == false) {
            if (ach.customerPaymentProfileId != null) {
                generator.writeStringField('customerPaymentProfileId', ach.customerPaymentProfileId);
            } else if (ach.customerTeamGearsPaymentProfileId != null) {
                generator.writeStringField('customerPaymentProfileId', ach.customerTeamGearsPaymentProfileId);
            }
        }

        generator.writeEndObject();
    }

    /*
        Creating the payment tag. This tag contains the data of the credit card or ACH.
        To create a payment request use the TransactionRequest method.
    */
    private static void payment(JSONGenerator generator, CreditCardObject card) {
        generator.writeFieldName('payment');
        generator.writeStartObject();

        creditCard(generator, card);

        generator.writeEndObject();
    }

    /*
        Creating the payment tag. This tag contains the data of the credit card or ACH.
        To create a payment request use the TransactionRequest method.
    */
    private static void payment(JSONGenerator generator, ACHObject ach) {
        generator.writeFieldName('payment');
        generator.writeStartObject();

        bankAccount(generator, ach);

        generator.writeEndObject();
    }

    @TestVisible
    private static void billTo(JSONGenerator generator, CreditCardObject card) {
        ContactPointAddress address = [
            SELECT
                Street,
                City,
                State,
                PostalCode,
                Country
            //,
            //ContactPointPhone.TelephoneNumber
            FROM ContactPointAddress
            WHERE Id = :card.billingAddressId
            LIMIT 1
        ];

        generator.writeStartObject();
        generator.writeFieldName('billTo');

        generator.writeStartObject();
        generator.writeStringField('firstName', UserInfo.getFirstName());
        generator.writeStringField('lastName', UserInfo.getLastName());
        generator.writeStringField('company', UserInfo.getOrganizationName());

        generator.writeStringField('address', address.Street);
        generator.writeStringField('city', address.City);
        generator.writeStringField('state', address.State);
        generator.writeStringField('zip', address.PostalCode);
        generator.writeStringField('country', address.Country);

        generator.writeEndObject();
    }

    private static void creditCard(JSONGenerator generator, CreditCardObject card) {
        generator.writeFieldName('creditCard');
        generator.writeStartObject();

        generator.writeStringField('cardNumber', card.cardNumber);
        generator.writeStringField('expirationDate', card.expiryYear + '-' + card.expiryMonth);
        if (card.cvvNumber != null) {
            generator.writeStringField('cardCode', card.cvvNumber);
        }

        generator.writeEndObject();
    }

    private static void bankAccount(JSONGenerator generator, ACHObject ach) {
        generator.writeFieldName('bankAccount');
        generator.writeStartObject();

        generator.writeStringField('accountType', 'saving');
        generator.writeStringField('routingNumber', ach.routingNumber);
        generator.writeStringField('accountNumber', ach.accountNumber);
        generator.writeStringField('nameOnAccount', ach.nameOnAccount);
        generator.writeStringField('echeckType', 'WEB');
        generator.writeStringField('bankName', ach.bankName);

        generator.writeEndObject();
    }

    private static String isNull(String value) {
        return value == null ? '' : value;
    }

    //RESPONSE

    public class Response {
        public String customerProfileId;
        public String customerPaymentProfileId;
        public List<String> customerPaymentProfileIdList;
        public List<String> customerShippingAddressIdList;
        public List<String> validationDirectResponseList;
        public B2BAuthorizeNetWrapper.TransactionResponse transactionResponse;
        public String refId;
        public B2BAuthorizeNetWrapper.Messages_Response messages;
        public B2BAuthorizeNetWrapper.Profile profile;
        public List<String> subscriptionIds;
    }

    public class GetTransactionResponse {
        public B2BAuthorizeNetWrapper.Transaction_x transaction_x;
    }

    public class Profile {
        public List<B2BAuthorizeNetWrapper.PaymentProfile> paymentProfiles;
        public String customerProfileId;
        public String merchantCustomerId;
        public String description;
        public String email;
        public String profileType;
        public String customerPaymentProfileId;
    }

    public class PaymentProfile {
        public boolean defaultPaymentProfile;
        public String customerPaymentProfileId;
        public B2BAuthorizeNetWrapper.Payment payment;
        public String customerType;
        public B2BAuthorizeNetWrapper.BillTo billTo;
    }

    public class Payment {
        public B2BAuthorizeNetWrapper.CreditCard creditCard;
        public B2BAuthorizeNetWrapper.BankAccount bankAccount;
    }

    public class TransactionResponse {
        public String responseCode;
        public String authCode;
        public String avsResultCode;
        public String cvvResultCode;
        public String cavvResultCode;
        public String transId;
        public String refTransID;
        public String transHash;
        public String testRequest;
        public String accountNumber;
        public String accountType;
        public List<B2BAuthorizeNetWrapper.Errors> errors;
        public List<B2BAuthorizeNetWrapper.Messages> messages;
        public String transHashSha2;
        public Integer SupplementalDataQualificationIndicator;
        public String networkTransId;
        public Profile profile;
    }

    public class Messages {
        public String code;
        public String description;
    }

    public class Message {
        public String code;
        public String text;
    }

    public class Errors {
        public String errorCode;
        public String errorText;
    }

    public class Messages_Response {
        public String resultCode;
        public List<B2BAuthorizeNetWrapper.Message> message;
    }

    public class Transaction_x {
        public String transId;
        public String transactionStatus;
        public String responseCode;
        public String refTransId;
    }

    public static Response parseResponse(String json) {
        return (Response) System.JSON.deserializeStrict(json, Response.class);
    }

    public static GetTransactionResponse parseGetTransactionResponse(String json) {
        return (GetTransactionResponse) System.JSON.deserialize(json, GetTransactionResponse.class);
    }

    public class CreditCard {
        public String cardNumber;
        public String expirationDate;
        public String cardType;
        public String issuerNumber;
        public Boolean isPaymentToken;
    }

    public class BankAccount {
        public String accountType; //checking, savings, businessChecking
        public String routingNumber;
        public String accountNumber;
        public String nameOnAccount;
        public String echeckType = 'WEB';
        public String bankName;
        public Boolean isPaymentToken;
    }

    public class BillTo {
        public String firstName;
        public String lastName;
        public String company;
        public String address;
        public String city;
        public String state;
        public String zip;
        public String country;
        public String phoneNumber;
    }

    public class CreditCardObject {
        @AuraEnabled public String cardNumber;
        @AuraEnabled public String cvvNumber;
        @AuraEnabled public String expiryMonth;
        @AuraEnabled public String expiryYear;
        @AuraEnabled public Boolean isDefault;
        @AuraEnabled public String billingAddressId;
        @AuraEnabled public String customerPaymentProfileId;
        @AuraEnabled public String customerTeamGearsPaymentProfileId;
        @AuraEnabled public String cardBillingAddressString;
    }

    public class ACHObject {
        @AuraEnabled public String routingNumber;
        @AuraEnabled public String accountNumber;
        @AuraEnabled public String nameOnAccount;
        @AuraEnabled public String bankName;
        @AuraEnabled public Boolean isDefault;
        @AuraEnabled public String customerPaymentProfileId;
        @AuraEnabled public String customerTeamGearsPaymentProfileId;
    }
}