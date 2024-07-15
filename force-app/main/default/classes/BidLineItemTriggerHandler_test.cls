/******************************************************************************************************************************************************
Name                    : BidLineItemTriggerHandler_test
Author                  : Melonleaf


Description             :Test class for BidLineItemTriggerHandler to test the data
Version                 : 1.0
Change Log              : 
Test Class for          : BidLineItemTriggerHandler
CreateDate              : 25-05-2024
LastModifiedDate        : 25-05-2024
******************************************************************************************************************************************************/
@isTest
public class BidLineItemTriggerHandler_test {
    @isTest
    public static void method1(){
        Account acc = new Account();
        acc=TestDataUtilClass.returnAccountRec();
        insert acc;
        
        Bid_Tracker__c BidTracker = new Bid_Tracker__c();
        BidTracker=TestDataUtilClass.getBidTracker();
        insert BidTracker;
        
        Bid_Line_Item__c bidLineVar = new Bid_Line_Item__c();
        bidLineVar=TestDataUtilClass.getBidLineItem();
        bidLineVar.RFQ_Number__c=BidTracker.id;
        bidLineVar.Bid_Supplier__c=acc.Id;
        bidLineVar.Quote_Numbers__c='131234';
        insert bidLineVar;
        
        User userVar = new User();
        userVar=TestDataUtilClass.getUser();
        Test.startTest();
        insert userVar;
        Test.stopTest();
        bidLineVar.Status__c = 'Supplier Responded';
        update bidLineVar;
        bidLineVar.Sales_Rep__c=userVar.Id;
        bidLineVar.Status__c='New';
        bidLineVar.Unit_Cost__c=999;
        bidLineVar.Weeks_ARO__c = '2W';
        update bidLineVar;
        bidLineVar.Status__c='Hold';
        update bidLineVar;
        
    }
    
    @isTest
    public static void sendMailToSupplierFieldMissing_testMethod(){
        
        Account acc = new Account();
        acc=TestDataUtilClass.returnAccountRec();
        insert acc;
        
        Bid_Tracker__c BidTracker = new Bid_Tracker__c();
        BidTracker=TestDataUtilClass.getBidTracker();
        insert BidTracker;
        
        Bid_Group_Items__c BidGrpItem = new Bid_Group_Items__c();
        BidGrpItem=TestDataUtilClass.getBidGroupItem();
        BidGrpItem.RFQ_Number__c=BidTracker.Id;
        insert BidGrpItem;

        Bid_Line_Item__c bidLineVar = new Bid_Line_Item__c();
        bidLineVar=TestDataUtilClass.getBidLineItem();
        bidLineVar.RFQ_Number__c=BidTracker.id;
        bidLineVar.Bid_Supplier__c=acc.Id;
        bidLineVar.Quote_Numbers__c='131234';
        bidLineVar.Status__c='Sent to Supplier';
        bidLineVar.Bid_Group_Items__c=BidGrpItem.Id;
        insert bidLineVar;
        Bid_line_item__c oldBidLineItem = bidLineVar.clone();
        Test.startTest();
        BidLineItemTriggerHandler.isBidLineItemTrigger = true;
        bidLineVar.Status__c='Supplier Responded';
        update bidLineVar;
        Test.stopTest();
        
    }
    
    @isTest
    public static void updatetheBidValuesRollUpSummary_testMethod(){
        
        Account acc = new Account();
        acc=TestDataUtilClass.returnAccountRec();
        insert acc;
        
        Bid_Tracker__c BidTracker = new Bid_Tracker__c();
        BidTracker=TestDataUtilClass.getBidTracker();
        insert BidTracker;
        
        Bid_Group_Items__c BidGrpItem = new Bid_Group_Items__c();
        BidGrpItem=TestDataUtilClass.getBidGroupItem();
        BidGrpItem.RFQ_Number__c=BidTracker.Id;
        insert BidGrpItem;

        Bid_Line_Item__c bidLineVar = new Bid_Line_Item__c();
        bidLineVar=TestDataUtilClass.getBidLineItem();
        bidLineVar.RFQ_Number__c=BidTracker.id;
        bidLineVar.Bid_Supplier__c=acc.Id;
        bidLineVar.Quote_Numbers__c='131234';
        bidLineVar.Status__c='Sent to Supplier';
        bidLineVar.Bid_Group_Items__c=BidGrpItem.Id;
        bidLineVar.Unit_Cost__c=100;
        bidLineVar.Quantity__c=1000;
        insert bidLineVar;
        Bid_line_item__c oldBidLineItem = bidLineVar.clone();
        Test.startTest();
        BidLineItemTriggerHandler.isBidLineItemTrigger = true;
        bidLineVar.Status__c='Supplier Responded';
        bidLineVar.Unit_Cost__c=120;
        bidLineVar.Quantity__c=1200;
        update bidLineVar;
        Test.stopTest();
        
    }
    
    @isTest
    public static void pullingDarleyCostFromPriceBookEntry_testMethod(){
        
        Account acc = new Account();
        acc=TestDataUtilClass.returnAccountRec();
        insert acc;
        
        Bid_Tracker__c BidTracker = new Bid_Tracker__c();
        BidTracker=TestDataUtilClass.getBidTracker();
        insert BidTracker;
        
        Bid_Group_Items__c BidGrpItem = new Bid_Group_Items__c();
        BidGrpItem=TestDataUtilClass.getBidGroupItem();
        BidGrpItem.RFQ_Number__c=BidTracker.Id;
        insert BidGrpItem;

        Bid_Line_Item__c bidLineVar = new Bid_Line_Item__c();
        bidLineVar=TestDataUtilClass.getBidLineItem();
        bidLineVar.RFQ_Number__c=BidTracker.id;
        bidLineVar.Bid_Supplier__c=acc.Id;
        bidLineVar.Quote_Numbers__c='131234';
        bidLineVar.Status__c='Sent to Supplier';
        bidLineVar.Bid_Group_Items__c=BidGrpItem.Id;
        bidLineVar.Unit_Cost__c=100;
        bidLineVar.Quantity__c=1000;
        insert bidLineVar;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
        System.debug('pricebookId-----> '+pricebookId);
        System.debug('standaPricebook-----> '+standardPricebook);
        
        Id recordTypePrdDefense = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Defense').getRecordTypeId();
        Product2 pro = new Product2(
            Name = 'iPhone X',
            Vendor_Account__c = bidLineVar.Bid_Supplier__c,
            Vendor_Part_Number__c = 'VR-FST-1',
            recordTypeId = recordTypePrdDefense
        );
        Insert pro;
        
        PricebookEntry pbe1 = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = pro.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        Insert pbe1;
        System.debug('pbe1----->'+pbe1);

        Test.startTest();
        BidLineItemTriggerHandler.isBidLineItemTrigger = true;
        bidLineVar.Bid_Supplier__c=pro.Vendor_Account__c;
        bidLineVar.Supplier_Part_Number__c=pro.Vendor_Part_Number__c;
        bidLineVar.Sales_Rep__c=null;
        bidLineVar.Quantity__c=5;
        update bidLineVar;
        List<PricebookEntry> varPriceBook =  [SELECT Id, Product2.Vendor_Account__c, 
                                              Product2.Vendor_Part_Number__c,Product2.Vendor_Account__r.Name,
                                              ProductCode, IsActive, Product2Id, Pricebook2Id, Name FROM PricebookEntry];
        System.debug('varPriceBook -----> '+varPriceBook);
        List<Product2> proList = [SELECT Id, Vendor_Account__c, Vendor_Part_Number__c, Name FROM Product2];
        System.debug('proList -----> '+proList);
        List<Pricebook2> priceBookList = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
        System.debug('priceBookList -----> '+priceBookList);
        System.debug('pro.Vendor_Account__c --> '+pro.Vendor_Account__c);
        System.debug('pro.Vendor_Part_Number__c --> '+pro.Vendor_Part_Number__c);
        System.debug('pro.RecordTypeId --> '+pro.RecordTypeId);
        Test.stopTest();
        
    }
    
    @isTest
    public static void CreateTheTaskforRFQ_testMethod(){
        
        Account acc = new Account();
        acc=TestDataUtilClass.returnAccountRec();
        acc.Send_Questionnarie__c=true;
        insert acc;
        
        Bid_Tracker__c BidTracker = new Bid_Tracker__c();
        BidTracker=TestDataUtilClass.getBidTracker();
        insert BidTracker;
        
        Bid_Group_Items__c BidGrpItem = new Bid_Group_Items__c();
        BidGrpItem=TestDataUtilClass.getBidGroupItem();
        BidGrpItem.RFQ_Number__c=BidTracker.Id;
        insert BidGrpItem;

        Bid_Line_Item__c bidLineVar = new Bid_Line_Item__c();
        bidLineVar=TestDataUtilClass.getBidLineItem();
        bidLineVar.RFQ_Number__c=BidTracker.id;
        bidLineVar.Bid_Supplier__c=acc.Id;
        bidLineVar.Quote_Numbers__c='131234';
        bidLineVar.Status__c='Sent to Supplier';
        bidLineVar.Bid_Group_Items__c=BidGrpItem.Id;
        bidLineVar.Unit_Cost__c=100;
        bidLineVar.Quantity__c=1000;
        bidLineVar.Unit_of_Issue__c='KIT (KT)';
        Test.startTest();
        BidLineItemTriggerHandler.isBidLineItemTrigger = true;
        insert bidLineVar;
        Test.stopTest();
        
    }
    
    @isTest
    public static void updateFindManufactureForMRO_testMethod(){
        
        Account acc = new Account();
        acc=TestDataUtilClass.returnAccountRec();
        acc.Send_Questionnarie__c=true;
        acc.Preferred_Supplier__c = 'Yes';
        insert acc;
        
        Bid_Tracker__c BidTracker = new Bid_Tracker__c();
        BidTracker=TestDataUtilClass.getBidTracker();
        insert BidTracker;
        
        Bid_Group_Items__c BidGrpItem = new Bid_Group_Items__c();
        BidGrpItem=TestDataUtilClass.getBidGroupItem();
        BidGrpItem.RFQ_Number__c=BidTracker.Id;
        BidGrpItem.PrePay__c =false;
        insert BidGrpItem;

        Bid_Line_Item__c bidLineVar = new Bid_Line_Item__c();
        bidLineVar=TestDataUtilClass.getBidLineItem();
        bidLineVar.RFQ_Number__c=BidTracker.id;
        bidLineVar.Bid_Supplier__c=acc.Id;
        bidLineVar.Quote_Numbers__c='131234';
        bidLineVar.Status__c='Sent to Supplier';
        bidLineVar.Bid_Group_Items__c=BidGrpItem.Id;
        bidLineVar.Unit_Cost__c=100;
        bidLineVar.Quantity__c=1000;
        bidLineVar.Unit_of_Issue__c='KIT (KT)';
        insert bidLineVar;
        
       // Id recordTypeId = Schema.SObjectType.Bid_line_item__C.getRecordTypeInfosByName().get('MRO').getRecordTypeId();
        Test.startTest();
        BidLineItemTriggerHandler.isBidLineItemTrigger = true;
       // bidLineVar.RecordTypeId=recordTypeId;
        bidLineVar.DoDAAC_Number_Text__c='12333354';
        bidLineVar.Country_of_Origin__c='CA - Canada';
        bidLineVar.Status__c = 'Pending Margin Calculation';
        bidLineVar.Payment_Terms__c = 'Net 30';
        update bidLineVar;
        bidLineVar.Country_of_Origin__c='US - United States';
        bidLineVar.Status__c =NULL;
        update bidLineVar; 
            bidLineVar.Payment_Terms__c = '30% PREPAY';
        bidLineVar.Status__c ='Pending Margin Calculation';
        update bidLineVar;
        Test.stopTest();
        
    }
    
}