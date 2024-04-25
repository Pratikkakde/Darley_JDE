/******************************************************************************************************************************************************
Name                    : AccountTriggerHandler
Author                  : Pratik Kakade
Purpose                 : This Apex class is designed to handle Account triggers, providing methods for after insert and after update operations.
Description             : This class provides methods to process Account records, including splitting address fields, handling record type changes, and 
                          syncing data with an external system.
Version                 : 1.3
Change Log              : Modified by Pratik Kakade on 26 Feb 2024.
Test Class for          : accountTriggerHandlerServiceClassTest
CreateDate              : 1 Sept 2023
LastModifiedDate        : 26 Feb 2024
******************************************************************************************************************************************************/

public class AccountTriggerHandler {
     /**
     * Method to handle after insert trigger event for Account records.
     * 
     * @param newList List of newly inserted Account records
     */
    public static void handleAfterInsert(List<Account> newList) { 
        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        
        if(profileName != 'Salesforce API Only System Integrations'){
            
            AccountWrapper wrapperObj = new AccountWrapper();
            // loop through the inserted accounts and create the wrapper objects
            if(!newList.isEmpty()){
                for (Account acc : newList) {
                    //------------------------------Address Split Logic starts here----------------------------//
                    if(acc.BillingStreet != null) {
                        splitAddress(acc.BillingStreet, wrapperObj, 'Billing');
                    }
                    
                    if(acc.ShippingStreet != null) {
                        splitAddress(acc.ShippingStreet, wrapperObj, 'Shipping');
                    }
                    //------------------------------Address Split Logic Ends here--------------------------------------//
                    
                    populateWrapper(acc, wrapperObj);
       
                }
            }
            
            String jsonStr = JSON.serialize(wrapperObj).replace('_', ' ');
            String jsonSt = jsonStr.replace('null', '""');
            // convert the list of wrapper objects to a JSON string
            system.debug('jsonstring= '+jsonStr);
            system.debug('JSON string= '+jsonSt); 
            
            
            //string EdarleyRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('EDarley New Registrant').getRecordTypeId();
            string EquipmentCustomer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Equipment Customer').getRecordTypeId();
            
            
            if(!newList.isEmpty()){
                if(newList[0].recordTypeId == EquipmentCustomer && newList[0].JDE_Guest_Account__c == false && newList[0].Sync_with_JDE__c == true){
                    CalloutToRestInsertUpdateAccount.makeCalloutInsert(jsonSt, 'Account', 'Account Insert');
                }
            }
            // handle logic here, such as validation or field manipulation
        }        
    }

     /**
     * Method to handle after update trigger event for Account records.
     * 
     * @param newList List of newly updated Account records
     * @param oldRecMap Map of old Account records
     */
    
    public static void handleAfterUpdate(List<Account> newList , Map<Id, Account> oldRecMap){
        Boolean valueChanged;
        Boolean sendAccountToJDE = false;
        Boolean sendContactOrderToJDE = false;
               
        String EdarleyRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('EDarley New Registrant').getRecordTypeId();
        string EquipmentCustomer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Equipment Customer').getRecordTypeId();

        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        
        //if(profileName != 'Salesforce API Only System Integrations'){
        
        AccountWrapper wrapperObj = new AccountWrapper();  
        
       List<Order> OrdList = [SELECT id  FROM Order WHERE AccountId = :newList[0].id LIMIT 1];
       Account oldAcc;
        // loop through the inserted accounts and create the wrapper objects
        if(!newList.isEmpty()){
            for (Account acc : newList) {
                //------------------------------Address Split Logic starts here----------------------------//
                oldAcc = oldRecMap.get(acc.Id);
            
                if(acc.BillingStreet != null) {
                    splitAddress(acc.BillingStreet, wrapperObj, 'Billing');
                }
                
                if(acc.ShippingStreet != null) {
                    splitAddress(acc.ShippingStreet, wrapperObj, 'Shipping');
                }
                //------------------------------Address Split Logic Ends here--------------------------------------//
                populateWrapper(acc, wrapperObj);
                
                // map other fields as needed
                // add the wrapper object to the list
                    Account accOld = oldRecMap.get(acc.id); 
                   //Old Version of Account Record.
                
                if ( acc.Id == accOld.Id && acc.Name == accOld.Name && acc.Primary_Division__c == accOld.Primary_Division__c && acc.BillingStreet == accOld.BillingStreet && acc.BillingCity == accOld.BillingCity && acc.BillingState == accOld.BillingState && acc.BillingCountry == accOld.BillingCountry && acc.BillingPostalCode == accOld.BillingPostalCode && acc.Phone == accOld.Phone && acc.ShippingStreet == accOld.ShippingStreet && acc.ShippingCity == accOld.ShippingCity && acc.ShippingState == accOld.ShippingState && acc.ShippingCountry == accOld.ShippingCountry && acc.ShippingPostalCode == accOld.ShippingPostalCode && acc.Region__c == accOld.Region__c && acc.Primary_POC_Email__c == accOld.Primary_POC_Email__c && acc.Payment_Terms2__c == accOld.Payment_Terms2__c && acc.Customer_Distribution_Channel__c == accOld.Customer_Distribution_Channel__c && acc.Credit_Limit__c == accOld.Credit_Limit__c && acc.Adjustment_Schedule__c == accOld.Adjustment_Schedule__c && acc.Customer_Price_Group__c == accOld.Customer_Price_Group__c && acc.JDE_Guest_Account__c == accOld.JDE_Guest_Account__c)
                {
                    valueChanged = false ;
                    
                } else {
                    
                    valueChanged = true;
                }
            
                //if recordtype changed from EDarley and Jde number==null,thens sync with jde.
                if (acc.RecordTypeId == EquipmentCustomer && acc.Sync_with_JDE__c == true && acc.jde_address_number__c == null && acc.JDE_Guest_Account__c == false && OrdList.size() > 0) {
                    sendAccountToJDE = true;
                }
                
                //if jde address number updated from null, then runs this logic and sync contact and order with jde.
                if (acc.RecordTypeId == EquipmentCustomer && acc.Sync_with_JDE__c == true && acc.jde_address_number__c != null && acc.JDE_Address_Number__c != accold.JDE_Address_Number__c && accold.JDE_Address_Number__c == null) {
                    sendContactOrderToJDE = true;
                    system.debug('sendContactOrderToJDE= '+sendContactOrderToJDE);
                }   
            }
        }
        
        String jsonStr = JSON.serialize(wrapperObj).replace('_', ' ');
        String jsonSt = jsonStr.replace('null','""');
        // convert the list of wrapper objects to a JSON string
        system.debug('jasonstring= '+jsonStr); 
        system.debug('jasonstring= '+jsonSt); 
        system.debug('newAccount.recordTypeId= '+newList[0].recordTypeId);
        system.debug('sendAccountToJDE= '+sendAccountToJDE);
        system.debug('sendContactOrderToJDE= '+sendContactOrderToJDE);
        
        //if value change is true then update send this jde to update
        system.debug('Valuchanged= '+valueChanged);
        if(valueChanged == true){
            if(!newList.isEmpty()){
                if(profileName != 'Salesforce API Only System Integrations' && newList[0].recordTypeId == EquipmentCustomer  && newList[0].JDE_Guest_Account__c == false && newList[0].jde_address_number__c != null && newList[0].Sync_with_JDE__c == true){
                    CalloutToRestInsertUpdateAccount.makeCalloutupdate(jsonSt, 'Account', 'Account Update');
                    system.debug('Callout Run Successfully');
                }
            }
        }
        else {
            system.debug('No Change in Values.');
        }     

        //Send Account to JDE if recordtype is changed.       
        if(sendAccountToJDE == true && profileName != 'Salesforce API Only System Integrations'){
            CalloutToRestInsertUpdateAccount.makeCalloutInsert(jsonSt, 'Account', 'Account Insert');
        }
        //Send Associated order and Contact to JDE if jde Address number is updated.
        if(sendContactOrderToJDE == true && newList[0].RecordTypeId == EquipmentCustomer ){
            if (newList[0].JDE_Guest_Account__c != true ) {
                accountTriggerHandlerServiceClass.sendContactToJde(newList);

            }
            System.debug('Method Called ord ---> ');
            accountTriggerHandlerServiceClass.sendOrderToJde(newList);
            System.debug('Method Called ord succ ---> ');
        }
        //}      
        
    }  
    //Method to split adress and add it in a wrapper 
    public static void splitAddress(String address, AccountWrapper wrapperObj, String type) {
        List<String> splitStrings = new List<String>();
        Integer maxLength = 30;  // Maximum length of each split substring 
        Integer startIndex = 0;
        
        while (startIndex < address.length()) {
            Integer endIndex = Math.min(startIndex + maxLength, address.length());
            splitStrings.add(address.substring(startIndex, endIndex));
            startIndex = endIndex;
        }
        
        wrapperObj.setAddressFields(type, splitStrings);
    }
    // Method to populate wrapper
    public static void populateWrapper(Account acc, AccountWrapper wrapperObj) {
        wrapperObj.Alpha_Name = acc.Name;
        wrapperObj.Business_Unit = acc.Primary_Division__c;
        wrapperObj.Billing_City = acc.BillingCity;
        wrapperObj.Billing_State = acc.BillingState;
        wrapperObj.Billing_Country = acc.BillingCountry;
        wrapperObj.Billing_Postal_Code = acc.BillingPostalCode;
        wrapperObj.Division = acc.Primary_Division__c;
        wrapperObj.DOM_or_EXP= acc.Customer_Distribution_Channel__c;
        wrapperObj.Customer_Type = acc.Region__c;
        wrapperObj.Equipment_Customer_Type = acc.Region__c;
        wrapperObj.Electronic_Address = acc.Primary_POC_Email__c;
        wrapperObj.Electronic_Address_Type= '';
        wrapperObj.Contact_Information= '';
        wrapperObj.Phone_Number= acc.Phone;
        wrapperObj.Payment_Terms = acc.Payment_Terms2__c;
        wrapperObj.Account_id= acc.Id;
        wrapperObj.Shipping_City = acc.ShippingCity;
        wrapperObj.Shipping_State = acc.ShippingState;
        wrapperObj.Shipping_Country = acc.ShippingCountry;
        wrapperObj.Shipping_Postal_Code = acc.ShippingPostalCode; 
        wrapperObj.Credit_Limit = string.valueOf( acc.Credit_Limit__c);
        wrapperObj.Adjustment_Schedule = acc.Adjustment_Schedule__c;
        wrapperObj.Customer_Price_Group = acc.Customer_Price_Group__c;
        wrapperObj.Address_Number = acc.JDE_Address_Number__c;
    }
    //Method to update RecordType // BeforeInsert
    public static void changeRecordType(List<Account> newList){
        if(!newList.isEmpty()){
            //Id profileId = UserInfo.getProfileId();
            //String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
            
            //if(profileName == 'Salesforce API Only System Integrations'){
            string Customer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            string Equipment_Customer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Equipment Customer').getRecordTypeId();
            string Pump_Customer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Pump Customer').getRecordTypeId();
            if(!newList.isEmpty()){
                for(Account acc : newList){
                    if(acc.Region__c == '*Blanks'){
                        acc.Region__c = null;
                    }
                    if(acc.Customer_Distribution_Channel__c == '*Blanks'){
                        acc.Customer_Distribution_Channel__c = null;
                    }
                    if(acc.Customer_Price_Group__c == '*Blanks'){
                        acc.Customer_Price_Group__c = null;
                    }
                    if(acc.Adjustment_Schedule__c == '*Blanks'){
                        acc.Adjustment_Schedule__c = null;
                    }
                    if(acc.Primary_Division__c == 'Equipment' || acc.Primary_Division__c == '' ){
                        acc.RecordTypeId = Equipment_Customer;
                    }else if(acc.Primary_Division__c == 'Defense'){
                        acc.RecordTypeId = Customer;  
                    }else if(acc.Primary_Division__c == 'Apparatus' || acc.Primary_Division__c == 'Pump' || acc.Primary_Division__c == 'Odin' || acc.Primary_Division__c == 'Ohler '){
                        acc.RecordTypeId = Pump_Customer;  
                    }       
                }
            }
        }
    } 
    
    //method to update JDE address Number based on JDE guest Account value. //Before Insert and Before Update.
    public static void updateJdeAddNum(List<Account> newList, Map<id,Account> accOldMap){
        if(!newList.isEmpty()){
            for(account acc : newList){
                if (acc.JDE_Guest_Account__c == true) {
                    acc.JDE_Address_Number__c = '88888';
                } else if ( accOldMap.containsKey(acc.id) && accOldMap.get(acc.id).JDE_Guest_Account__c == true && acc.JDE_Guest_Account__c == false ) {
                    acc.JDE_Address_Number__c = '';
                }
            }
        }
    }  
}