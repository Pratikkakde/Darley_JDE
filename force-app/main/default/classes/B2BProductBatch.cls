public with sharing class B2BProductBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {

    public List<SObject> productsFromTrigger = new List<SObject>();

    public B2BProductBatch (List<SObject> productsFromTrigger) {
        this.productsFromTrigger = productsFromTrigger;
    }

    public Iterable<SObject> start(Database.BatchableContext context) {
        return productsFromTrigger;
    }

    public void execute(Database.BatchableContext context, List<SObject> products) {
        if (!Test.isRunningTest()) {
            asanaTaskIntegration (products);
        }
        approvalProcess( products);
    }

    public void finish(Database.BatchableContext context) {}

    @TestVisible
    private static void asanaTaskIntegration (List<SObject> products) {
        List<AsanaPublic__AsanaTasksRelation__c> asanaTaskProductRelation = createAsanaTask(products);
        if (!asanaTaskProductRelation.isEmpty()) {
            insert asanaTaskProductRelation;
        }
    }

    private static List<AsanaPublic__AsanaTasksRelation__c> createAsanaTask(List<SObject> products) {
        String isActive = B2B_Asana__mdt.getInstance('Is_Active').Value__c;
        List<AsanaPublic__AsanaTasksRelation__c> asanaTaskProductRelation = new List<AsanaPublic__AsanaTasksRelation__c>();
        if (isActive == 'YES') {
            String asanaTaskId = '';
            for(SObject o: products) {
                asanaTaskId = B2BCalloutAsanaTaskCreation.createAsanaTask((Product2)o);
                if (asanaTaskId != null) {
                    AsanaPublic__AsanaTasksRelation__c taskRelation = new AsanaPublic__AsanaTasksRelation__c(
                        Name = 'New Product Created', 
                        AsanaPublic__AsanaTaskId__c = asanaTaskId,
                        AsanaPublic__ObjectId__c = (Id)o.get('Id'),
                        AsanaPublic__ObjectType__c = 'Product2'
                    );
                    asanaTaskProductRelation.add(taskRelation);
                }
            }
        }
        return asanaTaskProductRelation;
    }

    private static void approvalProcess(List<SObject> products) {
        Integer approcalCount = [SELECT COUNT() FROM ProcessDefinition where DeveloperName = 'B2BProductApprovalProcess' AND State = 'Active'];
        if (approcalCount > 0) {
            List<Approval.ProcessSubmitRequest> processRequests = new List<Approval.ProcessSubmitRequest>();
            Id prodId;
            for(SObject o: products) {
                prodId = (Id)o.get('Id');
                processRequests.add(startApprovalProcess(prodId));
            }
            if (!processRequests.isEmpty()) {
                try {
                    Approval.ProcessResult[] processResults = null;
                    processResults = Approval.process(processRequests, false);
                } catch (Exception exp) {
                    System.debug('Something went wrong with sending the product for Approval.\n Approval Process: B2BProductApprovalProcess');
                }
            }
        } else {
            System.debug('Approval Process Inactive');
        }
    }

    private static Approval.ProcessSubmitRequest startApprovalProcess(Id productId) {
        Approval.ProcessSubmitRequest processRequest = new Approval.ProcessSubmitRequest();
        processRequest.setObjectId(productId);
        processRequest.setProcessDefinitionNameOrId('B2BProductApprovalProcess');
        processRequest.setSkipEntryCriteria(false);
        return processRequest;
    }
}