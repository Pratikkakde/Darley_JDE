public  without sharing class DeleteFileHandler  {
 
 @AuraEnabled
    public static List<ContentDocument> getFilesUpdate(string recordId){  
        System.debug('recordId'+recordId);   
        
        
        
      Set<Id> documentIds = new Set<Id>();
 
        List<ContentDocumentLink> cdl=[SELECT id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:recordId];  
        
        for(ContentDocumentLink cdLink:cdl){  
            
            documentIds.add(cdLink.ContentDocumentId);  
            System.debug('documentIds'+documentIds);   
        }      
        List<ContentDocument> ContentDocumentList = [SELECT Id,Title,FileType FROM ContentDocument WHERE id IN: documentIds];  
        System.debug('ContentDocumentList'+ContentDocumentList);   
        if(ContentDocumentList.size()>0){
          return ContentDocumentList;
       }
        else{
           return null;
    }
    }
    
    @AuraEnabled
    
    public static void deleteFile(String docId){
        system.debug('docId'+docId);
        
        delete [SELECT Id from ContentDocument WHERE id=:docId];
    } 
}