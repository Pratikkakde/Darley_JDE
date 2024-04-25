trigger TriggerOnContact on Contact (After insert, After update) {
    
    switch on Trigger.OperationType  {
        when After_INSERT{
            ContactTriggerHandler.handleAfterInsert(Trigger.new);
        }
    
        when After_Update{
            ContactTriggerHandler.handleAfterUpdate(Trigger.new, trigger.oldMap);
        }
    }
}