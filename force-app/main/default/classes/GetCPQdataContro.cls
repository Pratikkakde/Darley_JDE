public class GetCPQdataContro {
    @AuraEnabled
    public static void updateTheBidLIneAndTracWithQuoteAndLIne(Id idBidTracker){
        system.debug(idBidTracker);
        Bid_Tracker__c bidTracVar = [SELECT Id, Name, CPQ_Quote_Number__c   ,
                                     (SELECT Id, Unit_Cost__c, Margin_Percent__c, Berry_Compliant__c, Country_of_Origin__c,Supplier_Part_Number__c,Bid_Group_Items__c,
                                      Weeks_ARO__c, Payment_Terms__c, Comments__c, Sales_Tax__c, Berry_Applies__c, ServiceNow_State__c,Country__c, Sales_Rep__c
                                      FROM Bid_Items__r)
                                     FROM Bid_Tracker__c where Id = :idBidTracker  Limit 1];
       
       
        List<SBQQ__Quote__c> quoteVar = [SELECT Id,Name, SBQQ__ShippingState__c, SBQQ__ShippingCountry__c, SBQQ__SalesRep__c,
                                         (SELECT Id, Shipping_each__c, MarginPercent__c, SBQQ__Quote__r.SBQQ__SalesRep__c,SBQQ__Quote__r.SBQQ__ShippingCountry__c,
                                          Country_of_Origin__c,Vendor_Part_Number__c,  SBQQ__UnitCost__c, Berry_Applicable__c, SBQQ__Description__c,
                                          Lead_Time__c, Supplier_Payment_Terms__c, SBQQ__NetPrice__c, Total_Cost__c, Cost_wShipping__c, SBQQ__Quote__r.SBQQ__ShippingState__c,
                                          Sales_Tax__c, Sales_Tax_Amount__c,
                                          SBQQ__Group__r.Payment_Terms__c, SBQQ__Group__r.Margin__c, SBQQ__Group__r.Shipping_Total_from_mfg__c
                                          FROM SBQQ__LineItems__r)
                                         
                                         FROM SBQQ__Quote__c where Name =:bidTracVar.CPQ_Quote_Number__c limit 1 ];
        If (!quoteVar.isEmpty() ){  
            system.debug(quoteVar[0]);
            Map<String,SBQQ__QuoteLine__c> mapStrQuoteLIne = new Map<String,SBQQ__QuoteLine__c>();
            For (SBQQ__QuoteLine__c qtLIneVar : quoteVar[0].SBQQ__LineItems__r ) {
                system.debug(qtLIneVar);
                mapStrQuoteLIne.put(qtLIneVar.Vendor_Part_Number__c,qtLIneVar);
            }
            Map<Id,Bid_LIne_Item__c> mapIdBidLIneUpatee = new Map<Id,Bid_LIne_Item__c>();
            Map<Id,Bid_Group_Items__c> mapIdGroupLiUpatee = new Map<Id,Bid_Group_Items__c>();
            For (Bid_LIne_Item__c bidVar : bidTracVar.Bid_Items__r ) {
                If (mapStrQuoteLIne.containskey(bidVar.Supplier_Part_Number__c) ) {
                    bidVar.Margin_Percent__c = mapStrQuoteLIne.get(bidVar.Supplier_Part_Number__c).MarginPercent__c;
                    bidVar.Country_of_Origin__c = mapStrQuoteLIne.get(bidVar.Supplier_Part_Number__c).Country_of_Origin__c;
                    bidVar.Weeks_ARO__c = mapStrQuoteLIne.get(bidVar.Supplier_Part_Number__c).Lead_Time__c+'W';
                    If (mapStrQuoteLIne.get(bidVar.Supplier_Part_Number__c).Berry_Applicable__c ==True) {
                        bidVar.Berry_Applies__c ='Yes';
                    }else {
                        bidVar.Berry_Applies__c ='No';
                    }
                   
                    bidVar.Payment_Terms__c = mapStrQuoteLIne.get(bidVar.Supplier_Part_Number__c).Supplier_Payment_Terms__c;
                    bidVar.Comments__c = mapStrQuoteLIne.get(bidVar.Supplier_Part_Number__c).SBQQ__Description__c;
                    bidVar.Unit_Cost__c = mapStrQuoteLIne.get(bidVar.Supplier_Part_Number__c).SBQQ__UnitCost__c;
                    bidVar.Sales_Rep__c = mapStrQuoteLIne.get(bidVar.Supplier_Part_Number__c).SBQQ__Quote__r.SBQQ__SalesRep__c;
                    bidVar.Country__c = mapStrQuoteLIne.get(bidVar.Supplier_Part_Number__c).SBQQ__Quote__r.SBQQ__ShippingCountry__c;
                    bidVar.ServiceNow_State__c = mapStrQuoteLIne.get(bidVar.Supplier_Part_Number__c).SBQQ__Quote__r.SBQQ__ShippingState__c;
                    mapIdBidLIneUpatee.put(bidVar.Id,bidVar);
                    Bid_Group_Items__c grpVar =  new Bid_Group_Items__c();
                    grpVar.Id = bidVar.Bid_Group_Items__c;
                    grpVar.Margin__c= mapStrQuoteLIne.get(bidVar.Supplier_Part_Number__c).SBQQ__Group__r.Margin__c;
                   // grpVar.CPQ_Shipping_Total_from_mfg__c = mapStrQuoteLIne.get(bidVar.Supplier_Part_Number__c).SBQQ__Group__r.Shipping_Total_from_mfg__c;
                  //  grpVar.Supplier_Payment_Terms__c= mapStrQuoteLIne.get(bidVar.Supplier_Part_Number__c).SBQQ__Group__r.Payment_Terms__c;
                    mapIdGroupLiUpatee.put(grpVar.Id , grpVar);
                   
                }
            }
           
            If (!mapIdBidLIneUpatee.isEmpty()) {
                system.debug(mapIdBidLIneUpatee);
                If (!Test.isRunningTest()){
                    Update mapIdBidLIneUpatee.values();
                }
               
            }
           
           
            If (!mapIdGroupLiUpatee.isEmpty()) {
                system.debug(mapIdBidLIneUpatee);
                If (!Test.isRunningTest()){
                Update mapIdGroupLiUpatee.values();
                }
            }
           
        }
       
    }
    //SELECT Id, Supplier_Name_Text__c, Unit_Cost__c, ServiceNow_State__c, Country__c, Margin_Percent__c, Berry_Compliant__c, Country_of_Origin__c,
    //  Weeks_ARO__c, Payment_Terms__c, Comments__c FROM Bid_Line_Item__c
   
}