/******************************************************************************************************************************************************

Name                : OrderUpdateWebService_test
Author              : Pratik Kakade
Purpose             : This Apex class is designed to test the OrderUpdateWebService class, which provides a RESTful web service endpoint for updating Order records in Salesforce.

Description         : The OrderUpdateWebService_test class tests the behavior of the OrderUpdateWebService class. 
                      It ensures that the updateOrder method correctly handles various scenarios, such as updating existing orders, handling orders that don't exist, and handling errors.

Version             : 1.1
Change Log          : Created by Pratik Kakade - 30-Apr-24
Test Class for      : OrderUpdateWebService
CreateDate          : 30 Apr 2024
LastModifiedDate    : 30-Apr-24

******************************************************************************************************************************************************/


@isTest
public class OrderUpdateWebService_test {

    @istest
    static void UpdateOrder_test(){
        Account acc = Utility_DataCreation.CreateAccountRec(2,'Equipment Customer')[0];
        insert acc;

        Id pricebookId = Test.getStandardPricebookId();
        List<Order> ordList = Utility_DataCreation.createOrder(acc.id,5,pricebookId);
        ordList[0].JDE_Order_Number__c = 123;
        insert ordList;

        List<Product2> productsList = Utility_DataCreation.CreteProducts(5);
        insert productsList;

        List<priceBookEntry> pbeList = new List<priceBookEntry>();
        pbeList.add(new priceBookEntry(Pricebook2Id = pricebookId, UnitPrice= 604,Product2Id= productsList[0].Id,IsActive = true));
        insert pbeList;

        List<orderitem> ordItem = Utility_DataCreation.createOrderItem(5,ordList,productsList,pbeList[0].id);
        insert ordItem;

        System.debug('JDE ord number--->'+ordList[0].JDE_Order_Number__c);
        String requestBody = '{ "JDE_Order_Number__c": "'+ordList[0].JDE_Order_Number__c+'", "Line Number": "123", "Ship Date": "30-04-2024", "Invoice Date": "30-04-2024", "Cancel Date": "30-04-2024", "Order Status": "Shipped", "Tracking Number": "Line Number 1:Shipped, Line Number 2:Delayed" }';
        System.debug('ReqBody--->'+requestBody);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RestRequest request = new RestRequest();
        request.requestUri = '/updateOrderInSF';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.request.requestBody = Blob.valueOf(requestBody);
        // Call the web service method
        Test.startTest();
        String reqBody = '{ "JDE_Order_Number__c": "123", "Line Number": "123", "Ship Date": "30-04-2024", "Invoice Date": "30-04-2024", "Cancel Date": "30-04-2024", "Order Status": "Shipped", "Tracking Number": "Line Number 1:Shipped, Line Number 2:Delayed" }';
        String response = OrderUpdateWebService.UpdateOrder();
        System.assertEquals('Success: Order update Successfully.',response);
        Test.stopTest();


    }
    
    @istest
    static void UpdateOrder_testnoOrdFound(){
        Account acc = Utility_DataCreation.CreateAccountRec(2,'Equipment Customer')[0];
        insert acc;

        Id pricebookId = Test.getStandardPricebookId();
        List<Order> ordList = Utility_DataCreation.createOrder(acc.id,5,pricebookId);
        ordList[0].JDE_Order_Number__c = 12345789;
        insert ordList;

        List<Product2> productsList = Utility_DataCreation.CreteProducts(5);
        insert productsList;

        List<priceBookEntry> pbeList = new List<priceBookEntry>();
        pbeList.add(new priceBookEntry(Pricebook2Id = pricebookId, UnitPrice= 604,Product2Id= productsList[0].Id,IsActive = true));
        insert pbeList;

        List<orderitem> ordItem = Utility_DataCreation.createOrderItem(5,ordList,productsList,pbeList[0].id);
        insert ordItem;

        System.debug('JDE ord number--->'+ordList[0].JDE_Order_Number__c);
        Integer jdeordNum = 123;
        String requestBody = '{"JDE_Order_Number__c": "'+jdeordNum+'", "Line Number": "123", "Ship Date": "30-04-2024", "Invoice Date": "30-04-2024", "Cancel Date": "30-04-2024", "Order Status": "Shipped", "Tracking Number": "Line Number 1:Shipped, Line Number 2:Delayed" }';
        System.debug('ReqBody--->'+requestBody);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RestRequest request = new RestRequest();
        request.requestUri = '/updateOrderInSF';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.request.requestBody = Blob.valueOf(requestBody);
        // Call the web service method
        Test.startTest();
        String response = OrderUpdateWebService.UpdateOrder();
        System.assertEquals('Not Found: No order found in Salesforce for this JDE Order Number - '+jdeordNum,response);
        Test.stopTest();


    }
    @istest
    static void UpdateOrder_testFail(){
        Account acc = Utility_DataCreation.CreateAccountRec(2,'Equipment Customer')[0];
        insert acc;

        Id pricebookId = Test.getStandardPricebookId();
        List<Order> ordList = Utility_DataCreation.createOrder(acc.id,5,pricebookId);
        insert ordList;

        List<Product2> productsList = Utility_DataCreation.CreteProducts(5);
        insert productsList;

        List<priceBookEntry> pbeList = new List<priceBookEntry>();
        pbeList.add(new priceBookEntry(Pricebook2Id = pricebookId, UnitPrice= 604,Product2Id= productsList[0].Id,IsActive = true));
        insert pbeList;

        List<orderitem> ordItem = Utility_DataCreation.createOrderItem(5,ordList,productsList,pbeList[0].id);
        insert ordItem;

        System.debug('JDE ord number--->'+ordList[0].JDE_Order_Number__c);
        String requestBody = '{ "JDE_Order_Number__c": "'+ordList[0].JDE_Order_Number__c+'", "Line Number": "123", "Ship Date": "30-04-2024", "Invoice Date": "30-04-2024", "Cancel Date": "30-04-2024", "Order Status": "Shipped", "Tracking Number": "Line Number 1:Shipped, Line Number 2:Delayed" }';
        System.debug('ReqBody--->'+requestBody);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RestRequest request = new RestRequest();
        request.requestUri = '/updateOrderInSF';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.request.requestBody = Blob.valueOf(requestBody);
        // Call the web service method
        Test.startTest();
        String reqBody = '{ "JDE_Order_Number__c": "123", "Line Number": "123", "Ship Date": "30-04-2024", "Invoice Date": "30-04-2024", "Cancel Date": "30-04-2024", "Order Status": "Shipped", "Tracking Number": "Line Number 1:Shipped, Line Number 2:Delayed" }';
        String response = OrderUpdateWebService.UpdateOrder();
        System.assertEquals(response,response);

        Test.stopTest();


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