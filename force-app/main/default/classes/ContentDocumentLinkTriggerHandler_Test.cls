@isTest
public class ContentDocumentLinkTriggerHandler_Test {
    
    
    @isTest
    public static void sendDocumentTosuppLierTest(){
        
        
    Bid_Tracker__c bidtr=new Bid_Tracker__c();
    Id recordTypeId = Schema.SObjectType.Bid_Tracker__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
     
     bidtr.Name='Test Name';
     bidtr.Quote_Number__c='Test Quote Number'; 
     bidtr.RecordTypeId=recordTypeId;

     
     insert bidtr;
        
   
        
        
          
        Bid_Group_Items__c bidgrp4 = new Bid_Group_Items__c();
        bidgrp4.Name = 'test Bid Group2';
        bidgrp4.Margin__c = null;
        bidgrp4.CPQ_Shipping_Total_from_mfg__c = 500;
        bidgrp4.Total_Cost__c=1200;
       // bidgrp4.Supplier__c=acc.Id;
        bidgrp4.RFQ_Number__c=bidtr.Id;
        bidgrp4.Approval_Status__c='Approved';
        
        insert bidgrp4;
        
        
          
        Bid_Line_Item__c bl1 = new Bid_Line_Item__c();
       bl1.RFQ_Number__c=bidtr.id;
      //  bl1.Bid_Supplier__c=acc.Id;
        bl1.Name='Testing';
        bl1.Regular_vs_Alternative__c='Regular';
        bl1.Supplier_Part_Number__c='7484784';
        bl1.Weeks_ARO__c='3D';
        bl1.TLSP_Supplier_Extension__c='WSD';
        bl1.Load_Batch_Number__c='2353';
        bl1.Due_Date__c=DateTime.now().addDays(25);
        bl1.Supplier_Part_Number__c='VR-FST-1';	
        bl1.Due_Date__c=system.today().addDays(5);
        bl1.Item_Description__c='bundle';
        bl1.Status__c='Pending Margin Calculation';
        bl1.Margin_Percent__c=0.75;
        bl1.Payment_Terms__c='Net 10';
        bl1.NO_Quote_Reason__c='Supplier F or X Rating';
        bl1.Quote_Type__c='No Quote';
        bl1.Status__c='SalesRep Claim';
        bl1.Country__c='Test';
        bl1.Bid_Group_Items__c=bidgrp4.Id;
        bl1.Quote_Numbers__c='test Number';
        bl1.SALES_REP__C=null;
        insert bl1;
        
        
        
        
    
        
     
        
        String base64Content = 'YourBase64EncodedContent';

// Create a new ContentVersion object
   ContentVersion cv = new ContentVersion();
   cv.Title = 'Questionnaire';
   cv.PathOnClient = 'YourFileName.extension';
   cv.VersionData = EncodingUtil.base64Decode(base64Content);
  // cv.ContentDocumentId=cdl.Id;
   
   insert cv;    
   ContentVersion contentVersions = [SELECT Id, Title, ContentDocumentId FROM ContentVersion where title='Questionnaire' limit 1];

        
   ContentDocumentLink cdl = new ContentDocumentLink();
   cdl.LinkedEntityId = bidgrp4.id; // ID of the linked entity (e.g., a record ID)
   cdl.ContentDocumentId = contentVersions.ContentDocumentId; // ID of the ContentDocument
   cdl.ShareType = 'V'; // 'V' for Viewer, 'C' for Collaborator
   cdl.Visibility = 'AllUsers'; // 'AllUsers' or 'InternalUsers'
        
        
   insert cdl;  
        
   
  
    
        
        
    }
    
    @isTest
    public static void suppLierTest(){
    
        Workbench_Parent__c wp=new Workbench_Parent__c();
    wp.Name='RFQTest Name';
    insert wp;
          Bid_Workbench__c bidWorkbench = new Bid_Workbench__c(
            Manufacturer_Name__c = 'Test Manufacturer',
            ShipTo_DODAAC__c = 'DODAAC1', 
            Processed__c = true,
           Order_Item_ID__c='OLN123'
          );
        
        insert bidWorkbench;
        
                    String base64Content = 'YourBase64EncodedContent';

         ContentVersion cv1 = new ContentVersion();
   cv1.Title = 'Questionnairevbcvb';
   cv1.PathOnClient = 'YourFileName.extension';
   cv1.VersionData = EncodingUtil.base64Decode(base64Content);
  // cv.ContentDocumentId=cdl.Id;
   
   insert cv1;    
  
        ContentVersion contentVersionsde = [SELECT Id, Title, ContentDocumentId FROM ContentVersion where title='Questionnairevbcvb' limit 1];

         ContentDocumentLink cd2 = new ContentDocumentLink();
   cd2.LinkedEntityId = bidWorkbench.id; // ID of the linked entity (e.g., a record ID)
   cd2.ContentDocumentId = contentVersionsde.ContentDocumentId; // ID of the ContentDocument
   cd2.ShareType = 'V'; // 'V' for Viewer, 'C' for Collaborator
   cd2.Visibility = 'AllUsers'; // 'AllUsers' or 'InternalUsers'
        
        
   insert cd2;    
        
        

// Create a new ContentVersion object
   ContentVersion cv = new ContentVersion();
   cv.Title = 'Questionnaire';
   cv.PathOnClient = 'YourFileName.extension';
   cv.VersionData = EncodingUtil.base64Decode(base64Content);
  // cv.ContentDocumentId=cdl.Id;
   
   insert cv;    
   ContentVersion contentVersions = [SELECT Id, Title, ContentDocumentId FROM ContentVersion where title='Questionnaire' limit 1];

        
   ContentDocumentLink cdl = new ContentDocumentLink();
   cdl.LinkedEntityId = wp.id; // ID of the linked entity (e.g., a record ID)
   cdl.ContentDocumentId = contentVersions.ContentDocumentId; // ID of the ContentDocument
   cdl.ShareType = 'V'; // 'V' for Viewer, 'C' for Collaborator
   cdl.Visibility = 'AllUsers'; // 'AllUsers' or 'InternalUsers'
        
        
   insert cdl;    
       
 
        
    }
}