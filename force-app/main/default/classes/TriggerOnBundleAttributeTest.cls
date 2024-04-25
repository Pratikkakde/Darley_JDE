@isTest
public class TriggerOnBundleAttributeTest {
    
    @isTest
    public static void myTriggerTest(){
        
        Attributes__c att = new Attributes__c(Name='AIR FLOW INDICATOR',Bundle_Sequence__c=855);
        insert att;
        
        Product_Bundle__c pBundle = new Product_Bundle__c(Name='1.25AGE 2023');
        insert pBundle;
        
        List<Bundle_Attributes__c> bAttributesList = new List<Bundle_Attributes__c>();
        Bundle_Attributes__c bAttribute = new Bundle_Attributes__c(Name='AIR FLOW INDICATOR_ 1.25AGE 2023',
                                                                  Attributes_text__c='AIR FLOW INDICATOR',Bundle_Sequence__c=855,
                                                                  Is_Numeric__c='N',Product_Bundle_Text__c='1.25AGE 2023',
                                                                  Required__c='O',Product_Bundle__c=pBundle.Id,
                                                                  Attributes__c=att.Id);
        bAttributesList.add(bAttribute);
        insert bAttributesList;

    }

}