public class calloutOrderDiscount implements Queueable, Database.AllowsCallouts {
    
    Public List<orderItem> newOrdList;
    
    //Constructor
    public calloutOrderDiscount(List<OrderItem> newList){       
        this.newOrdList = newList;       
    }
    
    //Method to callout to send orderItem to JDE
    public void execute(QueueableContext context) {
        OrderProductTriggerHandler.handleAfterInsertOrderItem(newOrdList);
    }
}