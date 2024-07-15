trigger triggerOnPriceEvaluationList on Price_Evaluation_List__c (before insert , before update) {
    if(Trigger.isBefore){
        if(Trigger.isInsert || Trigger.isUpdate){
            
           PriceEvaluationListTrigger_handler.executeFesCalculations(Trigger.new);
           PriceEvaluationListTrigger_handler.executeSoeCalculations(Trigger.new);
           PriceEvaluationListTrigger_handler.PelIdInsert(Trigger.New);
            PriceEvaluationListTrigger_handler.lookups(Trigger.New);
        }
    }
    
}