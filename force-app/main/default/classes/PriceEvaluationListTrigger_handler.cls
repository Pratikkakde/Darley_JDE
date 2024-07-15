/******************************************************************************************************************************************************
Name                    : PriceEvaluationListTrigger_handler
Author                  : Melonleaf


Description             :This class is written to handle changes on PriceEvaluationList and do changes on record as per the criteria 
Version                 : 1.0
Change Log              : 
Test Class              : Pricing_Matrix_TriggerHandler_test
CreateDate              : 25-05-2024
LastModifiedDate        : 25-05-2024
******************************************************************************************************************************************************/
public class PriceEvaluationListTrigger_handler {
    
    /******************************************************************************************************************************************************
     This method is fired on the before event .The executeFesCalculations method updates the Current_Period_COST__c and Current_Period_SELL__c fields of Price_Evaluation_List__c 
      records based on the active contract period and the options specified in each record.
    ******************************************************************************************************************************************************/
    public static void executeFesCalculations(List<Price_Evaluation_List__c> PELRecordList){
        
        List<Contract_Period__c> contractOptionList = [Select Id, Name , Period_Begin_Date__c,Period_End_Date__c ,Period_ID__c, Period_Active__c ,Contract_Period_Active__c from Contract_Period__c WHERE Contract_Period_Active__c='ACTIVE'];
        system.debug('contractOptionList'+contractOptionList);
        List<Price_Evaluation_List__c> FesUpdate = new List<Price_Evaluation_List__c>();
        
        for(Contract_Period__c contractRecordFes : contractOptionList ){
            system.debug('contractRecordFes'+contractRecordFes);
            for(Price_Evaluation_List__c PELRecord : PELRecordList ){
                system.debug('PELRecord'+PELRecord);
                system.debug('contractRecordFeS   Name   '+contractRecordFeS.Name+'==  PELRecord.Name   ' + PELRecord.Name);
                
                string ContractName = PELRecord.Name;
                if(ContractName.startsWith('FES')){
                    if(contractRecordFes.Period_Begin_Date__c <= date.today() && contractRecordFes.Period_End_Date__c >= date.today() && contractRecordFeS.Name == PELRecord.Name && contractRecordFes.Period_ID__c == 0 && contractRecordFes.Period_Active__c == 'ACTIVE' && contractRecordFes.Contract_Period_Active__c == 'ACTIVE' && PELRecord.Active__c == 'ACTIVE'  ){
                        if(PELRecord.BASE_Unit_Cost__c != NULL)  {
                            PELRecord.Current_Period_COST__c = PELRecord.BASE_Unit_Cost__c;
                        }
                        if(PELRecord.Base_Period_Unit_SELL__c != NULL ){
                            
                            PELRecord.Current_Period_SELL__c = PELRecord.Base_Period_Unit_SELL__c;
                        }
                    }
                    else if(contractRecordFes.Period_Begin_Date__c <= date.today() && contractRecordFes.Period_End_Date__c >= date.today() &&   contractRecordFeS.Name == PELRecord.Name && contractRecordFes.Period_ID__c == 1 && contractRecordFes.Period_Active__c ==  'ACTIVE' && contractRecordFes.Contract_Period_Active__c ==  'ACTIVE' && PELRecord.Active__c ==  'ACTIVE' ){
                        if(PELRecord.BASE_Unit_Cost__c != NULL && PELRecord.Option_1_Cost__c !=null) {
                            PELRecord.Current_Period_COST__c = PELRecord.Option_1_Cost__c;
                        }
                        if(PELRecord.Base_Period_Unit_SELL__c != NULL && PELRecord.Option_1_Unit_SELL__c!=null){
                            
                            PELRecord.Current_Period_SELL__c = PELRecord.Option_1_Unit_SELL__c;
                        }
                    }
                    else if(contractRecordFes.Period_Begin_Date__c <= date.today() && contractRecordFes.Period_End_Date__c >= date.today() &&  contractRecordFeS.Name == PELRecord.Name && contractRecordFes.Period_ID__c == 2 && contractRecordFes.Period_Active__c == 'ACTIVE' && contractRecordFes.Contract_Period_Active__c == 'ACTIVE' && PELRecord.Active__c == 'ACTIVE' ){
                        if(PELRecord.BASE_Unit_Cost__c != NULL && PELRecord.Option_2_Cost__c!=null) {
                            PELRecord.Current_Period_COST__c = PELRecord.Option_2_Cost__c;
                        }
                        if(PELRecord.Base_Period_Unit_SELL__c != NULL && PELRecord.Option_2_Unit_SELL__c!=null ){
                            
                            PELRecord.Current_Period_SELL__c = PELRecord.Option_2_Unit_SELL__c;
                        }
                    }
                    else if(contractRecordFes.Period_Begin_Date__c <= date.today() && contractRecordFes.Period_End_Date__c >= date.today() && contractRecordFeS.Name == PELRecord.Name  && contractRecordFes.Period_ID__c == 3 && contractRecordFes.Period_Active__c == 'ACTIVE' && contractRecordFes.Contract_Period_Active__c == 'ACTIVE' && PELRecord.Active__c == 'ACTIVE'){
                        if(PELRecord.BASE_Unit_Cost__c != NULL && PELRecord.Option_3_Cost__c!=null) {
                            
                            PELRecord.Current_Period_COST__c = PELRecord.Option_3_Cost__c;
                        }
                        if(PELRecord.Base_Period_Unit_SELL__c != NULL && PELRecord.Option_3_Unit_SELL__c!=null ){
                            
                            PELRecord.Current_Period_SELL__c = PELRecord.Option_3_Unit_SELL__c;
                        }
                    }
                    else if(contractRecordFes.Period_Begin_Date__c <= date.today() && contractRecordFes.Period_End_Date__c >= date.today() &&  contractRecordFeS.Name == PELRecord.Name && contractRecordFes.Period_ID__c == 4 && contractRecordFes.Period_Active__c == 'ACTIVE' && contractRecordFes.Contract_Period_Active__c == 'ACTIVE' && PELRecord.Active__c == 'ACTIVE'){
                        if(PELRecord.BASE_Unit_Cost__c != NULL && PELRecord.Option_4_Cost__c !=null) {
                            
                            PELRecord.Current_Period_COST__c = PELRecord.Option_4_Cost__c;
                        }
                        if(PELRecord.Base_Period_Unit_SELL__c != NULL && PELRecord.Option_4_Unit_SELL__c!=null){
                            
                            PELRecord.Current_Period_SELL__c = PELRecord.Option_4_Unit_SELL__c;
                        }
                    } 
                    else if(contractRecordFes.Period_Begin_Date__c <= date.today() && contractRecordFes.Period_End_Date__c >= date.today() &&  contractRecordFeS.Name == PELRecord.Name && contractRecordFes.Period_ID__c == 5 && contractRecordFes.Period_Active__c == 'ACTIVE' && contractRecordFes.Contract_Period_Active__c == 'ACTIVE' && PELRecord.Active__c == 'ACTIVE'){
                        if(PELRecord.BASE_Unit_Cost__c != NULL &&  PELRecord.Option_5_Cost__c!=null) {
                            
                            PELRecord.Current_Period_COST__c = PELRecord.Option_5_Cost__c;
                        }
                        if(PELRecord.Base_Period_Unit_SELL__c != NULL && PELRecord.Option_5_Unit_SELL__c!=null){
                            
                            PELRecord.Current_Period_SELL__c = PELRecord.Option_5_Unit_SELL__c;
                        }
                    } 
                    else if(contractRecordFes.Period_Begin_Date__c <= date.today() && contractRecordFes.Period_End_Date__c >= date.today() &&  contractRecordFeS.Name == PELRecord.Name && contractRecordFes.Period_ID__c == 6 && contractRecordFes.Period_Active__c == 'ACTIVE' && contractRecordFes.Contract_Period_Active__c == 'ACTIVE' && PELRecord.Active__c == 'ACTIVE'){
                        if(PELRecord.BASE_Unit_Cost__c != NULL &&  PELRecord.Option_6_Cost__c!=null) {
                            
                            PELRecord.Current_Period_COST__c = PELRecord.Option_6_Cost__c;
                        }
                        if(PELRecord.Base_Period_Unit_SELL__c != NULL && PELRecord.Option_6_Unit_SELL__c!=null){
                            
                            PELRecord.Current_Period_SELL__c = PELRecord.Option_6_Unit_SELL__c;
                        }
                    }
                }
                FesUpdate.add(PELRecord);  
                
                
                
                
            }
            system.debug('FesUpdate'+FesUpdate);
        }
        
    }
    
    /******************************************************************************************************************************************************
    The executeSoeCalculations method updates the Current_Period_COST__c and Current_Period_SELL__c fields of Price_Evaluation_List__c 
        records based on the active contract period and the options specified in each record.
    *****************************************************************************************************************************************************/
    
    public static void executeSoeCalculations(List<Price_Evaluation_List__c> soeRecordList){
        LIST<Contract_Period__c> contractOptionSoeList = [Select Id, Name , Period_Begin_Date__c,Period_End_Date__c ,Period_ID__c, Period_Active__c ,Contract_Period_Active__c from Contract_Period__c WHERE Contract_Period_Active__c='ACTIVE'];
        system.debug('contractOptionSoeList'+contractOptionSoeList);
        
        List<Price_Evaluation_List__c> SoeUpdate = new List<Price_Evaluation_List__c>();  
        for(Contract_Period__c contractRecordSoe : contractOptionSoeList ){
            for(Price_Evaluation_List__c soeRecord : soeRecordList ){
                string ContractName = soeRecord.Name;
                if(ContractName.startsWith('SOE')){
                    if(contractRecordSoe.Period_Begin_Date__c <= date.today() && contractRecordSoe.Period_End_Date__c >= date.today() && contractRecordSoe.Name == soeRecord.Name && contractRecordSoe.Period_ID__c == 0 && contractRecordSoe.Period_Active__c == 'ACTIVE' && contractRecordSoe.Contract_Period_Active__c == 'ACTIVE' && soeRecord.Active__c =='ACTIVE'   ){
                        if(soeRecord.BASE_Unit_Cost__c != NULL)  {
                            soeRecord.Current_Period_COST__c = soeRecord.BASE_Unit_Cost__c;
                        }
                        if(soeRecord.Base_Period_Unit_SELL__c != NULL ){
                            
                            soeRecord.Current_Period_SELL__c = soeRecord.Base_Period_Unit_SELL__c;
                        }
                    }
                    else if(contractRecordSoe.Period_Begin_Date__c <= date.today() && contractRecordSoe.Period_End_Date__c >= date.today() &&  contractRecordSoe.Name == soeRecord.Name && contractRecordSoe.Period_ID__c == 1 && contractRecordSoe.Period_Active__c == 'ACTIVE' && contractRecordSoe.Contract_Period_Active__c == 'ACTIVE' && soeRecord.Active__c =='ACTIVE' ){
                        if(soeRecord.BASE_Unit_Cost__c != NULL && soeRecord.Option_1_Cost__c!=null) {
                            soeRecord.Current_Period_COST__c = soeRecord.Option_1_Cost__c;
                        }
                        if(soeRecord.Base_Period_Unit_SELL__c != NULL && soeRecord.Option_1_Unit_SELL__c!=null ){
                            
                            soeRecord.Current_Period_SELL__c = soeRecord.Option_1_Unit_SELL__c;
                        }
                    }
                    else if(contractRecordSoe.Period_Begin_Date__c <= date.today() && contractRecordSoe.Period_End_Date__c >= date.today() &&  contractRecordSoe.Name == soeRecord.Name && contractRecordSoe.Period_ID__c == 2 && contractRecordSoe.Period_Active__c == 'ACTIVE' && contractRecordSoe.Contract_Period_Active__c == 'ACTIVE' && soeRecord.Active__c =='ACTIVE'  ){
                        if(soeRecord.BASE_Unit_Cost__c != NULL && soeRecord.Option_2_Cost__c!=null) {
                            soeRecord.Current_Period_COST__c = soeRecord.Option_2_Cost__c;
                        }
                        if(soeRecord.Base_Period_Unit_SELL__c != NULL && soeRecord.Option_2_Unit_SELL__c!=null ){
                            
                            soeRecord.Current_Period_SELL__c = soeRecord.Option_2_Unit_SELL__c;
                        }
                    }
                    else if(contractRecordSoe.Period_Begin_Date__c <= date.today() && contractRecordSoe.Period_End_Date__c >= date.today() && contractRecordSoe.Name == soeRecord.Name && contractRecordSoe.Period_ID__c == 3 && contractRecordSoe.Period_Active__c == 'ACTIVE' && contractRecordSoe.Contract_Period_Active__c == 'ACTIVE' && soeRecord.Active__c =='ACTIVE'){
                        if(soeRecord.BASE_Unit_Cost__c != NULL && soeRecord.Option_3_Cost__c!=null) {
                            
                            soeRecord.Current_Period_COST__c = soeRecord.Option_3_Cost__c;
                        }
                        if(soeRecord.Base_Period_Unit_SELL__c != NULL && soeRecord.Option_3_Unit_SELL__c!=null){
                            
                            soeRecord.Current_Period_SELL__c = soeRecord.Option_3_Unit_SELL__c;
                        }
                    }
                    else if(contractRecordSoe.Period_Begin_Date__c <= date.today() && contractRecordSoe.Period_End_Date__c >= date.today() && contractRecordSoe.Name == soeRecord.Name && contractRecordSoe.Period_ID__c == 4 && contractRecordSoe.Period_Active__c == 'ACTIVE' && contractRecordSoe.Contract_Period_Active__c == 'ACTIVE' && soeRecord.Active__c =='ACTIVE'){
                        if(soeRecord.BASE_Unit_Cost__c != NULL && soeRecord.Option_4_Cost__c!=null) {
                            
                            soeRecord.Current_Period_COST__c = soeRecord.Option_4_Cost__c;
                        }
                        if(soeRecord.Base_Period_Unit_SELL__c != NULL && soeRecord.Option_4_Unit_SELL__c!=null){
                            
                            soeRecord.Current_Period_SELL__c = soeRecord.Option_4_Unit_SELL__c;
                        }
                    }
                    else if(contractRecordSoe.Period_Begin_Date__c <= date.today() && contractRecordSoe.Period_End_Date__c >= date.today() && contractRecordSoe.Name == soeRecord.Name && contractRecordSoe.Period_ID__c == 5 && contractRecordSoe.Period_Active__c == 'ACTIVE' && contractRecordSoe.Contract_Period_Active__c == 'ACTIVE' && soeRecord.Active__c =='ACTIVE'){
                        if(soeRecord.BASE_Unit_Cost__c != NULL && soeRecord.Option_5_Cost__c!=null) {
                            
                            soeRecord.Current_Period_COST__c = soeRecord.Option_5_Cost__c;
                        }
                        if(soeRecord.Base_Period_Unit_SELL__c != NULL && soeRecord.Option_5_Unit_SELL__c!=null){
                            
                            soeRecord.Current_Period_SELL__c = soeRecord.Option_5_Unit_SELL__c;
                        }
                    }
                    else if(contractRecordSoe.Period_Begin_Date__c <= date.today() && contractRecordSoe.Period_End_Date__c >= date.today() && contractRecordSoe.Name == soeRecord.Name && contractRecordSoe.Period_ID__c == 6 && contractRecordSoe.Period_Active__c == 'ACTIVE' && contractRecordSoe.Contract_Period_Active__c == 'ACTIVE' && soeRecord.Active__c =='ACTIVE'){
                        if(soeRecord.BASE_Unit_Cost__c != NULL && soeRecord.Option_6_Cost__c!=null) {
                            
                            soeRecord.Current_Period_COST__c = soeRecord.Option_6_Cost__c;
                        }
                        if(soeRecord.Base_Period_Unit_SELL__c != NULL && soeRecord.Option_6_Unit_SELL__c!=null){
                            
                            soeRecord.Current_Period_SELL__c = soeRecord.Option_6_Unit_SELL__c;
                        }
                    }
                }
                SoeUpdate.add(soeRecord);   
            }
            
        }
        system.debug('SoeUpdate'+SoeUpdate);
        
    }
    
    /******************************************************************************************************************************************************
     The PelIdInsert method updates the PEL_ID__c, PEL_Type__c, and TLSP_Supplier_Extension__c fields of Price_Evaluation_List__c
     records based on the matching contract period and contract name prefix.
     ******************************************************************************************************************************************************/
    Public static void PelIdInsert(List<Price_Evaluation_List__c> priceRecordList){
        LIST<Contract_Period__c> contractOptionList = [Select Id, Name, Period_Begin_Date__c , Period_End_Date__c,Contract_Period_ID__c ,Period_ID__c ,Period_Active__c,Contract_Period_Active__c from Contract_Period__c];
        
        For(Contract_Period__c contractRecords : contractOptionList){
            for(Price_Evaluation_List__c priceRecords : priceRecordList ){
                if(contractRecords.Name == priceRecords.Name && contractRecords.Period_Begin_Date__c <= date.today() && contractRecords.Period_End_Date__c >= date.today() && contractRecords.Period_Active__c == 'ACTIVE' && contractRecords.Contract_Period_Active__c == 'ACTIVE'){
                    priceRecords.PEL_ID__c = contractRecords.Contract_Period_ID__c;}
            }
            
        }
        
        for(Price_Evaluation_List__c priceRecords : priceRecordList ){
            string contractId = priceRecords.Name;
            
            if(ContractId.startsWith('FES')){
                priceRecords.PEL_Type__c = 'FES';
                priceRecords.TLSP_Supplier_Extension__c = 'WSD';
            }
            if(ContractId.startsWith('SOE')){
                priceRecords.PEL_Type__c = 'SOE';
                priceRecords.TLSP_Supplier_Extension__c = 'DAR';
            }
        }  
    }
    
    /******************************************************************************************************************************************************
    The lookups method assigns the Bid_Supplier__c and Supplier_Part_Number__c lookup fields of Price_Evaluation_List__c records based 
    on corresponding Account and Product2 records. It does this by creating maps from the names and part numbers to their respective IDs.
   *****************************************************************************************************************************************************/
    //lookups of bid supplier and supplier part Number 
    public static void lookups(List<Price_Evaluation_List__c> evaluationRecordList){
        set<string>nameset=new set<string>();
        set<string>productNameSet=new set<string>();
        for(Price_Evaluation_List__c p:evaluationRecordList){
            nameset.add(p.Bid_Supplier_Text__c);
            productNameSet.add(p.Supplier_Part_Number_Text__c);
        }
        Map<String,Id> AccountMap = new Map<String,Id>();
        List<Account> AccountList = [select Id,Name from Account where name IN:nameset ];
        
        for(Account accountRecords : AccountList){
            AccountMap.put(accountRecords.Name , accountRecords.Id);
        }
        
        Map<String,Id> ProductMap = new Map<String,Id>();
        List<Product2> productList = [select Id,ProductCode,Vendor_Part_Number__c from Product2 where  Vendor_Part_Number__c IN: productNameSet ];
        for(Product2 productRecords : productList){
            ProductMap.put(productRecords.Vendor_Part_Number__c , productRecords.Id);
        }
        
        for (Price_Evaluation_List__c PELRecords : evaluationRecordList){
            if(AccountMap.containsKey(PELRecords.Bid_Supplier_Text__c)){
                PELRecords.Bid_Supplier__c = AccountMap.get(PELRecords.Bid_Supplier_Text__c);
            }
            if(ProductMap.containsKey(PELRecords.Supplier_Part_Number_Text__c)){
                PELRecords.Supplier_Part_Number__c = ProductMap.get(PELRecords.Supplier_Part_Number_Text__c);
            }
        }
        
    }
    
    
}