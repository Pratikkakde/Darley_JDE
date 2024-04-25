public class ContactTriggerHandler {
    
    public static void handleAfterInsert(List<Contact> newList) {
        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        
        String EdarleyRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('EDarley New Registrant').getRecordTypeId();
        String EquipmentCustomer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Equipment Customer').getRecordTypeId();

        if(profileName != 'Salesforce API Only System Integrations'){
            
            ContactWrapper conWrapperObj = new ContactWrapper();
            List<Account> AccountList = [Select Id, Name,Sync_with_JDE__c,  BillingStreet,  BillingState, BillingCity, BillingPostalCode, BillingCountry, Primary_Division__c, JDE_Address_Number__c, recordTypeId,
                                         Primary_POC_Email__c, Phone ,Payment_Terms2__c, ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, 
                                         Region__c, Adjustment_Schedule__c, Credit_Limit__c, Customer_Distribution_Channel__c,Customer_Price_Group__c,JDE_Guest_Account__c from Account where Id =:newList[0].AccountId];
            
            //------------------------------Address Split Logic starts here----------------------------//
            String BillAdd1 = '';
            String BillAdd2 = '';
            String BillAdd3 = '';
            String BillAdd4 = '';
            String ShipAdd1 = '';
            String ShipAdd2 = '';
            String ShipAdd3 = '';
            String ShipAdd4 = '';
            
            If(!AccountList.isEmpty()){
                List<String> splitBillStrings = new List<String>();
                if(AccountList[0].BillingStreet != null){
                    String BillStreet = AccountList[0].BillingStreet;
                    Integer maxLength = 30;  // Maximum length of each split substring 
                    
                    Integer startIndex = 0;
                    while (startIndex < BillStreet.length()) {
                        Integer endIndex = Math.min(startIndex + maxLength, BillStreet.length());
                        String splitSubstring = BillStreet.substring(startIndex, endIndex);
                        splitBillStrings.add(splitSubstring);
                        startIndex = endIndex;
                    }
                    if(splitBillStrings.size() >= 4){BillAdd1 = splitBillStrings[0]; BillAdd2 = splitBillStrings[1]; BillAdd3 = splitBillStrings[2];BillAdd4 = splitBillStrings[3];}
                    else if(splitBillStrings.size() == 3){BillAdd1 = splitBillStrings[0]; BillAdd2 = splitBillStrings[1]; BillAdd3 = splitBillStrings[2];}
                    else if(splitBillStrings.size() == 2){BillAdd1 = splitBillStrings[0]; BillAdd2 = splitBillStrings[1];}
                    else if(splitBillStrings.size() == 1){BillAdd1 = splitBillStrings[0];}  
                }
                
                List<String> splitShipStrings = new List<String>();
                if(AccountList[0].ShippingStreet != null){
                    String ShipStreet = AccountList[0].ShippingStreet;
                    Integer maxLength = 30;  // Maximum length of each split substring 
                    
                    Integer startIndex = 0;
                    while (startIndex < ShipStreet.length()) {
                        Integer endIndex = Math.min(startIndex + maxLength, ShipStreet.length());
                        String splitSubstring = ShipStreet.substring(startIndex, endIndex);
                        splitShipStrings.add(splitSubstring);
                        startIndex = endIndex;
                    }
                    if(splitShipStrings.size() >= 4){ShipAdd1 = splitShipStrings[0];ShipAdd2 = splitShipStrings[1];ShipAdd3 = splitShipStrings[2];ShipAdd4 = splitShipStrings[3];}
                    else if(splitShipStrings.size() == 3){ShipAdd1 = splitShipStrings[0];ShipAdd2 = splitShipStrings[1];ShipAdd3 = splitShipStrings[2];}
                    else if(splitShipStrings.size() == 2){ShipAdd1 = splitShipStrings[0];ShipAdd2 = splitShipStrings[1];}
                    else if(splitShipStrings.size() == 1){ShipAdd1 = splitShipStrings[0];}
                }
            }
            //------------------------------Address Split Logic Ends here--------------------------------------//
            
            // loop through the inserted accounts and create the wrapper objects
            if(!newList.isEmpty()){
                for(Contact contact : newList) {
                    String full_Name = contact.FirstName+' '+contact.MiddleName+' '+contact.LastName;
                    String con_Alpha_Name = full_Name.remove('null ');
                    
                    //------------------------------Mailing Address Split Logic starts here----------------------------//
                    String mailAdd1 = '';
                    String mailAdd2 = '';
                    String mailAdd3 = '';
                    String mailAdd4 = '';
                    List<String> splitmailStrings = new List<String>();
                    if(contact.MailingStreet != null){
                        String mailStreet = contact.MailingStreet;
                        Integer maxLength = 30;  // Maximum length of each split substring 
                        
                        Integer startIndex = 0;
                        while (startIndex < mailStreet.length()) {
                            Integer endIndex = Math.min(startIndex + maxLength, mailStreet.length());
                            String splitSubstring = mailStreet.substring(startIndex, endIndex);
                            splitmailStrings.add(splitSubstring);
                            startIndex = endIndex;
                        }
                        if(splitmailStrings.size() >= 4){mailAdd1 = splitmailStrings[0];mailAdd2 = splitmailStrings[1];mailAdd3 = splitmailStrings[2];mailAdd4 = splitmailStrings[3];}
                        else if(splitmailStrings.size() == 3){mailAdd1 = splitmailStrings[0]; mailAdd2 = splitmailStrings[1]; mailAdd3 = splitmailStrings[2];}
                        else if(splitmailStrings.size() == 2){mailAdd1 = splitmailStrings[0]; mailAdd2 = splitmailStrings[1];}
                        else if(splitmailStrings.size() == 1){ mailAdd1 = splitmailStrings[0];} 
                    }
                    //------------------------------Mailing Address Split Logic Ends here--------------------------------------//
                    
                    // Account fields Mapping
                    if(AccountList.size()>0){
                        conWrapperObj.Alpha_Name = AccountList[0].Name;
                        conWrapperObj.Business_Unit = AccountList[0].Primary_Division__c;
                        conWrapperObj.Billing_Address_1 = BillAdd1;
                        conWrapperObj.Billing_Address_2 = BillAdd2;
                        conWrapperObj.Billing_Address_3 = BillAdd3;
                        conWrapperObj.Billing_Address_4 = BillAdd4;
                        conWrapperObj.Billing_City = AccountList[0].BillingCity;
                        conWrapperObj.Billing_State = AccountList[0].BillingState;
                        conWrapperObj.Billing_Country = AccountList[0].BillingCountry;
                        conWrapperObj.Billing_Postal_Code = AccountList[0].BillingPostalCode;
                        conWrapperObj.Division = AccountList[0].Primary_Division__c;
                        conWrapperObj.DOM_or_EXP= AccountList[0].Customer_Distribution_Channel__c;
                        conWrapperObj.Customer_Type = AccountList[0].Region__c;
                        conWrapperObj.Equipment_Customer_Type = AccountList[0].Region__c;
                        conWrapperObj.Credit_Limit=String.valueOf(AccountList[0].Credit_Limit__c);
                        conWrapperObj.Adjustment_Schedule= AccountList[0].Adjustment_Schedule__c;
                        conWrapperObj.Customer_Price_Group= AccountList[0].Customer_Price_Group__c;
                        conWrapperObj.Address_Number = AccountList[0].JDE_Address_Number__c;
                        
                        conWrapperObj.Electronic_Address = AccountList[0].Primary_POC_Email__c;
                        conWrapperObj.Electronic_Address_Type='';
                        
                        conWrapperObj.Phone_Number= AccountList[0].Phone;
                        conWrapperObj.Payment_Terms = AccountList[0].Payment_Terms2__c;
                        
                        conWrapperObj.Contact_Information='';
                        conWrapperObj.Account_id=AccountList[0].Id;
                        conWrapperObj.Shipping_Address_1 = ShipAdd1;
                        conWrapperObj.Shipping_Address_2 = ShipAdd2;
                        conWrapperObj.Shipping_Address_3 = ShipAdd3;
                        conWrapperObj.Shipping_Address_4 = ShipAdd4;
                        conWrapperObj.Shipping_City = AccountList[0].ShippingCity;
                        conWrapperObj.Shipping_Country = AccountList[0].ShippingCountry;
                        conWrapperObj.Shipping_Postal_Code = AccountList[0].ShippingPostalCode;
                        conWrapperObj.Shipping_State = AccountList[0].ShippingState;
                    }
                    
                    //Contact fields Mapping.
                    conWrapperObj.First_Name = contact.FirstName;
                    conWrapperObj.Last_Name = contact.LastName;
                    conWrapperObj.Middle_Name = contact.MiddleName;
                    conWrapperObj.Contact_id = contact.id;
                    conWrapperObj.Contact_Address_1 = mailAdd1;
                    conWrapperObj.Contact_Address_2 = mailAdd2;
                    conWrapperObj.Contact_Address_3 = mailAdd3;
                    conWrapperObj.Contact_Address_4 = mailAdd4;
                    conWrapperObj.Contact_City = contact.MailingCity;
                    conWrapperObj.Contact_State = contact.MailingState;
                    conWrapperObj.Contact_Postal_Code = contact.MailingPostalCode;
                    conWrapperObj.Contact_Country = contact.MailingCountry;
                    conWrapperObj.Contact_Title = contact.Title;
                    conWrapperObj.Contact_Email = contact.Email;
                    conWrapperObj.Contact_Phone_Number = contact.phone;
                    conWrapperObj.Contact_Alpha_Name = con_Alpha_Name;
                    
                    // add the wrapper object to the list
                    
                }
            }
            
            String jsonStr = JSON.serialize(conWrapperObj).replace('_', ' ');
            String jsonSt = jsonStr.replace('null', '""');
            system.debug('jsonStr= '+jsonStr);
            // convert the list of wrapper objects to a JSON string
            
            if(!AccountList.isEmpty()){
                if(AccountList[0].recordTypeId == EquipmentCustomer && AccountList[0].Sync_with_JDE__c == true && AccountList[0].JDE_Guest_Account__c == false && AccountList[0].JDE_Address_Number__c != null ){              
                    CalloutToRestUpdateAccountContact.makeCalloutUpdate(jsonSt, 'Contact', 'Contact Insert');
                }
            }           
        }  
    }
    
    public static void handleAfterUpdate(List<Contact> newList, Map<Id, Contact> oldConMap) {
        Boolean valueChanged;
        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        
        String EdarleyRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('EDarley New Registrant').getRecordTypeId();
        String EquipmentCustomer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Equipment Customer').getRecordTypeId();

        if(profileName != 'Salesforce API Only System Integrations'){
            
            ContactWrapper conWrapperObj = new ContactWrapper();
            List<Account> AccountList = [Select Id, Name, Sync_with_JDE__c, BillingStreet,  BillingState, BillingCity, BillingPostalCode, BillingCountry, Primary_Division__c, JDE_Address_Number__c, recordTypeId,
                                         Primary_POC_Email__c, Phone ,Payment_Terms2__c, ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, JDE_Guest_Account__c,
                                         Region__c, Adjustment_Schedule__c, Credit_Limit__c, Customer_Distribution_Channel__c,Customer_Price_Group__c from Account where Id =:newList[0].AccountId];
            
            //------------------------------Address Split Logic starts here----------------------------//
            String BillAdd1 = '';
            String BillAdd2 = '';
            String BillAdd3 = '';
            String BillAdd4 = '';
            String ShipAdd1 = '';
            String ShipAdd2 = '';
            String ShipAdd3 = '';
            String ShipAdd4 = '';
            
            List<String> splitBillStrings = new List<String>();
            if(!AccountList.isEmpty()){
                if(AccountList[0].BillingStreet != null){
                    String BillStreet = AccountList[0].BillingStreet;
                    Integer maxLength = 30;  // Maximum length of each split substring 
                    
                    Integer startIndex = 0;
                    while (startIndex < BillStreet.length()) {
                        Integer endIndex = Math.min(startIndex + maxLength, BillStreet.length());
                        String splitSubstring = BillStreet.substring(startIndex, endIndex);
                        splitBillStrings.add(splitSubstring);
                        startIndex = endIndex;
                    }
                    if(splitBillStrings.size() >= 4){BillAdd1 = splitBillStrings[0]; BillAdd2 = splitBillStrings[1]; BillAdd3 = splitBillStrings[2];BillAdd4 = splitBillStrings[3];}
                    else if(splitBillStrings.size() == 3){BillAdd1 = splitBillStrings[0]; BillAdd2 = splitBillStrings[1]; BillAdd3 = splitBillStrings[2];}
                    else if(splitBillStrings.size() == 2){BillAdd1 = splitBillStrings[0]; BillAdd2 = splitBillStrings[1];}
                    else if(splitBillStrings.size() == 1){BillAdd1 = splitBillStrings[0];}  
                }
                
                List<String> splitShipStrings = new List<String>();
                if(AccountList[0].ShippingStreet != null){
                    String ShipStreet = AccountList[0].ShippingStreet;
                    Integer maxLength = 30;  // Maximum length of each split substring 
                    
                    Integer startIndex = 0;
                    while (startIndex < ShipStreet.length()) {
                        Integer endIndex = Math.min(startIndex + maxLength, ShipStreet.length());
                        String splitSubstring = ShipStreet.substring(startIndex, endIndex);
                        splitShipStrings.add(splitSubstring);
                        startIndex = endIndex;
                    }
                    if(splitShipStrings.size() >= 4){ShipAdd1 = splitShipStrings[0];ShipAdd2 = splitShipStrings[1];ShipAdd3 = splitShipStrings[2];ShipAdd4 = splitShipStrings[3];}
                    else if(splitShipStrings.size() == 3){ShipAdd1 = splitShipStrings[0];ShipAdd2 = splitShipStrings[1];ShipAdd3 = splitShipStrings[2];}
                    else if(splitShipStrings.size() == 2){ShipAdd1 = splitShipStrings[0];ShipAdd2 = splitShipStrings[1];}
                    else if(splitShipStrings.size() == 1){ShipAdd1 = splitShipStrings[0];}
                }
            }
            //------------------------------Address Split Logic Ends here--------------------------------------//
            
            system.debug('AccountList'+AccountList);
            // loop through the inserted accounts and create the wrapper objects
            if(!newList.isEmpty()){
                for (Contact newCon : newList) {
                    String full_Name = newCon.FirstName+' '+newCon.MiddleName+' '+newCon.LastName;
                    System.debug('full_Name ---> '+full_Name);
                    String con_Alpha_Name = full_Name.remove('null ');
                    System.debug('con_Alpha_Name ---> '+con_Alpha_Name);
                    //------------------------------Mailing Address Split Logic starts here----------------------------//
                    String mailAdd1 = '';
                    String mailAdd2 = '';
                    String mailAdd3 = '';
                    String mailAdd4 = '';
                    List<String> splitmailStrings = new List<String>();
                    if(newCon.MailingStreet != null){
                        String mailStreet = newCon.MailingStreet;
                        Integer maxLength = 30;  // Maximum length of each split substring 
                        
                        Integer startIndex = 0;
                        while (startIndex < mailStreet.length()) {
                            Integer endIndex = Math.min(startIndex + maxLength, mailStreet.length());
                            String splitSubstring = mailStreet.substring(startIndex, endIndex);
                            splitmailStrings.add(splitSubstring);
                            startIndex = endIndex;
                        }
                        
                        if(splitmailStrings.size() >= 4){mailAdd1 = splitmailStrings[0];mailAdd2 = splitmailStrings[1];mailAdd3 = splitmailStrings[2];mailAdd4 = splitmailStrings[3];}
                        else if(splitmailStrings.size() == 3){mailAdd1 = splitmailStrings[0]; mailAdd2 = splitmailStrings[1]; mailAdd3 = splitmailStrings[2];}
                        else if(splitmailStrings.size() == 2){mailAdd1 = splitmailStrings[0]; mailAdd2 = splitmailStrings[1];}
                        else if(splitmailStrings.size() == 1){ mailAdd1 = splitmailStrings[0];}  
                    }
                    //------------------------------Mailing Address Split Logic Ends here--------------------------------------//
                    
                    
                    // Account fields Mapping
                    if(AccountList.size()>0){
                        conWrapperObj.Alpha_Name = AccountList[0].Name;
                        conWrapperObj.Business_Unit = AccountList[0].Primary_Division__c;
                        conWrapperObj.Billing_Address_1 = BillAdd1;
                        conWrapperObj.Billing_Address_2 = BillAdd2;
                        conWrapperObj.Billing_Address_3 = BillAdd3;
                        conWrapperObj.Billing_Address_4 = BillAdd4;
                        conWrapperObj.Billing_City = AccountList[0].BillingCity;
                        conWrapperObj.Billing_State = AccountList[0].BillingState;
                        conWrapperObj.Billing_Country= AccountList[0].BillingCountry;
                        conWrapperObj.Billing_Postal_Code = AccountList[0].BillingPostalCode;
                        conWrapperObj.Division = AccountList[0].Primary_Division__c;
                        conWrapperObj.DOM_or_EXP= AccountList[0].Customer_Distribution_Channel__c;
                        conWrapperObj.Customer_Type = AccountList[0].Region__c;
                        conWrapperObj.Equipment_Customer_Type = AccountList[0].Region__c;
                        conWrapperObj.Credit_Limit = String.valueOf(AccountList[0].Credit_Limit__c);
                        conWrapperObj.Adjustment_Schedule = AccountList[0].Adjustment_Schedule__c;
                        conWrapperObj.Customer_Price_Group = AccountList[0].Customer_Price_Group__c;
                        conWrapperObj.Address_Number = AccountList[0].JDE_Address_Number__c;
                        conWrapperObj.Electronic_Address = AccountList[0].Primary_POC_Email__c;
                        conWrapperObj.Electronic_Address_Type='';       
                        conWrapperObj.Phone_Number= AccountList[0].Phone;
                        conWrapperObj.Payment_Terms = AccountList[0].Payment_Terms2__c; 
                        conWrapperObj.Contact_Information='';
                        conWrapperObj.Account_Id=AccountList[0].Id;
                        conWrapperObj.Shipping_Address_1 = ShipAdd1;
                        conWrapperObj.Shipping_Address_2 = ShipAdd2;
                        conWrapperObj.Shipping_Address_3 = ShipAdd3;
                        conWrapperObj.Shipping_Address_4 = ShipAdd4;
                        conWrapperObj.Shipping_City = AccountList[0].ShippingCity;
                        conWrapperObj.Shipping_State = AccountList[0].ShippingState;
                        conWrapperObj.Shipping_Country = AccountList[0].ShippingCountry;
                        conWrapperObj.Shipping_Postal_Code = AccountList[0].ShippingPostalCode;
                        
                        
                    }
                    
                    //Contact fields Mapping.
                    conWrapperObj.First_Name = newCon.FirstName;
                    conWrapperObj.Last_Name = newCon.LastName;
                    conWrapperObj.Middle_Name = newCon.MiddleName;
                    
                    conWrapperObj.Contact_id = newCon.id;
                    conWrapperObj.Contact_Address_1 = mailAdd1;
                    conWrapperObj.Contact_Address_2 = mailAdd2;
                    conWrapperObj.Contact_Address_3 = mailAdd3;
                    conWrapperObj.Contact_Address_4 = mailAdd4;
                    conWrapperObj.Contact_City = newCon.MailingCity;
                    conWrapperObj.Contact_State = newCon.MailingState;
                    conWrapperObj.Contact_Postal_Code = newCon.MailingPostalCode;
                    conWrapperObj.Contact_Country = newCon.MailingCountry;
                    conWrapperObj.Contact_Title = newCon.Title;
                    conWrapperObj.Contact_Email = newCon.Email;
                    conWrapperObj.Contact_Phone_Number = newCon.phone;
                    conWrapperObj.Contact_Alpha_Name = con_Alpha_Name ;
                        System.debug('Contact_Alpha_Name ---> '+conWrapperObj.Contact_Alpha_Name);
                    
                    // add the wrapper object to the list
                    
                    contact oldCon =  oldConMap.get(newCon.Id);
                    
                    if(newCon.FirstName == oldCon.FirstName && newCon.LastName == oldCon.LastName  && newCon.MiddleName == oldCon.MiddleName && newCon.id == oldCon.id && newCon.AccountId == oldCon.AccountId && newCon.MailingStreet == oldCon.MailingStreet && newCon.Phone == oldCon.Phone &&
                       newCon.MailingCity == oldCon.MailingCity && newCon.MailingState == oldCon.MailingState && newCon.MailingPostalCode == oldCon.MailingPostalCode && newCon.MailingCountry == oldCon.MailingCountry && newCon.Title == oldCon.Title  && newCon.Email == oldCon.Email)
                    {
                        valueChanged = False;                   
                    }else{
                        valueChanged= True;
                    }         
                }
            }
            
            String jsonStr = JSON.serialize(conWrapperObj).replace('_', ' ');
            String jsonSt = jsonStr.replace('null', '""');
            system.debug('jsonStr'+jsonStr);
            system.debug('Value Changed:= '+valueChanged);
            // convert the list of wrapper objects to a JSON string
            
            
            if(valueChanged){
                system.debug('Contact Values Changed, Callout initiated.');
                if(!AccountList.isEmpty()){
                    if(AccountList[0].recordTypeId == EquipmentCustomer && AccountList[0].Sync_with_JDE__c == true && AccountList[0].JDE_Guest_Account__c == false && AccountList[0].JDE_Address_Number__c != null ){              
                        CalloutToRestUpdateAccountContact.makeCalloutUpdate(jsonSt, 'Contact', 'Contact Update');
                    }
                }                
            }
            else
            {
                system.debug('Contact Values did not Change, so No callout');
            }      
        }
    }
}