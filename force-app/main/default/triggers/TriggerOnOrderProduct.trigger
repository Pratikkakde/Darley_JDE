trigger TriggerOnOrderProduct on OrderItem (After insert, After Update, After Delete) {
    
    switch on Trigger.OperationType  {
        when After_INSERT{
         // OrderProductTriggerHandler.handleAfterInsertOrderItem(trigger.new);
            System.enqueueJob(new calloutOrderDiscount(trigger.new));
        }
    
        when After_Update{
           OrderProductTriggerHandler.handleAfterUpdate(trigger.new);
        }
        
        when After_Delete{
            OrderProductTriggerHandler.handleAfterDelete(Trigger.old);
        }
    }
}