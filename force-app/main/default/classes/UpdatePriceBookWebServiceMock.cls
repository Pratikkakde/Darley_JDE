@isTest
Global class UpdatePriceBookWebServiceMock implements HttpCalloutMock {
  
        Global static HttpResponse respond(HttpRequest request) {
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"success": true}');
            response.setStatusCode(200);
            return response;
        }  
    }