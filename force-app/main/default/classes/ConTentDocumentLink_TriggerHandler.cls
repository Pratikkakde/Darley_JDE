/******************************************************************************************************************************************************
Name                    : ConTentDocumentLink_TriggerHandler
Author                  : Melonleaf
Purpose                 : This method is fired  by the Attachment(ConTentDocument) is attach to bid group Item 
Description             : this is fired on after event we send the mail to supplier when we attach the document to the bid group  
Version                 : 1.0
Change Log              : 
Test Class              : ConTentDocumentLink_TriggerHandler_Test
CreateDate              : 25-05-2024
LastModifiedDate        : 25-05-2024
******************************************************************************************************************************************************/
public class ConTentDocumentLink_TriggerHandler {
    
    /******************************************************************************************************************************************************
     * When the user attach the pdf of rfq to bid group this method call and mail is send to supplier with the attahment 
******************************************************************************************************************************************************/

    public static void sendDocumentTosuppLier (List<ContentDocumentLink> listNewContDocuLink ) {
        system.debug('listNewContDocuLink'+listNewContDocuLink);
        
        Map<Id,Id> setIdBidgroup = new map<Id,Id>();
        
        If(!listNewContDocuLink.isempty()){
            For (ContentDocumentLink contDocLik : listNewContDocuLink ){
                If (contDocLik.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Bid_Group_Items__c') {
                    setIdBidgroup.Put(contDocLik.ContentDocumentId,contDocLik.LinkedEntityId);
                }
            }
        }
       Map<Id,Bid_Line_Item__c> mapBidLIneWhithBidGr = new Map<Id,Bid_Line_Item__c>();
       Map<String,Bid_Line_Item__c> mapIdStrBidTraRFQname = new  Map<String,Bid_Line_Item__c>();
        For (Bid_Line_Item__c bidvar : [SELECT Name, RecordTypeId, Rfq_number__C,Bid_Supplier__c,Lead__r.Company,Lead__c,
                                        Lead__r.Email_Address__c,Lead__r.Name,Bid_Supplier__r.Email_Address__c,Bid_Supplier__r.Name,Bid_Group_Items__c,
                                        Status__c,RFQ_Number__r.Contract__c ,Supplier_Name_Text__c, Quote_Numbers__c, Id, Before_due_date__c
                                        FROM Bid_Line_Item__c WHERE Bid_Group_Items__c In : setIdBidgroup.values() ]){
                                            mapBidLIneWhithBidGr.put(bidvar.Bid_Group_Items__c,bidvar);
                                            mapIdStrBidTraRFQname.put(bidvar.Bid_Supplier__r.Name+'_'+bidvar.Quote_Numbers__c+'.pdf',bidvar);
                                        }
            Map<Attachment,Bid_Line_Item__c> mapAttwhtiBid =  new Map<Attachment,Bid_Line_Item__c>();

        For (ContentVersion contVar : [SELECT Id, ContentDocumentId, VersionData , PathOnClient, Title FROM ContentVersion where ContentDocumentId IN: setIdBidgroup.keySet() ] ) {
            If (contVar.Title.ContainsIgnoreCase('Questionnaire') ) {
                Attachment attvar = new Attachment();
                attvar.parentID = mapBidLIneWhithBidGr.get(setIdBidgroup.get(contVar.ContentDocumentId)).Rfq_number__C;
                attvar.Name =contVar.PathOnClient;
                attvar.Body =contVar.VersionData;
                mapAttwhtiBid.put(attvar,mapBidLIneWhithBidGr.get(setIdBidgroup.get(contVar.ContentDocumentId)));
            }
            
        }
        If (!mapAttwhtiBid.isEmpty()){
            For (Attachment attVar : [SELECT Id, parentID, Name, Body, ContentType FROM Attachment WHERE 
                                      Name LIKE : mapIdStrBidTraRFQname.keySet()]){
                                          mapAttwhtiBid.put(attVar,mapIdStrBidTraRFQname.get(attVar.Name));
                                          system.debug(mapAttwhtiBid);
                                      }
        }
  
        If (!mapAttwhtiBid.isEmpty()){
            system.debug(mapAttwhtiBid);
            Lead_trigger_Handler.sendEmailTotheSupplierWithAttachMent(mapAttwhtiBid);
        }
    }
        /******************************************************************************************************************************************************

    this method is fired when we insert the document by the service now Api "createOrderLineItemInSalesforce" we inserting the doc to the bid line and bid tracker as per t
    ******************************************************************************************************************************************************/
    public static void attachDocgtoBidLineAndBidTrack (List<ContentDocumentLink> listNewContDocuLink){
        Map<Id,Id> setIdBidgroup = new map<Id,Id>();
        
        For (ContentDocumentLink contDocLik : listNewContDocuLink ){
            
            If (contDocLik.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Bid_Workbench__c') {
                setIdBidgroup.Put(contDocLik.ContentDocumentId,contDocLik.LinkedEntityId);
            } else if (contDocLik.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Workbench_Parent__c') {
                setIdBidgroup.Put(contDocLik.ContentDocumentId,contDocLik.LinkedEntityId);
                
            }
        }
        MAP<Id,String> mapOrderLIneID = new  MAP<Id,String>();
        SeT<String> setStrRfqNum = new Set<String>();
        For (Bid_Workbench__c varBid :  [SELECT Id, Processed__c, Order_Item_ID__c, Quote_Number__c FROM Bid_Workbench__c  WHERE  Processed__c = True AND Id In : setIdBidgroup.Values() and Record_Source__c = 'Service Now' ]) {
            mapOrderLIneID.put(varBid.Id,varBid.Order_Item_ID__c);
            setStrRfqNum.add(varBid.Quote_Number__c);
        }
        For (Workbench_Parent__c bidWorkpar : [SELECT Id, Name FROM Workbench_Parent__c  WHERE   Id In : setStrRfqNum]){
            mapOrderLIneID.put(bidWorkpar.Id,bidWorkpar.Name);
        }
        Map<String,Id> mapStrIDBidLIne = new  Map<String,Id>();
        For ( Bid_Line_Item__c varBid : [SELECT ID, Line_Item_ID__c from Bid_line_Item__c where Line_Item_ID__c In : mapOrderLIneID.values() ]){
            mapStrIDBidLIne.put(varBid.Line_Item_ID__c,varBid.Id);
        }
        For (Bid_tracker__c varBidtrac : [SELECT id,name from Bid_tracker__c where name In : mapOrderLIneID.values()  ]) {
            mapStrIDBidLIne.put(varBidtrac.Name,varBidtrac.Id);
            
        }
        List<ContentDocumentLink> listContDocuInsert = new List<ContentDocumentLink>();
        For (ContentDocumentLink contDocLik : listNewContDocuLink ){
            If  (mapStrIDBidLIne.containsKey(mapOrderLIneID.get(contDocLik.LinkedEntityId))) {
                ContentDocumentLink varIns = new ContentDocumentLink();
                
                varIns.LinkedEntityId = mapStrIDBidLIne.get(mapOrderLIneID.get(contDocLik.LinkedEntityId));
                varIns.ContentDocumentId = contDocLik.ContentDocumentId;
                listContDocuInsert.add(varIns);
            }
            
        }
        If (!listContDocuInsert.isEmpty()) {
            insert listContDocuInsert;
        }
        
        
        
    }
    
    
    
    
}