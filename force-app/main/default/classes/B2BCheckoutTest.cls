@IsTest
public class B2BCheckoutTest {
    
    @TestSetup
    private static void makeData() {
        new B2BDefaultTestData().initAllData();
    }
    
    @IsTest
    private static void testSummary() {
        List<WebCart> cartIds = [
            SELECT Id FROM WebCart lIMIT 1];
        Id cartId = cartIds[0].Id;
        
        B2BCheckoutOrderSummary summary = new B2BCheckoutOrderSummary(cartId);
        Test.startTest();
        
        
        
    }
    
    @IsTest
    private static void testPlaceOrder() {

    }

}