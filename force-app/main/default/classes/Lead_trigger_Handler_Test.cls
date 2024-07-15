/******************************************************************************************************************************************************
Name                    : Lead_trigger_Handler_Test
Author                  : Melonleaf
Purpose                 : This method is written to test the data.

Version                 : 1.0
Change Log              : 
Test Class  for         : Lead_trigger_Handler
CreateDate              : 25-05-2024
LastModifiedDate        : 25-05-2024
******************************************************************************************************************************************************/

@isTest
public class Lead_trigger_Handler_Test {
    @isTest
    public static  void whentheEmailAreAddtotheEmailfieldTest(){
   
         Account acc=new Account();
        acc.Name='Test Account';
        insert acc;
        
         Id recordTypeIdd = Schema.SObjectType.Bid_Tracker__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();

         Bid_Tracker__c BidTracker = new Bid_Tracker__c();
         BidTracker.name='test Name';
        BidTracker.RecordTypeId=recordTypeIdd;
        insert BidTracker;
         
        Id recodTyprIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Supply Partner Application').getRecordTypeId();

        Lead ledvar = new Lead();
        ledvar.lastName= 'Supplier Name';
        ledvar.RecordTypeId=recodTyprIdLead;
        ledvar.Company	='Supplier Name';
       // ledvar.Email_Address__c='test@gmail.com';
        
        insert ledvar;
        
        
       
         Bid_Line_Item__c bl = new Bid_Line_Item__c();
         bl.RFQ_Number__c=BidTracker.id;
        bl.Bid_Supplier__c=acc.Id;
        Id recordTypeIdBidLine = Schema.SObjectType.Bid_Line_Item__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
        bl.Name='Testing';
        bl.Regular_vs_Alternative__c='Regular';
        bl.Supplier_Part_Number__c='7484784';
        bl.Weeks_ARO__c='3D';
        bl.TLSP_Supplier_Extension__c='WSD';
        bl.Load_Batch_Number__c='2353';
        bl.Due_Date__c=DateTime.now().addDays(25);
        bl.RecordTypeId=recordTypeIdBidLine;
        bl.Supplier_Part_Number__c='VR-FST-1';	
        bl.Quote_Numbers__c='test value';
        bl.Due_Date__c=system.today().addDays(5);
        bl.Quote_Type__c='Quoted';
        bl.Item_Description__c='bundle';
        bl.Status__c='RFQ Ready for DLA';
        bl.Lead__c=ledvar.Id;
        
        
        
       insert bl;
        
        
         
        Blob b = Blob.valueOf('Test Data');
    	Attachment attachment = new Attachment();
    	attachment.ParentId = BidTracker.Id;
    	attachment.Name = 'Supplier Name_test value.pdf';
    	attachment.Body = b;
    	insert attachment;
        map<attachment,Bid_Line_Item__c> abcdmap = new map<attachment,Bid_Line_Item__c>();
       abcdmap.put(attachment,bl);
        
         ledvar.Email_Address__c='Testemail@gmail.com';
        
        Test.startTest();
        update ledvar;
        Lead_trigger_Handler.sendEmailTotheSupplierWithAttachMent(abcdmap);
        Test.stopTest();
        
        
    }
        
 
    @isTest
    public static void linkAccountTOXLTAfterConveertTest(){
     
     Id recodTyprIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Supply Partner Application').getRecordTypeId();

        Lead ledvar = new Lead();
        ledvar.lastName= 'Supplier Name';
        ledvar.RecordTypeId=recodTyprIdLead;
        ledvar.Company	='Supplier Name';
        ledvar.Email_Address__c='testold@gmail.com';
        ledvar.Status='New';
        insert ledvar;
        
        
        Supplier_XLAT__c supp=new Supplier_XLAT__c();
        supp.Child__c='test Child';
        supp.Name='test Parent';
        supp.Lead__c=ledvar.Id;
        insert supp;
        
        
       // ledvar.Email_Address__c='Testemail@gmail.com';
           Database.LeadConvert lc1 = new database.LeadConvert();
lc1.setLeadId(ledvar.id);
lc1.setDoNotCreateOpportunity(true);
lc1.setConvertedStatus('Converted');

Database.LeadConvertResult lcr1 = Database.convertLead(lc1,false);
   supp.Account__c=ledvar.ConvertedAccountId;
        update supp;
       
        
    }
         
        
        
    }