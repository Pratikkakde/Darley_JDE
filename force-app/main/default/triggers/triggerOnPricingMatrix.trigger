trigger triggerOnPricingMatrix on Pricing_Matrix__c (after insert, after update ,before update, before insert) {
    if(Trigger.isafter && Trigger.isInsert){
        Pricing_Matrix_TriggerHandler.updateFieldsCost_High_End(trigger.new);
    }
    if( Trigger.isUpdate && Trigger.isAfter   ){
Pricing_Matrix_TriggerHandler.updateFieldsCost_High_EndOnUpdateRecord(trigger.new,Trigger.oldmap);
    }
    If((Trigger.isInsert || Trigger.isUpdate )&& Trigger.isBefore){
        Pricing_Matrix_TriggerHandler.updateOrderChange(trigger.new);
    }
    
    
    If(Trigger.isInsert && Trigger.isBefore){
//        Pricing_Matrix_TriggerHandler.addErrorForactiveContractValidation(Trigger.new);
          Pricing_Matrix_TriggerHandler.changeName(trigger.new);
    }
      If(Trigger.isUpdate && Trigger.isBefore){
          // this method is call when the single active pricing is changes to inactive 
        Pricing_Matrix_TriggerHandler.addErrorForTostopFromActivaion(Trigger.new);
    }
        
}