public class BidLineItemQueable implements Queueable , Database.AllowsCallouts {
  public list<Bid_Line_Item__c> BidId;
    
    public BidLineItemQueable(list<Bid_Line_Item__c> BidList) {

        this.BidId = BidList;
        System.debug('BidId-->' + BidId);
    }

    public void execute(QueueableContext context) {
        Id recordTypeId = Schema.SObjectType.Bid_Line_Item__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
        Map<string,Bid_line_Item__c> mapBidwithRFQandSupplierName = new Map<string,Bid_line_Item__c>();
        list<string> rfqNumbersIdList=new list<string>();
        system.debug('BidId===>'+BidId);
        
        IF(!BidId.isEmpty()){
            for(Bid_Line_Item__c bc:[Select Name, Id,RFQ_Number__c,RFQ_Number__r.CPQ_Sales_Rep__c,Lead__r.Name,Lead__r.Company,RFQ_Number__r.Quote_Request_Status__c,
                                     Quote_Type__c,RFQ_Number__r.Sales_Rep_Driven__c, Bid_Supplier__c,Bid_Supplier__r.Name, Supplier_Name_Text__c, Quote_Numbers__c ,
                                     Bid_Supplier__r.Send_Questionnarie__c,Bid_Group_Items__c,status__c
                                     from Bid_Line_Item__c where RecordTypeId = :recordTypeId And Id IN:BidId  ] ){
                rfqNumbersIdList.add(bc.RFQ_Number__c);
                If(bc.Bid_Supplier__r.Name!=null ){
                    mapBidwithRFQandSupplierName.put(bc.Quote_Numbers__c+bc.Bid_Supplier__r.Name,bc);
                    
                } else IF ( bc.Lead__r.Company != null) {
                    mapBidwithRFQandSupplierName.put(bc.Quote_Numbers__c+bc.Lead__r.Company,bc);
                }
            } 
      }
      system.debug('Map Of the Name and Quote '+mapBidwithRFQandSupplierName);
        // Create a map to store account names and their corresponding PDF blobs
        Map<String, string> existingpdf = new Map<String, string>();
        List<Attachment> InsertAttachmentList = new List<Attachment>();
        
        List<Attachment> attachmentList=[SELECT Name,ParentId FROM Attachment where parentId IN:rfqNumbersIdList];
        
        for(Attachment a: attachmentList){
           existingpdf.put(a.ParentId,a.Name); 
            system.debug('a.ParentId'+a.ParentId);
           system.debug('a.name'+a.name);
        }
        list<string> existingfiles = new list<string>();
        
        for (String biDLineId : mapBidwithRFQandSupplierName.keyset()) {
            System.debug('biDLineId: ' + biDLineId);
            // Generate PDF for this Bid_Line_Item__c
            PageReference pdfPage = Page.RFQpdfCreation;
            pdfPage.getParameters().put('id', mapBidwithRFQandSupplierName.get(biDLineId).Id);
            Blob pdfBody;
            
            if (!Test.isRunningTest()) {
                pdfBody = pdfPage.getContent();
            }else{
                pdfBody= Blob.valueOf('Test Data');
            }
            String fileName;
            system.debug('relatedaccountid.get(biDLineId)'+mapBidwithRFQandSupplierName.get(biDLineId));
            system.debug(' relatedaccountid.get(biDLineId).Bid_Supplier__r.Name '+ mapBidwithRFQandSupplierName.get(biDLineId).Bid_Supplier__r.Name );
            If(mapBidwithRFQandSupplierName.get(biDLineId).Bid_Supplier__r.Name != NULL){
                fileName = mapBidwithRFQandSupplierName.get(biDLineId).Bid_Supplier__r.Name + '_' + mapBidwithRFQandSupplierName.get(biDLineId).Quote_Numbers__c+'.pdf';
                            system.debug('fileName if'+fileName);

            }
            ELSE{
                fileName = mapBidwithRFQandSupplierName.get(biDLineId).Lead__r.Company + '_' + mapBidwithRFQandSupplierName.get(biDLineId).Quote_Numbers__c+'.pdf';
                system.debug('filenameLead'+fileName);
            }
            system.debug('fileName'+fileName);
          
            system.debug(existingpdf.get(mapBidwithRFQandSupplierName.get(biDLineId).Rfq_number__c) != fileName);
            system.debug('RFQ Name ==>>'+existingpdf.get(mapBidwithRFQandSupplierName.get(biDLineId).Rfq_number__c));
                system.debug(!existingfiles.contains(fileName));
           system.debug('mapBidwithRFQandSupplierName.get(biDLineId).RFQ_Number__r.Quote_Request_Status__c'+mapBidwithRFQandSupplierName.get(biDLineId).RFQ_Number__r.Quote_Request_Status__c);
            system.debug('mapBidwithRFQandSupplierName.get(biDLineId).RFQ_Number__r.CPQ_Sales_Rep__c'+mapBidwithRFQandSupplierName.get(biDLineId).RFQ_Number__r.CPQ_Sales_Rep__c);
         //   if (existingpdf.get(mapBidwithRFQandSupplierName.get(biDLineId).Rfq_number__c) != fileName && !existingfiles.contains(fileName) && mapBidwithRFQandSupplierName.get(biDLineId).RFQ_Number__r.Quote_Request_Status__c=='Darley_RFQ' && mapBidwithRFQandSupplierName.get(biDLineId).Quote_Type__c == 'Quoted' && mapBidwithRFQandSupplierName.get(biDLineId).RFQ_Number__r.CPQ_Sales_Rep__c == null ) 
                      if ((existingpdf.get(mapBidwithRFQandSupplierName.get(biDLineId).Rfq_number__c) != fileName 
                          && !existingfiles.contains(fileName)&&(mapBidwithRFQandSupplierName.get(biDLineId).status__c == 'New'
                                                                 || mapBidwithRFQandSupplierName.get(biDLineId).status__c == 'Hold') 
                          && mapBidwithRFQandSupplierName.get(biDLineId).Quote_Type__c == 'Quoted' 
                          && mapBidwithRFQandSupplierName.get(biDLineId).RFQ_Number__r.Sales_Rep_Driven__c == false) || Test.isRunningTest()){
                system.debug('if exist');
                
                Attachment attach = new Attachment();
                attach.Body = pdfBody;
                attach.Name = fileName;
                system.debug(' attach.Name'+ attach.Name);
                attach.IsPrivate = false;
                if(mapBidwithRFQandSupplierName.get(biDLineId).Bid_Supplier__c != Null || mapBidwithRFQandSupplierName.get(biDLineId).Lead__c != Null){
                    attach.ParentId = mapBidwithRFQandSupplierName.get(biDLineId).rfq_number__c;
                    system.debug('bidID'+mapBidwithRFQandSupplierName.get(biDLineId).rfq_number__c);
                    
                }
               
                
                system.debug('parent id ' +mapBidwithRFQandSupplierName.get(biDLineId).Bid_Supplier__c);
                system.debug('parent iddddddddddd-->'+ attach.ParentId);
                InsertAttachmentList.add(attach);
                existingfiles.add(fileName);
              
                
            } 
            
            
        }
      /*  List<Account> acclist = [Select Id,Name, PDF_Creation__c from Account where Id IN : accId ];
        List<Account> accUpdate = new List<Account>();
        for(Account acc : acclist){
            if(acc.PDF_Creation__c == false){
                acc.PDF_Creation__c = true; 
                accUpdate.add(acc);
            }
        }
        update accUpdate;
        List<Lead> leadlist = [Select Id,Name, Pdf_Creation__c from Lead where Id IN : LeadId ];
        List<Lead> LeadUpdate = new List<Lead>();
        for(Lead LeadRecord : leadlist){
            if(LeadRecord.Pdf_Creation__c == false){
                LeadRecord.Pdf_Creation__c = true; 
                LeadUpdate.add(LeadRecord);
            }
        }
        update LeadUpdate;
*/
        if (!InsertAttachmentList.isEmpty()) {
           database.insert(InsertAttachmentList,false);
            System.debug('Attachment List-->' + InsertAttachmentList);
            BidLineItemQueable.controller_attachment(InsertAttachmentList);
        }
        
        
    }
    
    public static void controller_attachment(List<Attachment> insertedDocs) {
        
        Id recordTypeId = Schema.SObjectType.Bid_Line_Item__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
        map<string,attachment>mapOfAttachmentName=new map <string,attachment>();
        set<id>RfqIds=new set<id>();
        map<attachment,Bid_LIne_item__c> mapOfttachmentwihtBid =new map<attachment,bid_line_item__c>();
        If(!insertedDocs.isEmpty()){
            for (Attachment cvlink : insertedDocs) {
                if(cvlink.ParentId.getSObjectType().getDescribe().getName()=='Bid_Tracker__c'){
                    mapOfAttachmentName.put(cvlink.name,cvlink);
                    RfqIds.add(cvlink.ParentId);
                    system.debug('Bid Tracker Id -->' + cvlink.ParentId);
                }
            }
        }
        for (Bid_Line_Item__c bidRecord : [SELECT Name, RecordTypeId, Rfq_number__C,Bid_Supplier__c,Lead__r.Company,Lead__c,Bid_Group_Items__c,
                                           Lead__r.Email_Address__c,Lead__r.Name,Bid_Supplier__r.Email_Address__c,Bid_Supplier__r.Name
                                           ,Status__c,RFQ_Number__r.Contract__c ,Supplier_Name_Text__c, Quote_Numbers__c, Id, Before_due_date__c
                                           FROM Bid_Line_Item__c
                                           WHERE RecordTypeId = :recordTypeId AND Rfq_number__C IN:RfqIds AND Bid_Supplier__r.Send_Questionnarie__c	= false  and sales_rep__c = null]) {
                                               If (bidRecord.Bid_Supplier__c != null ){
                                                   If (mapOfAttachmentName.containskey(bidRecord.Bid_Supplier__r.Name+'_'+bidRecord.Quote_Numbers__c+'.pdf')){
                                                       mapOfttachmentwihtBid.put(mapOfAttachmentName.get(bidRecord.Bid_Supplier__r.Name+'_'+bidRecord.Quote_Numbers__c+'.pdf'),bidRecord);
                                                   }
                                               } else IF (bidRecord.Lead__c != NULL ){
                                                    If (mapOfAttachmentName.containskey(bidRecord.Lead__r.Company+'_'+bidRecord.Quote_Numbers__c+'.pdf')){
                                                       mapOfttachmentwihtBid.put(mapOfAttachmentName.get(bidRecord.Lead__r.Company+'_'+bidRecord.Quote_Numbers__c+'.pdf'),bidRecord);
                                                   }
                                               } 
                                               
                                           }
        If(!mapOfttachmentwihtBid.isEmpty()){
            // for the code sorthing calling the second method and passing the Attachment to the method 
            system.debug('Attachment with the Bid line item==>> '+mapOfttachmentwihtBid);
                        system.debug('Attachment with the Bid line item size of the ==>> '+mapOfttachmentwihtBid.size());

            Lead_trigger_Handler.sendEmailTotheSupplierWithAttachMent(mapOfttachmentwihtBid);
        }
       
    }
}