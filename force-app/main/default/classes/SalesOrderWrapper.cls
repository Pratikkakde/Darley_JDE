public class SalesOrderWrapper {
    
   /*SalesOrderWrapper is used for New/Fresh Order creation in salesforce*/     
    //public String branchPlant;
    //public String soldTo;
    //public String shipTo;
    //public String requestedDate;
    //public String customerPhone;
    //public String mailingName;
    //public String county;
    //public String customer;
    public String Customer_PO{get;set;} 
    public String Freight_Code{get;set;} 
    public String Zone_Number{get;set;} 
    
    public String Shipping_Address1;
    //public String Shipping_Address2;
    //public String Shipping_Address3;
    //public String Shipping_Address4;
    public String Shipping_City;
    public String Shipping_State;
    public String Shipping_PostalCode;
    public String Shipping_country;
    public String Billing_Address1;
    //public String Billing_address2;
    //public String Billing_address3;
    //public String Billing_address4;
    public String Billing_City;
    public String Billing_State;
    public String Billing_PostalCode;
    public String Billing_Country; 
    
    /*Account data associated with Order*/
    public String Account_id{get;set;} 
    public String Customer_Name {get;set;} 
    public String Business_Unit{get;set;}
    public String SalesForce_Order_Number{get;set;}
    public String Address_Number{get;set;}
    public String Payment_Terms{get;set;}
    public String Payment_Instrument{get;set;}
    public List<OrderItems> OrderDetail {get; set;}
    
    public class OrderItems {
        public String Quantity{get;set;} 
        public String Item_Number{get;set;} 
        public String Unit_Price{get;set;}
        public string Line_Number{get;set;} 
        Public String Extended_Price;
        Public String Discount_Price;
        Public String Extended_Discount;
    }
    
     /*SalesOrderWrapper.updateOrderQtyDetail is used when orderItem quantity is updated in salesforce*/ 
    public class updateOrderQtyDetail {
        public String Order_Number{get;set;} 
        public String Order_Type{get;set;} 
        public String Item_Number{get;set;} 
        public string Line_Number{get;set;}
        public String Quantity_Ordered{get;set;}
    }
   
    /*SalesOrderWrapper.updateNewLineItem is used when new orderItem is added/updated for existing order in salesforce*/ 
    public class updateNewLineItem {
        public String Order_Number{get;set;} 
        public String Order_Type{get;set;} 
        public List<Order_Detail> Order_Detail {get; set;}
    }  
    public class Order_Detail {
        public String Quantity{get;set;}
        public String Unit_Price{get;set;}
        public String Item_Number{get;set;} 
        public string Line_Number{get;set;}
    }
    
    /*SalesOrderWrapper.update_Address is used when billing and shipping address is updated existing order in salesforce*/ 
    public class update_Address {
        public String Shipping_Address;
        //public String Shipping_Address2;
        //public String Shipping_Address3;
        //public String Shipping_Address4;
        public String Shipping_City;
        public String Shipping_State;
        public String Shipping_PostalCode;
        public String Shipping_country;
        public String Billing_Address;
        //public String Billing_address2;
        //public String Billing_address3;
        //public String Billing_address4;
        public String Billing_City;
        public String Billing_State;
        public String Billing_PostalCode;
        public String Billing_Country;
        public String Order_Number{get;set;}
        public String Order_Type{get;set;} 
    }
    
    public class creditCardDetail {
        public String orderNumber;
        public String SFAmount;
        public String SFCCNumber;
        public String SFCustomerName;
        public String SFCardName;
        public String SFAuthCode;
        public String SFAuthID;
    }
   
}