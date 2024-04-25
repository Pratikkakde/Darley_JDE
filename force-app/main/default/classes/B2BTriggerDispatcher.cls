public with sharing class B2BTriggerDispatcher {
    /*
        Call this method from your trigger, passing in an instance of a trigger handler which implements B2BITriggerHandler.
        This method will fire the appropriate methods on the handler depending on the trigger context.
    */
    public static void Run(B2BITriggerHandler handler, System.TriggerOperation triggerEvent) {
        // Check to see if the trigger has been disabled. If it has, return
        if(handler.IsDisabled()) {
            return;
        }

        // Detect the current trigger context and fire the relevant methods on the trigger handler:
    
        switch on triggerEvent {
            when BEFORE_INSERT {
                handler.beforeInsert(Trigger.new);
            } when BEFORE_UPDATE {
                handler.beforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
            } when BEFORE_DELETE {
                handler.beforeDelete(Trigger.old, Trigger.oldMap);
            } when AFTER_INSERT {
                handler.afterInsert(Trigger.new, Trigger.newMap);
            } when AFTER_UPDATE {
                handler.afterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
            } when AFTER_DELETE {
                handler.afterDelete(Trigger.old, Trigger.oldMap);
            } when AFTER_UNDELETE {
                handler.afterUnDelete(Trigger.new, Trigger.oldMap);
            }
        }  
    }
    
}