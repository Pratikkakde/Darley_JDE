/******************************************************************************************************************************************************
Name                    : workbenchTrigger_handler
Author                  : Melonleaf
Purpose                 : This  class is written to reassign the values of bid workbench, counting the number of workbench record related to one rfq and
                          when record is being updated then creating the task for the Rfq owner and also implementing the queable so if the 
                          excelImportController has more than 30000 heap size so we will call this queuable.

Description             :This  class is written to reassign the values of bid workbench, counting the number of workbench record reclated to one rfq and
                         then record is being updated then creating the task for the Rfq owner and also implementing the queable so if the 
                         excelImportController has more than 30000 heap size so we will call this queuable.
Version                 : 1.0
Change Log              : 
Test Class              : workbenchTrigger_handlerTest
CreateDate              : 25-05-2024
LastModifiedDate        : 25-05-2024
******************************************************************************************************************************************************/
public class workbenchTrigger_handler  {
    public static Boolean isBidWorkBenchTrigger = true;
 
    
    
/******************************************************************************************************************************************************
    This  method is written to reassign the values of bid workbench when record source is CSV
******************************************************************************************************************************************************/
    
    public static void ReAssignData(List<Bid_Workbench__c> newRecords) {
        system.debug('newRecords'+newRecords);
        List<Bid_Workbench__c> WorkBenchRecordInsertList = new List<Bid_Workbench__c>();
        
        for (Bid_Workbench__c record : newRecords) {
            if(record.Record_Source__c=='CSV'){
                
                if(record.Alternate_Manufacturer_Name__c != Null && record.Alternate_Manufacturer_Part_Number__c != Null ){
                    record.Alternate_Item_Offered__c ='Yes';
                }
                
                //FOB Origin
                if(record.FOB_Origin__c != Null && record.FOB_Origin__c == 'N'){
                    record.FOB_Origin__c = 'No';
                }
                
                if(record.FOB_Origin__c != Null && record.FOB_Origin__c == 'Y'){
                    record.FOB_Origin__c = 'Yes';
                }
                //RFID Required
                if(record.RFID_Required__c != Null && record.RFID_Required__c == 'N'){
                    record.RFID_Required__c = 'No';
                }
                if(record.RFID_Required__c != Null && record.RFID_Required__c == 'Y'){
                    record.RFID_Required__c = 'Yes';
                }
                //customer Permits Alternate
                if(record.Customer_Permits_Alternates__c != Null && record.Customer_Permits_Alternates__c == 'N'){
                    record.Customer_Permits_Alternates__c = 'No';
                }
                if(record.Customer_Permits_Alternates__c != Null && record.Customer_Permits_Alternates__c == 'Y'){
                    record.Customer_Permits_Alternates__c = 'Yes';
                }
                if(record.ServiceNow_RFQ_Program__c != Null && record.TLSP_Vendor_Extension__c == 'DAR'){
                    record.ServiceNow_RFQ_Program__c = 'SOE Tents';
                    
                }
                
                else if(record.TLSP_Vendor_Extension__c == 'DAR' && record.ServiceNow_RFQ_Program__c == Null ){
                    record.ServiceNow_RFQ_Program__c = 'TLS SOE';
                    
                }
                else if(record.TLSP_Vendor_Extension__c == 'WSD' && record.ServiceNow_RFQ_Program__c == Null){
                    record.ServiceNow_RFQ_Program__c = 'TLS FES';
                 }
                
            }  
            
            WorkBenchRecordInsertList.add(record);
        }
    }
/******************************************************************************************************************************************************
   This method is written to count the number of workbench record related to one rfq 
******************************************************************************************************************************************************/
    
    public static void LineItemCount(List<Bid_Workbench__c> workbenchRecordList) {
        
        Set<String> setQuoteNumber = new  Set<String>();
        If(!workbenchRecordList.isEmpty()){
            For(Bid_Workbench__c bidWorkVar : workbenchRecordList){
                If(bidWorkVar.Quote_Number__c!= null){
                    setQuoteNumber.add(bidWorkVar.Quote_Number__c);
                }
            }
        }
        
        Map<String, Integer> countMap = new Map<String, Integer>(); 
        If(!setQuoteNumber.isEmpty()){
            for (AggregateResult bid :    [SELECT COUNT(Id) quoteCount, Quote_Number__c quoteNumber FROM Bid_WorkBench__c  WHERE  Quote_Number__c IN: setQuoteNumber  GROUP BY Quote_Number__c ]) {
                countMap.put((String)bid.get('quoteNumber'), (Integer)bid.get('quoteCount'));
            } 
        }
        
        
        system.debug('countMap: ' + countMap);
        
        List<Bid_Workbench__c> bidWorkbenchToUpdate = new List<Bid_Workbench__c>();
        for (Bid_Workbench__c bid : [SELECT Id, Quote_Number__c, Line_items__c FROM Bid_Workbench__c WHERE  Quote_Number__c IN: setQuoteNumber  ]) {
            if (countMap.containsKey(bid.Quote_Number__c) ) {
                If (bid.Line_items__c != countMap.get(bid.Quote_Number__c)){
                    bid.Line_items__c = countMap.get(bid.Quote_Number__c);
                    bidWorkbenchToUpdate.add(bid);
                }
               
            }
        }
        
        // Update records with the new count
        if (!bidWorkbenchToUpdate.isEmpty()) {
            workbenchTrigger_handler.isBidWorkBenchTrigger= false;
            update bidWorkbenchToUpdate;
        }
    }
    
    
/******************************************************************************************************************************************************
 This method is written to to check the old and new values with bidline item object correspoing to OrdelineItem number and creating the task when value got update
******************************************************************************************************************************************************/
    
    public static void updatetheBidLineFields(List<Bid_Workbench__c> newListBidWork , Map<Id,Bid_Workbench__c> mapOldBidWorkRec ) {
        Map<String , Bid_Workbench__c> mapStrBidWork = new Map<String , Bid_Workbench__c>();
        Map<String, Task> mapStrTaskInsert =  new Map<String, Task>();
        If(!newListBidWork.isEmpty()){
            For (Bid_Workbench__c varBidWork :  newListBidWork ) {
                system.debug(varBidWork.Country__c);
                If ( varBidWork.Manufacturer_Name__c != mapOldBidWorkRec.get(varBidWork.Id).Manufacturer_Name__c ) {
                    Task newTask = new Task();
                    newTask.Subject = 'The following Bid Line Items Fields values are  getting change by Service Now : Manufacturer_Name' ;
                    newTask.Description = 'The Manufacturer_Name is getting change from   : ' + mapOldBidWorkRec.get(varBidWork.Id).Manufacturer_Name__c +' to '+ varBidWork.Manufacturer_Name__c;
                    newTask.Status = 'Not Started';
                    newTask.Priority = 'Normal';
                    // newTask.WhatId = bidvar.Rfq_number__c;
                    newTask.ActivityDate= system.today().addDays(1);
                    // newTask.OwnerId = bidvar.Rfq_number__r.OwnerId; // Assign task to rfq  owner
                    newTask.IsReminderSet	=true;
                    newTask.ReminderDateTime =system.today();
                    If (varBidWork.Quote_Number__c != null) {     
                        mapStrTaskInsert.put(varBidWork.Quote_Number__c.removeStart('RFQ'), newTask );
                        system.debug(mapStrTaskInsert);
                        system.debug(varBidWork.Manufacturer_Name__c);
                        system.debug(mapOldBidWorkRec.get(varBidWork.Id).Manufacturer_Name__c );
                        
                    }
                    
                    mapStrBidWork.put(varBidWork.Order_Item_ID__c, varBidWork);
                    system.debug(mapStrBidWork);
                    
                } 
                if ((varBidWork.ShipTo_DODAAC__c != mapOldBidWorkRec.get(varBidWork.Id).ShipTo_DODAAC__c || varBidWork.Delivery_Destination__c != mapOldBidWorkRec.get(varBidWork.Id).Delivery_Destination__c ||
                     varBidWork.City__c != mapOldBidWorkRec.get(varBidWork.Id).City__c || varBidWork.State__c != mapOldBidWorkRec.get(varBidWork.Id).State__c ||
                     varBidWork.Zip_Code__c != mapOldBidWorkRec.get(varBidWork.Id).Zip_Code__c || varBidWork.Country__c != mapOldBidWorkRec.get(varBidWork.Id).Country__c ||
                     varBidWork.Quantity__c != mapOldBidWorkRec.get(varBidWork.Id).Quantity__c ||varBidWork.ServiceNow_Quote_Item_Number_DLA__c != mapOldBidWorkRec.get(varBidWork.Id).ServiceNow_Quote_Item_Number_DLA__c ||
                     varBidWork.Manufacturer_Part_Number__c != mapOldBidWorkRec.get(varBidWork.Id).Manufacturer_Part_Number__c || varBidWork.serviceNow_RFQ_Stage__c != mapOldBidWorkRec.get(varBidWork.Id).serviceNow_RFQ_Stage__c ||
                     varBidWork.Quote_Due_Date__c != mapOldBidWorkRec.get(varBidWork.Id).Quote_Due_Date__c || varBidWork.ServiceNow_Vendor_Assign_To__c != mapOldBidWorkRec.get(varBidWork.Id).ServiceNow_Vendor_Assign_To__c ||
                     varBidWork.ServiceNow_RFQ_Updated_On__c != mapOldBidWorkRec.get(varBidWork.Id).ServiceNow_RFQ_Updated_On__c || varBidWork.ServiceNow_Quote_Status__c != mapOldBidWorkRec.get(varBidWork.Id).ServiceNow_Quote_Status__c ||
                     varBidWork.Additional_Information__c != mapOldBidWorkRec.get(varBidWork.Id).Additional_Information__c  ||  varBidWork.Vendor_Representative__c	 != mapOldBidWorkRec.get(varBidWork.Id).Vendor_Representative__c  ||
                     varBidWork.ServiceNow_RFQ_Updated_By__c != mapOldBidWorkRec.get(varBidWork.Id).ServiceNow_RFQ_Updated_By__c ||  varBidWork.Order_Stage__c != mapOldBidWorkRec.get(varBidWork.Id).Order_Stage__c )
                    && varBidWork.Processed__c == true  ) {
                        
                        mapStrBidWork.put(varBidWork.Order_Item_ID__c, varBidWork);
                    }
                
            }
        }
        System.debug('mapStrBidWork.keySet() ---> '+mapStrBidWork.keySet());
        Map<Id, Bid_lIne_Item__c> mapIdBidLineUpdate = new Map<Id, Bid_lIne_Item__c>();
        Map<Id, Bid_Tracker__c> mapIdBidTRackerUpdate = new Map<Id, Bid_Tracker__c>();
        Map<string, Task> mapStrGRpTaskInsert = new Map<string, Task>();
        for (Bid_line_Item__c bidvar : [SELECT Id, Ship_To_DoDAAC__c, Delivery_Address__c, City__c, ServiceNow_State__c, ZIP_Postal_Code__c, Country__c,DoDAAC_Number_Text__c, 
                                        Supplier_Part_Number__c, Quantity__c, Status__c,Quote_Numbers__c, Bid_Group_Items__c, Name, ServiceNow_Quote_Item_Number_DLA__c,
                                        RFQ_Number__c, RFQ_Number__r.Rfq_Stage_ServiceNow__c, RFQ_Number__r.Due_Date__c, RFQ_Number__r.Vendor_Assign_To_ServiceNow__c,
                                        RFQ_Number__r.Updated_On_serviceNow__c, RFQ_Number__r.Updated_By_serviceNow__c, RFQ_Number__r.Quote_Status_ServiceNow__c, RFQ_Number__r.OwnerId,
                                        RFQ_Number__r.Additional_Information_for_Vendors__c, Line_Item_ID__c, Rfq_number__r.Name
                                        FROM Bid_Line_Item__c WHERE Line_Item_ID__c In : mapStrBidWork.keySet() ]) {
                                            // if the manufa name is change 
                                            If(mapStrTaskInsert.containsKey(bidvar.Line_Item_ID__c)){
                                                mapStrTaskInsert.get(bidvar.Line_Item_ID__c).WhatId = bidvar.RFQ_Number__c;
                                                
                                                
                                            }
                                            
                                            String subjectrfe;
                                            Bid_Tracker__c trackVar = new Bid_Tracker__c(); 
                                            trackVar.Id = bidvar.RFQ_Number__c;
                                            trackVar.Rfq_Stage_ServiceNow__c = mapStrBidWork.get(bidvar.Line_Item_ID__c).serviceNow_RFQ_Stage__c; 
                                            If ( bidvar.Status__c != 'RFQ Ready for DLA' || bidvar.Status__c != 'Sent to DLA' || bidvar.Status__c != 'Awarded' ) {
                                                trackVar.Due_Date__c = mapStrBidWork.get(bidvar.Line_Item_ID__c).Quote_Due_Date__c;
                                            } Else {
                                                subjectrfe = 'The RFQ Due Date is change by DLA to  .'+mapStrBidWork.get(bidvar.Line_Item_ID__c).Quote_Due_Date__c;
                                            }
                                            trackVar.Vendor_Assign_To_ServiceNow__c = mapStrBidWork.get(bidvar.Line_Item_ID__c).ServiceNow_Vendor_Assign_To__c;
                                            trackVar.Updated_On_serviceNow__c = mapStrBidWork.get(bidvar.Line_Item_ID__c).ServiceNow_RFQ_Updated_On__c;
                                            trackVar.Updated_By_serviceNow__c = mapStrBidWork.get(bidvar.Line_Item_ID__c).ShipTo_DODAAC__c; 
                                            trackVar.Quote_Status_ServiceNow__c = mapStrBidWork.get(bidvar.Line_Item_ID__c).ServiceNow_Quote_Status__c;
                                            trackVar.Additional_Information_for_Vendors__c = mapStrBidWork.get(bidvar.Line_Item_ID__c).Additional_Information__c;
                                            trackVar.Quote_Number__c = mapStrBidWork.get(bidvar.Line_Item_ID__c).Quote_Number__c;
                                            trackVar.Order_Stage__c = mapStrBidWork.get(bidvar.Line_Item_ID__c).Order_Stage__c; 
                                            trackVar.Vendor_Representative__c = mapStrBidWork.get(bidvar.Line_Item_ID__c).Vendor_Representative__c; 
                                            
                                            mapIdBidTRackerUpdate.put(trackVar.Id, trackVar);
                                            bidvar.ServiceNow_Quote_Item_Number_DLA__c = mapStrBidWork.get(bidvar.Line_Item_ID__c).ServiceNow_Quote_Item_Number_DLA__c;
                                            
                                            if (bidvar.Status__c == 'New'){  
                                                bidvar.DoDAAC_Number_Text__c = mapStrBidWork.get(bidvar.Line_Item_ID__c).ShipTo_DODAAC__c; 
                                                bidvar.Delivery_Address__c = mapStrBidWork.get(bidvar.Line_Item_ID__c).Delivery_Destination__c; 
                                                bidvar.City__c = mapStrBidWork.get(bidvar.Line_Item_ID__c).City__c;
                                                bidvar.ServiceNow_State__c = mapStrBidWork.get(bidvar.Line_Item_ID__c).State__c;
                                                bidvar.ZIP_Postal_Code__c = mapStrBidWork.get(bidvar.Line_Item_ID__c).Zip_Code__c; 
                                                bidvar.Country__c = mapStrBidWork.get(bidvar.Line_Item_ID__c).Country__c; 
                                                bidvar.Supplier_Part_Number__c = mapStrBidWork.get(bidvar.Line_Item_ID__c).Manufacturer_Part_Number__c; 
                                                bidvar.Quantity__c = mapStrBidWork.get(bidvar.Line_Item_ID__c).Quantity__c;
                                                     
                                                
                                            } else {
                                                String fielsChange;
                                                
                                                If (bidvar.DoDAAC_Number_Text__c != mapStrBidWork.get(bidvar.Line_Item_ID__c).ShipTo_DODAAC__c ){
                                                    fielsChange = 'Ship_To_DoDAAC  ';
                                                }
                                                
                                                If (bidvar.Delivery_Address__c != mapStrBidWork.get(bidvar.Line_Item_ID__c).Delivery_Destination__c){
                                                    fielsChange = fielsChange == null ? 'Delivery_Address' : fielsChange + ', Delivery_Address ';
                                                }  
                                                If (bidvar.City__c != mapStrBidWork.get(bidvar.Line_Item_ID__c).City__c){
                                                    fielsChange = fielsChange == null ? 'City ' : fielsChange + ', City ';
                                                } 
                                                If ( bidvar.ServiceNow_State__c != mapStrBidWork.get(bidvar.Line_Item_ID__c).State__c){
                                                    
                                                    fielsChange = fielsChange == null ? 'ServiceNow_State' : fielsChange + ', ServiceNow_State ';
                                                } 
                                                If ( bidvar.ZIP_Postal_Code__c != mapStrBidWork.get(bidvar.Line_Item_ID__c).Zip_Code__c){
                                                    
                                                    fielsChange = fielsChange == null ? 'ZIP_Postal_Code' : fielsChange + ', ZIP_Postal_Code ';
                                                    
                                                } 
                                                system.debug(bidvar.Country__c);
                                                system.debug(mapStrBidWork.get(bidvar.Line_Item_ID__c).Country__c);
                                                If (bidvar.Country__c != mapStrBidWork.get(bidvar.Line_Item_ID__c).Country__c){
                                                    system.debug('Inside for If'+fielsChange);
                                                    fielsChange = fielsChange == null ? 'Country' : fielsChange + ', Country ';
                                                    system.debug('Inside for If'+fielsChange);
                                                } 
                                                If (bidvar.Supplier_Part_Number__c != mapStrBidWork.get(bidvar.Line_Item_ID__c).Manufacturer_Part_Number__c){
                                                    
                                                    fielsChange = fielsChange == null ? 'Supplier_Part_Number' : fielsChange + ', Supplier_Part_Number ';
                                                } 
                                                If (bidvar.Quantity__c != mapStrBidWork.get(bidvar.Line_Item_ID__c).Quantity__c){
                                                    
                                                    fielsChange = fielsChange == null ? 'Quantity' : fielsChange + ', Quantity ';
                                                }
                                                system.debug('fielsChange====>>>'+fielsChange);
                                                If (!String.isBlank(fielsChange)){
                                                    IF (mapStrGRpTaskInsert.containsKey(bidvar.RFQ_Number__c)){
                                                        mapStrGRpTaskInsert.get(bidvar.RFQ_Number__c).Description = bidvar.Name+'->' +fielsChange ;
                                                        
                                                    } else { 
                                                        Task newTask = new Task();
                                                        If (bidvar.Status__c == 'RFQ Ready for DLA' || bidvar.Status__c == 'Sent to DLA' || bidvar.Status__c == 'Awarded'|| bidvar.Status__c == 'Awaiting Approval' ){
                                                            newTask.Subject = 'BidTracker.Contract_DLA Change Request: “'+bidvar.Quote_Numbers__c+'” – BidLineItem Status (Approved)';
                                                        } else {
                                                            newTask.Subject = 'BidTracker.Contract_DLA Change Request: “'+bidvar.Quote_Numbers__c+'” – BidLineItem Status (Not approved)';
                                                        }
                                                        
                                                        newTask.Description = 'The following Bid Line Items Fields values are  getting change by Service Now  '+ bidvar.Name+'->'+fielsChange ;
                                                        newTask.Status = 'Not Started';
                                                        newTask.Priority = 'Normal';
                                                        newTask.WhatId = bidvar.Rfq_number__c;
                                                        newTask.ActivityDate= system.today().addDays(1);
                                                        newTask.OwnerId = bidvar.Rfq_number__r.OwnerId; // Assign task to rfq  owner
                                                        newTask.IsReminderSet	=true;
                                                        newTask.ReminderDateTime =system.today();
                                                        If (!String.isBlank(subjectrfe) ){
                                                            newTask.Description = subjectrfe + newTask.Description ;
                                                        }
                                                        mapStrGRpTaskInsert.put(bidvar.RFQ_Number__c, newTask);
                                                    }
                                                    
                                                }
                                                
                                            }
                                            mapIdBidLineUpdate.put(bidvar.Id, bidvar);
                                            System.debug('Quote nuber'+bidvar.Quote_Numbers__c);
                                            If (mapStrTaskInsert.containsKey(bidvar.Quote_Numbers__c)) {
                                                Task newTask = new Task();
                                                If (bidvar.Status__c == 'RFQ Ready for DLA' || bidvar.Status__c == 'Sent to DLA' || bidvar.Status__c == 'Awarded'|| bidvar.Status__c == 'Awaiting Approval' ){
                                                    newTask.Subject = 'BidTracker.Contract_DLA Change Request for Manufacturer_Name  : “'+bidvar.Quote_Numbers__c+'” – BidLineItem Status (Approved)';
                                                } else {
                                                    newTask.Subject = 'BidTracker.Contract_DLA Change Request  for Manufacturer_Name : “'+bidvar.Quote_Numbers__c+'” – BidLineItem Status (Not approved)';
                                                }
                                                newTask.Description = 'The Manufacturer_Name is getting change by Service Now  ' + bidvar.Rfq_number__r.Name;
                                                newTask.Status = 'Not Started';
                                                newTask.Priority = 'Normal';
                                                newTask.WhatId = bidvar.Rfq_number__c;
                                                newTask.ActivityDate= system.today().addDays(1);
                                                newTask.OwnerId = bidvar.Rfq_number__r.OwnerId; // Assign task to rfq  owner
                                                newTask.IsReminderSet	=true;
                                                newTask.ReminderDateTime =system.today();
                                                mapStrGRpTaskInsert.put(bidvar.Bid_Group_Items__c, newTask);
                                                
                                            }
                                            
                                        }
        If (!mapIdBidLineUpdate.isEmpty()){
            update mapIdBidLineUpdate.values();
            system.debug('mapIdBidTRackerUpdate.values()'+mapIdBidTRackerUpdate.values());
            update mapIdBidTRackerUpdate.values();
        }
        If (!mapStrGRpTaskInsert.isEmpty()) {
            insert  mapStrGRpTaskInsert.values();
            system.debug( mapStrGRpTaskInsert.values());
        }
        If (!mapStrTaskInsert.isEMpty()) {
            insert  mapStrTaskInsert.values();
        } 
    }  
    
    
/******************************************************************************************************************************************************
 This method is written to upsert the record when ExcelImport Controller has large data i.e if heap size is greater than 30000 than we are calling this queable
/******************************************************************************************************************************************************/
    

 
    
    
}