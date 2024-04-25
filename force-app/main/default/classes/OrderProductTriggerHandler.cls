/******************************************************************************************************************************************************
Name                    : OrderProductTriggerHandler
Author                  : Pratik Kakade
Purpose                 : This Apex class is designed to handle triggers on OrderItem objects, facilitating communication with an external system (JDE_Integration)
                          to perform operations related to sales orders. It provides functionality for inserting, updating, and deleting order line items, including
                          callouts to an external service (CalloutToRestOrderItem) to synchronize data with JDE (JD Edwards) system.
Description             : This class contains methods to handle various scenarios such as new order item insertion, quantity changes, and order item deletion. It creates
                          wrapper objects for order data, handles the calculation of discounts, and prepares JSON strings for callouts to JDE_Integration. Depending on the
                          record type and synchronization status of the associated account, it triggers the appropriate callouts.
Version                 : 1.2
Change Log              : Modified by Pratik Kakade on 23 April 2024
Test Class              : 
CreateDate              : 14 Oct 2023
LastModifiedDate        : 22 April 2024
******************************************************************************************************************************************************/

public class OrderProductTriggerHandler {
    
    //New order item insertion
    public static void handleAfterInsertOrderItem(List<OrderItem> newList){
        String EDarley_New_Registrant = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('EDarley New Registrant').getRecordTypeId();
        String EquipmentCustomer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Equipment Customer').getRecordTypeId();
        
        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        
        if(profileName != 'Salesforce API Only System Integrations'){
            
            SalesOrderWrapper wrapperObj = new SalesOrderWrapper();
            List<SalesOrderWrapper.OrderItems> orderDetList = new List<SalesOrderWrapper.OrderItems>();
            Set<Id> orderId = new Set<Id>();
            Set<Id> productId = new Set<Id>();
            
            if(newList.size()>0){
                for(OrderItem od : newList){
                    orderId.add(od.orderId);
                    productId.add(od.Product2Id);
                    system.debug('orderId:= '+od.orderId);
                    system.debug('Product2Id:= '+od.Product2Id);      
                    
                }
            }
            
            List<Product2> prodList = [Select id, productCode, JDE_Part_Number__c from Product2 where id in:productId ];
            
            Map<Id, String> productCodeMap = new map<Id,String>();
            
            if(!prodList.isEmpty()){
                for(product2 pro : prodList){
                    productCodeMap.put(pro.id, pro.ProductCode); 
                }
            }
            
            List<Order> oderList = [Select id,Payment_Type__c ,AccountId, Account.Primary_Division__c, Account.JDE_Address_Number__c, Account.Payment_Terms2__c,  JDE_Order_Number__c, OrderNumber,
                                    Billingcity, Billingstreet, billingCountry, billingPostalCode, billingState, Account.RecordTypeId, B2BCreditCardId__c, TotalUnitPrice__c, B2BDarleyDollars__c,
                                    Shippingcity, Shippingstreet, ShippingCountry, ShippingPostalCode, ShippingState from Order where id in:orderId];

            Account acc = [SELECT Id, Sync_with_JDE__c, RecordTypeId FROM Account WHERE Id =: oderList[0].AccountId];
            String accRecordTypeId = acc.RecordTypeId;
            if(!oderList.isEmpty()){               
                for(order ord : oderList ){
                    //accRecordTypeId = ord.Account.RecordTypeId;
                    Decimal Discount = 0;
                    Decimal TotalDiscountPrice = 0;
                    Decimal TotalExtendedDiscount= 0;
                    
                    system.debug('B2BDarleyDollars__c := '+ord.B2BDarleyDollars__c);
                    system.debug('TotalUnitPrice__c := '+ord.TotalUnitPrice__c);
                    
                    if(ord.B2BDarleyDollars__c != null && (ord.TotalUnitPrice__c != null && ord.TotalUnitPrice__c != 0) ){
                        //SubTotal is TotalUnitPrice__c
                        Discount = ((ord.TotalUnitPrice__c + ord.B2BDarleyDollars__c)/ord.TotalUnitPrice__c);
                    }
                    
                    system.debug('Discount Calculated := '+Discount);
                    
                    wrapperObj.Customer_PO= '';
                    wrapperObj.Freight_Code= 'DES';
                    wrapperObj.Zone_Number='';             
                    wrapperObj.SalesForce_Order_Number = ord.OrderNumber;
                    
                    wrapperObj.account_id = ord.AccountId;
                    wrapperObj.Business_Unit = ord.Account.Primary_Division__c;

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
                    
                    wrapperObj.Billing_city = ord.billingCity;
                    wrapperObj.Billing_State = ord.billingState;
                    wrapperObj.Billing_postalCode = ord.billingPostalCode ;
                    wrapperObj.Billing_country = ord.billingCountry;
                    wrapperObj.Billing_Address1 = ord.billingStreet;
                    wrapperObj.Shipping_Address1 = ord.ShippingStreet;
                    wrapperObj.Shipping_city = ord.ShippingCity;
                    wrapperObj.Shipping_State = ord.ShippingState;
                    wrapperObj.Shipping_postalCode = ord.ShippingPostalCode ;
                    wrapperObj.Shipping_country = ord.ShippingCountry;
                    
                    if(newList.size()>0){
                        for(OrderItem oi :newList ){
                            SalesOrderWrapper.OrderItems orderDet = new SalesOrderWrapper.OrderItems();
                            //This will execute if Darley Dollar field have Null value and ProductCode is not Frieght.   
                            if(oi.OrderId == ord.Id && productCodeMap.containsKey(oi.Product2Id) && productCodeMap.get(oi.Product2Id) != 'Freight' && ord.B2BDarleyDollars__c == null){
                                Decimal NonFreightExtPrice = oi.UnitPrice * oi.Quantity;
                                orderDet.Quantity = String.valueOf(oi.Quantity);
                                orderDet.Item_Number = productCodeMap.get(oi.Product2Id);
                                orderDet.Line_Number = string.valueOf(oi.LineNumber);
                                orderDet.Unit_Price = string.valueOf(oi.UnitPrice);
                                orderDet.Extended_Price = string.valueOf(NonFreightExtPrice);
                                orderDet.Discount_Price = string.valueOf(NonFreightExtPrice);
                                
                                orderDetList.add(orderDet);
                            }
                            
                            //This will execute if Darley Dollar field have value other than 0 and ProductCode is not Frieght.  
                            else if(oi.OrderId == ord.Id && productCodeMap.containsKey(oi.Product2Id) && productCodeMap.get(oi.Product2Id) != 'Freight' && ord.B2BDarleyDollars__c != null){
                                Decimal ExtendedPrice = oi.UnitPrice * oi.Quantity;
                                Decimal DiscountPrice = (ExtendedPrice * Discount).setScale(2, RoundingMode.HALF_UP);
                                Decimal ExtendedDiscount = ExtendedPrice-DiscountPrice;
                                
                                TotalDiscountPrice = TotalDiscountPrice + DiscountPrice;
                                TotalExtendedDiscount = TotalExtendedDiscount + ExtendedDiscount;
                                
                                orderDet.Quantity = String.valueOf(oi.Quantity);
                                orderDet.Item_Number = productCodeMap.get(oi.Product2Id);
                                orderDet.Line_Number = string.valueOf(oi.LineNumber);
                                orderDet.Unit_Price = string.valueOf(oi.UnitPrice);
                                orderDet.Extended_Price = string.valueOf(ExtendedPrice);
                                orderDet.Discount_Price = string.valueOf(DiscountPrice);
                                orderDet.Extended_Discount = string.valueOf(ExtendedDiscount);
                                
                                system.debug('#Line: '+oi.LineNumber+', Product Code: '+productCodeMap.get(oi.Product2Id)+', UnitPrice: '+oi.UnitPrice+', Quantity: '+oi.Quantity+', Extended Price: '+ExtendedPrice+', Discount Price: '+DiscountPrice+', Extended-Discount: '+ExtendedDiscount);
                                orderDetList.add(orderDet);
                            }
                            
                            //This will execute if Darley Dollar field have value other than 0 and ProductCode is Frieght.
                            else if(oi.OrderId == ord.Id && productCodeMap.containsKey(oi.Product2Id) && productCodeMap.get(oi.Product2Id) == 'Freight'){
                                Decimal FreightExtendedPrice = oi.UnitPrice * oi.Quantity;
                                orderDet.Quantity = String.valueOf(oi.Quantity);
                                orderDet.Item_Number = productCodeMap.get(oi.Product2Id);
                                orderDet.Line_Number = string.valueOf(oi.LineNumber);
                                orderDet.Unit_Price = string.valueOf(oi.UnitPrice);
                                orderDet.Extended_Price = string.valueOf(FreightExtendedPrice);
                                orderDet.Discount_Price = string.valueOf(FreightExtendedPrice);
                                
                                orderDetList.add(orderDet);
                            }
                            
                            system.debug('Product Code: '+productCodeMap.get(oi.Product2Id)+', Calculated UnitPrice := '+orderDet.Unit_Price);
                        }
                    }
                    if(ord.B2BDarleyDollars__c != null){
                        system.debug('TotalDiscountPrice: '+TotalDiscountPrice+', SubTotal-DarleyDollar: '+(ord.TotalUnitPrice__c + ord.B2BDarleyDollars__c));
                        system.debug('TotalExtendedDiscount: '+TotalExtendedDiscount+', Darley Dollar: '+ord.B2BDarleyDollars__c);
                    }        
                }
            }
            
            wrapperObj.OrderDetail = orderDetList;
            
            // convert the list of wrapper objects to a JSON string
            String jsonStr = JSON.serialize(wrapperObj).replace('_', ' ');
            String jsonSt = jsonStr.replace('null', '""');
            system.debug('JSON String:= '+jsonSt);
            System.debug('accRecordTypeId'+accRecordTypeId);
            
            //Creating New Order with orderLineItems in JDE.
            if(!oderList.isEmpty()){
                if(oderList[0].JDE_Order_Number__c == null && accRecordTypeId == EquipmentCustomer && acc.Sync_with_JDE__c == true){
                    system.debug('JDE_Order_Number__c: '+oderList[0].JDE_Order_Number__c);
                    CalloutToRestOrderItem.makeCalloutSalesOrder(jsonSt, 'Order Product', 'Order Item Insert');
                }
                
                
                //Updating OrderlineItem in JDE for existing order.
                if(oderList[0].JDE_Order_Number__c != null && accRecordTypeId == EquipmentCustomer){
                    SalesOrderWrapper.updateNewLineItem wrapObj = new SalesOrderWrapper.updateNewLineItem();
                    List<SalesOrderWrapper.Order_Detail> order_DetList = new List<SalesOrderWrapper.Order_Detail>();
                    
                    wrapObj.Order_Number = string.valueOf(oderList[0].JDE_Order_Number__c);
                    wrapObj.Order_Type = 'S5';
                    if(newList.size()>0){
                        for(OrderItem oli :newList ){
                            if(productCodeMap.containsKey(oli.Product2Id)){
                                SalesOrderWrapper.Order_Detail order_Det = new SalesOrderWrapper.Order_Detail();
                                order_Det.quantity = String.valueOf(oli.Quantity);
                                order_Det.Item_Number= productCodeMap.get(oli.Product2Id);
                                order_Det.Unit_Price = String.valueOf(oli.UnitPrice);
                                order_Det.Line_Number = string.valueOf(oli.LineNumber);
                                order_DetList.add(order_Det);
                            }
                        }
                    }
                    
                    wrapObj.Order_Detail = order_DetList;
                    
                    String jsonStr1 = JSON.serialize(wrapObj).replace('_', ' ');
                    String jsonStr2 = jsonStr1.replace('null', '""');
                    system.debug('JSON String2:= '+jsonStr2);
                    
                    CalloutToRestOrderItem.makeUpdateCallout(jsonStr2, 'Order Product', 'OrderItem Update');              
                } 
            }          
        }
    }
    
    //For quantityChange update in order product
    public static void handleAfterUpdate(List<OrderItem> newList){
        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;   
        if(profileName != 'Salesforce API Only System Integrations'){ 
            
            SalesOrderWrapper.updateOrderQtyDetail ordUpd = new SalesOrderWrapper.updateOrderQtyDetail();
            Set<Id> orderId = new Set<Id>();
            Set<Id> productId = new Set<Id>();
            
            //loop on orderItem to get orderId and ProductId
            if(newList.size()>0){
                for(OrderItem od : newList){
                    orderId.add(od.orderId);
                    productId.add(od.Product2Id);
                }
            }
            
            List<Product2> prodList = [Select id, productCode, JDE_Part_Number__c from Product2 where id in:productId ];
            List<order> ordList = [Select id, JDE_Order_Number__c, Account.RecordTypeId from order where id in:orderId ];
            Map<Id, String> productCodeMap = new map<Id,String>();
            Map<Id, String> jdeOrdNumMap = new map<Id,String>();
            
            if(!prodList.isEmpty()){
                for(product2 pro : prodList){
                    productCodeMap.put(pro.id, pro.ProductCode); 
                }
            }
            
            String accRecordTypeId;
            if(!ordList.isEmpty()){
                for(order ord : ordList){
                    jdeOrdNumMap.put(ord.id, string.valueOf(ord.JDE_Order_Number__c)); 
                    accRecordTypeId = ord.Account.RecordTypeId;
                }
            }
            
            if(!newList.isEmpty()){
                for(orderItem oli : newList){
                    ordUpd.Quantity_Ordered = String.valueOf(oli.Quantity) ;
                    ordUpd.Item_Number = productCodeMap.get(oli.Product2Id);
                    ordUpd.Order_Number = jdeOrdNumMap.get(oli.OrderId);
                    ordUpd.Line_Number = string.valueOf(oli.LineNumber);
                    ordUpd.Order_Type = 'S5';
                }
            }
            
            String jsonStr = JSON.serialize(ordUpd).replace('_', ' ');
            String jsonStr1 = jsonStr.replace('null','""');
            system.debug('JSON String:= '+jsonStr1);
            
            String EquipmentCustomer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Equipment Customer').getRecordTypeId();
            if(!ordList.isEmpty()){
                if(ordList[0].JDE_Order_Number__c != null && accRecordTypeId == EquipmentCustomer){
                    CalloutToRestOrderItem.makeUpdateCallout(jsonStr1, 'Order Product', 'OrderItem Quantity Change');
                }
            }
            
        }
    }
    
    //If orderline item is deleted.
    public static void handleAfterDelete(List<OrderItem> oldList){
        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        
        if(profileName != 'Salesforce API Only System Integrations'){ 
            
            SalesOrderWrapper.updateOrderQtyDetail ordUpd = new SalesOrderWrapper.updateOrderQtyDetail();
            Set<Id> orderId = new Set<Id>();
            Set<Id> productId = new Set<Id>();
            
            if(oldList.size()>0){
                for(OrderItem od : oldList){
                    orderId.add(od.orderId);
                    productId.add(od.Product2Id);
                }
            }
            
            List<order> ordList = [Select id, JDE_Order_Number__c, Account.recordTypeId from order where id in:orderId ];
            List<Product2> prodList = [Select id, productCode, JDE_Part_Number__c from Product2 where id in:productId ];
            Map<Id, String> productCodeMap = new map<Id,String>();
            Map<Id, String> jdeOrdNumMap = new map<Id,String>();
            if(!prodList.isEmpty()){
                for(product2 pro : prodList){
                    productCodeMap.put(pro.id, pro.ProductCode); 
                } 
            }
            string accRecordTypeId;
            if(!ordList.isEmpty()){
                for(order ord : ordList){
                    jdeOrdNumMap.put(ord.id, string.valueOf(ord.JDE_Order_Number__c)); 
                    accRecordTypeId = ord.Account.recordTypeId;
                }
            }
            
            if(!oldList.isEmpty()){
                for(orderItem oli : oldList){
                    ordUpd.Quantity_Ordered = '0' ;
                    ordUpd.Item_Number = productCodeMap.get(oli.Product2Id);
                    ordUpd.Order_Number = jdeOrdNumMap.get(oli.OrderId);
                    ordUpd.Line_Number = string.valueOf(oli.LineNumber);
                    ordUpd.Order_Type = 'S5';
                }
            }
            
            String jsonStr = JSON.serialize(ordUpd).replace('_', ' ');
            String jsonStr1 = jsonStr.replace('null','""');
            system.debug('JSON String:= '+jsonStr1);
            
            String EquipmentCustomer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Equipment Customer').getRecordTypeId();
            if(!ordList.isEmpty()){
                if(ordList[0].JDE_Order_Number__c != null && accRecordTypeId == EquipmentCustomer){
                    CalloutToRestOrderItem.makeUpdateCallout(jsonStr1, 'Order Product', 'OrderItem Delete');
                }  
            }
        }
    }     
}