/******************************************************************************************************************************************************
Name                    : AccountTriggerHandler
Author                  : Pratik Kakade
Purpose                 : This Apex class is designed to handle Account triggers, providing methods for after insert and after update operations.
Description             : This class provides methods to process Account records, including splitting address fields, handling record type changes, and 
                          syncing data with an external system.
Version                 : 1.2
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
                if ( acc.JDE_Guest_Account__c == true &&  acc.jde_address_number__c == '88888' && acc.RecordTypeId == EquipmentCustomer && acc.Sync_with_JDE__c == true) {
                    sendContactOrderToJDE = true;
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

/******************************************************************************************************************************************************
    This method is call when the email field is updated and also when the email is add to the previous fields 
******************************************************************************************************************************************************/
public static void sendEmailOnUpdatethefieldEmailAddresses(List<Account> accListEmailUpdate,Map<Id, Account> oldMapAccRecord){
    Map<Id, String> accListEmailUpdateId = new Map<Id, String>();
    Id recordTypeId = Schema.SObjectType.Bid_Line_Item__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
    If(!accListEmailUpdate.isEmpty()){
        For(Account acc : accListEmailUpdate){
            // ccheque the record is having the old value is null and the acc recored is having the new email added to the fields 
            If(oldMapAccRecord.get(acc.id).Email_Address__c==null && acc.Email_Address__c!= null){// it fire when the fields is empty and user is add the email to null fields 
                accListEmailUpdateId.put(acc.id,acc.Email_Address__c);
            } else if (oldMapAccRecord.get(acc.id).Email_Address__c!=null && acc.Email_Address__c!= null) {//when the user add the new Email to the old email 
                If (acc.Email_Address__c.length()> oldMapAccRecord.get(acc.Id).Email_Address__c.length()){
                    //accListEmailUpdateId.put(acc.Id,acc.Email_Address__c.remove(oldMapAccRecord.get(acc.id).Email_Address__c).removeStart(';'));
                }
            }
        }
    }
    Map<Id,Bid_line_item__c> mapBidLineAccoiuntId = new  Map<Id,Bid_line_item__c>();
    Map<String,Bid_line_item__c> mapBidLineNamewith = new Map<String,Bid_line_item__c>();
   If(!accListEmailUpdateId.isEmpty()){
        For(Bid_Line_Item__c bidVar :[SELECT  Id, Name, RecordTypeId, Bid_Supplier__c, Lead__c,Status__c,RFQ_Number__r.Contract__c ,Supplier_Name_Text__c, Quote_Numbers__c, 
                                      Before_due_date__c, Due_Date__c, Lead__r.Email_Address__c,Lead__r.Company,Bid_Supplier__r.Email_Address__c,Bid_Supplier__r.Name, RFQ_Number__r.Owner.Email
                                      FROM Bid_Line_Item__c
                                      WHERE Bid_Supplier__c IN :accListEmailUpdateId.keyset() AND Due_Date__c > TODAY AND RecordType.Id=:recordTypeId AND Quote_Type__c='Quoted' ]){
                                          bidVar.Bid_Supplier__r.Email_Address__c= accListEmailUpdateId.get(bidVar.Bid_Supplier__c);  
                                          system.debug('the email fields in the '+accListEmailUpdateId.get(bidVar.Bid_Supplier__c));
                                          If(bidVar.Lead__r.Email_Address__c!=null){
                                              bidVar.Lead__r.Email_Address__c=accListEmailUpdateId.get(bidVar.Bid_Supplier__c);

                                          }
                                          mapBidLineAccoiuntId.put(bidVar.RFQ_Number__c,bidVar);
                                          mapBidLineNamewith.put(bidVar.Bid_Supplier__r.Name+'_'+bidVar.Quote_Numbers__c+'.pdf',bidVar);
                                      } 
    }
    Map<Attachment,Bid_Line_Item__c> mapAttchBidLine = new Map<Attachment,Bid_Line_Item__c>();
    If(!mapBidLineAccoiuntId.isEmpty()){
        for (Attachment attchVar :[SELECT Id, parentID, Name, Body, ContentType FROM Attachment WHERE ParentID In : mapBidLineAccoiuntId.keyset() AND Name IN : mapBidLineNamewith.keySet() ]){
            If (mapBidLineNamewith.containsKey(attchVar.Name)){
                mapAttchBidLine.put(attchVar,mapBidLineNamewith.get(attchVar.Name));
            }
        }
    }
    If(!mapAttchBidLine.isEmpty()){
        // for the code sorthing calling the second method and passing the Attachment to the method 
        System.debug('Map of bid line item and '+mapAttchBidLine);
        Lead_trigger_Handler.sendEmailTotheSupplierWithAttachMent(mapAttchBidLine);
    }
}
}