/******************************************************************************************************************************************************
Name                    : ExcelImportController
Author                  : Melonleaf
Purpose                 : This  class is designed to create the records in Bid Workbench & Award Workbench.
Description             : This class is creating the records of Award Workbench and Bid Workbench when a excel file is droped on the upload excel file comp.
Version                 : 1.0
Change Log              : 
Test Class              : ExcelImportController_Test
CreateDate              : 25-05-2024
LastModifiedDate        : 25-05-2024
******************************************************************************************************************************************************/

public with sharing class ExcelImportController { 
    
    public virtual class BulkEmployeeException extends Exception {}     
    /*
* @param base64Data : Content of the File in JSON format 
* @param fileName : File Name 
* @param contentType : Type of the File (Excel)
*/
    Public static String FileNameOfExcel;
    @AuraEnabled
    public static String parseFile(String base64Data, String fileName) {

        System.debug('In ParseFile');
        try {
                                     
            FileNameOfExcel = fileName;
       
            
            String returnMsg = createEmployeeBatchRecords(Blob.valueOf(base64Data));
            return returnMsg;
            
            
        }catch(BulkEmployeeException e){
            System.debug('BulkEmployeeException::::'+e.getMessage());
                System.debug('Stack Trace::::' + e.getStackTraceString());

            return 'Error While Creating Records';
            
            
        }catch (Exception e) {
            System.debug('Exception::::'+e);
                System.debug('Stack Trace::::' + e.getStackTraceString());

            return 'Error While Creating Records';
        }
    }
    
    
    public static String createEmployeeBatchRecords(Blob blobData)
    {
        
        String extractedRFQNumber; //Storing RFQ Number
        
        if(FileNameOfExcel.containsIgnoreCase('Request') || FileNameOfExcel.containsIgnoreCase('RFQ')){
            //Extracting RFQ Number
            if(FileNameOfExcel.containsIgnoreCase('RFQ')){
                
                String[] parts = FileNameOfExcel.split('RFQ'); // Split the string at "RFQ"
                if (parts.size() > 1) {
                    String[] numberParts = parts[1].split('_'); // Split the second part at "_"
                    extractedRFQNumber = numberParts[0]; // The number is the first part after "RFQ"
                    System.debug('Extracted Number: ' + extractedRFQNumber);
                } else {
                    System.debug('Number not found in the file name.');
                }
            }
            
            
            String csvAsString;
            String[] csvFileLines;
            System.debug('blobData:::'+blobData);
          
            
            List<Bid_Workbench__c> batchEmployeeList = new List<Bid_Workbench__c>();
            Map<String,Bid_Workbench__c> mapBidWorkbenchInsert = new Map<String,Bid_Workbench__c>();
            
            system.debug('size'+(jsonFormator(blobData.toString())));
            system.debug('size'+blobData.toString());
            for(JSON2ApexController item:  JSON2ApexController.parse(jsonFormator(blobData.toString()))) {
                System.debug('item.OrderItemID'+item.OrderItemID);
                
                if(item.OrderItemID != NULL)  {
                    Bid_Workbench__c batchEmployeeRecord = new Bid_Workbench__c();            
                    
                    if(!String.isBlank(FileNameOfExcel) && FileNameOfExcel.containsIgnoreCase('TENTCE')){
                        batchEmployeeRecord.ServiceNow_RFQ_Program__c = 'SOE Tents';
                    }
                      else if(!String.isBlank(FileNameOfExcel) && FileNameOfExcel.containsIgnoreCase('TENT')){
                        batchEmployeeRecord.ServiceNow_RFQ_Program__c = 'SOE Tents';
                    }
                    
                    batchEmployeeRecord.Vendor_ID__c = item.VendorId;
                    batchEmployeeRecord.TLSP_Vendor_Extension__c = item.TLSPVendorExtension;  
                    batchEmployeeRecord.Region_Group__c = item.RegionGroup;
                    batchEmployeeRecord.Region__c = item.Region;
                    batchEmployeeRecord.Request_Type__c = item.RequestType;
                    batchEmployeeRecord.Order_Item_ID__c = item.OrderItemID;
                    batchEmployeeRecord.Manufacturer_Name__c = item.ManufacturerName;
                    batchEmployeeRecord.Manufacturer_Part_Number__c = item.ManufacturerPartNumber;
                    batchEmployeeRecord.Item_Description__c = item.ItemDescription;
                    system.debug('The additional information '+item.AdditionalInformation);
                    batchEmployeeRecord.Additional_Information__c = item.AdditionalInformation;
                    
                    if(item.RequestedDeliveryDate != NULL && !item.RequestedDeliveryDate.contains('-')){
                        If (item.RequestedDeliveryDate.contains('/')){
                            batchEmployeeRecord.Requested_Delivery_Date__c= returnDate(item.RequestedDeliveryDate);
                            
                        }else {
                            batchEmployeeRecord.Requested_Delivery_Date__c = convertExcelDateNumToApexDate(item.RequestedDeliveryDate);

                        }
                    } else if(item.RequestedDeliveryDate != NULL && item.RequestedDeliveryDate.contains('-')){
                        String inputDateTimeString = String.valueOf(item.RequestedDeliveryDate);                                
                        Integer year = Integer.valueOf(inputDateTimeString.substring(6, 10));
                        Integer day = Integer.valueOf(inputDateTimeString.substring(3, 5));
                        Integer month = Integer.valueOf(inputDateTimeString.substring(0, 2));
                        
                        Date parsedDate = Date.newInstance(year, month, day);
                        batchEmployeeRecord.Requested_Delivery_Date__c = parsedDate;
                        
                    }
                    
                    batchEmployeeRecord.Unit_of_Issue__c = item.UnitofIssue;
                    batchEmployeeRecord.Quantity__c = item.Quantity;
                    batchEmployeeRecord.ShipTo_DODAAC__c = item.ShipToDoDAAC;
                    batchEmployeeRecord.FOB_Origin__c = item.FOBOrigin;
                    batchEmployeeRecord.RFID_Required__c = item.RFIDRequired;
                    batchEmployeeRecord.Purchase_Unit_Price__c = item.PurchaseUnitPrice;
                    batchEmployeeRecord.Customer_Permits_Alternates__c = item.CustomerPermitsAlternates;
                    
                    if(FileNameOfExcel.containsIgnoreCase('RFQ')){
                        batchEmployeeRecord.Quote_Number__c = extractedRFQNumber;
                        batchEmployeeRecord.Record_source__c='ServiceNow';
                        if( batchEmployeeRecord.ServiceNow_RFQ_Program__c == 'SOE Tents'){
                       batchEmployeeRecord.TLSP_Vendor_Extension__c = 'DAR';
                    }
                    }
                    else{
                    batchEmployeeRecord.Quote_Number__c = item.QuoteNumber;
                    }
                    
                    batchEmployeeRecord.Load_Batch_Number__c = item.LoadBatchNumber;
                    batchEmployeeRecord.Core_List_Number__c = item.CoreListNumber;
                    batchEmployeeRecord.NSN__c = item.NSN;
                    batchEmployeeRecord.TLSP_Vendor_Part_Number__c = item.TLSPVendorPartNumber;
                    batchEmployeeRecord.Delivery_Destination__c = item.DeliveryDestination;
                    batchEmployeeRecord.Special_Project_Code__c = item.SpecialProjectCode;
                    batchEmployeeRecord.Transportation_Price_Required__c = item.TransportationPriceRequired;
                    batchEmployeeRecord.Transportation_Price__c = item.TransportationPrice;
                    batchEmployeeRecord.Vendor_Unit_Price__c = item.VendorUnitPrice;
                    batchEmployeeRecord.Purchase_Extended_Price__c = item.PurchaseExtendedPrice;
                    batchEmployeeRecord.Lead_Time__c =  item.LeadTime;
                    batchEmployeeRecord.Treade_Agreement_Compliant__c =  item.TradeAgreementCompliant;
                    batchEmployeeRecord.Comments__c =  item.Comments;
                    batchEmployeeRecord.Berry_Amendment_Compliant__c = item.BerryAmendmentCompliant;
                    batchEmployeeRecord.Country_of_Origin__c = item.CountryofOrigin;
                    batchEmployeeRecord.Alternate_Core_List_Number__c =  item.AlternateCoreListNumber;
                    batchEmployeeRecord.Alternate_NSN__c = item.AlternateNSN;
                    batchEmployeeRecord.Alternate_Manufacturer_Name__c = item.AlternateManufacturerName;
                    batchEmployeeRecord.Alternate_Manufacturer_Part_Number__c  = item.AlternateManufacturerPartNumber;
                    batchEmployeeRecord.Alternate_Item_Description__c = item.AlternateItemDescription;
                    batchEmployeeRecord.Alternate_TLSP_Vendor_Part_Number__c =  item.AlternateTLSPVendorPartNumber;
                    batchEmployeeRecord.Alternate_Transportation_Price__c =  item.AlternateTransportationPrice;
                    batchEmployeeRecord.Alternate_Vendor_Unit_Price__c =  item.AlternateVendorUnitPrice;
                    batchEmployeeRecord.Alternate_Purchase_Unit_Price__c =  item.AlternatePurchaseUnitPrice;
                    batchEmployeeRecord.Alternate_Purchase_Extended_Price__c =  item.AlternatePurchaseExtendedPrice;
                    batchEmployeeRecord.Alternate_Procurement_Agreement_Complian__c =  item.AlternateTradeAgreementCompliant; 
                    batchEmployeeRecord.Alternate_Comments__c =  item.AlternateComments;
                    batchEmployeeRecord.Alternate_Lead_Time__c =  item.AlternateLeadTime;
                    batchEmployeeRecord.Alternate_Berry_Amendment_Compliant__c =  item.AlternateBerryAmendmentCompliant;
                    
                    //FOR RFQ New
                    batchEmployeeRecord.Intended_Use__c =  item.IntendedUse;
                    batchEmployeeRecord.Timeframe__c =  item.Timeframe;
                    batchEmployeeRecord.City__c =  item.City;
                    batchEmployeeRecord.State__c =  item.State;
                    batchEmployeeRecord.Country__c =  item.Country;
                    batchEmployeeRecord.Zip_Code__c =  item.ZipCode;                  
                    batchEmployeeRecord.Purchase_Unit_Price__c =  item.PurchaseUnitPrice;
                    batchEmployeeRecord.Lead_Time__c =  item.LeadTime;
                    batchEmployeeRecord.Alternate_Item_Offered__c =  item.AlternateItemOffered;
                    batchEmployeeRecord.First_Name__c =  item.POCFirstName;
                    System.debug('First Name'+ item.POCFirstName + 'batchEmployeeRecord.First_Name__c'+batchEmployeeRecord.First_Name__c);
                    batchEmployeeRecord.Last_Name__c =  item.POCLastName;
                    batchEmployeeRecord.Unit__c =  item.POCUnit;
                    batchEmployeeRecord.Phone__c =  item.POCPhone;
                    batchEmployeeRecord.Email__c =  item.POCEmail;
                    
                    if(item.QuoteDueDate != NULL && item.QuoteDueDate.contains('.')){
                        batchEmployeeRecord.Quote_Due_Date__c =  convertExcelDateTimeDecimalToApexDateTime(item.QuoteDueDate); 
                    } else if(item.QuoteDueDate != NULL && (item.QuoteDueDate.contains('-') ) ){
                        String inputDateTimeString = String.valueOf(item.QuoteDueDate) ;
                        Integer year = Integer.valueOf(inputDateTimeString.substring(6, 10));
                        Integer day = Integer.valueOf(inputDateTimeString.substring(3, 5));
                        Integer month = Integer.valueOf(inputDateTimeString.substring(0, 2));
                        Integer hour = Integer.valueOf(inputDateTimeString.substring(11, 13));
                        
                        Integer minute = Integer.valueOf(inputDateTimeString.substring(14, 16));
                        Integer second = Integer.valueOf(inputDateTimeString.substring(17, 19));
                        DateTime parsedDateTime = DateTime.newInstance(year, month, day, hour, minute, second); 
                        
                        batchEmployeeRecord.Quote_Due_Date__c = parsedDateTime;
                        
                        
                    } else if ( item.QuoteDueDate != NULL && item.QuoteDueDate.contains('/')){
                        String dateTimeString = item.QuoteDueDate;
                        
                        // Extract the date and time parts
                        List<String> dateTimeParts = dateTimeString.split(' ');
                        String dateString = dateTimeParts[0];
                        String timeString = dateTimeParts[1] + ' ' + dateTimeParts[2];
                        
                        
                        // Convert the date string to a Date object
                        Date dateValue = Date.parse(dateString);
                        
                        // Convert the time string to a Time object
                        String timeWithoutAmPm = timeString.replace('AM', '').replace('PM', '').trim();
                        List<String> timeParts = timeWithoutAmPm.split(':');
                        Integer hour = Integer.valueOf(timeParts[0]);
                        Integer minute = Integer.valueOf(timeParts[1]);
                        Integer second = Integer.valueOf(timeParts[2]);
                        
                        if (dateTimeParts[2] == 'PM' && hour != 12) {
                            hour += 12;
                        } else if (dateTimeParts[2] == 'AM' && hour == 12) {
                            hour = 0;
                        }
                        
                        // Combine date and time to a DateTime object
                        DateTime dateTimeValue = DateTime.newInstance(dateValue.year(), dateValue.month(), dateValue.day(), hour, minute, second);
                        
                        // Example SObject
                      
                        
                        // Assign the DateTime value to the field
                        batchEmployeeRecord.Quote_Due_Date__c = dateTimeValue.addHours(1);
                    }
                    system.debug('Values of date Time'+batchEmployeeRecord.Quote_Due_Date__c);
                    
                    batchEmployeeRecord.Alternate_Country_of_Origin__c = item.AlternateCountryofOrigin;
                    
                    batchEmployeeList.add(batchEmployeeRecord); 
                    mapBidWorkbenchInsert.put(batchEmployeeRecord.Order_Item_ID__c,batchEmployeeRecord);
                }
                else{
                    return 'Wrong File have been inserted';
                }
            }
            
            List<Bid_Workbench__c> bidworkBenchForDuplicate = [SELECT ID,Order_Item_ID__c, Manufacturer_Name__c, Manufacturer_Part_Number__c, Requested_Delivery_Date__c, Quantity__c
                                                               , ShipTo_DODAAC__c, Delivery_Destination__c
                                                               FROM Bid_Workbench__c WHERE Order_Item_ID__c IN : mapBidWorkbenchInsert.KeySet()];
            
            for(Bid_Workbench__c bw:bidworkBenchForDuplicate){
                IF(mapBidWorkbenchInsert.containsKey(bw.Order_Item_ID__c)){
                    Bid_Workbench__c bidVar = new Bid_Workbench__c();
                    bidVar = mapBidWorkbenchInsert.get(bw.Order_Item_ID__c);
                    bidVar.Id = bw.id;
                    bidVar.Order_Item_ID__c = bw.Order_Item_ID__c;
                    If ( bw.Manufacturer_Name__c != mapBidWorkbenchInsert.get(bw.Order_Item_ID__c).Manufacturer_Name__c){
                        bidVar.Manufacturer_Name__c = bw.Manufacturer_Name__c;
                    }
                    If ( bw.Manufacturer_Part_Number__c != mapBidWorkbenchInsert.get(bw.Order_Item_ID__c).Manufacturer_Part_Number__c){
                        bidVar.Manufacturer_Part_Number__c = bw.Manufacturer_Part_Number__c;
                    }
                    If ( bw.Requested_Delivery_Date__c != mapBidWorkbenchInsert.get(bw.Order_Item_ID__c).Requested_Delivery_Date__c){
                        bidVar.Requested_Delivery_Date__c = bw.Requested_Delivery_Date__c;
                    }
                    If ( bw.Quantity__c != mapBidWorkbenchInsert.get(bw.Order_Item_ID__c).Quantity__c){
                        bidVar.Quantity__c = bw.Quantity__c;
                    }
                    If ( bw.ShipTo_DODAAC__c != mapBidWorkbenchInsert.get(bw.Order_Item_ID__c).ShipTo_DODAAC__c){
                       bidVar.ShipTo_DODAAC__c = bw.ShipTo_DODAAC__c;
                    }
                    If ( bw.Delivery_Destination__c != mapBidWorkbenchInsert.get(bw.Order_Item_ID__c).Delivery_Destination__c){
                       bidVar.Delivery_Destination__c = bw.Delivery_Destination__c;
                    }
                    
                    mapBidWorkbenchInsert.put(bidVar.Order_Item_ID__c, bidVar);
                }   
                
            }
            for (Bid_Workbench__c bidWork : mapBidWorkbenchInsert.values() ) {
                    system.debug(mapBidWorkbenchInsert.size());
                    bidWork.Line_items__c = mapBidWorkbenchInsert.size();
                }
            
            try{
                system.debug('Insert values=====>>size   '+mapBidWorkbenchInsert.size());
                system.debug('limit'+Limits.getHeapSize());
                if(Limits.getHeapSize() >30000){
              
              //  database.executeBatch(new workbenchTrigger_handler(mapBidWorkbenchInsert.values())); 
                     upsert mapBidWorkbenchInsert.values();
                }
                else{
                    upsert mapBidWorkbenchInsert.values();
                }
               
                return 'Records have been Successfully Created';
                
                
            } catch(Exception e) {
                System.debug('Insert Exception::::'+e.getMessage()); 
                return 'Error While Creating Records';
                
                
            }   
            
        }
        
        if(FileNameOfExcel.containsIgnoreCase('Award')){
            String csvAsString;
            String[] csvFileLines;
            System.debug('blobData:::'+blobData);
            csvAsString = blobData.toString();
            system.debug('Before JSON Formator csvAsString Award::' + csvAsString);
            
            String csvAsString1 = jsonFormator(csvAsString);
            
            System.debug('After JSON Formator csvAsString1::'+csvAsString1);
            
            List<JSON2ApexController> objList = JSON2ApexController.parse(csvAsString1);
            System.debug('After JSON deserialize objList::'+objList);
            System.debug('objList[0]::'+objList[0]);
            
            
            
            List<Award_WorkBench__c> batchEmployeeList = new List<Award_WorkBench__c>();
            Map<String,Award_WorkBench__c> mapAwardWorkbenchInsert = new Map<String,Award_WorkBench__c>();
            
            
            for(JSON2ApexController item: objList) {
                
                
                if(item.OrderItemID != NULL)  {
                    System.debug('Award Order Item Id'+item.OrderItemID);
                    Award_WorkBench__c award = new Award_WorkBench__c();            
                    
                    award.Vendor_ID__c = item.VendorId;
                    award.Unit_of_Issue__c = item.UnitofIssue;
                    award.QUANTITY__c = String.valueOf(item.quantity);
                    award.Purchase_Unit_Price__c = item.PurchaseUnitPrice;
                    award.Purchase_Extended_Price__c = item.PurchaseExtendedPrice;
                    award.Burdened_Unit_Price__c = item.BurdenedUnitPrice;
                    award.Lead_Time__c = item.LeadTime;
                    award.Record_Source__c='ServiceNow';
                    
                    if(item.OrderDate != NULL){
                        String inputDateTimeString = String.valueOf(item.OrderDate);                                
                        Integer year = Integer.valueOf(inputDateTimeString.substring(6, 10));
                        Integer day = Integer.valueOf(inputDateTimeString.substring(3, 5));
                        Integer month = Integer.valueOf(inputDateTimeString.substring(0, 2));
                        
                        Date parsedDate = Date.newInstance(year, month, day);
                        award.Order_Date__c = parsedDate;
                        System.debug('After Converting Order Date Time parsedDate'+ parsedDate);
                        System.debug('After Converting Order Date Time award.Order_Date__c'+award.Order_Date__c);
                    }
                    
                    
                    if(item.RequiredDeliveryDate != NULL){
                        award.Required_Delivery_Date__c =  convertExcelDateNumToApexDate(item.RequiredDeliveryDate);
                    }
                    
                    award.Ordering_DODAAC__c = item.OrderingDODAAC;
                    award.Supplementary_BillTo_DODAAC__c = item.SupplementaryBillToDODAAC;
                    award.POC_Name__c = item.POCName;                   
                   
                    award.POC_Phone__c = item.POCPhone;
                    
                    if( item.POCEmail!=null){
                    if(item.POCEmail.containsWhitespace() && !item.POCEmail.contains(';') ){
                        award.POC_Email__c = item.POCEmail.replaceAll('\\s+',';');
                    }
                    else{
                        award.POC_Email__c = item.POCEmail;
                    }
                    }
                    award.Fund_Code__c = item.FundCode;
                    award.Signal_Code__c = item.SignalCode;
                    award.MIPR_Code__c = item.MIPRCode;
                    award.Credit_Card_Profile_Code__c = item.CreditCardProfileCode;
                    award.Requisition_Number__c = item.RequisitionNumber;
                    award.Requisition_Suffix_Code__c = item.RequisitionSuffixCode;
                    award.Customer_PO_Number__c = item.CustomerPONumber;
                    award.Contractor_Control_Number__c = item.ContractorControlNumber;
                    award.RFQ_Number__c = item.RFQNumber;
                    award.Name = item.OrderItemID;
                    award.Award_Number__c = item.AwardNumber;
                    award.Contract_Number__c = item.ContractNumber;
                   // award.Delivery_Order_Number__c = item.OrderNumber;
                    
                    if(item.ReceiptPOCEmail!=null){
                    if(item.ReceiptPOCEmail.containsWhitespace()){
                        award.Receipt_POC_Email__c = item.ReceiptPOCEmail.replaceAll('\\s+',';');
                    }
                    else{
                        award.Receipt_POC_Email__c = item.ReceiptPOCEmail; 
                    }
                    }
                    
                    award.TLSP_Vendor_Part_Number__c = item.TLSPVendorPartNumber;
                    award.Manufacturer_Name__c = item.ManufacturerName;
                    award.Manufacturer_Part_Number__c = item.ManufacturerPartNumber;
                    award.Item_Description__c = item.ItemDescription;
                    award.Additional_Information__c = item.AdditionalInformation;
                    award.Unit_of_Issue__c = item.UnitofIssue;
                    award.Delivery_Destination__c = item.DeliveryDestination;
                    award.ShipTo_DODAAC__c = item.ShipToDoDAAC;
                    award.FOB_Origin__c = item.FOBOrigin;
                    award.Purchase_Unit_Price__c = item.PurchaseUnitPrice;
                    award.Load_Batch_Number__c = item.LoadBatchNumber;
                    award.Special_Project_Code__c = item.SpecialProjectCode;
                    award.Purchase_Extended_Price__c = item.PurchaseExtendedPrice;
                    award.Lead_Time__c = item.LeadTime;   
                    award.Order_Item_ID__c = item.OrderItemID;
                    award.TLSP_Vendor_Extension__c = item.TLSPVendorExtension;
                    award.Item_is_a_Alternate__c = item.ItemIsaAlternate;
                    award.POC_Unit__c = item.POCUnit;
                    
                    batchEmployeeList.add(award); 
                    mapAwardWorkbenchInsert.put(award.Order_Item_ID__c,award);
                }
                else{
                    return 'Wrong File have been inserted';
                }
            }
            System.debug('mapAwardWorkbenchInsert Map'+mapAwardWorkbenchInsert.KeySet());
            List<Award_WorkBench__c> bidworkBenchForDuplicate = [SELECT ID, Order_Item_ID__c
                                                                 FROM Award_WorkBench__c WHERE Order_Item_ID__c IN : mapAwardWorkbenchInsert.KeySet()];
            System.debug('bidworkBenchForDuplicate'+bidworkBenchForDuplicate);
            for(Award_WorkBench__c bw:bidworkBenchForDuplicate){
                IF(mapAwardWorkbenchInsert.containsKey(bw.Order_Item_ID__c)){
                    system.debug('bw.Order_Item_ID__c'+bw.Order_Item_ID__c);
      
                   
                    
                   mapAwardWorkbenchInsert.remove(bw.Order_Item_ID__c);
                    
                    return 'Duplicate Records Have Been Found While Creating Records';
                    
                }        
            }
            
            try{
                
               upsert mapAwardWorkbenchInsert.values();
             
                return 'Records have been Successfully Created';
                
                
            } catch(Exception e) {
                System.debug('Insert Exception::::'+e.getMessage()); 
                return 'Error While Creating Records';
                
                
            }   
            
            
        }
        
        return 'Error While Creating Records';
    }
    
    public static List<JSON2ApexController> parse(String jsonString) {
        return (List<JSON2ApexController>) System.JSON.deserialize(jsonString, List<JSON2ApexController>.class);
    } 
    
    public class JSON2ApexController {
        
        public String VendorId;
        public String TLSPVendorExtension;
        public String RegionGroup;
        public String Region;
        public String RequestType;
        public String OrderItemID;
        public String ManufacturerName;
        public String ManufacturerPartNumber;
        public String ItemDescription;
        public String AdditionalInformation;
        public String RequestedDeliveryDate;
        public String UnitofIssue;
        public decimal Quantity;
        
        public String DeliveryDestination;
        public String ShipToDoDAAC;
        public String FOBOrigin;
        public String RFIDRequired;
        public String PurchaseUnitPrice;
        public String CustomerPermitsAlternates;
        public String QuoteNumber;
        public string LoadBatchNumber;
        
        public string CoreListNumber;
        public string NSN;
        public string TLSPVendorPartNumber;
        public string SpecialProjectCode;
        public string TransportationPriceRequired;
        public string TransportationPrice;
        public string VendorUnitPrice;
        public string PurchaseExtendedPrice;
        public string LeadTime;
        public string TradeAgreementCompliant;
        public string Comments;
        public string BerryAmendmentCompliant;
        public string CountryofOrigin;
        public string AlternateCoreListNumber;
        public string AlternateNSN;
        public string AlternateManufacturerName;
        public string AlternateManufacturerPartNumber;
        public string AlternateItemDescription;
        public string AlternateTLSPVendorPartNumber;
        public string AlternateTransportationPrice;
        public string AlternateVendorUnitPrice;
        public string AlternatePurchaseExtendedPrice;
        public string AlternatePurchaseUnitPrice;
        public string AlternateTradeAgreementCompliant;
        public string AlternateLeadTime;
        public string AlternateComments;
        
        public string AlternateBerryAmendmentCompliant;
        public String QuoteDueDate;
        public string AlternateCountryofOrigin;
        
        public string ItemIsaAlternate;
        public string BurdenedUnitPrice;
        public String OrderDate;
        public string RequiredDeliveryDate;
        public string OrderingDODAAC;
        public string SupplementaryBillToDODAAC;
        public string POCName;
        public string POCUnit;
        public string POCPhone;
        public string POCEmail;
        public string FundCode;
        public string SignalCode;
        public string MIPRCode;
        public string CreditCardProfileCode;
        public string RequisitionNumber;
        public string RequisitionSuffixCode;
        public string ContractorControlNumber;
        public string CustomerPONumber;
        public string RFQNumber;
        public string AwardNumber;
        public string ContractNumber;
        public string ReceiptPOCEmail;
        public string OrderNumber;
        
        //For RFQ New
        public string IntendedUse;
        public string Timeframe;
        public string City;
        public string State;
        public string Country;
        public string ZipCode;
        public string AlternateItemOffered;
        public string POCLastName;
        public string POCFirstName;
        
        
    }
    
 public static String jsonFormator(String jsonString) {
    System.debug('Current heap size: ' + Limits.getHeapSize() + ' out of ' + Limits.getLimitHeapSize());

    Map<String, String> replacements = new Map<String, String>{
        'Vendor ID' => 'VendorId',
        'TLSP Vendor Extension' => 'TLSPVendorExtension',
        'Region Group' => 'RegionGroup',
        'Request Type' => 'RequestType',
        'Core List Number' => 'CoreListNumber',
        'TLSP Vendor Part Number' => 'TLSPVendorPartNumber',
        'Order Item ID' => 'OrderItemID',
        'Order Line Item Number' => 'OrderItemID',
        'Manufacturer Name' => 'ManufacturerName',
        'Manufacturer Part Number' => 'ManufacturerPartNumber',
        'Item Description' => 'ItemDescription',
        'Additional Information' => 'AdditionalInformation',
        'Additional Item Information' => 'AdditionalInformation',
        'Requested Delivery Date' => 'RequestedDeliveryDate',
        'Unit of Issue' => 'UnitofIssue',
        'Delivery Destination' => 'DeliveryDestination',
        'Delivery Address' => 'DeliveryDestination',
        'ShipTo DODAAC' => 'ShipToDoDAAC',
        'ShipTo DoDAAC' => 'ShipToDoDAAC',
        'Ship To DoDAAC' => 'ShipToDoDAAC',
        'FOB Origin' => 'FOBOrigin',
        'RFID Required' => 'RFIDRequired',
        'Purchase Unit Price' => 'PurchaseUnitPrice',
        'Customer Permits Alternates' => 'CustomerPermitsAlternates',
        'Quote Number' => 'QuoteNumber',
        'Load Batch Number' => 'LoadBatchNumber',
        'Special Project Code' => 'SpecialProjectCode',
        'Transportation Price Required' => 'TransportationPriceRequired',
        'Transportation Price' => 'TransportationPrice',
        'Vendor Unit Price' => 'VendorUnitPrice',
        'Purchase Extended Price' => 'PurchaseExtendedPrice',
        'Lead Time' => 'LeadTime',
        'Lead Time(Days)' => 'LeadTime',
        'Trade Agreement Compliant' => 'TradeAgreementCompliant',
        'TAA Compliant (if applicable)' => 'TradeAgreementCompliant',
        'Berry Amendment Compliant' => 'BerryAmendmentCompliant',
        'Berry Compliant (if applicable)' => 'BerryAmendmentCompliant',
        'Country of Origin' => 'CountryofOrigin',
        'Alternate Core List Number' => 'AlternateCoreListNumber',
        'Alternate NSN' => 'AlternateNSN',
        'Alternate Manufacturer Name' => 'AlternateManufacturerName',
        'Alternate Manufacturer Part Number' => 'AlternateManufacturerPartNumber',
        'Alternate Item Description' => 'AlternateItemDescription',
        'Alternate TLSP Vendor Part Number' => 'AlternateTLSPVendorPartNumber',
        'Alternate Transportation Price' => 'AlternateTransportationPrice',
        'Alternate Vendor Unit Price' => 'AlternateVendorUnitPrice',
        'Alternate Purchase Unit Price' => 'AlternatePurchaseUnitPrice',
        'Alternate Purchase Extended Price' => 'AlternatePurchaseExtendedPrice',
        'Alternate Lead Time' => 'AlternateLeadTime',
        'Alternate Comments' => 'AlternateComments',
        'Alternate Trade Agreement Compliant' => 'AlternateTradeAgreementCompliant',
        'Alternate Berry Amendment Compliant' => 'AlternateBerryAmendmentCompliant',
        'Alternate Country of Origin' => 'AlternateCountryofOrigin',
        'Quote Due Date' => 'QuoteDueDate',
        'Respond By Date' => 'QuoteDueDate',
        'Item is a Alternate' => 'ItemIsaAlternate',
        'Burdened Unit Price' => 'BurdenedUnitPrice',
        'Order Date' => 'OrderDate',
        'Required Delivery Date' => 'RequiredDeliveryDate',
        'Ordering DODAAC' => 'OrderingDODAAC',
        'Supplementary BillTo DODAAC' => 'SupplementaryBillToDODAAC',
        'POC Name' => 'POCName',
        'Receipt POC Email' => 'ReceiptPOCEmail',
        'Fund Code' => 'FundCode',
        'Signal Code' => 'SignalCode',
        'MIPR Code' => 'MIPRCode',
        'Credit Card Profile Code' => 'CreditCardProfileCode',
        'Requisition Number' => 'RequisitionNumber',
        'Requisition Suffix Code' => 'RequisitionSuffixCode',
        'Customer PO Number' => 'CustomerPONumber',
        'Contractor Control Number' => 'ContractorControlNumber',
        'RFQ Number' => 'RFQNumber',
        'Award Number' => 'AwardNumber',
        'Contract Number' => 'ContractNumber',
        'Order Number' => 'OrderNumber',
        'Intended Use' => 'IntendedUse',
        'Timeframe  (Routine, Urgent, Emergency)' => 'Timeframe',
        'State/Province/Region' => 'State',
        'ZIP/Postal Code' => 'ZipCode',
        'Alternate Item Offered?' => 'AlternateItemOffered',
        ' POC First Name' => 'POCFirstName'.normalizeSpace(),
        ' POC Last Name' => 'POCLastName'.normalizeSpace(),
        ' POC Unit' => 'POCUnit'.normalizeSpace(),
        ' POC Phone' => 'POCPhone'.normalizeSpace(),
        ' POC Email' => 'POCEmail'.normalizeSpace(),
        'POC First Name' => 'POCFirstName',
        'POC Last Name' => 'POCLastName',
        'POC Unit' => 'POCUnit',
        'POC Phone' => 'POCPhone',
        'POC Email' => 'POCEmail'
    };

    for (String key : replacements.keySet()) {
        jsonString = jsonString.replace(key, replacements.get(key));
    }


    return jsonString;
}


    
    public static Date convertExcelDateNumToApexDate(String inputNumberFromExcel){
        
        if(inputNumberFromExcel.contains('.')){           
            
            String beforeDecimalPoint = inputNumberFromExcel.substringBefore('.');
            
            
            //For Days
            Integer daysNumber = Integer.valueOf(beforeDecimalPoint);            
            
            Date myDate = Date.newInstance(1900,1,1); 
            Date newDate = myDate.addDays(daysNumber - 2);              
            
            
            return newDate;
            
        }
        
        ///////////////////////////////////////////////////////
        
        
        if(!inputNumberFromExcel.contains('.')){
            Integer convertStrToInt = Integer.valueOf(inputNumberFromExcel);
            
            Date myDate = Date.newInstance(1900, 1, 1);        
            Date newDate = myDate.addDays(convertStrToInt - 2);    
            
            return newDate;
        }
        
        return NULL;
    }
    
    public static Datetime convertExcelDateTimeDecimalToApexDateTime(String inputDecimalFromExcel){
        
        
        string srt1= inputDecimalFromExcel.substringBefore('.');
        system.debug(srt1);
        string srt2 = inputDecimalFromExcel.substringAfter('.');
        system.debug(srt2);
        
        
        // For Days
        Integer daysNumber = Integer.valueOF(srt1);
        
        //  For Time
        string hoursNumber ='0.'+srt2;
        double finalHoursNumber = double.ValueOf(hoursNumber)*24*60;
        Decimal varNumber = Decimal.valueOf(finalHoursNumber);
        Integer finalNumber = Math.round(varNumber);
        
        Datetime myDateTime = DateTime.newInstance(1900,1,1,0,0,0); 
        Datetime newDateTime = myDateTime.addDays(daysNumber - 2);   
        IF(finalNumber>0){
            IF(math.mod(finalNumber,60) == 0){
                newDateTime = newDateTime.addMinutes(finalNumber - 60);
            }else{
                newDateTime = newDateTime.addMinutes(finalNumber - 60);
                
            }
            
        }
        
        
        return newDateTime;
        
        
        
    } 
    
    public static date returnDate(String inputDateTimeString02) {
        Integer year02 = Integer.valueOf(inputDateTimeString02.substring(6, 10));
        Integer day02 = Integer.valueOf(inputDateTimeString02.substring(3, 5));
        Integer month02 = Integer.valueOf(inputDateTimeString02.substring(0, 2));
        return Date.newInstance(year02, month02, day02);
    }

      
    
}