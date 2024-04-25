/**
 * Created by Piotr Harbunou on 8/30/2023.
 */

@IsTest
private class B2BQuoteTriggerHandlerTest {

    @TestSetup
    private static void makeData() {
        Map<String, Object> initData = new B2BDefaultTestData().initAllData();

        List<Product2> newProducts = new List<Product2> {
            new Product2 (
                Name = 'Test Quote Product 1',
                IsActive = true,
                ProductCode = 'P1'
            ),
            new Product2 (
                Name = 'Test Quote Product 2',
                IsActive = true,
                ProductCode = 'P2'
            )
        };
        insert newProducts;

        Quote__c quote = new Quote__c(
            Account__c = ((Account) initData.get(B2BDefaultTestData.CUSTOMER_ACCOUNT)).Id,
            DateRequested__c = System.today(),
            Description__c = 'Test Message',
            Estimated_Shipping__c = 0,
            Estimated_Tax__c = 0,
            Status__c = 'Pending'
        );
        insert quote;

        List<QuoteItem__c> quoteItems = new List<QuoteItem__c> {
            new QuoteItem__c(
                Quote__c  = quote.Id,
                Product__c = newProducts[0].Id,
                UnitPrice__c = 10,
                OriginalPrice__c = 10,
                Promotions__c = 0,
                Quantity__c = 1,
                B2BDarleyCost__c = 8
            ),
            new QuoteItem__c(
                Quote__c  = quote.Id,
                Product__c = newProducts[1].Id,
                UnitPrice__c = 11,
                OriginalPrice__c = 11,
                Promotions__c = 0,
                Quantity__c = 1,
                B2BDarleyCost__c = 6
            )
        };
        insert quoteItems;

        Opportunity opportunity = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId(),
            Name = 'Test',
            AccountId = ((Account) initData.get(B2BDefaultTestData.CUSTOMER_ACCOUNT)).Id,
            B2BQuote__c = quote.Id,
            StageName = 'Quoted Opportunity',
            CloseDate = Date.today().addDays(1)
        );
        insert opportunity;
    }



    @IsTest
    static void updateUnitPrice() {
        List<QuoteItem__c> quoteItems = [SELECT Id, UnitPrice__c, Product__r.Name FROM QuoteItem__c ORDER BY UnitPrice__c ASC];
        quoteItems[0].UnitPrice__c = 12;
        quoteItems[0].B2BDarleyCost__c = 7;

        Test.startTest();
        update quoteItems[0];

        Opportunity opportunity = [SELECT Id, Name, Amount FROM Opportunity LIMIT 1];
        System.assertEquals(opportunity.Amount, 23, 'Amount was not recalculated');
        System.assert(opportunity.Name.contains(quoteItems[0].Product__r.Name), 'Opportunity Name is not correct.');

        quoteItems[1].UnitPrice__c = 13;
        update quoteItems[1];
        Test.stopTest();

        opportunity = [SELECT Id, Name, Amount FROM Opportunity LIMIT 1];
        System.assertEquals(opportunity.Amount, 25, 'Amount was not recalculated');
        System.assert(opportunity.Name.contains(quoteItems[1].Product__r.Name), 'Opportunity Name is not correct.');
    }

    @IsTest
    static void removeCartItem() {
        QuoteItem__c quoteItem = [SELECT Id FROM QuoteItem__c WHERE UnitPrice__c = 11];

        Test.startTest();
        delete quoteItem;
        Test.stopTest();

        Opportunity opportunity = [SELECT Id, Name, Amount, Darley_Cost__c FROM Opportunity LIMIT 1];
        System.assertEquals(opportunity.Amount, 10, 'Amount was not recalculated');
        System.assertEquals(opportunity.Darley_Cost__c, 8, 'Amount was not recalculated');

        QuoteItem__c existedItem = [SELECT Id, Product__r.Name FROM QuoteItem__c WHERE UnitPrice__c = 10 LIMIT 1];
        System.assert(opportunity.Name.contains(existedItem.Product__r.Name), 'Opportunity Name is not correct.');
    }

}