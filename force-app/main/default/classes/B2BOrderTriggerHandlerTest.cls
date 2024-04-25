@IsTest
public without sharing class B2BOrderTriggerHandlerTest {
    @IsTest
    private static void sendOrderShippedEmailTest() {
        B2BTestDataFactory factory = new B2BTestDataFactory();
        Map<String, Object> initData = factory.initCustomerUserData();

        User commUser = (User) initData.get(B2BDefaultTestData.COMMUNITY_USER);
        Account acc = (Account) initData.get(B2BDefaultTestData.CUSTOMER_ACCOUNT);

        System.runAs(commUser) {
            List<Order> orders = new List<Order>();
            for (Integer i = 0; i < 50; i ++) {
                Order order = B2BTestDataFactory.createOrder(false, acc.Id, 'Draft');

                orders.add(order);
            }
            insert orders;

            List<Order> ordersToUpdate = new List<Order>();
            for (Order order: orders) {
                order.Tracking_Links__c = 'Z1F978V0394303045';
                ordersToUpdate.add(order);
            }

            update ordersToUpdate;

            System.assertEquals(1, Limits.getEmailInvocations());
        }
    }
}