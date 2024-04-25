public without sharing class B2BOrderDetailsController {

    @AuraEnabled
    public static B2BResponse getOrderSummary(Id orderSummaryId, Id accountId) {
        OrderSummaryDto orderSummaryDto = new OrderSummaryDto();
        for(OrderItemSummary orderItemSummary : [
            SELECT
                Id,
                Name,
                Quantity,
                UnitPrice,
                TotalLineAdjustmentAmount,
                TotalLineAmount,
                Product2Id,
                Product2.Name,
                Product2.StockKeepingUnit
            FROM OrderItemSummary
            WHERE OrderSummaryId = :orderSummaryId
                AND Type = 'Order Product'
                AND OrderSummary.AccountId = :accountId
        ]) {
            orderSummaryDto.products.add(new ProductDto(orderItemSummary));
        }

        List<OrderSummary> orderSummaries = [
            SELECT
                Id,
                OrderNumber,
                OrderedDate,
                BillingAddress,
                PoNumber,
                TotalTaxAmount,
                TotalProductAmount,
                TotalAdjDistAmount,
                TotalAdjustedDeliveryAmount,
                B2BGrandTotal__c,
                Account.Name,
                BillingStreet,
                BillingCity,
                BillingState,
                BillingPostalCode,
                BillingCountry,
                OriginalOrder.Tracking_Links__c,
                B2BCreditCardName__c,
                TotalProductAdjDistAmount,
                B2BDarleyDollars__c,
                B2BPromotions__c,
                OriginalOrderId,
                StoreStatus__c,
                Payment_Type__c
            FROM OrderSummary
            WHERE Id = :orderSummaryId
                AND AccountId = :accountId
        ];

        if (!orderSummaries.isEmpty()) {
            OrderSummary orderSummary = orderSummaries[0];

            orderSummaryDto.billing = new BillingDto(orderSummary);
            orderSummaryDto.order = new OrderDto(orderSummary);
            orderSummaryDto.payment = new PaymentDto(orderSummary);

            OrderDeliveryGroupSummary orderDeliveryGroupSummary = [
                SELECT
                    Id,
                    DeliverToStreet,
                    DeliverToCity,
                    DeliverToState,
                    DeliverToPostalCode,
                    DeliverToCountry,
                    DeliveryInstructions,
                    OrderDeliveryMethod.Carrier,
                    OrderDeliveryMethod.ClassOfService
                FROM OrderDeliveryGroupSummary
                WHERE OrderSummaryId = :orderSummaryId
                LIMIT 1
            ];
            orderSummaryDto.shipping = new ShippingDto(orderDeliveryGroupSummary, orderSummary);

            orderSummaryDto.totals = new TotalsDto(orderSummary);
            orderSummaryDto.trackingLinks = parseTrackingLinks(orderSummary.OriginalOrder.Tracking_Links__c);
        }

        return new B2BResponse(true, orderSummaryDto, '');
    }

    private static Set<String> parseTrackingLinks(String tracking) {
        Set<String> trackingLinks = new Set<String>();

        if (tracking == null) {
            return trackingLinks;
        }

        String trackingWithoutSpaces = tracking.replaceAll(' ', '');
        List<String> trackingNumbers = trackingWithoutSpaces.split(',\\r\\n');

        for (String trackingNumber : trackingNumbers) {
            trackingLinks.add(trackingNumber);
        }

        return trackingLinks;
    }

    public class OrderSummaryDto {
        @AuraEnabled public BillingDto billing { get; set; }
        @AuraEnabled public OrderDto order { get; set; }
        @AuraEnabled public PaymentDto payment { get; set; }
        @AuraEnabled public List<ProductDto> products { get; set; }
        @AuraEnabled public ShippingDto shipping { get; set; }
        @AuraEnabled public TotalsDto totals { get; set; }
        @AuraEnabled public Set<String> trackingLinks { get; set; }

        public OrderSummaryDto() {
            products = new List<ProductDto>();
        }
    }

    public class BillingDto {
        @AuraEnabled public String accountName { get; set; }
        @AuraEnabled public String billingStreet { get; set; }
        @AuraEnabled public String billingCity { get; set; }
        @AuraEnabled public String billingState { get; set; }
        @AuraEnabled public String billingPostalCode { get; set; }
        @AuraEnabled public String billingCountry { get; set; }

        public BillingDto(OrderSummary orderSummary) {
            accountName = orderSummary.Account.Name;
            billingStreet = orderSummary.BillingStreet;
            billingCity = orderSummary.BillingCity;
            billingState = orderSummary.BillingState;
            billingPostalCode = orderSummary.BillingPostalCode;
            billingCountry = orderSummary.BillingCountry;
        }
    }

    public class OrderDto {
        @AuraEnabled public String currencyIsoCode { get; set; }
        @AuraEnabled public String orderNumber { get; set; }
        @AuraEnabled public Datetime orderDate { get; set; }
        @AuraEnabled public String status { get; set; }

        public OrderDto(OrderSummary orderSummary) {
            currencyIsoCode = 'USD';
            orderNumber = orderSummary.OrderNumber;
            orderDate = orderSummary.OrderedDate;
            status = orderSummary.StoreStatus__c;
        }
    }

    public class PaymentDto {
        @AuraEnabled public String creditCard { get; set; }
        @AuraEnabled public String poNumber { get; set; }
        @AuraEnabled public String paymentType { get; set; }

        public PaymentDto(OrderSummary orderSummary) {
            creditCard = orderSummary.B2BCreditCardName__c;
            poNumber = orderSummary.PoNumber;
            paymentType = orderSummary.Payment_Type__c;
        }
    }

    public class ProductDto {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String sku { get; set; }
        @AuraEnabled public Decimal price { get; set; }
        @AuraEnabled public Decimal quantity { get; set; }
        @AuraEnabled public Decimal total { get; set; }

        public ProductDto(OrderItemSummary orderItemSummary) {
            id = orderItemSummary.Product2Id;
            name = orderItemSummary.Product2.Name;
            sku = orderItemSummary.Product2.StockKeepingUnit;
            quantity = orderItemSummary.Quantity;
            price = orderItemSummary.UnitPrice;
            total = orderItemSummary.TotalLineAmount;
        }
    }

    public class ShippingDto {
        @AuraEnabled public String street { get; set; }
        @AuraEnabled public String city { get; set; }
        @AuraEnabled public String state { get; set; }
        @AuraEnabled public String postalCode { get; set; }
        @AuraEnabled public String country { get; set; }
        @AuraEnabled public String specialInstruction { get; set; }

        public ShippingDto(OrderDeliveryGroupSummary orderDeliveryGroupSummary, OrderSummary orderSummary) {
            street = orderDeliveryGroupSummary.DeliverToStreet;
            city = orderDeliveryGroupSummary.DeliverToCity;
            state = orderDeliveryGroupSummary.DeliverToState;
            postalCode = orderDeliveryGroupSummary.DeliverToPostalCode;
            country = orderDeliveryGroupSummary.DeliverToCountry;
            specialInstruction = orderDeliveryGroupSummary.DeliveryInstructions;
        }
    }

    public class TotalsDto {
        @AuraEnabled public Double subtotal { get; set; }
        @AuraEnabled public Double darleyDollars { get; set; }
        @AuraEnabled public Double tax { get; set; }
        @AuraEnabled public Double estimatedShipping { get; set; }
        @AuraEnabled public Double promotions { get; set; }
        @AuraEnabled public Double total { get; set; }
      

        public TotalsDto(OrderSummary orderSummary) {
            subtotal = orderSummary.TotalProductAmount;
            darleyDollars = orderSummary.B2BDarleyDollars__c;
            tax = orderSummary.TotalTaxAmount;
            promotions = orderSummary.B2BPromotions__c;
            estimatedShipping =  orderSummary.TotalAdjustedDeliveryAmount;
            total = orderSummary.B2BGrandTotal__c;
        }
    }

}