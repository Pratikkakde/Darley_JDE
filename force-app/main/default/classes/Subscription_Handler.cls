/*
* Name - triggerOnSubscription
* Author - Melonleaf Consulting
* Created Date - 21/11/2021
* Purpose - Trigger
* -----------Change Log---------
* Last Modified by - Niketan Singh
* Last Modified Date -8/11/2022
*/

public class Subscription_Handler {
    
    public Static void updateDate (List<Subscription__c> newSubscriptionlist){
        list<Subscription__c> sn = new list<Subscription__c>();
        
        for(Subscription__c snn : newSubscriptionlist)
        {
            if(snn.Invoice_sent__c==true && snn.Overwrite_Payment_Reminder_Date__c==false )
                
            {    
                if(snn.Invoice_Paid__c==false)
                {
                    Date startDate = Date.today();
                    Date endDate = snn.Subscription_contracts_end_date__c;
                    Integer noOfDays = (startDate.daysBetween(endDate))/4;
                             //        Integer noOfDays = (endDate.daysBetween(startDate))/4;

                    system.debug(' Date startDate'+ startDate);
                    system.debug(' Date endDate'+ endDate);
                    system.debug( 'Output is ' + noOfDays );
                    snn.Payment_Reminder_Date_1__c=startDate+(noOfDays);
                    snn.Payment_Reminder_Date_2__c=snn.Payment_Reminder_Date_1__c+(noOfDays);
                    snn.Payment_Reminder_Date_3__c=snn.Payment_Reminder_Date_2__c+(noOfDays);
                    system.debug('Payment_Reminder_Date_1__c'+snn.Payment_Reminder_Date_1__c);
                    system.debug('Payment_Reminder_Date_2__c'+snn.Payment_Reminder_Date_2__c);
                    system.debug('Payment_Reminder_Date_3__c'+snn.Payment_Reminder_Date_3__c);


                }
            }
            
        }
        
    }
    public Static void updateData (List<Subscription__c> newList){
        Map<Id,String> m1 = new Map<Id,String>();
        Map<Id,String> m2 = new Map<Id,String>();
        
        Map<Id,Boolean> m3=  new Map<Id,Boolean>();
        
        List<Account> ac = new List<Account>();
        List<Contact> co = [Select id,Primary__c,Email,name,AccountID from Contact where AccountID!=NULL];
        system.debug('co'+co);
        
        for(Contact c1 : co)
        {  
            if(c1.Primary__c==true)
            {
                m1.put(c1.AccountId, c1.Email);
                m2.put(c1.AccountId, c1.name);
                m3.put(c1.AccountId, c1.Primary__c);
            }  
        }
        
        for(Subscription__c s1:newList){
            
            if(!m3.containsKey(s1.Account__c)){
                s1.addError('No Primary Contact');
            }
            else{
                s1.Customer_Email__c=m1.get(s1.Account__c);
                system.debug('s1.Customer_Email__c'+s1.Customer_Email__c);
                s1.Contact_First_Name__c=m2.get(s1.Account__c);
                system.debug('s1.Contact_First_Name__c'+s1.Contact_First_Name__c);
            }
        }
    }
    public Static void paidCheckbox (List<Subscription__c> newList){
        for(Subscription__c snn : newList){
            if(snn.Invoice_Paid__c==true && snn.Subscription_contracts_start_date__c < system.today()){
                snn.Subscription_contracts_start_date__c= snn.Subscription_contracts_start_date__c.addMonths(12);
                snn.Subscription_contracts_end_date__c=snn.Subscription_contracts_end_date__c.addMonths(12);
            }
        }
    }
}