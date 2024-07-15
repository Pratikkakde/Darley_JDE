/******************************************************************************************************************************************************
Name                    : BidTrackerTrigger_handler
Author                  : Melonleaf


Description             :This class is written to perform update Dml at bid line.
Version                 : 1.0
Change Log              : 
Test Class              : BidTrackerTrigger_Test
CreateDate              : 25-05-2024
LastModifiedDate        : 25-05-2024
******************************************************************************************************************************************************/

public class BidTrackerTrigger_handler {
    public static boolean isBidTrackerTrigger=true;
 /******************************************************************************************************************************************************
This method is written to insert the Attachment if the rfq number matches with workbench parent name and record source is ServiceNow
Criteria: After Insert
/******************************************************************************************************************************************************/
    public static void InsertAttachment(list<Bid_Tracker__c>newList){
        list<string>RfqNumSetSet=new list<string>();
        map<string,Bid_Tracker__c> mapNameId = new map<string,Bid_Tracker__c>();
        
        Id LineItemRecordTypeId = Schema.SObjectType.Bid_Tracker__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
        for(Bid_Tracker__c bid:newList){
            if(bid.RecordTypeId  == LineItemRecordTypeId){
               
                RfqNumSetSet.add('RFQ'+bid.Name);
                mapNameId.put('RFQ'+bid.Name,bid);
            }
        }
    
        
        set<id> idforContent = new set<id>();
        map<Id,string> mapNameIdWork = new map<Id,String>();
        For(Workbench_parent__c prtWork : [Select Id,Name from Workbench_parent__c where name In:RfqNumSetSet]){
            idforContent.add(prtWork.Id);
            mapNameIdWork.put(prtWork.id,prtWork.Name);
        }
        system.debug('idforContent'+idforContent);
        
        List<ContentDocumentLink> insertContetDoc =new List<ContentDocumentLink>();
        if(!idforContent.isEmpty()){
            For(ContentDocumentLink coDoLink : [select id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId in :idforContent ]){
                ContentDocumentLink conbtVarInt = new ContentDocumentLink();
                If(mapNameIdWork.containskey(coDoLink.LinkedEntityId)){
                    If(mapNameId.Containskey(mapNameIdWork.get(coDoLink.LinkedEntityId))){
                        conbtVarInt.LinkedEntityId=mapNameId.get(mapNameIdWork.get(coDoLink.LinkedEntityId)).Id;
                    }
                }
                conbtVarInt.ContentDocumentId=coDoLink.ContentDocumentId;
                insertContetDoc.add(conbtVarInt);
            }
        }
        If(!insertContetDoc.isEmpty()){
            insert insertContetDoc;
            
        }
    }
    
    
 /******************************************************************************************************************************************************
This method is written to Empty the values of certain fields of bidline when sales rep driven checkbox is unchecked
Criteria: After update
/******************************************************************************************************************************************************/
 
    // When user Manually clicks on the Sales Rep Driven Order Checkbox to make it NO Sales Rep Driven.....................
    public static void NoSalesRepDriven(List<Bid_Tracker__c> bidTrackerList,map<id,Bid_Tracker__c> oldValueBidtracker){
        Set<id> setIDBidTrack = new  Set<id>();
        If (!bidTrackerList.isEmpty()){
            For (Bid_Tracker__c bidtack :bidTrackerList ) {
                If (bidtack.Sales_Rep_Driven__c == false && oldValueBidtracker.get(bidtack.Id).Sales_Rep_Driven__c == true ) {
                    setIDBidTrack.add(bidtack.Id);
                } 
                
            }
        }
        
        List<Bid_line_item__c> listUpdateNoSalesRep = new List<Bid_line_item__c>();
        
        IF(!bidTrackerList.isEmpty()){
            
            For (Bid_Tracker__c bidtack : [select id, (select id,Status__c,Payment_Terms__c,Comments__c,Weeks_ARO__c,Country_of_Origin__c,RFQ_Number__c,
                                              Margin_Percent__c,Unit_Cost__c,RFQ_Number__r.Sales_Rep_Driven__c ,Sales_Rep__c from Bid_Items__r
                                                       where RFQ_Number__c In :bidTrackerList ) from Bid_Tracker__c where Id In : setIDBidTrack]){ 
            For(Bid_line_item__c bidQuery : bidtack.Bid_Items__r ){
                If(bidQuery.RFQ_Number__r.Sales_Rep_Driven__c != oldValueBidtracker.get(bidQuery.RFQ_Number__c).Sales_Rep_Driven__c && bidQuery.RFQ_Number__r.Sales_Rep_Driven__c==false && oldValueBidtracker.get(bidQuery.RFQ_Number__c).Sales_Rep_Driven__c == true){
                    if(bidQuery.Sales_Rep__c != null){
                        bidQuery.Sales_Rep__c = Null;  
                    }
                    if(bidQuery.Unit_Cost__c != null){
                        bidQuery.Unit_Cost__c = Null;  
                    }
                    if(bidQuery.Margin_Percent__c != null){
                        bidQuery.Margin_Percent__c = Null;  
                    }
                   
                    if(bidQuery.Country_of_Origin__c != null){
                        bidQuery.Country_of_Origin__c = Null;  
                    }
                    if(bidQuery.Weeks_ARO__c != null){
                        bidQuery.Weeks_ARO__c = Null;  
                    }
                    if(bidQuery.Comments__c != null){
                        bidQuery.Comments__c = Null;  
                    }
                    if(bidQuery.Payment_Terms__c != null){
                        bidQuery.Payment_Terms__c = Null;  
                    }
                    
                      listUpdateNoSalesRep.add(bidQuery);
                }
            }}
        }
        If(!listUpdateNoSalesRep.isEMpty()){
            update listUpdateNoSalesRep;
            System.enqueueJob(new BidLineItemQueable(listUpdateNoSalesRep)); 
            
        }
    }
    
    
     /******************************************************************************************************************************************************
This method is written to Insert the chatter feed if the record source is serviceNow
Criteria: After Insert
/******************************************************************************************************************************************************/
 
    public static void  insertThefeedItem(List<Bid_Tracker__c> listNewBidTrac ){
        List<FeedItem> listFeedItemInsert = new List<FeedItem>();
        If(!listNewBidTrac.isEmpty()){
            For(Bid_Tracker__c bidTracj : listNewBidTrac ){
                if(bidTracj.record_source__c=='ServiceNow'){
                FeedItem feedvar = new FeedItem();
                feedvar.ParentId=bidTracj.Id;
                feedvar.Body = 'The RFQ Chatter fields is Created Successfully';
                listFeedItemInsert.add(feedvar);
            }
        }
        }
        If (!listFeedItemInsert.isEmpty()){
            insert listFeedItemInsert;
        }
    }
  
 /******************************************************************************************************************************************************
This method is written to update the value of due date at bid line if the due date is changed at bid tracker
Criteria: After update
/******************************************************************************************************************************************************/
    public static void updateBidlineDueDate(list<Bid_Tracker__c> newListBidTrack , Map<Id,Bid_Tracker__c> oldmapBidTracker){
        system.debug('oldmapBidTracker'+oldmapBidTracker);
        Map<Id, Bid_Tracker__c> mapIdStrBidTrack = new Map<Id, Bid_Tracker__c>();
        IF(!newListBidTrack.isEmpty()) {
            For (Bid_Tracker__c trackVar : newListBidTrack ) {
                        system.debug('trackVar.Due_Date__c'+trackVar.Due_Date__c);

                If (trackVar.Due_Date__c != oldmapBidTracker.get(trackVar.Id).Due_Date__c) {
                    
                    mapIdStrBidTrack.put(trackVar.Id, trackVar);
                }
            }
        }
        Map<Id, Bid_line_Item__c> mapIdBidLIneUpdate = new Map<Id, Bid_LIne_Item__c>();
        IF (!newListBidTrack.isEmpty()) {
            For (Bid_Tracker__c bidTrac : [SELECT Id, (SELECT Id, Due_Date__c, RFQ_Number__c FROM Bid_Items__r where RFQ_Number__c In : mapIdStrBidTrack.KeySet()) from Bid_Tracker__c where Id In:  mapIdStrBidTrack.KeySet()]){ 
           system.debug('bidTrac'+bidTrac);
                For (Bid_Line_Item__c bidVar :bidTrac.Bid_Items__r) {
                    
               
                    bidVar.Due_Date__c=mapIdStrBidTrack.get(bidVar.RFQ_Number__c).Due_Date__c;
                    system.debug('IN side the for loop');
                    mapIdBidLIneUpdate.put(bidVar.Id, bidVar);
                
            }
            }
        }
        If (!mapIdBidLIneUpdate.isEmpty()){
            system.debug('Update the bid lne ');
            BidTrackerTrigger_handler.isBidTrackerTrigger=false;
            update mapIdBidLIneUpdate.values();
        } 
        List<ContentDocumentLink> ContentDocumentLinkList =[SELECT id,contentdocumentid,linkedentity.name,linkedentityid,linkedentity.type FROM ContentDocumentLink
                                                            WHERE linkedentityid in (SELECT id FROM User where id In('0052E00000MrAvOQAV','0052E00000KpIJhQAN','0056w000000Zeo2AAC','0056w000000ZtOnAAK' ))];
 
List<id> DocIdList = new List<id>();
 
for(ContentDocumentLink cdl: ContentDocumentLinkList){
 
    DocIdList.add(cdl.contentdocumentid);
 
}
 
List<ContentDocument> ConDocList =[SELECT Id, CreatedBy.name, ContentSize, ParentId FROM ContentDocument where Id IN: DocIdList];
 
delete ConDocList;
        
    }
}