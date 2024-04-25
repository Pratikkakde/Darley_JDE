public class CPQ_Quote_Handler {
    public static void method1(list<SBQQ__Quote__c> quotelist){
        
          list<opportunity> opplist=[select id from opportunity where id not in (select opportunityid from OpportunityContactRole)];
    system.debug('opplist'+opplist);
    set<id> newsetid=new set<id>();
   for(opportunity opp:opplist){
        newsetid.add(opp.id);
    }
   list<id> setid=new list<id>(newsetid);
  
       // Require_contactrole_for_quote_handler.requirecontactrole(trigger.new);
    for(SBQQ__Quote__c qu:quotelist){
       if(newsetid.contains(qu.SBQQ__Opportunity2__c)  ){
            system.debug('quote'+qu.id);
             qu.addError('Please add contact role on opportunity to create quote');
        }       
    }
  
     set<id> newset=new set<id>();
        for(SBQQ__Quote__c qu1:quotelist){
          if(qu1.SBQQ__Opportunity2__c!=null){             
         newset.add(qu1.SBQQ__Opportunity2__c);
                     
        
      }      
    }
    map<id,id> opmap= new map<id,id>();
    list<opportunity> opplist1=[select id,(select contactid from OpportunityContactRoles) from opportunity where id in:newset];    
    for(opportunity opp2:opplist1){
         for(OpportunityContactRole oppConRole : opp2.OpportunityContactRoles){
             opmap.put(opp2.Id, oppConRole.ContactId);             
           }   
     }
       
        for(SBQQ__Quote__c qu2:quotelist){
            if(qu2.SBQQ__PrimaryContact__c==null){
                qu2.SBQQ__PrimaryContact__c=opmap.get(qu2.SBQQ__Opportunity2__c);               
             }   
     
   
        
    }
}
}