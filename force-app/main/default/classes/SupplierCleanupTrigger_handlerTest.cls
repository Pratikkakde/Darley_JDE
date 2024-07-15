/******************************************************************************************************************************************************
Name                    : SupplierCleanupTrigger_handlerTest
Author                  : Melonleaf
Purpose                 : This test is written to test the functionality of supplier cleanup.
Version                 : 1.0
Change Log              : 
Test Class for          : SupplierCleanupTrigger_handler
CreateDate              : 25-05-2024
LastModifiedDate        : 25-05-2024
******************************************************************************************************************************************************/

@isTest
public class SupplierCleanupTrigger_handlerTest {
    @isTest
   public static void testSupplierCleanupStatusUpdate(){
        list<Supplier_Cleanup__c> scList = new list<Supplier_Cleanup__c>();
        
        Supplier_Cleanup__c sc = new Supplier_Cleanup__c();
        sc.Status__c = 'New';
        sc.RFQ_Number__c='23256536';
        scList.add(sc);
       
        Supplier_Cleanup__c sc01 = new Supplier_Cleanup__c();
        sc01.Status__c='Waiting on Approval';
       
        sc01.RFQ_Number__c='8232565765';
        scList.add(sc01);
        
        if(scList != null && scList.size()>0){
            insert scList;
        }

       Supplier_Cleanup__c retSc = [Select id,Status__c from Supplier_Cleanup__c where id =:sc01.id  LIMIT 1];
        retSc.Status__c='Pending';
        retSc.Supplier_XLAT__c=null;
        retSc.New_Parent_Supplier__c=null;

   
		Test.startTest();
        update scList;
        update retSc;
       
       retSc.Status__c='Waiting on Approval';
       retSc.Supplier_Status__c='New Supplier';
       update retSc;
       
       retSc.Supplier_Status__c='Lead Exist';
       update retSc;
       
       retSc.Supplier_Status__c='Account Exist';
       update retSc;

        Test.stopTest();
    } 
    
   /*  private static testmethod void testRejectionWithComment()
    {
        // Generate sample work item using utility method.
        Id testWorkItemId = generateAndSubmitObject();
        
        // Reject the submitted request, providing a comment.
        Approval.ProcessWorkitemRequest testRej = new Approval.ProcessWorkitemRequest();
        //testRej.setComments('Rejecting request with a comment.');
        testRej.setAction  ('Reject');
        testRej.setWorkitemId(testWorkItemId);
    
        Test.startTest();        
            // Process the rejection
           // Approval.ProcessResult testRejResult =  Approval.process(testRej);
        Test.stopTest();
        
        // Verify the rejection results
        //System.assert(testRejResult.isSuccess(), 'Rejections that include comments should be permitted');
        //System.assertEquals('Rejected', testRejResult.getInstanceStatus(), 
         // 'Rejections that include comments should be successful and instance status should be Rejected');
    }
        private static Id generateAndSubmitObject() {
        // Create a sample invoice statement object and then submit it for approval.
        Supplier_Cleanup__c testIS = new Supplier_Cleanup__c();
        testIS.Status__c = 'Pending';
        testIS.RFQ_Number__c='23256534';
        
        insert testIS;
        
        Approval.ProcessSubmitRequest testReq = new Approval.ProcessSubmitRequest();
        testReq.setObjectId(testIS.Id);
        Approval.ProcessResult reqResult = Approval.process(testReq);
        
        System.assert(reqResult.isSuccess(),'Unable to submit new Supplier_Cleanup__c record for approval');
        //return testIS.id;
        return reqResult.getNewWorkitemIds()[0];
    } */

}