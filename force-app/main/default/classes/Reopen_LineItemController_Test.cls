@IsTest
public class Reopen_LineItemController_Test {
    @IsTest
    public static void UnLockBidlineItem(){
         
        Account acc = new Account();
        acc=TestDataUtilClass.returnAccountRec();
        insert acc;
        
        Bid_Tracker__c BidTracker = new Bid_Tracker__c();
        BidTracker=TestDataUtilClass.getBidTracker();
        insert BidTracker;
        
        Bid_Group_Items__c BidGrpItem = new Bid_Group_Items__c();
        BidGrpItem=TestDataUtilClass.getBidGroupItem();
        BidGrpItem.RFQ_Number__c=BidTracker.Id;
        insert BidGrpItem;

        Bid_Line_Item__c bidLineVar = new Bid_Line_Item__c();
        bidLineVar=TestDataUtilClass.getBidLineItem();
        bidLineVar.RFQ_Number__c=BidTracker.id;
        bidLineVar.Bid_Supplier__c=acc.Id;
        bidLineVar.Quote_Numbers__c='131234';
        bidLineVar.Status__c='Sent to Supplier';
        bidLineVar.Bid_Group_Items__c=BidGrpItem.Id;
        bidLineVar.Unit_Cost__c=100;
        bidLineVar.Quantity__c=1000;
        insert bidLineVar;
        Bid_line_item__c oldBidLineItem = bidLineVar.clone();
        Test.startTest();
        Reopen_LineItemController.UnLockBidlineItem(new List<Id>{BidGrpItem.Id});
        Test.stopTest();
        
        
    }

}