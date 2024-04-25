@IsTest
private class B2BHttpUtilsTest {

    @IsTest
    private static void testEmptyConstructor() {
        B2BHttpUtils util = new B2BHttpUtils(null);
        Integer statusCode = util.statusCode;
        String status = util.status;

        System.assertEquals(util.requestContentType, null);
        System.assertEquals(util.endpoint, null);
        System.assertEquals(util.body, null);
        System.assertEquals(util.method, B2BHttpUtils.REQUEST_TYPE.GET);
        System.assertEquals(statusCode, null);
        System.assertEquals(status, null);
    }

    @IsTest
    private static void testException() {
        B2BHttpUtils util = new B2BHttpUtils(null);
        B2BHttpUtilsTestMock testMock = new B2BHttpUtilsTestMock();
        testMock.throwException = true;
        Test.setMock(HttpCalloutMock.class, testMock);
        Test.startTest();
        util.submitRequest();
        Test.stopTest();
        System.assert(util.requestErrors);
    }

    @IsTest
    private static void testFullConstructor() {
        Test.setMock(HttpCalloutMock.class, new B2BHttpUtilsTestMock());
        Test.startTest();
        B2BHttpUtils util = new B2BHttpUtils(null, 'http://test.com', B2BHttpUtils.CONTENT_TYPE.JSON, '{ "userName":"test@test.com”, "password": "password", "firstName":"firstName","lastName":"lastName","email":"email@test.com"}');
        util.addCookie('AuthToken', 'MyAuth');
        util.addQueryParameter('isOrganization', 'true');
        util.setBody('test');
        util.addQueryParameter('param1', 'value1');
        util.addQueryParameter('param2', 'value2');
        util.submitRequest();
        Test.stopTest();
        System.assertEquals(200, util.statusCode);
        System.assertEquals('OK', util.status);
    }

    @IsTest
    private static void testCookie() {
        PageReference pageRef = new PageReference('/');
        Cookie c = new Cookie('testkey', 'testvalue', null, -1, false);
        pageRef.setCookies(new List<Cookie>{
            c
        });

        Test.setCurrentPage(pageRef);
        Test.setMock(HttpCalloutMock.class, new B2BHttpUtilsTestMock());
        Test.startTest();
        B2BHttpUtils util = new B2BHttpUtils(null, 'http://test.com', B2BHttpUtils.CONTENT_TYPE.JSON, '{ "userName":"test@test.com”, "password": "password", "firstName":"firstName","lastName":"lastName","email":"email@test.com"}');
        util.addCookie('AuthToken', 'MyAuth');
        util.addQueryParameter('isOrganization', 'true');
        util.setBody('test');
        util.addQueryParameter('param1', 'value1');
        util.addQueryParameter('param2', 'value2');
        util.submitRequest();
        Test.stopTest();
        System.assertEquals(200, util.statusCode);
        System.assertEquals('OK', util.status);
        System.assertEquals('testvalue', util.getCookieValue('testkey'));
    }

    @IsTest
    private static void testResetState() {
        Test.setMock(HttpCalloutMock.class, new B2BHttpUtilsTestMock());
        Test.startTest();
        B2BHttpUtils util = new B2BHttpUtils(null, 'http://test.com', B2BHttpUtils.CONTENT_TYPE.JSON, '{ "userName":"test@test.com”, "password": "password", "firstName":"firstName","lastName":"lastName","email":"email@test.com"}');
        util.addCookie('AuthToken', 'MyAuth');
        util.addQueryParameter('isOrganization', 'true');
        util.setBody('test');
        util.addQueryParameter('param1', 'value1');
        util.addQueryParameter('param2', 'value2');
        util.submitRequest();
        util.resetState();
        Test.stopTest();

        System.assertEquals(util.requestContentType, null);
        System.assertEquals(util.endpoint, null);
        System.assertEquals(util.body, null);
        System.assertEquals(util.method, null);
        System.assertEquals(util.statusCode, null);
        System.assertEquals(util.status, null);

    }

    public class B2BHttpUtilsTestMock implements HttpCalloutMock {
        public B2BHttpUtilsTestMock() {
            throwException = false;
        }

        public HTTPResponse respond(HttpRequest request) {
            if (throwException) {
                throw new B2BHttpUtils.B2BHttpUtilsException('Test Exception');
            }
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('OK');
            response.setHeader('set-cookie', 'testkey=testvalue');
            return response;
        }

        public Boolean throwException { get; set; }
    }
}