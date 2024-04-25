/**
 * Created by Piotr Harbunou on 8/29/2023.
 */

public without sharing class B2BQuoteTriggerHandler implements B2BITriggerHandler {

    public static Boolean TriggerDisabled =  false;

    public void beforeInsert(List<sObject> newList) {}

    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) {}

    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {}

    public void afterInsert(List<sObject> newList, Map<Id, sObject> newMap) {}

    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) {
        updateOpportunity((Map<Id, Quote__c>)newMap, (Map<Id, Quote__c>)oldMap);
    }

    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {}

    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {}

    public Boolean isDisabled() {
        return TriggerDisabled;
    }

    private static void updateOpportunity(Map<Id, Quote__c> newMap, Map<Id, Quote__c> oldMap) {
        List<Id> quoteIds = new List<Id>();
        for (Id quoteId : newMap.keySet()) {
            if (newMap.get(quoteId).Estimated_Quote_Total__c != oldMap.get(quoteId).Estimated_Quote_Total__c
                || newMap.get(quoteId).B2BDarleyCost__c != oldMap.get(quoteId).B2BDarleyCost__c
            ) {
                quoteIds.add(quoteId);
            }
        }

        if (!quoteIds.isEmpty()) {
            List<Opportunity> opportunities = [
                SELECT Id, Amount, B2BQuote__c, B2BQuote__r.Account__c
                FROM Opportunity
                WHERE B2BQuote__c IN :quoteIds
            ];

            Map<Id, String> opportunityNameByQuoteId = getOpportunityName(quoteIds);
            for (Opportunity opportunity : opportunities) {
                opportunity.Amount = newMap.get(opportunity.B2BQuote__c).Estimated_Quote_Total__c;
                opportunity.Darley_Cost__c = newMap.get(opportunity.B2BQuote__c).B2BDarleyCost__c;
                opportunity.Name = opportunityNameByQuoteId.get(opportunity.B2BQuote__c);
            }

            Database.update(opportunities, false);
        }

    }

    private static Map<Id, String> getOpportunityName(List<Id> quoteIds) {
        Map<Id, String> opportunityNameByQuoteId = new Map<Id, String>();
        Map<Id, Decimal> unitPriceMaxByQuoteId = new Map<Id, Decimal>();

        for (QuoteItem__c quoteItem : [
            SELECT Id, UnitPrice__c, Quote__c, Product__r.Name, Quote__r.Account__r.Name
            FROM QuoteItem__c
            WHERE Quote__c IN :quoteIds
                AND UnitPrice__c != NULL
        ]) {
            if (opportunityNameByQuoteId.containsKey(quoteItem.Quote__c) && unitPriceMaxByQuoteId.containsKey(quoteItem.Quote__c)) {
                if (quoteItem.UnitPrice__c > unitPriceMaxByQuoteId.get(quoteItem.Quote__c)) {
                    opportunityNameByQuoteId.put(quoteItem.Quote__c, B2BOpportunityService.getOpportunityName(quoteItem.Quote__r.Account__r.Name, quoteItem.Product__r.Name));
                    unitPriceMaxByQuoteId.put(quoteItem.Quote__c, quoteItem.UnitPrice__c);
                }
            } else {
                opportunityNameByQuoteId.put(quoteItem.Quote__c, B2BOpportunityService.getOpportunityName(quoteItem.Quote__r.Account__r.Name, quoteItem.Product__r.Name));
                unitPriceMaxByQuoteId.put(quoteItem.Quote__c, quoteItem.UnitPrice__c);
            }
        }

        return opportunityNameByQuoteId;
    }

}