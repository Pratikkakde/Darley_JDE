@isTest
public class RFQpdfCreationTest 
{ 
    @isTest
    static void testWithBidLineId() {
        
        Bid_Tracker__c bid = TestDataUtilClass.getBidTracker();
        insert bid;
        
        Bid_Line_Item__c testBidLineItem = TestDataUtilClass.getBidLineItem();
        testBidLineItem.RFQ_Number__c = bid.id;
        testBidLineItem.Quote_Numbers__c='123';
        insert testBidLineItem;
       
        ApexPages.currentPage().getParameters().put('id', testBidLineItem.Id);
        
        RFQpdfCreation pdfCreation = new RFQpdfCreation();
        
        System.assertEquals(testBidLineItem.Name, pdfCreation.recordList[0].Name);  
    }
    
    @isTest
    static void testWithGroupId() 
    {
        Bid_Tracker__c bid = TestDataUtilClass.getBidTracker();
        insert bid;
        
        Bid_Group_Items__c testBidGroupItem = TestDataUtilClass.getBidGroupItem();
        testBidGroupItem.RFQ_Number__c=bid.Id;
        insert testBidGroupItem;
        
        ApexPages.currentPage().getParameters().put('gid', testBidGroupItem.Id);
  
        RFQpdfCreation pdfCreation = new RFQpdfCreation();
        pdfCreation.todayDate = Date.today();
        pdfCreation.groupId = testBidGroupItem.Id;
        pdfCreation.bidLineId = 'SampleBidLineId';
        pdfCreation.beforeDueDate = DateTime.now();
        pdfCreation.beforeDueDateString = pdfCreation.beforeDueDate.format('MM/dd/yyyy');
        pdfCreation.hasSupplierUnitPrice = true;
        pdfCreation.boolenStrign = false;
        pdfCreation.requestedDeliverDate = '05/10/2024'; 
        pdfCreation.deliverDestination = 'Test Destination'; 
        pdfCreation.groupId = testBidGroupItem.Id;
    }  
}