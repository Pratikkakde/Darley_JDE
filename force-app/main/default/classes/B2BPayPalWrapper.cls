public class B2BPayPalWrapper {

    public class paymentInfo{
        @auraEnabled public String crediCardNumber{get;set;}
        @auraEnabled public String crediCardExpirationDate{get;set;}
        @auraEnabled public String crediCardCVC{get;set;}
        @auraEnabled public Decimal amount{get;set;}
        @auraEnabled public Boolean savePaymentMethod{get;set;}
        @auraEnabled public String originalTransactionReferencedId{get;set;}
        @auraEnabled public String billtozip{get;set;}
        //utils
        @auraEnabled public String cartType{get;set;}
        @auraEnabled public String selectedCustomerCardPaymentId{get;set;}
        @auraEnabled public String cardHolderName{get;set;}
        @auraEnabled public Boolean isDefault{get;set;}
    }

    public class PaymentInfoResponse{
        @auraEnabled public String postfpsmsg{get;set;}//No
        @auraEnabled public String prefpsmsg{get;set;}//No Rules Triggered
        @auraEnabled public String authcode{get;set;}//010101
        @auraEnabled public String respmsg{get;set;}//Approved
        @auraEnabled public String pnref{get;set;}//A53F1A9BCB40
        @auraEnabled public String result{get;set;}//0
        @auraEnabled public String acct{get;set;}// last 4
    }
}