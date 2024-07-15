trigger TriggerOnDoDaac on DoDAAC__c (after insert,after update) {
    if(Trigger.isInsert && Trigger.isAfter){
        DoDaacTrigger_Handler.DodaacUpdate_Method(Trigger.New);
    }
if(trigger.isAfter && trigger.isUpdate){
    DoDaacTrigger_Handler.handleDoDaacUpdates(Trigger.new);
}
}