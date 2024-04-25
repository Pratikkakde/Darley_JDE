/*
 * Name - triggerOnSubscription
 * Author - Melonleaf Consulting
 * Created Date - 21/11/2021
 * Purpose - Trigger
 * -----------Change Log---------
 * Last Modified by - Niketan Singh
 * Last Modified Date -8/11/2022
 */

trigger triggerOnSubscription on Subscription__c (before Update,before insert) {
    
      if(Trigger.isBefore){
        if(Trigger.isInsert||Trigger.isUpdate){
            Subscription_Handler.updateDate(Trigger.new);
        }
          
        if(Trigger.isInsert){
            Subscription_Handler.updateData(Trigger.new);
        }
           if(Trigger.isUpdate){
            Subscription_Handler.paidCheckbox(Trigger.new);
        }
     }

}