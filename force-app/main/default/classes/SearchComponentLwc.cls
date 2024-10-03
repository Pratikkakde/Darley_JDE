public class SearchComponentLwc {
    
    @AuraEnabled(cacheable=true)
    public static list<Supplier_XLAT__c> searchXlat(string strXlatName){
        if(strXlatName!=''  ){
            
            String keyString = strXlatName+'%';
            system.debug('string-->'+strXlatName);
            list<Supplier_XLAT__c>  lstXlat = [Select Id, Name ,child__c,  Account__r.Name, Lead__r.Name from Supplier_XLAT__c where child__c like: keyString ];
            system.debug('list-->'+lstXlat);
            return lstXlat;  
        }
      else{
            list<Supplier_XLAT__c> lstXlat = new list<Supplier_XLAT__c>() ;
            system.debug('else');
            return lstXlat;
        }   
    }
    
      @AuraEnabled(cacheable=true)
    public static list<lead>searchLead( string strLeads){
        if(strLeads!=''){
            
            String keyString = strLeads+'%';
            system.debug('string-->'+strLeads);
            list<lead>listLead = [Select Id, Name ,company from lead where company like: keyString AND RecordType.name='Supply Partner Application' ];
            system.debug('listLead-->'+listLead);
            return listLead;  
        }
        else{
            list<lead> listLead = new list<lead>() ;
            system.debug('else');
            return listLead;
        }
        
    }
    
       @AuraEnabled(cacheable=true)
    public static list<Account>searchAccount( string strAccounts){
        system.debug('strAccounts'+strAccounts);
        if(strAccounts!=''){
            
            String keyString = strAccounts+'%';
            system.debug('string-->'+strAccounts);
            list<Account>listAccount = [Select Id, Name , Supplier_Rating__c  from Account where Name like: keyString AND RecordType.name ='Vendor'];
            system.debug('listAccount-->'+listAccount);
            return listAccount;  
        }
        else{
            list<Account> listAccount = new list<Account>() ;
            system.debug('else');
            return listAccount;
        }
        
    }
    
    @AuraEnabled(cacheable=true)
    public static list<Bid_Line_Item__c> searchPartNumber( string strPartNumber){
        // list<Bid_Line_Item__c> lstBidTracker = new list<Bid_Line_Item__c>();
      
         
        if(strPartNumber!=''  ){
            String keyString1 = '%'+strPartNumber+'%';
            system.debug('string-->'+strPartNumber);
            list<Bid_Line_Item__c>  lstBidTracker = [Select Id, Name ,Supplier_Name_Text__c ,Supplier_Part_Number__c from Bid_Line_Item__c where Supplier_Part_Number__c like: keyString1];
            system.debug('list-->'+lstBidTracker);
            
            return lstBidTracker;  
        }
        else{
            list<Bid_Line_Item__c> lstBidTracker = new list<Bid_Line_Item__c>();
            return lstBidTracker;
        }
    }
    
    
    @AuraEnabled(cacheable=true)
    public static list<Account> serachEmail(string emails){
        if(emails!='' ||  emails!=null){
            // String keyString1 = '%'+searchEmail+'%';
            system.debug('string-->'+emails);
            string s=emails.toLowerCase();
            list<account>acclist=new list <account>();
            list<account>lstAccount = [Select Id, Name, Email_Address__c  from Account where  recordtype.name='Vendor'];
            system.debug('lstAccount-->'+lstAccount);
            for(account acc:lstAccount){
               //  system.debug('acc.Email_Address__c.toLowerCase()'+acc.Email_Address__c.toLowerCase());
                if(acc.Email_Address__c!=null){ 
               
                if(acc.Email_Address__c.toLowerCase().contains(s)){
                    acclist.add(acc);
                }
            }
            }
            return acclist;  
        }
        else{
            list<Account> lstAccount = new list<Account>();
            return lstAccount;
        }
    }
    
     @AuraEnabled
    public static void updateSupplierCleanup(string recordIds, string xlatIds,String leadIds){
                system.debug('recordIds'+recordIds);
        system.debug('xlatIds'+xlatIds);

      supplier_cleanup__c s=[select id ,Supplier_XLAT__c from supplier_cleanup__c where id=:recordIds ];
        system.debug('s'+s);
        if(xlatIds != NULL){
        s.Supplier_XLAT__c=xlatIds;
        }
        if(leadIds != NUll){
            s.Lead__c = leadIds;
        }
         system.debug('s.Supplier_XLAT__cSupplier_XLAT__c'+s.Supplier_XLAT__c);
     update s;
    }
        
}