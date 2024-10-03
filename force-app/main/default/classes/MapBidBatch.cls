/******************************************************************************************************************************************************
Name                    : MapBidBatch
Author                  : Melonleaf
Purpose                 : This batch class is designed to process all the bid workbench records.
Description             : This class is processing all the bid workbench records, checking all the sales rep condition doing csupplier cleanup
                          & creating the records of Bidtracker, Bidline items and BidGroup.
Version                 : 1.0
Change Log              : 
Test Class              : MapBidBatch_Test
CreateDate              : 25-05-2024
LastModifiedDate        : 25-05-2024
******************************************************************************************************************************************************/


global class MapBidBatch implements Database.Batchable<sObject>,Database.Stateful{ 
    private boolean restartJob;
    global  list<bid_workbench__c> unProceesedRecList= new list<bid_workbench__c>() ;
    global list<Bid_Line_Item__c> listBidLineSendToQuable= new list<Bid_Line_Item__c>() ;
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        restartJob=true;
        list<AsyncApexJob> aJob =  [SELECT Id, Status, JobType,createddate, apexclass.name FROM AsyncApexJob WHERE JobType = 'BatchApex' AND Status IN ('Processing', 'Queued') and apexclass.name='MapBidBatch' order by createddate ASc];
        if(aJob.size() > 1){
            restartJob=false;
        }
        system.debug('restartJob start'+restartJob);
        system.debug('aJob'+aJob.size());
        for(AsyncApexJob j:ajob ){
            
            System.AbortJob(j.Id);
        }
        
        
       
        
        String query = 'Select Name,unit__c,MIPR_Code__c,Line_Items__c,Item_Description__c, Intended_Use__c, Vendor_ID__c,Country_of_Origin__c,City__c, Acquisition_Cost__c,' 
            +  'ServiceNow_RFQ_Additional_Informatiom__c,Customer_Extended_Price__c,Country__c,Email__c,First_Name__c ,Last_Name__c,Mission_Impact_Statement__c,Other_Cost__c,' 
            +  '  Phone__c,Special_Instructions__c,Timeframe__c,state__c,Zip_Code__c,Record_Source__c,Manufacturer_Name__c,Order_Item_ID__c,'
            +  '  Region__c,Core_List_Number__c,TLSP_Vendor_Part_Number__c,Requested_Delivery_Date__c,Quantity__c,ShipTo_DODAAC__c,Delivery_Destination__c,FOB_Origin__c,'
            +  '  RFID_Required__c,Transportation_Price_Required__c,Transportation_Price__c,Vendor_Unit_Price__c,Lead_Time__c,Purchase_Unit_Price__c,Berry_Amendment_Compliant__c,Comments__c,'
            +  ' Purchase_Extended_Price__c,Customer_Permits_Alternates__c,Unit_of_Issue__c,Special_Project_Code__c,Procurement_Agreement_Compliant__c,Additional_Information__c,NSN__c,'
            +  ' Request_Type__c,TLSP_Vendor_Extension__c,Region_Group__c,Manufacturer_Part_Number__c,Processed__c,Quote_Due_Date__c,'
            +  'Quote_Number__c,Load_Batch_Number__c,Alternate_Manufacturer_Name__c,Alternate_Manufacturer_Part_Number__c,Alternate_Comments__c,Alternate_Berry_Amendment_Compliant__c,'
            +  ' Alternate_Purchase_Extended_Price__c,Alternate_Item_Offered__c,Alternate_Core_List_Number__c,Alternate_Item_Description__c,Alternate_Transportation_Price__c,'
            +  ' Alternate_TLSP_Vendor_Part_Number__c,Alternate_Purchase_Unit_Price__c,Alternate_NSN__c,Alternate_Lead_Time__c,Alternate_Country_of_Origin__c,Alternate_Vendor_Unit_Price__c,'
            +  ' Alternate_Procurement_Agreement_Complian__c,serviceNow_RFQ_Stage__c,ServiceNow_RFQ_Issue_Date__c,ServiceNow_Vendor_Assign_To__c,ServiceNow_RFQ_Program__c,ServiceNow_RFQ_Updated_On__c,'
            +  ' ServiceNow_RFQ_Updated_By__c,ServiceNow_Quote_Status__c from Bid_Workbench__c Where Processed__c = false  ORDER BY Order_Item_ID__c ASC' ;
        
         //AND Quote_Number__c ='\' + QuoteNumber + '\';
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Bid_Workbench__c> WorkbenchRecords) {
        
        system.debug('unProceesedRecList size'+unProceesedRecList.size());

      
        system.debug('WorkbenchRecords Size ==>>'+  WorkbenchRecords.size());
        //records in chunk to process the dodaac records 
        List<Bid_Workbench__c> WorkbenchRecordList=new list<bid_workbench__C>();
        
        List<string> rfqNumberList = new List<string>();
        set<string> productDlaSet = new set<string>();
        set<string> dodaacDlaSet = new set<string>();
        List<String> putManufacturerInXlat = new List<String>(); 
        Set<String> OrderLineItemDlaSet = new set<String>(); 
        
        map<string,Id>slaesRepDatamap=new map<string,id>();
        
        
        map<string,list<bid_workbench__c>> filterMap=new map<string,list<bid_workbench__c>>(); 
        
        if(unProceesedRecList.size()>0){
            system.debug('unProceesedRecList'+unProceesedRecList);
            WorkbenchRecords.addAll(unProceesedRecList);
        }
        if(unProceesedRecList.size()>0){
            unProceesedRecList.clear();
        }         
        
        system.debug('WorkbenchRecords Size==>>'+WorkbenchRecords.size());
        
        for(Bid_Workbench__c dlaAdvanceRecord : WorkbenchRecords){
            if(filterMap.containskey(dlaAdvanceRecord.quote_number__c)){
                filterMap.get(dlaAdvanceRecord.quote_number__c).add(dlaAdvanceRecord);
            }
            else{
                filterMap.put(dlaAdvanceRecord.quote_number__c,new list<bid_workbench__C>{dlaAdvanceRecord});
            }
        }
        system.debug('filterMap'+filterMap);

        
        for(list<bid_workbench__c> bidrec: filterMap.values()){
            system.debug('bidrec'+bidrec);
            system.debug('bidrec.size()'+bidrec.size());
            system.debug('bidVar.Line_Items__c'+bidrec[0].Line_Items__c);
            if(bidrec[0].Line_Items__c==bidrec.size()){
                system.debug('condition if ');
                WorkbenchRecordList.addAll(bidrec);
            }
            else{
                system.debug('condition else if ');
                unProceesedRecList.addAll(bidrec);
            }
            
        }
        
        system.debug('WorkbenchRecordList'+WorkbenchRecordList.size());
        for(bid_workbench__c w:WorkbenchRecordList){
               dodaacDlaSet.add(w.ShipTo_DODAAC__c);
            OrderLineItemDlaSet.add(w.Order_Item_ID__c);
             w.Quote_Number__c = w.Quote_Number__c.removeStart('RFQ');

            system.debug('Removw RFQ '+ w.Quote_Number__c);
            productDlaSet.add(w.Manufacturer_Part_Number__c);
            putManufacturerInXlat.add(w.Manufacturer_Name__c);
            
             rfqNumberList.add((w.Quote_Number__c).removeStart('RFQ'));
        }
        
        Id recordTypeIdBidTracker = Schema.SObjectType.Bid_Tracker__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
        
        // Contract Option Period Data ........................
        // for the FES     
        Map<string,Date> beginDatePeriodIdFESMap = new Map<string,date>();
        Map<string,Date> EndDatePeriodIdFESMap = new Map<string,date>();
        //FOR the SOE
        Map<string,Date> beginDatePeriodIdSOEMap = new Map<string,date>();
        Map<string,Date> EndDatePeriodIdSOEMap = new Map<string,date>();
        For (Contract_Period__c cp : [Select Id, Name , Period_End_Date__c, Contract_Name_Text__c, Period_Begin_Date__c, Period_Active__c, Contract_Period_Active__c, Contract_Period_ID__c 
                                     FROM Contract_Period__c ]){
                                         if(cp.Contract_Name_Text__c == 'FES'){
                                             beginDatePeriodIdFESMap.put(cp.Contract_Period_ID__c,cp.Period_Begin_Date__c);
                                             EndDatePeriodIdFESMap.put(cp.Contract_Period_ID__c , cp.Period_End_Date__c);
                                         }
                                         ELSE if( cp.Contract_Name_Text__c == 'SOE'){
                                             beginDatePeriodIdSOEMap.put(cp.Contract_Period_ID__c,cp.Period_Begin_Date__c);
                                             EndDatePeriodIdSOEMap.put(cp.Contract_Period_ID__c , cp.Period_End_Date__c);
                                         }
                                     }
        Map<string,Price_Evaluation_List__c> objectPELMap = new  Map<string,Price_Evaluation_List__c>();
        // PRICE EVALUATION LIST .........
        List<Price_Evaluation_List__c> PELRecordList = [SELECT name, Country_of_Origin__c, Active__c, PEL_ID__c, PEL_Type__c, TLSP_Supplier_Extension__c, Supplier_Part_Number_Text__c,
                                                        Bid_Supplier_Text__c,Item_Description__c,Price_Evaluation_List_Item__c,Current_Period_SELL__c,Current_Period_Cost__c
                                                        FROM Price_Evaluation_List__c WHERE Supplier_Part_Number_Text__c IN:productDlaSet ORDER BY Price_Evaluation_List_Item__c ASC];
        for(Price_Evaluation_List__c p: PELRecordList){
            objectPELMap.put(p.Supplier_Part_Number_Text__c, p);
        }
        
        // all the Existing bid tracker Records.....................
        List<Bid_Tracker__c> BidTrackerList = [SELECT Name  FROM Bid_Tracker__c WHERE Name IN :rfqNumberList AND RecordTypeId =: recordTypeIdBidTracker ];
        Set<String> RfqNumberUnique = new Set<String>();
        for(Bid_Tracker__c bidTrackerRecord :BidTrackerList ){
            RfqNumberUnique.add(bidTrackerRecord.Name);
        }
        
        // for Product Table
        Map<String, Id> productMap = new Map<String, Id>();
       
        For (Product2  productRecord : [SELECT Id , Name, Vendor_Part_Number__c  FROM Product2 where Vendor_Part_Number__c IN:productDlaSet ]){
            productMap.put(productRecord.Vendor_Part_Number__c,productRecord.Id);
        }
        // For Dodaac Directory
        Map<String, DoDAAC__c> dodaacMap = new Map<String, DoDAAC__c>();
        
        for (DoDAAC__c  dodaacRecord :[SELECT Id , Name, TAC2_Ship_To_Zip__c, TAC1_Owner_Zip__c, TAC2_Ship_To_State_A_Province__c, TAC2_Ship_To_City__c, TAC2_Ship_To_Country_Name__c, 
                                      TAC1_Owner_City__c, TAC1_Owner_Country_Name__c, TAC1_Owner_State_A_Province__c FROM DoDAAC__c where Name IN:dodaacDlaSet]  ){
            dodaacMap.put(dodaacRecord.Name,dodaacRecord);
        }
        
        //FOR XLAT Table .......................................................
        List<String> accountListXlat= new List<String>();
        Map<String, Supplier_XLAT__c> mapXlat = new Map<String, Supplier_XLAT__c>();
        //Map<string,Id> LeadId =  new Map<string,Id>();
        
        for ( Supplier_XLAT__c xlatRecords : [SELECT Name,Child__c,Lead__c,Account__c,Account__r.Name, Account__r.Send_Questionnarie__c, Lead__r.Name, Account__r.Payment_Terms_Bid_Tracker__c,
                                              Lead__r.Company,Account__r.Prime_Supplier__c ,Active__c, Lead__r.Prime_Supplier__c,Lead__r.Payment_Terms_Bid_Tracker__c 
                                              FROM Supplier_XLAT__c WHERE Child__c IN: putManufacturerInXlat AND Active__c = true]){ 
                                                  
                                                  mapXlat.put(xlatRecords.Child__c.toLowerCase(), xlatRecords);
                                                  accountListXlat.add(xlatRecords.Account__r.name);
                                                  system.debug('xlatRecords.Account__r.name-->'+xlatRecords.Account__r.name);
                                                  
                                              }
        
        //for Account Table
        List<String> FandXRatingAccount = new List<String>(); 
        List<String> PrimeSupplierAccount = new List<String>(); 
        Map<String, Id> accountListMap = new Map<String, Id>();
         
        for (Account  accRecord :[SELECT Id, Name, Supplier_Rating__c, Prime_Supplier__c  FROM Account where Name 
                                  IN : accountListXlat AND RecordType.Name =:'Vendor']){
                                      if(accRecord.Supplier_Rating__c == 'F: Required NO QUOTE'){
                                          FandXRatingAccount.add(accRecord.Name);
                                          System.debug('FandXRatingAccount-->'+ FandXRatingAccount);
                                          System.debug('accRecord.Name-->'+ accRecord.Name);
                                          
                                      } 
                                      IF(accRecord.Prime_Supplier__c == true){
                                          PrimeSupplierAccount.add(accRecord.Name);
                                      }
                                  }
        
        // Existing Supplier Cleanup Records.......................
        List<String> SupplierNameCleanup = new List<String>();
        for(Supplier_Cleanup__c cleanupRecords : [SELECT Name,RFQ_Supplier_Name__c ,Additional_information__c,RFQ_Number__c 
                                                  FROM Supplier_Cleanup__c WHERE RFQ_Supplier_Name__c In: putManufacturerInXlat]){
                                                      SupplierNameCleanup.add(cleanupRecords.RFQ_Supplier_Name__c.toLowerCase());
                                                  }
        
        
        // existing line item id in the Bid Line Item 
        List<String> existinglineItemIdList = new List<String>();
        For (Bid_Line_Item__c bidRecords : [SELECT  Id , Name , Quote_Type__c , Line_Item_ID__c FROM Bid_Line_Item__c
                                            WHERE Quote_Type__c ='Quoted' AND Line_Item_ID__c IN: OrderLineItemDlaSet  ORDER BY Line_Item_ID__c ASC,Id  ]){
            existinglineItemIdList.add(bidRecords.Line_Item_ID__c);
        }
        // get the System label for the Record Owner..
        Map<string,Id> aliasIdRFQOwnerMap = new Map<string,Id>(); 
        Set<string> RecOwnerCustomLabelSet = new Set<string>{System.label.Contract_Fes,System.label.Contract_C_E_Tents,System.label.Contract_SOE_Ends_with_Even,System.label.Contract_SOE_RFQ_Ends_with_Odd};
            List<User> UserQuery = [Select Id,alias from User where alias In : RecOwnerCustomLabelSet and IsActive = true];
        for(User userRec : UserQuery){
            aliasIdRFQOwnerMap.put(userRec.Alias, userRec.Id);
            
        }
        //-----------workbench Quote Number- (count)  ......................................
        Map<String, Decimal>  mapBidWorkbenchQuoteCount = new Map<String, Decimal>();
       
        For (AggregateResult dlaQuoteRecord : [SELECT  Count(Id) quoteCount , Quote_Number__c quoteNumber FROM Bid_Workbench__c
                                               WHERE Processed__c = false AND Quote_Number__c IN : rfqNumberList GROUP BY Quote_Number__c ]){
            mapBidWorkbenchQuoteCount.put((String)dlaQuoteRecord.get('quoteNumber') , (Decimal)dlaQuoteRecord.get('quoteCount'));//put the quote number size in Map
       
        }
        
        // CPQ quote line size count
        Map<String, Decimal>  mapQuoteLineCount = new Map<String, Decimal>();
        
        For (SBQQ__Quote__c quoteRecords : [SELECT Id, Name ,SBQQ__Status__c,SBQQ__Primary__c, SBQQ__Opportunity2__r.Name ,SBQQ__Opportunity2__r.StageName,
                                          SBQQ__Opportunity2__r.Contract_Type__c ,(Select Id , Vendor_Part_Number__c  from SBQQ__LineItems__r) 
                                          FROM SBQQ__Quote__c where SBQQ__Opportunity2__r.Name != null AND SBQQ__Primary__c = TRUE AND (SBQQ__Opportunity2__r.StageName!='Closed/Lost'
                                          And SBQQ__Opportunity2__r.StageName!='Closed/Won') ]) {
            if(quoteRecords.SBQQ__LineItems__r.size() > 0){
                mapQuoteLineCount.put(quoteRecords.Name, quoteRecords.SBQQ__LineItems__r.size());
                // through this we find  particular quote name and the size of quote line item of that particular Quote 
            }   
        }
        
        //maps 
        Map<String, Map<String , SBQQ__QuoteLine__c>> dualQuoteLineRecordsMap = new Map<string , Map<string , SBQQ__QuoteLine__c>>();
        Map<string, SBQQ__QuoteLine__c> allQuoteLineRecords = new Map<string,SBQQ__QuoteLine__c>();
        Map<string, Decimal> dualsizeMap = new  Map<string , Decimal>();
        list<string> notequalpartnumber = new list<string>();
        list<string> runningLineItemId = new List<string>();
        List<string> CleanupRFQNumber = new List<String>();
        Map<string, Supplier_Cleanup__c> supplierCleanupList = new Map<string, Supplier_Cleanup__c>();
        List<SBQQ__QuoteLine__c> quoteLineQuery = [Select Id,ShipTo_DoDAAC_Line__r.Name,Lead_Time__c,SBQQ__Description__c ,Berry_Applicable__c,
                                                   SBQQ__Quote__r.SBQQ__ShippingState__c,SBQQ__Group__r.Margin__c,SBQQ__Quote__r.Shipping_Overseas__c,
                                                   SBQQ__Quote__r.SBQQ__ShippingCountry__c,SBQQ__UnitCost__c,Country_of_Origin__c, Vendor_Part_Number__c,
                                                   MarginPercent__c ,SBQQ__OriginalPrice__c ,SBQQ__Quote__c,SBQQ__Quote__r.SBQQ__SalesRep__c,
                                                   SBQQ__Quote__r.SBQQ__Status__c,Shipping_from_mfg__c,
                                                   SBQQ__Quote__r.SBQQ__Primary__c,SBQQ__Quote__r.Name,SBQQ__Quote__r.SBQQ__Opportunity2__r.Contract_Type__c,
                                                   SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName, SBQQ__Group__r.Supplier__r.Name,
                                                   SBQQ__Group__r.Shipping_Total_from_mfg__c,SBQQ__Group__r.Payment_Terms__c ,SBQQ__Quote__r.SBQQ__Opportunity2__r.owner.Name,
                                                   SBQQ__Quote__r.SBQQ__Opportunity2__r.ownerId,SBQQ__Quote__r.SBQQ__Opportunity2__r.owner.email,
                                                    SBQQ__Quote__r.SBQQ__Opportunity2__r.Name from SBQQ__QuoteLine__c WHERE SBQQ__Quote__r.Name in : mapQuoteLineCount.keyset() 
                                                   AND Vendor_Part_Number__c IN : productDlaSet];
        // if the CPQ QUote size matches with the workBench Quote Number Size then put the records in the Size map  
        for(SBQQ__QuoteLine__c quoteLineRecords : quoteLineQuery){
            for( Bid_Workbench__c dlaDupRecord : WorkbenchRecordList){
                if(mapQuoteLineCount.get(quoteLineRecords.SBQQ__Quote__r.Name)==mapBidWorkbenchQuoteCount.get(dlaDupRecord.Quote_Number__c))
                {
                    
                    dualsizeMap.put(dlaDupRecord.Order_Item_ID__c,mapQuoteLineCount.get(quoteLineRecords.SBQQ__Quote__r.Name));
                }
            }
        }
        
        list<Bid_Tracker__c> BidTrackerRecordList = new list<Bid_Tracker__c>();
        List<Task> taskCreatedForDeliveryAddressCsv = new List<Task>();
        list<string> rfqbidtracker = new list<string>();
        
        for( Bid_Workbench__c dlaDupRecord : WorkbenchRecordList){
            if( mapXlat.containsKey(dlaDupRecord.Manufacturer_Name__c.toLowerCase()) ){
                
                for(SBQQ__QuoteLine__c quoteLineRecords : quoteLineQuery){
                    if((quoteLineRecords.Vendor_Part_Number__c  == dlaDupRecord.Manufacturer_Part_Number__c) && (mapQuoteLineCount.get(quoteLineRecords.SBQQ__Quote__r.Name)==mapBidWorkbenchQuoteCount.get(dlaDupRecord.Quote_Number__c))){
                        runningLineItemId.add(dlaDupRecord.Order_Item_ID__c);
                        // whole  Quote Line Object
                        if(quoteLineRecords.SBQQ__Quote__r.Name!=null){
                            allQuoteLineRecords.put(quoteLineRecords.Vendor_Part_Number__c, quoteLineRecords);
                            
                        }
                    }
                }
               
                for(SBQQ__QuoteLine__c quoteLineRecords : quoteLineQuery){
                    if((quoteLineRecords.Vendor_Part_Number__c  != dlaDupRecord.Manufacturer_Part_Number__c) && (mapQuoteLineCount.get(quoteLineRecords.SBQQ__Quote__r.Name)==mapBidWorkbenchQuoteCount.get(dlaDupRecord.Quote_Number__c)) && !existinglineItemIdList.contains(dlaDupRecord.Order_Item_ID__c) && !runningLineItemId.contains(dlaDupRecord.Order_Item_ID__c)){
                       notequalpartnumber.add( dlaDupRecord.Order_Item_ID__c);
                        system.debug('notequal partnumber' +dlaDupRecord.Manufacturer_Part_Number__c);
                        system.debug('workbench size  ' +mapBidWorkbenchQuoteCount.get(dlaDupRecord.Quote_Number__c));
                        system.debug(' cpqsize  ' +mapQuoteLineCount.get(quoteLineRecords.SBQQ__Quote__r.Name));
                    }
                }
                
               
                // through this we populate all the salesep driven fields like cost ,margin etc
                dualQuoteLineRecordsMap.put(dlaDupRecord.Order_Item_ID__c ,allQuoteLineRecords);
            }
            // if cannot find the xlat then create cleanup record here ......
            else if(!mapXlat.containsKey(dlaDupRecord.Manufacturer_Name__c.toLowerCase()))
            {
                //------ifconditions not match exclude supplier name
                if(!SupplierNameCleanup.contains(dlaDupRecord.Manufacturer_Name__c.toLowerCase()))
                {
                    Supplier_Cleanup__c cleanupRecords = new Supplier_Cleanup__c();
                    cleanupRecords.Status__c = 'New';
                    cleanupRecords.RFQ_Number__c = dlaDupRecord.Quote_Number__c;
                    cleanupRecords.RFQ_Supplier_Name__c = dlaDupRecord.Manufacturer_Name__c;
                    cleanupRecords.Additional_information__c = dlaDupRecord.Additional_Information__c;
                    supplierCleanupList.put(cleanupRecords.RFQ_Supplier_Name__c.toLowerCase() , cleanupRecords);
                   
                    system.debug('RFQ Number in cleanup-->'+CleanupRFQNumber);
                    
                }
                 CleanupRFQNumber.add(dlaDupRecord.Quote_Number__c);
                system.debug('CleanupRFQNumber-->'+ CleanupRFQNumber);
                system.debug('Supplier CleanUp List-->' + supplierCleanupList);
            }
            // create the bid tracker record here 
            if( mapXlat.containsKey(dlaDupRecord.Manufacturer_Name__c.toLowerCase()) && !CleanupRFQNumber.contains(dlaDupRecord.Quote_Number__c)){
                system.debug('mapXlat.containsKey(dlaDupRecord.Manufacturer_Name__c.toLowerCase()'+ mapXlat.containsKey(dlaDupRecord.Manufacturer_Name__c.toLowerCase()));
                //&& !CleanupRFQNumber.contains(dlaDupRecord.Quote_Number__c) 
                if(!RfqNumberUnique.contains(dlaDupRecord.Quote_Number__c) && !rfqbidtracker.contains(dlaDupRecord.Quote_Number__c)  ){
                    
                    String regexPattern = '.*[02468]$';
                    String QuoteNumber = dlaDupRecord.Quote_Number__c;
                    Pattern myPattern = Pattern.compile(regexPattern);
                    Matcher Mymatcher = myPattern.Matcher(QuoteNumber);
                    Bid_Tracker__c BidTrackerRecord = new Bid_Tracker__c();
                    
                    if(dlaDupRecord.Quote_Number__c !=null)
                        BidTrackerRecord.Name = QuoteNumber;
                    BidTrackerRecord.Load_Batch_Number__c =string.ValueOf(dlaDupRecord.Load_Batch_Number__c);
                    BidTrackerRecord.RecordTypeId = recordTypeIdBidTracker;
                    BidTrackerRecord.TLSP_Supplier_Extension__c = dlaDupRecord.TLSP_Vendor_Extension__c;
                     
                    BidTrackerRecord.Due_Date__c = dlaDupRecord.Quote_Due_Date__c;
                    BidTrackerRecord.Rfq_Stage_ServiceNow__c=dlaDupRecord.serviceNow_RFQ_Stage__c;
                    BidTrackerRecord.Program__c=dlaDupRecord.ServiceNow_RFQ_Program__c;
                    BidTrackerRecord.RFQ_Issue_Date_ServiceNow__c=dlaDupRecord.ServiceNow_RFQ_Issue_Date__c;
                    BidTrackerRecord.Vendor_Assign_To_ServiceNow__c=dlaDupRecord.ServiceNow_Vendor_Assign_To__c;
                    BidTrackerRecord.Updated_On_serviceNow__c=dlaDupRecord.ServiceNow_RFQ_Updated_On__c;
                    BidTrackerRecord.Updated_By_serviceNow__c=dlaDupRecord.ServiceNow_RFQ_Updated_By__c;
                    BidTrackerRecord.Quote_Status_ServiceNow__C=dlaDupRecord.ServiceNow_Quote_Status__c;
                   
                    DateTime now =DateTime.Now();
                    system.debug('now '+now);
                    String currentMonth = now.format('MM'); 
                    system.debug('currentMonth ->' +currentMonth);
                    string BusyMonth =System.Label.Busy_Season_Months;
                    system.debug('s ->' +BusyMonth);
                    if(BusyMonth.containsIgnoreCase(currentMonth)){
                        BidTrackerRecord.Busy_Seasons__c = True;
                    }
                    else {
                        BidTrackerRecord.Busy_Seasons__c = false;
                    }
                    //send Original Quote To supplier .........
                    string SupplierOriginalQuote =System.Label.Months_for_sending_original_suppliers_quote_to_DLA;
                    system.debug('ssss ->' +SupplierOriginalQuote);
                    if(SupplierOriginalQuote.containsIgnoreCase(currentMonth)){
                        BidTrackerRecord.Attach_Supplier_Quote_Months__c = true;
                    }
                    if(dlaDupRecord.RFID_Required__c!=null){
                        iF (dlaDupRecord.RFID_Required__c == 'N') {
                            BidTrackerRecord.Is_an_RFID_Tag_required__c ='No';
                        } else If (dlaDupRecord.RFID_Required__c == 'Y') {
                            BidTrackerRecord.Is_an_RFID_Tag_required__c ='Yes';
                        } else {
                            BidTrackerRecord.Is_an_RFID_Tag_required__c=dlaDupRecord.RFID_Required__c;
                        }
                        
                    }
                    if(dlaDupRecord.FOB_Origin__c!=null){
                        iF (dlaDupRecord.FOB_Origin__c == 'N') {
                            BidTrackerRecord.Is_Destination_FOB_Orgin__c ='No';
                        } else If (dlaDupRecord.FOB_Origin__c == 'Y') {
                            BidTrackerRecord.Is_Destination_FOB_Orgin__c ='Yes';
                        } else {
                            BidTrackerRecord.Is_Destination_FOB_Orgin__c=dlaDupRecord.FOB_Origin__c;
                        }
                        
                        
                    }
                    BidTrackerRecord.Record_Source__c=dlaDupRecord.Record_Source__c;
                    if(dlaDupRecord.ServiceNow_RFQ_Additional_Informatiom__c!=null){
                        BidTrackerRecord.Additional_Information_for_Vendors__c=dlaDupRecord.ServiceNow_RFQ_Additional_Informatiom__c;
                    }
                    if(dlaDupRecord.ServiceNow_RFQ_Program__c  == 'TLS SOE'){
                        BidTrackerRecord.Contract__c = 'TLS SOE';
                        if(Mymatcher.matches()){
                            BidTrackerRecord.OwnerId = aliasIdRFQOwnerMap.get(System.label.Contract_SOE_Ends_with_Even); 
                        }
                        
                        else{
                            BidTrackerRecord.OwnerId = aliasIdRFQOwnerMap.get(System.label.Contract_SOE_RFQ_Ends_with_Odd); 
                        }
                    }
                    else if(dlaDupRecord.ServiceNow_RFQ_Program__c  == 'TLS FES' || dlaDupRecord.ServiceNow_RFQ_Program__c == 'F&ESE'){
                        BidTrackerRecord.Contract__c = 'TLS FES';
                       BidTrackerRecord.OwnerId = aliasIdRFQOwnerMap.get(System.label.Contract_Fes);
                    }
                    else if(dlaDupRecord.ServiceNow_RFQ_Program__c  == 'SOE Tents'){
                        BidTrackerRecord.Contract__c = 'C&E Tent';
                        BidTrackerRecord.OwnerId = aliasIdRFQOwnerMap.get(System.label.Contract_C_E_Tents);
                    }
                     
                    rfqbidtracker.add(dlaDupRecord.Quote_Number__c);
                    BidTrackerRecordList.add(BidTrackerRecord);
                    // bidTrackerId.add(BidTrackerRecord.Id);
                }
            }
        }
        list<Bid_Tracker__c>bidRecInsertList=new list<Bid_Tracker__c>();
        if(!BidTrackerRecordList.isEmpty()){
            for(Bid_Tracker__c bidRecord : BidTrackerRecordList){
                if(!CleanupRFQNumber.contains(bidRecord.Name)){
                    system.debug('in if');
                    bidRecInsertList.add(bidRecord);
                }
                
                
            }
            if(!bidRecInsertList.isEmpty()){
                system.debug('bidRecInsertList'+bidRecInsertList);
                insert bidRecInsertList;
            }
        } 
        
        
        //main List to process the record ...........................................................................................................  
        Map<Id,string> SalesRepBidLine = new Map<Id,string>(); 
        List<Bid_Line_Item__c> mappedRecordsToBid = new List<Bid_Line_Item__c>();
        list<Bid_Workbench__c> processedRecords = new List<Bid_Workbench__c>();
        List<String> failedSalesDrivenQuote  = new List<String>();
        // List<decimal> SuccessSalesDrivenQuote  = new List<decimal>();
        map<string,Id> rfqMap = new map<string,Id>();
        List<Bid_Tracker__c> BidTrackerQuery = [Select Name ,Id from Bid_Tracker__c where Name IN : rfqNumberList];
        for(Bid_Tracker__c  BidTracker : BidTrackerQuery){
            rfqMap.put(BidTracker.Name , BidTracker.Id);
        }
        List<string> quoteNumber = new List<string>();  
        system.debug('WorkbenchRecordList'+WorkbenchRecordList);
        list<Bid_Workbench__c>bid=new list<Bid_Workbench__c>(WorkbenchRecordList);
        system.debug('bid'+bid.size());
        list<string> MissingStateDodaacQuoteNumber =  new list<string>();
          Map<Id,String> mapIdStrQuoteName = new Map<ID,String>();
        Map<Id,string> mapTdstrOppOwner = new Map<Id,string>(); 
        map<id,string> mapidstrOppName = new map<id,string>();
        for ( Bid_Workbench__c recordDla : WorkbenchRecordList){
            system.debug('recordDla'+recordDla);
            map<string,string>salesRepdatMap=new map<string,string>();
            
            Bid_Line_Item__c destinationBids = new Bid_Line_Item__c();
            system.debug(mapXlat.containsKey(recordDla.Manufacturer_Name__c.toLowerCase()));
            system.debug(!CleanupRFQNumber.contains(recordDla.Quote_Number__c));
              //part where PEL Comes 
            if(mapXlat.containsKey(recordDla.Manufacturer_Name__c.toLowerCase()) &&  !CleanupRFQNumber.contains(recordDla.Quote_Number__c))   {
                if(PELRecordList.size() > 0 && recordDla.TLSP_Vendor_Extension__c == 'DAR' && objectPELMap.containsKey(recordDla.Manufacturer_Part_Number__c) && recordDla.Quote_Due_Date__c >= beginDatePeriodIdSOEMap.get(objectPELMap.get(recordDla.Manufacturer_Part_Number__c).PEL_ID__c) && recordDla.Quote_Due_Date__c <= EndDatePeriodIdSOEMap.get(objectPELMap.get(recordDla.Manufacturer_Part_Number__c).PEL_ID__c)){
                    
                    destinationBids.PEL_Price__c = objectPELMap.get(recordDla.Manufacturer_Part_Number__c).Current_Period_SELL__c ;
                    
                     destinationBids.PEL_Price_Cost__c  =  objectPELMap.get(recordDla.Manufacturer_Part_Number__c).Current_Period_Cost__c;
                }
                else if(PELRecordList.size() > 0 && recordDla.TLSP_Vendor_Extension__c == 'WSD' && objectPELMap.containsKey(recordDla.Manufacturer_Part_Number__c) && recordDla.Quote_Due_Date__c >= beginDatePeriodIdFESMap.get(objectPELMap.get(recordDla.Manufacturer_Part_Number__c).PEL_ID__c) && recordDla.Quote_Due_Date__c <= EndDatePeriodIdFESMap.get(objectPELMap.get(recordDla.Manufacturer_Part_Number__c).PEL_ID__c)){
                    
                    destinationBids.PEL_Price__c = objectPELMap.get(recordDla.Manufacturer_Part_Number__c).Current_Period_SELL__c ;
                      destinationBids.PEL_Price_Cost__c  = objectPELMap.get(recordDla.Manufacturer_Part_Number__c).Current_Period_Cost__c;
                    
                }
                system.debug('In IF');
                IF(dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).containsKey(recordDla.Manufacturer_Part_Number__c) ){
                    
               
                    system.debug('dualsizeMap.get(recordDla.Order_Item_ID__c)'+dualsizeMap.get(recordDla.Order_Item_ID__c));
                    system.debug('mapBidWorkbenchQuoteCount.get(recordDla.Quote_Number__c)'+mapBidWorkbenchQuoteCount.get(recordDla.Quote_Number__c));
                    system.debug('= recordDla.ShipTo_DODAAC__'+recordDla.ShipTo_DODAAC__c);
                    
                    //if(dualsizeMap.get(recordDla.Order_Item_ID__c)==mapBidWorkbenchQuoteCount.get(recordDla.Quote_Number__c) &&((recordDla.TLSP_Vendor_Extension__c=='DAR'&& dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Quote__r.SBQQ__Opportunity2__r.Contract_Type__c =='TLS SOE')||(recordDla.TLSP_Vendor_Extension__c=='WSD'&& dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Quote__r.SBQQ__Opportunity2__r.Contract_Type__c =='TLS FES') )&&  dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Group__r.Supplier__r.Name == mapXlat.get(recordDla.Manufacturer_Name__c.toLowerCase()).Name && !notequalpartnumber.contains(recordDla.Order_Item_ID__c) && dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Quote__r.SBQQ__Primary__c == true && (dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName != 'Closed/Lost' || dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName != 'Closed/Won')){
                    if(( dualsizeMap.get(recordDla.Order_Item_ID__c)==mapBidWorkbenchQuoteCount.get(recordDla.Quote_Number__c) 
&&((recordDla.TLSP_Vendor_Extension__c=='DAR'&& dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Quote__r.SBQQ__Opportunity2__r.Contract_Type__c =='TLS SOE')||(recordDla.TLSP_Vendor_Extension__c=='WSD'&& dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Quote__r.SBQQ__Opportunity2__r.Contract_Type__c =='TLS FES') )
//&&  dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Group__r.Supplier__r.Name == mapXlat.get(recordDla.Manufacturer_Name__c.toLowerCase()).Name 
&& !notequalpartnumber.contains(recordDla.Order_Item_ID__c) 
&& dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Quote__r.SBQQ__Primary__c == true 
&& (dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName != 'Closed/Lost' || dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName != 'Closed/Won')
&& dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c ).ShipTo_DoDAAC_Line__r.Name ==  Null)
 || (dualsizeMap.get(recordDla.Order_Item_ID__c)==mapBidWorkbenchQuoteCount.get(recordDla.Quote_Number__c) 
&&((recordDla.TLSP_Vendor_Extension__c=='DAR'&& dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Quote__r.SBQQ__Opportunity2__r.Contract_Type__c =='TLS SOE')||(recordDla.TLSP_Vendor_Extension__c=='WSD'&& dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Quote__r.SBQQ__Opportunity2__r.Contract_Type__c =='TLS FES') )
//&&  dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Group__r.Supplier__r.Name == mapXlat.get(recordDla.Manufacturer_Name__c.toLowerCase()).Name 
&& !notequalpartnumber.contains(recordDla.Order_Item_ID__c) 
&& dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Quote__r.SBQQ__Primary__c == true 
&& (dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName != 'Closed/Lost' || dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName != 'Closed/Won')
&& dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c ).ShipTo_DoDAAC_Line__r.Name !=  Null &&
 dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c ).ShipTo_DoDAAC_Line__r.Name == recordDla.ShipTo_DODAAC__c 
)  
	
	){
                        system.debug('Inner If');
                        system.debug('size check-->'+ dualsizeMap.get(recordDla.Order_Item_ID__c));
                        system.debug('size check 2-->'+mapBidWorkbenchQuoteCount.get(recordDla.Quote_Number__c));
                        
                       // status for Sales Rep Driven order........
                       //Approval Logic Goes Here
                       system.debug('dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Quote__r.SBQQ__Status__c'+dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Quote__r.SBQQ__Status__c);
                        if(dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Quote__r.SBQQ__Status__c == 'Approved'){
                                 destinationBids.Status__c = 'SalesRep Claim';
                            System.debug('destinationBids.Status__c-->'+ destinationBids.Status__c);
                            
                        }
                        else{
                            destinationBids.Status__c = 'Hold';
                            System.debug('destinationBids.Status__c-->'+ destinationBids.Status__c);
                            
                        }
                       //sales Rep
                        destinationBids.Sales_Rep__c =  dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Quote__r.SBQQ__SalesRep__c;
                     system.debug('sales Rep-->'+dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Quote__r.SBQQ__SalesRep__c);
                        //1.Unit Cost .....
                        destinationBids.Unit_Cost__c = dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__UnitCost__c;
                        // for Margin we need  shipping state for the sales Tax Thing
                        destinationBids.ServiceNow_State__c = dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Quote__r.SBQQ__ShippingState__c;
                        // for Margin we need shipping Ovrseas for margin%
                        destinationBids.Country__c = dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Quote__r.SBQQ__ShippingCountry__c;
                        //Payment Terms....
                       destinationBids.Payment_Terms__c = dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Group__r.Payment_Terms__c;
        
        System.debug('Group Payment Terms-->'+dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Group__r.Payment_Terms__c);
                        //Berry Applicable(check box).....
        if(dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).Berry_Applicable__c == true){
                        destinationBids.Berry_Applies__c =  'Yes';
        } else{
             destinationBids.Berry_Applies__c =  'No';
        }
                        //Country of origin.....
                        destinationBids.Country_of_Origin__c = dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).Country_of_Origin__c; 
                        //lead time(Weeks ARO)
                        system.debug('Weeks Aro+++....'+dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).Lead_Time__c);
        If (dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).Lead_Time__c != null) {
            destinationBids.Weeks_ARO__c  = String.valueOf(dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).Lead_Time__c) +'W';
            
        }
        //margin at line level
        if(dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Group__r.Margin__c != null  ) {
                                                      if(dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Quote__r.Shipping_Overseas__c =='Yes'){
                                                          destinationBids.Margin_Percent__c = dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Group__r.Margin__c+0.1;
														  }
														  else{
														      destinationBids.Margin_Percent__c = dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Group__r.Margin__c;
															  }
															  }

                        // payment Terms comes from group Directly in the Line Items....
                        //Comments.......
                        destinationBids.Comments__c = dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Description__c;
                         // shipping from mfg in the line level............
                  destinationBids.Shipping__c = dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).Shipping_from_mfg__c;
        system.debug('Shipping-->'+ dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).Shipping_from_mfg__c);
                  

                    }
                }

                else{
                    system.debug(recordDla.Order_Item_ID__c);
System.debug('Rating Account---->'+FandXRatingAccount.contains(mapXlat.get(recordDla.Manufacturer_Name__c.toLowerCase()).Account__r.Name));
                    if(mapXlat.ContainsKey(recordDla.Manufacturer_Name__c.toLowerCase())){
                        System.debug('In If---------->');
                    if( FandXRatingAccount.contains(mapXlat.get(recordDla.Manufacturer_Name__c.toLowerCase()).Account__r.Name)  ){
                        System.debug('In Else-->');
                    destinationBids.Quote_Type__c = 'No Quote';
                        destinationBids.Comments__c = 'Based on Darley\'s due diligence findings and/or negtive performance history with this manufacturer, we will be submitting a no quote for this Opportunity ';
                        system.debug('destinationBids.Quote_Type__c'+ destinationBids.Quote_Type__c);
                        destinationBids.Status__c = 'RFQ Ready for DLA';
                    }
                        else if((mapXlat.get(recordDla.Manufacturer_Name__c.toLowerCase()).Account__c != null &&
                                  PrimeSupplierAccount.contains(mapXlat.get(recordDla.Manufacturer_Name__c.toLowerCase()).Account__r.Name) 
                                   ) || 
                                 (mapXlat.get(recordDla.Manufacturer_Name__c.toLowerCase()).Lead__c != null && 
                                  mapXlat.get(recordDla.Manufacturer_Name__c.toLowerCase()).Lead__r.Prime_Supplier__c == true 
                                    )){

                           destinationBids.Quote_Type__c = 'No Quote';
                            destinationBids.Status__c = 'RFQ Ready for DLA';      
                            system.debug('destinationBids.Quote_Type__c '+ destinationBids.Quote_Type__c );
                            
                        }
                    }
                    // destinationBids.Sales_Rep__c = Null;
                   // failedSalesDrivenQuote.add(recordDla.Quote_Number__c);
                    //system.debug('failedSalesDrivenQuote' +recordDla.Manufacturer_Part_Number__c);
                }
                
                
                // Query for the Record Type Id based on the Record Type Name
                Id recordTypeId = Schema.SObjectType.Bid_Line_Item__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
                destinationBids.RecordTypeId = recordTypeId;
                
                //Lookups................
                if(recordDla.ShipTo_DODAAC__c != NULL){
                    destinationBids.DoDAAC_Number_Text__c = recordDla.ShipTo_DODAAC__c;
                }
                
                //  1. Ship to dodac
                if(recordDla.ShipTo_DODAAC__c != NULL){
                    if(dodaacMap.containsKey(recordDla.ShipTo_DODAAC__c)){
                        destinationBids.Ship_To_DoDAAC__c = dodaacMap.get(recordDla.ShipTo_DODAAC__c).Id;
                        system.debug('Ship to Dodaac-->' +destinationBids.Ship_To_DoDAAC__c );
                    }
                    else if(!dodaacMap.containsKey(recordDla.ShipTo_DODAAC__c)) {
                        //Create Task Here for the Dodaac......................
                        // destinationBids.Status__c ='Waiting on DoDAAC';
                        system.debug('destinationBids.Status__c-->'+ destinationBids.Status__c);
                    }
                }
                
                
                //2. Manufacturer  Part Number
                if(recordDla.Manufacturer_Part_Number__c != NULL){
                    destinationBids.Supplier_Part_Number__c = recordDla.Manufacturer_Part_Number__c;
                    destinationBids.Darley_Part_Number__c = 'ML'+ recordDla.Manufacturer_Part_Number__c;

                } 
                  
                if(recordDla.Manufacturer_Part_Number__c != Null){
                    if(productMap.containsKey(recordDla.Manufacturer_Part_Number__c)){
                        destinationBids.Part_Number__c = productMap.get(recordDla.Manufacturer_Part_Number__c);
                    }
                   
                }
                // 3.Account Lookup on Bid Supplier
                //Condition to check whether the manufacturer name is in the xlat or not..........................
                if(mapXlat.containsKey(recordDla.Manufacturer_Name__c.toLowerCase()))
                {
                    if(mapXlat.get(recordDla.Manufacturer_Name__c.toLowerCase()).Account__r.Name != null  ){
                        if(destinationBids.Payment_Terms__c == null){
                     destinationBids.Payment_Terms__c = mapXlat.get(recordDla.Manufacturer_Name__c.toLowerCase()).Account__r.Payment_Terms_Bid_Tracker__c;
                        }
                    destinationBids.Supplier_Name_Text__c = mapXlat.get(recordDla.Manufacturer_Name__c.toLowerCase()).Account__r.Name;//get function always take values in the map
                        system.debug('Accountname'+ mapXlat.get(recordDla.Manufacturer_Name__c.toLowerCase()).Account__r.Name);
                }
                else{
                                    if(destinationBids.Payment_Terms__c == null){

                 destinationBids.Payment_Terms__c = mapXlat.get(recordDla.Manufacturer_Name__c.toLowerCase()).Lead__r.Payment_Terms_Bid_Tracker__c;
                    
                                                 }
                    destinationBids.Supplier_Name_Text__c = mapXlat.get(recordDla.Manufacturer_Name__c.toLowerCase()).Lead__r.Company;
                system.debug('LeadName'+ mapXlat.get(recordDla.Manufacturer_Name__c.toLowerCase()).Lead__r.Company);

                }
                    system.debug('destinationBids.Supplier_Name_Text__c'+destinationBids.Supplier_Name_Text__c);
                }
                if(recordDla.Manufacturer_Name__c != null){
                    if(mapXlat.containsKey(recordDla.Manufacturer_Name__c.toLowerCase())){
                        destinationBids.Bid_Supplier__c = mapXlat.get(recordDla.Manufacturer_Name__c.toLowerCase()).Account__c;
                        destinationBids.Lead__c = mapXlat.get(recordDla.Manufacturer_Name__c.toLowerCase()).Lead__c;
                       
                        
                        system.debug( 'Bid Supplier Lookup Account--> ' + destinationBids.Bid_Supplier__c);
                        system.debug( 'Bid Supplier Lead__c--> ' + destinationBids.Lead__c);
                        
                    }
                    
                }
                
                
                //name ..........to concat the three field 
                if(recordDla.Quote_Number__c != null && recordDla.Order_Item_ID__c !=null && recordDla.TLSP_Vendor_Extension__c != null){
                    destinationBids.Name = recordDla.TLSP_Vendor_Extension__c+'-'+recordDla.Order_Item_ID__c+'-'+recordDla.Quote_Number__c;
                    
                } 
                //Vendor Id
                if(recordDla.Vendor_ID__c != NULL){
                    destinationBids.Vendor_ID__c = decimal.valueOf(recordDla.Vendor_ID__c);
                } 
                

                //RFQ Number 

                if(recordDla.Quote_Number__c != Null){

                    If ( recordDla.Quote_Number__c != Null && recordDla.Manufacturer_Part_Number__c != null) {

                        If (dualQuoteLineRecordsMap.containsKey(recordDla.Order_Item_ID__c)){

                            If ( dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).containsKey(recordDla.Manufacturer_Part_Number__c)){

                                iF ( dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Quote__r.Name!= NULL &&  rfqMap.get(recordDla.Quote_Number__c) != Null){

                                    mapIdStrQuoteName.put(rfqMap.get(recordDla.Quote_Number__c),dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Quote__r.Name);
                                    mapTdstrOppOwner.put(rfqMap.get(recordDla.Quote_Number__c),dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Quote__r.SBQQ__Opportunity2__r.owner.Email);
                                        mapidstrOppName.put(rfqMap.get(recordDla.Quote_Number__c),dualQuoteLineRecordsMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c).SBQQ__Quote__r.SBQQ__Opportunity2__r.Name);
                                }

                            }

                            

                        }

                        

                    }





                    destinationBids.RFQ_Number__c = rfqMap.get(recordDla.Quote_Number__c);

                }
                //tlsp supplier Extension
                if(recordDla.TLSP_Vendor_Extension__c != NULL){
                    destinationBids.TLSP_Supplier_Extension__c = recordDla.TLSP_Vendor_Extension__c;
                } 
                //Region 
                if(recordDla.Region__c != NULL){
                    destinationBids.Region__c = recordDla.Region__c;
                }  
                //Region group 
                if(recordDla.Region_Group__c != NULL){
                    destinationBids.Region_Group__c = recordDla.Region_Group__c;
                }  
                //Request Type 
                if(recordDla.Request_Type__c != NULL){
                    destinationBids.Request_Type__c = recordDla.Request_Type__c;
                }  
                //order item id/Line item Id
                if(recordDla.Order_Item_ID__c != NULL){
                    destinationBids.Line_Item_ID__c = recordDla.Order_Item_ID__c;
                }  
                //core List Number
                if(recordDla.Core_List_Number__c != NULL){
                    destinationBids.Core_List_Number__c = Integer.valueOf(recordDla.Core_List_Number__c);
                }  
                //National Stock Number
                if(recordDla.NSN__c != NULL){
                    destinationBids.National_Stock_Number__c = recordDla.NSN__c;
                }  
                
                
                //Item Description
                if(recordDla.Item_Description__c != Null && destinationBids.Item_Description__c==null){
                    destinationBids.Item_Description__c = recordDla.Item_Description__c;
                }
                //Additional Information
                if(recordDla.Additional_Information__c != Null){
                    destinationBids.Additional_Information__c = recordDla.Additional_Information__c;
                }
                //Requested Delivery
                if(recordDla.Requested_Delivery_Date__c != Null){
                    destinationBids.Requested_Delivery_Date__c = recordDla.Requested_Delivery_Date__c;
                }
                // Unit of Issue 
                if(recordDla.Unit_of_Issue__c != NULL){
                    destinationBids.Unit_of_Issue__c =recordDla.Unit_of_Issue__c;
                }
                // Quantity
                if(recordDla.Quantity__c != Null){
                    destinationBids.Quantity__c = recordDla.Quantity__c;
                }
               
                // Record_Source__c
                if(recordDla.Record_Source__c != NULL){
                    destinationBids.Record_Source__c = recordDla.Record_Source__c;
                }
                //It comes when data Comes from Service Now then add these Field
                   // for servieNow 
                if(recordDla.Record_Source__c == 'ServiceNow'){
                    //Delivery City 
                    if(recordDla.City__c != null){
                    destinationBids.City__c = recordDla.City__c;
                    }
                    //Delivery Country
                    if(recordDla.Country__c != NULL){
                    destinationBids.Country__c = recordDla.Country__c;
                } 
                     // Delievery State------------
                if(recordDla.State__c != NULL ){
                    destinationBids.ServiceNow_State__c = recordDla.State__c;
                     } 
                    // Zip Code    
                if(recordDla.Zip_Code__c != NULL){
                    destinationBids.ZIP_Postal_Code__c =(recordDla.Zip_Code__c);
                }  
                }
                 // for CSV
                if(recordDla.Record_Source__c == 'CSV'  && dodaacMap.containsKey(recordDla.ShipTo_DODAAC__c)){
                    //Delivery City 
                    if(recordDla.City__c == null){
                    destinationBids.City__c = dodaacMap.get(recordDla.ShipTo_DODAAC__c).TAC2_Ship_To_City__c;
                    }
                    //Delivery Country
                    if(recordDla.Country__c == NULL){
                    destinationBids.Country__c = dodaacMap.get(recordDla.ShipTo_DODAAC__c).TAC2_Ship_To_Country_Name__c;
                } 
                     // Delievery State------------
                if(recordDla.State__c == NULL ){
                    destinationBids.ServiceNow_State__c = dodaacMap.get(recordDla.ShipTo_DODAAC__c).TAC2_Ship_To_State_A_Province__c;
                     } 
                    // Zip Code    
                if(recordDla.Zip_Code__c == NULL){
                    destinationBids.ZIP_Postal_Code__c =  dodaacMap.get(recordDla.ShipTo_DODAAC__c).TAC2_Ship_To_Zip__c;
                }  
                }
                  //Delievery Destination
                if(recordDla.Delivery_Destination__c  != NULL){
                    destinationBids.Delivery_Address__c =recordDla.Delivery_Destination__c;
                }                     
                
               //FOB Origin
                if(recordDla.FOB_Origin__c != Null){
                    If (recordDla.FOB_Origin__c =='N') {
                        destinationBids.FOB_Origin__c ='No';
                    } else If (recordDla.FOB_Origin__c =='Y') {
                        destinationBids.FOB_Origin__c ='Yes';
                    } else {
                        destinationBids.FOB_Origin__c = recordDla.FOB_Origin__c;
                    }
                    
                }
                
                //RFID Required
                if(recordDla.RFID_Required__c != Null){
                    If (recordDla.RFID_Required__c == 'N') {
                        destinationBids.RFID_Required__c  = 'No';                        
                    } else If (recordDla.RFID_Required__c == 'Y') {
                         destinationBids.RFID_Required__c  = 'Yes';    
                    } else {
                        destinationBids.RFID_Required__c = recordDla.RFID_Required__c;
                    }
                    
                }
                //Special Project Code
                if(recordDla.Special_Project_Code__c != Null){
                    destinationBids.Special_Project_Code__c = recordDla.Special_Project_Code__c;
                }
                //Transportation Price Required
                if(recordDla.Transportation_Price_Required__c != Null){
                    destinationBids.Transportation_Price_Required__c = recordDla.Transportation_Price_Required__c;
                }
                //Transportation Price 
                if(recordDla.Transportation_Price__c!= Null){
                 //   destinationBids.Transportation_Price__c =decimal.valueOf(recordDla.Transportation_Price__c);
                }
                //Vendor unit price 
                if(recordDla.Vendor_Unit_Price__c != Null){
                //    destinationBids.Vendor_Price__c= decimal.valueOf(recordDla.Vendor_Unit_Price__c);
                }
                //Purchase Unit Price 
                if(recordDla.Purchase_Unit_Price__c != Null){
                    system.debug('recordDla.Purchase_Unit_Price__c'+recordDla.Purchase_Unit_Price__c);
                    system.debug('recordDla.id'+recordDla.id);
                    
                    //destinationBids.Purchase_Unit_Price__c =  decimal.valueOf(recordDla.Purchase_Unit_Price__c);
                    // system.debug('destinationBids.Purchase_Unit_Price__c'+destinationBids.Purchase_Unit_Price__c);
                    
                    // destinationBids.Purchase_Unit_Price__c =  decimal.valueOf(recordDla.Purchase_Unit_Price__c.substring(1,recordDla.Purchase_Unit_Price__c.length()));
                }
                //Purchase Extended Price 
                if(recordDla.Purchase_Extended_Price__c != Null){
                   // destinationBids.Purchase_Extended_Price__c =  decimal.valueOf(recordDla.Purchase_Extended_Price__c);
                    
                    // destinationBids.Purchase_Extended_Price__c = decimal.valueOf(recordDla.Purchase_Extended_Price__c.substring(1,recordDla.Purchase_Extended_Price__c.length()));
                }
                //Lead Time 
                if(recordDla.Lead_Time__c!= Null){
                  //  destinationBids.Lead_Time_Days__c = integer.valueOf(recordDla.Lead_Time__c);
                }
               
                //Procurement agreement Complaint
                if(recordDla.Procurement_Agreement_Compliant__c!= Null){
                    destinationBids.Procurement_Agreement_Compliant__c = recordDla.Procurement_Agreement_Compliant__c;
                }
                //Berry Amendment Complaint
                if(recordDla.Berry_Amendment_Compliant__c != Null  ){
                    If(recordDla.Berry_Amendment_Compliant__c =='n/a'|| recordDla.Berry_Amendment_Compliant__c =='Not Applicable' ||recordDla.Berry_Amendment_Compliant__c =='N/A' ||recordDla.Berry_Amendment_Compliant__c =='na'  ){
                        destinationBids.Berry_Applies__c = 'No';

                    }
                     else if (recordDla.Berry_Amendment_Compliant__c =='Y'|| recordDla.Berry_Amendment_Compliant__c =='y' || recordDla.Berry_Amendment_Compliant__c =='Yes'||recordDla.Berry_Amendment_Compliant__c =='yes'){
                         destinationBids.Berry_Applies__c = 'Yes';

                    }
                }
                // Country of origin
                if(recordDla.Country_of_Origin__c != Null && destinationBids.Country_of_Origin__c == null){
                    system.debug('recordDla.Country_of_Origin__c'+recordDla.Country_of_Origin__c);
                      destinationBids.Country_of_Origin__c = recordDla.Country_of_Origin__c;
                }
                                
                //Customer Permits Alternate
                if(recordDla.Customer_Permits_Alternates__c != Null){
                    If (recordDla.Customer_Permits_Alternates__c == 'Y') {
                        destinationBids.Customer_Permits_Alternates__c = 'Yes';
                    } else If (recordDla.Customer_Permits_Alternates__c == 'N') {
                        destinationBids.Customer_Permits_Alternates__c = 'No';
                    } else {
                        destinationBids.Customer_Permits_Alternates__c = recordDla.Customer_Permits_Alternates__c;
                    }
                    
                }
                
                //extra files which we have to process .............
               
                if(recordDla.Alternate_Item_Offered__c != null){
                    if(recordDla.Alternate_Item_Offered__c == 'Yes'){
                        destinationBids.Regular_vs_Alternative__c = 'Alternative';
                    }
                    else{
                        destinationBids.Regular_vs_Alternative__c = 'Regular' ;
                    }
                }
                //quote...........................................................................................................
                //Load Batch Number
                if(recordDla.Load_Batch_Number__c != NULL){
                    destinationBids.Load_Batch_Number__c = String.valueOf(recordDla.Load_Batch_Number__c);
                }
                //Quote Due Date
                if(recordDla.Quote_Due_Date__c != NULL){
                    destinationBids.Due_Date__c = recordDla.Quote_Due_Date__c;
                }
                //Quote Number
                if(recordDla.Quote_Number__c != NULL){
                    destinationBids.Quote_Numbers__c =recordDla.Quote_Number__c;
                }
                
                
                
                if(recordDla.Acquisition_Cost__c != NULL){
                    destinationBids.ServiceNow_Acquistion_cost__c = (recordDla.Acquisition_Cost__c);
                }
                
                if(recordDla.Customer_Extended_Price__c != NULL){
                    destinationBids.ServiceNow_Customer_Extended_Price__c = decimal.valueof(recordDla.Customer_Extended_Price__c);
                }
                
                if(recordDla.Email__c != NULL){
                    destinationBids.POC_Email__c =recordDla.Email__c;
                }
                
                if(recordDla.First_Name__c != NULL || recordDla.Last_Name__c != NULL ){
                    destinationBids.POC_Name__c = recordDla.First_Name__c +' '+ recordDla.Last_Name__c;
                }
               if(recordDla.Intended_Use__c != NULL){
                    destinationBids.Intended_Use__c =recordDla.Intended_Use__c;
                }
               
                if(recordDla.MIPR_Code__c != NULL){
                    destinationBids.ServiceNow_MIPR_Code__c =recordDla.MIPR_Code__c;
                }
                if(recordDla.Mission_Impact_Statement__c != NULL){
                    destinationBids.ServiceNow_Mission_Impact_Statement__c  =recordDla.Mission_Impact_Statement__c;
                }
                if(recordDla.Other_Cost__c != NULL){
                    destinationBids.ServiceNow_Other_Cost__c = recordDla.Other_Cost__c;
                }
                if(recordDla.Phone__c != NULL){
                    destinationBids.POC_Phone__c = recordDla.Phone__c; 
                }
                if(recordDla.Special_Instructions__c != NULL){
                    destinationBids.ServiceNow_Special_Instruction__c = recordDla.Special_Instructions__c; 
                }
                
                if(recordDla.Timeframe__c != NULL){
                    destinationBids.ServiceNow_Timeframe__c = recordDla.Timeframe__c; 
                }
                
                
                if(recordDla.Unit__c != NULL){
                    destinationBids.POC_Unit__c = recordDla.Unit__c; 
                }
               
                system.debug('destinationBids'+destinationBids );
                mappedRecordsToBid.add(destinationBids);
                
                SalesRepBidLine.put(destinationBids.RFQ_Number__c ,destinationBids.Sales_Rep__c) ; 
                System.debug('SalesRepBidLine-->' + SalesRepBidLine);
                system.debug('destination-->'+destinationBids);
                 if(recordDla.Record_Source__c == 'ServiceNow'){

                    recordDla.Quote_Number__c = 'RFQ'+ recordDla.Quote_Number__c ;

                }
                recordDla.Processed__c = true;
                recordDla.Last_Batch_Modified__c = Datetime.now();
                processedRecords.add(recordDla);
                // system.debug('processedRecords size-->'+processedRecords.size());
            }
            
        }
        
        
        
        insert supplierCleanupList.Values();
        system.debug('Inserted Cleanup Record-->'+supplierCleanupList.Values());
        If(!mappedRecordsToBid.isEmpty()){
            lIST<Bid_Line_Item__c> listBidLineInset = MapBidBatch.creatTheBidgroupItemAndLinkToBidLIn(mappedRecordsToBid,dualQuoteLineRecordsMap);
            
            insert listBidLineInset; 
            listBidLineSendToQuable.addAll(mappedRecordsToBid);
        }
    
        system.debug('insert list-->'+mappedRecordsToBid); 
        system.debug('insert list size-->'+mappedRecordsToBid.size());
        workbenchTrigger_handler.isBidWorkBenchTrigger=false;
        update processedRecords;
       // for Bid tracker Sales Rep Update and send the email to inside and outside sales Rep Both
        List<Bid_Tracker__c> bidTrackerUpdate = new List<Bid_Tracker__c>();
            Map<id,Task> maptaskInsert = new map<id,Task>();

        List<Bid_Tracker__c> SuccessSalesRepBidTracker = [Select Id,Name,Sales_Rep_Driven__c,CPQ_Sales_Rep__r.Name, OwnerId, (SELECT Id,Customer_Permits_Alternates__c,Status__c, Sales_Rep__r.Name, Sales_Rep__r.Email From Bid_Items__r ) from Bid_Tracker__c where   Id IN : SalesRepBidLine.KeySet()  ];
        List<Messaging.SingleEmailMessage> emailToSalesRep = new List<Messaging.SingleEmailMessage>();
        system.debug('SuccessSalesRepBidTracker Query -- > ' + SuccessSalesRepBidTracker);
        for(Bid_Tracker__c bidTracker : SuccessSalesRepBidTracker){
             If (mapIdStrQuoteName.containsKey(bidTracker.Id) ) {

                    bidTracker.CPQ_Quote_Number__c = mapIdStrQuoteName.get(bidTracker.Id);
                // bidtracker.Outside_SalesRep__c = mapTdstrOppOwner.get(bidTracker.Id);
}
            If(bidTracker.Sales_Rep_Driven__c == false){
                Id salesRepId = SalesRepBidLine.get(bidTracker.Id); 
                
                
                bidTracker.CPQ_Sales_Rep__c = salesRepId;
                
                system.debug('Store Email of Sales Rep-->'+ bidTracker.Bid_Items__r[0].Sales_Rep__r.Email);
                system.debug('SalesRepBidLine.get(bidTracker.Id)'+ SalesRepBidLine.get(bidTracker.Id));
                //bidTrackerUpdate.add(bidTracker);
                if (String.isNotBlank( bidTracker.Bid_Items__r[0].Sales_Rep__r.Email) && mapTdstrOppOwner.containskey(bidTracker.Id) ) {
                   
                    bidTracker.Sales_Rep_Driven__c = TRUE;
                    bidTrackerUpdate.add(bidTracker);
                    //salesRepEmails.add(bidTracker.CPQ_Sales_Rep__r.Email);
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.subject= 'DLA RFQ Received :'+mapidstrOppName.get(bidTracker.Id)+','+ mapIdStrQuoteName.get(bidTracker.id)+',' + bidTracker.Name ;
                    email.setToAddresses(new String[] { bidTracker.Bid_Items__r[0].Sales_Rep__r.Email , mapTdstrOppOwner.get(bidTracker.Id)});
                    String recordUrl = URL.getOrgDomainUrl().toExternalForm() + '/' + bidTracker.Id;
                    
                    email.setHtmlBody('Hi! ,\n\nWe have some updates regarding the quote. \nThis Quote is Sales Rep Driven do you want to changed this to not Sales Rep Driven RFQ'+'<br/>'+'<a href="'+ recordUrl +'">'+ recordUrl + '</a>');
                    emailToSalesRep.add(email);
                    system.debug( 'Email To Sales Rep-->'+email);
                }
               
                
            }
            
            If(bidTracker.Bid_Items__r[0].status__c =='Hold' && bidTracker.Bid_Items__r[0].sales_rep__c != null){
                Task newTask = new Task();
                newTask.Subject = 'The CPQ Quote is not Approved having RFQ Number- '+bidTracker.Name+ 'and CPQ Quote(' +mapIdStrQuoteName.get(bidTracker.Id)+')';
                newTask.Description = 'Can you please Approve this RFQ: ' + bidTracker.Name;
                newTask.Status = 'Not Started';
                newTask.Priority = 'Normal';
                newTask.WhatId = bidTracker.Id;
                newTask.OwnerId = bidTracker.OwnerId; // Assign task to rfq  owner
               maptaskInsert.Put( bidTracker.Id,newTask);
                
            }
            
            
        }
        Update bidTrackerUpdate;
       insert maptaskInsert.values();
        IF (!Test.isRunningTest()){
             Messaging.sendEmail(emailToSalesRep);
        }
       
    
    } 
    
    
     // insertign the bid line group and linking the group to the bid lineitme 
    public static list<Bid_line_item__c> creatTheBidgroupItemAndLinkToBidLIn(List<Bid_line_item__c> lineItemListNew ,Map<string , Map<string , SBQQ__QuoteLine__c>> mapStrMapStrQuoteLine ){  
 
     
        Set<Id> setIDAccId = new Set<Id>();
        for(Bid_Line_Item__c bidline : lineItemListNew){
            IF(bidline.Bid_Supplier__r.Name!=null){
                setIDAccId.add( bidline.Bid_Supplier__c);
                setIDAccId.add(bidline.RFQ_Number__c);
            } else {
                setIDAccId.add( bidline.Lead__c);
                setIDAccId.add(bidline.RFQ_Number__c);
            }
        } 
        System.debug('List of the id Acc And Lead or RFQ'+setIDAccId);
        Map<String,Id> mapIDAccRefBidgroupPreseInOrg = new Map<String,Id>();
        If(!setIDAccId.isEmpty()){
            For(Bid_Group_Items__c bidGrovar : [select id, name, Supplier__c, RFQ_Number__c, Lead__c, Supplier_Payment_Terms__c  FROM Bid_Group_Items__c WHERE
                                                (Supplier__c In : setIDAccId AND RFQ_Number__c In : setIDAccId) OR  (Lead__c In : setIDAccId AND RFQ_Number__c In : setIDAccId) ]){
                                                    If(bidGrovar.Supplier__c!=null){
                                                        mapIDAccRefBidgroupPreseInOrg.put((String)bidGrovar.Supplier__c+(String)bidGrovar.RFQ_Number__c,bidGrovar.id);
                                                    } else {
                                                        mapIDAccRefBidgroupPreseInOrg.put((String)bidGrovar.Lead__c+(String)bidGrovar.RFQ_Number__c,bidGrovar.id);
                                                    }
                                                    
                                                }
        }
        system.debug('the bid group Item Presendt in the Org '+mapIDAccRefBidgroupPreseInOrg.Values());
        list<Bid_Line_Item__c> lsitUpdateBidLIn = new  list<Bid_Line_Item__c>();
        Map<string,Bid_Group_Items__c> mapAccIdRfqid = new Map<string,Bid_Group_Items__c>();
        For(Bid_Line_Item__c bidLineVar : lineItemListNew ){
            If(mapIDAccRefBidgroupPreseInOrg.containsKey((String)bidLineVar.Bid_Supplier__c+(String)bidLineVar.RFQ_Number__c) || mapIDAccRefBidgroupPreseInOrg.containsKey((String)bidLineVar.Lead__c+(String)bidLineVar.RFQ_Number__c) ){
                If(mapIDAccRefBidgroupPreseInOrg.containsKey((String)bidLineVar.Bid_Supplier__c+(String)bidLineVar.RFQ_Number__c)){
                    bidLineVar.Bid_Group_Items__c=mapIDAccRefBidgroupPreseInOrg.get((String)bidLineVar.Bid_Supplier__c+(String)bidLineVar.RFQ_Number__c);
                    lsitUpdateBidLIn.add(bidLineVar);
                } else If (mapIDAccRefBidgroupPreseInOrg.containsKey((String)bidLineVar.Lead__c+(String)bidLineVar.RFQ_Number__c)){
                    bidLineVar.Bid_Group_Items__c=mapIDAccRefBidgroupPreseInOrg.get((String)bidLineVar.Lead__c+(String)bidLineVar.RFQ_Number__c);
                    // mapBidItemUpdate.put(bidLineVar.Id,bidLineVar);
                    lsitUpdateBidLIn.add(bidLineVar);
                }
            } else {
                Bid_Group_Items__c bidGroupItem = new Bid_Group_Items__c();
                If(bidLineVar.Bid_Supplier__c != null ){
                    bidGroupItem.Name = bidLineVar.Supplier_Name_Text__c;
                    bidGroupItem.Supplier__c = bidLineVar.Bid_Supplier__c;
                } else { 
                    bidGroupItem.Name = bidLineVar.Supplier_Name_Text__c;
                    bidGroupItem.Lead__c = bidLineVar.lead__c;
                    
                }
                bidGroupItem.Supplier_Payment_Terms__c =  bidLineVar.Payment_Terms__c;
                bidGroupItem.RFQ_Number__c = bidLineVar.RFQ_Number__c;
                If (bidLineVar.sales_rep__c != null) {
                    If ( mapStrMapStrQuoteLine.containsKey(bidLineVar.Line_Item_ID__c)){
                        If (mapStrMapStrQuoteLine.get(bidLineVar.Line_Item_ID__c).containsKey(bidLineVar.Supplier_Part_Number__c)) {
                            bidGroupItem.Margin__c= mapStrMapStrQuoteLine.get(bidLineVar.Line_Item_ID__c).get(bidLineVar.Supplier_Part_Number__c).SBQQ__Group__r.Margin__c;
                        }
                        
                    }
                }
              If(bidLineVar.Bid_Supplier__c != null ){
                    mapAccIdRfqid.put((String)bidLineVar.Bid_Supplier__c+(String)bidLineVar.RFQ_Number__c, bidGroupItem);
                } else {
                    mapAccIdRfqid.put((String)bidLineVar.Lead__c+(String)bidLineVar.RFQ_Number__c, bidGroupItem);
                }
              
            }
         
        }
        If(!mapAccIdRfqid.isEmpty()){
            system.debug('list of the bid group Insert '+mapAccIdRfqid.values());
            
            // insert mapAccIdRfqid.values();
            DataBase.saveResult[] saveResult = database.Insert(mapAccIdRfqid.values(),False);
            for (Database.SaveResult sr : saveResult) {
                if (sr.isSuccess()) { 
                    System.debug( sr.getId()); 
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(err.getStatusCode() + ' : ' +err.getMessage() + ' : ' + err.getFields());
                        system.debug('error'+err);
                    }
                }
            }
        }
        For(Bid_Line_Item__c bidLineVar : lineItemListNew ){
            system.debug('bidLineVar'+bidLineVar.id);
            system.debug('the Bid group id to the Bid Line itme Acc  '+bidLineVar.Bid_Group_Items__c);
            If(mapAccIdRfqid.containsKey((String)bidLineVar.Bid_Supplier__c+(String)bidLineVar.RFQ_Number__c)){
                bidLineVar.Bid_Group_Items__c=mapAccIdRfqid.get((String)bidLineVar.Bid_Supplier__c+(String)bidLineVar.RFQ_Number__c).Id;
                lsitUpdateBidLIn.add(bidLineVar);
            } else  if (mapAccIdRfqid.containskey((String)bidLineVar.Lead__c+(String)bidLineVar.RFQ_Number__c)) {
                system.debug('the Bid group id to the Bid Line itme lead  '+mapAccIdRfqid.get((String)bidLineVar.Lead__c+(String)bidLineVar.RFQ_Number__c).Id);
                bidLineVar.Bid_Group_Items__c=mapAccIdRfqid.get((String)bidLineVar.Lead__c+(String)bidLineVar.RFQ_Number__c).Id;
                lsitUpdateBidLIn.add(bidLineVar);
            }
            
            
        }
        return lsitUpdateBidLIn;
        
      /*  If(!lsitUpdateBidLIn.isempty()){
            system.Debug('list of the bid LIne Update '+lsitUpdateBidLIn);
            BidLineItemTriggerHandler.isBidLineItemTrigger = false;
           // Update lsitUpdateBidLIn;
        }*/
    } 
    
    
    global void finish(Database.BatchableContext info) {
        system.debug('restartJob finish'+restartJob);
        
        if(restartJob==false){
            String strJobId = Database.executeBatch(new MapBidBatch());
            system.debug('strJobId : '+strJobId);
        }
    
        If (!listBidLineSendToQuable.isEmpty()) {
            System.enqueueJob(new BidLineItemQueable(listBidLineSendToQuable));  
            system.debug(' the  bid Line send to Quable ==>'+listBidLineSendToQuable);
            system.debug(' the  bid Line send to Quable SIZE  ==>'+listBidLineSendToQuable.size());
        }
           if(!Test.isRunningTest()) {
            System.scheduleBatch(new MapBidbatch(), 'MapBidBatch', 5, 200);
        }
        
        
    }
 
    
    
}