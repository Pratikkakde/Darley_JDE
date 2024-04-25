trigger TriggerOnOrder on Order (After update, After Insert) {
    if(trigger.isAfter){ 
        if(trigger.isUpdate){        
           // OrderTriggerHandler.address_Cred_CardUpdateToJde(trigger.new, trigger.old);            
        }
    }   
}