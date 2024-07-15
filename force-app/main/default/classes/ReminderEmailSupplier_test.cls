@isTest
public class ReminderEmailSupplier_test {

    @isTest
    public static void SchedulabletestMethod(){
        
        Account acc = new Account();
        acc=TestDataUtilClass.returnAccountRec();
        acc.Name='test Account223';
        acc.Preferred_Supplier__c='Yes';
        acc.Email_Address__c='test@gmail.com';
        insert acc;
        
        Bid_Tracker__c BidTracker = new Bid_Tracker__c();
        BidTracker=TestDataUtilClass.getBidTracker();
        insert BidTracker;
        
        Id recordTypeId = Schema.SObjectType.Bid_Line_Item__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
        Bid_Line_Item__c bidLineVar = new Bid_Line_Item__c();
        bidLineVar=TestDataUtilClass.getBidLineItem();
        bidLineVar.RFQ_Number__c=BidTracker.id;
        bidLineVar.Bid_Supplier__c=acc.Id;
        bidLineVar.Quote_Numbers__c='131234';
        bidLineVar.Status__c='Sent to Supplier';
        bidLineVar.Due_Date__c=Date.Today()+2;
        bidLineVar.Quote_Type__c='Quoted';
        bidLineVar.RecordTypeId=recordTypeId;
        insert bidLineVar;
        
        bidLineVar.Unit_Cost__c=0;
        update bidLineVar;
        
        List<Account> accList = [Select Id, Name , Email_Address__c, Preferred_Supplier__c	
                                 from Account ];
        System.debug('accList ---> '+accList);
        
        List<Bid_Line_Item__c> bidList = [select Id, Bid_Supplier__c, Unit_Cost__c, Due_Date__c, RecordType.Id, Quote_Type__c, Sales_Rep__c
                                 from Bid_Line_Item__c];
        System.debug('bidList ---> '+bidList);
        
        ReminderEmailSupplier obj = new ReminderEmailSupplier();
        Test.startTest();
        obj.execute(null);
        Test.stopTest();
        
    }
    
    @isTest
    public static void SchedulabletestMethod1(){
        
        Account acc = new Account();
        acc=TestDataUtilClass.returnAccountRec();
        acc.Name='test Account223';
        acc.Preferred_Supplier__c='No';
        acc.Email_Address__c='test12@gmail.com';
        insert acc;
        
        Bid_Tracker__c BidTracker = new Bid_Tracker__c();
        BidTracker=TestDataUtilClass.getBidTracker();
        insert BidTracker;
        
        Id recordTypeId = Schema.SObjectType.Bid_Line_Item__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
        Bid_Line_Item__c bidLineVar = new Bid_Line_Item__c();
        bidLineVar=TestDataUtilClass.getBidLineItem();
        bidLineVar.RFQ_Number__c=BidTracker.id;
        bidLineVar.Bid_Supplier__c=acc.Id;
        bidLineVar.Quote_Numbers__c='131234';
        bidLineVar.Status__c='Sent to Supplier';
        bidLineVar.Due_Date__c=Date.Today()+1;
        bidLineVar.Quote_Type__c='Quoted';
        bidLineVar.RecordTypeId=recordTypeId;
        insert bidLineVar;
        
        bidLineVar.Unit_Cost__c=0;
        update bidLineVar;
        
        List<Account> accList = [Select Id, Name , Email_Address__c, Preferred_Supplier__c	
                                 from Account ];
        System.debug('accList ---> '+accList);
        
        List<Bid_Line_Item__c> bidList = [select Id, Bid_Supplier__c, Unit_Cost__c, Due_Date__c, RecordType.Id, Quote_Type__c, Sales_Rep__c
                                 from Bid_Line_Item__c];
        System.debug('bidList ---> '+bidList);
        
        ReminderEmailSupplier obj = new ReminderEmailSupplier();
        Test.startTest();
        obj.execute(null);
        Test.stopTest();
        
    }
    
}