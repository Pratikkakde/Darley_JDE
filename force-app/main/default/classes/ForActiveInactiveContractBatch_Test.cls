/******************************************************************************************************************************************************
Name                    : ForActiveInactiveContractBatch
Author                  : Melonleaf
Purpose                 : This batch class is designed to test the functionality of 

Version                 : 1.0
Change Log              : 
Test Class              : ForActiveInactiveContractBatch_Test
CreateDate              : 25-05-2024
LastModifiedDate        : 25-05-2024
******************************************************************************************************************************************************/

@isTest
public class ForActiveInactiveContractBatch_Test {
    @isTest
    public static void testBatchClass(){
        list<Contract_Period__c> cpList = new list<Contract_Period__c>();
        Contract_Period__c cp = new Contract_Period__c();
        cp.Name='Test Contract';
        cp.Period_Begin_Date__c=date.today().addDays(-15);
        cp.Period_End_Date__c=date.today().addDays(-10);
        cp.Contract_Period_Active__c='Active';
        cpList.add(cp);
        
        Contract_Period__c cpr = new Contract_Period__c();
        cpr.Name='Test Contract1';
        cpr.Period_Begin_Date__c=Date.Today().addDays(-10);
        cpr.Period_End_Date__c=Date.today().addDays(30);
        cpList.add(cpr);
        
        
        insert cpList;
        
        list<Price_Evaluation_List__c> pelList = new list<Price_Evaluation_List__c>();
        Price_Evaluation_List__c pel = new Price_Evaluation_List__c();
        pel.Name= cpList[0].Name;
        pel.Active__c='ACTIVE';
        
        Price_Evaluation_List__c pel01 = new Price_Evaluation_List__c();
        pel01.Name= cpList[1].Name;
        pel01.Active__c='ACTIVE';
        
        pelList.add(pel);
        pelList.add(pel01);
        insert pelList;
        
        system.debug('pelList : '+pelList);
        
        Test.startTest();
        Database.executeBatch(new ForActiveInactiveContractBatch());
        test.stopTest();
        
    }
    
}