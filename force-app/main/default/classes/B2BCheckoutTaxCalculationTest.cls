@IsTest
private class B2BCheckoutTaxCalculationTest {

    @TestSetup
    private static void makeData() {
        new B2BDefaultTestData().initAllData();

        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        ContactPointAddress address = new ContactPointAddress(
            AddressType = 'Billing',
            Name = 'Billing Address',
            ParentId = communityUser.AccountId,
            IsDefault = false,
            Country = 'United States',
            State = 'Texas',
            City = 'Austin',
            Street = 'Test Address',
            PostalCode = '73301'
        );
        insert address;

        WebCart webCart = [SELECT Id FROM WebCart LIMIT 1];
        update new WebCart(
            Id = webCart.Id,
            B2BCheckoutShippingAddress__c = address.Id
        );
    }

    @IsTest
    private static void testCartProcess() {
        WebCart webCart = [SELECT Id FROM WebCart LIMIT 1];
        List<CartItem> cartItems = [SELECT Id FROM CartItem WHERE CartId = :webCart.Id];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2BAvalaraTest.B2BAvalaraMock(false, cartItems));

        B2BCheckoutTaxCalculation taxCalc = new B2BCheckoutTaxCalculation();
        Sfdc_Checkout.IntegrationStatus integrationStatus = taxCalc.startCartProcessAsync(new Sfdc_Checkout.IntegrationInfo(), webCart.Id);

        System.assertEquals(integrationStatus.status, Sfdc_Checkout.IntegrationStatus.Status.SUCCESS, 'Integration Status should be SUCCESS.');
        System.assertNotEquals(
            [SELECT Id, AvalaraTaxRequestBody__c FROM WebCart WHERE Id = :webCart.Id LIMIT 1].AvalaraTaxRequestBody__c,
            null,
            'Response value should be added to Web Cart record.'
        );
        Test.stopTest();
    }

    @IsTest
    private static void testCartProcessWithError() {
        WebCart webCart = [SELECT Id FROM WebCart LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2BAvalaraTest.B2BAvalaraMock(true, null));

        B2BCheckoutTaxCalculation taxCalc = new B2BCheckoutTaxCalculation();
        Sfdc_Checkout.IntegrationStatus integrationStatus = taxCalc.startCartProcessAsync(new Sfdc_Checkout.IntegrationInfo(), webCart.Id);

        System.assertEquals(integrationStatus.status, Sfdc_Checkout.IntegrationStatus.Status.FAILED, 'Integration Status should be FAILED.');
        Test.stopTest();
    }
}