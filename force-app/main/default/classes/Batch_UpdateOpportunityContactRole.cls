/*
 * Name - Batch_UpdateOpportunityContactRole
 * Author - Melonleaf Consulting
 * Created Date - 07/20/2022
 * Purpose - One time Run batch for the adding the contact roles from the Quote for all the Recordtypes
 * -----------Change Log---------
 * Last Modified by - Lalit
 * Last Modified Date - 09/20/2022 
 */

public class Batch_UpdateOpportunityContactRole implements Database.Batchable<sObject>{   
    public Database.QueryLocator start(Database.BatchableContext bc)
    { 
        
        return Database.getQueryLocator([select Id from Opportunity where
                                         Id not in (select OpportunityId from OpportunityContactRole )
                                         AND Id in (select SBQQ__Opportunity2__c from SBQQ__Quote__c where SBQQ__Opportunity2__c!=null AND SBQQ__PrimaryContact__c!=null)]);
    }
    public void execute(Database.BatchableContext bc, List<opportunity> opplist){
        system.debug('opplo'+opplist);
        set<id> oppsetid=new set<id>();
        Map<id,id> oppContactMap=new Map<id,id>();
        for(opportunity oppo:opplist){
            oppsetid.add(oppo.id);
            system.debug('opposetid'+oppsetid);
        }
        list<SBQQ__Quote__c> qolist=[select id ,SBQQ__PrimaryContact__c,SBQQ__Opportunity2__c from SBQQ__Quote__c where SBQQ__PrimaryContact__c!=null ANd SBQQ__Opportunity2__c in :oppsetid];
        system.debug('qolist'+qolist);
        for(SBQQ__Quote__c q:qolist){
            oppContactMap.put(q.SBQQ__Opportunity2__c,q.SBQQ__PrimaryContact__c);            
        }
        list<OpportunityContactRole> ocrlist=new list<OpportunityContactRole>();
        for(opportunity opp:opplist){
            OpportunityContactRole ocr=new OpportunityContactRole();
            ocr.ContactId=oppContactMap.get(opp.id);
            ocr.Role = 'Decision Maker';
            ocr.OpportunityId=opp.id;
            ocr.IsPrimary = true;
            ocrlist.add(ocr);            
        }
        insert ocrlist;
    }
    public void finish(Database.BatchableContext bc)
    { 
    }
}