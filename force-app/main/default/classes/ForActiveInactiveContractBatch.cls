/******************************************************************************************************************************************************
Name                    : ForActiveInactiveContractBatch
Author                  : Melonleaf
Purpose                 : This batch class is designed to active and inactive the contract and contract period on the basis of todays date.we rae using PEl and contract period object.

Version                 : 1.0
Change Log              : 
Test Class              : ForActiveInactiveContractBatch_Test
CreateDate              : 25-05-2024
LastModifiedDate        : 25-05-2024
******************************************************************************************************************************************************/

global class ForActiveInactiveContractBatch implements Database.Batchable<sObject>,Schedulable {
     global void execute(SchedulableContext sc)
    {
        ForActiveInactiveContractBatch b = new ForActiveInactiveContractBatch();
        database.executeBatch(b,200);

    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        
       integer year=system.today().addYears(-1).year();
system.debug('year'+year);

        string query = 'Select Id, Name ,Period_End_Date__c,Period_Begin_Date__c,Period_Active__c,Contract_Period_Active__c from Contract_Period__c where CALENDAR_YEAR(Period_End_Date__c)>=: year ';
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Contract_Period__c> contractRecordList) {
        
        AggregateResult[] results = [Select count(Id) cnt,Name,max(Period_End_Date__c) endDt, min(Period_Begin_Date__c) bgdt from Contract_Period__c group by Name];
        system.debug('results'+results);
        Set<string> contractNameList1 = new Set<string>(); //contains Inactive contract
        Set<string> contractNameList2 = new Set<string>();//contains Active contract
        
        for (AggregateResult result : results) {
            if ((Date.today() >= (Date)result.get('bgdt') && (date)result.get('endDt') >= Date.today())) {
                contractNameList2.add((string)result.get('Name'));//for Active
            }
            else{
                contractNameList1.add((string)result.get('Name'));//for inactive
            }
        }
        system.debug('contractNameList1'+contractNameList1);
        system.debug('contractNameList2'+contractNameList2);
        
        
        List<Contract_Period__c> contractListToUpdate = new List<Contract_Period__c>();
        List<Price_Evaluation_List__c> PELListToUpdate = new List<Price_Evaluation_List__c>();
        
        List<Price_Evaluation_List__c> PELRecordList =[select Id,Name,PEL_Type__c,Active__c from Price_Evaluation_List__c where Name IN: contractNameList1 AND Active__c='ACTIVE'];
        system.debug('PELRecordList'+PELRecordList);
        
        //updating the PEL to Inactive
        for(Price_Evaluation_List__c PELRecord : PELRecordList ) {
            PELRecord.Active__c = 'INACTIVE';
            PELListToUpdate.add(PELRecord);
            
        }
        SYSTEM.debug('PEL ACTIVE' + PELListToUpdate);
        
        
        //Updating the ContractOptionPeriod 
        for(Contract_Period__c contractRecord : contractRecordList ){
            if(contractNameList1.contains(contractRecord.name)){
                contractRecord.Contract_Period_Active__c = 'INACTIVE';
                contractRecord.Period_Active__c='INACTIVE'; // Making the contract Inactive;
                system.debug('contractRecord.Contract_Period_Active__c-->'+ contractRecord.Contract_Period_Active__c);
                system.debug('contractRecord.Period_Active__c-->'+contractRecord.Period_Active__c);

            }
            else if(contractNameList2.contains(contractRecord.name)){
                system.debug('IN IF');
                contractRecord.Contract_Period_Active__c = 'ACTIVE';
                system.debug('contractRecord.Contract_Period_Active__c-->'+ contractRecord.Contract_Period_Active__c);
                
                if ((Date.today() >= contractRecord.Period_Begin_Date__c && contractRecord.Period_End_Date__c >= Date.today())) {
                    contractRecord.Period_Active__c='ACTIVE';  
                }
                    else{
                        contractRecord.Period_Active__c='INACTIVE';  
                    }
                }
                contractListToUpdate.add(contractRecord);
            }
            
            
            
         
            //logic for updating the PEL list to Active
            list<Price_Evaluation_List__c> PELRecordList1 =[select Id,Name,Active__c,PEL_Type__c  from Price_Evaluation_List__c where Name IN :contractNameList2];
            system.debug('PELRecordList1'+PELRecordList1);
            
            for( Price_Evaluation_List__c PELRecord : PELRecordList1){
                PELRecord.Active__c = 'ACTIVE';
                PELListToUpdate.add(PELRecord);
            }
            
            
            system.debug('contractListToUpdate'+contractListToUpdate);
            system.debug('PELListToUpdate'+PELListToUpdate);
            
            
             Update contractListToUpdate;
             update PELListToUpdate;
            
        }    
        
        
        global void finish(Database.BatchableContext BC) {
            
            
        }
    }