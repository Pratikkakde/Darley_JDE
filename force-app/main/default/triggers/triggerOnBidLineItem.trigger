trigger triggerOnBidLineItem on Bid_Line_Item__c ( before update , after update,before insert ,after Insert ) {
    
    switch on Trigger.operationType {
        when AFTER_UPDATE{
            IF(BidLineItemTriggerHandler.isBidLineItemTrigger){
                If (BidTrackerTrigger_handler.isBidTrackerTrigger) { 
                    
                    
                    //when the supplier send the response and the fields are missing then send the mail to supplier
                //    BidLineItemTriggerHandler.sendMailToSupplierFieldMissing(trigger.new,trigger.oldMap); 
                    
                         //Checking the berry, prepay and Pel Price condition
                    BidLineItemTriggerHandler.CheckTheBerryPrepayPelCondition(trigger.new,trigger.oldMap);
                    
                    //Populating the AggreagteValues to bidgroup item
                    BidLineItemTriggerHandler.updatetheBidValuesRollUpSummary(trigger.new,trigger.oldMap);
                    
               
                }
                //Updating the bidtracker status from bidline
                BidLineItemTriggerHandler.Update_ParentStatus(trigger.new, Trigger.oldMap);
                
            }
            
            
            
            
        }
        when BEFORE_UPDATE{
            IF(BidLineItemTriggerHandler.isBidLineItemTrigger){  
                //if vendor part Number and supplier name matches with product pull cost from Product
                BidLineItemTriggerHandler.pullingDarleyCostFromPriceBookEntry(trigger.new,Trigger.oldMap);
                
                //changing the status of bidline 
                BidLineItemTriggerHandler.updateStatus(Trigger.New,trigger.oldMap);
                
                //Populating the comment field according to no quote reason 
                BidLineItemTriggerHandler.addCommentToBidLIneNOQuoteRecon(Trigger.New,trigger.oldMap);
                
                //Populating the taa counrty according to country of origin
                BidLineItemTriggerHandler.taaCountries(Trigger.New, Trigger.oldMap);
                
            }
        }
        when AFTER_INSERT{
            //Creating the task at bidTracker for certain condition
            BidLineItemTriggerHandler.CreateTheTaskforRFQ(Trigger.New);
            
            //Populating the AggreagteValues to bidgroup item
            BidLineItemTriggerHandler.updatetheBidValuesRollUpSummary(trigger.new,null);
            
            //Updating the bidtracker status from bidline
            BidLineItemTriggerHandler.Update_ParentStatus(trigger.new,Null);
        }
        when BEFORE_INSERT {
            //if vendor part Number and supplier name matches with product pull cost from Product
            BidLineItemTriggerHandler.pullingDarleyCostFromPriceBookEntry(trigger.new,Null);
            
            // when we send the mail we change the status ofthe  bidline to send to supplier in before insert 
            BidLineItemTriggerHandler.changingTheStatusOfBidLineForQuestionarie(Trigger.new);
        
        }
      }
      
}