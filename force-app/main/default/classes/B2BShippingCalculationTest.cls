@isTest
private class B2BShippingCalculationTest {
    @TestSetup
    static void makeData(){
        new B2BDefaultTestData().initAllData();
    }

    @IsTest
    static void testCalculateShipping(){
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        WebCart cart = [SELECT Id FROM WebCart LIMIT 1];
        Test.startTest();
        System.runAs(communityUser) {
             B2BShippingCalculation.calculateShipping(cart.Id);
        }
        List<CartItem> cartItems = [SELECT Id FROM CartItem WHERE CartId =: cart.Id AND Name = 'Delivery Cart Item' ];
        System.assertEquals(1, cartItems.size(),'One charge item must be created.');
    }
}