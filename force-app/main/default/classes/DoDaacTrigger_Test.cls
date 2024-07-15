@isTest
public class DoDaacTrigger_Test {
    @isTest
    public static void DodaacUpdate_Method(){
  
      Account acc = new Account();
        acc=TestDataUtilClass.returnAccountRec();
        insert acc;
        
        Bid_Tracker__c BidTracker = new Bid_Tracker__c();
        BidTracker=TestDataUtilClass.getBidTracker();
        insert BidTracker;
        
        Bid_Line_Item__c bidLineVar = new Bid_Line_Item__c();
        bidLineVar=TestDataUtilClass.getBidLineItem();
        bidLineVar.RFQ_Number__c=BidTracker.id;
        bidLineVar.Bid_Supplier__c=acc.Id;
        bidLineVar.Quote_Numbers__c='131234';
        bidLineVar.DoDAAC_Number_Text__c='W51E9T';
        bidLineVar.ServiceNow_State__c=null;
        bidLineVar.Country__c=null;
        bidLineVar.ZIP_Postal_Code__c=null;
        bidLineVar.Due_Date__c = system.today().addDays(3);
            
        insert bidLineVar;
        DoDAAC__c doDacVar = new DoDAAC__c();
        doDacVar.Name = 'W51E9T';
        
        insert doDacVar;
        bidLineVar.Ship_To_DoDAAC__c= doDacVar.Id;
        update bidLineVar;
         update doDacVar;
    }

}