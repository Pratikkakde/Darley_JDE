@IsTest
private without sharing class B2BOpportunityServiceTest {

    @TestSetup
    private static void makeData() {
        new B2BDefaultTestData().initAllData();
    }

    @IsTest
    static void createOpportunity() {
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        WebCart webCart = [SELECT
            Id,
            TotalPromoAdjustmentAmount,
            TotalAmount,
            GrandTotalAmount,
            (
                SELECT
                    Id,
                    Product2Id,
                    Product2.Name,
                    Name,
                    Sku,
                    Quantity,
                    SalesPrice,
                    TotalAmount,
                    TotalAdjustmentAmount
                FROM CartItems
            )
            FROM WebCart
            LIMIT 1
        ];
        Account account = [SELECT Id, Name, JDE_Address_Number__c FROM Account WHERE Id = :communityUser.AccountId];
        insert new Quote__c(Account__c = account.Id);
        Quote__c quote = [SELECT Id, Name FROM Quote__c LIMIT 1];

        Test.startTest();
        System.runAs(communityUser) {
            B2BOpportunityService.createOpportunity(account, webCart, quote, 22);
            Test.stopTest();
        }

        List<Opportunity> opportunities = [SELECT Id FROM Opportunity];
        System.assertEquals(opportunities.size(), 1, 'Opportunity record was not created.');
    }

}