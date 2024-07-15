@isTest
public   class GetCPQdataContro_Test {
    
    @isTest
    public static void returnAccountRectest() {   
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__ShippingState__c = 'Georgia';
        quote.SBQQ__ShippingCountry__c = 'United States';
        quote.Kitting_Picklist__c='Yes';
        insert quote;
        Product2 product = new Product2(
            Name = 'Test Product',              
            ProductCode = 'TEST001',             
            Type__c = 'Test Type', 
            IsActive = true
        );
        insert product;
              Pricebook2 pricBook = new Pricebook2(IsActive = true ,Name ='Standard Price Book' );
        //insert pricBook;
        id pricebookId =Test.getStandardPricebookId();        
        // 1. Define a standard price for the product
        PricebookEntry standardPrice = new PricebookEntry(
             Pricebook2Id = pricebookId,
            Product2Id = product.Id,
            UnitPrice = 1000,
            IsActive = true
            
        );
        
        // You need to specify that this is the standard price
        //standardPrice.IsStandardPrice = true;
        insert standardPrice;
        
   
        
        //SELECT Id, ProductCode, Name FROM Product2
        SBQQ__Quote__c quote1 = [SELECT Id, Name FROM SBQQ__Quote__c where Id =: quote.Id limit 1];
        system.debug('SBQQ__Quote__c--> '+quote1.Id);
        system.debug('SBQQ__Quote__c--> '+quote1.Name);
        
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id,  SBQQ__Product__c = product.id,
                                                              MarginPercent__c=5.00000, Country_of_Origin__c='USA',
                                                              Vendor_Part_Number__c='CCT-AS-TCT 1.0', SBQQ__UnitCost__c=28815.00,
                                                              Berry_Applicable__c=false, Lead_Time__c=10, 
                                                              SBQQ__NetPrice__c=30331.58 ,Exp_Date__c = System.today().addDays(1)
                                                              
                                                             );
      
        
        insert quoteLine;
        System.debug('quoteLine ---> '+quoteLine);
        
        Bid_Tracker__c bid = TestDataUtilClass.getBidTracker();
        bid.CPQ_Quote_Number__c = quote1.Name;
       insert bid;
        
        Bid_Group_Items__c Bidg = TestDataUtilClass.getBidGroupItem();
        Bidg.RFQ_Number__c=bid.id;
        insert Bidg;
        
        Bid_Line_Item__c testBidLineItem = TestDataUtilClass.getBidLineItem();
        testBidLineItem.RFQ_Number__c = bid.id;
        testBidLineItem.Quote_Numbers__c='123';
        testBidLineItem.Sales_Rep__c=null;
        testBidLineItem.Bid_Group_Items__c=Bidg.Id;
        testBidLineItem.Supplier_Part_Number__c= 'CCT-AS-TCT 1.0';

        insert testBidLineItem;

        
        test.startTest();
       GetCPQdataContro.updateTheBidLIneAndTracWithQuoteAndLIne(bid.id);
        test.stoptest();
    }
    
}