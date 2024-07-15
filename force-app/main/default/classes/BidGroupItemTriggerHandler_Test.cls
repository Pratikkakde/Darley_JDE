@isTest
public class BidGroupItemTriggerHandler_Test {
    @istest
    static void bidGroupTriggerTestMethod(){
        Account acc = new Account();
        acc=TestDataUtilClass.returnAccountRec();
        insert acc;
        
        
        Tier__c tc = new Tier__c();
        tc.Name='test Name';
        tc.Tier_del__c='5646565';
        tc.Contract_Type__c ='TLS SOE';
        insert tc;
        
        Id recordTypeId = Schema.SObjectType.Bid_Tracker__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
        
        Bid_Tracker__c BidTracker = new Bid_Tracker__c();
        BidTracker.name='RFQRFQ202311150001729';
        BidTracker.RecordTypeId=recordTypeId;
        BidTracker.Contract__c='TLS SOE';
        insert BidTracker;
        
        
        for (Integer i = 0; i < 3; i++) {
            
            Pricing_Matrix__c pricMatVar1 = new Pricing_Matrix__c();
            pricMatVar1.Name='Tier 1'+i;
            pricMatVar1.Tier__c=tc.Id;
            pricMatVar1.Cost_High_End__c=5000;
            pricMatVar1.Cost_Low_End__c=1000;
            pricMatVar1.Effective_Date_From__c=system.today()-10;
            pricMatVar1.Effective_Date_Thru__c=system.today()+10;
            pricMatVar1.Margin__c=1;
            
            insert pricMatVar1;
        }
        
        Pricing_Matrix__c pricMatVar12 = new Pricing_Matrix__c();
        pricMatVar12.Name='Tier 12';
        pricMatVar12.Tier__c=tc.Id;
        pricMatVar12.Cost_High_End__c=5000;
        pricMatVar12.Cost_Low_End__c=1000;
        pricMatVar12.Effective_Date_From__c=system.today()-10;
        pricMatVar12.Effective_Date_Thru__c=system.today()+10;
        pricMatVar12.Margin__c=1;
        
        insert pricMatVar12;
        
        
        
        for (Integer i = 0; i < 3; i++) {
            Bid_Group_Items__c bidgrp5 = new Bid_Group_Items__c();
            bidgrp5.Name = 'test Bid Group'+i;
            bidgrp5.Margin__c = 20;
            bidgrp5.CPQ_Shipping_Total_from_mfg__c = 500;
            bidgrp5.Total_Cost__c=6000;
            bidgrp5.Supplier__c=acc.Id;
            bidgrp5.RFQ_Number__c=BidTracker.Id;
            bidgrp5.Approval_Status__c='Approved';
            bidgrp5.Supplier_Payment_Terms__c='Net 10';
            
            insert bidgrp5;
            bidgrp5.Total_Cost__c=6000;
              bidgrp5.Margin__c = 21;
            update bidgrp5; 
        }
        
        
        
        
        /* //  Bid_Group_Items__c bidGrItem = new Bid_Group_Items__c();
// bidGrItem=TestDataUtilClass.getBidGroupItem();
Bid_Group_Items__c bidgrp = new Bid_Group_Items__c();
bidgrp.Name = 'Ozarka';
bidgrp.Margin__c = 20;
bidgrp.CPQ_Shipping_Total_from_mfg__c = 500;
bidgrp.Total_Cost__c=6000;
bidgrp.Supplier__c=acc.Id;
bidgrp.RFQ_Number__c=BidTracker.Id;
bidgrp.Supplier_Payment_Terms__c='.5% 10 NET 30';



insert bidgrp;


/*  // bidGrItem=TestDataUtilClass.getBidGroupItem();
/*  Bid_Group_Items__c bidgrp2 = new Bid_Group_Items__c();
bidgrp2.Name = 'old test Bid Group';
bidgrp2.Margin__c = 20;
bidgrp2.CPQ_Shipping_Total_from_mfg__c = 500;
bidgrp2.Total_Cost__c=6000;
bidgrp2.Supplier__c=acc.Id;
bidgrp2.RFQ_Number__c=BidTracker.Id;


insert bidgrp2;*/
        
        /*   Pricing_Matrix__c pricMatVar = new Pricing_Matrix__c();
pricMatVar.Name='Tier 1';
pricMatVar.Tier__c=tc.Id;
pricMatVar.Cost_High_End__c=5000;
pricMatVar.Cost_Low_End__c=1000;
pricMatVar.Effective_Date_From__c=system.today()-10;
pricMatVar.Effective_Date_Thru__c=system.today()+10;
pricMatVar.Margin__c=1;

insert pricMatVar;

for (Integer i = 0; i < 3; i++) {

Pricing_Matrix__c pricMatVar1 = new Pricing_Matrix__c();
pricMatVar1.Name='Tier 1'+i;
pricMatVar1.Tier__c=tc.Id;
pricMatVar1.Cost_High_End__c=5000;
pricMatVar1.Cost_Low_End__c=1000;
pricMatVar1.Effective_Date_From__c=system.today()-10;
pricMatVar1.Effective_Date_Thru__c=system.today()+10;
pricMatVar1.Margin__c=1;

insert pricMatVar1;
}


for (Integer i = 0; i < 3; i++) {
Bid_Group_Items__c bidgrp5 = new Bid_Group_Items__c();
bidgrp5.Name = 'test Bid Group'+i;
bidgrp5.Margin__c = 20;
bidgrp5.CPQ_Shipping_Total_from_mfg__c = 500;
bidgrp5.Total_Cost__c=6000;
bidgrp5.Supplier__c=acc.Id;
bidgrp5.RFQ_Number__c=BidTracker.Id;
bidgrp5.Approval_Status__c='Approved';
bidgrp5.Supplier_Payment_Terms__c='Net 10';

//insert bidgrp5;

}



Bid_Group_Items__c bidgrp3 = new Bid_Group_Items__c();
bidgrp3.Name = 'test Bid Group';
bidgrp3.Margin__c = 20;
bidgrp3.CPQ_Shipping_Total_from_mfg__c = 500;
bidgrp3.Total_Cost__c=6000;
bidgrp3.Supplier__c=acc.Id;
bidgrp3.RFQ_Number__c=BidTracker.Id;
bidgrp3.Approval_Status__c='Approved';
bidgrp3.Supplier_Payment_Terms__c='Net 10';

insert bidgrp3;

// bidgrp3.Approval_Status__c='Awaiting Approval';

bidgrp3.Margin__c = 25;
bidgrp3.Total_Cost__c=6599;
bidgrp3.CPQ_Shipping_Total_from_mfg__c = 600;

update bidgrp3;



// Bid_Line_Item__c bidLineVar = new Bid_Line_Item__c();
// bidLineVar=TestDataUtilClass.getBidLineItem();
// Id recordTypeIdd = Schema.SObjectType.Bid_Line_Item__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
/* Bid_Line_Item__c bl = new Bid_Line_Item__c();
bl.RFQ_Number__c=BidTracker.id;
bl.Bid_Supplier__c=acc.Id;
bl.Name='Testing';
bl.Regular_vs_Alternative__c='Regular';
bl.Supplier_Part_Number__c='7484784';
bl.Weeks_ARO__c='3D';
bl.TLSP_Supplier_Extension__c='WSD';
bl.Load_Batch_Number__c='2353';
bl.Due_Date__c=DateTime.now().addDays(25);
//bl.RecordTypeId=recordTypeId;
bl.Supplier_Part_Number__c='VR-FST-1';	
// bl.Quote_Numbers__c='';
bl.Due_Date__c=system.today().addDays(5);
// bl.Quote_Type__c='Quoted';
bl.Item_Description__c='bundle';
bl.Status__c='RFQ Ready for DLA';
bl.Margin_Percent__c=0.75;
bl.Payment_Terms__c='Net 10';
bl.NO_Quote_Reason__c='Supplier F or X Rating';
bl.Quote_Type__c='No Quote';
bl.Status__c='SalesRep Claim';
bl.Country__c='Test';
bl.Bid_Group_Items__c=bidgrp3.Id;
bl.Quote_Numbers__c='test Number';



//  insert bl;

Bid_Line_Item__c bl1 = new Bid_Line_Item__c();
bl1.RFQ_Number__c=BidTracker.id;
bl1.Bid_Supplier__c=acc.Id;
bl1.Name='Testing';
bl1.Regular_vs_Alternative__c='Regular';
bl1.Supplier_Part_Number__c='7484784';
bl1.Weeks_ARO__c='3D';
bl1.TLSP_Supplier_Extension__c='WSD';
bl1.Load_Batch_Number__c='2353';
bl1.Due_Date__c=DateTime.now().addDays(25);
bl1.Supplier_Part_Number__c='VR-FST-1';	
bl1.Due_Date__c=system.today().addDays(5);
bl1.Item_Description__c='bundle';
bl1.Status__c='Pending Margin Calculation';
bl1.Margin_Percent__c=0.75;
bl1.Payment_Terms__c='Net 10';
bl1.NO_Quote_Reason__c='Supplier F or X Rating';
bl1.Quote_Type__c='No Quote';
bl1.Status__c='SalesRep Claim';
bl1.Country__c='Test';
bl1.Bid_Group_Items__c=bidgrp3.Id;
bl1.Quote_Numbers__c='test Number';
bl1.SALES_REP__C=null;
insert bl1;
}
@istest
static void bidGroupTriggerTestMethod1(){
Account acc = new Account();
acc=TestDataUtilClass.returnAccountRec();
insert acc;

Id recordTypeId = Schema.SObjectType.Bid_Tracker__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();

Bid_Tracker__c BidTracker = new Bid_Tracker__c();
BidTracker.name='RFQRFQ202311150001729';
BidTracker.RecordTypeId=recordTypeId;
BidTracker.Contract__c='TLS SOE';
insert BidTracker;

Bid_Group_Items__c bidgrp4 = new Bid_Group_Items__c();
bidgrp4.Name = 'test Bid Group2';
bidgrp4.Margin__c = null;
bidgrp4.CPQ_Shipping_Total_from_mfg__c = 500;
bidgrp4.Total_Cost__c=1200;
bidgrp4.Supplier__c=acc.Id;
bidgrp4.RFQ_Number__c=BidTracker.Id;
bidgrp4.Approval_Status__c='Approved';
insert bidgrp4;

bidgrp4.Approval_Status__c='Awaiting Approval';
update bidgrp4;

Bid_Line_Item__c bl1 = new Bid_Line_Item__c();
bl1.RFQ_Number__c=BidTracker.id;
bl1.Bid_Supplier__c=acc.Id;
bl1.Name='Testing';
bl1.Regular_vs_Alternative__c='Regular';
bl1.Supplier_Part_Number__c='7484784';
bl1.Weeks_ARO__c='3D';
bl1.TLSP_Supplier_Extension__c='WSD';
bl1.Load_Batch_Number__c='2353';
bl1.Due_Date__c=DateTime.now().addDays(25);
bl1.Supplier_Part_Number__c='VR-FST-1';	
bl1.Due_Date__c=system.today().addDays(5);
bl1.Item_Description__c='bundle';
bl1.Status__c='Pending Margin Calculation';
bl1.Margin_Percent__c=0.75;
bl1.Payment_Terms__c='Net 10';
bl1.NO_Quote_Reason__c='Supplier F or X Rating';
bl1.Quote_Type__c='No Quote';
bl1.Status__c='SalesRep Claim';
bl1.Country__c='Test';
bl1.Bid_Group_Items__c=bidgrp4.Id;
bl1.Quote_Numbers__c='test Number';
bl1.SALES_REP__C=null;


Test.startTest();
//String response = RfqWebService.applyMarginBidLine();
insert bl1;
Test.stopTest();*/
        
    }
    @istest
    public static void applyMarginBidLine_TestMethod1(){
        
        Account acc = new Account();
        acc=TestDataUtilClass.returnAccountRec();
        insert acc;
        
        Bid_Tracker__c BidTracker = new Bid_Tracker__c();
        BidTracker=TestDataUtilClass.getBidTracker();
        insert BidTracker;
        
        Bid_Group_Items__c BidGrpItem = new Bid_Group_Items__c();
        BidGrpItem=TestDataUtilClass.getBidGroupItem();
        BidGrpItem.RFQ_Number__c=BidTracker.Id;
        BidGrpItem.Margin__c=5;
        BidGrpItem.Total_Cost__c=30;
        BidGrpItem.Approval_Status__c='Awaiting Approval';
        insert BidGrpItem;
        
        Bid_Line_Item__c bidLineVar = new Bid_Line_Item__c();
        bidLineVar=TestDataUtilClass.getBidLineItem();
        bidLineVar.RFQ_Number__c=BidTracker.id;
        bidLineVar.Bid_Supplier__c=acc.Id;
        bidLineVar.Quote_Numbers__c='131234';
        bidLineVar.Status__c='Sent to Supplier';
        bidLineVar.Bid_Group_Items__c=BidGrpItem.Id;
        bidLineVar.Country__c='USA';
         bidLineVar.NO_Quote_Reason__c = 'The Quote is Under $2500';
        insert bidLineVar;
        
        Bid_Group_Items__c BidGrpItem1 = new Bid_Group_Items__c();
        BidGrpItem1=TestDataUtilClass.getBidGroupItem();
        BidGrpItem1.RFQ_Number__c=BidTracker.Id;
        BidGrpItem1.Margin__c=5;
        BidGrpItem1.Total_Cost__c=30;
        insert BidGrpItem1;
        
        Bid_Line_Item__c bidLineVar1 = new Bid_Line_Item__c();
        bidLineVar1=TestDataUtilClass.getBidLineItem();
        bidLineVar1.RFQ_Number__c=BidTracker.id;
        bidLineVar1.Bid_Supplier__c=acc.Id;
        bidLineVar1.Quote_Numbers__c='131234';
        bidLineVar1.Status__c='Sent to Supplier';
        bidLineVar1.Bid_Group_Items__c=BidGrpItem1.Id;
        bidLineVar1.Country__c='USA';
        bidLineVar1.NO_Quote_Reason__c = 'Supplier F or X Rating';
        insert bidLineVar1;
        
        Bid_Group_Items__c BidGrpItem2 = new Bid_Group_Items__c();
        BidGrpItem2=TestDataUtilClass.getBidGroupItem();
        BidGrpItem2.RFQ_Number__c=BidTracker.Id;
        BidGrpItem2.Margin__c=5;
        BidGrpItem2.Total_Cost__c=30;
        insert BidGrpItem2;
        
        Bid_Line_Item__c bidLineVar12 = new Bid_Line_Item__c();
        bidLineVar12=TestDataUtilClass.getBidLineItem();
        bidLineVar12.RFQ_Number__c=BidTracker.id;
        bidLineVar12.Bid_Supplier__c=acc.Id;
        bidLineVar12.Quote_Numbers__c='131234';
        bidLineVar12.Status__c='Sent to Supplier';
        bidLineVar12.Bid_Group_Items__c=BidGrpItem2.Id;
        bidLineVar12.Country__c='USA';
        insert bidLineVar12;
        
       // Test.startTest();
        
              Bid_Group_Items__c BidGrpItem4 = new Bid_Group_Items__c();
        BidGrpItem4=TestDataUtilClass.getBidGroupItem();
        BidGrpItem4.RFQ_Number__c=BidTracker.Id;
        BidGrpItem4.Margin__c=5;
        BidGrpItem4.Total_Cost__c=30000;
        insert BidGrpItem4;
        
        Bid_Line_Item__c bidLineVar124 = new Bid_Line_Item__c();
        bidLineVar124=TestDataUtilClass.getBidLineItem();
        bidLineVar124.RFQ_Number__c=BidTracker.id;
        bidLineVar124.Bid_Supplier__c=acc.Id;
        bidLineVar124.Quote_Numbers__c='131234';
        bidLineVar124.Status__c='Sent to Supplier';
        bidLineVar124.Bid_Group_Items__c=BidGrpItem2.Id;
        bidLineVar124.Country__c='USA';
        
            Bid_Line_Item__c bidLineVar1245 = new Bid_Line_Item__c();
         bidLineVar1245=TestDataUtilClass.getBidLineItem();
        bidLineVar1245.RFQ_Number__c=BidTracker.id;
        bidLineVar1245.Bid_Supplier__c=acc.Id;
        bidLineVar1245.Quote_Numbers__c='131234';
        bidLineVar1245.Status__c='Sent to Supplier';
        bidLineVar1245.Bid_Group_Items__c=BidGrpItem2.Id;
        bidLineVar1245.Country__c='USA';
        bidLineVar1245.NO_Quote_Reason__c = 'The Quote is Under $2500';
        
        
        Bid_Line_Item__c bidLineVar12456 = new Bid_Line_Item__c();
        bidLineVar12456=TestDataUtilClass.getBidLineItem();
        bidLineVar12456.RFQ_Number__c=BidTracker.id;
        bidLineVar12456.Bid_Supplier__c=acc.Id;
        bidLineVar12456.Quote_Numbers__c='131234';
        bidLineVar12456.Status__c='Sent to Supplier';
        bidLineVar12456.Bid_Group_Items__c=BidGrpItem2.Id;
        bidLineVar12456.Country__c='USA';
        bidLineVar12456.NO_Quote_Reason__c = 'Supplier F or X Rating';
        list<Bid_LIne_Item__c> listUpdatBid = new List<Bid_Line_Item__C>{bidLineVar124, bidLineVar1245, bidLineVar12456};
        insert listUpdatBid;
    Test.StartTest();
        
        bidLineVar.Status__c= 'Awaiting Approval';
        update bidLineVar;
        BidGrpItem.Margin__c=10;
        BidGrpItem.Total_Cost__c=100;
        BidGrpItem.Approval_Status__c='Approved';
        update BidGrpItem;
        
        bidLineVar1.Status__c= 'Awaiting Approval';
        update bidLineVar1;
        BidGrpItem1.Margin__c=50;
        BidGrpItem1.Total_Cost__c=25001;
        BidGrpItem1.Approval_Status__c='Approval Denied';
        update BidGrpItem1;
        
        bidLineVar12.Status__c= 'Pending Margin Calculation';
        update bidLineVar12;
        BidGrpItem2.Approval_Status__c='Awaiting Approval';
        update BidGrpItem2;
        //BidGrpItem2.NO_Quote_Reason__c = 'The Quote is Under $2500';
        update BidGrpItem2;
        System.debug('Bid_Line_Item__c ---> '+bidLineVar);
        System.debug('Bid_Line_Item__cSales_Rep__c---> '+bidLineVar.Sales_Rep__c);
       Test.stopTest();
        
    }
    
    
     @istest
    static void bidGroupTriggerTestMethod1(){
        Account acc = new Account();
        acc=TestDataUtilClass.returnAccountRec();
        insert acc;
        
        
        Tier__c tc = new Tier__c();
        tc.Name='test Name';
        tc.Tier_del__c='5646565';
        tc.Contract_Type__c ='TLS SOE';
        insert tc;
        
        Id recordTypeId = Schema.SObjectType.Bid_Tracker__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
        
        Bid_Tracker__c BidTracker = new Bid_Tracker__c();
        BidTracker.name='RFQRFQ202311150001729';
        BidTracker.RecordTypeId=recordTypeId;
        BidTracker.Contract__c='TLS SOE';
        insert BidTracker;
        
        
        for (Integer i = 0; i < 3; i++) {
            
            Pricing_Matrix__c pricMatVar1 = new Pricing_Matrix__c();
            pricMatVar1.Name='Tier 1'+i;
            pricMatVar1.Tier__c=tc.Id;
            pricMatVar1.Cost_High_End__c=5000;
            pricMatVar1.Cost_Low_End__c=1000;
            pricMatVar1.Effective_Date_From__c=system.today()-10;
            pricMatVar1.Effective_Date_Thru__c=system.today()+10;
            pricMatVar1.Margin__c=1;
            
            insert pricMatVar1;
        }
        
        Pricing_Matrix__c pricMatVar12 = new Pricing_Matrix__c();
        pricMatVar12.Name='Tier 12';
        pricMatVar12.Tier__c=tc.Id;
         pricMatVar12.Cost_High_End__c=50000;
        pricMatVar12.Cost_Low_End__c=4999;
        pricMatVar12.Effective_Date_From__c=system.today()-10;
        pricMatVar12.Effective_Date_Thru__c=system.today()+10;
        pricMatVar12.Margin__c=1;
        
        insert pricMatVar12;
                Pricing_Matrix__c pricMatVar121 = new Pricing_Matrix__c();
        pricMatVar121.Name='Tier 12';
        pricMatVar121.Tier__c=tc.Id;
        pricMatVar121.Cost_Low_End__c=100;
        pricMatVar121.Effective_Date_From__c=system.today()-10;
        pricMatVar121.Effective_Date_Thru__c=system.today()+10;
        pricMatVar121.Margin__c=1;
        
        insert pricMatVar121;
        
        
        for (Integer i = 0; i < 3; i++) {
            Bid_Group_Items__c bidgrp5 = new Bid_Group_Items__c();
            bidgrp5.Name = 'test Bid Group'+i;
            bidgrp5.Margin__c = 20;
            bidgrp5.CPQ_Shipping_Total_from_mfg__c = 500;
            bidgrp5.Total_Cost__c=6000;
            bidgrp5.Supplier__c=acc.Id;
            bidgrp5.RFQ_Number__c=BidTracker.Id;
            bidgrp5.Approval_Status__c='Approved';
            bidgrp5.Supplier_Payment_Terms__c='Net 10';
            
            insert bidgrp5;
            bidgrp5.Total_Cost__c=6000;
            bidgrp5.Total_Cost__c=100;
            bidgrp5.Margin__c = 22;
            update bidgrp5; 
        }
    
    }
}