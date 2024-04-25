@isTest
public class productTriggerHandlerTest {
    @isTest
    public static void Method1(){
        
       
        
        List<Product2> proList = new List<Product2>();
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.JDE_Part_Number__c = 'AF032';
        p.ProductCode = 'AF032';
        p.Branch_Plant__c = '400' ;
        p.JDE_Stocking_Type__c = 'Obsolete';
        
        
        proList.add(p);
        
        Product2 p1 = new Product2();
        p1.Name = 'Test Product AF033';
        p1.JDE_Part_Number__c = 'AF033';
        p1.ProductCode = 'AF033';
        p1.Branch_Plant__c = '400' ;
        p1.JDE_Stocking_Type__c = 'Obsolete - Use Up';
        
        proList.add(p1);
        
        Product2 p2 = new Product2();
        p2.Name = 'Test Product AF034';
        p2.JDE_Part_Number__c = 'AF034';
        p2.ProductCode = 'AF034';
        p2.Branch_Plant__c = '400' ;
        p2.JDE_Stocking_Type__c = 'Raw Material';
        
        proList.add(p2);
        
        insert proList ;
        
        string Equipment_Products = Schema.Sobjecttype.product2.getRecordTypeInfosByName().get('Equipment Products').getRecordTypeId();
                
    }
}