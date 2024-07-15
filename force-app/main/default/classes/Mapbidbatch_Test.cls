@isTest
public class Mapbidbatch_Test {
    
    
   @isTest
    Private static void methodForbatchMapbidbatch(){
        
        Id personRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        Account acc = new Account();
        acc.name='DESAPRO';
        acc.RecordTypeid=personRecordTypeId;
        acc.Supplier_Rating__c ='A: Preferred Supplier';
        insert acc;
        
        
        Product2 prd = new Product2();
        prd.Vendor_Part_Number__c='Jon';
        prd.name='Jon';
        prd.Vendor_Part_Number__c='TLS SOE';
        insert prd;  
               // if(quoteRecords.SBQQ__Opportunity2__r.StageName != 'Closed/Won' && quoteRecords.SBQQ__Opportunity2__r.StageName != 'Closed/Won'
        //  &&((quoteRecords.SBQQ__Opportunity2__r.Contract_Type__c == 'TLS FES') || (quoteRecords.SBQQ__Opportunity2__r.Contract_Type__c == 'TLS SOE')) ){
        Contact cot = new Contact();
        cot.lastName= 'Test Cot';
        insert cot;
        
        Opportunity oppVar = new Opportunity();
        oppVar.StageName = 'Customer Contact';
        oppVar.name='Test Opp';
        oppVar.CloseDate=Date.newInstance(2024, 5, 9);
        oppVar.ContactId=cot.id;
        oppVar.Contract_Type__c = 'TLS SOE';
        insert oppVar;
        
        
        Bid_Workbench__c varVarBid = new Bid_Workbench__c();
        //list<Bid_Workbench__c> query = [Select Name,Vendor_ID__c,Manufacturer_Name__c,Order_Item_ID__c,Region__c,Country_of_Origin__c,Core_List_Number__c,TLSP_Vendor_Part_Number__c,Requested_Delivery_Date__c,Quantity__c,ShipTo_DODAAC__c,Delivery_Destination__c,FOB_Origin__c,RFID_Required__c,Transportation_Price_Required__c,Transportation_Price__c,Vendor_Unit_Price__c,Lead_Time__c,Purchase_Unit_Price__c,Berry_Amendment_Compliant__c,Comments__c,Purchase_Extended_Price__c,Customer_Permits_Alternates__c,Unit_of_Issue__c,Special_Project_Code__c,Procurement_Agreement_Compliant__c,Additional_Information__c,NSN__c,Request_Type__c,TLSP_Vendor_Extension__c,Region_Group__c,Item_Description__c,Manufacturer_Part_Number__c,Processed__c,Quote_Due_Date__c,Quote_Numbers__c,Load_Batch_Number__c,Alternate_Manufacturer_Name__c,Alternate_Manufacturer_Part_Number__c,Alternate_Comments__c,Alternate_Berry_Amendment_Compliant__c,Alternate_Purchase_Extended_Price__c,Alternate_Core_List_Number__c,Alternate_Item_Description__c,Alternate_Transportation_Price__c,Alternate_TLSP_Vendor_Part_Number__c,Alternate_Purchase_Unit_Price__c,Alternate_NSN__c,Alternate_Lead_Time__c,Alternate_Country_of_Origin__c,Alternate_Vendor_Unit_Price__c,Alternate_Procurement_Agreement_Complian__c from Bid_Workbench__c Where Processed__c = false limit 1];
        // varVarBid.Additional_Information__c=
        // varVarBid.Alternate_Berry_Amendment_Compliant__c
        varVarBid.Vendor_ID__c='2';
        varVarBid.Manufacturer_Name__c=acc.name;
        varVarBid.Order_Item_ID__c='1230851';
        varVarBid.Region__c='17';
        varVarBid.Requested_Delivery_Date__c=Date.newInstance(2023, 9, 11);
        varVarBid.Quantity__c=2;
        varVarBid.ShipTo_DODAAC__c='N00164';
        varVarBid.Delivery_Destination__c='NAVAL SURFACE WARFARE CENTER CRANE  C-JXYM BLDG 41NW-Stan Hodges  300 HIGHWAY 361, BLDG 41  CRANE, IN 47522 US';
        varVarBid.FOB_Origin__c='No';
        varVarBid.RFID_Required__c='No';
        varVarBid.Quote_Number__c='20230308651387';
        varVarBid.Alternate_Item_Offered__c='No';
        varVarBid.Manufacturer_Part_Number__c='test';
        varVarBid.TLSP_Vendor_Extension__c='DAR';
        varVarBid.Request_Type__c='R';
        varVarBid.Core_List_Number__c='1';
        varVarBid.NSN__c='1';
        varVarBid.Item_Description__c='Ok';
        varVarBid.Additional_Information__c='Pass';
        varVarBid.Special_Project_Code__c='TESTPRD';
        varVarBid.Transportation_Price_Required__c='No';
        varVarBid.Transportation_Price__c='1';
        varVarBid.Vendor_Unit_Price__c='1';
        varVarBid.Purchase_Unit_Price__c='1.25';
        varVarBid.Purchase_Extended_Price__c='1.25';
        //varVarBid.Lead_Time__c= dateField.format('05/09/2026');
        varVarBid.Comments__c='Test';
        varVarBid.Procurement_Agreement_Compliant__c='No';
        varVarBid.Berry_Amendment_Compliant__c='No';
        varVarBid.Country_of_Origin__c='India';
        varVarBid.Customer_Permits_Alternates__c='Yes';
        varVarBid.Alternate_Berry_Amendment_Compliant__c='Yes';
        varVarBid.Alternate_Core_List_Number__c='Yes';
        varVarBid.Alternate_NSN__c='Test';
        varVarBid.Alternate_Item_Description__c='yes';
        varVarBid.Alternate_Vendor_Unit_Price__c='2.25';
        varVarBid.Alternate_Transportation_Price__c='3.25';
        varVarBid.Alternate_Purchase_Unit_Price__c='3.25';
        varVarBid.Alternate_Purchase_Extended_Price__c='3.26';
        varVarBid.Alternate_Lead_Time__c='22';
       varVarBid.Lead_Time__c = '120';
        varVarBid.Alternate_Comments__c='yes';
        varVarBid.Alternate_Country_of_Origin__c='India';
        varVarBid.Alternate_Procurement_Agreement_Complian__c='Yes';
        varVarBid.Alternate_Item_Offered__c='Yes';
        varVarBid.Alternate_Berry_Amendment_Compliant__c='test';
        varVarBid.Alternate_Manufacturer_Name__c='Test';
        varVarBid.Quote_Number__c='1234';
        varVarBid.Alternate_Manufacturer_Part_Number__c='TLS SOE';
        varVarBid.Load_Batch_Number__c='2.25';
        varVarBid.Quote_Due_Date__c=system.today();
        varVarBid.Unit_of_Issue__c='EA';
        varVarBid.Region_Group__c='FES Global';
        //       else if((accListMap.contains(recordDla.Manufacturer_Name__c) && dualsalesRepMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c) == Null) && ((recordDla.TLSP_Vendor_Extension__c=='DAR'
        //       && dualoppMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c)!='TLS SOE')||(recordDla.TLSP_Vendor_Extension__c=='WSD'&& dualoppMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c)!='TLS FES') ||  dualSupplierMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c) != mapXlat.get(recordDla.Manufacturer_Name__c))  ||  notequalpartnumber.contains(recordDla.Order_Item_ID__c)|| dualPrimaryQuoteMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c) != true || (dualOppStageNameMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c) == 'Closed/Lost' || dualOppStageNameMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c) == 'Closed/Won') ){
        varVarBid.TLSP_Vendor_Extension__c='DAR';
        varVarBid.Alternate_TLSP_Vendor_Part_Number__c=prd.ID;
        
        
        
        
        insert varVarBid;
        
        
        Product2 pdr = new Product2();
        pdr.Name='Test 1';
        pdr.Vendor_Part_Number__c=varVarBid.Manufacturer_Part_Number__c;
        
        insert pdr;
        
        DoDAAC__c dac = new DoDAAC__c();
        dac.Name=varVarBid.ShipTo_DODAAC__c;
        insert dac;
        
        DoDAAC__c dac1 = new DoDAAC__c();
        dac1.Name=varVarBid.ShipTo_DODAAC__c+'test';
        insert dac1;
        
        
        Supplier_XLAT__c suppl =new Supplier_XLAT__c();
        suppl.Child__c=varVarBid.Manufacturer_Name__c;
        suppl.Account__c = acc.Id;
        
        insert suppl;
        
        
        Supplier_Cleanup__c suppli = new Supplier_Cleanup__c();
        suppli.RFQ_Supplier_Name__c='AkkiShay';
        suppli.RFQ_Number__c='963258';
        insert suppli;
        
        
 
        // Create a Quote record
        Quote newQuote = new Quote();
        newQuote.Name = 'Test Quote'; // Set the name of the quote
        newQuote.OpportunityId = oppVar.id; // Set the OpportunityId to associate the quote with an opportunity
        // newQuote.Pricebook2Id = 'Pricebook2IdHere'; // Set the Pricebook2Id to associate the quote with a price book
        newQuote.ContactId = cot.id; // Set the ContactId to associate the quote with a contact
        newQuote.ExpirationDate = Date.today().addDays(30); // Set the expiration date
        
        // Insert the Quote record
        insert newQuote;
        
        
        SBQQ__Quote__c parnetVar = new SBQQ__Quote__c();
        parnetVar.SBQQ__Opportunity2__c	=oppVar.id;
        parnetVar.SBQQ__ExpirationDate__c=Date.newInstance(2024, 5, 9);
        parnetVar.Kitting_Picklist__c='Yes';
        parnetVar.SBQQ__Type__c='Quote';
        parnetVar.SBQQ__Status__c='Draft';
        parnetVar.SBQQ__Primary__c = True;
        // parnetVar.SBQQ__SalesRep__c='';
        //parnetVar.Contract_Type__c='TLS SOE';
        
        insert parnetVar;
        
        
        
        //List<SBQQ__Quote__c> quoteList = [SELECT Id, Name , SBQQ__Opportunity2__r.Name ,SBQQ__Opportunity2__r.StageName ,SBQQ__Opportunity2__r.Contract_Type__c ,(Select Id , Vendor_Part_Number__c  from SBQQ__LineItems__r)  FROM SBQQ__Quote__c where SBQQ__Primary__c = True];
        SBQQ__QuoteLine__c sbqqChild = new  SBQQ__QuoteLine__c();
        sbqqChild.Vendor_Part_Number__c='test Vandor';
        sbqqChild.Exp_Date__c=Date.newInstance(2024, 8, 16); 
        sbqqChild.MarginPercent__c=1;
        sbqqChild.SBQQ__Quantity__c	=10;
        sbqqChild.SBQQ__PricingMethod__c='List';
        sbqqChild.Darley_Net_w_o_Shipping__c=20;
        sbqqChild.SBQQ__OriginalPrice__c=20;
        sbqqChild.SBQQ__ListPrice__c=30;
        sbqqChild.SBQQ__Product__c=prd.id;
        sbqqChild.SBQQ__Quote__c=parnetVar.id;
        sbqqChild.Vendor_Part_Number__c='test';
        //sbqqChild.SBQQ__SalesRep__c='';
        
        insert sbqqChild;
        
        
        //List<Bid_Line_Item__c> bidLineQuery = [Select Id , Quote_Type__c,Supplier_Name_Text__c,supplier_Part_Number__c,line_Item_ID__c,  Name from  Bid_Line_Item__c where Quote_Number__c IN: failedSalesDrivenQuote];
        Bid_Tracker__c bidTracker = new Bid_Tracker__c();
        bidTracker = TestDataUtilClass.getBidTracker();
        Insert bidTracker;
        
        List<Bid_Line_Item__c> testBidList = new List<Bid_Line_Item__c>{
            new Bid_Line_Item__c(Name = 'DAR-1231212-20230308651567', Supplier_Part_Number__c = '106-H023957',Bid_Supplier__c=acc.id,
                                 Regular_vs_Alternative__c	='Regular',Quote_Numbers__c='1234',RFQ_Number__c =bidTracker.Id,
                                 Alternate_Item_Offered__c='Yes',Quote_Type__c ='Quoted',Alternate_Supplier_Name__c	=acc.Id ,Line_Item_ID__c='1234')
                
                // new Bid_Line_Item__c(Name = 'Test Bid 2', Supplier_Part_Number__c = 'Part 2',Bid_Supplier__c=acc.id)
                };
                    //,Alternate_Supplier_Name__c	=acc.Id 	
                    
                    insert testBidList;
        
        Test.startTest();
        Database.executeBatch(new MapBidBatch());
        
        Test.stopTest();
    }
    
    @isTest
    public static void methodElseStatte(){
        Id personRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        Account acc = new Account();
        acc.name='DESAPRO';
        acc.RecordTypeid=personRecordTypeId;
        acc.Supplier_Rating__c ='A: Preferred Supplier';
        insert acc;
        
        Product2 pdr = new Product2();
        pdr.Name='Test 1';
        pdr.Vendor_Part_Number__c='Diffrentvaalue';
        
        insert pdr;
        
        
        Bid_Workbench__c varVarBid = new Bid_Workbench__c();
        list<Bid_Workbench__c> query = [Select Name,Vendor_ID__c,Manufacturer_Name__c,Order_Item_ID__c,Region__c,Country_of_Origin__c,Core_List_Number__c,TLSP_Vendor_Part_Number__c,Requested_Delivery_Date__c,Quantity__c,ShipTo_DODAAC__c,Delivery_Destination__c,FOB_Origin__c,RFID_Required__c,Transportation_Price_Required__c,Transportation_Price__c,Vendor_Unit_Price__c,Lead_Time__c,Purchase_Unit_Price__c,Berry_Amendment_Compliant__c,Comments__c,Purchase_Extended_Price__c,Customer_Permits_Alternates__c,Unit_of_Issue__c,Special_Project_Code__c,Procurement_Agreement_Compliant__c,Additional_Information__c,NSN__c,Request_Type__c,TLSP_Vendor_Extension__c,Region_Group__c,
                                       Item_Description__c, Manufacturer_Part_Number__c,Processed__c,Quote_Due_Date__c,Quote_Number__c,Load_Batch_Number__c,Alternate_Manufacturer_Name__c,Alternate_Manufacturer_Part_Number__c,Alternate_Comments__c,Alternate_Berry_Amendment_Compliant__c,Alternate_Purchase_Extended_Price__c,Alternate_Core_List_Number__c,Alternate_Item_Description__c,Alternate_Transportation_Price__c,Alternate_TLSP_Vendor_Part_Number__c,Alternate_Purchase_Unit_Price__c,Alternate_NSN__c,Alternate_Lead_Time__c,Alternate_Country_of_Origin__c,Alternate_Vendor_Unit_Price__c,Alternate_Procurement_Agreement_Complian__c from Bid_Workbench__c Where Processed__c = false limit 1];
        // varVarBid.Additional_Information__c=
        // varVarBid.Alternate_Berry_Amendment_Compliant__c
        varVarBid.Vendor_ID__c='2';
        varVarBid.Manufacturer_Name__c='DESAPRO';
        varVarBid.Order_Item_ID__c='1230851';
        varVarBid.Region__c='17';
        varVarBid.Requested_Delivery_Date__c=Date.newInstance(2023, 9, 11);
        
        varVarBid.Quantity__c=2;
        varVarBid.ShipTo_DODAAC__c='N00164Akk';
        varVarBid.Delivery_Destination__c='NAVAL SURFACE WARFARE CENTER CRANE  C-JXYM BLDG 41NW-Stan Hodges  300 HIGHWAY 361, BLDG 41  CRANE, IN 47522 US';
        varVarBid.FOB_Origin__c='No';
        varVarBid.RFID_Required__c='No';
        varVarBid.Quote_Number__c='20230308651387';
        varVarBid.Alternate_Item_Offered__c='No';
        varVarBid.Manufacturer_Part_Number__c='testTesstDifferent';
        varVarBid.TLSP_Vendor_Extension__c='DAR';
        varVarBid.Request_Type__c='R';
        varVarBid.Core_List_Number__c='1';
        varVarBid.NSN__c='1';
        varVarBid.Item_Description__c='Ok';
        varVarBid.Additional_Information__c='Pass';
        varVarBid.Special_Project_Code__c='TESTPRD';
        varVarBid.Transportation_Price_Required__c='No';
        varVarBid.Transportation_Price__c='1';
        varVarBid.Vendor_Unit_Price__c='1';
        varVarBid.Purchase_Unit_Price__c='1.25';
        varVarBid.Purchase_Extended_Price__c='1.25';
       //varVarBid.Lead_Time__c= '12';
        varVarBid.Comments__c='Test';
        varVarBid.Procurement_Agreement_Compliant__c='No';
        varVarBid.Berry_Amendment_Compliant__c='No';
        varVarBid.Country_of_Origin__c='India';
        varVarBid.Customer_Permits_Alternates__c='Yes';
        varVarBid.Alternate_Berry_Amendment_Compliant__c='Yes';
        varVarBid.Alternate_Core_List_Number__c='Yes';
        varVarBid.Alternate_NSN__c='Test';
        //varVarBid.Alternate_Item_Description__c='yes';
        varVarBid.Alternate_Vendor_Unit_Price__c='2.25';
        varVarBid.Alternate_Transportation_Price__c='3.25';
        varVarBid.Alternate_Purchase_Unit_Price__c='3.25';
        varVarBid.Alternate_Purchase_Extended_Price__c='3.26';
        varVarBid.Alternate_Lead_Time__c='22';
        varVarBid.Lead_Time__c = '150';
        varVarBid.Alternate_Comments__c='yes';
        varVarBid.Alternate_Country_of_Origin__c='India';
        varVarBid.Alternate_Procurement_Agreement_Complian__c='Yes';
        varVarBid.Alternate_Item_Offered__c='No';
        varVarBid.Alternate_Berry_Amendment_Compliant__c='test';
        varVarBid.Alternate_Manufacturer_Name__c='Test';
        varVarBid.Quote_Number__c='1234';
        varVarBid.Alternate_Manufacturer_Part_Number__c='TLS SOE';
        varVarBid.Load_Batch_Number__c='2.25';
        varVarBid.Quote_Due_Date__c=system.today();
        varVarBid.Unit_of_Issue__c='EA';
        varVarBid.Region_Group__c='FES Global';
        
        //       else if((accListMap.contains(recordDla.Manufacturer_Name__c) && dualsalesRepMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c) == Null) && ((recordDla.TLSP_Vendor_Extension__c=='DAR'
        //       && dualoppMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c)!='TLS SOE')||(recordDla.TLSP_Vendor_Extension__c=='WSD'&& dualoppMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c)!='TLS FES') ||  dualSupplierMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c) != mapXlat.get(recordDla.Manufacturer_Name__c))  ||  notequalpartnumber.contains(recordDla.Order_Item_ID__c)|| dualPrimaryQuoteMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c) != true || (dualOppStageNameMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c) == 'Closed/Lost' || dualOppStageNameMap.get(recordDla.Order_Item_ID__c).get(recordDla.Manufacturer_Part_Number__c) == 'Closed/Won') ){
        varVarBid.TLSP_Vendor_Extension__c='DAR';
        
        
        
        
        insert varVarBid;
        
        
        
        
        DoDAAC__c dac = new DoDAAC__c();
        dac.Name='Test';
        insert dac;
        
        
        
        
        Supplier_XLAT__c suppl =new Supplier_XLAT__c();
        suppl.Child__c='test10';
        suppl.Account__c= acc.id;
        insert suppl;
        
        
        Supplier_Cleanup__c suppli = new Supplier_Cleanup__c();
        suppli.RFQ_Supplier_Name__c='AkkiShay';
        suppli.RFQ_Number__c='963258';
        insert suppli;
        
        
        // if(quoteRecords.SBQQ__Opportunity2__r.StageName != 'Closed/Won' && quoteRecords.SBQQ__Opportunity2__r.StageName != 'Closed/Won'
        //  &&((quoteRecords.SBQQ__Opportunity2__r.Contract_Type__c == 'TLS FES') || (quoteRecords.SBQQ__Opportunity2__r.Contract_Type__c == 'TLS SOE')) ){
        Contact cot = new Contact();
        cot.lastName= 'Test Cot';
        insert cot;
        
        Opportunity oppVar = new Opportunity();
        oppVar.StageName = 'Customer Contact';
        oppVar.name='Test Opp';
        oppVar.CloseDate=Date.newInstance(2024, 5, 9);
        oppVar.ContactId=cot.id;
        oppVar.Contract_Type__c = 'TLS FES';
        insert oppVar;
        
        // Create a Quote record
        Quote newQuote = new Quote();
        newQuote.Name = 'Test Quote'; // Set the name of the quote
        newQuote.OpportunityId = oppVar.id; // Set the OpportunityId to associate the quote with an opportunity
        // newQuote.Pricebook2Id = 'Pricebook2IdHere'; // Set the Pricebook2Id to associate the quote with a price book
        newQuote.ContactId = cot.id; // Set the ContactId to associate the quote with a contact
        newQuote.ExpirationDate = Date.today().addDays(30); // Set the expiration date
        
        // Insert the Quote record
        insert newQuote;
        
        
        SBQQ__Quote__c parnetVar = new SBQQ__Quote__c();
        parnetVar.SBQQ__Opportunity2__c	=oppVar.id;
        parnetVar.SBQQ__ExpirationDate__c=Date.newInstance(2024, 5, 9);
        parnetVar.Kitting_Picklist__c='Yes';
        parnetVar.SBQQ__Type__c='Quote';
        parnetVar.SBQQ__Status__c='Draft';
        parnetVar.SBQQ__Primary__c = True;
        // parnetVar.SBQQ__SalesRep__c='Test';
        
        insert parnetVar;
        
        Product2 prd = new Product2();
        prd.Vendor_Part_Number__c='Jon12';
        prd.name='Jon';
        insert prd;        
        
        
        //List<SBQQ__Quote__c> quoteList = [SELECT Id, Name , SBQQ__Opportunity2__r.Name ,SBQQ__Opportunity2__r.StageName ,SBQQ__Opportunity2__r.Contract_Type__c ,(Select Id , Vendor_Part_Number__c  from SBQQ__LineItems__r)  FROM SBQQ__Quote__c where SBQQ__Primary__c = True];
        SBQQ__QuoteLine__c sbqqChild = new  SBQQ__QuoteLine__c();
        sbqqChild.Vendor_Part_Number__c='test Vandor';
        sbqqChild.Exp_Date__c=Date.newInstance(2024, 8, 16); 
        sbqqChild.MarginPercent__c=1;
        sbqqChild.SBQQ__Quantity__c	=10;
        sbqqChild.SBQQ__PricingMethod__c='List';
        sbqqChild.Darley_Net_w_o_Shipping__c=20;
        sbqqChild.SBQQ__OriginalPrice__c=20;
        sbqqChild.SBQQ__ListPrice__c=30;
        sbqqChild.SBQQ__Product__c=prd.id;
        sbqqChild.SBQQ__Quote__c=parnetVar.id;
        sbqqChild.Vendor_Part_Number__c='test';
        //sbqqChild.SBQQ__SalesRep__c='';
        
        insert sbqqChild;
        
        
        //List<Bid_Line_Item__c> bidLineQuery = [Select Id , Quote_Type__c,Supplier_Name_Text__c,supplier_Part_Number__c,line_Item_ID__c,  Name from  Bid_Line_Item__c where Quote_Number__c IN: failedSalesDrivenQuote];
        
                Bid_Tracker__c bidTracker = new Bid_Tracker__c();
        bidTracker = TestDataUtilClass.getBidTracker();
        Insert bidTracker;
        
        List<Bid_Line_Item__c> testBidList = new List<Bid_Line_Item__c>{
            new Bid_Line_Item__c(Name = 'DAR-1231212-20230308651567',RFQ_Number__c=bidTracker.Id,
                                 Supplier_Part_Number__c = '106-H023957',Bid_Supplier__c=acc.id,Regular_vs_Alternative__c	='Regular',
                                 Quote_Numbers__c='1234',Alternate_Item_Offered__c='Yes',Alternate_Supplier_Name__c=acc.Id ,Quote_Type__c ='Quoted')
                // new Bid_Line_Item__c(Name = 'Test Bid 2', Supplier_Part_Number__c = 'Part 2',Bid_Supplier__c=acc.id)
                };
                    
                //,Alternate_Supplier_Name__c	=acc.Id    
                    
                    Test.startTest();
        Database.executeBatch(new MapBidBatch());
        
        Test.stopTest();
        
    }
 
}