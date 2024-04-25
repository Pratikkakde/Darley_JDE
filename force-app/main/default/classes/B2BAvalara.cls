public without sharing class B2BAvalara {

    private B2BAvalaraConfiguration configuration;

    public B2BAvalara() {
        this.configuration = B2BAvalaraConfiguration.getInstance();
    }

    public B2BAvalaraWrapper.Response calculateTax(Id webCartId) {
//        B2BAvalaraWrapper.Request requestBody = B2BAvalaraService.getWebCartRequestData(webCartId, configuration.companyCode);
        B2BAvalaraWrapper.Request requestBody;

        if (webCartId.getSobjectType() == WebCart.SObjectType) {
            requestBody = B2BAvalaraService.getWebCartRequestData(webCartId, configuration.companyCode);
        } else {
            /* Used for Subscription functionality, Comment the part for Core functionality OR Uncomment the part for Subscription*/
//            requestBody = B2BSubscriptionAvalaraTaxService.getSubscriptionRequestData(webCartId, configuration.companyCode);
        }

        if (requestBody == null) {
            return null;
        }

        B2BHttpUtils request = new B2BHttpUtils(webCartId, configuration.endpoint, B2BHttpUtils.CONTENT_TYPE.JSON, System.JSON.serialize(requestBody).replaceAll('_x', ''));
        addAuthorization(request);
        request.method = B2BHttpUtils.REQUEST_TYPE.POST;

        HttpResponse response = request.submitRequest();

        if (request.requestErrors) {
            throw new B2BAvalaraException(request.requestException.getMessage());
        }

        if (response.getBody() == '' && response.getStatusCode() == 404) {
            throw new B2BAvalaraException('Response body is empty. Please check you Avalara configuration settings.');
        }

        B2BAvalaraWrapper.Response parsedResponse = B2BAvalaraService.parseResponse(response.getBody());

        if (parsedResponse.error != null) {
            throw new B2BAvalaraException(parsedResponse.error.message);
        }

        if (webCartId.getSobjectType() == WebCart.SObjectType) {
            update new WebCart(
                Id = webCartId,
                AvalaraTaxRequestBody__c = System.JSON.serialize(requestBody).replaceAll('_x', '')
            );
        }

        return parsedResponse;
    }

    public List<B2BAvalaraWrapper.Response> sendCommittedRequest(Id webCartId) {
        WebCart updatedCart = [
            SELECT Id, AvalaraTaxRequestBody__c
            FROM WebCart
            WHERE Id = :webCartId
        ];

        List<B2BAvalaraWrapper.Response> responses = new List<B2BAvalaraWrapper.Response>();
        responses.add(sendRequest(webCartId, updatedCart.AvalaraTaxRequestBody__c));

        return responses;
    }

    public String getEcommerceToken(String avalaraCustomerCode) {
        Integer companyId = getCompanyId();
        String urlEndPoint = Test.isRunningTest() ? B2BAvalaraTest.AVALARA_TOKEN_TEST_ENDPOINT :  this.configuration.requestURI + 'companies/' + companyId + '/ecommercetokens';

        Map<String, String> requestBody = new Map<String, String> {
            'customerNumber' => avalaraCustomerCode
        };

        B2BHttpUtils request = new B2BHttpUtils(null, urlEndPoint, B2BHttpUtils.CONTENT_TYPE.JSON, System.JSON.serialize(requestBody));
        addAuthorization(request);
        request.method = B2BHttpUtils.REQUEST_TYPE.POST;

        HttpResponse response = request.submitRequest();
        String bodyJson = response.getBody();
        Map<String, String> responseBody = (Map<String, String>)JSON.deserialize(bodyJson, Map<String, String>.class);
        return responseBody.get('token');
    }
    

    public Integer getCompanyId() {
        String urlEndPoint = Test.isRunningTest() ? B2BAvalaraTest.AVALARA_COMPANY_TEST_ENDPOINT : this.configuration.requestURI + 'companies?filter=isDefault+eq+true';
        B2BHttpUtils request = new B2BHttpUtils(null, urlEndPoint, B2BHttpUtils.CONTENT_TYPE.JSON, null);
        addAuthorization(request);
        request.method = B2BHttpUtils.REQUEST_TYPE.GET;
        
        HttpResponse response = request.submitRequest();

        if (request.requestErrors) {
            throw new B2BAvalaraException(request.requestException.getMessage());
        }
        B2BAvalaraWrapper.ResponseCompanies companiesResponse = B2BAvalaraService.parseCompaniesResponse(response.getBody());
        List<B2BAvalaraWrapper.Company> companies = companiesResponse.value;

        return !companies.isEmpty() ? companies[0].id : null;
    }

    private B2BAvalaraWrapper.Response sendRequest(Id webCartId, String requestBody) {
        String updatedBody = requestBody.replace('"type":"SalesOrder"', '"type":"SalesInvoice"');
        updatedBody = updatedBody.replace('"commit":false', '"commit":true');

        B2BHttpUtils request = new B2BHttpUtils(webCartId, this.configuration.endpoint, B2BHttpUtils.CONTENT_TYPE.JSON, updatedBody);
        addAuthorization(request);
        request.method = B2BHttpUtils.REQUEST_TYPE.POST;

        HttpResponse response = request.submitRequest();

        if (request.requestErrors) {
            throw new B2BAvalaraException(request.requestException.getMessage());
        }

        B2BAvalaraWrapper.Response parsedResponse = B2BAvalaraService.parseResponse(response.getBody());

        if (parsedResponse.error != null) {
            throw new B2BAvalaraException(parsedResponse.error.message);
        }

        return parsedResponse;
    }

    private void addAuthorization(B2BHttpUtils request) {
        if (this.configuration.accountId != null && this.configuration.licenseKey != null) {
            request.addBasicAuthorization(this.configuration.accountId, this.configuration.licenseKey);
        } else {
            throw new B2BAvalaraException('There`s no Avalara\'s credentials for Authorization');
        }
    }

    public class B2BAvalaraException extends Exception {}

}