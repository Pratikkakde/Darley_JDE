/******************************************************************************************************************************************************
Name                    : Tier_Trigger_Handler
Author                  : Melonleaf
Purpose                 : This class is call by the trigger of the tier Reocrd in update and insert 
Description             : This class is processing all the bid workbench records, checking all the sales rep condition doing csupplier cleanup
                          & creating the records of Bidtracker, Bidline items and BidGroup.
Version                 : 1.0
Change Log              : 
Test Class              : Tier_Trigger_Test
CreateDate              : 25-05-2024
LastModifiedDate        : 25-05-2024
******************************************************************************************************************************************************/
public class Tier_Trigger_Handler {
    
  /******************************************************************************************************************************************************
    This method is call on the before event .This automation works to assign the name to the tier based on the contract type.
  ******************************************************************************************************************************************************/
    Public static void nameAutoNumberAutomation(List<Tier__c> newRecordTier){
        IF(!newRecordTier.isEmpty()){
            for (Tier__c varTier : newRecordTier){
                If(varTier.Contract_Type__c!=Null && varTier.Tier_del__c!=Null){
                    IF(varTier.Contract_Type__c=='TLS FES'  ){
                        varTier.Name= 'FES' +' '+ varTier.Tier_del__c;
                    }else
                        IF(varTier.Contract_Type__c=='TLS SOE'){
                            varTier.Name= 'SOE' +' '+ varTier.Tier_del__c;
                        }else{
                            varTier.Name= varTier.Contract_Type__c +' '+ varTier.Tier_del__c;
                        }  
                }
                
            }
        }
    }
    
  /******************************************************************************************************************************************************
    This method is call on the before event .When the tier Name change we are updating the orderPosition of the pricing matrix .
  ******************************************************************************************************************************************************/
    public static void orderpositionchange(List<Tier__c> newRecordTier,Map<Id,Tier__c> mapOldvalueTier){
        List<Pricing_Matrix__c> listUpdatePric = new List<Pricing_Matrix__c>();
        Map<Id,String> mapTierID = new Map<Id,String>();
        If(!newRecordTier.isEmpty()){
            For(Tier__c tirVar : newRecordTier ) {
                If(tirVar.Tier_del__c != mapOldvalueTier.get(tirVar.Id).Tier_del__c){
                    mapTierID.put(tirVar.Id,tirVar.Tier_del__c);
                }
            }
        }
        If(!mapTierID.isEmpty()) {
            For(Pricing_Matrix__c pricVar : [SELECT Id, OrderPosition__c, Tier__c FROM Pricing_Matrix__c WHERE Tier__c IN : mapTierID.keyset()]) {
                pricVar.OrderPosition__c=Decimal.valueOf(mapTierID.get(pricVar.Tier__c).replaceAll('[a-zA-Z]','').deleteWhitespace());
                listUpdatePric.add(pricVar);
            }
        }
        
        IF(!listUpdatePric.isEmpty()){
            Update  listUpdatePric;
        }
        
        
    }
    
}