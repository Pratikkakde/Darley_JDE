public with sharing class B2BCalloutAsanaTaskCreationTest {
    
    public class B2BAsanaTaskMock implements HttpCalloutMock {
        public Boolean failCall { get; set; }

        public B2BAsanaTaskMock(Boolean failCall) {
            this.failCall = failCall;
        }

        public HTTPResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            if (failCall) {
                response.setStatusCode(400);
                response.setStatus('Bad Request');
            } else {
                response.setStatusCode(201);
                response.setStatus('Created');
                response.setBody('{"data":{"gid":"1205873277839659"}}');
            }
            return response;
        }
    }
}