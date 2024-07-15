@isTest
public class QueueableBidLineNoQuote_Test {

    @isTest
    public static void SchedulableTestMethod(){
        
        Account acc = new Account();
        acc=TestDataUtilClass.returnAccountRec();
        insert acc;
        
        Bid_Tracker__c BidTracker = new Bid_Tracker__c();
        BidTracker=TestDataUtilClass.getBidTracker();
        insert BidTracker;

        List<Bid_Line_Item__c> bidLineItem = new List<Bid_Line_Item__c>();
        
        Bid_Line_Item__c bidLineVar = new Bid_Line_Item__c();
        bidLineVar=TestDataUtilClass.getBidLineItem();
        bidLineVar.RFQ_Number__c=BidTracker.id;
        bidLineVar.Bid_Supplier__c=acc.Id;
        bidLineVar.Quote_Numbers__c='131234';
        bidLineVar.Status__c='Sent to Supplier';
        bidLineVar.Due_Date__c=Datetime.now().addHours(2);
        bidLineItem.add(bidLineVar);
        
        Bid_Line_Item__c bidLineVar1 = new Bid_Line_Item__c();
        bidLineVar1=TestDataUtilClass.getBidLineItem();
        bidLineVar1.RFQ_Number__c=BidTracker.id;
        bidLineVar1.Bid_Supplier__c=acc.Id;
        bidLineVar1.Quote_Numbers__c='13123443';
        bidLineVar1.Status__c='Supplier Responded';
        bidLineVar1.Due_Date__c=Datetime.now().addHours(2);
        bidLineItem.add(bidLineVar1);
        
        Bid_Line_Item__c bidLineVar2 = new Bid_Line_Item__c();
        bidLineVar2=TestDataUtilClass.getBidLineItem();
        bidLineVar2.RFQ_Number__c=BidTracker.id;
        bidLineVar2.Bid_Supplier__c=acc.Id;
        bidLineVar2.Quote_Numbers__c='13123485';
        bidLineVar2.Status__c='New';
        bidLineVar2.Due_Date__c=Datetime.now().addHours(2);
        bidLineItem.add(bidLineVar2);
        
        insert bidLineItem;
        
        QueueableBidLineNoQuote obj = new QueueableBidLineNoQuote();
        Test.startTest();
        obj.execute(null);
        Test.stopTest();
    }
    
}