trigger B2BAccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    B2BTriggerDispatcher.Run(new B2BAccountTriggerHandler(), Trigger.operationType); 
    
    //AccountTriggerHandler is used to send Account to JDE
    switch on Trigger.OperationType  {
        when BEFORE_INSERT{
            //AccountTriggerHandler.coppyAddress(Trigger.new);
            AccountTriggerHandler.changeRecordType(Trigger.new);
            AccountTriggerHandler.updateJdeAddNum(trigger.new, new Map<Id, Account>());
        }
        when BEFORE_UPDATE{
            // AccountTriggerHandler.coppyAddress(Trigger.new);
            AccountTriggerHandler.updateJdeAddNum(trigger.new ,trigger.oldMap);
        }
        when AFTER_INSERT{
            AccountTriggerHandler.handleAfterInsert(Trigger.new);           
        }
        when AFTER_UPDATE{
            AccountTriggerHandler.handleAfterUpdate(Trigger.new, trigger.oldMap); 
            AccountTriggerHandler.sendEmailOnUpdatethefieldEmailAddresses(Trigger.new, trigger.oldMap); 
        }
    }
}