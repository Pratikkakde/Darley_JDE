/**
* @File Name           :   	B2BUpdateCCExpDate.apxc
* @Description         :   	Class for updating the Exp Date on payment methods
* @Author              :   	Nishil Patel - Aleysian
*==============================================================================
* Ver         Date                     Author      		      Modification
*==============================================================================
* 1.0 		06.17.2024 				Nishil Patel 			 Initial Build
**/

public class B2BUpdateCCExpDate {
    
    public static void updateCCInfo(List<Order> newList) {
        //------------------------------B2BCard Field Update Logic Start here--------------------------------------//
        
        //list to hold orders for update
        List<Order> updateList = new List<Order>();
        
        //loop through all orders
        for(Order order : newList) {
            //check that payment exists
            if(order.B2BCreditCardId__c != null) {
                //get card
                CustomerCardPayment__c card;
                List<CustomerCardPayment__c> cards = [SELECT Id, Name, Contact__c, Card_Type__c, Is_Default__c, Card_Last_Four__c, Expiration_Month__c, Expiration_Year__c FROM CustomerCardPayment__c WHERE Id = :order.B2BCreditCardId__c LIMIT 1];
                           
                //check for null
                if(!cards.isEmpty()) {
                    card = cards[0];
                    order.B2B_CreditCard_ExpDate__c = card.Expiration_Month__c + '/' + card.Expiration_Year__c;
                    System.debug('order ---->'+order);
    				updateList.add(order);
                }
                
                
                //------------------------------B2BCard Field Update Logic End here--------------------------------------//
                
            }else {
                System.debug('No payment found for Order ' + order.Id);
            }          
        }
        
        //perform DML in bulk
        if(!updateList.isEmpty()) {
            try {
                update updateList;
            }catch(DmlException e){
                System.debug(e.getMessage());
            }
        }
    }
}