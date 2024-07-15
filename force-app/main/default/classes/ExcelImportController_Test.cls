/******************************************************************************************************************************************************
Name                    : ExcelImportController_Test
Author                  : Melonleaf
Purpose                 : This  class is designed to test the functionality.
Description             : This class is creating the records of Award Workbench and Bid Workbench when a excel file is droped on the upload excel file comp.
Version                 : 1.0
Change Log              : 
Test Class For          : ExcelImportController
CreateDate              : 25-05-2024
LastModifiedDate        : 25-05-2024
******************************************************************************************************************************************************/

@isTest
public class ExcelImportController_Test {
    
    @isTest
    public static void testParseFileData(){
        String base64Data = '[{"Vendor ID":2,"TLSP Vendor Extension":"WSD","Region Group":"FES Global","Region":40,"Request Type":"M","Order Item ID":1244413,"Manufacturer Name":"3M- SCOTT","Manufacturer Part Number":"7012472110","Item Description":"201215-04 H,AV-3K HT 5-ST, KEV, R BKT, S","Additional Information":"Masks- small","Requested Delivery Date":45108,"Unit of Issue":"EA","Quantity":16,"ShipTo DoDAAC":"M02209","Delivery Destination":"Station Fire Department","FOB Origin":"N","RFID Required":"N","Transportation Price":0,"Vendor Unit Price":0,"Purchase Unit Price":0,"Purchase Extended Price":0,"Customer Permits Alternates":"Y","Alternate Purchase Unit Price":0,"Alternate Purchase Extended Price":0,"Quote Due Date":45035.625,"Quote Number":"20230414666957","Load Batch Number":"20230414180793","Fund Code":"123"},{"Vendor ID":2,"TLSP Vendor Extension":"WSD","Region Group":"FES Global","Region":40,"Request Type":"M","Order Item ID":1244414,"Manufacturer Name":"3M- SCOTT","Manufacturer Part Number":"7012472111","Item Description":"201215-04 H,AV-3K HT 5-ST, KEV, R BKT, M","Additional Information":"Masks- med","Requested Delivery Date":45108,"Unit of Issue":"EA","Quantity":50,"ShipTo DoDAAC":"M02209","Delivery Destination":"Station Fire Department","FOB Origin":"N","RFID Required":"N","Transportation Price":0,"Vendor Unit Price":0,"Purchase Unit Price":0,"Purchase Extended Price":0,"Customer Permits Alternates":"Y","Alternate Purchase Unit Price":0,"Alternate Purchase Extended Price":0,"Quote Due Date":45035.625,"Quote Number":"20230414666957","Load Batch Number":"20230414180793","FundCode":"123","Signa lCode":"123"}]';
    	String fileName = 'DAR-Request_For_Quote_1.xlsx';
         
        String base64Data1 = '[{"Vendor ID":2,"TLSP Vendor Extension":"WSD","Region Group":"FES Global","Region":40,"Request Type":"M","Order Item ID":1244413,"Manufacturer Name":"3M- SCOTT","Manufacturer Part Number":"7012472110","Item Description":"201215-04 H,AV-3K HT 5-ST, KEV, R BKT, S","Additional Information":"Masks- small","Requested Delivery Date":45108,"Unit of Issue":"EA","Quantity":16,"ShipTo DoDAAC":"M02209","Delivery Destination":"Station Fire Department","FOB Origin":"N","RFID Required":"N","Transportation Price":0,"Vendor Unit Price":0,"Purchase Unit Price":0,"Purchase Extended Price":0,"Customer Permits Alternates":"Y","Alternate Purchase Unit Price":0,"Alternate Purchase Extended Price":0,"Quote Due Date":45035.625,"Quote Number":"20230414666957","Load Batch Number":"20230414180793","Fund Code":"123"},{"Vendor ID":2,"TLSP Vendor Extension":"WSD","Region Group":"FES Global","Region":40,"Request Type":"M","Order Item ID":1244414,"Manufacturer Name":"3M- SCOTT","Manufacturer Part Number":"7012472111","Item Description":"201215-04 H,AV-3K HT 5-ST, KEV, R BKT, M","Additional Information":"Masks- med","Requested Delivery Date":45108,"Unit of Issue":"EA","Quantity":50,"ShipTo DoDAAC":"M02209","Delivery Destination":"Station Fire Department","FOB Origin":"N","RFID Required":"N","Transportation Price":0,"Vendor Unit Price":0,"Purchase Unit Price":0,"Purchase Extended Price":0,"Customer Permits Alternates":"Y","Alternate Purchase Unit Price":0,"Alternate Purchase Extended Price":0,"Quote Due Date":45035.625,"Quote Number":"20230414666957","Load Batch Number":"20230414180793","FundCode":"123","Signal Code":"123"}]';
    	String fileName1 = 'DAR-Award_For_Quote_2.xlsx';
        
        String base64Data2 = '[{"Vendor ID":2,"TLSP Vendor Extension":"WSD","Region Group":"FES Global","Region":40,"Request Type":"M","Order Item ID":1244413,"Manufacturer Name":"3M- SCOTT","Manufacturer Part Number":"7012472110","Item Description":"201215-04 H,AV-3K HT 5-ST, KEV, R BKT, S","Additional Information":"Masks- small","Requested Delivery Date":45108,"Unit of Issue":"EA","Quantity":16,"ShipTo DoDAAC":"M02209","Delivery Destination":"Station Fire Department","FOB Origin":"N","RFID Required":"N","Transportation Price":0,"Vendor Unit Price":0,"Purchase Unit Price":0,"Purchase Extended Price":0,"Customer Permits Alternates":"Y","Alternate Purchase Unit Price":0,"Alternate Purchase Extended Price":0,"Quote Due Date":45035.625,"Quote Number":"20230414666957","Load Batch Number":"20230414180793","Fund Code":"123"},{"Vendor ID":2,"TLSP Vendor Extension":"WSD","Region Group":"FES Global","Region":40,"Request Type":"M","Order Item ID":1244414,"Manufacturer Name":"3M- SCOTT","Manufacturer Part Number":"7012472111","Item Description":"201215-04 H,AV-3K HT 5-ST, KEV, R BKT, M","Additional Information":"Masks- med","Requested Delivery Date":45108,"Unit of Issue":"EA","Quantity":50,"ShipTo DoDAAC":"M02209","Delivery Destination":"Station Fire Department","FOB Origin":"N","RFID Required":"N","Transportation Price":0,"Vendor Unit Price":0,"Purchase Unit Price":0,"Purchase Extended Price":0,"Customer Permits Alternates":"Y","Alternate Purchase Unit Price":0,"Alternate Purchase Extended Price":0,"Quote Due Date":45035.625,"Quote Number":"20230414666957","Load Batch Number":"20230414180793","FundCode":"123","Signal Code":"123"}]';
    	String fileName2 = 'DAR-Request_For_Quote_3.xlsx';
        
        Bid_Workbench__c testRecord = TestDataUtilClass.createBidWorkbenchRecordWithFOBOriginY();
        insert testRecord;
        
        Award_workbench__C bidAward=new Award_workbench__C();
        bidAward.Order_Number__c = '1244414';
            bidAward.TLSP_Vendor_Part_Number__c  = 'p';
        bidAward.Name='1244414';
        insert bidAward;
        test.startTest();
        
        ExcelImportController.parseFile(base64Data,fileName);
        //For Duplicate Records
       ExcelImportController.parseFile(base64Data1,fileName1);
        //For Excel Data Containing Error 
        ExcelImportController.parseFile(base64Data2,fileName2);
        
        test.stopTest();
    }
    
   
    
}