trigger TriggerOnBidWorkbench on Bid_Workbench__c (before insert , after insert, after update ) {
 
  
      
    switch on Trigger.operationType {
        when AFTER_UPDATE{
            If (workbenchTrigger_handler.isBidWorkBenchTrigger) {
               workbenchTrigger_handler.updatetheBidLineFields(Trigger.new, Trigger.OldMap); 

            }
        }
        when BEFORE_INSERT{
          // workbenchTrigger_handler.handleBeforeInsert(Trigger.new);
             workbenchTrigger_handler.ReAssignData(Trigger.new);
        }
        when AFTER_INSERT{
          //  workbenchTrigger_handler.LineItemCount(Trigger.new); 
        }
        
    }
}