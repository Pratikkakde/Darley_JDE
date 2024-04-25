@isTest
private class B2BDarleyDollarControllerTest {
    @isTest
    private static void addDarleyDollarForRegistrationTest() {
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initCustomerUserData();
        User commUser = ((User) initData.get(B2BDefaultTestData.COMMUNITY_USER));
        Contact contact = (Contact) initData.get(B2BDefaultTestData.CUSTOMER_CONTACT);
        Id contactId = contact.Id;

        // Call the method being tested
        System.runAs(commUser) {
            Test.startTest();
            B2BDarleyDollarController.addDarleyDollarForRegistration(contactId);
            Test.stopTest();
        }

        // Verify that a new DarleyDollar__c record was created with the correct values
        List<DarleyDollar__c> darleyDollars = [SELECT Amount__c, Origin__c, Order__c, Contact__c FROM DarleyDollar__c];
        System.assertEquals(1, darleyDollars.size());
        System.assertEquals(10, darleyDollars[0].Amount__c);
        System.assertEquals('Registration', darleyDollars[0].Origin__c);
        System.assertEquals(null,darleyDollars[0].Order__c);
        System.assertEquals(contactId, darleyDollars[0].Contact__c);
    }
    
    @isTest
    static void addDarleyDollarForRegistrationWithNullValuesTest() {
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initCustomerUserData();
        User commUser = ((User) initData.get(B2BDefaultTestData.COMMUNITY_USER));
        Id contactId = null;
        try {
            System.runAs(commUser) {	
                Test.startTest();
            		B2BDarleyDollarController.addDarleyDollarForRegistration(contactId);
            	Test.stopTest();
            }    
        } catch (B2BDarleyDollarController.B2BDarleyDollarControllerException ex) {
            System.assertEquals(ex.getMessage(), 'Amount and ContactId are required');
        }
    }
    
    @isTest
    static void createDarleyDollarWithNullValuesTest() {
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initCustomerUserData();
        User commUser = ((User) initData.get(B2BDefaultTestData.COMMUNITY_USER));
        Contact contact = (Contact) initData.get(B2BDefaultTestData.CUSTOMER_CONTACT);
        Id contactId = contact.Id;
        Decimal value = 20;
        String source = 'Order';
        Id orderId = null;
        try {
            System.runAs(commUser) {	
                Test.startTest();
            		DarleyDollar__c result = B2BDarleyDollarController.createDarleyDollar(value, source, contactId, orderId);
            	Test.stopTest();
            }    
        } catch (B2BDarleyDollarController.B2BDarleyDollarControllerException ex) {
            System.assertEquals(ex.getMessage(), 'Order is required');
        }
    }
}