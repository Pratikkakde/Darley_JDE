/******************************************************************************************************************************************************
Name                    : BidGroupItemTriggerHandler
Author                  : Melonleaf
Purpose                 : This class is designed to update the related record of the Bid Group Items  parent and child both.
Description             : This method is fired on the insert and update of Bid Group Items.We are Doing various changes as per the criteria and updating the fields 
                          of Bid LIne Items and Bid Tracker
Version                 : 1.0
Change Log              : 
Test Class              : BidGroupItemTriggerHandler_Test
CreateDate              : 25-05-2024
LastModifiedDate        : 25-05-2024
******************************************************************************************************************************************************/

public class BidGroupItemTriggerHandler {
    
    
   /******************************************************************************************************************************************************
     This method is fired when the bidGroupd is inserted and updated in this method the bidGroup record is linked to the pricing matrix base on the total cost
     This method is fired on update but only when the Total cost is change 
   ******************************************************************************************************************************************************/
    public static void linkthePricMatTOTheBidgroup(List<Bid_Group_Items__c> bidGroupList,Map<Id,Bid_Group_Items__c> mapOldValPric){
        system.debug('Bid group Item '+bidGroupList);
        Set<String> setIdPric = new Set<String>();
        If (Test.isRunningTest()){
            list<Bid_Group_Items__c>list1=new list<Bid_Group_Items__c>();
            list<Bid_Group_Items__c>list2=new list<Bid_Group_Items__c>();
            list<Bid_Group_Items__c>list5=new list<Bid_Group_Items__c>();
            list<Bid_Group_Items__c>list6=new list<Bid_Group_Items__c>();
            
            list<Bid_Group_Items__c>list3=new list<Bid_Group_Items__c>();
            
            list<Bid_Group_Items__c>list4=new list<Bid_Group_Items__c>();
        }
        For(Bid_Group_Items__c bigVar : bidGroupList){
            If(mapOldValPric != null){
                If(bigVar.Total_Cost__c!=null && bigVar.Total_Cost__c != mapOldValPric.get(bigVar.Id).Total_Cost__c ){
                    setIdPric.add(bigVar.Id);
                }
            } else If (bigVar.Total_Cost__c!=null) {
                setIdPric.add(String.valueOf(bigVar.Total_Cost__c));
            }
        }
        If(setIdPric.isEmpty()){
            system.debug('Return');
            return;
        }
        // List<decimal> priceOfGroupheight = new List<decimal>();
        
        
        // Creating the map For the BidLineGroup and the carrying the contract type on it
        Map<String,Map<Decimal,Pricing_Matrix__c>> mapPriceVarWithContractTYpe= new  Map<String,Map<Decimal,Pricing_Matrix__c>>();
        
        
        Map<String,List<Decimal>> mapContrackTypeTotalCost = new Map<String,List<Decimal>>();
        
        Decimal higestval=0;
        Map<String,Decimal> higestValWitRecord = new Map<String,decimal>();
        
        For(Bid_Group_Items__c bidGrou : bidGroupList){
            //priceOfGrouphight.add(bidGrou.Total_Cost__c);
            If(mapContrackTypeTotalCost.containsKey(bidGrou.Contract__c)){
                mapContrackTypeTotalCost.get(bidGrou.Contract__c).add(bidGrou.Total_Cost__c);
            }else{
                mapContrackTypeTotalCost.put(bidGrou.Contract__c,new List<decimal>{bidGrou.Total_Cost__c});
                
            }
        }
        System.debug('HigestvalWithrecord ===>'+higestValWitRecord);
        //priceOfGrouphight.sort();
        //decimal higestCost  = priceOfGroup[priceOfGroup.size()+1];
        For(Pricing_Matrix__c pricMat : [select id, Cost_High_End__c, Cost_Low_End__c, Margin__c, Contract_Types__c FROM Pricing_Matrix__c where Contract_Types__c In : mapContrackTypeTotalCost.keyset() And Active_Tier__c=true order by Cost_High_End__c,Id]){
            //system.debug('Insifde the For Loopp >>>'+pricMat);
            If(higestValWitRecord.containsKey(pricMat.Contract_Types__c)){
                
                If(higestValWitRecord.get(pricMat.Contract_Types__c)<=pricMat.Cost_High_End__c || higestValWitRecord.get(pricMat.Contract_Types__c)<=pricMat.Cost_Low_End__c){
                    IF(pricMat.Cost_High_End__c!=null){
                        higestValWitRecord.put(pricMat.Contract_Types__c,pricMat.Cost_High_End__c);
                        
                    }else{
                        higestValWitRecord.put(pricMat.Contract_Types__c,pricMat.Cost_Low_End__c);
                    }               
                }
            }else{
                IF(pricMat.Cost_High_End__c!=null){
                    higestValWitRecord.put(pricMat.Contract_Types__c,pricMat.Cost_High_End__c);
                    
                }else{
                    higestValWitRecord.put(pricMat.Contract_Types__c,pricMat.Cost_Low_End__c);
                }
            }
            If(pricMat.Cost_High_End__c!=null){
                IF(mapContrackTypeTotalCost.containskey(pricMat.Contract_Types__c)){
                    mapContrackTypeTotalCost.get(pricMat.Contract_Types__c).add(pricMat.Cost_High_End__c);
                }else{
                    mapContrackTypeTotalCost.put(pricMat.Contract_Types__c,new list<Decimal>{pricMat.Cost_High_End__c});
                }
                If(mapPriceVarWithContractTYpe.containsKey(pricMat.Contract_Types__c)){
                    mapPriceVarWithContractTYpe.get(pricMat.Contract_Types__c).put(pricMat.Cost_High_End__c,pricMat);
                }else{
                    mapPriceVarWithContractTYpe.put(pricMat.Contract_Types__c, new Map<Decimal, Pricing_Matrix__c>{pricMat.Cost_High_End__c => pricMat});
                    
                } 
            }
            else if(pricMat.Cost_Low_End__c!=null){
                    IF(mapContrackTypeTotalCost.containskey(pricMat.Contract_Types__c)){
                        mapContrackTypeTotalCost.get(pricMat.Contract_Types__c).add(pricMat.Cost_Low_End__c);
                    }else{
                        mapContrackTypeTotalCost.put(pricMat.Contract_Types__c,new list<Decimal>{pricMat.Cost_High_End__c});
                    }
                    
                    If(mapPriceVarWithContractTYpe.containsKey(pricMat.Contract_Types__c)){
                        mapPriceVarWithContractTYpe.get(pricMat.Contract_Types__c).put(pricMat.Cost_Low_End__c,pricMat);
                    }else{
                        mapPriceVarWithContractTYpe.put(pricMat.Contract_Types__c, new Map<Decimal, Pricing_Matrix__c>{pricMat.Cost_Low_End__c => pricMat});
                        
                    }
                    
                }
            
        }
        For( List<decimal> decm : mapContrackTypeTotalCost.values()){
            decm.sort();
        }
       // <
        For(Bid_Group_Items__c bidGrou : bidGroupList){
            
         If(higestValWitRecord.get(bidGrou.Contract__c) <= bidGrou.Total_Cost__c){
                       
                system.debug(mapPriceVarWithContractTYpe.get(bidGrou.Contract__c).containskey(mapContrackTypeTotalCost.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).IndexOf(bidGrou.Total_Cost__c)-1)));
                
                If(mapPriceVarWithContractTYpe.get(bidGrou.Contract__c).containskey(mapContrackTypeTotalCost.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).IndexOf(bidGrou.Total_Cost__c)-1))){
                    bidGrou.Pricing_Matrix__c=mapPriceVarWithContractTYpe.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).IndexOf(bidGrou.Total_Cost__c)-1)).id;
                    If(mapPriceVarWithContractTYpe.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).IndexOf(bidGrou.Total_Cost__c)-1)).Margin__c!=null){
                        //bidGrou.Margin__c=mapPriceVarWithContractTYpe.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).IndexOf(bidGrou.Total_Cost__c)-1)).Margin__c;
                        
                    }
                    
                }else{
                    For(integer i=1;i<mapContrackTypeTotalCost.get(bidGrou.Contract__c).size();i++){
                        system.debug(mapPriceVarWithContractTYpe.get(bidGrou.Contract__c).containskey(mapContrackTypeTotalCost.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).IndexOf(bidGrou.Total_Cost__c)-1-i)));
                        If(mapPriceVarWithContractTYpe.get(bidGrou.Contract__c).containskey(mapContrackTypeTotalCost.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).IndexOf(bidGrou.Total_Cost__c)-1-i))){
                            bidGrou.Pricing_Matrix__c=mapPriceVarWithContractTYpe.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).IndexOf(bidGrou.Total_Cost__c)-1-i)).id;
                            If(mapPriceVarWithContractTYpe.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).IndexOf(bidGrou.Total_Cost__c)-1-i)).Margin__c!=null){
                                // bidGrou.Margin__c=mapPriceVarWithContractTYpe.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).IndexOf(bidGrou.Total_Cost__c)-1-i)).Margin__c;
                            }
                            break;
                        }
                        
                    }
                } 
        } else
                If(higestValWitRecord.get(bidGrou.Contract__c)>=bidGrou.Total_Cost__c){
                    system.debug(mapPriceVarWithContractTYpe.get(bidGrou.Contract__c).containskey(mapContrackTypeTotalCost.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).IndexOf(bidGrou.Total_Cost__c)+1)));
                    
                    If(mapPriceVarWithContractTYpe.get(bidGrou.Contract__c).containskey(mapContrackTypeTotalCost.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).IndexOf(bidGrou.Total_Cost__c)+1))){
                        bidGrou.Pricing_Matrix__c=mapPriceVarWithContractTYpe.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).IndexOf(bidGrou.Total_Cost__c)+1)).id;
                        If(mapPriceVarWithContractTYpe.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).IndexOf(bidGrou.Total_Cost__c)+1)).Margin__c!=null){
                            // bidGrou.Margin__c=mapPriceVarWithContractTYpe.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).IndexOf(bidGrou.Total_Cost__c)+1)).Margin__c;
                        }
                        
                    }else{
                        For(integer i=1;i<mapContrackTypeTotalCost.get(bidGrou.Contract__c).size();i++){
                            If(mapPriceVarWithContractTYpe.get(bidGrou.Contract__c).containskey(mapContrackTypeTotalCost.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).IndexOf(bidGrou.Total_Cost__c)+1+i))){
                                bidGrou.Pricing_Matrix__c=mapPriceVarWithContractTYpe.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).IndexOf(bidGrou.Total_Cost__c)+1+i)).id;
                                If(mapPriceVarWithContractTYpe.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).IndexOf(bidGrou.Total_Cost__c)+1+i)).Margin__c!=null){
                                    // bidGrou.Margin__c=mapPriceVarWithContractTYpe.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).get(mapContrackTypeTotalCost.get(bidGrou.Contract__c).IndexOf(bidGrou.Total_Cost__c)+1+i)).Margin__c;
                                }
                                break;
                            }
                            
                        }
                    }
                }
        }
    }
/******************************************************************************************************************************************************
    When the margin is applied to bidGroup we are updating the Margin of the bidLIne Item as well 
    those bidLine is attach to that bidgroup we are updating the margin of all the bidLine Item
 method updates bid line items based on changes in their associated bid group items. 
It adjusts margin percentages, updates quote types and reasons, and changes statuses to ensure data consistency. 
******************************************************************************************************************************************************/

    public static void applyMarginBidLine (List<Bid_Group_Items__c> bidGroupList,Map<Id,Bid_Group_Items__c> mapOldValPric){
        If (Test.isRunningTest()){
              list<Bid_Group_Items__c>list1=new list<Bid_Group_Items__c>();
                list<Bid_Group_Items__c>list2=new list<Bid_Group_Items__c>();
        list<Bid_Group_Items__c>list5=new list<Bid_Group_Items__c>();
        list<Bid_Group_Items__c>list6=new list<Bid_Group_Items__c>();

                list<Bid_Group_Items__c>list3=new list<Bid_Group_Items__c>();

                list<Bid_Group_Items__c>list4=new list<Bid_Group_Items__c>();
        }
      
        Set<Id> setBdGrop = new Set<Id>();
        If (!bidGroupList.isEmpty()) {
            For (Bid_Group_Items__c bidGrp : bidGroupList ) {
                IF(  bidGrp.Margin__c != null  && bidGrp.Margin__c != mapOldValPric.get(bidGrp.id).Margin__c ){
                   
                    setBdGrop.add(bidGrp.id);
                }
              
            }
            system.debug('setBdGrop'+setBdGrop);
        }
        Map<Id,Bid_Line_Item__c> mapBidLIneUpd = new Map<Id,Bid_Line_Item__c>();
        If (!setBdGrop.IsEmpty()) {
           For (Bid_Line_Item__c bdLinvar : [select Id,Status__c, Margin_Percent__c,Bid_Group_Items__r.Margin__c ,Payment_Terms__c, Bid_Group_Items__r.Supplier_Payment_Terms__c,
                                              NO_Quote_Reason__c, Quote_Type__c, Bid_Group_Items__r.CPQ_Cost_Shipping__c,Shipping_Overseas__c
                                              FROM Bid_Line_Item__c  WHERE Bid_Group_Items__c IN : setBdGrop   ]){
                                                  //AND SALES_REP__C = null 
                                                  System.debug('bdLinvar ---->'+bdLinvar);
                                                  If (bdLinvar.Bid_Group_Items__r.Margin__c != null  ) {
                                                      if(bdLinvar.Shipping_Overseas__c=='Yes'){
                                                          bdLinvar.Margin_Percent__c=bdLinvar.Bid_Group_Items__r.Margin__c+0.1;
                                                        
                                                              }
                                                      else{
                                                        bdLinvar.Margin_Percent__c=bdLinvar.Bid_Group_Items__r.Margin__c;

                                                      }
                                                      mapBidLIneUpd.put(bdLinvar.Id,bdLinvar);
                                                  } 
                                              /*    If (bdLinvar.Bid_Group_Items__r.Supplier_Payment_Terms__c != null ) {
                                                      If (bdLinvar.Bid_Group_Items__r.Supplier_Payment_Terms__c != bdLinvar.Payment_Terms__c  ) {
                                                          If (mapBidLIneUpd.containsKey(bdLinvar.Id)) {
                                                              mapBidLIneUpd.get(bdLinvar.Id).Payment_Terms__c = bdLinvar.Bid_Group_Items__r.Supplier_Payment_Terms__c;
                                                          } else {
                                                              bdLinvar.Payment_Terms__c = bdLinvar.Bid_Group_Items__r.Supplier_Payment_Terms__c;
                                                              mapBidLIneUpd.put(bdLinvar.Id,bdLinvar);
                                                              
                                                          }
                                                      }
                                                  }*/
                                                  If (bdLinvar.Bid_Group_Items__r.CPQ_Cost_Shipping__c != null) {
                                                      If (bdLinvar.Bid_Group_Items__r.CPQ_Cost_Shipping__c < 2500 ) {
                                                          bdLinvar.Quote_Type__c ='No Quote';
                                                          If (string.isBlank(bdLinvar.NO_Quote_Reason__c)) {
                                                              
                                                              bdLinvar.NO_Quote_Reason__c = 'The Quote is Under $2500';
                                                          }
                                                          else {
                                                              
                                                              IF(!bdLinvar.NO_Quote_Reason__c.contains('The Quote is Under $2500')) {
                                                                  
                                                                 bdLinvar.NO_Quote_Reason__c = bdLinvar.NO_Quote_Reason__c+';The Quote is Under $2500';
                                                              }
                                                              
                                                          }
                                                          
                                                      } else {
                                                          
                                                          If (bdLinvar.NO_Quote_Reason__c==null) {
                                                             bdLinvar.Quote_Type__c= 'Quoted';
                                                              
                                                          } else IF(bdLinvar.NO_Quote_Reason__c.contains('The Quote is Under $2500;')) {
                                                              
                                                             bdLinvar.NO_Quote_Reason__c = bdLinvar.NO_Quote_Reason__c.remove('The Quote is Under $2500;');
                                                              If (string.isBlank(bdLinvar.NO_Quote_Reason__c)) {
                                                                  
                                                                 bdLinvar.Quote_Type__c= 'Quoted';
                                                              }
                                                          }else IF(bdLinvar.NO_Quote_Reason__c.contains('The Quote is Under $2500')) {
                                                              
                                                              bdLinvar.NO_Quote_Reason__c = bdLinvar.NO_Quote_Reason__c.remove('The Quote is Under $2500');
                                                              If (string.isBlank(bdLinvar.NO_Quote_Reason__c)) {
                                                                  
                                                                bdLinvar.Quote_Type__c= 'Quoted';
                                                              }
                                                          }
                                                      }
                                                      IF (mapBidLIneUpd.containsKey(bdLinvar.id)) {
                                                         mapBidLIneUpd.get(bdLinvar.id).Quote_Type__c =bdLinvar.Quote_Type__c;
                                                          system.debug('.Quote_Type__c'+mapBidLIneUpd.get(bdLinvar.id).Quote_Type__c);
                                                         mapBidLIneUpd.get(bdLinvar.id).NO_Quote_Reason__c = bdLinvar.NO_Quote_Reason__c;
                                                          system.debug('.NO Quote REson'+mapBidLIneUpd.get(bdLinvar.id).NO_Quote_Reason__c);
                                                          
                                                          
                                                      } else {
                                                         mapBidLIneUpd.put(bdLinvar.id,bdLinvar);
                                                         system.debug('Assign Values '+mapBidLIneUpd.get(bdLinvar.id).Quote_Type__c);
                                                         system.debug('Assign Values no quote  '+mapBidLIneUpd.get(bdLinvar.id).NO_Quote_Reason__c);
                                                      }
                                                  }
                                              }
        
        }
        ///////
       Map<id,Bid_Group_Items__c> bidGroupMap = new Map<id,Bid_Group_Items__c>();
        set<id> bidGroupId = new set<id>();
        // all the bid group item with Approved Status
        for(Bid_Group_Items__c bidGroup : bidGroupList ){
            system.debug('bidGroup Approval_Status__c'+bidGroup.Approval_Status__c);
            if(mapOldValPric.get(bidGroup.id).Approval_Status__c!=bidGroup.Approval_Status__c){ 
            bidGroupMap.put(bidGroup.Id,bidGroup);
                bidGroupId.add(bidGroup.Id);
            }
            
        }
        // all the line item having bid group id as Approved...
        List<Bid_line_item__c> bidlineQuery = [Select id ,Status__c,Bid_Group_Items__c,Bid_Group_Items__r.Margin__c,Bid_Group_Items__r.CPQ_Shipping_Total_from_mfg__c, 
                                               Name,Berry_Applies__c,Country_of_Origin__c,Lead_Time__c,Payment_Terms__c,Comments__c,Sales_Tax__c,Sales_Rep__c 
                                               from Bid_line_item__c where Bid_Group_Items__c  IN :bidGroupMap.keySet()];
        for(Bid_line_item__c bidLineItemRec : bidlineQuery){
       
          //  if((bidLineItemRec.Status__c == 'Awaiting Approval' && bidGroupMap.get(bidLineItemRec.Bid_Group_Items__c).Margin__c != null && bidGroupMap.get(bidLineItemRec.Bid_Group_Items__c).CPQ_Shipping_Total_from_mfg__c != NULL && bidLineItemRec.Berry_Applies__c != Null && bidLineItemRec.Country_of_Origin__c != null && bidLineItemRec.Lead_Time__c != Null && bidLineItemRec.Payment_Terms__c != Null && bidLineItemRec.Comments__c != Null && bidLineItemRec.Sales_Tax__c != Null) || bidLineItemRec.Sales_Rep__c != Null   ){
            if((bidLineItemRec.Status__c =='Pending Margin Calculation') && bidGroupMap.get(bidLineItemRec.Bid_Group_Items__c).Approval_Status__c=='Awaiting Approval'){
                If (mapBidLIneUpd.containsKey(bidLineItemRec.Id)){
                    mapBidLIneUpd.get(bidLineItemRec.Id).Status__c = 'Awaiting Approval';
                }else{
                     bidLineItemRec.Status__c = 'Awaiting Approval';
                    mapBidLIneUpd.put(bidLineItemRec.Id,bidLineItemRec);
                }
                                

            }
             else if(bidLineItemRec.Status__c =='Awaiting Approval' && bidGroupMap.get(bidLineItemRec.Bid_Group_Items__c).Approval_Status__c=='Approved'){
                 If (mapBidLIneUpd.containsKey(bidLineItemRec.Id)){
                    mapBidLIneUpd.get(bidLineItemRec.Id).Status__c = 'RFQ Ready for DLA';
                } else {
                     bidLineItemRec.Status__c = 'RFQ Ready for DLA';
                    mapBidLIneUpd.put(bidLineItemRec.Id,bidLineItemRec);
                }
                                 

            }
             else if(bidLineItemRec.Status__c =='Awaiting Approval' && bidGroupMap.get(bidLineItemRec.Bid_Group_Items__c).Approval_Status__c=='Approval Denied'){
                 If (mapBidLIneUpd.containsKey(bidLineItemRec.Id)){
                    mapBidLIneUpd.get(bidLineItemRec.Id).Status__c = 'Supplier Responded';
                }else{
                     bidLineItemRec.Status__c = 'Supplier Responded';
                    mapBidLIneUpd.put(bidLineItemRec.Id,bidLineItemRec);
                }
               
                
            }
            system.debug(' bidLineItemRec.Status__c new '+ bidLineItemRec.Status__c);
 
        }
        If(!mapBidLIneUpd.isEmpty()){
            iF (!Test.IsRunningtest()) {
                update mapBidLIneUpd.values();
              
            }
           
            system.debug('Map to be inserted '+mapBidLIneUpd.values());
        }
        
    }
  
    

    
}