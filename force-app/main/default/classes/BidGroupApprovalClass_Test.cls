@isTest
public class BidGroupApprovalClass_Test {
    
    @isTest
    public static void testCallApproval(){
        // Create test data
        Bid_Tracker__c bidTracker = TestDataUtilClass.getBidTracker();
        insert bidTracker;
        
        Bid_Group_Items__c bidGrpItem = TestDataUtilClass.getBidGroupItem();
        bidGrpItem.RFQ_Number__c = bidTracker.Id;
        insert bidGrpItem;
        
        User userVar = TestDataUtilClass.getUser();
        insert userVar; 
        
        // Create OppAndAccountDetailsRequest instance
        BidGroupApprovalClass.BidGroupDetail var = new BidGroupApprovalClass.BidGroupDetail();
        var.SobeIdBidgrp = bidGrpItem.Id;
        var.userId = userVar.Id;
        var.CommentApproal = 'Test class';  
        
        // Add the instance to a list 
        List<BidGroupApprovalClass.BidGroupDetail> varList = new List<BidGroupApprovalClass.BidGroupDetail>();
        varList.add(var);
        
        Test.startTest();
        // Call the method with the list
        BidGroupApprovalClass.callApproval(varList); 
        Test.stopTest();
        
        
    }
}