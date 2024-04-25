/*******************************************************************************************************************************************************************************************************************************
Name                : Utility_DataCreation
Author              : Pratik Kakade
Purpose             : This Apex class serves as a utility for creating test data. It includes methods to create account records, generate JSON data, and create order records associated with accounts.
Description         : This class contains methods to facilitate the creation of test data for various scenarios. It includes methods to create account records with specific attributes, generate JSON data for integration purposes, and create order records associated with accounts.
Version             : 1.1
Change Log          : Updated by Pratik Kakade on 19 Feb 2024
Test Class          : Utility_DataCreation_test
CreateDate          : 19 Feb 2024
LastModifiedDate    : 19 Feb 2024
*******************************************************************************************************************************************************************************************************************************/

public class Utility_DataCreation {
    
    /**
* Method        : CreateAccountRec
* Purpose       : Creates a specified number of Account records with the given record type.
* Parameters    :- numRecord: The number of account records to create
*                - recTyp: The record type of the accounts to be created
* Returns       :- List<Account>: The list of created account records
*/
    public static List<Account> CreateAccountRec(Integer numRecord, String recTyp) {
        // Retrieve the record type ID based on the provided record type name
        String recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recTyp).getRecordTypeId();
        
        // Initialize a list to store the created account records
        List<Account> accList = new List<Account>();
        
        // Iterate to create the specified number of account records
        for (Integer i = 0; i < numRecord; i++) {
            Account acc = new Account (
                Name = 'Test12' + i,
                Primary_Division__c = 'Equipment',
                BillingStreet = '77 NARROW STREET',
                BillingCity = 'HOUSTON',
                BillingState = 'Texas',
                BillingPostalCode = '77084',
                ShippingStreet = '123 Broad Street',
                ShippingCity = 'Austin',
                ShippingState = 'Texas',
                Customer_Distribution_Channel__c = 'Export',
                Primary_POC_Email__c = 'test@test.com',
                Phone = '7346498567',
                Payment_Terms2__c = 'Net 30',
                ShippingPostalCode = '77084',
                Adjustment_Schedule__c = 'Darley',
                Credit_Limit__c = 1, 
                Sync_with_JDE__c = true,
                RecordTypeId = recTypeId
            );
            accList.add(acc);
        }
        
        // Return the list of created account records
        return accList;
    }
    
    public static  List<Contact> createCotactAccoCiatedWithAccount(Integer numRec, String accId){
        List<Contact> conList = new List<Contact> ();
        for (Integer i = 0; i<numRec; i++) {
            Contact con = new Contact ();
            con.FirstName = 'Test';
            con.MiddleName = 'Test2';
            con.LastName = 'Test3';
            con.Title = 'Fire';
            con.MailingStreet = '123 Maple Street Apt 5A Anytown USA 12345 This cozy apartment features modern amenities and a convenient location Situated in a friendly neighborhood it\'s perfect for families or professionals With easy access to parks schools and shopping centers there\'s always something to do nearby Plus our spacious living area and well-equipped kitchen make it ideal for entertaining Don\'t miss out on this fantastic opportunity to call this place home';
            con.MailingCity = 'Houston';
            con.MailingState = 'Texas';
            con.MailingCountry = 'United States';
            con.MailingPostalCode = '553881';
            con.accountId  = accId;
            conList.add(con);
        }
        return conList ; 
    }
    
    public static  List<Product2>  CreteProducts (integer numRec){
        
        List<Product2> productsList = new List<Product2> ();
        for (Integer i = 0; i<numRec; i++) {
            Product2  prd = new Product2();
            prd.Name = 'Test Product'+i;
            prd.JDE_Part_Number__c = 'AF032';
            prd.ProductCode = 'AF032';
            prd.isActive=true;
            
            productsList.add(prd);
        }
        
        return productsList;
    }
    public static  List<Product2>  CreteProducts2 (integer numRec){
        
        List<Product2> productsList = new List<Product2> ();
        for (Integer i = 0; i<numRec; i++) {
            Product2  prd = new Product2();
            prd.Name = 'Test Product'+i;
            prd.JDE_Part_Number__c = 'Freight';
            prd.ProductCode = 'Freight';
            prd.isActive=true;
            
            productsList.add(prd);
        }
        
        return productsList;
    }
    /**
* Method         : createJsonData
* Purpose        : Creates JSON data for integration purposes based on the provided account ID.
* Parameters     : accId: The ID of the account for which JSON data is to be generated
* Returns        : Map<String, Object>: The generated JSON data as a map
*/
    public static Map<String, Object> createJsonData(String accId) {
        // Initialize a map to store the JSON data
        Map<String, Object> requestData = new Map<String, Object>{
            'Alpha Name' => 'Test Account 123456',
                'Business Unit' => 'Equipment',
                'DOM or EXP' => '*Blanks',
                'Address Number' => 456,
                'Address Line 1' => '1100 VAN NESS AVENUE',
                'Postal Code' => '94109',
                'Electronic Address' => 'updated@email.com',
                'Phone Number' => '987-654-3210',
                'Payment Terms' => 'NET 30',
                'Credit Limit' => 15000,
                'Account id' => accId,
                'Customer Price Group' => '*Blanks',
                'Adjustment Schedule' => '*Blanks',
                'Customer Type' => '*Blanks'
                };
                    
                    // Return the generated JSON data
                    return requestData;
    }
    
    /**
* Method         : createSameJsonData
* Purpose        : Creates JSON data with the same attributes for integration purposes based on the provided account ID.
* Parameters     : accId: The ID of the account for which JSON data is to be generated
* Returns        : Map<String, Object>: The generated JSON data as a map
*/
    public static Map<String, Object> createSameJsonData(String accId) {
        // Initialize a map to store the JSON data
        Map<String, Object> requestData = new Map<String, Object>{
            'Alpha Name' => 'Test120',
                'Business Unit' => 'Apparatus',
                'DOM or EXP' => 'Export',
                'Address Number' => 456,
                'Address Line 1' => '77 NARROW STREET',
                'Postal Code' => '77084',
                'Electronic Address' => 'test@test.com',
                'Phone Number' => '7346498567',
                'Payment Terms' => 'Net 30',
                'Credit Limit' => 1,
                'Account id' => accId,
                'Customer Price Group' => '*Blanks',
                'Adjustment Schedule' => 'Darley',
                'Customer Type' => '*Blanks'
                };
                    
                    // Return the generated JSON data
                    return requestData;
    }
    
    /**
* Method          : createOrder
* Purpose         : Creates a specified number of Order records associated with the provided account ID.
* Parameters      : accId: The ID of the account for which order records are to be created
*                   numRecords: The number of order records to create
* Returns         : List<Order>: The list of created order records
*/
    public static List<Order> createOrder(String accId, Integer numRecords, String pbId) {
        // Initialize a list to store the created order records
        List<Order> orderList = new List<Order>();
        
        // Iterate to create the specified number of order records
        for (Integer i = 0; i < numRecords; i++) {
            Order od = new Order();
            od.AccountId = accId;
            od.Status='draft';
            od.EffectiveDate=system.today();
            od.Pricebook2Id= pbId;
            od.BillingStreet ='123 park evenue';
            od.BillingCity = 'Houston';
            od.BillingState = 'Texas';
            od.BillingPostalCode = '12345';
            od.shippingstreet= '123 Grand Evenue';
            od.ShippingCity = 'Houston';
            od.ShippingState = 'Texas';
            od.ShippingPostalCode = '12345';
            od.Payment_Type__c = 'Amazon Pay';
            orderList.add(od);
        }
        
        // Return the list of created order records
        return orderList;
    }
    public static List<Order> createOrderwithDarleyDollers(String accId, Integer numRecords, String pbId) {
        // Initialize a list to store the created order records
        List<Order> orderList = new List<Order>();
        
        // Iterate to create the specified number of order records
        for (Integer i = 0; i < numRecords; i++) {
            Order od = new Order();
            od.AccountId = accId;
            od.Status='draft';
            od.EffectiveDate=system.today();
            od.Pricebook2Id= pbId;
            od.BillingStreet ='123 park evenue';
            od.BillingCity = 'Houston';
            od.BillingState = 'Texas';
            od.BillingPostalCode = '12345';
            od.shippingstreet= '123 Grand Evenue';
            od.ShippingCity = 'Houston';
            od.ShippingState = 'Texas';
            od.ShippingPostalCode = '12345';
            od.B2BDarleyDollars__c = 0;
            od.Payment_Type__c = 'Credit Card';
            orderList.add(od);
            
        }
        
        // Return the list of created order records
        return orderList;
    }
    public static List<orderitem> createOrderItem (Integer numRec, List<Order> odList, List<Product2> prdList, String pbEntryid){
        
        List<orderitem> ordItem = new List<orderitem>();
        for (Integer i = 0; i<numRec; i++) {
            orderitem oi = new orderitem();
            oi.OrderId = odList[i].id;
            oi.Product2Id = prdList[i].id;
            oi.Quantity = 2;
            oi.PricebookEntryId = pbEntryid;
            oi.UnitPrice = 234;
            ordItem.add(oi);
        }
        return ordItem;
        
    }
}