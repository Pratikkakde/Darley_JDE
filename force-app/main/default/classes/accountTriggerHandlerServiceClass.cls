/******************************************************************************************************************************************************
Name                    : AccountTriggerHandlerServiceClass
Author                  : Pratik Kakade
Purpose                 : This Apex class is designed to handle callouts for inserting and updating sales orders, as well as contacts. It facilitates communication with an external system (JDE_Integration) 
                          to perform operations related to sales orders and contact information.
Description             : This class provides methods for making callouts to external REST APIs to insert or update sales orders and contacts. It includes methods for sending order and contact information to an 
                          external system, managing request and response payloads, and updating Salesforce records accordingly. The class also logs integration requests and responses in the API_Integration_Log__c 
                          object for monitoring and troubleshooting purposes.
Version                 : 1.2
Change Log              : Modified by Pratik Kakade on 23 April 2024
Test Class              : AccountTriggerHandlerServiceClassTest
CreateDate              : 14 Oct 2023
LastModifiedDate        : 23 April 2024
******************************************************************************************************************************************************/

public class accountTriggerHandlerServiceClass {

/************************************************************************************************************************************************************************************************
      Method-sendOrderToJde used to handle Send Order Details to Jde as per criteria are match
      
      @param- newAccList List of Account that is updated and Sync With Jde is checked
************************************************************************************************************************************************************************************************/

    public static void sendOrderToJde(List<Account> newAccList) {
        String EDarley_New_Registrant = Schema.SObjectType.Account.getRecordTypeInfosByName().get('EDarley New Registrant').getRecordTypeId();
        String EquipmentCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Equipment Customer').getRecordTypeId();

        Set<Id> accIdSet = new Set<Id>();
        if (!newAccList.isEmpty()) {
            for (Account acc : newAccList) {
                accIdSet.add(acc.Id);
            }
        }

        List<Order> ordList = [SELECT Id, AccountId, JDE_Order_Number__c 
                               FROM Order 
                               WHERE JDE_Order_Number__c = null AND AccountId IN :accIdSet ORDER BY CreatedDate DESC LIMIT 5];
        Set<Id> ordIdSet = new Set<Id>();
        if (!ordList.isEmpty()) {
            for (Order ord : ordList) {
                ordIdSet.add(ord.Id);
            }
        }

        List<OrderItem> ordItmList = [SELECT Id, Product2Id, Product2.ProductCode, OrderId, LineNumber, UnitPrice, Quantity 
                                      FROM OrderItem 
                                      WHERE OrderId IN :ordIdSet];

        Set<Id> orderId = new Set<Id>();
        Set<Id> productId = new Set<Id>();
        for (OrderItem od : ordItmList) {
            orderId.add(od.OrderId);
            productId.add(od.Product2Id);
        }

        Map<Id, String> productCodeMap = new Map<Id, String>();
        Map<Id, String> branchPlantMap = new Map<Id, String>();

        for (Product2 pro : [SELECT Id, ProductCode,Branch_Plant__c FROM Product2 WHERE Id IN :productId]) {
            productCodeMap.put(pro.Id, pro.ProductCode);
            branchPlantMap.put(pro.ID,pro.Branch_Plant__c);
        }

        for (Order ord : [SELECT Id, AccountId, Account.Primary_Division__c,Account.Name, Account.JDE_Address_Number__c, Account.Payment_Terms2__c, JDE_Order_Number__c,Payment_Type__c ,OrderNumber,
                          BillingCity, BillingStreet, BillingCountry, BillingPostalCode, BillingState, Account.RecordTypeId, B2BCreditCardId__c, TotalUnitPrice__c, B2BDarleyDollars__c,
                          ShippingCity, ShippingStreet, ShippingCountry, ShippingPostalCode, ShippingState 
                          FROM Order 
                          WHERE Id IN :orderId]) {

            SalesOrderWrapper wrapperObj = new SalesOrderWrapper();
            List<SalesOrderWrapper.OrderItems> orderDetList = new List<SalesOrderWrapper.OrderItems>();

            String accRecordTypeId = ord.Account.RecordTypeId;
            Decimal Discount = 0;
            Decimal TotalDiscountPrice = 0;
            Decimal TotalExtendedDiscount = 0;

            if (ord.B2BDarleyDollars__c != null && ord.TotalUnitPrice__c != null && ord.TotalUnitPrice__c != 0) {
                Discount = (ord.TotalUnitPrice__c + ord.B2BDarleyDollars__c) / ord.TotalUnitPrice__c;
            }

            for (OrderItem oi : ordItmList) {
                SalesOrderWrapper.OrderItems orderDet = new SalesOrderWrapper.OrderItems();
                if (oi.OrderId == ord.Id && productCodeMap.containsKey(oi.Product2Id) && productCodeMap.get(oi.Product2Id) != 'Freight' && ord.B2BDarleyDollars__c == null) {
                    Decimal ExtendedPrice = oi.UnitPrice * oi.Quantity;
                    Decimal DiscountPrice = (ExtendedPrice * Discount).setScale(2, RoundingMode.HALF_UP);
                    Decimal ExtendedDiscount = ExtendedPrice - DiscountPrice;

                    TotalDiscountPrice += DiscountPrice;
                    TotalExtendedDiscount += ExtendedDiscount;

              
                    orderDet.Quantity = String.valueOf(oi.Quantity);
                    orderDet.Item_Number = productCodeMap.get(oi.Product2Id);
                    orderDet.Branch_Plant = branchPlantMap.get(oi.Product2Id);

                    orderDet.Line_Number = String.valueOf(oi.LineNumber);
                   // orderDet.Unit_Price = String.valueOf(oi.UnitPrice);
                    //orderDet.Extended_Price = String.valueOf(ExtendedPrice);
                    orderDet.Discount_Price = String.valueOf(DiscountPrice);
                    //orderDet.Extended_Discount = String.valueOf(ExtendedDiscount);

                    orderDetList.add(orderDet);
                } else if (oi.OrderId == ord.Id && productCodeMap.containsKey(oi.Product2Id) && productCodeMap.get(oi.Product2Id) != 'Freight' && ord.B2BDarleyDollars__c != null) {
                    Decimal ExtendedPrice = oi.UnitPrice * oi.Quantity;
                    Decimal DiscountPrice = (ExtendedPrice * Discount).setScale(2, RoundingMode.HALF_UP);
                    Decimal ExtendedDiscount = ExtendedPrice-DiscountPrice;
                 
                    TotalDiscountPrice = TotalDiscountPrice + DiscountPrice;
                    TotalExtendedDiscount = TotalExtendedDiscount + ExtendedDiscount;
                    
                    orderDet.Quantity = String.valueOf(oi.Quantity);
                    orderDet.Item_Number = productCodeMap.get(oi.Product2Id);
                    orderDet.Line_Number = string.valueOf(oi.LineNumber);
                    //orderDet.Unit_Price = string.valueOf(oi.UnitPrice);
                    //orderDet.Extended_Price = string.valueOf(ExtendedPrice);
                    orderDet.Discount_Price = string.valueOf(DiscountPrice);
                    //orderDet.Extended_Discount = string.valueOf(ExtendedDiscount);
                    
                    system.debug('#Line: '+oi.LineNumber+', Product Code: '+productCodeMap.get(oi.Product2Id)+', UnitPrice: '+oi.UnitPrice+', Quantity: '+oi.Quantity+', Extended Price: '+ExtendedPrice+', Discount Price: '+DiscountPrice+', Extended-Discount: '+ExtendedDiscount);
                    orderDetList.add(orderDet);
                } else if (oi.OrderId == ord.Id && productCodeMap.containsKey(oi.Product2Id) && productCodeMap.get(oi.Product2Id) == 'Freight') {
                    Decimal FreightExtendedPrice = oi.UnitPrice * oi.Quantity;
                    orderDet.Quantity = String.valueOf(oi.Quantity);
                    orderDet.Item_Number = productCodeMap.get(oi.Product2Id);
                    orderDet.Line_Number = string.valueOf(oi.LineNumber);
                    //orderDet.Unit_Price = string.valueOf(oi.UnitPrice);
                    //orderDet.Extended_Price = string.valueOf(FreightExtendedPrice);
                    orderDet.Discount_Price = string.valueOf(FreightExtendedPrice);
                    
                    orderDetList.add(orderDet);
                }
            }

            wrapperObj.Customer_PO = '';
            wrapperObj.Freight_Code = 'DES';
            wrapperObj.Zone_Number = '';
            wrapperObj.SalesForce_Order_Number = ord.OrderNumber;
            wrapperObj.Account_id = ord.AccountId;
            wrapperObj.Business_Unit = ord.Account.Primary_Division__c;
            wrapperObj.Customer_Name = ord.Account.Name;

            
             // Updated logic for Payment type: If payment type is Amazon Pay, then send Address Number as 70000. 
              // For all other payment types, send the expected Address number.

                  /************************************************************************************************/
                    if (ord.Payment_Type__c == 'Amazon Pay') {
                    wrapperObj.Address_Number = '70000';
                    } else {
                    wrapperObj.Address_Number = ord.Account.JDE_Address_Number__c;
                    }
                  /************************************************************************************************/
            wrapperObj.Payment_Terms = ord.Account.Payment_Terms2__c;
            wrapperObj.Payment_Instrument = '';
            wrapperObj.Billing_city = ord.BillingCity;
            wrapperObj.Billing_State = ord.BillingState;
            wrapperObj.Billing_postalCode = ord.BillingPostalCode;
            wrapperObj.Billing_country = ord.BillingCountry;
            wrapperObj.Billing_Address1 = ord.BillingStreet;
            wrapperObj.Shipping_Address1 = ord.ShippingStreet;
            wrapperObj.Shipping_city = ord.ShippingCity;
            wrapperObj.Shipping_State = ord.ShippingState;
            wrapperObj.Shipping_postalCode = ord.ShippingPostalCode;
            wrapperObj.Shipping_country = ord.ShippingCountry;
            wrapperObj.OrderDetail = orderDetList;

            String jsonStr = JSON.serialize(wrapperObj).replace('_', ' ');
            String jsonSt = jsonStr.replace('null', '""');

            if (jsonSt != '' && ord.JDE_Order_Number__c == null ) {
                CalloutToRestOrderItem.makeCalloutSalesOrder(jsonSt, 'Order Product', 'Order Item Insert');
            }
        }
    }

/************************************************************************************************************************************************************************************************
      Method-sendContactToJde used to handle Send Contacts Details to Jde as per criteria are match
      
      @param- newAccList List of Account that is updated and Sync With Jde is checked
************************************************************************************************************************************************************************************************/

    public static void sendContactToJde(List<Account> newAccList) {
        String EquipmentCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Equipment Customer').getRecordTypeId();

        Set<Id> accIDSet = new Set<Id>();
        for (Account acc : newAccList) {
            accIDSet.add(acc.Id);
        }

        List<Contact> conList = [SELECT Id, AccountId,Email,phone, LastName, Title, FirstName, MiddleName, MailingCity, MailingStreet, MailingState, MailingPostalCode, MailingCountry 
                                 FROM Contact 
                                 WHERE AccountId IN :accIDSet LIMIT 5];

        for (Contact contact : conList) {
            ContactWrapper conWrapperObj = new ContactWrapper();

            String mailAdd1 = '', mailAdd2 = '', mailAdd3 = '', mailAdd4 = '';
            List<String> splitmailStrings = new List<String>();
            if (contact.MailingStreet != null) {
                String mailStreet = contact.MailingStreet;
                Integer maxLength = 30;
                Integer startIndex = 0;
                while (startIndex < mailStreet.length()) {
                    Integer endIndex = Math.min(startIndex + maxLength, mailStreet.length());
                    String splitSubstring = mailStreet.substring(startIndex, endIndex);
                    splitmailStrings.add(splitSubstring);
                    startIndex = endIndex;
                }
                if (splitmailStrings.size() >= 4) {
                    mailAdd1 = splitmailStrings[0];
                    mailAdd2 = splitmailStrings[1];
                    mailAdd3 = splitmailStrings[2];
                    mailAdd4 = splitmailStrings[3];
                } else if (splitmailStrings.size() == 3) {
                    mailAdd1 = splitmailStrings[0];
                    mailAdd2 = splitmailStrings[1];
                    mailAdd3 = splitmailStrings[2];
                } else if (splitmailStrings.size() == 2) {
                    mailAdd1 = splitmailStrings[0];
                    mailAdd2 = splitmailStrings[1];
                } else if (splitmailStrings.size() == 1) {
                    mailAdd1 = splitmailStrings[0];
                }
            }

            if (!newAccList.isEmpty()) {
                conWrapperObj.Alpha_Name = newAccList[0].Name;
                conWrapperObj.Business_Unit = newAccList[0].Primary_Division__c;
                conWrapperObj.Billing_Address_1 = newAccList[0].BillingStreet;
                conWrapperObj.Billing_City = newAccList[0].BillingCity;
                conWrapperObj.Billing_State = newAccList[0].BillingState;
                conWrapperObj.Billing_Country = newAccList[0].BillingCountry;
                conWrapperObj.Billing_Postal_Code = newAccList[0].BillingPostalCode;
                conWrapperObj.Division = newAccList[0].Primary_Division__c;
                conWrapperObj.DOM_or_EXP = newAccList[0].Customer_Distribution_Channel__c;
                conWrapperObj.Customer_Type = newAccList[0].Region__c;
                conWrapperObj.Equipment_Customer_Type = newAccList[0].Region__c;
                conWrapperObj.Credit_Limit = String.valueOf(newAccList[0].Credit_Limit__c);
                conWrapperObj.Adjustment_Schedule = newAccList[0].Adjustment_Schedule__c;
                conWrapperObj.Customer_Price_Group = newAccList[0].Customer_Price_Group__c;
                conWrapperObj.Address_Number = newAccList[0].JDE_Address_Number__c;
                conWrapperObj.Electronic_Address = newAccList[0].Primary_POC_Email__c;
                conWrapperObj.Electronic_Address_Type = '';
                conWrapperObj.Phone_Number = newAccList[0].Phone;
                conWrapperObj.Payment_Terms = newAccList[0].Payment_Terms2__c;
                conWrapperObj.Contact_Information = '';
                conWrapperObj.Account_id = newAccList[0].Id;
                conWrapperObj.Shipping_City = newAccList[0].ShippingCity;
                conWrapperObj.Shipping_Country = newAccList[0].ShippingCountry;
                conWrapperObj.Shipping_Postal_Code = newAccList[0].ShippingPostalCode;
                conWrapperObj.Shipping_State = newAccList[0].ShippingState;
            }

            conWrapperObj.First_Name = contact.FirstName;
            conWrapperObj.Last_Name = contact.LastName;
            conWrapperObj.Middle_Name = contact.MiddleName;
            conWrapperObj.Contact_id = contact.Id;
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
            String full_Name = contact.FirstName+' '+contact.MiddleName+' '+contact.LastName;
            String con_Alpha_Name = full_Name.remove('null ');
            conWrapperObj.Contact_Alpha_Name =  con_Alpha_Name;
            System.debug('Contact_Alpha_Name ---> '+conWrapperObj.Contact_Alpha_Name);

            String jsonStr = JSON.serialize(conWrapperObj).replace('_', ' ');
            String jsonSt = jsonStr.replace('null', '""');
            System.debug('jsonSt ---> '+jsonSt);
            if (!newAccList.isEmpty() && newAccList[0].RecordTypeId == EquipmentCustomer && !newAccList[0].JDE_Guest_Account__c && newAccList[0].JDE_Address_Number__c != null) {
                System.debug('Method Called con ---> ');
                CalloutToRestUpdateAccountContact.makeCalloutUpdate(jsonSt, 'Contact', 'Contact Insert');
                System.debug('Method Called Succesfully con ---> ');
            }
        }
    }
}