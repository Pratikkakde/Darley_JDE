@isTest
public class Pricing_Matrix_TriggerHandler_test {

    @isTest
    public static void changeName_testMethod(){
        
        Tier__c tc = new Tier__c();
        tc.Name='test Name';
        tc.Tier_del__c='Tier 9';
        tc.Contract_Type__c ='TLS SOE';
        insert tc;
        
        Pricing_Matrix__c newListPricingMatrix = new Pricing_Matrix__c();
        newListPricingMatrix = TestDataUtilClass.getPricingMatrix();
        newListPricingMatrix.Tier__c = tc.Id;
        
        Test.startTest();    
        insert newListPricingMatrix;
        Test.stopTest();
        
    }
    
    @isTest
    public static void updateFieldsCost_High_EndOnUpdateRecord_testMethod(){
        
        Tier__c tc = new Tier__c();
        tc.Name='test Name';
        tc.Tier_del__c='Tier 9';
        tc.Contract_Type__c ='TLS SOE';
        insert tc;
        
        Tier__c tc1 = new Tier__c();
        tc1.Name='test Name1';
        tc1.Tier_del__c='Tier 9';
        tc1.Contract_Type__c ='TLS SOE';
        insert tc1;
        
        List<Pricing_Matrix__c> priceMatrixList = new List<Pricing_Matrix__c>();
        
        Pricing_Matrix__c newListPricingMatrix = new Pricing_Matrix__c();
        newListPricingMatrix = TestDataUtilClass.getPricingMatrix();
        newListPricingMatrix.Tier__c = tc.Id;
        newListPricingMatrix.Effective_Date_From__c = Date.Today()+1;
        newListPricingMatrix.Effective_Date_Thru__c = Date.Today()+1;
        priceMatrixList.add(newListPricingMatrix);
        system.debug('Date.Today() ---> '+Date.Today());
        System.debug('newListPricingMatrix ---> '+newListPricingMatrix);
        System.debug('newListPricingMatrix Active_Tier__c---> '+newListPricingMatrix.Active_Tier__c);
        
        Pricing_Matrix__c newListPricingMatrix1 = new Pricing_Matrix__c();
        newListPricingMatrix1 = TestDataUtilClass.getPricingMatrix();
        newListPricingMatrix1.Tier__c = tc1.Id;
        newListPricingMatrix1.Effective_Date_From__c = Date.Today()+1;
        newListPricingMatrix1.Effective_Date_Thru__c = Date.Today()+1;
        priceMatrixList.add(newListPricingMatrix1);
        
        insert priceMatrixList;
        
        Test.startTest();    
        priceMatrixList[0].Effective_Date_From__c = Date.Today();
        priceMatrixList[0].Effective_Date_Thru__c = Date.Today();
        priceMatrixList[1].Effective_Date_From__c = Date.Today();
        priceMatrixList[1].Effective_Date_Thru__c = Date.Today();
        update priceMatrixList;
        
        Test.stopTest();
        
    }
    
}