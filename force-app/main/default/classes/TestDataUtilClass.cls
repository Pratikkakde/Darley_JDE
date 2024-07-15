// this Class is created for the Data use in the test class 
@isTest
public class TestDataUtilClass {
     @istest
    public static Account returnAccountRec(){
        // Specify the object and field API name for which you want to get picklist values
       
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
            Account acc = new Account( 
                Name = 'Supplier Name ',
                Supplier_Rating__c='A+: Strategic Supplier',	
                Email_Address_for_RFQ__c='abc123@gmail.com',
              //  PDF_Creation__c =true,
                RecordTypeId=recordTypeId
            );
            
            Return acc;
        }
    
    public static attachment addAttachmentToParent(Id parentId) {
        // Build page reference for contract PDF & attach to the contract record		

    
    	Blob b = Blob.valueOf('Test Data');
    	Attachment attachment = new Attachment();
    	attachment.ParentId = parentId; 
    	attachment.Name = 'Supplier Name ';
    	attachment.Body = b;
    	
    	return attachment;
        
      
    }
     @istest
    public static Bid_Line_Item__c getBidLineItem(){
        Id recordTypeId = Schema.SObjectType.Bid_Line_Item__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
        Bid_Line_Item__c bl = new Bid_Line_Item__c();
        bl.Name='Testing';
        bl.Regular_vs_Alternative__c='Regular';
        bl.Supplier_Part_Number__c='7484784';
        bl.TLSP_Supplier_Extension__c='WSD';
        bl.Load_Batch_Number__c='2353';
        bl.Due_Date__c=DateTime.now().addDays(25);
        bl.RecordTypeId=recordTypeId;
        bl.Supplier_Part_Number__c='VR-FST-1';	
        bl.Quote_Numbers__c='';
        bl.Due_Date__c=system.today().addDays(5);
        bl.Quote_Type__c='Quoted';
        bl.Item_Description__c='bundle';
        bl.Status__c='RFQ Ready for DLA';
        bl.Unit_Cost__c=2800;
        bl.Margin_Percent__c=16;
        bl.Country_of_Origin__c='United States';
     	bl.Weeks_ARO__c='3D';
        bl.Payment_Terms__c='60% PREPAY';
        bl.Comments__c='Supplier is requiring advance payment and does not pass Darley&#39;s due diligence assessment.';
        bl.ServiceNow_State__c ='WASHINGTON';
        bl.Berry_Applies__c='Yes';
        bl.Country__c='United States';
       
     return bl;        
    }
     @istest
    public static Bid_Tracker__c getBidTracker(){
        Id recordTypeId = Schema.SObjectType.Bid_Tracker__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();

        Bid_Tracker__c BidTracker = new Bid_Tracker__c(
            name='RFQRFQ202311150001729',
            RecordTypeId=recordTypeId,
            CPQ_Quote_Number__c='Q-10902',
            Due_Date__c=DateTime.now().addDays(25),
            Record_Source__c='ServiceNow',
            ServiceNow_Communication_CreatedDate__c='2024-05-12'
        );
        
        return BidTracker;
    }
     @istest
    public static Bid_Group_Items__c getBidGroupItem(){
		Bid_Group_Items__c bidgrp = new Bid_Group_Items__c();
        bidgrp.Name = 'Ozarka';
        bidgrp.Margin__c = 20;
        bidgrp.CPQ_Shipping_Total_from_mfg__c = 500;
        bidgrp.Total_Cost__c=2500;
        return bidgrp;

}
   @istest
    public static Lead getLeadRecord(){
        Id recodTyprIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Supply Partner Application').getRecordTypeId();

        Lead ledvar = new Lead();
        ledvar.lastName= 'Supplier Name';
        ledvar.RecordTypeId=recodTyprIdLead;
        ledvar.Company	='Supplier Name';
        return ledvar;
    }
     @istest
    public static User getUser() {
        // Create a new user
        User newUser = new User(
            FirstName = 'John',
            LastName = 'Wick',
            Email = 'john.Wick@example.com',
            Username = 'john.Wick@example.com',
            Alias = 'jdoe',
            CommunityNickname = 'jdoe',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/New_York'
        );
        return newUser;
    }
    public static Pricing_Matrix__c getPricingMatrix(){
        
        Tier__c tc = new Tier__c();
        tc.Name='test Name';
        tc.Tier_del__c='test tier del';
        tc.Contract_Type__c ='TLS SOE';
        insert tc;
		system.debug('tc id : '+tc.Id);
        
        Pricing_Matrix__c pricMatVar = new Pricing_Matrix__c(
            Name=  'Tier 1',
            Tier__c= tc.Id,
            Cost_High_End__c=5000.00,
            Cost_Low_End__c=1000.00,
            Effective_Date_From__c=system.today()-10,
            Effective_Date_Thru__c=system.today()+10
          
        );
        return pricMatVar;
    }
    
    
    public static List<Bid_Workbench__c> createBidWorkbenchRecords(Integer count) {
        List<Bid_Workbench__c> records = new List<Bid_Workbench__c>();
        for (Integer i = 0; i < count; i++) {
            Bid_Workbench__c record = new Bid_Workbench__c(
                Record_Source__c = 'CSV',
                Alternate_Manufacturer_Name__c = 'Test Manufacturer',
                Alternate_Manufacturer_Part_Number__c = '123',
                FOB_Origin__c = 'N',
                RFID_Required__c = 'Y',
                Customer_Permits_Alternates__c = 'N',
                TLSP_Vendor_Extension__c = 'DAR',
                ServiceNow_RFQ_Program__c='some'
            );
            records.add(record);
        }
        return records;
    }
    
     @istest
    public static Bid_Workbench__c createBidWorkbenchRecordWithFOBOriginY() {
        Bid_Workbench__c record = new Bid_Workbench__c(
            Record_Source__c = 'CSV',
            Alternate_Manufacturer_Name__c = 'Test Manufacturer',
            Alternate_Manufacturer_Part_Number__c = '123',
            FOB_Origin__c = 'Y',
            RFID_Required__c = 'N',
            Manufacturer_Name__c='test manufacture',
            Customer_Permits_Alternates__c = 'Y',
            TLSP_Vendor_Extension__c = 'WSD',
            ServiceNow_RFQ_Program__c='',
            Order_Item_ID__c='OLN123',
            Processed__c=true,
            Quantity__c=7,
            ShipTo_DODAAC__c='DODAAC1'
            
            
        );  
        
        return record;
    }
    public static List<Bid_Workbench__c> createBidWorkbenchRecordsForLineItemCount(Integer count) {
    List<Bid_Workbench__c> records = new List<Bid_Workbench__c>();
    for (Integer i = 0; i < count; i++) {
        Bid_Workbench__c record = new Bid_Workbench__c(
            Record_Source__c = 'CSV',
            Alternate_Manufacturer_Name__c = 'Test Manufacturer',
            Alternate_Manufacturer_Part_Number__c = '123',
            FOB_Origin__c = 'N',
            RFID_Required__c = 'Y',
            Customer_Permits_Alternates__c = 'N',
            TLSP_Vendor_Extension__c = 'DAR',
            Quote_Number__c = 'TestQuoteNumber'
        );
        records.add(record);
    }
    return records;
	}

}