public class OrderWrapper {
    public List<OrderInfo> orders;
    
    public class OrderInfo {
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
        public String Business_Unit{get;set;}
        public String SalesForce_Order_Number{get;set;}
        public String Address_Number{get;set;}
        public String Payment_Terms{get;set;}
        public String Payment_Instrument{get;set;}
        public List<OrderItemInfo> OrderItems;
        
      
    }
    
    public class OrderItemInfo {
        
        public String Quantity{get;set;} 
        public String Item_Number{get;set;} 
        public String Unit_Price{get;set;}
        public string Line_Number{get;set;}
        public String Branch_Plant{get;set;}
    }
}