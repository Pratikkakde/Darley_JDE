public class AttachmentComponentController {
    
    @AuraEnabled
  public static String uploadFile(String base64, String filename, String recordId, boolean uploadtoDla, string labelPicklist) {
        ContentVersion cv = createContentVersion(base64, filename, uploadtoDla, labelPicklist);
        ContentDocumentLink cdl = AttachmentComponentController.createContentLink(cv.Id, recordId);
        if (cv == null || cdl == null) { 
            return null; 
        }
        return cdl.Id;
  }
  
  private static ContentVersion createContentVersion(String base64, String filename, boolean uploadtoDla, string labelPicklist) {
    ContentVersion cv = new ContentVersion();
    cv.VersionData = EncodingUtil.base64Decode(base64);
    cv.Title = filename;
    cv.PathOnClient = filename;
      if(uploadtoDla != null){
    cv.Upload_to_DLA__c = uploadtoDla;
      }
     cv.Label__c = labelPicklist; 
    try {
      insert cv;
      return cv;
    } catch(DMLException e) {
      System.debug(e);
      return null;
    }
  }

  
  private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
              if (contentVersionId == null || recordId == null) { return null; }
    ContentDocumentLink cdl = new ContentDocumentLink();
    cdl.ContentDocumentId = [
      SELECT ContentDocumentId 
      FROM ContentVersion 
      WHERE Id =: contentVersionId
    ].ContentDocumentId;
    cdl.LinkedEntityId = recordId;
    
    cdl.ShareType = 'V';
    try {
      insert cdl;
      return cdl;
    } catch(DMLException e) {
      System.debug(e);
      return null;
    }
  }
    //get all content version data related to a specific Bid Tracker record
@AuraEnabled(cacheable=true)
public static List<ContentVersion>getAllBidTrackerContentVersions(Id bidTrackerId) {
    if (bidTrackerId == null) {
        return new List<ContentVersion>();
    }

    // Query to get ContentDocumentLink records related to a specific Bid_Tracker__c record
    List<ContentDocumentLink> contentDocumentLinks = [
        SELECT ContentDocumentId
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :bidTrackerId
    ];
    
    // Extract ContentDocumentIds from the ContentDocumentLink query
    Set<Id> contentDocumentIds = new Set<Id>();
    for (ContentDocumentLink cdl : contentDocumentLinks) {
        contentDocumentIds.add(cdl.ContentDocumentId);
    }
    
    // Query to get all ContentVersion records related to the ContentDocumentIds
    List<ContentVersion> contentVersionData = new List<ContentVersion>();
    if (!contentDocumentIds.isEmpty()) {
        contentVersionData = [
            SELECT Id, Title, ContentDocumentId, Send_to_DLA__c, Delete_Attachment__c, Upload_to_DLA__c
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocumentIds
        ];
    }
    
    return contentVersionData;
}


    //update existing Content Version 
   @AuraEnabled
 public static void updateExistingRecord(string recordId ,boolean tabledeleteattachment,Boolean tableuploadattachment){
         // Query to get all ContentDocumentLink records related to Bid_Tracker__c
        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId =: recordId
        ];
        system.debug('contentDocumentLinks-->'+ contentDocumentLinks);
        // Extract ContentDocumentIds from the ContentDocumentLink query
        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentDocumentLink cdl : contentDocumentLinks) {
            contentDocumentIds.add(cdl.ContentDocumentId);
        }
                system.debug('contentDocumentIds-->'+ contentDocumentIds);

        // Query to get all ContentVersion records related to the ContentDocumentIds
        List<ContentVersion> contentVersionData = new List<ContentVersion>();
        if (!contentDocumentIds.isEmpty()) {
            contentVersionData = [
                SELECT Id, Title, ContentDocumentId, Send_to_DLA__c, Delete_Attachment__c, Upload_to_DLA__c
                FROM ContentVersion
                WHERE ContentDocumentId IN :contentDocumentIds
            ];
                            system.debug('contentVersionData-->'+ contentVersionData);

        }
        List<ContentVersion> UpdatecontentVersion = new List<ContentVersion>();
        for(ContentVersion cv : contentVersionData){
            if(!contentVersionData.isEmpty()){
                cv.Upload_to_DLA__c = tableuploadattachment;
                cv.Delete_Attachment__c = tabledeleteattachment;
                UpdatecontentVersion.add(cv);
                system.debug('tableuploadattachment-->'+tableuploadattachment);
                system.debug('cv.Upload_to_DLA__c-->'+cv.Upload_to_DLA__c );
                  system.debug('cv.Delete_Attachment__c->'+cv.Delete_Attachment__c);
                 system.debug('tabledeleteattachment->'+tabledeleteattachment);

}
            
            
        }
        if(!UpdatecontentVersion.isEmpty()){
            system.debug('In If-->');
        update UpdatecontentVersion;
            system.debug('UpdatecontentVersion-->'+ UpdatecontentVersion);
        }
    }

  // LIGHTNING DATA TABLE  UPDATE RECORDS
  @AuraEnabled

    public static void updateContentVersion(List<ContentVersion> conVersions) {
        update conVersions;
    }
  





}