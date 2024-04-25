public class OrderTriggerHandler {  
    //Address and credit card update to jde after JDE Order Number gets updated
    public static void address_Cred_CardUpdateToJde(List<order> newList, List<order> oldList){
        String EquipmentCustomer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Equipment Customer').getRecordTypeId();
        system.debug('EquipmentCustomer: '+EquipmentCustomer);
        
        //system.debug('Order.Account.RecordTypeId: '+newList[0].Account.RecordTypeId);
        
        Account acc = [SELECT id, RecordTypeId from Account where Id =:newList[0].AccountId ];
        system.debug('acc.RecordTypeId= '+ acc.RecordTypeId);
        if(!newList.isEmpty()){ 
            //This condition works when Jde order Number gets Updated 
            if(newList[0].JDE_Order_Number__c != null && oldList[0].JDE_Order_Number__c != newList[0].JDE_Order_Number__c && acc.RecordTypeId == EquipmentCustomer){
                System.enqueueJob(new CalloutToRestOrderAddressUpdateQue(newList, oldList, True ), 1);               
            }
            
            //This condition works when address gets Updated 
            if(newList[0].JDE_Order_Number__c != null && oldList[0].JDE_Order_Number__c == newList[0].JDE_Order_Number__c && acc.RecordTypeId == EquipmentCustomer){
                if(oldList[0].billingStreet != newList[0].billingStreet || 
                   oldList[0].billingCity != newList[0].billingCity || 
                   oldList[0].billingState != newList[0].billingState || 
                   oldList[0].billingCountry != newList[0].billingCountry || 
                   oldList[0].billingPostalCode != newList[0].billingPostalCode || 
                   oldList[0].ShippingStreet != newList[0].ShippingStreet || 
                   oldList[0].ShippingCity != newList[0].ShippingCity || 
                   oldList[0].ShippingState != newList[0].ShippingState || 
                   oldList[0].ShippingCountry != newList[0].ShippingCountry || 
                   oldList[0].ShippingPostalCode != newList[0].ShippingPostalCode  ){
                       System.enqueueJob(new CalloutToRestOrderAddressUpdateQue(newList, oldList, false ));
                   }              
            }
        }
    }
    public static void afterinsert (List<order> NewList) { 
        System.debug('Called--->');
        
        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        
        string EquipmentCustomer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Equipment Customer').getRecordTypeId();
        Boolean sendToJde = false;
        List<Account> accList = [SELECT Name, RecordTypeId, Sync_with_JDE__c, JDE_Guest_Account__c, Primary_Division__c, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, Customer_Distribution_Channel__c, Region__c, Primary_POC_Email__c, Phone, Payment_Terms2__c, Id, ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, Credit_Limit__c, Adjustment_Schedule__c, Customer_Price_Group__c, JDE_Address_Number__c FROM Account WHERE Id = :newList[0].AccountId];
        if (!accList.isEmpty()) {
            for (Account acc : accList) { 
                if (acc.RecordTypeId == EquipmentCustomer &&  acc.Sync_with_JDE__c == true && acc.jde_address_number__c == null && acc.JDE_Guest_Account__c == false ) {
                    sendToJde = true;
                }
            }
            if (sendToJde == true) {
                AccountWrapper wrapperObj = new AccountWrapper();
                System.debug('sendToJde--->'+sendToJde);
                
                Account acc = accList[0];
                //------------------------------Address Split Logic Start here--------------------------------------//
                if(acc.BillingStreet != null) {
                    AccountTriggerHandler.splitAddress(acc.BillingStreet, wrapperObj, 'Billing');
                }
                
                if(acc.ShippingStreet != null) {
                    AccountTriggerHandler.splitAddress(acc.ShippingStreet, wrapperObj, 'Shipping');
                }
                //------------------------------Address Split Logic Ends here--------------------------------------//
                
                AccountTriggerHandler.populateWrapper(acc, wrapperObj);
                
                String jsonStr = JSON.serialize(wrapperObj).replace('_', ' ');
                String jsonSt = jsonStr.replace('null','""');
                
                if(sendToJde == true && profileName != 'Salesforce API Only System Integrations'){
                    System.debug('sendToJde--->'+sendToJde);
                    CalloutToRestInsertUpdateAccount.makeCalloutInsert(jsonSt, 'Account', 'Account Insert');
                }
            }
        }
    }
}