trigger Tier_Trigger on Tier__c (before insert,before Update , after Update  ) {

    If(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
            Tier_Trigger_Handler.nameAutoNumberAutomation(Trigger.new);
    }
  
    If(Trigger.isAfter &&  Trigger.isUpdate){
        Tier_Trigger_Handler.orderpositionchange(Trigger.New,Trigger.OldMap);
    }
}