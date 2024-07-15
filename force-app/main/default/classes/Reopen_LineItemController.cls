public class Reopen_LineItemController {
    @InvocableMethod(label='Reopen_LineItem')
    public Static void UnLockBidlineItem(List<Id> bidGroupId){
        Bid_tracker__c bidTra =[SELECT Id, Quote_Request_Status__c , (select id, Status__c,Payment_Terms__c,Comments__c,Weeks_ARO__c,Country_of_Origin__c,RFQ_Number__c,
                                                                     Margin_Percent__c,Unit_Cost__c,RFQ_Number__r.Sales_Rep_Driven__c ,Sales_Rep__c from Bid_Items__r
                                                                     where Bid_Group_Items__c In :bidGroupId ),
                                (SELECT Id, Approval_Status__c , IsRunning__c from Bid_Group_Items__r WHERE Id IN:bidGroupId) 
                                from  Bid_tracker__c
                                where Id IN (SELECT RFQ_Number__c FROM Bid_Group_Items__c where Id IN: bidGroupId )];
        Map<Id, Bid_LIne_Item__c> mapIdBidLine = new Map<Id, Bid_LIne_Item__c>();
        For (Bid_LIne_Item__c bidLine : bidTra.Bid_Items__r){
            bidLine.Status__c = 'Supplier Responded';
            bidLine.Payment_Terms__c='';
            mapIdBidLine.put(bidLine.Id, bidLine);
        }
        update mapIdBidLine.values();
        Map<Id, Bid_Group_Items__c> mapIdBidGrp = new Map<Id, Bid_Group_Items__c>();
        For (Bid_Group_Items__c bidgrp : bidTra.Bid_Group_Items__r) {
            bidgrp.Approval_Status__c='';
            bidgrp.IsRunning__c = false;
            
            mapIdBidGrp.put(bidgrp.Id, bidgrp);
        }
        update mapIdBidGrp.values();
        bidTra.Quote_Request_Status__c ='Supplier_Response';
        update bidTra;
        
    }
    
    

}