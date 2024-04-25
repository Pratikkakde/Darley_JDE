trigger TriggerOnAccount on Account (After insert, After update, Before Insert, Before Update) {
    
    /*switch on Trigger.OperationType  {
        when BEFORE_INSERT{
            //AccountTriggerHandler.coppyAddress(Trigger.new);
            AccountTriggerHandler.changeRecordType(Trigger.new);
            AccountTriggerHandler.updateJdeAddNum(trigger.new);
        }
        when BEFORE_UPDATE{
            // AccountTriggerHandler.coppyAddress(Trigger.new);
            AccountTriggerHandler.updateJdeAddNum(trigger.new);
        }
        when AFTER_INSERT{
            AccountTriggerHandler.handleAfterInsert(Trigger.new);           
        }
        when AFTER_UPDATE{
            AccountTriggerHandler.handleAfterUpdate(Trigger.new, trigger.oldMap); 
        }
    }*/
}