/******************************************************************************************************************************************************

Name                : ProductInsertWebService_test
Author              : Pratik Kakade
Purpose             : This Apex class is designed to test the ProductInsertWebService class, which provides a RESTful web service endpoint for updating Order records in Salesforce.
Description         : The ProductInsertWebService class tests the behavior of the ProductInsertWebService class. 
					  It ensures that the updateOrder method correctly handles various scenarios, such as updating existing orders, handling orders that don't exist, and handling errors.
Version             : 1.1
Change Log          : Created by Pratik Kakade - 15 Jul 2024
Test Class for      : ProductInsertWebService
CreateDate          : 15 Jul 2024
LastModifiedDate    : 15 Jul 2024

******************************************************************************************************************************************************/
@isTest
public class ProductInsertWebService_test {
    
    @istest
    public static void AddProduct_test(){
        String reqBody = '{"ProductCode": "12345", "Vendor_Part_Number__c": "123", "Name": "Test From Postman", "Description": "Test for owner name", "JDE_Stocking_Type__c": "112234", "StockKeepingUnit": "112234", "Quantity_Available__c": "12", "Vendor__c": "123", "Branch_Plant__c": "Equipment","Record_Type_Calculation":"Defense"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RestRequest request = new RestRequest();
        request.requestUri = '/updateOrderInSF';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.request.requestBody = Blob.valueOf(reqBody);
        test.startTest();
        ProductInsertWebService.AddProduct();
        test.stopTest();
    }
    
    @istest
    public static void AddProduct_test01(){
        String reqBody = '{"ProductCode": "12345", "Vendor_Part_Number__c": "123", "Name": "Test From Postman", "Description": "Test for owner name", "JDE_Stocking_Type__c": "112235", "StockKeepingUnit": "112235", "Quantity_Available__c": "12", "Vendor__c": "123", "Branch_Plant__c": "Defense","Record_Type_Calculation":"Defense"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RestRequest request = new RestRequest();
        request.requestUri = '/updateOrderInSF';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.request.requestBody = Blob.valueOf(reqBody);
        test.startTest();
        ProductInsertWebService.AddProduct();
        test.stopTest();
    }
    @istest
    public static void AddProduct_testfailed01(){
        Product2 pr = Utility_DataCreation.CreteProducts(1)[0];
        pr.StockKeepingUnit = '112236';
        insert pr;
        String reqBody = '{"ProductCode": "12345", "Vendor_Part_Number__c": "123", "Name": "Test From Postman", "Description": "Test for owner name", "JDE_Stocking_Type__c": "112236", "StockKeepingUnit": "112236", "Quantity_Available__c": "12", "Vendor__c": "123", "Branch_Plant__c": "Pump"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RestRequest request = new RestRequest();
        request.requestUri = '/updateOrderInSF';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.request.requestBody = Blob.valueOf(reqBody);
        test.startTest();
        ProductInsertWebService.AddProduct();
        test.stopTest();
    }
    @istest
    public static void AddProduct_testfailed02(){
        String reqBody = '';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RestRequest request = new RestRequest();
        request.requestUri = '/updateOrderInSF';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.request.requestBody = Blob.valueOf(reqBody);
        test.startTest();
        ProductInsertWebService.AddProduct();
        test.stopTest();
    }
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"success": true}');
            response.setStatusCode(200);
            return response;
        }
    }
}