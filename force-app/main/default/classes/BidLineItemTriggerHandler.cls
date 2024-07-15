/******************************************************************************************************************************************************
Name                    : BidLineItemTriggerHandler
Author                  : Melonleaf


Description             :This class is written to perform update Dml at bid line, bidtracker and Bidgroup
Version                 : 1.0
Change Log              : 
Test Class              : BidLineItemTriggerHandler_test
CreateDate              : 25-05-2024
LastModifiedDate        : 25-05-2024
******************************************************************************************************************************************************/
public  class BidLineItemTriggerHandler {
    
     public static Boolean isBidLineItemTrigger = true;
     public static Boolean isBidLineItemStatus = true;
    
    
        
 /******************************************************************************************************************************************************
   If Supplier PartNumber and Suplier of Bid Line  matches which products Vendor part number and Supplier then we are pulling the cost from that.
   Also checking the Quantity From the metdata and pulling related price.
/******************************************************************************************************************************************************/
    public static void pullingDarleyCostFromPriceBookEntry(List<Bid_line_item__c> lineItemList, Map<Id, Bid_line_item__c> mapOldvalueBidLIne){

        Set<Id> setAcId = new Set<Id>();
        Set<String> setsuppliefrpart = new Set<String>();
        If (mapOldvalueBidLIne == null) {
            For(Bid_line_item__c bidLinevar : lineItemList){
                If(bidLinevar.Sales_Rep__c == null){
                    If(bidLinevar.Bid_Supplier__c != null){
                        setAcId.add(bidLinevar.Bid_Supplier__c);
                    }
                    If(bidLinevar.Supplier_Part_Number__c != null){
                        setsuppliefrpart.add(bidLinevar.Supplier_Part_Number__c);
                    }
                }
            }
        } else {
            for (Bid_line_item__c bidLinevar : lineItemList){
                If(bidLinevar.Sales_Rep__c==null  && (bidLinevar.Unit_Cost__c !=  mapOldvalueBidLIne.get(bidLinevar.id).Unit_Cost__c || 
                                                      bidLinevar.Supplier_Part_Number__c !=  mapOldvalueBidLIne.get(bidLinevar.id).Supplier_Part_Number__c)){
                                                          If(bidLinevar.Bid_Supplier__c != null){
                                                              setAcId.add(bidLinevar.Bid_Supplier__c);
                                                          }
                                                          If(bidLinevar.Supplier_Part_Number__c != null){
                                                              setsuppliefrpart.add(bidLinevar.Supplier_Part_Number__c);
                                                          }
                                                      }
            }
            
        }
     
        Map<String,Pre_Define_Price_Rule_Criteria__mdt>  mapStrPreDefineMDT = new Map<String,Pre_Define_Price_Rule_Criteria__mdt>();
        For (Pre_Define_Price_Rule_Criteria__mdt preDe : [SELECT DeveloperName, MasterLabel, Price_1__c, Price_2__c FROM Pre_Define_Price_Rule_Criteria__mdt] ) {
            mapStrPreDefineMDT.put(preDe.MasterLabel,preDe);
        }

        System.debug('setAcId+++....'+setAcId);
        System.debug('setsuppliefrpart------>.>>'+setsuppliefrpart);
        Map<String,PricebookEntry> mapvendorIdAndVendor = new Map<String,PricebookEntry>();
        Id recordTypePrdDefense = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Defense').getRecordTypeId();
        If(!setAcId.isEmpty() && !setsuppliefrpart.isEmpty()){
            For(PricebookEntry varPriceBook :  [SELECT Price_Effective_From__c, Cost_Last_Updated__c, Discount__c, IsArchived, Product2.Vendor_Account__c, 
                                                    Product2.Vendor_Account__r.Name,
                                               Product2.Vendor_Part_Number__c, ProductCode, SystemModstamp, UseStandardPrice, IsActive, UnitPrice, Product2Id, Pricebook2Id, Name, Id FROM PricebookEntry
                                                WHERE Product2Id In (SELECT Id  FROM Product2 WHERE Vendor_Account__c IN : setAcId AND Vendor_Part_Number__c IN : setsuppliefrpart AND recordTypeId =: recordTypePrdDefense )
                                                AND Pricebook2Id IN (SELECT Id FROM  Pricebook2 WHERE IsStandard = true)  ]){
                                                    mapvendorIdAndVendor.put(varPriceBook.Product2.Vendor_Account__c+varPriceBook.Product2.Vendor_Part_Number__c,varPriceBook);
                                                }  
        }
        If (!mapvendorIdAndVendor.isEmpty()){
            For(Bid_line_item__c bidLinevar : lineItemList){
                If(mapvendorIdAndVendor.containsKey(bidLinevar.Bid_Supplier__c+bidLinevar.Supplier_Part_Number__c)){
                    IF(mapvendorIdAndVendor.get(bidLinevar.Bid_Supplier__c+bidLinevar.Supplier_Part_Number__c).UnitPrice != null){
                        IF (mapStrPreDefineMDT.containsKey(mapvendorIdAndVendor.get(bidLinevar.Bid_Supplier__c+bidLinevar.Supplier_Part_Number__c).Product2.Vendor_Account__r.Name)){
                            
                            IF (bidLinevar.Quantity__c < mapStrPreDefineMDT.get(mapvendorIdAndVendor.get(bidLinevar.Bid_Supplier__c+bidLinevar.Supplier_Part_Number__c).Product2.Vendor_Account__r.Name).Price_1__c ){
                                bidLinevar.Unit_Cost__c = mapvendorIdAndVendor.get(bidLinevar.Bid_Supplier__c+bidLinevar.Supplier_Part_Number__c).UnitPrice;//Standard_Cost__c is Darley cost
                            } else if (bidLinevar.Quantity__c < mapStrPreDefineMDT.get(mapvendorIdAndVendor.get(bidLinevar.Bid_Supplier__c+bidLinevar.Supplier_Part_Number__c).Product2.Vendor_Account__r.Name).Price_2__c) {
                                bidLinevar.Unit_Cost__c = mapvendorIdAndVendor.get(bidLinevar.Bid_Supplier__c+bidLinevar.Supplier_Part_Number__c).Price_1__c;//Standard_Cost__c is Darley cost
                            } else if (bidLinevar.Quantity__c >= mapStrPreDefineMDT.get(mapvendorIdAndVendor.get(bidLinevar.Bid_Supplier__c+bidLinevar.Supplier_Part_Number__c).Product2.Vendor_Account__r.Name).Price_2__c) {
                                bidLinevar.Unit_Cost__c = mapvendorIdAndVendor.get(bidLinevar.Bid_Supplier__c+bidLinevar.Supplier_Part_Number__c).Price_2__c;//Standard_Cost__c is Darley cost
                            }
                            
                        } else {
                            bidLinevar.Unit_Cost__c=mapvendorIdAndVendor.get(bidLinevar.Bid_Supplier__c+bidLinevar.Supplier_Part_Number__c).UnitPrice;//Standard_Cost__c is Darley cost
                        system.debug('Unit Cost '+bidLinevar.Unit_Cost__c);
                        }
                  
                    }
                }
            }
        }
        
        
    }
    
    
    
/******************************************************************************************************************************************************
   If the supplier has Send Questionnarie Checkbox checkbox check then changing the status of bidline item record to hold.
   Criteria : Before Insert 
/******************************************************************************************************************************************************/
     public static void changingTheStatusOfBidLineForQuestionarie( List<Bid_line_item__c> listNewBidlineItem){
       system.debug('listNewBidlineItem-->'+ listNewBidlineItem);
        List<String> mapBidLineLineItemId = new  List<String>();
        set<Id> setIdAccLead = new Set<Id>();
        For (Bid_line_item__c bidVar : listNewBidlineItem  ) {
            If (bidVar.Bid_Supplier__c != null ) {
                setIdAccLead.add(bidVar.Bid_Supplier__c);
            }
           
        }
        Map<Id, Account> mapIdAccount = new Map<Id, Account>([SELECT Id, Email_Address__c , Send_Questionnarie__c from Account where Id In :setIdAccLead and Send_Questionnarie__c=true ]);
        Map<Id,Account> mapIdAccEmailContain = new Map<Id,Account>();
        For ( Account acc : mapIdAccount.values() ) {
            If ( acc.Send_Questionnarie__c == true) {
                mapIdAccEmailContain.put(acc.id, acc);
            }
        }

        If(!listNewBidlineItem.isEmpty()){
            For (Bid_line_item__c bidvar : listNewBidlineItem ) {
                If (mapIdAccEmailContain.containsKey(bidvar.Bid_Supplier__c) ) {
                    bidvar.Status__c ='Hold';
                    system.debug('status-->'+ bidvar.Status__c);
                } 
             
            }
        }
    }
    
     
    
/******************************************************************************************************************************************************
 Creating the Task for Dodaac number Missing, Kitting, for fillig out Questionnaire At Bidtracker and also sending
custom Notification if delvery information is missing to Rfq Owner
Criteria: AFTER INSERT
 ******************************************************************************************************************************************************/
    public static void CreateTheTaskforRFQ(List<Bid_line_item__c> listNewBidlineItem ){
               List<Bid_Line_Item__c> listBidLineReclaate = [Select Id,Bid_Supplier__r.Name,Supplier_Name_Text__c,Quote_Numbers__c,RFQ_Number__c,RFQ_Number__r.Name, Name, Lead__c, Lead__r.Name ,
                                                     DoDAAC_Number_Text__c, Bid_Supplier__c, Lead__r.Company,Bid_Group_Items__c,City__c, ServiceNow_State__c, Country__c,ZIP_Postal_Code__c,Bid_Supplier__r.Send_Questionnarie__c	,
                                                     Ship_To_DoDAAC__c,Ship_To_DoDAAC__r.Name ,Rfq_number__r.OwnerId, Unit_of_Issue__c,Kitting__c, Item_Description__c, Customer_Permits_Alternates__c, Status__c   
                                                      from Bid_Line_Item__c where Id IN: listNewBidlineItem];
        list<Bid_line_item__c>bidlistToUpdate=new list<Bid_line_item__c>();
        Map<Id,Task> mapInsertTask = new Map<Id,Task>();
        CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Missing_Dodaac_Address' limit 1 ];  
        Map<Id,Id> mapIdUserIDOwner = new Map<Id,Id>();
        map<id,task>MapDodaacTask=new map<id,task>();
        If(!listBidLineReclaate.isEmpty()){
            For (Bid_line_item__c bidvar : listBidLineReclaate ){
                IF (bidvar.Unit_of_Issue__c == null ) {
                    bidvar.Unit_of_Issue__c= '';
                }
                  IF (bidvar.Item_Description__c == null ) {
                    bidvar.Item_Description__c= '';
                }
                String subjectTask ;
                If(bidvar.Unit_of_Issue__c == 'KIT (KT)' || bidvar.Unit_of_Issue__c == 'PACKAGE (PG)' || bidvar.Unit_of_Issue__c == 'ASSEMBLY (AY)' || bidvar.Unit_of_Issue__c == 'SET (SE)' || bidvar.Unit_of_Issue__c == 'KT'){
                    subjectTask = 'Contains Kit :'+bidvar.Rfq_number__r.Name;
                    bidvar.kitting__c='Yes';
                    bidlistToUpdate.add(bidvar);
                    
                } else If (bidvar.Item_Description__c.containsIgnoreCase('Bundle') || bidvar.Item_Description__c.containsIgnoreCase('Kit') ||bidvar.Item_Description__c.containsIgnoreCase('Package') ||bidvar.Item_Description__c.containsIgnoreCase('System')){
                    subjectTask = ' Contains Kit :'+bidvar.Rfq_number__r.Name;
                    bidvar.kitting__c='Yes';
                    bidlistToUpdate.add(bidvar);
                }
                //dodaac Number Missing
                if(bidvar.Ship_To_DoDAAC__c==null){
                    Task newTask = new Task();
                    newTask.Subject ='DoDAAC Number Missing -' + bidvar.DoDAAC_Number_Text__c;
                    newTask.WhatId = bidvar.Rfq_number__c;
                    newTask.Status = 'Not Started';
                    newTask.Priority = 'Normal';
                    newTask.WhatId = bidvar.Rfq_number__c;
                    newTask.ActivityDate= system.today();
                    newTask.OwnerId = bidvar.Rfq_number__r.OwnerId; // Assign task to rfq  owner
                    newTask.IsReminderSet	=true;
                    newTask.ReminderDateTime = system.now().addHours(1); 
                    MapDodaacTask.Put(bidvar.RFQ_Number__c,newTask);
                }
                
                //Send Questionarrie
                If(bidvar.Bid_Supplier__r.Send_Questionnarie__c == true ) {
                    Task newTask = new Task();
                    newTask.Subject ='Fill out Questionnaire for “ '+bidvar.Bid_Supplier__r.Name+' ” (Attached Questionnaire in Bid Group)';
                    newTask.WhatId = bidvar.Rfq_number__c;
                    newTask.Status = 'Not Started';
                    newTask.Priority = 'Normal';
                    newTask.WhatId = bidvar.Rfq_number__c;
                    newTask.ActivityDate= system.today().addDays(1);
                    newTask.OwnerId = bidvar.Rfq_number__r.OwnerId; // Assign task to rfq  owner
                    newTask.IsReminderSet	=true;
                    newTask.ReminderDateTime = system.now().addHours(1); 
                    mapInsertTask.Put( bidvar.Bid_Supplier__c,newTask);
                    
                }
                
                If(!String.isBlank(subjectTask)){
                    Task newTask = new Task();
                    newTask.Subject = subjectTask ;
                    newTask.Description = 'Follow up with the new Bid Tracker Have Rfq : ' + bidvar.Rfq_number__r.Name;
                    newTask.Status = 'Not Started';
                    newTask.Priority = 'Normal';
                    newTask.WhatId = bidvar.Rfq_number__c;
                    newTask.ActivityDate= system.today().addDays(1);
                    newTask.OwnerId = bidvar.Rfq_number__r.OwnerId; // Assign task to rfq  owner
                    newTask.IsReminderSet	=true;
                    newTask.ReminderDateTime =system.today();
                    mapInsertTask.Put( bidvar.Rfq_number__c,newTask);
                    
                 
                }
                If (bidvar.City__c == null || bidvar.ServiceNow_State__c == null  || bidvar.Country__c == null ||bidvar.ZIP_Postal_Code__c ==null){
                    mapIdUserIDOwner.put(bidvar.Rfq_number__c,bidvar.Rfq_number__r.OwnerId);
                    
                }
                
            }
        }
        If (!mapIdUserIDOwner.isEmpty()) {
            for (Id idvar : mapIdUserIDOwner.keySet()) {
                Messaging.CustomNotification notification = new Messaging.CustomNotification(); 
                notification.setBody('State,City,Country,Zip Code is not Present in Dodaac'); 
                notification.setTitle('Delivery Address Missing In DoDAAC'); 
                notification.setSenderId(mapIdUserIDOwner.get(idvar)); 
                notification.setNotificationTypeId(type.id); 
                notification.setTargetId(idvar); // target object id 
                notification.send(new Set<String> { mapIdUserIDOwner.get(idvar) });  
            }
        }
        
        
        try {
            IF (!mapInsertTask.isEmpty()){
                insert mapInsertTask.values();
            }
            
            if(!bidlistToUpdate.isEmpty()){
                BidLineItemTriggerHandler.isBidLineItemTrigger = false;
                update bidlistToUpdate;
            }
            if(!MapDodaacTask.isEmpty()){
                insert MapDodaacTask.values();
            }
        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
        
    }
    
/******************************************************************************************************************************************************
 Checking the condition and changing the status according to condition.
 Criteria: Before Update
 ******************************************************************************************************************************************************/
         public static void updateStatus(List<Bid_Line_Item__c> bidLineItemList,Map<id,Bid_Line_Item__c> mapOldvalBid){
        Map<Id,Bid_Group_Items__c> mapIdBidGroup = new Map<Id,Bid_Group_Items__c>([select id, CPQ_Shipping_Total_from_mfg__c, (SELECT Id, Payment_Terms__c,shipping__c FROM Bid_Line_Items__r) 
                                                                                   from Bid_Group_Items__c
                                                                                  where Id In (select Bid_Group_Items__c from Bid_Line_Item__c  where Id In: bidLineItemList)]);
        
        for(Bid_Line_Item__c  bl: bidLineItemList){

        
            if( bl.Payment_Terms__c != Null  && bl.Ship_To_DoDAAC__c!=null
               && bl.Weeks_ARO__c!=null && bl.Unit_Cost__c != Null && bl.Berry_Applies__c != null && bl.Country_of_Origin__c != null
              && (mapOldvalBid.get(bl.id).Status__c == 'Supplier Responded'|| mapOldvalBid.get(bl.id).Status__c == 'Sent to Supplier') 
               && bl.shipping__c>=0  ){
                   system.debug('aa');
                   If (BidLineItemTriggerHandler.isBidLineItemStatus) {
                   }
                    bl.Status__c = 'Pending Margin Calculation';
                 
            }
            else If((( bl.Weeks_ARO__c != mapOldvalBid.get(bl.id).Weeks_ARO__c 
                        || bl.Country_of_Origin__c!=mapOldvalBid.get(bl.id).Country_of_Origin__c
                        || bl.Berry_Applies__c !=mapOldvalBid.get(bl.id).Berry_Applies__c ||
                        bl.Shipping__c>0 ||
                        bl.Payment_Terms__c !=mapOldvalBid.get(bl.id).Payment_Terms__c
                       )&& (  mapOldvalBid.get(bl.id).Status__c == 'Sent to Supplier' && mapOldvalBid.get(bl.id).Status__c != 'Hold' ) )
                      && ! (mapOldvalBid.get(bl.id).Sales_Rep__c != null && bl.Sales_Rep__c==null)){
                          system.debug(bl.Status__c);
                          If (BidLineItemTriggerHandler.isBidLineItemStatus) {
                          }
                           bl.Status__c = 'Supplier Responded';
                        }
        
         
            if((bl.Order_Number__c !=  mapOldvalBid.get(bl.id).Order_Number__c || bl.Award_Type__c !=  mapOldvalBid.get(bl.id).Award_Type__c || bl.Awardee__c !=  mapOldvalBid.get(bl.id).Awardee__c || bl.Contract_Number__c !=  mapOldvalBid.get(bl.id).Contract_Number__c || bl.Core_List_Number__c !=  mapOldvalBid.get(bl.id).Core_List_Number__c || bl.Total_Award_Amount__c !=  mapOldvalBid.get(bl.id).Total_Award_Amount__c || bl.Post_Award_Notes__c !=  mapOldvalBid.get(bl.id).Post_Award_Notes__c ||  bl.Award_Date__c !=  mapOldvalBid.get(bl.id).Award_Date__c ||  bl.Award_Create_Date__c !=  mapOldvalBid.get(bl.id).Award_Create_Date__c ||  bl.ServiceNow_MIPR_Code__c !=  mapOldvalBid.get(bl.id).ServiceNow_MIPR_Code__c) && bl.Status__c == 'Sent to DLA' ){
               If (BidLineItemTriggerHandler.isBidLineItemStatus) {
                bl.Status__c = 'Awarded'  ; 
               }
            }

        }
    }
/******************************************************************************************************************************************************
Based on No Quote reason field checking the metadata and pulling the comment from metadata
Criteria: Before Update
 ******************************************************************************************************************************************************/
     public static  void  addCommentToBidLIneNOQuoteRecon(List<Bid_Line_Item__c> bidLineItemList,Map<id,Bid_Line_Item__c> mapOldvalBid){
        
        List<String> strVauePickList = new LISt<String>();
        Schema.DescribeFieldResult fieldResult = bid_line_item__c.NO_Quote_Reason__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        integer i =1;
        for( Schema.PicklistEntry f : ple) {
            strVauePickList.add(f.getLabel());
            i++;
        }
 
        list<No_Quote_Comments__mdt> listMetaNoQot =  [SELECT DeveloperName, MasterLabel, Comments__c FROM No_Quote_Comments__mdt];
        Map<String,String> mapStrStr = new Map<String,String>();
        For (No_Quote_Comments__mdt varMeta : listMetaNoQot ){
            mapStrStr.put(varMeta.MasterLabel,varMeta.Comments__c);
        }
        system.debug(mapStrStr);
        
        For (Bid_Line_Item__c bidvar : bidLineItemList ) {
            If (bidvar.NO_Quote_Reason__c != mapOldvalBid.get(bidvar.id).NO_Quote_Reason__c &&  bidvar.NO_Quote_Reason__c != null ) {
                For (String strVar : strVauePickList ) {
                  
                    If (bidvar.NO_Quote_Reason__c.contains(strVar)) {
                        bidvar.Comments__c = mapStrStr.get(strVar);
                        break;
                    }
                }
            } else  If (bidvar.NO_Quote_Reason__c == null){
                bidvar.Comments__c ='';
            }
            
        }
        
    }
   
/*************************************************************************************************************************************************
If all the line items related to an RFQ have the same status then changing the parent object i.e. Bidtracker Status
Criteria: After Insert And After Update
 ******************************************************************************************************************************************************/
    public static void Update_ParentStatus(List<Bid_Line_Item__c> BidLineItemList, Map<Id,Bid_Line_Item__c> mapIdBidLineOld ) {
        Set<Id> bidTrackerIds = new Set<Id>();
        
        // Collect all parent BidTracker IDs related to the child bid line item records
        If (mapIdBidLineOld == null ) {
            for (Bid_Line_Item__c bidRecords : BidLineItemList) {
            if (bidRecords.RFQ_Number__c != null) {
                bidTrackerIds.add(bidRecords.RFQ_Number__c);
            }
        } 
        } else {
            for (Bid_Line_Item__c bidRecords : BidLineItemList) {
            if (bidRecords.Status__c != mapIdBidLineOld.get(bidRecords.Id).Status__c) {
                bidTrackerIds.add(bidRecords.RFQ_Number__c);
            }
        } 
            
        }
       
        
        Id recordTypeIdBidTracker = Schema.SObjectType.Bid_Tracker__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
        Id recordTypeIdBidLineItem = Schema.SObjectType.Bid_Line_Item__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
        
        // Map to store parent BidTracker IDs and their associated child Bid Line Items
        Map<Id, List<Bid_Line_Item__c>> bidTrackerToBidLineItems = new Map<Id, List<Bid_Line_Item__c>>();
        // Query and store Bid Trackers with associated Bid Line Items
        for (Bid_LIne_Item__c bidLIneVar : [SELECT Id, Status__c, Record_Source__c, RFQ_Number__c FROM Bid_LIne_Item__c 
                                            WHERE RFQ_Number__c IN :bidTrackerIds AND RecordTypeId = :recordTypeIdBidLineItem
                                            AND no_quote_reason__C Excludes ('Supplier F or X Rating','Supplier is one of the Prime Vendor')]) {
                                                If (bidTrackerToBidLineItems.containskey(bidLIneVar.RFQ_Number__c)) {
                                                    bidTrackerToBidLineItems.get(bidLIneVar.RFQ_Number__c).add(bidLIneVar);
                                                } else {
                                                    bidTrackerToBidLineItems.put(bidLIneVar.RFQ_Number__c, new List<Bid_LIne_Item__c>{bidLIneVar}); 
                                                }
                                                
                                            }
        Map<Id, Bid_Tracker__c> BidTrackerStatusUpdate = new  Map<Id, Bid_Tracker__c>();
        // Iterate through the Bid Trackers and their associated Bid Line Items
        for (Id bidTrackerId : bidTrackerToBidLineItems.keySet()) {
            Boolean allChildItemsMatchStatus = true;
            String parentStatus = '';
            String recordSource ;
            Set<String> uniqueStatuses = new Set<String>();
            
            for (Bid_Line_Item__c childRecord : bidTrackerToBidLineItems.get(bidTrackerId)) {
                if (childRecord.Status__c == null) {
                    allChildItemsMatchStatus = false;
                    break;
                }
                uniqueStatuses.add(childRecord.Status__c);
         
                
                recordSource = childRecord.Record_Source__c;
            }
            system.debug('allChildItemsMatchStatus-->'+ allChildItemsMatchStatus);
                        system.debug('uniqueStatuses-->'+ uniqueStatuses);

            
            // If all child records have the same status, update the parent status
            if (uniqueStatuses.size() == 1 && allChildItemsMatchStatus) {
                
                
                Bid_Tracker__c parentRecord = new Bid_Tracker__c(Id = bidTrackerId);
                for(string sVar:uniqueStatuses){
                String childStatus=sVar;
                if (childStatus == 'Sent to Supplier') {
                    parentRecord.Quote_Request_Status__c = 'Darley_RFQ';
                } else if (childStatus == 'New') {
                    parentRecord.Quote_Request_Status__c = 'TLS_RFQ';
                } else if (childStatus == 'Supplier Responded') {
                    parentRecord.Quote_Request_Status__c = 'Supplier_Response';
                } else if (childStatus == 'RFQ Ready for DLA') {
                    parentRecord.Quote_Request_Status__c = 'RFQ Ready for DLA';
                } else if (childStatus == 'Sent to DLA') {
                    parentRecord.Quote_Request_Status__c = 'Darley_Response';
                } else if (childStatus == 'Awarded') {
                    parentRecord.Quote_Request_Status__c = 'Awarded';
                }
                }

                BidTrackerStatusUpdate.put(parentRecord.Id, parentRecord);
            } else If (uniqueStatuses.size() == 2 && uniqueStatuses.contains('RFQ Ready for DLA') && uniqueStatuses.contains('Sent to DLA')) {
                 Bid_Tracker__c parentRecord = new Bid_Tracker__c(Id = bidTrackerId);
                 parentRecord.Quote_Request_Status__c = 'RFQ Ready for DLA';
                BidTrackerStatusUpdate.put(parentRecord.Id, parentRecord);
            }
                    
            
        }
        if(!BidTrackerStatusUpdate.isEmpty()){

            update BidTrackerStatusUpdate.Values();
        } 
    }
 
 /*************************************************************************************************************************************************
This is a rollup summary method which rollup all the values  of bidline at pending margin calculation status to Bid group object And
Pulling the value of Payment term from bidline item to bid group
Criteria: After Insert And After Update
 ******************************************************************************************************************************************************/

    public static void updatetheBidValuesRollUpSummary(List<Bid_Line_Item__c> newBidLine,Map<Id,Bid_Line_Item__c> mapOldBidLine){
        Id recordTypeId = Schema.SObjectType.Bid_Line_Item__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
        system.debug('Rollup summmery '+newBidLine);
        Map<ID,Bid_Group_Items__c> bidGroupListUpdate = new Map<ID,Bid_Group_Items__c>();
       set<id> bidBidGroupItemId = new set<id>();
        Set<Id> setIdBidGrpStatusChange = new Set<Id>();
        If(!newBidLine.isEmpty()){
            For(Bid_Line_Item__c bidLin : newBidLine){
                if(mapOldBidLine!=null){
                    
                    If (bidLin.CPQ_Total_Cost__c != mapOldBidLine.get(bidLin.Id).CPQ_Total_Cost__c  || bidLin.CPQ_Net_Total__c != mapOldBidLine.get(bidLin.Id).CPQ_Net_Total__c ||
                        bidLin.Lead_time__c != mapOldBidLine.get(bidLin.Id).Lead_time__c  || bidLin.Sales_Tax_Amount__c != mapOldBidLine.get(bidLin.Id).Sales_Tax_Amount__c ||
                        bidLin.Count_of_Kitting__c != mapOldBidLine.get(bidLin.Id).Count_of_Kitting__c  || bidLin.Count_of_Sales_Tax_Applied__c != mapOldBidLine.get(bidLin.Id).Count_of_Sales_Tax_Applied__c ||
                        bidLin.Total_Price__c != mapOldBidLine.get(bidLin.Id).Total_Price__c  || bidLin.Darley_Net__c != mapOldBidLine.get(bidLin.Id).Darley_Net__c ||
                        bidLin.CPQ_Margin_Dollars__c != mapOldBidLine.get(bidLin.Id).CPQ_Margin_Dollars__c  || bidLin.CPQ_Required_Prepay__c != mapOldBidLine.get(bidLin.Id).CPQ_Required_Prepay__c   ||
                        bidLin.Cost_of_Borrowing__c != mapOldBidLine.get(bidLin.Id).Cost_of_Borrowing__c ||   bidLin.Shipping__c != mapOldBidLine.get(bidLin.Id).Shipping__c ) {
                            bidBidGroupItemId.add(bidLin.Bid_Group_Items__c);
                        }
                    
                    If (bidLin.Payment_Terms__c != mapOldBidLine.get(bidLin.Id).Payment_Terms__c) {
                        Bid_Group_Items__c bidGrpVar = new Bid_Group_Items__c();
                        bidGrpVar.Id = bidLin.Bid_Group_Items__c;
                        bidGrpVar.Supplier_Payment_Terms__c = bidLin.Payment_Terms__c;
                        bidGroupListUpdate.put(bidGrpVar.Id,bidGrpVar);
                    }
                    If (bidLin.Status__c != mapOldBidLine.get(bidLin.id).Status__c && bidLin.Status__c == 'Pending Margin Calculation' ) {
                        system.debug('the status creiteri is fullfilll');
                        setIdBidGrpStatusChange.add(bidLin.Bid_Group_Items__c);
                        
                    }
                }
                if(mapOldBidLine==null && bidLin.Sales_Rep__c!=null){
                    bidBidGroupItemId.add(bidLin.Bid_Group_Items__c);
                }
              
            }
            
        }
        system.debug('Log');
        Map<Id,Integer> mapIDSetS = new Map<Id,Integer>();
        //If the BidLIne Status is change cheque for the relatedRecord ChANGE 
        For (AggregateResult argValue  :[SELECT Bid_Group_Items__c, COUNT(Status__c) statu
                                         FROM Bid_Line_Item__c
                                         WHERE Bid_Group_Items__c In: setIdBidGrpStatusChange
                                         AND Status__c = 'Pending Margin Calculation'
                                         GROUP BY Bid_Group_Items__c
                                        ]) {
                                            mapIDSetS.put((Id)argValue.get('Bid_Group_Items__c'), (Integer)argValue.get('statu'));
                                        }
              
                system.debug('mapIDSetS'+mapIDSetS);

        //For method is for the BidGroupItem to update the total cost ,Net total 
        For(AggregateResult argValue :[SELECT Bid_Group_Items__c ,SUM(CPQ_Total_Cost__c)coShi,SUM(CPQ_Net_Total__c)nup,MAX(Lead_time__c)lt,SUM(Sales_Tax_Amount__c)salesTaxAmount,SUM(Cost_of_Borrowing__c)costOfBorrow,
        SUM(Count_of_Kitting__c)kit,SUM(Count_of_Sales_Tax_Applied__c)salesTaxSum ,SUM(Total_Price__c)totalPric, SUM(Darley_Net__c)darleyNet,SUM(CPQ_Margin_Dollars__c)marginDollar, COUNT(Id)varId,
         SUM(CPQ_Required_Prepay__c)requiredPrePay, SUM(Shipping__c)Shipping FROM Bid_Line_Item__c WHERE Bid_Group_Items__c In :bidBidGroupItemId or Bid_Group_Items__c in:mapIDSetS.keySet()  GROUP BY Bid_Group_Items__c]){
             
            system.debug(argValue);
            Bid_Group_Items__c varBidGroup = new Bid_Group_Items__c();

             If (mapIDSetS.containsKey((Id)argValue.get('Bid_Group_Items__c'))){
                 If (mapIDSetS.get((Id)argValue.get('Bid_Group_Items__c')) ==(Integer)argValue.get('varId')){
                     
                     varBidGroup.IsRunning__c = True;
                 }
             }
            If(argValue.get('Bid_Group_Items__c')!=null){
                varBidGroup.ID=(Id)argValue.get('Bid_Group_Items__c');
            }
             
            //varBidTrack.Required_Prepay__c=(decimal)argValue.get('requiredPrePay');
            varBidGroup.Cost_of_Borrowing__c = 	(decimal)argValue.get('costOfBorrow');
            varBidGroup.Total_Sales_Tax__c=(decimal)argValue.get('salesTaxAmount');
            varBidGroup.Darley_Net_Total__c=(decimal)argValue.get('darleyNet');
            varBidGroup.Total_Margin__c	=(decimal)argValue.get('marginDollar');
            varBidGroup.Total_Price__c=(decimal)argValue.get('totalPric');
            varBidGroup.Total_Cost__c=(decimal)argValue.get('coShi');
             varBidGroup.CPQ_Shipping_Total_from_mfg__c=(decimal)argValue.get('Shipping');
            system.debug(argValue.get('nup'));
            varBidGroup.Longest_Lead_Time__c = (decimal)argValue.get('lt');
            system.debug(argValue.get('lt'));
             IF((decimal)argValue.get('salesTaxSum') > 0){
                varBidGroup.Sales_Tax_Approval_Needed__c = 'Approval Needed: SalesTax';
            }
            else{
                varBidGroup.Sales_Tax_Approval_Needed__c = 'No';
            }
            IF((decimal)argValue.get('kit') > 0){
                varBidGroup.Kit_Approval_Needed__c = 'Approval Needed: Kit';
            }
            else{
                varBidGroup.Kit_Approval_Needed__c = 'No';
            }
           // For total Purchasee Price  in group
            varBidGroup.CPQ_Net_Total__c=(decimal)argValue.get('nup');
             
             
             If (bidGroupListUpdate.containsKey(varBidGroup.id)){
                varBidGroup.Supplier_Payment_Terms__c= bidGroupListUpdate.get(varBidGroup.id).Supplier_Payment_Terms__c;
                 
                 bidGroupListUpdate.put(varBidGroup.id, varBidGroup);
             }else {
                  bidGroupListUpdate.put(varBidGroup.id,varBidGroup);
             }
           
        }
        
        IF (!bidGroupListUpdate.isEmpty()) {
           update bidGroupListUpdate.values();
         
        }
        
    }
    
       
/*************************************************************************************************************************************************
If some of the information (field are not populated by user) is missing at the supplier resonded status then sending the email to supplier for that information.
Criteria:  After Update
 ******************************************************************************************************************************************************/
 
    Public static void sendMailToSupplierFieldMissing(List<Bid_line_item__c> newLIstBid ,Map<Id,Bid_line_item__c> oldvalOftheBidLine){
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Set<id> setIDBidGroup = new Set<ID>();
        Set<id> setIDBidGroupfilter = new Set<ID>();
        
        
        If(!newLIstBid.isEmpty()){
            For(Bid_line_item__c bidVar : newLIstBid){
                If(bidVar.Status__c =='Supplier Responded' && bidVar.Status__c != oldvalOftheBidLine.get(bidVar.Id).Status__c && oldvalOftheBidLine.get(bidVar.Id).Status__c == 'Sent to Supplier' ){
                    setIDBidGroup.add(bidvar.Bid_Group_Items__c);
                    system.debug('bidLineItem bidGroupID'+bidvar.Bid_Group_Items__c);
                }
            }
        }
        If(!setIDBidGroup.isEmpty()){   
            For(Bid_Group_Items__c bidGroupVar : [select id ,(select id, status__c from Bid_Line_Items__r where status__c = 'Supplier Responded') from Bid_Group_Items__c where id In : setIDBidGroup]){
               
                If(bidGroupVar.Bid_Line_Items__r.size()==0){
                    setIDBidGroupfilter.add(bidGroupVar.id);
                }
            }
        }
        Map<Id,String> mapIdAccWithBidLiIDFields = new  Map<Id,String>(); 
        IF(!setIDBidGroupfilter.isEmptY()){
            system.debug(setIDBidGroupfilter);
            For(Bid_line_item__c bl : [select id,Name, Unit_Cost__c, Lead_Time__c,Berry_Applies__c, Payment_Terms__c,Quote_Numbers__c,
                                       Line_Item_ID__c,Supplier_Part_Number__c   , Comments__c, Procurement_Agreement_Compliant__c, 
                                       Bid_Supplier__c from  Bid_line_item__c where Bid_Group_Items__c  in : setIDBidGroupfilter ]){
                string varStr;
                If(bl.Unit_Cost__c==null){
                    varStr='Unit Cost';
                }
                If(bl.Lead_Time__c==null){
                    If(varStr==null){
                        varStr='Lead Time ';
                    }else{
                        varStr+=', Lead Time';
                    }
                }
                       If(bl.Payment_Terms__c==null){
                    If(varStr==null){
                        varStr='Payment Terms';
                    }else{
                        varStr+=', Payment Terms';
                    }
                }
                
                If(varStr!=null){
                    varStr+=' )<br><br>';
                }
                IF(varStr!=null){
                    varStr='( '+ bl.Line_Item_ID__c +','+ bl.Supplier_Part_Number__c+'->' + varStr;
                    system.debug('varStr'+varStr);
                    IF(mapIdAccWithBidLiIDFields.containsKey(bl.Bid_Supplier__c)){
                        varStr+= mapIdAccWithBidLiIDFields.get(bl.Bid_Supplier__c);
                        mapIdAccWithBidLiIDFields.put(bl.Bid_Supplier__c,varStr);
                    }else{
                        mapIdAccWithBidLiIDFields.put(bl.Bid_Supplier__c,varStr);
                    }
                }
            }
            OrgWideEmailAddress orgWideEmailAddresses = [SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Darley Defense TLS'];
            If(!mapIdAccWithBidLiIDFields.isEmpty()){
                For(Account acc : [select id ,Name,Email_Address__c, (select id,Quote_Numbers__c from Bid_Line_Items1__r where Bid_Group_Items__c In : setIDBidGroupfilter ) from Account where Id In :mapIdAccWithBidLiIDFields.keySet()]){
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                     String emailBody = 'Hi ' + acc.Name + ',<br><br>' +
                        'We noticed that the '+mapIdAccWithBidLiIDFields.get(acc.Id)+' missing for your supplier record. ' +
                        'Please update the information at your earliest convenience.<br><br>' +
                        'Thank you,<br>Darley';
                    email.setHtmlBody(emailBody);
                    email.setUseSignature(false);
                    If(acc.Email_Address__c!=null){
                        email.setToAddresses(acc.Email_Address__c.split(';'));
                    }
                    //email.setTemplateId(template.Id);
                    email.Subject = 'Darley_'+acc.Name+' _RFQ_(' + acc.Name +')_'+acc.Bid_Line_Items1__r[0].Quote_Numbers__c;
                    email.setOrgWideEmailAddressId(orgWideEmailAddresses.Id);
                    email.setBccSender(true);
                    //email.setBccAddresses(new String[] { orgWideEmailAddresses.Address });
                    email.setTargetObjectId(UserInfo.getUserId());
                    email.setSaveAsActivity(false);
                    //email.setFileAttachments(new Messaging.EmailFileAttachment[] { emailAttachment });
                    emailList.add(email);
                }
            }
            //messaging.sendEmail(emailList);
            If(!emailList.isEmpty()){
                Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
                system.debug(result);
                for (Messaging.SendEmailResult result1 : result) {
                    if (result1.isSuccess()) {
                        System.debug('Email sent successfully');
                    } else {
                        // Handle email sending failure
                        for (Messaging.SendEmailError error : result1.getErrors()) {
                            System.debug('Email sending failed: ' + error.getStatusCode() + ' - ' + error.getMessage());
                            
                        }
                    }
                }
            }
        }
        
    }
    
    

  
 /*************************************************************************************************************************************************
This Method is checking the berry, Pel price and Prepay condition  at status Pending margin calculation and making no Quote according to it.
Criteria:  After Update
 ******************************************************************************************************************************************************/
    public static void CheckTheBerryPrepayPelCondition(List<Bid_line_item__c> newLIstBidList,Map<Id,Bid_line_item__c> oldvalOftheBidLine ){
        Id recordTypePrdDefense = Schema.SObjectType.Bid_Line_Item__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
        Map<Id, Bid_line_item__c> newLIstBid = new Map<Id, Bid_line_item__c>([Select id, Sales_Rep__c, Quote_Type__c, Unit_Cost__c, RecordTypeId, Status__c, Payment_Terms__c,Bid_Supplier__r.Preferred_Supplier__c,
                                                                              Bid_Group_Items__r.PrePay__c, RFQ_Number__r.OwnerId,  Bid_Supplier__c, Bid_Group_Items__r.Supplier_Payment_Terms__c, NO_Quote_Reason__c,
                                                                              Berry_Applies__c,Prepayment__c, Country_of_Origin__c, PEL_Price__c from Bid_line_item__c where Id In:newLIstBidList
                                                                             ]);
        If (!newLIstBid.isEmpty()) {
            For(Bid_line_item__c bidLine : newLIstBidList ) {
                If (bidLine.Sales_Rep__c == null && bidLine.RecordTypeId == recordTypePrdDefense && ((bidLine.Quote_Type__c == 'Quoted' && bidLine.Unit_Cost__c != null)|| bidLine.Quote_Type__c == 'No Quote')) {
                    If (bidLine.Status__c != oldvalOftheBidLine.get(bidLine.Id).Status__c && bidLine.Status__c == 'Pending Margin Calculation') {
                        
                    }
                    else {
                        newLIstBid.remove(bidLine.Id);
                    }
                }else {
                    newLIstBid.remove(bidLine.Id);
                    
                }
                
            }
        }
        If (!newLIstBid.isEmpty()){
            
        }
        Map<Id, Task> mapIdTaskInsert = new Map<Id, Task>();
        Map<ID, Bid_Group_Items__c> mapIdBidGRp = new Map<ID, Bid_Group_Items__c>();
        // cheque for the pre pay 
        If (!newLIstBid.isEmpty()) {
            For(Bid_line_item__c bidLine : newLIstBid.values() ) {
                If (bidLine.Payment_Terms__c != null) {
                    if (bidLine.Payment_Terms__c.contains('PREPAY')) {
                        
                        If ( bidLine.Bid_Supplier__r.Preferred_Supplier__c == 'Yes') { // the supplier is prefed 
                            
                            If (bidLine.Bid_Group_Items__r.PrePay__c == false ) {
                                
                                Task  varTask = new Task();
                                varTask.Description= 'Follow up with Supplier';
                                varTask.OwnerId = bidLine.RFQ_Number__r.OwnerId;
                                varTask.Subject = 'The supplier Contains PrePay in the Payment Terms';
                                vartask.WhatId = bidLine.Bid_Supplier__c;
                                mapIdTaskInsert.put(bidLine.Bid_Supplier__c, varTask );
                                Bid_Group_Items__c bidGrp = new Bid_Group_Items__c();
                                bidGrp.Id = bidLine.Bid_Group_Items__c;
                                bidGrp.PrePay__c = True;
                                mapIdBidGRp.put(bidGrp.Id, bidGrp);
                                
                            } else {
                                
                            }
                        } else { 
                            If (bidLine.Prepayment__c >50 ) {// have to work on it
                                
                                bidLine.Quote_Type__c = 'No Quote';
                                If (bidLine.NO_Quote_Reason__c != null) {
                                    If (!bidLine.NO_Quote_Reason__c.contains('Does NOT meet Prepayment Requirement')){
                                        bidLine.NO_Quote_Reason__c += ';Does NOT meet Prepayment Requirement';
                                    }
                                    
                                } else {
                                    bidLine.NO_Quote_Reason__c = 'Does NOT meet Prepayment Requirement';
                                }
                                
                            } else {
                                //prement less then 50 
                                If (bidLine.NO_Quote_Reason__c != null && bidLine.NO_Quote_Reason__c.contains('Does NOT meet Prepayment Requirement')){
                                    
                                    bidLine.NO_Quote_Reason__c =bidLine.NO_Quote_Reason__c.remove('Does NOT meet Prepayment Requirement;');
                                    bidLine.NO_Quote_Reason__c =bidLine.NO_Quote_Reason__c.remove(';Does NOT meet Prepayment Requirement');
                                    bidLine.NO_Quote_Reason__c =bidLine.NO_Quote_Reason__c.remove('Does NOT meet Prepayment Requirement');
                                }
                                
                            }
                        }
                        
                    } else {//the payment terms is not contains prepay
                        
                    }
                }
                If (bidLine.NO_Quote_Reason__c ==''){
                    bidLine.Quote_Type__c = 'Quoted';
                }
            }
        }
        // insert the Task of the prepays supplier have prepay more than 50 per 
        If (!mapIdTaskInsert.isEmpty()) {
            insert  mapIdTaskInsert.values();
        }
        Set<Id> setIDBidGroup = new Set<id>();
        // Berry flow 
        If (!newLIstBid.isEmpty()) {
            For(Bid_line_item__c bidLine : newLIstBid.values() ) {
                setIDBidGroup.add(bidLine.Bid_Group_Items__c);
                system.debug( bidLine.Country_of_Origin__c != 'US - United States');
                If(bidLine.Country_of_Origin__c == null ){
                    bidLine.Country_of_Origin__c='';
                }
                If (bidLine.Berry_Applies__c == 'Yes' &&  !bidLine.Country_of_Origin__c.contains('US - United States')) { // Berry flow 
                    bidLine.Quote_Type__c = 'No Quote';
                    If (bidLine.NO_Quote_Reason__c != null) {
                        system.debug('no quote for berry');
                        if (!bidLine.NO_Quote_Reason__c.contains('Not USA: Does Not Meet Berry Compliance')) {
                            bidLine.NO_Quote_Reason__c += ';Not USA: Does Not Meet Berry Compliance';
                        }
                        
                        
                    } else {
                        bidLine.NO_Quote_Reason__c = 'Not USA: Does Not Meet Berry Compliance';
                    }
                }  else {
                    If (bidLine.NO_Quote_Reason__c != null && bidLine.NO_Quote_Reason__c.contains('Not USA: Does Not Meet Berry Compliance')  ) {
                        bidLine.NO_Quote_Reason__c  =bidLine.NO_Quote_Reason__c.remove('Not USA: Does Not Meet Berry Compliance;');
                        bidLine.NO_Quote_Reason__c  = bidLine.NO_Quote_Reason__c.remove(';Not USA: Does Not Meet Berry Compliance');
                        bidLine.NO_Quote_Reason__c  = bidLine.NO_Quote_Reason__c.remove('Not USA: Does Not Meet Berry Compliance');
                        
                        
                    }
                    
                    
                }
                // Berry flow end 
                If (bidLine.PEL_Price__c < bidLine.Unit_Cost__c && bidLine.PEL_Price__c != null) {
                    
                    bidLine.Quote_Type__c = 'No Quote';
                    If (bidLine.NO_Quote_Reason__c != null) {
                        If (!bidLine.NO_Quote_Reason__c .contains('Cost exceeds Darley\'s Ceiling Price')){
                            bidLine.NO_Quote_Reason__c += ';Cost exceeds Darley\'s Ceiling Price';
                        }
                        
                    } else {
                        bidLine.NO_Quote_Reason__c = 'Cost exceeds Darley\'s Ceiling Price';
                    }
                } else {
                    system.debug('no quote for pel nore pl preice is less ');
                    If (bidLine.NO_Quote_Reason__c != null && bidLine.NO_Quote_Reason__c.contains('Cost exceeds Darley\'s Ceiling Price')){
                        
                        bidLine.NO_Quote_Reason__c =bidLine.NO_Quote_Reason__c.remove('Cost exceeds Darley\'s Ceiling Price;');
                        bidLine.NO_Quote_Reason__c =bidLine.NO_Quote_Reason__c.remove(';Cost exceeds Darley\'s Ceiling Price');
                        bidLine.NO_Quote_Reason__c =bidLine.NO_Quote_Reason__c.remove('Cost exceeds Darley\'s Ceiling Price');
                    }
                }
                If (bidLine.NO_Quote_Reason__c ==''){
                    bidLine.Quote_Type__c = 'Quoted';
                }
            }
           
            If (!newLIstBid.isEmpty()) {
                Update newLIstBid.values();
             
            }
            If (!mapIdBidGRp.isEmpty()) {
                Update mapIdBidGRp.values();
               
            }
            
        }
    }
 /*************************************************************************************************************************************************
This Method is written to check if the country of origin is in taa Countury picklist then populate that value in Taa county field
Criteria:  After Update
 ******************************************************************************************************************************************************/
     public static void taaCountries(List<Bid_Line_Item__c> listBidLineItmes, Map<Id, Bid_Line_Item__c> mapIdBidLIneOld ){
        Set<Id> setIdBidLIne = new Set<Id>();
        For (Bid_Line_Item__c bidLine : listBidLineItmes ) {
            if(bidLine.Country_of_Origin__c !=  mapIdBidLIneOld.get(bidLine.Id).Country_of_Origin__c && bidLine.Country_of_Origin__c != null ) {
                setIdBidLIne.add(bidLine.Id);
            }
            
        }
        If (setIdBidLIne.isEmpty()){
            return;
        }
        Schema.DescribeSObjectResult bliDescribe = Bid_Line_Item__c.SObjectType.getDescribe();
        Schema.DescribeFieldResult taaCountriesFieldDescribe = bliDescribe.fields.getMap().get('TAA_Countries__c').getDescribe();
        List<Schema.PicklistEntry> taaCountriesValues = taaCountriesFieldDescribe.getPicklistValues();
        
        
        List<String> picklistValues = new List<String>();
        
        // Iterate through the picklist values and add them to the list
        for (Schema.PicklistEntry picklistValue : taaCountriesValues) {
                if (picklistValue.isActive()) {

            picklistValues.add(picklistValue.getValue().normalizeSpace());
                    System.debug('Picklist Value: ' + picklistValue.getLabel() + ' (API Name: ' + picklistValue.getValue() + ')');
                }
            
        }
        system.debug(picklistValues);
         For (Bid_Line_Item__c bidLine : listBidLineItmes ) {
            if(bidLine.Country_of_Origin__c !=  mapIdBidLIneOld.get(bidLine.Id).Country_of_Origin__c && bidLine.Country_of_Origin__c != null ) {
                system.debug(picklistValues.contains(bidLine.Country_of_Origin__c.normalizeSpace()));
                system.debug(bidLine.TAA_Countries__c );
                 system.debug(bidLine.Country_of_Origin__c );
                
               If (picklistValues.contains(bidLine.Country_of_Origin__c.normalizeSpace())){
                    bidLine.TAA_Countries__c = bidLine.Country_of_Origin__c.normalizeSpace();
                }
                
            }
            
        }
    }
    
    
    public static void myMethod(){
        map<id,map<id,map<id,bid_line_item__C>>> newMap=new map<id,map<id,map<id,bid_line_item__C>>>();
        list<bid_line_item__c>bidlist=[select id,rfq_number__C ,bid_group_items__c from bid_line_item__c];
        
        for(bid_line_item__c bid:bidlist){
            if(!newMap.containsKey(bid.rfq_number__C)){
                newMap.put(bid.rfq_number__C,new map<id,map<id,bid_line_item__C>>{bid.bid_group_items__c=> new map<id,bid_line_item__C>{bid.id=>bid} });
          }
            else{
                 if(!newMap.get(bid.rfq_number__C).containsKey(bid.bid_group_items__c)){
                     newMap.get(bid.rfq_number__C).put(bid.bid_group_items__c, new map<id,bid_line_item__C>{bid.id=>bid});
                 }
                else{
                  newMap.get(bid.rfq_number__C).get(bid.bid_group_items__c).put(bid.id,bid);
  
                }
            }
             
        }
        
        
    }
}