global class MockHttpCalloutGenerator implements HttpCalloutMock {
        private String responseBody;
        private String expectedEndpoint;
        private Integer statusCode;
        
        public MockHttpCalloutGenerator(String responseBody, String expectedEndpoint, Integer statusCode) {
            this.responseBody = responseBody;
            this.expectedEndpoint = expectedEndpoint;
            this.statusCode = statusCode;
        }
        
        global HTTPResponse respond(HTTPRequest req) {
            // Verify the endpoint
            //System.assertEquals(expectedEndpoint, req.getEndpoint());
            
            // Create a mock response
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            
            return res;
        }
    }