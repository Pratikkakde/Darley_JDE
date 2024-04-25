@IsTest
public class B2BAvalaraTest {

    public static final String AVALARA_TOKEN_TEST_ENDPOINT = 'https//avalata.com/test/token';
    public static final String AVALARA_COMPANY_TEST_ENDPOINT = 'https//avalata.com/test/companies';

    @TestSetup
    private static void makeData() {
        new B2BDefaultTestData().initAllData();

        WebCart webCart = [SELECT Id FROM WebCart LIMIT 1];
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];

        ContactPointAddress address = new ContactPointAddress(
            AddressType = 'Billing',
            Name = 'Billing Address',
            ParentId = communityUser.AccountId,
            IsDefault = false,
            Country = 'United States',
            State = 'Texas',
            City = 'Austin',
            Street = 'Test Address',
            PostalCode = '73301'
        );
        insert address;

        update new WebCart(
            Id = webCart.Id,
            B2BCheckoutShippingAddress__c = address.Id
        );
    }

    @IsTest
    private static void calculateCartTaxTest() {
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        WebCart webCart = [SELECT Id FROM WebCart LIMIT 1];
        List<CartItem> cartItems = [SELECT Id FROM CartItem WHERE CartId = :webCart.Id];

        System.runAs(communityUser) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new B2BAvalaraMock(false, cartItems));

            B2BAvalara avalara = new B2BAvalara();
            avalara.calculateTax(webCart.Id);

            System.assertNotEquals(
                [SELECT Id, AvalaraTaxRequestBody__c FROM WebCart WHERE Id = :webCart.Id LIMIT 1].AvalaraTaxRequestBody__c,
                null,
                'Response value should be added to Web Cart record.'
            );

            Test.stopTest();
        }
    }

    @IsTest
    private static void calculateCartTaxWithError() {
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        WebCart webCart = [SELECT Id FROM WebCart LIMIT 1];

        System.runAs(communityUser) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new B2BAvalaraMock(true, null));

            B2BAvalara avalara = new B2BAvalara();
            try {
                avalara.calculateTax(webCart.Id);
                System.assert(false, 'Tax calculation should be failed.');
            } catch(Exception ex) {
                System.assertEquals('The address value was incomplete.', ex.getMessage(), 'Error message is not correct.');
            }

            Test.stopTest();
        }
    }

    @IsTest
    private static void sendRequestAsCommitted() {
        WebCart webCart = [SELECT Id, AvalaraTaxRequestBody__c FROM WebCart LIMIT 1];
        String avaTaxRequest = '{"type":"SalesOrder","lines":[{"taxCode":null,"quantity":"10","number":"0a919000000AnjSAAS","description":"Test Product","amount":null}],"date":"10/28/2021","customerCode":"testCustomerAccount","companyCode":"Comp Code","commit":false,"addresses":{"shipTo":{"region":"Illinois","postalCode":"606060","line1":"mail street","country":"United States","city":"Chicago"}}}';
        webCart.AvalaraTaxRequestBody__c = avaTaxRequest;
        update webCart;

        List<CartItem> cartItems = [SELECT Id FROM CartItem WHERE CartId = :webCart.Id];
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];

        System.runAs(communityUser) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new B2BAvalaraMock(false, cartItems));

            B2BAvalara avalara = new B2BAvalara();
            List<B2BAvalaraWrapper.Response> responses = avalara.sendCommittedRequest(webCart.Id);
            System.assertEquals(responses.size(), 1, 'Response value should be exist.');

            Test.stopTest();
        }
    }

    @IsTest
    private static void sendRequestAsCommittedWithError() {
        WebCart webCart = [SELECT Id, AvalaraTaxRequestBody__c FROM WebCart LIMIT 1];
        String avaTaxRequest = '{"type":"SalesOrder","lines":[{"taxCode":null,"quantity":"10","number":"0a919000000AnjSAAS","description":"Test Product","amount":null}],"date":"10/28/2021","customerCode":"testCustomerAccount","companyCode":"Comp Code","commit":false,"addresses":{"shipTo":{"region":"Illinois","postalCode":"606060","line1":"mail street","country":"United States","city":"Chicago"}}}';
        webCart.AvalaraTaxRequestBody__c = avaTaxRequest;
        update webCart;

        List<CartItem> cartItems = [SELECT Id FROM CartItem WHERE CartId = :webCart.Id];
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];

        System.runAs(communityUser) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new B2BAvalaraMock(true, cartItems));

            B2BAvalara avalara = new B2BAvalara();
            try {
                avalara.calculateTax(webCart.Id);
                System.assert(false, 'Tax calculation should be failed.');
            } catch(Exception ex) {
                System.assertEquals('The address value was incomplete.', ex.getMessage(), 'Error message is not correct.');
            }

            Test.stopTest();
        }
    }

    public class B2BAvalaraMock implements HttpCalloutMock {
        public Boolean failCall { get; set; }
        public List<CartItem> cartItems { get; set; }

        public String failResponse = '{"error": {"target": "IncorrectData", "message": "The address value was incomplete.", "code": "InvalidAddress"}}';

        public B2BAvalaraMock(Boolean failCall , List<CartItem> cartItems) {
            this.failCall = failCall;
            this.cartItems = cartItems;
        }

        public HTTPResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();

            if (failCall) {
                response.setStatusCode(400);
                response.setStatus('Bad Request');
                response.setBody(failResponse);
            } else {
                response.setStatusCode(200);
                response.setStatus('OK');
                response.setHeader('set-cookie', 'testkey=testvalue');
                response.setBody(getSuccessResponse(cartItems));
            }

            return response;
        }

        private String getSuccessResponse(List<CartItem> cartItems) {
            String successResponse = '{"totalTax": 2557.5, "lines": [linesToReplace]}';
            List<String> lineItems = new List<String>();

            if (cartItems != null) {
                for (CartItem cartItem : cartItems) {
                    String item = '{"details": [{"taxableAmount": 18000.0, "rate": 0.06, "jurisType": "STA", "jurisdictionType": "State", "tax": 1080.0, "jurisName": "CALIFORNIA", "taxCalculated": 1080.0, "taxName": "CA STATE TAX", "taxType": "Sales"}], "tax": 1395.0, "lineNumber": "' + cartItem.Id +'"}';
                    lineItems.add(item);
                }
            } else {
                String item = '{"id":74000002566846,"transactionId":80000001120836,"lineNumber":"a2k19000000qnAaAAI","description":"Altify: Dealmaker Enterprise Licenses","destinationAddressId":67000001757587,"originAddressId":67000001757587,"discountAmount":0.0,"discountTypeId":0,"exemptAmount":1120.0,"exemptCertId":0,"isItemTaxable":false,"isSSTP":false,"lineAmount":1120.0,"quantity":2.00,"ref1":"","ref2":"","reportingDate":"2021-10-24","revAccount":"","sourcing":"Destination","tax":0.0000,"taxableAmount":0.0,"taxCalculated":0.0000,"taxCode":"SW054005","taxCodeId":91765,"taxDate":"2021-10-24","taxEngine":"","taxOverrideType":"None","businessIdentificationNo":"","taxOverrideAmount":0.0,"taxOverrideReason":"","taxIncluded":false,"details":[{"id":61000006588683,"transactionLineId":74000002566846,"transactionId":80000001120836,"addressId":67000001757587,"country":"US","region":"CA","countyFIPS":"","stateFIPS":"","exemptAmount":0.0000,"exemptReasonId":5,"inState":true,"jurisCode":"06","jurisName":"CALIFORNIA","jurisdictionId":5000531,"signatureCode":"AGAM","stateAssignedNo":"","jurisType":"STA","jurisdictionType":"State","nonTaxableAmount":1120.0000,"nonTaxableRuleId":4137162,"nonTaxableType":"ProductTaxabilityRule","rate":0.060000,"rateRuleId":1782860,"rateSourceId":3,"serCode":"","sourcing":"Destination","tax":0.0000,"taxableAmount":0.0000,"taxType":"Sales","taxSubTypeId":"S","taxTypeGroupId":"SalesAndUse","taxName":"CA STATE TAX","taxAuthorityTypeId":45,"taxRegionId":4024330,"taxCalculated":0.0000,"taxOverride":0.0000,"rateType":"General","rateTypeCode":"G","taxableUnits":0.0000,"nonTaxableUnits":1120.0000,"exemptUnits":0.0000,"unitOfBasis":"PerCurrencyUnit","isNonPassThru":false,"isFee":false,"reportingTaxableUnits":0.0,"reportingNonTaxableUnits":1120.0,"reportingExemptUnits":0.0,"reportingTax":0.0,"reportingTaxCalculated":0.0,"liabilityType":"Seller"},{"id":62000006588683,"transactionLineId":74000002566846,"transactionId":80000001120836,"addressId":67000001757587,"country":"US","region":"CA","countyFIPS":"","stateFIPS":"","exemptAmount":0.0000,"exemptReasonId":5,"inState":true,"jurisCode":"075","jurisName":"SAN FRANCISCO","jurisdictionId":275,"signatureCode":"AIUQ","stateAssignedNo":"","jurisType":"CTY","jurisdictionType":"County","nonTaxableAmount":1120.0000,"nonTaxableRuleId":4137162,"nonTaxableType":"ProductTaxabilityRule","rate":0.002500,"rateRuleId":1782858,"rateSourceId":3,"serCode":"","sourcing":"Destination","tax":0.0000,"taxableAmount":0.0000,"taxType":"Sales","taxSubTypeId":"S","taxTypeGroupId":"SalesAndUse","taxName":"CA COUNTY TAX","taxAuthorityTypeId":45,"taxRegionId":4024330,"taxCalculated":0.0000,"taxOverride":0.0000,"rateType":"General","rateTypeCode":"G","taxableUnits":0.0000,"nonTaxableUnits":1120.0000,"exemptUnits":0.0000,"unitOfBasis":"PerCurrencyUnit","isNonPassThru":false,"isFee":false,"reportingTaxableUnits":0.0,"reportingNonTaxableUnits":1120.0,"reportingExemptUnits":0.0,"reportingTax":0.0,"reportingTaxCalculated":0.0,"liabilityType":"Seller"},{"id":63000006588683,"transactionLineId":74000002566846,"transactionId":80000001120836,"addressId":67000001757587,"country":"US","region":"CA","countyFIPS":"","stateFIPS":"","exemptAmount":0.0000,"exemptReasonId":5,"inState":true,"jurisCode":"EMBE0","jurisName":"SAN FRANCISCO COUNTY DISTRICT TAX SP","jurisdictionId":2001061430,"signatureCode":"EMBE","stateAssignedNo":"940","jurisType":"STJ","jurisdictionType":"Special","nonTaxableAmount":1120.0000,"nonTaxableRuleId":4137162,"nonTaxableType":"ProductTaxabilityRule","rate":0.013750,"rateRuleId":2443104,"rateSourceId":3,"serCode":"","sourcing":"Destination","tax":0.0000,"taxableAmount":0.0000,"taxType":"Sales","taxSubTypeId":"S","taxTypeGroupId":"SalesAndUse","taxName":"CA SPECIAL TAX","taxAuthorityTypeId":45,"taxRegionId":4024330,"taxCalculated":0.0000,"taxOverride":0.0000,"rateType":"General","rateTypeCode":"G","taxableUnits":0.0000,"nonTaxableUnits":1120.0000,"exemptUnits":0.0000,"unitOfBasis":"PerCurrencyUnit","isNonPassThru":false,"isFee":false,"reportingTaxableUnits":0.0,"reportingNonTaxableUnits":1120.0,"reportingExemptUnits":0.0,"reportingTax":0.0,"reportingTaxCalculated":0.0,"liabilityType":"Seller"},{"id":64000006588683,"transactionLineId":74000002566846,"transactionId":80000001120836,"addressId":67000001757587,"country":"US","region":"CA","countyFIPS":"","stateFIPS":"","exemptAmount":0.0000,"exemptReasonId":5,"inState":true,"jurisCode":"EMTV0","jurisName":"SAN FRANCISCO CO LOCAL TAX SL","jurisdictionId":2001061792,"signatureCode":"EMTV","stateAssignedNo":"38","jurisType":"STJ","jurisdictionType":"Special","nonTaxableAmount":1120.0000,"nonTaxableRuleId":4137162,"nonTaxableType":"ProductTaxabilityRule","rate":0.010000,"rateRuleId":1782856,"rateSourceId":3,"serCode":"","sourcing":"Destination","tax":0.0000,"taxableAmount":0.0000,"taxType":"Sales","taxSubTypeId":"S","taxTypeGroupId":"SalesAndUse","taxName":"CA SPECIAL TAX","taxAuthorityTypeId":45,"taxRegionId":4024330,"taxCalculated":0.0000,"taxOverride":0.0000,"rateType":"General","rateTypeCode":"G","taxableUnits":0.0000,"nonTaxableUnits":1120.0000,"exemptUnits":0.0000,"unitOfBasis":"PerCurrencyUnit","isNonPassThru":false,"isFee":false,"reportingTaxableUnits":0.0,"reportingNonTaxableUnits":1120.0,"reportingExemptUnits":0.0,"reportingTax":0.0,"reportingTaxCalculated":0.0,"liabilityType":"Seller"}],"nonPassthroughDetails":[],"lineLocationTypes":[{"documentLineLocationTypeId":82000006878416,"documentLineId":74000002566846,"documentAddressId":67000001757587,"locationTypeCode":"ShipTo"}],"hsCode":"","costInsuranceFreight":0.0,"vatCode":"","vatNumberTypeId":0}],"addresses":[{"id":67000001757587,"transactionId":80000001120836,"boundaryLevel":"Address","line1":"12 Main St","line2":"","line3":"","city":"San Francisco","region":"CA","postalCode":"94105","country":"US","taxRegionId":4024330,"latitude":"37.79276","longitude":"-122.396229"}],"locationTypes":[{"documentLocationTypeId":64000002274932,"documentId":80000001120836,"documentAddressId":67000001757587,"locationTypeCode":"ShipTo"}],"summary":[{"country":"US","region":"CA","jurisType":"State","jurisCode":"06","jurisName":"CALIFORNIA","taxAuthorityType":45,"stateAssignedNo":"","taxType":"Sales","taxSubType":"S","taxName":"CA STATE TAX","rateType":"General","taxable":0.00,"rate":0.060000,"tax":0.00,"taxCalculated":0.00,"nonTaxable":1120.00,"exemption":0.00},{"country":"US","region":"CA","jurisType":"County","jurisCode":"075","jurisName":"SAN FRANCISCO","taxAuthorityType":45,"stateAssignedNo":"","taxType":"Sales","taxSubType":"S","taxName":"CA COUNTY TAX","rateType":"General","taxable":0.00,"rate":0.002500,"tax":0.00,"taxCalculated":0.00,"nonTaxable":1120.00,"exemption":0.00},{"country":"US","region":"CA","jurisType":"Special","jurisCode":"EMTV0","jurisName":"SAN FRANCISCO CO LOCAL TAX SL","taxAuthorityType":45,"stateAssignedNo":"38","taxType":"Sales","taxSubType":"S","taxName":"CA SPECIAL TAX","rateType":"General","taxable":0.00,"rate":0.010000,"tax":0.00,"taxCalculated":0.00,"nonTaxable":1120.00,"exemption":0.00},{"country":"US","region":"CA","jurisType":"Special","jurisCode":"EMBE0","jurisName":"SAN FRANCISCO COUNTY DISTRICT TAX SP","taxAuthorityType":45,"stateAssignedNo":"940","taxType":"Sales","taxSubType":"S","taxName":"CA SPECIAL TAX","rateType":"General","taxable":0.00,"rate":0.013750,"tax":0.00,"taxCalculated":0.00,"nonTaxable":1120.00,"exemption":0.00}';
                lineItems.add(item);
            }

            return successResponse.replace('linesToReplace', String.join(lineItems, ','));
        }
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        Integer responseStatusCode;
        String responseBody;
        Map<String, String> responseBodies;

        public MockHttpResponseGenerator(Integer responseStatusCode, Map<String, String> responseBodies) {
            this.responseStatusCode = responseStatusCode;
            this.responseBodies = responseBodies;
        }

        public MockHttpResponseGenerator(Integer responseStatusCode, String responseBody) {
            this.responseStatusCode = responseStatusCode;
            this.responseBody = responseBody;
        }

        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-type', 'application/json');
            response.setStatusCode(responseStatusCode);
            String body = responseBody;
            if(responseBodies != null && responseBodies.size() > 0) {
                for(String endpoint : responseBodies.keySet()) {
                    if(request.getEndpoint().contains(endpoint)) {
                        body = responseBodies.get(endpoint);
                    }
                }
            }
            response.setBody(body);
            return response;
        }
    }

}