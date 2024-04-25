@istest
public class ApprovalProcessController_test {
    
    @isTest
    public static void UnLockBidlineItem(){
         // Id recordTypeId = Schema.SObjectType.Bid_Line_Item__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
        Account acc = new Account();
        acc.name='DESAPRO';
        //acc.RecordTypeid=personRecordTypeId;
       // acc.Supplier_Rating__c ='F - Required NO QUOTE';
        insert acc;
        
        
        Product2 prd = new Product2();
        prd.Vendor_Part_Number__c='Jon';
        prd.name='Jon';
        prd.Vendor_Part_Number__c='TLS SOE';
        insert prd;  
               // if(quoteRecords.SBQQ__Opportunity2__r.StageName != 'Closed/Won' && quoteRecords.SBQQ__Opportunity2__r.StageName != 'Closed/Won'
        //  &&((quoteRecords.SBQQ__Opportunity2__r.Contract_Type__c == 'TLS FES') || (quoteRecords.SBQQ__Opportunity2__r.Contract_Type__c == 'TLS SOE')) ){
        Contact cot = new Contact();
        cot.lastName= 'Test Cot';
        insert cot;
        
        Opportunity oppVar = new Opportunity();
        oppVar.StageName = 'Customer Contact';
        oppVar.name='Test Opp';
        oppVar.CloseDate=Date.newInstance(2024, 5, 9);
        oppVar.ContactId=cot.id;
        oppVar.Contract_Type__c = 'TLS SOE';
        insert oppVar;
           
        SBQQ__Quote__c parnetVar = new SBQQ__Quote__c();
        parnetVar.SBQQ__Opportunity2__c	=oppVar.id;
        parnetVar.SBQQ__ExpirationDate__c=Date.newInstance(2024, 5, 9);
        parnetVar.Kitting_Picklist__c='Yes';
        parnetVar.SBQQ__Type__c='Quote';
        parnetVar.SBQQ__Status__c='Draft';
        parnetVar.SBQQ__Primary__c = True;
        // parnetVar.SBQQ__SalesRep__c='';
        //parnetVar.Contract_Type__c='TLS SOE';
        
        insert parnetVar;
        string  varSbbq= parnetVar.Id;
        
        ApprovalProcessController_test.submitAccountForApproval(varSbbq);
        List<id> listPar = new List<id>();
        listPar.add(parnetVar.Id);
    ApprovalProcessController.UnLockBidlineItem(listPar);
        
        
    }
    public static void submitAccountForApproval(String accountId) {
        try {
            // Create an instance of the Approval.ProcessSubmitRequest class
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();

            // Set the ID of the record you want to submit for approval (Account in this case)
            req.setObjectId(accountId);

            // Set the ID of the approval process you want to use
            req.setNextApproverIds(new Id[]{}); // You can specify next approver IDs if needed

            // Submit the record for approval
            Approval.ProcessResult result = Approval.process(req);

            // Check if the submission was successful
            if (result.isSuccess()) {
               // return 'Record submitted for approval successfully.';
            } else {
               // return 'Error submitting record for approval: ' + result.getErrors()[0].getMessage();
            }
        } catch (Exception e) {
           // return 'An error occurred: ' + e.getMessage();
        }}

}