public class ApprovalProcessController {
    // class for unlocking the record for editing when submitted for Approval (cpq quote)
   @InvocableMethod(label='Unlock Record')
    public Static void UnLockBidlineItem(List<Id> listAccIds){
        system.debug('listAccIds'+listAccIds); 
          for (Id accountToLock : listAccIds){
              Approval.unlock(accountToLock);
            
        }
        
    }
    
}