/******************************************************************************************************************************************************
Name                    : SupplierXlatTrigger_handlerTest
Author                  : Melonleaf
Description             :This class is written to test the functionality of supplier xalt trigger
Version                 : 1.0
Change Log              : 
Test Class for          : SupplierXlatTrigger_handler
CreateDate              : 25-05-2024
LastModifiedDate        : 25-05-2024
******************************************************************************************************************************************************/

@isTest
public class SupplierXlatTrigger_handlerTest {

    @isTest
    public static void duplicateChildName_testMetod(){
        
        Account acc = TestDataUtilClass.returnAccountRec();
        insert acc;
        
        Supplier_XLAT__c sx = new Supplier_XLAT__c();
        sx.name = 'Test';
        sx.Child__c='Testing';
        sx.Account__c=acc.Id;
        
        Test.startTest();
        insert sx;
        Test.stopTest();
    }
    
    @isTest
    public static void updateDuplicateChildName_testMetod(){
        
        Account acc = TestDataUtilClass.returnAccountRec();
        insert acc;
        
        Supplier_XLAT__c sx = new Supplier_XLAT__c();
        sx.name = 'Test';
        sx.Child__c='Testing';
        sx.Account__c=acc.Id;
        insert sx;
        
        sx.Child__c='Testing 1';
        Test.startTest();
        update sx;
        Test.stopTest();
    }
    
    @isTest
    public static void UpdateLineItemName_testMetod(){
        
        Account acc = TestDataUtilClass.returnAccountRec();
        insert acc;
        
        Supplier_XLAT__c sx = new Supplier_XLAT__c();
        sx.name = 'Test';
        sx.Child__c='Testing';
        sx.Account__c=acc.Id;
        
        Test.startTest();
        insert sx;
        Test.stopTest();
    }

}