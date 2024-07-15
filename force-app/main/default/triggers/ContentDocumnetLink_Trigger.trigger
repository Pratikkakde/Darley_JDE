trigger ContentDocumnetLink_Trigger on ContentDocumentLink (after insert) {
    
    
    switch on Trigger.operationType {
        
        when AFTER_INSERT{
            ConTentDocumentLink_TriggerHandler.sendDocumentTosuppLier(Trigger.New);
            
            
           // ConTentDocumentLink_TriggerHandler.test(Trigger.New);        
            ConTentDocumentLink_TriggerHandler.attachDocgtoBidLineAndBidTrack(Trigger.New); 
        }
    }


}