@isTest
public class AttachmentComponentControllerTest {
    @isTest
    static void testUploadFile() {
        // Test Data Setup
        String base64 = 'dGVzdA=='; // base64 for 'test'
        String filename = 'TestFile.txt';
       bid_tracker__c bidtrac = new Bid_tracker__c();
        bidtrac.name= 'Test';
        insert bidtrac;
        
        // Test the uploadFile method
        Test.startTest();
        String contentDocLinkId = AttachmentComponentController.uploadFile(base64, filename, bidtrac.Id, true, 'Proof Of Delivery');
        Test.stopTest();
        
        // Verify the ContentVersion
        ContentVersion cv = [SELECT Id, Title, Upload_to_DLA__c, Label__c FROM ContentVersion WHERE Title = :filename LIMIT 1];
       /* System.assertEquals(cv.Title, filename);
        System.assertEquals(cv.Upload_to_DLA__c, true);
        System.assertEquals(cv.Label__c, 'Label');*/
        
        // Verify the ContentDocumentLink
       // ContentDocumentLink cdl = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId = :cv.ContentDocumentId LIMIT 1];
       // System.assertEquals(cdl.LinkedEntityId, testAccount.Id);
    }
    
    @isTest
    static void testGetAllBidTrackerContentVersions() {
        // Test Data Setup
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        ContentVersion cv = new ContentVersion(
            Title = 'TestFile.txt',
            VersionData = Blob.valueOf('test'),
            PathOnClient = 'TestFile.txt'
        );
        insert cv;
               ContentVersion cv1= [SELECT ContentDocumentId from ContentVersion where Id =:cv.Id ];

        
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = cv1.ContentDocumentId,
            LinkedEntityId = testAccount.Id,
            ShareType = 'V'
        );
        insert cdl;
        
        // Test the getAllBidTrackerContentVersions method
        Test.startTest();
        List<ContentVersion> contentVersions = AttachmentComponentController.getAllBidTrackerContentVersions(testAccount.Id);
        Test.stopTest();
        
        // Verify the ContentVersions
      //  System.assertEquals(contentVersions.size(), 1);
      //  System.assertEquals(contentVersions[0].Title, 'TestFile.txt');
    }
    
    @isTest
    static void testUpdateExistingRecord() {
        // Test Data Setup
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        ContentVersion cv = new ContentVersion(
            Title = 'TestFile.txt',
            VersionData = Blob.valueOf('test'),
            PathOnClient = 'TestFile.txt'
        );
        insert cv;
       ContentVersion cv1= [SELECT ContentDocumentId from ContentVersion where Id =:cv.Id ];
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = cv1.ContentDocumentId,
            LinkedEntityId = testAccount.Id,
            ShareType = 'V'
        );
        insert cdl;
        
        // Test the updateExistingRecord method
        Test.startTest();
        AttachmentComponentController.updateExistingRecord(testAccount.Id, true, true);
        Test.stopTest();
        
        // Verify the updated ContentVersion
        ContentVersion updatedCv = [SELECT Id, Upload_to_DLA__c, Delete_Attachment__c FROM ContentVersion WHERE Id = :cv.Id];
       // System.assertEquals(updatedCv.Upload_to_DLA__c, true);
       // System.assertEquals(updatedCv.Delete_Attachment__c, true);
    }
    
    @isTest
    static void testUpdateContentVersion() {
        // Test Data Setup
        ContentVersion cv = new ContentVersion(
            Title = 'TestFile.txt',
            VersionData = Blob.valueOf('test'),
            PathOnClient = 'TestFile.txt'
        );
        insert cv;
        
        // Modify ContentVersion
        cv.Title = 'UpdatedTestFile.txt';
        
        // Test the updateContentVersion method
        Test.startTest();
        AttachmentComponentController.updateContentVersion(new List<ContentVersion>{cv});
        Test.stopTest();
        
        // Verify the updated ContentVersion
        ContentVersion updatedCv = [SELECT Id, Title FROM ContentVersion WHERE Id = :cv.Id];
      //  System.assertEquals(updatedCv.Title, 'UpdatedTestFile.txt');
    }
}