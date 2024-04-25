@IsTest
public class B2BHttpLogServiceTest {
    
    @IsTest
    public static void addLogTest() {
        Rest_Log__c log = new Rest_Log__c();
        log.URL__c = 'https://www.google.com';
        B2BHttpLogService.addLog(log);
    }
    
    @IsTest
    public static void createLogTest() {
        B2BHttpLogServiceTestMock testMock = new B2BHttpLogServiceTestMock();
        Test.setMock(HttpCalloutMock.class, testMock);
        
        Account acc = new Account (Name = 'test');
        insert acc;
        
        Order ord = new Order();
        ord.EffectiveDate = Date.today();
        ord.status = 'Draft';
        ord.accountId = acc.Id;
        insert ord;
        
        Rest_Log__c restLog = B2BHttpLogService.createLog(ord.Id);
        
        Contact cont = new Contact(LastName = 'Test');
        insert cont;
        Rest_Log__c restLog1 = B2BHttpLogService.createLog(cont.Id);
        
    }
    
    @IsTest
    public static void createLogTest2() {
        B2BHttpLogServiceTestMock testMock = new B2BHttpLogServiceTestMock();
        Test.setMock(HttpCalloutMock.class, testMock);
        
        Account acc = new Account (Name = 'test');
        insert acc;
        
        Order ord = new Order();
        ord.EffectiveDate = Date.today();
        ord.status = 'Draft';
        ord.accountId = acc.Id;
        insert ord;
        
        Contact cont = new Contact(LastName = 'Test');
        insert cont;
        
        HttpResponse response = new HttpResponse();
        HttpRequest request = new HttpRequest();
        
        Rest_Log__c restLog = B2BHttpLogService.createLog(ord.Id, response, request);
        Rest_Log__c restLog1 = B2BHttpLogService.createLog(cont.Id, response, request);
        B2BHttpLogService.saveLogs();
        
    }
    
    public class B2BHttpLogServiceTestMock implements HttpCalloutMock {
        public B2BHttpLogServiceTestMock() {
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