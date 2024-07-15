trigger triggerOnBidTracker on Bid_Tracker__c (before insert,before update, after insert,after update) {
    switch on Trigger.operationType {
       
        when AFTER_INSERT{
            BidTrackerTrigger_handler.InsertAttachment(trigger.new);
            
            //This method is Call when the rfq is Insterted we inserting the feedItme related to the RFQ
           BidTrackerTrigger_handler.insertThefeedItem(Trigger.New);
        }
      
        when AFTER_UPDATE {
            If (BidLineItemTriggerHandler.isBidLineItemTrigger ) {
                BidTrackerTrigger_handler.NoSalesRepDriven(Trigger.New, Trigger.OldMap);
                
                //Update the bidLIne item due date when the due date is change at parent bidtracker
                BidTrackerTrigger_handler.updateBidlineDueDate(Trigger.New, Trigger.OldMap);
            }
            
        }
    }
    
 
    
 

   

}