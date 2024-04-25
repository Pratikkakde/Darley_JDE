@IsTest
private without sharing class B2BOrderDetailsControllerTest {
    private static List<OrderSummary> makeData(){
        new B2BDefaultTestData().initAllData();

        Account testAccount = [SELECT Id FROM Account WHERE Name = 'testCustomerAccount' LIMIT 1];
        Account testAccountNegative = B2BTestDataFactory.createAccount(true, 'Test Negative Account', null, 'Customer', null);

        Order newOrderPositive1 = B2BTestDataFactory.createOrder(true, testAccount.Id, 'Draft');
        Order newOrderPositive2 = B2BTestDataFactory.createOrder(true, testAccount.Id, 'Draft');
        Order newOrderNegative = B2BTestDataFactory.createOrder(true, testAccountNegative.Id, 'Draft');

        Product2 testProduct = [SELECT Id FROM Product2 WHERE Name = 'Test Product' LIMIT 1];
        OrderItem newOrderItem1 = B2BTestDataFactory.createOrderItem(true, newOrderPositive1.Id, testProduct.Id, 200, 2);
        OrderItem newOrderItem2 = B2BTestDataFactory.createOrderItem(true, newOrderPositive2.Id, testProduct.Id, 300, 3);
        OrderItem newOrderItemNegative = B2BTestDataFactory.createOrderItem(true, newOrderNegative.Id, testProduct.Id, 100, 1);

        List<OrderDeliveryMethod> odms = new List<OrderDeliveryMethod>{
            new OrderDeliveryMethod (
                Name = 'Test Delivery Method1',
                ProductId = testProduct.Id,
                IsActive = true
            ), new OrderDeliveryMethod (
                Name = 'Test Delivery Method2',
                ProductId = testProduct.Id,
                IsActive = true
            ), new OrderDeliveryMethod (
                Name = 'Test Delivery Method3',
                ProductId = testProduct.Id,
                IsActive = true
            )
        };
        insert odms;

        //Create order delivery group
        List<OrderDeliveryGroup> odgs = new List<OrderDeliveryGroup> {
            new OrderDeliveryGroup(
                OrderId = newOrderPositive1.Id,
                OrderDeliveryMethodId = odms[0].Id,
                DeliverToName='The Shipping Address 1'
            ), new OrderDeliveryGroup(
                OrderId = newOrderPositive2.Id,
                OrderDeliveryMethodId = odms[1].Id,
                DeliverToName='The Shipping Address 2'
            ), new OrderDeliveryGroup(
                OrderId = newOrderNegative.Id,
                OrderDeliveryMethodId = odms[2].Id,
                DeliverToName='The Shipping Address 3'
            )
        };
        insert odgs;

        //Update newOrderItem
        newOrderItem1.OrderDeliveryGroupId = odgs[0].Id;
        newOrderItem1.Type = 'Order Product';

        newOrderItem2.OrderDeliveryGroupId = odgs[1].Id;
        newOrderItem2.Type = 'Order Product';

        newOrderItemNegative.OrderDeliveryGroupId = odgs[2].Id;
        newOrderItemNegative.Type = 'Order Product';

        update new List<OrderItem> { newOrderItem1, newOrderItem2, newOrderItemNegative };

        //Activate order
        newOrderPositive1.Status = 'Activated';
        newOrderPositive2.Status = 'Activated';
        newOrderNegative.Status = 'Activated';
        update new List<Order> { newOrderPositive1, newOrderPositive2, newOrderNegative };

        //Create order summary
        ConnectApi.OrderSummaryInputRepresentation representation = new ConnectApi.OrderSummaryInputRepresentation();
        representation.orderId = newOrderPositive1.Id;
        representation.orderLifeCycleType='UNMANAGED';
        ConnectApi.OrderSummaryOutputRepresentation osor = ConnectApi.OrderSummaryCreation.createOrderSummary(representation);
        Set<Id> orderSummaryPositiveIds = new Set<Id> { osor.orderSummaryId };

        representation = new ConnectApi.OrderSummaryInputRepresentation();
        representation.orderId = newOrderPositive2.Id;
        representation.orderLifeCycleType='UNMANAGED';
        osor = ConnectApi.OrderSummaryCreation.createOrderSummary(representation);
        orderSummaryPositiveIds.add(osor.orderSummaryId);

        representation.orderId = newOrderNegative.Id;
        representation.orderLifeCycleType = 'UNMANAGED';
        osor = ConnectApi.OrderSummaryCreation.createOrderSummary(representation);

        List<OrderSummary> orderSummaries = [
            SELECT Id, OrderNumber, AccountId, PoNumber, TotalAmount, OrderedDate, StoreStatus__c
            FROM OrderSummary
            WHERE Id = :orderSummaryPositiveIds
        ];

        orderSummaries[0].OrderedDate = Datetime.now();
        orderSummaries[1].OrderedDate = Datetime.now().addDays(1);
        update orderSummaries;

        return orderSummaries;
    }

    /**
     * description: Should be use 'SeeAllData=true', in order have possibility to execute
     *              ConnectApi.OrderSummaryCreation.createOrderSummary API method. In this
     *              case we don't use real data from org.
     */
    @IsTest(SeeAllData=true)
    private static void getOrderSummaryTest() {
        List<OrderSummary> orderSummaries = makeData();
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];

        Test.startTest();
        System.runAs(communityUser) {
            B2BResponse response = B2BOrderDetailsController.getOrderSummary(orderSummaries[0].Id, communityUser.AccountId);
            System.assertEquals(true, response.isSuccess);
        }
    }
}