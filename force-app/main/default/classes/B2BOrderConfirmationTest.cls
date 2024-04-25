/**
 * Created by IrinaSakovich on 4.08.22.
 */

@IsTest
public with sharing class B2BOrderConfirmationTest {

    @IsTest(SeeAllData=true)
    private static void getOrderDataPositive() {
        B2BTestDataFactory dataForTest = new B2BTestDataFactory();
        Map<String, Object> testData = dataForTest.initOrderData();
        Id orderSummaryId = ((OrderSummary) testData.get('OrderSummary')).Id;
        
        Test.startTest();
        B2BResponse response = B2BOrderConfirmation.getOrderData(orderSummaryId);
        Test.stopTest();

        System.assertEquals(True, response.isSuccess);
    }

    @IsTest(SeeAllData=true)
    private static void getOrderDataNegative() {
        Test.startTest();
        B2BResponse response = B2BOrderConfirmation.getOrderData('394857398');
        Test.stopTest();

        System.assertEquals(False, response.isSuccess);
    }

}