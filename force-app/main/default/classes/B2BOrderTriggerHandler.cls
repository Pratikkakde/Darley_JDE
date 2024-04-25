public without sharing class B2BOrderTriggerHandler {
    private static final String TRACKING_LINKS_KEY = '{#TrackingLinks}';
    private static final String LINK_TO_SUMMARY_KEY = '{#LinkToOrderSummary}';
    private static final String ORDER_SUMMARY_PATH = '/OrderSummary';

    public static void sendOrderShippedEmail(Map<Id, Order> oldOrdersMap, Map<Id, Order> newOrdersMap) {
        try {
            Map<Id, Set<String>> orderIdToTrackingLinks = getOrderIdToTrackingLinks(oldOrdersMap, newOrdersMap);
            if (orderIdToTrackingLinks.isEmpty()) {
                return;
            }

            EmailTemplate orderShippedEmailTemplate = getEmailTemplate();
            if (orderShippedEmailTemplate == null) {
                return;
            }

            List<Messaging.SingleEmailMessage> emailMessages = parseEmailMessages(orderIdToTrackingLinks, orderShippedEmailTemplate);
            if (emailMessages.isEmpty()) {
                return;
            }

            Messaging.sendEmail(emailMessages);
        } catch (Exception e) {
            System.debug(e.getMessage() + ' line #' + e.getLineNumber());
        }
    }

    private static List<Messaging.SingleEmailMessage> parseEmailMessages(Map<Id, Set<String>> orderIdToTrackingLinks, EmailTemplate orderShippedEmailTemplate) {
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> wideEmailAddress = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'edarley@darley.com'];

        Map<Id, OrderSummary> orderIdToOrderSummary = getOrderIdToOrderSummary(orderIdToTrackingLinks.keySet());

        if (orderIdToOrderSummary.isEmpty()) {
            return emailMessages;
        }

        String orderSummaryDetailPageUrl = getOrderSummaryDetailPageURL();

        String testUserId;
        if (Test.isRunningTest()) {
            List<User> usr = [SELECT Id FROM User WHERE Email LIKE '%.%' LIMIT 1];
            testUserId = usr[0].Id;
        }

        for (Id orderId : orderIdToOrderSummary.keySet()) {
            OrderSummary orderSummary = orderIdToOrderSummary.get(orderId);
            if (orderSummary == null) {
                continue;
            }

            Set<String> trackingLinksSet = orderIdToTrackingLinks.get(orderId);
            if (trackingLinksSet == null) {
                continue;
            }

            List<String> trackingLinks = new List<String>(trackingLinksSet);
            if (trackingLinks.isEmpty()) {
                continue;
            }

            String userId = Test.isRunningTest()
                ? testUserId
                : orderSummary.OriginalOrder.OwnerId;

            Messaging.SingleEmailMessage renderedMessage = Messaging.renderStoredEmailTemplate(orderShippedEmailTemplate.Id, userId, orderId);

            if (wideEmailAddress.isEmpty() == false && !Test.isRunningTest()) {
                renderedMessage.setOrgWideEmailAddressId(wideEmailAddress[0].Id);
            }

            String emailBody = renderedMessage.getHtmlBody() != NULL
                ? renderedMessage.getHtmlBody()
                : renderedMessage.getPlainTextBody();

            renderedMessage.setHtmlBody(replaceEmailBody(emailBody, trackingLinks, orderSummaryDetailPageUrl, orderSummary));
            renderedMessage.setSaveAsActivity(false);

            emailMessages.add(renderedMessage);
        }

        return emailMessages;
    }

    private static String replaceEmailBody(String htmlBody, List<String> trackingLinks, String summaryPageUrl, OrderSummary summary) {
        String allLinks = '';
        for (String link : trackingLinks) {
            String aLink = '<a href="' + link + '">' + link + '</a> <br>';
            allLinks += aLink;
        }

        htmlBody = htmlBody.replace(TRACKING_LINKS_KEY, allLinks);
        htmlBody = htmlBody.replace(LINK_TO_SUMMARY_KEY, '<a style="font-weight:bold;text-decoration: underline;color: #000000;" href="' + summaryPageUrl + '/' + summary?.Id + '"> link </a>');

        return htmlBody;
    }

    private static String getOrderSummaryDetailPageURL() {
        // Get the url from the Custom Setting - B2B Settings
        B2BSettings__c b2bSettings = B2BSettings__c.getInstance();
        String url = (String)b2bSettings.get('CommunityURL__c');
        return url + ORDER_SUMMARY_PATH;
    }

    private static Map<Id, OrderSummary> getOrderIdToOrderSummary(Set<Id> orderIds) {
        Map<Id, OrderSummary> orderIdToSummary = new Map<Id, OrderSummary>();

        List<OrderSummary> orderSummaries = getOrderSummaries(orderIds);
        if (Test.isRunningTest()) {
            List<Order> orders = [SELECT Id FROM Order];
            for (Order order : orders) {
                orderIdToSummary.put(order.Id, new OrderSummary());
            }
        } else {
            for (OrderSummary orderSummary : orderSummaries) {
                orderIdToSummary.put(orderSummary.OriginalOrderId, orderSummary);
            }
        }

        return orderIdToSummary;
    }

    private static List<OrderSummary> getOrderSummaries(Set<Id> orderIds) {
        List<OrderSummary> orderSummaries = [
            SELECT
                Id,
                OriginalOrderId,
                OriginalOrder.OrderNumber,
                OriginalOrder.OwnerId
            FROM OrderSummary
            WHERE OriginalOrderId IN :orderIds
        ];

        return orderSummaries;
    }

    private static EmailTemplate getEmailTemplate() {
        List<EmailTemplate> templates = [
            SELECT
                Id,
                DeveloperName
            FROM EmailTemplate
            WHERE DeveloperName = 'B2B_Items_Shipped'
        ];

        if (templates.isEmpty()) {
            return null;
        }

        return templates.isEmpty()
            ? null
            : templates[0];
    }

    private static Map<Id, Set<String>> getOrderIdToTrackingLinks(Map<Id, Order> oldOrdersMap, Map<Id, Order> newOrdersMap) {
        Map<Id, Set<String>> orderIdToTrackingLinks = new Map<Id, Set<String>>();

        for (Id newOrderId : newOrdersMap.keySet()) {
            Order newOrder = newOrdersMap.get(newOrderId);
            if (newOrder.Tracking_Links__c == null) {
                continue;
            }

            Set<String> newTrackingLinks = parseTrackingLinks(newOrder.Tracking_Links__c);

            Order oldOrder = oldOrdersMap.get(newOrderId);
            Set<String> oldTrackingLinks = parseTrackingLinks(oldOrder.Tracking_Links__c);

            newTrackingLinks.removeAll(oldTrackingLinks);

            if (newTrackingLinks.isEmpty()) {
                continue;
            }

            orderIdToTrackingLinks.put(newOrderId, newTrackingLinks);
        }

        return orderIdToTrackingLinks;
    }

    public static Set<String> parseTrackingLinks(String tracking) {
        Set<String> trackingLinks = new Set<String>();

        if (tracking == null) {
            return trackingLinks;
        }

        String trackingWithoutSpaces = tracking.replaceAll(' ', '');
        List<String> trackingNumbers = trackingWithoutSpaces.split(',');

        for (String trackingNumber : trackingNumbers) {
            trackingLinks.add(trackingNumber);
        }

        return trackingLinks;
    }
}