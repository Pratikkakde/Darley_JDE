public with sharing class contactController {
    public contactController() {}
  
    @AuraEnabled(cacheable=true)
    public static List<contact> searchContact1(string recordId,string searchcon ) {
        system.debug('recordId'+recordId);
        String searchConLike='%'+ searchcon +'%';
        
        list<opportunity>opplist=[select accountid from opportunity where id=:recordId];
        system.debug('opplist'+opplist); 
        list<contact>conlist=new list<contact>();
        conlist=[Select name,Accountid,Title,Email,Phone From Contact  WHERE   Accountid =:opplist[0].accountid LIMIT 5];
        if(conlist.size()>0 && searchcon== null){
            return conlist; 
        }
        else if(conlist.size()>0 && searchcon!= null){
          return[Select name,Accountid,Email,Title,Phone From Contact  WHERE   Accountid =:opplist[0].accountid AND Name like:searchConLike ];
        }
        else  {
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
        public static List<opportunity> searchContact( string recordId ) {
           List<opportunity> relatedContact = new List<opportunity>();
         relatedContact = [Select Id,Accountid From opportunity  WHERE id=:recordId ];
                return relatedContact;
     }
//contact recordtype
  @AuraEnabled(cacheable=true)
public static list <RecordType> getContactRTs(){
 List<RecordType> C_rtypes = [Select RecordType.Name ,id From RecordType 
 where sObjectType='Contact' and isActive=true ORDER BY RecordType.Name ASC];
  return C_rtypes;
     }        
 // Account recordtypename
     @AuraEnabled(cacheable=true)
  public static List<Account> Recordtypemethod( string recordId ) {
      system.debug('recordId'+recordId);
          List<opportunity> Opplist =[Select Accountid From opportunity  WHERE id=:recordId ];
      system.debug('Opplist'+Opplist);
     list<account>acclist=[select recordtype.name from account where id=:opplist[0].accountid];
      system.debug('acclist'+acclist);
          return acclist;      
     }     
   
    }