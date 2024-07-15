/******************************************************************************************************************************************************
Name                    : Pricing_Matrix_TriggerHandler
Author                  : Melonleaf
Purpose                 : This  class is written to maintain the record of the pricing matrix and link then to the tier object as per the criteria .

Description             :
Version                 : 1.0
Change Log              : 
Test Class              : Pricing_Matrix_TriggerHandler_test
CreateDate              : 25-05-2024
LastModifiedDate        : 25-05-2024
******************************************************************************************************************************************************/
public class Pricing_Matrix_TriggerHandler {
    /******************************************************************************************************************************************************
     * This method is fired on the before event ,We are assign the name of the Pricing Matrix from the parent name Tier
/******************************************************************************************************************************************************/

    
    Public static void changeName(List<Pricing_Matrix__c> newListPricingMatrix){
        set<id>tierIdset=new set <id>();
        for(Pricing_Matrix__c p:newListPricingMatrix){
            tierIdset.add(p.tier__C);
        }
        
        map<id,tier__C>pricingMap=new map<id,tier__C>([Select id,name from tier__C where id In:tierIdset]);
        If(!newListPricingMatrix.isEmpty()){
            For(Pricing_Matrix__c pMatrix :newListPricingMatrix){
                if(pricingMap.containskey(pMatrix.tier__c)){

                    pMatrix.name = pricingMap.get(pMatrix.tier__c).name.substringAfter(' ').trim();
                }
            }
        }
    }
      /******************************************************************************************************************************************************
     * This method is fired on the before event on insert ,We are updating the highcost end field of the pricing matrix base of the tier and the low cost end  
     
     /******************************************************************************************************************************************************/
    Public static void updateFieldsCost_High_End(List<Pricing_Matrix__c> newListPricingMatrix){
        List<Pricing_Matrix__c> listSendToQuable = new List<Pricing_Matrix__c>();
        If(!newListPricingMatrix.isEmpty()){
            For(Pricing_Matrix__c varPRice :newListPricingMatrix){
                IF(varPRice.Active_Tier__c == true ){
                    listSendToQuable.add(varPRice);
                }
            }
            
        }
        IF(!listSendToQuable.isEmpty()){
            System.enqueueJob(new QueueableClassPricingMatrixHighCost(listSendToQuable));
            
        }
        
        
    }
    /******************************************************************************************************************************************************
         * This method is fired on the before event on update ,We are updating the highcost end field of the pricing matrix base of the tier and the low cost end  

    ******************************************************************************************************************************************************/
    public static void updateFieldsCost_High_EndOnUpdateRecord(List<Pricing_Matrix__c> newListPricingMatrix,Map<Id,Pricing_Matrix__c> oldValueMap){
        List<Pricing_Matrix__c> listSendToQuable = new List<Pricing_Matrix__c>();
        If(!newListPricingMatrix.isEmpty()){
            For(Pricing_Matrix__c varPRice :newListPricingMatrix){
                IF(varPRice.Active_Tier__c==TRue && (varPRice.Active_Tier__c!= oldValueMap.get(varPRice.id).Active_Tier__c || varPRice.Cost_Low_End__c != oldValueMap.get(varPRice.id).Cost_Low_End__c)){
                    
                    listSendToQuable.add(varPRice);
                }
            }
            
        }
        IF(!listSendToQuable.isEmpty()){
            System.enqueueJob(new QueueableClassPricingMatrixHighCost(listSendToQuable));
            
        }
        
    }
    /******************************************************************************************************************************************************
     * This method is fired on the before event on update ,We are updating the OrderPosition__c  field of the pricing matrix if the tier is change or the ref field is change 

    ******************************************************************************************************************************************************/
    public static void updateOrderChange(List<Pricing_Matrix__c> newListPricingMatrix){
        
        set<ID> tierID = new set<ID>();
        
        If(!newListPricingMatrix.isEmpty()){
            For(Pricing_Matrix__c varPrie : newListPricingMatrix){
                If(varPrie.Tier__c!=null){
                    tierID.add(varPrie.Tier__c);
                }
            }
        }
        
        Map<Id,Tier__c>  parentRecord = new  Map<Id,Tier__c>([select Id, name, Tier_del__c From Tier__c where ID  In:tierID]);
        If(!newListPricingMatrix.isEmpty()){
            For(Pricing_Matrix__c varPrie : newListPricingMatrix){
                If(varPrie.Tier__c!=null){
                    String strvar = parentRecord.get(varPrie.Tier__c).Tier_del__c;
                    string removethespace =strvar.remove(' ');
                    varPrie.OrderPosition__c=Integer.valueOf(removethespace.removeStart('Tier'));
                }
            }
        }        
    }
     
     /******************************************************************************************************************************************************
     * This method is fired on the before event on update ,adding the error if the pricing matrix is the only child active on the tier
    ******************************************************************************************************************************************************/
    public static void addErrorForTostopFromActivaion(List<Pricing_Matrix__c> newListPricingMatrix){
        Set<Id> tierIdParent = new Set<ID>();
        If(!newListPricingMatrix.isEmpty()){
            For(Pricing_Matrix__c priceVar : newListPricingMatrix){
                If(priceVar.Tier__c!=null){
                    tierIdParent.add(priceVar.Tier__c);
                }
            }
        }
        
        Map<Id,List<ID>> mapIdWithActivePrice = new Map<Id,List<ID>>();
            For(Tier__c tierVar :[select Id, name, Tier_del__c , (select Effective_Date_From__c	, Effective_Date_Thru__c	from Pricing_Matrices__r where Active_Tier__c=True) From Tier__c where ID  In :tierIdParent ] ){
                If(tierVar.Pricing_Matrices__r.size()==1){
                    For(Pricing_Matrix__c varPRicemat :tierVar.Pricing_Matrices__r){
                        If(mapIdWithActivePrice.containsKey(tierVar.id)){
                            mapIdWithActivePrice.get(tierVar.id).add(varPRicemat.Id);
                        }
                        else{
                          
                            mapIdWithActivePrice.put(tierVar.Id,new List<ID>{varPRicemat.Id});
                        }
                    }
                    
                }
            }
        
        Date vardate=system.today();
        If(!newListPricingMatrix.isEmpty()){
            For(Pricing_Matrix__c priceVar : newListPricingMatrix){
                If(priceVar.Tier__c!=null && mapIdWithActivePrice.containsKey(priceVar.Tier__c)  && priceVar.Effective_Date_Thru__c<vardate && mapIdWithActivePrice.get(priceVar.Tier__c).contains(priceVar.Id) ){
                    priceVar.addError('Their is only a Active Tier present can not Deactive this record ');
                }
            }
        }    
    }
    
}