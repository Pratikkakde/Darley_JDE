/******************************************************************************************************************************************************

Name                : UpdatePriceBookWebServiceTest
Author              : Pratik Kakade
Purpose             : This Apex class is designed to test the ProductInsertWebService class, which provides a RESTful web service endpoint for updating Order records in Salesforce.
Description         : The ProductInsertWebService class tests the behavior of the ProductInsertWebService class. 
					  It ensures that the updateOrder method correctly handles various scenarios, such as updating existing orders, handling orders that don't exist, and handling errors.
Version             : 1.1
Change Log          : Created by Pratik Kakade - 13 Oct 2023
Test Class for      : UpdatePriceBookWebService
CreateDate          : 13 Oct 2023
LastModifiedDate    : 113 Oct 2023

******************************************************************************************************************************************************/

@isTest
private class UpdatePriceBookWebServiceTest {
    @isTest
    static void testUpdatePriceBookWebService1() {
        // Create a test instance of the ItemWrapper
        UpdatePriceBookWebService.ItemWrapper itemWrapper = new UpdatePriceBookWebService.ItemWrapper();
        itemWrapper.secondItemNumber = 'AF032';
        itemWrapper.thirdItemNumber = 'C-2';
        itemWrapper.unitCost = '340';
        itemWrapper.unitPrice = '603';
        itemWrapper.baseDISTI = '771.84';
        itemWrapper.baseDISTII = '771.84';
        itemWrapper.baseDISTIII = '771.84';
        itemWrapper.baseDISTIV = '771.84';
        itemWrapper.baseDISTV = '771.84';
        itemWrapper.baseDISTVI = '771.84';
        itemWrapper.description = '';
        itemWrapper.descriptionLine2 = '';
        itemWrapper.stockingType  = '';
        itemWrapper.costMeth = '';
        itemWrapper.available = '';
        itemWrapper.onHand = '';
        itemWrapper.backorder  = '';
        itemWrapper.committed = '';
        
        
        product2 prod = new product2();
        prod.ProductCode = 'AF032';
        prod.Name='\'C-2\' KIT, SERIES W/STANDARD';
        prod.JDE_Part_Number__c= 'AF032';
        
        insert prod;
        
         Id pricebookId = Test.getStandardPricebookId();
        
       List<Pricebook2> pricebookList = new List<Pricebook2>();
        pricebookList.add(new pricebook2(Name ='Dist I Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist II Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist III Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist IV Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist V Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist VI Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Enhanced Darley Store Price Book', IsActive = true ));
		pricebookList.add(new pricebook2(Name ='Pump Price Book', IsActive = true ));
		pricebookList.add(new pricebook2(Name ='Equipment Price Book', IsActive = true ));

               
        insert pricebookList;
        
        List<Pricebook2> pblist = [Select id, name from Pricebook2  Limit 10];
        
        
        List<priceBookEntry> pbeList = new List<priceBookEntry>();
        pbeList.add(new priceBookEntry(Pricebook2Id = pricebookId, UnitPrice= 604,Product2Id= prod.Id,IsActive = true));
        pbeList.add(new priceBookEntry(Pricebook2Id = pblist[0].id, UnitPrice= 604,Product2Id= prod.Id,IsActive = true));
        pbeList.add(new priceBookEntry(Pricebook2Id = pblist[1].id, UnitPrice= 604,Product2Id= prod.Id,IsActive = true));
        pbeList.add(new priceBookEntry(Pricebook2Id = pblist[2].id, UnitPrice= 604,Product2Id= prod.Id,IsActive = true));
        pbeList.add(new priceBookEntry(Pricebook2Id = pblist[3].id, UnitPrice= 604,Product2Id= prod.Id,IsActive = true));
        pbeList.add(new priceBookEntry(Pricebook2Id = pblist[4].id, UnitPrice= 604,Product2Id= prod.Id,IsActive = true));
        pbeList.add(new priceBookEntry(Pricebook2Id = pblist[5].id, UnitPrice= 604,Product2Id= prod.Id,IsActive = true));
        pbeList.add(new priceBookEntry(Pricebook2Id = pblist[6].id, UnitPrice= 604,Product2Id= prod.Id,IsActive = true));
		pbeList.add(new priceBookEntry(Pricebook2Id = pblist[7].id, UnitPrice= 604,Product2Id= prod.Id,IsActive = true));  
        pbeList.add(new priceBookEntry(Pricebook2Id = pblist[8].id, UnitPrice= 604,Product2Id= prod.Id,IsActive = true));  

        
        insert pbeList;
        
        /*List<PricebookEntry> pricebookEntries = [SELECT Pricebook2Id, Pricebook2.Name, Pricebook2.isActive, ProductCode, product2Id, product2.JDE_Part_Number__c, IsActive 
                                                 FROM PricebookEntry 
                                                 where (ProductCode = 'AF032' OR product2.JDE_Part_Number__c ='AF032') ];*/
        
        // Serialize the itemWrapper to JSON
        String requestBody = JSON.serialize(itemWrapper);
        
        Test.setMock(HttpCalloutMock.class, new UpdatePriceBookWebServiceMock());
        
        // Set the request body in the RestContext
        RestRequest request = new RestRequest();
        request.requestUri = '/updatePriceBook';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.request.requestBody = Blob.valueOf(requestBody);
        
        // Call the web service method
        String result = UpdatePriceBookWebService.updatePriceBook();
        
        // Verify the result
        System.assertEquals('PriceBookEntries are succesfully updated ', result);
        
    }
    
   // test method to insert pricebook entries for product having few entries available.
    @isTest
    static void testUpdatePriceBookWebService2() {
        // Create a test instance of the ItemWrapper
        UpdatePriceBookWebService.ItemWrapper itemWrapper = new UpdatePriceBookWebService.ItemWrapper();
        itemWrapper.secondItemNumber = 'AF032';
        itemWrapper.thirdItemNumber = 'C-2';
        itemWrapper.unitCost = '340';
        itemWrapper.unitPrice = '603';
        itemWrapper.baseDISTI = '771.84';
        itemWrapper.baseDISTII = '771.84';
        itemWrapper.baseDISTIII = '771.84';
        itemWrapper.baseDISTIV = '771.84';
        itemWrapper.baseDISTV = '771.84';
        itemWrapper.baseDISTVI = '771.84';
        itemWrapper.description = '';
        itemWrapper.descriptionLine2 = '';
        itemWrapper.stockingType  = '';
        itemWrapper.costMeth = '';
        itemWrapper.available = '';
        itemWrapper.onHand = '';
        itemWrapper.backorder  = '';
        itemWrapper.committed = '';
        
        product2 prod = new product2();
        prod.ProductCode = 'AF032';
        prod.Name='\'C-2\' KIT, SERIES W/STANDARD';
        prod.JDE_Part_Number__c= 'AF032';
       
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        List<Pricebook2> pricebookList = new List<Pricebook2>();
        pricebookList.add(new pricebook2(Name ='Dist I Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist II Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist III Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist IV Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist V Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist VI Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Enhanced Darley Store Price Boo', IsActive = true ));
		pricebookList.add(new pricebook2(Name ='Pump Price Book', IsActive = true ));
		pricebookList.add(new pricebook2(Name ='Equipment Price Book', IsActive = true ));

        
        
        insert pricebookList;
        
        List<Pricebook2> pblist = [Select id, name from Pricebook2  Limit 10];
        
        
        List<priceBookEntry> pbeList = new List<priceBookEntry>();
        pbeList.add(new priceBookEntry(Pricebook2Id = pricebookId, UnitPrice= 604, Product2Id= prod.Id, IsActive = true));
        pbeList.add(new priceBookEntry(Pricebook2Id = pblist[0].id, UnitPrice= 604,Product2Id= prod.Id,IsActive = true));
        pbeList.add(new priceBookEntry(Pricebook2Id = pblist[1].id, UnitPrice= 604,Product2Id= prod.Id,IsActive = true));
        pbeList.add(new priceBookEntry(Pricebook2Id = pblist[2].id, UnitPrice= 604,Product2Id= prod.Id,IsActive = true));


        
        
        insert pbeList;
        
        /*List<PricebookEntry> pricebookEntries = [SELECT Pricebook2Id, Pricebook2.Name, Pricebook2.isActive, ProductCode, product2Id, product2.JDE_Part_Number__c, IsActive 
                                                     FROM PricebookEntry 
                                                     where (ProductCode = 'AF032' OR product2.JDE_Part_Number__c ='AF032') ];*/
        
        // Serialize the itemWrapper to JSON
        String requestBody = JSON.serialize(itemWrapper);
        
        Test.setMock(HttpCalloutMock.class, new UpdatePriceBookWebServiceMock());
        
        // Set the request body in the RestContext
        RestRequest request = new RestRequest();
        request.requestUri = '/updatePriceBook';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.request.requestBody = Blob.valueOf(requestBody);
        
        // Call the web service method
        String result = UpdatePriceBookWebService.updatePriceBook();
        
        // Verify the result
        System.assertEquals('PriceBookEntries are succesfully updated ', result);
        
    }
    
    // test method to insert pricebook entries for product having no entries available.
     @isTest
    static void testUpdatePriceBookWebService3() {
        // Create a test instance of the ItemWrapper
        UpdatePriceBookWebService.ItemWrapper itemWrapper = new UpdatePriceBookWebService.ItemWrapper();
        itemWrapper.secondItemNumber = 'AF032';
        itemWrapper.thirdItemNumber = 'C-2';
        itemWrapper.unitCost = '340';
        itemWrapper.unitPrice = '603';
        itemWrapper.baseDISTI = '771.84';
        itemWrapper.baseDISTII = '771.84';
        itemWrapper.baseDISTIII = '771.84';
        itemWrapper.baseDISTIV = '771.84';
        itemWrapper.baseDISTV = '771.84';
        itemWrapper.baseDISTVI = '771.84';
        itemWrapper.description = '';
        itemWrapper.descriptionLine2 = '';
        itemWrapper.stockingType  = '';
        itemWrapper.costMeth = '';
        itemWrapper.available = '';
        itemWrapper.onHand = '';
        itemWrapper.backorder  = '';
        itemWrapper.committed = '';
        
        product2 prod = new product2();
        prod.ProductCode = 'AF032';
        prod.Name='\'C-2\' KIT, SERIES W/STANDARD';
        prod.JDE_Part_Number__c= 'AF032';
       
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        List<Pricebook2> pricebookList = new List<Pricebook2>();
        pricebookList.add(new pricebook2(Name ='Dist I Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist II Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist III Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist IV Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist V Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist VI Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Enhanced Darley Store Price Boo', IsActive = true ));
		pricebookList.add(new pricebook2(Name ='Pump Price Book', IsActive = true ));
		pricebookList.add(new pricebook2(Name ='Equipment Price Book', IsActive = true ));

        
        
        insert pricebookList;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
update standardPricebook;
        /*List<PricebookEntry> pricebookEntries = [SELECT Pricebook2Id, Pricebook2.Name, Pricebook2.isActive, ProductCode, product2Id, product2.JDE_Part_Number__c, IsActive 
                                                     FROM PricebookEntry 
                                                     where (ProductCode = 'AF032' OR product2.JDE_Part_Number__c ='AF032') ];*/
        
        // Serialize the itemWrapper to JSON
        String requestBody = JSON.serialize(itemWrapper);
        
        Test.setMock(HttpCalloutMock.class, new UpdatePriceBookWebServiceMock());
        
        // Set the request body in the RestContext
        RestRequest request = new RestRequest();
        request.requestUri = '/updatePriceBook';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.request.requestBody = Blob.valueOf(requestBody);
        
        // Call the web service method
        String result = UpdatePriceBookWebService.updatePriceBook();
        
        // Verify the result
        //System.assertEquals('PriceBookEntries are succesfully inserted ', result);
        
    }
    // test method for no product found
     @isTest
    static void testUpdatePriceBookWebService4() {
        // Create a test instance of the ItemWrapper
        UpdatePriceBookWebService.ItemWrapper itemWrapper = new UpdatePriceBookWebService.ItemWrapper();
        itemWrapper.secondItemNumber = 'AF0032';
        itemWrapper.thirdItemNumber = 'C-2';
        itemWrapper.unitCost = '340';
        itemWrapper.unitPrice = '603';
        itemWrapper.baseDISTI = '771.84';
        itemWrapper.baseDISTII = '771.84';
        itemWrapper.baseDISTIII = '771.84';
        itemWrapper.baseDISTIV = '771.84';
        itemWrapper.baseDISTV = '771.84';
        itemWrapper.baseDISTVI = '771.84';
        itemWrapper.description = '';
        itemWrapper.descriptionLine2 = '';
        itemWrapper.stockingType  = '';
        itemWrapper.costMeth = '';
        itemWrapper.available = '';
        itemWrapper.onHand = '';
        itemWrapper.backorder  = '';
        itemWrapper.committed = '';
        
        
        product2 prod = new product2();
        prod.ProductCode = 'AF032';
        prod.Name='\'C-2\' KIT, SERIES W/STANDARD';
        prod.JDE_Part_Number__c= 'AF032';
        
        insert prod;
        
         Id pricebookId = Test.getStandardPricebookId();
        
       List<Pricebook2> pricebookList = new List<Pricebook2>();
        pricebookList.add(new pricebook2(Name ='Dist I Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist II Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist III Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist IV Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist V Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist VI Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Enhanced Darley Store Price Boo', IsActive = true ));
		pricebookList.add(new pricebook2(Name ='Pump Price Book', IsActive = true ));
		pricebookList.add(new pricebook2(Name ='Equipment Price Book', IsActive = true ));

               
        insert pricebookList;
        
        List<Pricebook2> pblist = [Select id, name from Pricebook2  Limit 10];
        
        
        List<priceBookEntry> pbeList = new List<priceBookEntry>();
        pbeList.add(new priceBookEntry(Pricebook2Id = pricebookId, UnitPrice= 604,Product2Id= prod.Id,IsActive = true));
        pbeList.add(new priceBookEntry(Pricebook2Id = pblist[0].id, UnitPrice= 604,Product2Id= prod.Id,IsActive = true));
        pbeList.add(new priceBookEntry(Pricebook2Id = pblist[1].id, UnitPrice= 604,Product2Id= prod.Id,IsActive = true));
        pbeList.add(new priceBookEntry(Pricebook2Id = pblist[2].id, UnitPrice= 604,Product2Id= prod.Id,IsActive = true));
        pbeList.add(new priceBookEntry(Pricebook2Id = pblist[3].id, UnitPrice= 604,Product2Id= prod.Id,IsActive = true));
        pbeList.add(new priceBookEntry(Pricebook2Id = pblist[4].id, UnitPrice= 604,Product2Id= prod.Id,IsActive = true));
        pbeList.add(new priceBookEntry(Pricebook2Id = pblist[5].id, UnitPrice= 604,Product2Id= prod.Id,IsActive = true));
        pbeList.add(new priceBookEntry(Pricebook2Id = pblist[6].id, UnitPrice= 604,Product2Id= prod.Id,IsActive = true));
		pbeList.add(new priceBookEntry(Pricebook2Id = pblist[7].id, UnitPrice= 604,Product2Id= prod.Id,IsActive = true));  
        pbeList.add(new priceBookEntry(Pricebook2Id = pblist[8].id, UnitPrice= 604,Product2Id= prod.Id,IsActive = true));  

        
        insert pbeList;
        
        /*List<PricebookEntry> pricebookEntries = [SELECT Pricebook2Id, Pricebook2.Name, Pricebook2.isActive, ProductCode, product2Id, product2.JDE_Part_Number__c, IsActive 
                                                 FROM PricebookEntry 
                                                 where (ProductCode = 'AF032' OR product2.JDE_Part_Number__c ='AF032') ];*/
        
        // Serialize the itemWrapper to JSON
        String requestBody = JSON.serialize(itemWrapper);
        
        Test.setMock(HttpCalloutMock.class, new UpdatePriceBookWebServiceMock());
        
        // Set the request body in the RestContext
        RestRequest request = new RestRequest();
        request.requestUri = '/updatePriceBook';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.request.requestBody = Blob.valueOf(requestBody);
        
        // Call the web service method
        String result = UpdatePriceBookWebService.updatePriceBook();
        
        // Verify the result
        System.assertEquals('No product found for the given product code.Check the product code.', result);
        
    }
    
     // test method to catch insert pricebook entries for product having no entries available.
     @isTest
    static void testUpdatePriceBookWebService5() {
        // Create a test instance of the ItemWrapper
        UpdatePriceBookWebService.ItemWrapper itemWrapper = new UpdatePriceBookWebService.ItemWrapper();
        itemWrapper.secondItemNumber = 'AF032';
        itemWrapper.thirdItemNumber = 'C-2';
        itemWrapper.unitCost = '340';
        itemWrapper.unitPrice = '603';
        itemWrapper.baseDISTI = '771.84';
        itemWrapper.baseDISTII = '771.84';
        itemWrapper.baseDISTIII = '771.84';
        itemWrapper.baseDISTIV = '771.84';
        itemWrapper.baseDISTV = '771.84';
        itemWrapper.baseDISTVI = '771.84';
        itemWrapper.description = '';
        itemWrapper.descriptionLine2 = '';
        itemWrapper.stockingType  = '';
        itemWrapper.costMeth = '';
        itemWrapper.available = '';
        itemWrapper.onHand = '';
        itemWrapper.backorder  = '';
        itemWrapper.committed = '';
        
        product2 prod = new product2();
        prod.ProductCode = 'AF032';
        prod.Name='\'C-2\' KIT, SERIES W/STANDARD';
        prod.JDE_Part_Number__c= 'AF032';
       
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        List<Pricebook2> pricebookList = new List<Pricebook2>();
        pricebookList.add(new pricebook2(Name ='Dist I Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist II Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist III Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist IV Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist V Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist VI Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Enhanced Darley Store Price Boo', IsActive = true ));
		pricebookList.add(new pricebook2(Name ='Pump Price Book', IsActive = true ));
		pricebookList.add(new pricebook2(Name ='Equipment Price Book', IsActive = true ));

        
        
        insert pricebookList;
       
        /*List<PricebookEntry> pricebookEntries = [SELECT Pricebook2Id, Pricebook2.Name, Pricebook2.isActive, ProductCode, product2Id, product2.JDE_Part_Number__c, IsActive 
                                                     FROM PricebookEntry 
                                                     where (ProductCode = 'AF032' OR product2.JDE_Part_Number__c ='AF032') ];*/
        
        // Serialize the itemWrapper to JSON
        String requestBody = JSON.serialize(itemWrapper);
        
        Test.setMock(HttpCalloutMock.class, new UpdatePriceBookWebServiceMock());
        
        // Set the request body in the RestContext
        RestRequest request = new RestRequest();
        request.requestUri = '/updatePriceBook';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.request.requestBody = Blob.valueOf(requestBody);
        
        // Call the web service method
        String result = UpdatePriceBookWebService.updatePriceBook();
        
        // Verify the result
        System.assertEquals('Failed to insert pricebook Entries', result);
        
    }
     // test method to insert pricebook entries for product having few entries available.
    @isTest
    static void testUpdatePriceBookWebService6() {
        // Create a test instance of the ItemWrapper
        UpdatePriceBookWebService.ItemWrapper itemWrapper = new UpdatePriceBookWebService.ItemWrapper();
        itemWrapper.secondItemNumber = 'AF032';
        itemWrapper.thirdItemNumber = 'C-2';
        itemWrapper.unitCost = '';
        itemWrapper.unitPrice = '';
        itemWrapper.baseDISTI = '';
        itemWrapper.baseDISTII = '';
        itemWrapper.baseDISTIII = '';
        itemWrapper.baseDISTIV = '';
        itemWrapper.baseDISTV = '';
        itemWrapper.baseDISTVI = '';
        itemWrapper.description = '';
        itemWrapper.descriptionLine2 = '';
        itemWrapper.stockingType  = '';
        itemWrapper.costMeth = '';
        itemWrapper.available = '';
        itemWrapper.onHand = '';
        itemWrapper.backorder  = '';
        itemWrapper.committed = '';
        
        product2 prod = new product2();
        prod.ProductCode = 'AF032';
        prod.Name='\'C-2\' KIT, SERIES W/STANDARD';
        prod.JDE_Part_Number__c= 'AF032';
       
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        List<Pricebook2> pricebookList = new List<Pricebook2>();
        pricebookList.add(new pricebook2(Name ='Dist I Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist II Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist III Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist IV Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist V Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Dist VI Price Book', IsActive = true ));
        pricebookList.add(new pricebook2(Name ='Enhanced Darley Store Price Boo', IsActive = true ));
		pricebookList.add(new pricebook2(Name ='Pump Price Book', IsActive = true ));
		pricebookList.add(new pricebook2(Name ='Equipment Price Book', IsActive = true ));

        
        
        insert pricebookList;
        
        List<Pricebook2> pblist = [Select id, name from Pricebook2  Limit 10];
        
        
        List<priceBookEntry> pbeList = new List<priceBookEntry>();
        pbeList.add(new priceBookEntry(Pricebook2Id = pricebookId, UnitPrice= 604, Product2Id= prod.Id, IsActive = true));
        pbeList.add(new priceBookEntry(Pricebook2Id = pblist[0].id, UnitPrice= 604,Product2Id= prod.Id,IsActive = true));
        pbeList.add(new priceBookEntry(Pricebook2Id = pblist[1].id, UnitPrice= 604,Product2Id= prod.Id,IsActive = true));
        pbeList.add(new priceBookEntry(Pricebook2Id = pblist[2].id, UnitPrice= 604,Product2Id= prod.Id,IsActive = true));


        
        
        insert pbeList;
     
        
        // Serialize the itemWrapper to JSON
        String requestBody = JSON.serialize(itemWrapper);
        
        Test.setMock(HttpCalloutMock.class, new UpdatePriceBookWebServiceMock());
        
        // Set the request body in the RestContext
        RestRequest request = new RestRequest();
        request.requestUri = '/updatePriceBook';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.request.requestBody = Blob.valueOf(requestBody);
        
        // Call the web service method
        String result = UpdatePriceBookWebService.updatePriceBook();
        
        // Verify the result
       // System.assertEquals('Failed ', result);
        
    }
    
}