/******************************************************************************************************************************************************
Name                    : SupplierCleanupTrigger_handler
Author                  : Melonleaf
Purpose                 : This trigger handler is written to change status, and  to give error if the fields information is missing and to make the coment mandatory on rejection
Version                 : 1.0
Change Log              : 
Test Class              : SupplierCleanupTrigger_handlerTest
CreateDate              : 25-05-2024
LastModifiedDate        : 25-05-2024
******************************************************************************************************************************************************/


/******************************************************************************************************************************************************
This method is written to change status and null the values on diff scenerio and  to give error if the fields information is missing.
******************************************************************************************************************************************************/
public class SupplierCleanupTrigger_handler {
        public static void SupplierCleanupStatusUpdate(list<Supplier_Cleanup__c> newList,map<id,Supplier_Cleanup__c>oldmap){
        for(Supplier_Cleanup__c sc : newList){
            if(sc.Status__c=='New'){
                sc.Status__c='Pending';
            } 
            if(sc.Status__c=='Waiting on Approval'){
                if(sc.Supplier_Status__c=='New Supplier'){
                    sc.Supplier_XLAT__c=null;
                    sc.Lead__c=null;
                }
                else if(sc.Supplier_Status__c=='Lead Exist'){ 
                    sc.Supplier_XLAT__c=null;
                    sc.New_Parent_Supplier__c=null;
                }
                else if(sc.Supplier_Status__c=='Account Exist'){ 
                    sc.Lead__c=null;
                    sc.New_Parent_Supplier__c=null;
                }
            }
            
            if(sc.Status__c=='Pending' && oldmap.get(sc.id).Status__c=='Waiting on Approval'){
                sc.Supplier_XLAT__c=null;
                sc.New_Parent_Supplier__c=null;
                sc.Lead__c=null;
                sc.Supplier_Status__c='';
            }
            //Contains logic - when Status is Pending and Supplier Status is changed accordlingly then provide mandatory field error on respective fields
            if(sc.Status__c == 'Pending'){
                if(sc.Supplier_Status__c  == 'Account Exist' && String.isBlank(sc.Supplier_XLAT__c)&&  oldmap.get(sc.Id).Supplier_Status__c != 'New'){
                }
                
                if(sc.Supplier_Status__c  == 'Lead Exist' && String.isBlank(sc.Lead__c)&&  oldmap.get(sc.Id).Supplier_Status__c != 'New'){
                    sc.Lead__c.addError('Please add Lead Field');
                }
                
                if(sc.Supplier_Status__c  == 'New Supplier' && String.isBlank(sc.New_Parent_Supplier__c) &&  oldmap.get(sc.Id).Supplier_Status__c != 'New'){
                    sc.New_Parent_Supplier__c.addError('Please add New Parent Supplier Field');
                }
            }
        }
        
        
        
    }
    
  /******************************************************************************************************************************************************
This method is written to make the comment mandatory on if the record is rejected in approval process
******************************************************************************************************************************************************/
  public static void RequireRejectionComment(list<Supplier_Cleanup__c> newList){
        system.debug('RequireRejectionComment has been executed');
        Map<Id, Supplier_Cleanup__c> rejectedStatements = new Map<Id, Supplier_Cleanup__c>{};
            for(Supplier_Cleanup__c sc: newList){
                
                /* Get the old object record, and check if the approval status field has been updated to rejected.
If so, put it in a map so we only have to use 1 SOQL query to do all checks. */
                
                Supplier_Cleanup__c oldRec = (Supplier_Cleanup__c)System.Trigger.oldMap.get(sc.Id);
                system.debug('old record : '+oldRec);
                system.debug('old record.status : '+oldRec.Status__c);
                system.debug('sc.Status__c : '+sc.Status__c);
                
                
                if (oldRec.Status__c !='Denied' && sc.Status__c== 'Pending'){ 
                    system.debug('if block executed');
                    rejectedStatements.put(sc.Id, sc);  
                }
                system.debug('rejectedStatements: '+rejectedStatements.size());
            }
        
        
        
        
        if (!rejectedStatements.isEmpty()){
            List<Id> processInstanceIds = new List<Id>{};
                
                for (Supplier_Cleanup__c invs : [SELECT (SELECT ID FROM ProcessInstances ORDER BY CreatedDate DESC LIMIT 1) FROM Supplier_Cleanup__c
                                                 WHERE ID IN :rejectedStatements.keySet()])
            {
                if(invs.ProcessInstances.size()>0){
                    processInstanceIds.add(invs.ProcessInstances[0].Id);
                }
                
            }
            System.debug('ProcessIntanceIds : '+processInstanceIds.size());
            system.debug('ProcessInstanceIds: '+processInstanceIds);
            // Now that we have the most recent process instances, we can check
            // the most recent process steps for comments.
            //  TargetObjectId
            for (ProcessInstance pi : [SELECT TargetObjectId,(SELECT Id, StepStatus, Comments FROM Steps ORDER BY CreatedDate DESC LIMIT 1 )FROM ProcessInstance
                                       WHERE Id IN :processInstanceIds
                                       ORDER BY CreatedDate DESC])
            {                   
                system.debug('ProcessInstance: '+pi);
                if ((pi.Steps[0].Comments == null || 
                     pi.Steps[0].Comments.trim().length() == 0))
                {
                    rejectedStatements.get(pi.TargetObjectId).addError(
                        'Operation Cancelled: Please provide a rejection reason!');
                }
            }  
        }
         
        
    }
   
}