@isTest
public class PriceEvaluationListhandler_Test {
    @isTest
    public static void testexecuteFesCalculations(){
        for(integer i= 0;i<7;i++){
            Contract_Period__c contractPeeriod = new Contract_Period__c();
            contractPeeriod.Name='FES';
            contractPeeriod.Period_Begin_Date__c= Date.newInstance(2020, 5, 11);
            contractPeeriod.Period_End_Date__c= Date.newInstance(2030, 10, 11);
            contractPeeriod.Period_ID__c=i;
            contractPeeriod.Contract_Name_Text__c='FES';
            contractPeeriod.Period_Active__c = 'ACTIVE';
            contractPeeriod.Contract_Period_Active__c = 'ACTIVE';
            insert contractPeeriod;
            
            
            Price_Evaluation_List__c priceEvaVar = new Price_Evaluation_List__c();
            priceEvaVar.Name=contractPeeriod.name;
            priceEvaVar.Base_Period_Unit_Sell__c=300;
            priceEvaVar.Active__c = 'ACTIVE';
            priceEvaVar.BASE_Unit_Cost__c=300;
            priceEvaVar.Option_1_Cost__c=10;
            priceEvaVar.Option_1_Unit_SELL__c=10;
            
            priceEvaVar.Option_2_Cost__c=10;
            priceEvaVar.Option_2_Unit_SELL__c=10;
            
            priceEvaVar.Option_3_Cost__c=10;    
            priceEvaVar.Option_3_Unit_SELL__c=10;
            
            priceEvaVar.Option_4_Cost__c=10;
            priceEvaVar.Option_4_Unit_SELL__c=10;
            
            priceEvaVar.Option_5_Cost__c=10;
            priceEvaVar.Option_5_Unit_SELL__c=10;
            
            priceEvaVar.Option_6_Cost__c=10;
            priceEvaVar.Option_6_Unit_SELL__c=10;
            
            
            priceEvaVar.Bid_Supplier_Text__c='Ron'+i;
            priceEvaVar.Supplier_Part_Number_Text__c='Jon'+i;
            
            
            insert priceEvaVar;
            
        }
        
        
    }
    
    
    
    @isTest
    public static void testexecuteSoeCalculations123(){
        
        
        for(Integer i =0;i<7;i++){
            Account acc = new Account();
            acc.Name='Ron'+i;
            insert acc;
            Product2 prd = new Product2();
            prd.Vendor_Part_Number__c='Jon'+i;
            prd.name='Jon'+i;
            insert prd;
        }
        for(integer i= 0;i<7;i++){
            Contract_Period__c contractPeeriod = new Contract_Period__c();
            contractPeeriod.Name='SOE';
            contractPeeriod.Period_Begin_Date__c= Date.newInstance(2020, 5, 11);
            contractPeeriod.Period_End_Date__c= Date.newInstance(2030, 10, 11);
            contractPeeriod.Period_ID__c=i;
            contractPeeriod.Contract_Name_Text__c='SOE';
            contractPeeriod.Period_Active__c = 'ACTIVE';
            contractPeeriod.Contract_Period_Active__c = 'ACTIVE';
            insert contractPeeriod;
            
            Price_Evaluation_List__c priceEvaVar = new Price_Evaluation_List__c();
            priceEvaVar.Name=contractPeeriod.name;
            priceEvaVar.Base_Period_Unit_Sell__c=300;
            priceEvaVar.Active__c = 'ACTIVE';
            priceEvaVar.BASE_Unit_Cost__c=300;
            priceEvaVar.Option_1_Cost__c=1;
            priceEvaVar.Option_1_Unit_SELL__c=2;
            
            priceEvaVar.Option_2_Cost__c=3;
            priceEvaVar.Option_2_Unit_SELL__c=2;
            
            priceEvaVar.Option_3_Cost__c=3;
            priceEvaVar.Option_3_Unit_SELL__c=2;
            
            priceEvaVar.Option_4_Cost__c=3;
            priceEvaVar.Option_4_Unit_SELL__c=2;
            
            priceEvaVar.Option_5_Cost__c=3;
            priceEvaVar.Option_5_Unit_SELL__c=2;
            
            priceEvaVar.Option_6_Cost__c=3;
            priceEvaVar.Option_6_Unit_SELL__c=2;
             
            priceEvaVar.Bid_Supplier_Text__c='Ron'+i;
            priceEvaVar.Supplier_Part_Number_Text__c='Jon'+i;
            
            
            insert priceEvaVar;
            
        }
    }
    
    
}