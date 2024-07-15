@isTest
public class SearchComponentLwc_Test {
    @isTest
    public static void testSearchXlat1() {
        
      /*  List<Supplier_XLAT__c> testXlatList = new List<Supplier_XLAT__c>{
            new Supplier_XLAT__c(Name = 'Test Xlat 1', child__c = 'Child 1'),
                new Supplier_XLAT__c(Name = 'Test Xlat 2', child__c = 'Child 2')
                };
                    insert testXlatList;
        string nullPoint='';
        SearchComponentLwc.searchXlat('Test');
        SearchComponentLwc.searchXlat(nullPoint);
        
        */
        Id recodTyprIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Supply Partner Application').getRecordTypeId();

        Lead ledvar = new Lead();
        ledvar.lastName= 'Supplier Name';
        ledvar.RecordTypeId=recodTyprIdLead;
        ledvar.Company	='Supplier Name';
       // ledvar.Email_Address__c='test@gmail.com';
        
        insert ledvar;
        
        Account acc=new Account();
        acc.Name='Test Account';
        insert acc;
        List<Supplier_XLAT__c> supplierList=new List<Supplier_XLAT__c>();
        
        Supplier_XLAT__c supp=new Supplier_XLAT__c();
        supp.Name='Test Name';
        supp.Child__c='Test Child';
        supp.Lead__c=ledvar.Id;
        supp.Account__c=acc.id;
        
       // insert supp;
        supplierList.add(supp);
        insert supplierList;
        
        
        
        Test.startTest();
        List<Supplier_XLAT__c> result = SearchComponentLwc.searchXlat('Test Name');
        Test.stopTest();
        // System.assertEquals(1, result.size());
        // System.assertEquals('Test Name', result[0].Name);
        
    }
    
    @isTest
    public static void testSearchXlat2() {
         Test.startTest();
        List<Supplier_XLAT__c> result = SearchComponentLwc.searchXlat('');
        Test.stopTest();

        // Assert that the returned list is empty
        System.assertEquals(0, result.size());
    }
    
    @isTest
    public static void searchLead1(){
     
        List<lead> leadlist=new list<lead>();
        Lead l=new Lead();
        l.LastName='TestName';
        //l.Name='Test Name';
        l.Company='Test Company';
        leadlist.add(l);
        
        insert l;
        
        test.startTest();
        List<Lead> result=SearchComponentLwc.searchLead('Test Company');
        test.stopTest();
        
     }
    @isTest
    public static void searchLead2(){
        test.startTest();
        List<Lead> result=SearchComponentLwc.searchLead('');
        test.stopTest();
        
        System.assertEquals(0, result.size());
 
        
        
    }
    
    @isTest
    public static void searchPartNumber(){
        
         Id recordTypeIdd = Schema.SObjectType.Bid_Tracker__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();

         Bid_Tracker__c BidTracker = new Bid_Tracker__c();
         BidTracker.name='test Name';
        BidTracker.RecordTypeId=recordTypeIdd;
        insert BidTracker;
        
        List<Bid_Line_Item__c> bidList=new List<Bid_Line_Item__c>();
        Bid_Line_Item__c bli=new Bid_Line_Item__c();
        bli.Name='Test Name';
        bli.Supplier_Name_Text__c='Test supplier';
        bli.Supplier_Part_Number__c='Test partNumber';
        bli.RFQ_Number__c=BidTracker.Id;
        bli.Quote_Numbers__c='TestValue';
        
        insert bli;
        
        test.startTest();
        List<Bid_Line_Item__c> result=SearchComponentLwc.searchPartNumber('Test partNumber');
        test.stopTest();
        
       
        
        List<Bid_Line_Item__c> result2=SearchComponentLwc.searchPartNumber('');
        
        
        
        
    }
    @isTest
    public static void serachEmail(){
     
      Id recordTypeIdd = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
       String testEmail1 = 'test1@example.com';
        String testEmail2 = 'test2@example.com';
     List<Account> accList=new List<Account>();
     Account testAccount1=new Account();
     testAccount1.Name='TestName1';
     testAccount1.Email_Address__c=testEmail1;
     testAccount1.RecordTypeId=recordTypeIdd;
     
      
        
     accList.add(testAccount1);
     
     Account testAccount2=new Account();
     testAccount2.Name='TestName1';
     testAccount2.Email_Address__c=testEmail2;
     testAccount2.RecordTypeId=recordTypeIdd;
     
        
     accList.add(testAccount2);
        
     insert accList;
       
     Test.startTest();
        List<Account> result = SearchComponentLwc.serachEmail('test');
        List<Account> result2 = SearchComponentLwc.serachEmail('');

      Test.stopTest();
      
        System.assertEquals(2, result.size());
        System.assertEquals(testEmail1, result[0].Email_Address__c);
        System.assertEquals(testEmail2, result[1].Email_Address__c);
        
        
    
     //  List<Account> result2 = SearchComponentLwc.serachEmail('');
        
           //     System.assertEquals(0, result2.size());


        
    }
    
     @isTest
    public static void TestupdateSupplierCleanup(){
        
         List<lead> leadlist=new list<lead>();
        Lead l=new Lead();
        l.LastName='TestName';
        //l.Name='Test Name';
        l.Company='Test Company';
        leadlist.add(l);
        
        insert l;
        
        
         Supplier_XLAT__c sxlat=new Supplier_XLAT__c();
         sxlat.Child__c='test value';
         sxlat.name='TestName';
         sxlat.Lead__c=l.Id;
        insert sxlat;
        
         
         supplier_cleanup__c testSupplier = new supplier_cleanup__c();
        //testSupplier.Name = 'Test Supplier';
         testSupplier.Supplier_XLAT__c=sxlat.Id;
        
        
        insert testSupplier;

        // Call the method to be tested
       // Test.startTest();
       // SearchComponentLwc.updateSupplierCleanup(testSupplier.Id, 'New XLAT Id', 'New Lead Id');
      //  Test.stopTest();

        
    }
    
    
    
    
    
    
    
    
 
    
  /*  @isTest
    public static void testSearchPartNumber() {
        
        
        Account acc = new Account();
        acc.name='Test for bid';
        insert acc;
        List<Bid_Line_Item__c> testBidList = new List<Bid_Line_Item__c>{
            new Bid_Line_Item__c(Name = 'DAR-1231212-20230308651567', Supplier_Part_Number__c = '106-H023957',Bid_Supplier__c=acc.id,Regular_vs_Alternative__c	='Regular',Quote_Numbers__c='1234')
                // new Bid_Line_Item__c(Name = 'Test Bid 2', Supplier_Part_Number__c = 'Part 2',Bid_Supplier__c=acc.id)
                };
                    insert testBidList;
        
        SearchComponentLwc.searchPartNumber('DAR-1231212-20230308651567');
        SearchComponentLwc.searchPartNumber('');
        
        
    }*/
    
    
  /*  @isTest
    public static void testSearchEmail() {
        // Create test data
        // 
        // 
        
        Id personRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bid Supplier').getRecordTypeId();
        List<Account> testAccountList = new List<Account>{
            new Account(Name = 'Test Account 1', Email_Address__c = 'test1@example.com'),
                new Account(Name = 'Test Account 2', Email_Address__c = 'test2@example.com')
                };
                    insert testAccountList;
        
        SearchComponentLwc.serachEmail('test');
        SearchComponentLwc.serachEmail('');
        SearchComponentLwc.serachEmail('RandomName');
        
        
    }
    
    
    @isTest
    public static void testupdateSupplierCleanup() {
        List<Supplier_XLAT__c> testSuppp = new List<Supplier_XLAT__c> {
            new Supplier_XLAT__c(Name='Test SuppLier',Child__c='Child Test')
                };
                    insert testSuppp;
        
        List<supplier_cleanup__c> testAccountList = new List<supplier_cleanup__c>{
            new supplier_cleanup__c(Name = 'Test Account 1', RFQ_Number__c = 'test1',Status__c='New')
                };
                     insert testAccountList;
        
        Account acc= new Account(name='Test');
        insert acc;
        
        lead l=new Lead(lastname = 'Test Account 1',company=acc.id);
        insert l;
        
        
        SearchComponentLwc.updateSupplierCleanup(testAccountList[0].id,testSuppp[0].id,l.id);
     }*/
}