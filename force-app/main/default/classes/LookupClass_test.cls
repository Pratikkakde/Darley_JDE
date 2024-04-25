@istest
public class LookupClass_test {
    
    public testmethod static void testmethod1(){ 
        {     
            account acc = new account();
            acc.name = 'test';
            insert acc;
            lookupClass.searchDB('account','name','ownerid',1,'name','test');
        }
    }
}