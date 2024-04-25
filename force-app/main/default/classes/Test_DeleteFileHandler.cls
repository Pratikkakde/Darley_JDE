@isTest
public class Test_DeleteFileHandler {
@isTest
    public static void method1(){
        Account acc=new Account();
        Acc.name='test';
        insert acc;
        
      //  List<ContentDocument> documents = [SELECT Id FROM ContentDocument];
        
ContentDocument c=new ContentDocument();
        
         Test.startTest();
        DeleteFileHandler.getFilesUpdate(acc.id);
        DeleteFileHandler.deleteFile(c.id);
        Test.stopTest();
        
        
    }

}