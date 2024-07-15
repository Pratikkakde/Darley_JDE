/******************************************************************************************************************************************************
Name                    : BidTrackerTrigger_Test
Author                  : Melonleaf
Version                 : 1.0
Change Log              : 
Test Class              : BidTrackerTrigger_handler
CreateDate              : 25-05-2024
LastModifiedDate        : 25-05-2024
******************************************************************************************************************************************************/

@istest
public class BidTrackerTrigger_Test {
    
    
    @isTest
    public static void BidTrackerTrigger_TestMethod(){
        
    
    Workbench_Parent__c wp=new Workbench_Parent__c();
    wp.Name='RFQTest Name';
    insert wp;
    
        String base64Content = 'YourBase64EncodedContent';

// Create a new ContentVersion object
ContentVersion cv = new ContentVersion();
cv.Title = 'YourFileTitle';
cv.PathOnClient = 'YourFileName.extension';
cv.VersionData = EncodingUtil.base64Decode(base64Content);
insert cv;
        
ContentVersion contentVersions = [SELECT Id, Title, ContentDocumentId FROM ContentVersion where title='YourFileTitle' limit 1];


    ContentDocumentLink cdl = new ContentDocumentLink();
cdl.LinkedEntityId = wp.id; // ID of the linked entity (e.g., a record ID)
cdl.ContentDocumentId = contentVersions.ContentDocumentId; // ID of the ContentDocument
cdl.ShareType = 'V'; // 'V' for Viewer, 'C' for Collaborator
cdl.Visibility = 'AllUsers'; // 'AllUsers' or 'InternalUsers'
insert cdl;
    
    
        
    Bid_Tracker__c bidtr=new Bid_Tracker__c();
    Id recordTypeId = Schema.SObjectType.Bid_Tracker__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
     
     bidtr.Name='Test Name';
     bidtr.Quote_Number__c='Test Quote Number'; 
     bidtr.RecordTypeId=recordTypeId;

     Test.startTest();
     insert bidtr;
        
     Test.stopTest();
        
      
   

    
   
    
    }
    @isTest
    public static void insertThefeedItemTest(){
     Bid_Tracker__c bidtr2=new Bid_Tracker__c();
    Id recordTypeIdd = Schema.SObjectType.Bid_Tracker__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
     
     bidtr2.Name='Test Name';
     bidtr2.Quote_Number__c='Test Quote Number'; 
     bidtr2.RecordTypeId=recordTypeIdd;
      bidtr2.Record_Source__c='ServiceNow';
     Test.startTest();
     insert bidtr2;
        
     Test.stopTest();
        
      List<FeedItem> insertedFeedItems = [SELECT Id, ParentId, Body FROM FeedItem];
      System.assertEquals(1, insertedFeedItems.size());
        
        
    }
    
    
    @isTest
    public static void NoSalesRepDrivenTest(){
    
         Bid_Tracker__c bidtr3 =new Bid_Tracker__c();
    Id recordTypeIddd = Schema.SObjectType.Bid_Tracker__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
             map<id,Bid_Tracker__c>oldMpa= new map<id,Bid_Tracker__c>();

     bidtr3.Name='Test Name';
     bidtr3.Quote_Number__c='Test Quote Number'; 
     bidtr3.RecordTypeId=recordTypeIddd;
     bidtr3.Sales_Rep_Driven__c=true;
     bidtr3.Due_Date__c=system.today()+2;
        
     insert bidtr3;
        oldMpa.put(bidtr3.id,bidtr3);
     
     Bid_Line_Item__c bl = new Bid_Line_Item__c();
        bl.RFQ_Number__c=bidtr3.id;
        bl.Name='Testing';
        bl.Regular_vs_Alternative__c='Regular';
        bl.Supplier_Part_Number__c='7484784';
        bl.Weeks_ARO__c='3D';
        bl.TLSP_Supplier_Extension__c='WSD';
        bl.Load_Batch_Number__c='2353';
        bl.Due_Date__c=DateTime.now().addDays(25);
        bl.Supplier_Part_Number__c='VR-FST-1';	
        bl.Due_Date__c=system.today().addDays(4);
        bl.Item_Description__c='bundle';
        bl.Status__c='RFQ Ready for DLA';
       // bl.Margin_Percent__c=0.75;
        bl.Payment_Terms__c='Net 10';
        bl.NO_Quote_Reason__c='Supplier F or X Rating';
        bl.Quote_Type__c='No Quote';
        bl.Status__c='SalesRep Claim';
        bl.Country__c='Test';
      //  bl.Bid_Group_Items__c=bidgrp3.Id;
        bl.Quote_Numbers__c='test Number';
      // bl.Sales_Rep__c=newUser.Id;
        bl.Unit_Cost__c=10.00;
        bl.Margin_Percent__c=0.75;
        //bl.Berry_Compliant__c='Yes';
        bl.Country_of_Origin__c='AD - Andorra';
       // bl.Weeks_ARO__c='testing value';
        bl.Comments__c='hi i am testing this field';
        bl.Payment_Terms__c='Net 10';
        insert bl;
        
        Bid_tracker__c biddd=new bid_tracker__C(id=bidtr3.id);
     biddd.Due_Date__c=system.today()+5;
     biddd.Sales_Rep_Driven__c=false; 
        
  list<Bid_Tracker__c> bidd= new list<Bid_Tracker__c>();
   bidd.add(biddd);
         update bidd;
     Test.startTest();
        BidTrackerTrigger_handler.NoSalesRepDriven(bidd,oldMpa);
        BidTrackerTrigger_handler.updateBidlineDueDate(bidd,oldMpa);
 Test.stopTest();
              

    }
    
    @isTest
    public static void updateFieldOnBidTrackerTest(){
        
        Bid_Tracker__c bidtr4=new Bid_Tracker__c();
    Id recordTypeIddd = Schema.SObjectType.Bid_Tracker__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
     
     bidtr4.Name='Test Name';
     bidtr4.Quote_Number__c='Test Quote Number'; 
     bidtr4.RecordTypeId=recordTypeIddd;
     bidtr4.Sales_Rep_Driven__c=true;
     insert bidtr4; 
        
       Workbench_parent__c wbp = new Workbench_parent__c();
        wbp.Name='RFQTest Quote Number';
        insert wbp;
        
        
      Account acc=new Account();
      acc.Name='Test Account';
      insert acc;
      
      Bid_Line_Item__c bl = new Bid_Line_Item__c();
        bl.RFQ_Number__c=bidtr4.id;
       // bl.Bid_Supplier__c=acc.Id;
        bl.Name='Testing';
        bl.Regular_vs_Alternative__c='Regular';
        bl.Supplier_Part_Number__c='7484784';
        bl.Weeks_ARO__c='3D';
        bl.TLSP_Supplier_Extension__c='WSD';
        bl.Load_Batch_Number__c='2353';
        bl.Due_Date__c=DateTime.now().addDays(25);
        bl.Supplier_Part_Number__c='VR-FST-1';	
        bl.Due_Date__c=system.today().addDays(5);
        bl.Item_Description__c='bundle';
        bl.Status__c='RFQ Ready for DLA';
       // bl.Margin_Percent__c=0.75;
        bl.Payment_Terms__c='Net 10';
        bl.NO_Quote_Reason__c='Supplier F or X Rating';
        bl.Quote_Type__c='No Quote';
        bl.Status__c='SalesRep Claim';
        bl.Country__c='Test';
      //  bl.Bid_Group_Items__c=bidgrp3.Id;
        bl.Quote_Numbers__c='test Number';
      // bl.Sales_Rep__c=newUser.Id;
        bl.Unit_Cost__c=10.00;
        bl.Margin_Percent__c=0.75;
        //bl.Berry_Compliant__c='Yes';
        bl.Country_of_Origin__c='AD - Andorra';
       // bl.Weeks_ARO__c='testing value';
        bl.Comments__c='hi i am testing this field';
        bl.Payment_Terms__c='Net 10';
        bl.Bid_Supplier__c=acc.Id;
        bl.Darley_Part_Number__c='test part Number';
        insert bl;
        
          contact c=new contact();
         c.accountid=acc.id;
         c.lastname='test';
         insert c;
         
         opportunity opp=new opportunity();
          opp.name='test';         
         opp.CloseDate=system.today();
         opp.StageName='Awarded Won';
         opp.AccountId=acc.id;
        // opplist.add(opp);
         insert opp;
         
         OpportunityContactRole role=new OpportunityContactRole();
         role.OpportunityId=opp.id;
         role.ContactId=c.id;
         insert role;
         
        // list<SBQQ__Quote__c>qlist=new list <SBQQ__Quote__c>();
       SBQQ__Quote__c q=new SBQQ__Quote__c();
         	q.SBQQ__Account__c=acc.id;
        q.SBQQ__Opportunity2__c=opp.id;
         q.Kitting_Picklist__c='yes';
        q.SBQQ__Status__c='Approved';
        // qlist.add(q);
         insert q;
        q.SBQQ__Status__c='Presented';
        update q ;
        
        SBQQ__QuoteLine__c sq=new SBQQ__QuoteLine__c();
        sq.Vendor_Part_Number__c='test part Number';
        Sq.Exp_Date__c=system.today()+10;
        sq.MarginPercent__c=24;
        sq.SBQQ__Quote__c=q.id;
        //insert sq;
        
        
        
    }
    @isTest
    public static void changeStatusTest(){
     Bid_Tracker__c bidtr4=new Bid_Tracker__c();
    Id recordTypeIddd = Schema.SObjectType.Bid_Tracker__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
     
     bidtr4.Name='Test Name';
     bidtr4.Quote_Number__c='Test Quote Number'; 
     bidtr4.RecordTypeId=recordTypeIddd;
     bidtr4.Sales_Rep_Driven__c=true;
     bidtr4.Manager_Approval__c='';
     
     insert bidtr4;  

        
    }
    
    
    
    

}