public  class B2BPayPalService {
    public static string authorizeRequestBody(B2B_PayPalConfiguration__mdt payPalConfiguration, B2BPayPalWrapper.paymentInfo paymentInfo){
        return formatQueryParameters(authorizeRequestMapping(payPalConfiguration, paymentInfo));
    }

    public static B2BPayPalWrapper.PaymentInfoResponse processPayflowInfoResponse(String body){
        Map<String,String> nameValuePairs = processRawResponse(body);
        B2BPayPalWrapper.PaymentInfoResponse paymentInfoResponse = new B2BPayPalWrapper.PaymentInfoResponse();
        paymentInfoResponse.result = nameValuePairs.get('RESULT');
        paymentInfoResponse.pnref = nameValuePairs.get('PNREF');
        paymentInfoResponse.respmsg = nameValuePairs.get('RESPMSG');
        paymentInfoResponse.authcode = nameValuePairs.get('AUTHCODE');
        paymentInfoResponse.prefpsmsg = nameValuePairs.get('PREFPSMSG');
        paymentInfoResponse.postfpsmsg = nameValuePairs.get('POSTFPSMSG');
        paymentInfoResponse.acct = nameValuePairs.get('ACCT');
        return paymentInfoResponse;
    }

    private static Map<String,String> authorizeRequestMapping(B2B_PayPalConfiguration__mdt payPalConfiguration, B2BPayPalWrapper.paymentInfo paymentInfo){
        Map<String,String> parameters  = new  Map<String,String>();
        parameters.put('PARTNER', payPalConfiguration.Partner__c);
        parameters.put('PWD', payPalConfiguration.Password__c);
        parameters.put('VENDOR', payPalConfiguration.Vendor__c);
        parameters.put('USER', payPalConfiguration.User__c);
        parameters.put('TENDER', payPalConfiguration.Tender__c);
        parameters.put('TRXTYPE', 'A');
        parameters.put('AMT', String.valueOf(paymentInfo.amount));
        parameters.put('BILLTOZIP',paymentInfo.billtozip);


        if( String.isNotBlank(paymentInfo.originalTransactionReferencedId)){
            parameters.put('CARDONFILE', 'CITU');
            parameters.put('ORIGID', paymentInfo.originalTransactionReferencedId);
        }else{
            //Credit card Data
            parameters.put('ACCT', paymentInfo.crediCardNumber);
            parameters.put('EXPDATE', paymentInfo.crediCardExpirationDate);
            parameters.put('CVV2', paymentInfo.crediCardCVC);
            
            // Store CardData
            if(paymentInfo.savePaymentMethod){
                parameters.put('CARDONFILE', 'CITI');
            }
        }
        parameters.put('VERBOSITY', 'HIGH');
        return parameters;
    }

    private static String formatQueryParameters(Map<String,String> parameters){
        String parameterString = '';
        for (String key : parameters.keySet()) {
            if (parameterString.length() > 1) {
                parameterString += '&';
            }
            parameterString += key + '=' + parameters.get(key);
        }
        return parameterString;
    }

    private static Map<String,String> processRawResponse(String body){
        Map<String,String> nameValuePairs = new Map<String,String>();
        if(String.isNotBlank(body)){
            for (String  nameValuePair : body.split('&')) {
                nameValuePairs.put(nameValuePair.split('=').get(0), nameValuePair.split('=').get(1));
            }
        }
        return nameValuePairs;
    }
}