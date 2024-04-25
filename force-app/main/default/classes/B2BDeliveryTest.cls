@IsTest
private class B2BDeliveryTest {

    @IsTest
    static void testB2BShippingLWR() {
        B2BDelivery deliverySample = new B2BDelivery();

        sfdc_checkout.IntegrationInfo integrationInfo = new sfdc_checkout.IntegrationInfo();
        integrationInfo.jobId = null;
        sfdc_checkout.IntegrationStatus integrationResult = deliverySample.startCartProcessAsync(integrationInfo, null);

        System.assertEquals(integrationResult.status, sfdc_checkout.IntegrationStatus.Status.SUCCESS, 'Integration Status should be success.');
    }

}