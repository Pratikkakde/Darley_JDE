public class B2BOrderTestDataGeneration {
    public static List<String> addresses = new List<String>{
            '777 Brockton Avenue',
            '30 Memorial Drive',
            '250 Hartford Avenue',
            '700 Oak Street',
            '66-4 Parkhurst Rd',
            '591 Memorial Dr',
            '55 Brooksby Village Way',
            '137 Teaticket Hwy',
            '42 Fairhaven Commons Way',
            '374 William S Canning Blvd'
        };
        public static List<String> cities = new List<String>{
            'New York City',
            'Los Angeles',
            'Chicago',
            'Houston',
            'Phoenix',
            'Philadelphia',
            'San Antonio',
            'San Diego',
            'Dallas',
            'San Jose',
            'Austin',
            'Jacksonville',
            'Fort Worth',
            'Columbus',
            'Charlotte',
            'San Francisco',
            'Indianapolis'
        };
        public static List<String> states = new List<String> {
            'Alabama',
            'Alaska',
            'Arizona',
            'Colorado',
            'California'
        };
        public static List<String> postalCodes = new List<String>{
            '111111',
            '222222',
            '333333',
            '444444',
            '555555',
            '666666',
            '777777',
            '888888',
            '999999'
        };
        public static List<String> listingStatuses = new List<String>{
            'Active',
            'Sold',
            'Inactive'
        };
        public static List<String> orderSummaryStatues = new List<String>{
            'Created',
            'Completed',
            'Canceled'
        };
        
    public static void generateData () {
        
        
        
        Id orderDeliveryMethodId = [SELECT Id FROM OrderDeliveryMethod Limit 1].Id;
        Id salesStoreId = [SELECT Id FROM WebStore LIMIT 1].Id;
        User usr = [SELECT Id, AccountId FROM User WHERE AccountId ='0010100000u5Ul9AAE' LIMIT 1];
        
        Id communityUserId = usr.Id;
        Id accountId = usr.AccountId; 
        
        Date targetDate = Date.newInstance(2021, 06, 07);
        String poNumber = string.valueof(Math.abs(Crypto.getRandomLong())).substring(0, 10);
        // Integer пожалуйста = 10;
        
        // removeData();
        Order newOrder = generateData(targetDate, communityUserId, accountId, orderDeliveryMethodId, salesStoreId, poNumber);
        convertOrders(newOrder.Id, communityUserId);

    }
    
    public static Order generateData(Date orderDate, Id communityUserId, Id accountId, Id orderDeliveryMethodId, Id salesStoreId, String poNumber) {
        List<BuyerGroup> bgp = [
            SELECT Id, (SELECT Id, Pricebook2Id FROM BuyerGroupPricebooks LIMIT 1)
            FROM BuyerGroup
            WHERE Id IN (SELECT BuyerGroupId FROM BuyerGroupMember WHERE BuyerID =: accountId) 
            LIMIT 1
        ];
    
        Id pricebookId = bgp.get(0).BuyerGroupPricebooks.get(0).Pricebook2Id;
        List<PricebookEntry> entries = [SELECT Id, Product2Id, UnitPrice FROM PricebookEntry WHERE Pricebook2Id =: pricebookId LIMIT: 1 ];
    
        Order newOrder = new Order(
            AccountId = accountId,
            SalesStoreId = salesStoreId,
            Status = 'Draft',
            OrderedDate = orderDate,
            PONumber= poNumber,
            EffectiveDate = orderDate,
            OwnerId = communityUserId,
            Pricebook2Id = pricebookId,
            BillingStreet = addresses.get( Integer.valueof((Math.random() * addresses.size()))),
            BillingCity =  cities.get( Integer.valueof((Math.random() * cities.size()))),
            BillingCountry = 'United States',
            BillingState =  states.get( Integer.valueof((Math.random() * states.size()))),
            BillingPostalCode = postalCodes.get( Integer.valueof((Math.random() * postalCodes.size())))
        );
            
        insert newOrder;
    
        List<OrderItem> orderItemsToInsert = new List<OrderItem>();
        OrderDeliveryGroup ordgToInsert = new OrderDeliveryGroup(
            OrderId = newOrder.Id,
            OrderDeliveryMethodId = orderDeliveryMethodId,
            DeliverToName = 'Test Delivery Group ' + communityUserId
        );
    
        insert ordgToInsert;
    
        for(PricebookEntry item : entries){
            orderItemsToInsert.add( new OrderItem(
                OrderId = newOrder.Id,
                OrderDeliveryGroupId = ordgToInsert.Id,
                PriceBookEntryId = item.Id,
                Product2Id = item.Product2Id,
                Quantity = 5,
                ListPrice = item.UnitPrice,
                UnitPrice = item.UnitPrice,
                TotalLineAmount = item.UnitPrice * 5,
                Type = 'Order Product'
            ));
        }
    
        insert orderItemsToInsert;
    
        newOrder.Status = 'Activated';
    
        update newOrder;
    
        return newOrder;
    }
    
    public static void convertOrders( Id orderId, Id communityUserId) {
        List<Order> orders = [
            SELECT Id 
            FROM Order 
            WHERE Id  =: orderId 
            AND Id NOT IN (SELECT OriginalOrderId FROM OrderSummary)
        ];
        
        List<OrderSummary> summariesToUpdate = new List<OrderSummary>();
    
        for(Order order : orders){
            ConnectApi.OrderSummaryInputRepresentation osir = new ConnectApi.OrderSummaryInputRepresentation();
            osir.orderId = order.Id;
            
            ConnectApi.OrderSummaryOutputRepresentation osor = ConnectApi.OrderSummaryCreation.createOrderSummary(osir);
    
            summariesToUpdate.add( new OrderSummary( 
                Id = osor.orderSummaryId, 
                OwnerId = communityUserId, 
                Status = orderSummaryStatues.get( Integer.valueof((Math.random() * orderSummaryStatues.size())))
            ));
        }
        
        update summariesToUpdate;
    }

}