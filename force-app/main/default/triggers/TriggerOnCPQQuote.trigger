trigger TriggerOnCPQQuote on SBQQ__Quote__c (before insert) {
    
     if(trigger.isbefore && trigger.isinsert){
         CPQ_Quote_Handler.method1(trigger.new);
     }
   
    }