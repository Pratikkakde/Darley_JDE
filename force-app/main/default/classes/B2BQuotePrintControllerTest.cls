@IsTest
private class B2BQuotePrintControllerTest {

    @TestSetup
    private static void makeData() {
        new B2BDefaultTestData().initAllData();

        User communityUser = [SELECT Id, AccountId  FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        Contact contact = [SELECT Id FROM Contact WHERE AccountId = :communityUser.AccountId LIMIT 1];
        Quote__c testQuote = new Quote__c(
            Contact__c = contact.Id,
            DateRequested__c = Date.today(),
            Status__c = 'Pending',
            Account__c = communityUser.AccountId
        );

        Quote__c testQuote1 = new Quote__c(
            Contact__c = contact.Id,
            DateRequested__c = Date.today(),
            Status__c = 'Approved',
            Account__c = communityUser.AccountId
        );
        insert new List<Quote__c>{testQuote, testQuote1};

        Product2 product = [SELECT Id FROM Product2 LIMIT 1];

        insert new QuoteItem__c(
            Quote__c = testQuote.Id,
            Product__c = product.Id,
            UnitPrice__c = 100,
            Quantity__c = 2
        );
    }

    @IsTest
    static void printControllerTest() {
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        Quote__c quote = [SELECT Id FROM Quote__c WHERE Status__c = 'Pending' LIMIT 1];

        PageReference pageRef = Page.B2BQuotePrint;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(quote);
        ApexPages.currentPage().getParameters().put('id', quote.Id);

        B2BQuotePrintController ec = new B2BQuotePrintController();
    }
}