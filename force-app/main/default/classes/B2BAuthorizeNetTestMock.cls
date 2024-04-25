@IsTest
public with sharing class B2BAuthorizeNetTestMock {

    private class Mock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            if (req.getBody().contains('ERROR')) {
                return createResponse('ERROR');
            } else if (req.getBody().contains('createCustomerProfileRequest')) {
                return createResponse(CREATE_CUSTOMER_PROFILE_RESPONSE);
            } else if (req.getBody().contains('createCustomerPaymentProfileRequest')) {
                return createResponse(CREATE_CUSTOMER_PAYMENT_PROFILE_RESPONSE);
            } else if (req.getBody().contains('updateCustomerPaymentProfileRequest')) {
                return createResponse(UPDATE_CUSTOMER_PAYMENT_PROFILE_RESPONSE);
            } else if (req.getBody().contains('getCustomerProfileRequest')) {
                return createResponse(GET_CUSTOMER_PROFILE_RESPONSE);
            } else if (req.getBody().contains('deleteCustomerPaymentProfileRequest')) {
                return createResponse(CREATE_TRANSACTION_RESPONSE);
            } else if (req.getBody().contains('createTransactionRequest')) {
                return createResponse(DELETE_CUSTOMER_PAYMENT_PROFILE_RESPONSE);
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }

        private HttpResponse createResponse(String body) {
            HTTPResponse response = new HTTPResponse();
            response.setBody(body);
            response.setStatusCode(200);
            return response;
        }
    }

    public static void mock() {
        Test.setMock(HttpCalloutMock.class, new Mock());
    }

    private static String CREATE_CUSTOMER_PROFILE_RESPONSE = '{\n' +
        '    "customerProfileId": "190178",\n' +
        '    "customerPaymentProfileIdList": [\n' +
        '        "157497"\n' +
        '    ],\n' +
        '    "customerShippingAddressIdList": [],\n' +
        '    "validationDirectResponseList": [\n' +
        '        "1,1,1,(TESTMODE) This transaction has been approved.,000000,P,0,none,Test transaction for ValidateCustomerPaymentProfile.,1.00,CC,auth_only,Merchant_Customer_ID,,,,,,,,,,,customer-profile-email@her.com,,,,,,,,,0.00,0.00,0.00,FALSE,none,207BCBBF78E85CF174C87AE286B472D2,,,,,,,,,,,,,XXXX1111,Visa,,,,,,,,,,,,,,,,"\n' +
        '    ],\n' +
        '    "messages": {\n' +
        '        "resultCode": "Ok",\n' +
        '        "message": [\n' +
        '            {\n' +
        '                "code": "I00001",\n' +
        '                "text": "Successful."\n' +
        '            }\n' +
        '        ]\n' +
        '    }\n' +
        '}';

    private static String CREATE_CUSTOMER_PAYMENT_PROFILE_RESPONSE = '{\n' +
        '  "customerProfileId": "190178",\n' +
        '  "customerPaymentProfileId": "157497",\n' +
        '  "messages": {\n' +
        '    "resultCode": "Ok",\n' +
        '    "message": [\n' +
        '      {\n' +
        '        "code": "I00001",\n' +
        '        "text": "Successful."\n' +
        '      }\n' +
        '    ]\n' +
        '  }\n' +
        '}';

    private static String UPDATE_CUSTOMER_PAYMENT_PROFILE_RESPONSE = '{\n' +
        '  "validationDirectResponseList": [\n' +
        '        "1,1,1,(TESTMODE) This transaction has been approved.,000000,P,0,none,Test transaction for ValidateCustomerPaymentProfile.,1.00,CC,auth_only,Merchant_Customer_ID,,,,,,,,,,,customer-profile-email@her.com,,,,,,,,,0.00,0.00,0.00,FALSE,none,207BCBBF78E85CF174C87AE286B472D2,,,,,,,,,,,,,XXXX1111,Visa,,,,,,,,,,,,,,,,"\n' +
        '    ],\n' +
        '  "messages": {\n' +
        '    "resultCode": "Ok",\n' +
        '    "message": [{\n' +
        '        "code": "I00001",\n' +
        '        "text": "Successful."\n' +
        '      }\n' +
        '    ]\n' +
        '  }\n' +
        '}';

    private static String GET_CUSTOMER_PROFILE_RESPONSE = '{\n' +
        '    "profile": {\n' +
        '        "paymentProfiles": [\n' +
        '            {\n' +
        '                "defaultPaymentProfile": true,\n' +
        '                "customerPaymentProfileId": "157497",\n' +
        '                "payment": {\n' +
        '                    "creditCard": {\n' +
        '                        "cardNumber": "XXXX1111",\n' +
        '                        "expirationDate": "02-20",\n' +
        '                        "cardType": "Visa",\n' +
        '                        "issuerNumber": "411111",\n' +
        '                        "isPaymentToken": true\n' +
        '                    }\n' +
        '                },\n' +
        '                "customerType": "individual",\n' +
        '                "billTo": {\n' +
        '                    "firstName": "John",\n' +
        '                    "lastName": "Smith"\n' +
        '                }\n' +
        '            },\n' +
        '            {\n' +
        '                "defaultPaymentProfile": true,\n' +
        '                "customerPaymentProfileId": "157497",\n' +
        '                "payment": {\n' +
        '                    "bankAccount": {\n' +
        '                        "routingNumber": "XXXX1111",\n' +
        '                        "accountNumber": "02-20",\n' +
        '                        "nameOnAccount": "Visa",\n' +
        '                        "bankName": "411111",\n' +
        '                        "isPaymentToken": true\n' +
        '                    }\n' +
        '                },\n' +
        '                "customerType": "individual",\n' +
        '                "billTo": {\n' +
        '                    "firstName": "John",\n' +
        '                    "lastName": "Smith"\n' +
        '                }\n' +
        '            }\n' +
        '        ],\n' +
        '        "customerProfileId": "190178",\n' +
        '        "merchantCustomerId": "CUST001",\n' +
        '        "description": "Profile created by Subscription: 3078153",\n' +
        '        "email": "joe@mail.com"\n' +
        '    },\n' +
        '    "subscriptionIds": [\n' +
        '        "3078153",\n' +
        '        "3078154"\n' +
        '    ],\n' +
        '    "messages": {\n' +
        '        "resultCode": "Ok",\n' +
        '        "message": [\n' +
        '            {\n' +
        '                "code": "I00001",\n' +
        '                "text": "Successful."\n' +
        '            }\n' +
        '        ]\n' +
        '    }\n' +
        '}';

    private static String CREATE_TRANSACTION_RESPONSE = '{\n' +
        '    "messages": {\n' +
        '        "resultCode": "Ok",\n' +
        '        "message": [\n' +
        '            {\n' +
        '                "code": "I00001",\n' +
        '                "text": "Successful."\n' +
        '            }\n' +
        '        ]\n' +
        '    }\n' +
        '}';

    private static String DELETE_CUSTOMER_PAYMENT_PROFILE_RESPONSE = '{\n' +
        '    "transactionResponse": {\n' +
        '        "responseCode": "1",\n' +
        '        "authCode": "2768NO",\n' +
        '        "avsResultCode": "Y",\n' +
        '        "cvvResultCode": "P",\n' +
        '        "cavvResultCode": "2",\n' +
        '        "transId": "60006537898",\n' +
        '        "refTransID": "",\n' +
        '        "transHash": "B3BDC21A6B341938D8F1927492F4D516",\n' +
        '        "accountNumber": "XXXX0005",\n' +
        '        "accountType": "AmericanExpress",\n' +
        '        "messages": [\n' +
        '            {\n' +
        '                "code": "1",\n' +
        '                "description": "This transaction has been approved."\n' +
        '            }\n' +
        '        ],\n' +
        '        "transHashSha2": ""\n' +
        '    },\n' +
        '    "refId": "123456",\n' +
        '    "messages": {\n' +
        '        "resultCode": "Ok",\n' +
        '        "message": [\n' +
        '            {\n' +
        '                "code": "I00001",\n' +
        '                "text": "Successful."\n' +
        '            }\n' +
        '        ]\n' +
        '    }\n' +
        '}';
}