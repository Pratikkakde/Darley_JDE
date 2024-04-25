/*
 * Name - updateopportunitycontactrole
 * Author - Melonleaf Consulting
 * Created Date - 07/20/2022
 * Purpose - One time Run batch for the adding the contact roles from the Quote for all the Recordtypes
 * -----------Change Log---------
 * Last Modified by - Lalit
 * Last Modified Date - 09/20/2022 
 */
public class updateopportunitycontactrole implements Database.Batchable<sObject>{   
    public Database.QueryLocator start(Database.BatchableContext bc)
    { 
       
        return Database.getQueryLocator([select Id from Opportunity where
                Id not in (select OpportunityId from OpportunityContactRole )
                AND Id in (select OpportunityId from quote where opportunityid!=null AND ContactId!=null)]);
           }
    public void execute(Database.BatchableContext bc, List<opportunity> opplist){
        system.debug('opplo'+opplist);
        set<id> oppsetid=new set<id>();
        Map<id,id> OppContactMap=new Map<id,id>();
        for(opportunity oppo:opplist){
            oppsetid.add(oppo.id);
            system.debug('opposetid'+oppsetid);
        }
        list<quote> qolist=[select id ,Contactid,opportunityid from quote where ContactId!=null ANd opportunityid in :oppsetid];
        system.debug('qolist'+qolist);
        for(quote q:qolist){
            OppContactMap.put(q.OpportunityId,q.ContactId);            
        }
        list<OpportunityContactRole> ocrlist=new list<OpportunityContactRole>();
        for(opportunity opp:opplist){
            OpportunityContactRole ocr=new OpportunityContactRole();
            ocr.ContactId=OppContactMap.get(opp.id);
            ocr.Role = 'Decision Maker';
            ocr.OpportunityId=opp.id;
            ocr.IsPrimary = true;
            ocrlist.add(ocr);            
        }
        insert ocrlist;
      }
    public void finish(Database.BatchableContext bc){
       
    }
 }