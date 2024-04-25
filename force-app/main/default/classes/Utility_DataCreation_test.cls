/*******************************************************************************************************************************************************************************************************************************
Name                : Utility_DataCreation_test
Author              : Pratik Kakade
Purpose             : This Apex class serves as a utility for creating test data. It includes methods to create account records, generate JSON data, and create order records associated with accounts.
Description         : This class contains methods to facilitate the creation of test data for various scenarios. It includes methods to create account records with specific attributes, generate JSON data for integration purposes, and create order records associated with accounts.
Version             : 1.2
Change Log          : Updated by Pratik Kakade on 19 Feb 2024
Test Class          : Utility_DataCreation
CreateDate          : 19 Feb 2024
LastModifiedDate    : 19 Feb 2024
*******************************************************************************************************************************************************************************************************************************/

@istest
public class Utility_DataCreation_test {
    
    @istest
    public static void CreateAccountRec_test() {
        
        test.starttest();
        List<account> accList = Utility_DataCreation.CreateAccountRec(10, 'Equipment Customer');
        System.assertEquals(10,accList.size());
        test.stoptest();
        
    }
    @istest 
    public static void createCotactAccoCiatedWithAccount_test() {
        test.starttest();
        account acc = Utility_DataCreation.CreateAccountRec(10, 'Equipment Customer')[0];
        acc.Sync_with_JDE__c = false;
        insert acc;
        List<contact> conList = Utility_DataCreation.createCotactAccoCiatedWithAccount(10,acc.id);
        System.assertEquals(10,conList.size());
        System.assertEquals(acc.id, conList[0].accountId);
        test.stoptest();
    }
    @istest
    public static void CreteProducts_test() {
        
        test.starttest();
        List<Product2> prodList = Utility_DataCreation.CreteProducts(10);
        List<Product2> prodsList = Utility_DataCreation.CreteProducts2(10);
        System.assertEquals(10,prodList.size());
        System.assertEquals('AF032', prodList[0].ProductCode);
        System.assertEquals(10,prodsList.size());
        System.assertEquals('Freight', prodsList[0].ProductCode);
        test.stoptest();
    }
    @istest
    public static void createJsonData_test() {
        
        test.startTest();
        account acc = Utility_DataCreation.CreateAccountRec(10, 'Equipment Customer')[0];
        acc.Sync_with_JDE__c = false;
        insert acc;
        Map<String, Object> requestmap = Utility_DataCreation.createJsonData(acc.id);
        Map<String, Object> requestSameMap = Utility_DataCreation.createSameJsonData(acc.id);
        test.stopTest();
    }
    @istest
    public static void createOrder_test() {
        
        List<Pricebook2> pricebookList = new List<Pricebook2>();
        test.startTest();
        account acc = Utility_DataCreation.CreateAccountRec(10, 'Equipment Customer')[0];
        acc.Sync_with_JDE__c = false;
        insert acc;
        pricebookList.add(new pricebook2(Name ='Equipment Price Book', IsActive = true ));
        insert pricebookList ;
        
        List<Order> odList = Utility_DataCreation.createOrder(acc.id, 10, pricebookList[0].id);
        List<Order> od2List = Utility_DataCreation.createOrderwithDarleyDollers(acc.id, 10, pricebookList[0].id);
        test.stopTest();
    }
    @istest
    public static void createOrderItem_test(){
        
        List<Pricebook2> pricebookList = new List<Pricebook2>();
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        
        test.startTest();
        id pricebookId = Test.getStandardPricebookId();
        account acc = Utility_DataCreation.CreateAccountRec(10, 'Equipment Customer')[0]; 
        acc.Sync_with_JDE__c = false;
        insert acc;
        pricebookList.add(new pricebook2(Name ='Equipment Price Book', IsActive = true ));
        insert pricebookList ;
        List<Order> odList = Utility_DataCreation.createOrder(acc.id, 10, pricebookList[0].id);
        insert odList;
        List<Product2> prodList = Utility_DataCreation.CreteProducts(10);
        insert prodList;
        pbeList.add(new PricebookEntry(Product2Id = prodList[0].Id,  Pricebook2Id = pricebookId, UnitPrice = 600, IsActive = true));
        pbeList.add(new PricebookEntry(Product2Id = prodList[0].Id,  Pricebook2Id = pricebookList[0].Id, UnitPrice = 600, IsActive = true));
        List<orderitem> ordItem = Utility_DataCreation.createOrderItem(10, odList, prodList, pbeList[1].id);
        test.stopTest();
    }
}