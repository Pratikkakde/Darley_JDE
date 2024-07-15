/******************************************************************************************************************************************************
Name                    : QueueableClassPricingMatrixHighCost
Author                  : Melonleaf


Description             :This class is fired from the Pricing_Matrix_TriggerHandler on the update and insert event we are updating the Cost_High_End__c of pricing matrix 
                         base on the parent and 
Version                 : 1.0
Change Log              : 
Test Class              : Pricing_Matrix_TriggerHandler_test
CreateDate              : 25-05-2024
LastModifiedDate        : 25-05-2024
******************************************************************************************************************************************************/
public class QueueableClassPricingMatrixHighCost implements Queueable {
    // For giving the value to the pricing matrix to low end and  the high end when the Pricing matrix is created and updated this class run 
    public List<Pricing_Matrix__c> pricingMatrixList;
    
    public QueueableClassPricingMatrixHighCost(List<Pricing_Matrix__c> pricingMatrixList) {
        this.pricingMatrixList = pricingMatrixList;
    }
    
    public void execute(QueueableContext context) {
        
        Map<Id,Pricing_Matrix__c> mapPricMatrix = new Map<Id,Pricing_Matrix__c>(pricingMatrixList);
        Map<Id,Pricing_Matrix__c> mapPricMatrixForUpdate = new Map<Id,Pricing_Matrix__c>(pricingMatrixList);
        Map<String,List<Pricing_Matrix__c>> mapPriceMatrixContractType = new Map<String,List<Pricing_Matrix__c>>();
        List<String> ContactType = new List<String>();
        For(Pricing_Matrix__c varPricMat : mapPricMatrix.values()){
            system.debug(varPricMat);
            If(!ContactType.contains(varPricMat.Contract_Types__c)){
                            system.debug(varPricMat.Contract_Types__c);

                ContactType.add(varPricMat.Contract_Types__c);
            }
        }
        
        //List<Tier__c> parentRecord = new  List<Tier__c>([select Id, name, Tier_del__c From Tier__c where ID  In (select Tier__c From Pricing_Matrix__c where id In: pricingMatrixList)]);
        
        
        For(String strVarCont : ContactType){
            system.debug(strVarCont);
                    List<Pricing_Matrix__c> recotdpresentInDataBase =new  List<Pricing_Matrix__c>();

            recotdpresentInDataBase=[select Cost_Low_End__c, Cost_High_End__c, ID , Contract_Types__c, Tiers__c from Pricing_Matrix__c where Contract_Types__c=: strVarCont AND Active_Tier__c=True   order by  OrderPosition__c,id asc];
            system.debug(recotdpresentInDataBase);
        List<Pricing_Matrix__c> recotdpresentInDataBaseCopy =new  List<Pricing_Matrix__c>(recotdpresentInDataBase);
            mapPriceMatrixContractType.put(strVarCont,recotdpresentInDataBaseCopy);
            recotdpresentInDataBase.clear();
        }
        
        
    system.debug(mapPriceMatrixContractType);       
        For(String contractTy : mapPriceMatrixContractType.keyset()){
            
            
            Integer sizeOfList= mapPriceMatrixContractType.get(contractTy).size();
            For(Pricing_Matrix__c pricVar :mapPriceMatrixContractType.get(contractTy)){
                IF(sizeOfList > mapPriceMatrixContractType.get(contractTy).indexOf(pricVar)+1){
                    If(mapPriceMatrixContractType.get(contractTy).get(mapPriceMatrixContractType.get(contractTy).indexOf(pricVar)+1).Cost_Low_End__c!= null){
                        IF(mapPricMatrix.containskey(pricVar.ID)){
                            pricVar.Cost_High_End__c=mapPriceMatrixContractType.get(contractTy).get(mapPriceMatrixContractType.get(contractTy).indexOf(pricVar)+1).Cost_Low_End__c-0.01;
                            mapPricMatrixForUpdate.put(pricVar.Id,pricVar);
                            IF(mapPriceMatrixContractType.get(contractTy).indexOf(pricVar)!=0){
                                IF(mapPricMatrixForUpdate.containsKey( mapPriceMatrixContractType.get(contractTy)[mapPriceMatrixContractType.get(contractTy).indexOf(pricVar)-1].Id)){
                                    mapPricMatrixForUpdate.get(mapPriceMatrixContractType.get(contractTy)[mapPriceMatrixContractType.get(contractTy).indexOf(pricVar)-1].Id).Cost_High_End__c=pricVar.Cost_Low_End__c-0.01;
                                }else{
                                    mapPriceMatrixContractType.get(contractTy).get(mapPriceMatrixContractType.get(contractTy).indexOf(pricVar)-1).Cost_High_End__c=pricVar.Cost_Low_End__c-0.01;
                                    mapPricMatrixForUpdate.put( mapPriceMatrixContractType.get(contractTy).get(mapPriceMatrixContractType.get(contractTy).indexOf(pricVar)-1).Id,mapPriceMatrixContractType.get(contractTy).get(mapPriceMatrixContractType.get(contractTy).indexOf(pricVar)-1));
                                }
                            }
                        }
                        
                    }
                }
                IF(mapPriceMatrixContractType.get(contractTy).size()==mapPriceMatrixContractType.get(contractTy).indexOf(pricVar)+1 && mapPriceMatrixContractType.get(contractTy).size()>=3){
                    mapPriceMatrixContractType.get(contractTy)[mapPriceMatrixContractType.get(contractTy).size()-2].Cost_High_End__c=mapPriceMatrixContractType.get(contractTy)[mapPriceMatrixContractType.get(contractTy).size()-1].Cost_Low_End__c-0.01;
                    mapPricMatrixForUpdate.put(mapPriceMatrixContractType.get(contractTy)[mapPriceMatrixContractType.get(contractTy).size()-2].Id,mapPriceMatrixContractType.get(contractTy)[mapPriceMatrixContractType.get(contractTy).size()-2]);
                }
                IF(mapPriceMatrixContractType.get(contractTy).size()==mapPriceMatrixContractType.get(contractTy).indexOf(pricVar)+1 && mapPriceMatrixContractType.get(contractTy).size()==2){
                    mapPriceMatrixContractType.get(contractTy)[0].Cost_High_End__c=mapPriceMatrixContractType.get(contractTy)[1].Cost_Low_End__c-0.01;
                    mapPricMatrixForUpdate.put(mapPriceMatrixContractType.get(contractTy)[0].Id,mapPriceMatrixContractType.get(contractTy)[0]);
                }
            }
        }
        DataBase.saveResult[] saveResult = database.update(mapPricMatrixForUpdate.values(),False);
        for (Database.SaveResult sr : saveResult) {
            if (sr.isSuccess()) { 
                System.debug( sr.getId()); 
            }else{
                for(Database.Error err : sr.getErrors()) {
                    System.debug(err.getStatusCode() + ' : ' +err.getMessage() + ' : ' + err.getFields());
                }
            }
        }
    }
}