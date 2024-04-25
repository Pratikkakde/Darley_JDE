global with sharing class B2BDelivery implements sfdc_checkout.CartShippingCharges {

    global sfdc_checkout.IntegrationStatus startCartProcessAsync(sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
        sfdc_checkout.IntegrationStatus integrationStatus = new sfdc_checkout.IntegrationStatus();
        integrationStatus.status = sfdc_checkout.IntegrationStatus.Status.SUCCESS;

        return integrationStatus;
    }

}