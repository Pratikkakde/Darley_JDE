/******************************************************************************************************************************************************

Name                : productTriggerHandlerTest
Author              : Pratik Kakade
Purpose             : This Apex class is designed to test the ProductInsertWebService class, which provides a RESTful web service endpoint for updating Order records in Salesforce.
Description         : The ProductInsertWebService class tests the behavior of the ProductInsertWebService class. 
It ensures that the updateOrder method correctly handles various scenarios, such as updating existing orders, handling orders that don't exist, and handling errors.
Version             : 1.1
Change Log          : Created by Pratik Kakade - 15 Jul 2024
Test Class for      : productTriggerHandler
CreateDate          : 15 Jul 2024
LastModifiedDate    : 15 Jul 2024

******************************************************************************************************************************************************/

@isTest
public class productTriggerHandlerTest {
    
    @isTest
    public static void BeforeInsertTest(){
        
        Product2 prod1 = Utility_DataCreation.CreteProducts(1)[0];
        prod1.JDE_Stocking_Type__c = 'Obsolete';
        Prod1.Record_Type__c = 'Equipment';
        
        Product2 prod2 = Utility_DataCreation.CreteProducts(1)[0];
        prod2.JDE_Stocking_Type__c = 'Obsolete - Use Up';
        prod2.Record_Type__c = 'Defense';
        
        Product2 prod3 = Utility_DataCreation.CreteProducts(1)[0];
        prod3.JDE_Stocking_Type__c = 'Raw Material';
        prod3.Record_Type__c = 'Pump';
        
        Product2 prod4 = Utility_DataCreation.CreteProducts(1)[0];
        prod4.Record_Type__c = 'Odin';
        List<Product2> proList = new List<Product2>{prod1,prod3,prod2,prod4};
            insert proList ;
        
    }
}