/******************************************************************************************************************************************************
Name                    : AccountWrapper
Author                  : Pratik Kakade
Purpose                 : This Apex class provides a wrapper for Account records, facilitating the handling of address fields and other related data.
Description             : The AccountWrapper class is designed to streamline the processing of Account records, particularly focusing on managing address 
                          fields. It offers methods to dynamically set billing and shipping address fields based on input address parts, allowing for easy 
                          manipulation and organization of address information. This class can be utilized within Account trigger handlers or other Apex 
                          classes that require structured handling of Account data.
Version                 : 1.2
Change Log              : Modified by Pratik Kakade on 26 Feb 2024.
Test Class for          : UpdatePriceBookWebService
CreateDate              : 1 Sept 2023
LastModifiedDate        : 26 Feb 2024
******************************************************************************************************************************************************/

public class AccountWrapper {
    public String Alpha_Name { get; set; }
    public String Business_Unit { get; set; }
    public String Billing_Address_1 { get; set; }
    public String Billing_Address_2 { get; set; }
    public String Billing_Address_3 { get; set; }
    public String Billing_Address_4 { get; set; }
    public String Billing_City { get; set; }
    public String Billing_State { get; set; }
    public String Billing_Country {get; set;}
    public String Billing_Postal_Code { get; set; }
    public String Division { get; set; }
    public String DOM_or_EXP { get; set; }
    public String Customer_Type { get; set; }
    public String Equipment_Customer_Type { get; set; }
    public String Phone_Number { get; set; }
    public String Electronic_Address_Type { get; set; }
    public String Electronic_Address { get; set; }
    public String Contact_Information { get; set; }
    public String Payment_Terms { get; set; }
    public String Account_id {get; set;}
    public String Shipping_Address_1 { get; set; }
    public String Shipping_Address_2 { get; set; }
    public String Shipping_Address_3 { get; set; }
    public String Shipping_Address_4 { get; set; }
    public String Shipping_City { get; set; }
    public String Shipping_State { get; set; }
    public String Shipping_Country { get; set; }   
   	public String Shipping_Postal_Code { get; set; }
    public String Customer_Price_Group {get; set;}
   	public String Adjustment_Schedule {get; set;}
    public String Credit_Limit {get; set;}
    public String Address_Number {get; set;}
    
    public AccountWrapper() {}

      // Method to set address fields dynamically
      public void setAddressFields(String type, List<String> addressParts) {
        if (type == 'Billing') {
            this.Billing_Address_1 = addressParts.size() > 0 ? addressParts[0] : '';
            this.Billing_Address_2 = addressParts.size() > 1 ? addressParts[1] : '';
            this.Billing_Address_3 = addressParts.size() > 2 ? addressParts[2] : '';
            this.Billing_Address_4 = addressParts.size() > 3 ? addressParts[3] : '';
        } else if (type == 'Shipping') {
            this.Shipping_Address_1 = addressParts.size() > 0 ? addressParts[0] : '';
            this.Shipping_Address_2 = addressParts.size() > 1 ? addressParts[1] : '';
            this.Shipping_Address_3 = addressParts.size() > 2 ? addressParts[2] : '';
            this.Shipping_Address_4 = addressParts.size() > 3 ? addressParts[3] : '';
        }
    }
    
}