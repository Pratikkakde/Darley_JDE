@isTest
public class B2BStorePriceSetupTest {
    @TestSetup
    static void makeData(){
        new B2BDefaultTestData().initAllData();
    }

    @isTest
    static void testSetupPrices() {
        WebStore store = [SELECT id, Name FROM WebStore LIMIT 1];
        store.Name = 'Enhanced Darley Store';
        update store;
        CommerceEntitlementPolicy allAccess = new CommerceEntitlementPolicy(Name = 'All Access for Enhanced Darley Store');
        insert allAccess;
        CommerceEntitlementPolicy quoteOnly = new CommerceEntitlementPolicy(Name = 'Quote Only');
        insert quoteOnly;
        Integer initialPricebook = [SELECT count() FROM Pricebook2];

        Test.startTest();
        B2BStorePriceSetup.setupPrices();
        Test.stopTest();
        
        Integer totalPricebooks = [SELECT count() FROM Pricebook2];
        System.assertEquals(1, initialPricebook, '1 existing Pricebook2');
        System.assertEquals(7, totalPricebooks, '1 existing Pricebook2 + 6 Pricebook2 created');
        Integer totalBuyerGroups = [SELECT count() FROM BuyerGroup];
        System.assertEquals(7, totalBuyerGroups, '6 BuyerGroups must be created BuyerGroup');
    }
}