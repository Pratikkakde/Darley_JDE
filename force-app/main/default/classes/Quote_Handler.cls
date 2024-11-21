/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 11-18-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public class Quote_Handler {
    public static void requirecontactrole(list<quote> triggernew){
        list<opportunity> opplist=[select id from opportunity where id not in (select opportunityid from OpportunityContactRole)];
        set<id> newsetid=new set<id>();
        for(opportunity opp:opplist){
            newsetid.add(opp.id);
        }
        for(quote qu:triggernew){
            if(newsetid.contains(qu.OpportunityId)  ){
                system.debug('quote'+qu.id);
                qu.addError('Please add contact role on opportunity to create quote');
            }
        }
        set<id> newset=new set<id>();
        for(quote qu1:triggernew){
            if(qu1.OpportunityId!=null){
                newset.add(qu1.OpportunityId);
                
            }
        }
        map<id,id> opmap= new map<id,id>();
        list<opportunity> opplist1=[select id,(select contactid from OpportunityContactRoles) from opportunity where id in:newset];
        for(opportunity opp2:opplist1){
            for(OpportunityContactRole oppConRole : opp2.OpportunityContactRoles){
                opmap.put(opp2.Id, oppConRole.ContactId);
            }
        }
        for(quote qu2:triggernew){
            if(qu2.contactid==null){
                qu2.contactid=opmap.get(qu2.opportunityid);
            }
        }
    }
    
    public static void quoteamountupdate(list<quote> triggernew,Map<id,quote> triggeroldmaplist){
        set<id> quoteid=new set<id>();
        map<id,decimal> oppidmap=new map<id,decimal>();
        Map<Id, Id> quoteMap = new Map<Id, Id>();
        //  Id devRecordTypeId = Schema.SObjectType.quote.getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
        
        Set<String> recTypeId = new Set<String> ();
        for (RecordType recType : [Select Id  From RecordType  Where SobjectType = 'Quote' and (DeveloperName ='Pump' or  DeveloperName ='Equipment')]){
            recTypeId.add(recType.Id);
        }
        //      system.debug('RecType'+RecType);
        for(quote q:triggernew){
            if(q.opportunityid!=null && (q.TotalPrice!=null ||triggeroldmaplist.get(q.id).TotalPrice!=q.TotalPrice)  && recTypeId.contains(q.RecordTypeId)){
                    quoteMap.put(q.Id, q.OpportunityId);
                
                oppidmap.put(q.OpportunityId, q.TotalPrice);
                system.debug('oppidmap'+oppidmap);
                quoteid.add(q.OpportunityId);
                system.debug('quoteid'+quoteid);
            }
        }
        System.enqueueJob(new syncQuote(quoteMap));
        
        list<opportunity> opplist=[select id,amount from opportunity where  id in :quoteid ];
        system.debug('opplist'+ opplist);
        for(opportunity opp :opplist){
            // opp.amount=oppidmap.get(opp.id);
            system.debug('opp.amount'+opp.amount);
            
        }
        update opplist;
        
    }
    public static void quoteDarleyCostupdate(list<quote> triggernew,Map<id,quote> triggeroldmaplist ){
        set<id> quoteid=new set<id>();
        map<id,decimal> oppidmap=new map<id,decimal>();
        //   Id devRecordTypeId = Schema.SObjectType.quote.getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
        list< RecordType> RecType = [Select Id, name From RecordType  Where SobjectType = 'Quote' and DeveloperName = 'Equipment'];
        system.debug('RecType'+RecType);
        for(quote q:triggernew){
            if(q.opportunityid!=null && (q.Cost_22_Total_QLI__c!=null ||triggeroldmaplist.get(q.id).Cost_22_Total_QLI__c!=q.Cost_22_Total_QLI__c)  && q.RecordTypeId==RecType[0].ID  ){
                oppidmap.put(q.OpportunityId, q.Cost_22_Total_QLI__c);
                quoteid.add(q.OpportunityId);
                //0122E000000KnoPQAS
            }
        }
        list<opportunity> opplist=[select id,	Darley_Cost__c from opportunity where  id in :quoteid ];
        
        for(opportunity opp :opplist){
            
            opp.Darley_Cost__c=oppidmap.get(opp.id);
            
        }
        
        
        update opplist;
    }
    
    
    
}