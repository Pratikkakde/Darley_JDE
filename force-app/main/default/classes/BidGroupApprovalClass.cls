global class BidGroupApprovalClass {
    
    @InvocableMethod
    public static  void callApproval(List<BidGroupDetail> varInstances){
        map<id,id>uniqueMap=new Map<id,id>();
        for (BidGroupDetail instance : varInstances) {
            uniqueMap.put(instance.SobeIdBidgrp,instance.userId);
         }
        list<processInstance>ProcessvarList=[select id, TargetObjectId , status from processInstance where status='Pending' AND TargetObjectId  In:uniqueMap.keySet()];
        FOr (processInstance varProc :  ProcessvarList) {
            If (uniqueMap.containsKey(varProc.TargetObjectId)){
                uniqueMap.remove(varProc.TargetObjectId);

            }
        }

        For (Id varId : uniqueMap.keySet()){
           Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(varId);
            
             req1.setSubmitterId(uniqueMap.get(varId)); 
            
            If (!Test.isRunningTest()){
                Approval.ProcessResult result = Approval.process(req1);
            }
       
           
           
        }
      
    }
    public class BidGroupDetail{
        @InvocableVariable(required=true)
        public id SobeIdBidgrp;
        
        @InvocableVariable(required=true)
        public Id userId;
        
        @InvocableVariable
        public string CommentApproal;
    }
  
    
    
}