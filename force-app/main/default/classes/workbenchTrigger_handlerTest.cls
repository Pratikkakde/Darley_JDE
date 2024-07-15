/******************************************************************************************************************************************************
Name                    : workbenchTrigger_handlerTest
Author                  : Melonleaf
Purpose                 : This  class is designed to test the functionality.

Description             : 
Version                 : 1.0
Change Log              : 
Test Class For          : workbenchTrigger_handler
CreateDate              : 25-05-2024
LastModifiedDate        : 25-05-2024
******************************************************************************************************************************************************/

@isTest
public class workbenchTrigger_handlerTest {
    
    @isTest
    static void testProcessManufacturerPartNumbers() {
        List<Bid_Workbench__c> testRecords = TestDataUtilClass.createBidWorkbenchRecords(1);
        insert testRecords;
        Test.startTest();
        workbenchTrigger_handler.ReAssignData(testRecords);
        Test.stopTest();  
    }
    
    @isTest
    static void testProcessManufacturerPartNumbers1() {
        Bid_Workbench__c testRecord = TestDataUtilClass.createBidWorkbenchRecordWithFOBOriginY();
        insert testRecord;
        
        testRecord.Manufacturer_Name__c='update manufacturer';
        testRecord.Quantity__c=8;
        update testRecord;
        
        Bid_Line_Item__c bidln =TestDataUtilClass.getBidLineItem();
        
        Bid_Tracker__c bdtrac =TestDataUtilClass.getBidTracker();
        insert bdtrac;
        
        bidln.Line_Item_ID__c=testRecord.Order_Item_ID__c;
        bidln.RFQ_Number__c=bdtrac.id;
        bidln.Quote_Numbers__c='12';
        insert bidln;
        
        bdtrac.Due_Date__c=Date.today();
        update bdtrac;
        
        Test.startTest();
        workbenchTrigger_handler.ReAssignData(new List<Bid_Workbench__c>{testRecord});
        Test.stopTest();
    }
    
    @isTest
    static void testLineItemCount() 
    {
        List<Bid_Workbench__c> testRecords = TestDataUtilClass.createBidWorkbenchRecordsForLineItemCount(5);
        
        insert testRecords;
        
        Test.startTest();
        WorkbenchTrigger_Handler.LineItemCount(testRecords);
        Test.stopTest();
        
        List<Bid_Workbench__c> updatedRecords = [SELECT Id, Line_items__c FROM Bid_Workbench__c WHERE Quote_Number__c = 'TestQuoteNumber'];
        Integer expectedLineItemCount = 5; 
        for (Bid_Workbench__c record : updatedRecords) {
            System.assertEquals(expectedLineItemCount, record.Line_items__c);
        }
    }
    
    @isTest
    static void testBidWorkbenchUpdateCondition() {
        
        Bid_Workbench__c bidWorkbench = new Bid_Workbench__c(
            Manufacturer_Name__c = 'Test Manufacturer',
            ShipTo_DODAAC__c = 'DODAAC1', 
            Processed__c = true,
           Order_Item_ID__c='OLN123');
        insert bidWorkbench;
        
        
        Map<Id, Bid_Workbench__c> oldBidWorkMap = new Map<Id, Bid_Workbench__c>();
        oldBidWorkMap.put(
            bidWorkbench.Id,
            new Bid_Workbench__c(
                Manufacturer_Name__c = 'Test Manufacturer',
                ShipTo_DODAAC__c = 'DODAAC12',
                Order_Item_ID__c='OLN123'  
            )
        );
        
        Bid_Tracker__c bidTracker = new Bid_Tracker__c();
        bidTracker.Name = 'test bidTracker';
        insert bidTracker;
        
        DoDAAC__c dodac = new DoDAAC__c();
        dodac.Name = 'trestsfgd';
        insert dodac;
        
        Bid_Line_Item__c bidLineItems = new Bid_Line_Item__c(
            Name = 'Test bidLineItems',
            Line_Item_ID__c = 'OLN123',
            RFQ_Number__c = bidTracker.Id,
            Quote_Numbers__c = '1234567',
            Item_Description__c='Bundle',
            Ship_To_DoDAAC__c = dodac.Id
        );
        insert bidLineItems;
        
         Bid_Line_Item__c bidLineItems1 = new Bid_Line_Item__c(
            Name = 'Test bidLineItems',
            Line_Item_ID__c = 'OLN123',
            RFQ_Number__c = bidTracker.Id,
            Quote_Numbers__c = '1234567',
            Item_Description__c='Bundle',
            Ship_To_DoDAAC__c = dodac.Id,
            status__c='Awaiting Approval'
        );
        insert bidLineItems1;

  
        Test.startTest();
        workbenchTrigger_handler.updatetheBidLineFields(
            new List<Bid_Workbench__c>{ bidWorkbench },
            oldBidWorkMap
        );
        Test.stopTest();
    }
}