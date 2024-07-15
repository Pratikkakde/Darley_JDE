@isTest
public class Tier_Trigger_Test {
    
    @isTest
    public static void nameAutoNumberAutomationTests(){
        //Id recordTypeIdBidTracker = Schema.SObjectType.Tier__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
        Tier__c tc = new Tier__c();
        tc.Name='test Name';
        tc.Tier_del__c='Tier 9';
        tc.Contract_Type__c ='TLS FES';
        insert tc;
          Tier__c tc1 = new Tier__c();
        tc1.Name='test Name';
        tc1.Tier_del__c='Tier 1';
        tc1.Contract_Type__c ='TLS SOE';
        insert tc1;
        tc.Tier_del__c= 'Tier 10';
        tc1.Tier_del__c= 'Tier 10';
        update tc;
        update tc1;
        
    }
    

}