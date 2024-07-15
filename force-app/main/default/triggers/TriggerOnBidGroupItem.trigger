trigger TriggerOnBidGroupItem on Bid_Group_Items__c ( before Insert , before Update, after update) {
    if(Trigger.isAfter && trigger.isInsert) {
       //BidGroupItemTriggerHandler.Update_BidGroupItem(Trigger.New);
    }
  
    switch on Trigger.operationType {
        when BEFORE_UPDATE{
            If (BidLineItemTriggerHandler.isBidLineItemTrigger  || Test.isRunningTest()) {
                   // when the bidGroupItem is inserted we are linking the bidGroupItem to the pricing matrix base on the total cost of the bidGroup
            BidGroupItemTriggerHandler.linkthePricMatTOTheBidgroup(Trigger.New,Trigger.OldMap);

            }
         
        }
        when BEFORE_INSERT {
            
            // when the bidGroupItem is updated we are linking the bidGroupItem to the pricing matrix base on the total cost of the bidGroup
           BidGroupItemTriggerHandler.linkthePricMatTOTheBidgroup(Trigger.New,Null);

        }
        when AFTER_UPDATE {
             If (BidLineItemTriggerHandler.isBidLineItemTrigger || Test.isRunningTest()) {
            //When the margin is applied to bidGroup we are updating the Margin of the bidLIne Item as well 
            //those bidLine is attach to that bidgroup we are updating the margin of all the bidLine Item
           BidGroupItemTriggerHandler.applyMarginBidLine(Trigger.New,Trigger.OldMap);
             }
        }
    }

}