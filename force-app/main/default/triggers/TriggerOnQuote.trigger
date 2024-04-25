trigger TriggerOnQuote on Quote (after insert, after delete, after update) {
  
    if(trigger.isbefore && trigger.isinsert){
       Quote_Handler.requirecontactrole(trigger.new); 
  }  
    
     if(trigger.isupdate && trigger.isafter){
       Quote_Handler.quoteamountupdate(trigger.new,trigger.oldmap);
    }
     if(trigger.isupdate && trigger.isafter){
       Quote_Handler.quoteDarleyCostupdate(trigger.new,trigger.oldmap);
    }
}