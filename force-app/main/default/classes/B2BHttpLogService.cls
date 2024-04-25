public without sharing class B2BHttpLogService {

    private static List<Rest_Log__c> logs = new List<Rest_Log__c>();

    public static void addLog(Rest_Log__c log) {
        logs.add(log);
        try {
            if (String.isNotEmpty(log.URL__c)) {
                Matcher matcher = Pattern.compile('[a-z.]+\\.[a-z.]+').matcher(log.URL__c);
                if (matcher.matches()) {
                    matcher.find();
                    log.System__c = matcher.group();
                } else {
                    log.System__c = log.URL__c;
                }
            }
        } catch (Exception e) {
            FSystem.debug(e);
        }
    }

    public static void saveLogs() {
        try {
            insert logs;
        } catch (Exception e) {
            FSystem.debug(e);
        }
    }

    public static Rest_Log__c createLog(Id objectId) {
        Rest_Log__c log = new Rest_Log__c();
        if (String.isNotBlank(objectId)) {
            if (objectId.getSobjectType().getDescribe().getName() == 'Order') {
                log.Order__c = objectId;
            } else if (objectId.getSobjectType().getDescribe().getName() == 'WebCart') {
                log.Cart__c = objectId;
            }else if (objectId.getSobjectType().getDescribe().getName() == 'Contact') {
                log.Contact__c = objectId;
            }
        }
        return log;
    }

    public static Rest_Log__c createLog(Id objectId, HttpResponse response, HttpRequest request) {
        Rest_Log__c log = createLog(objectId);
        log.Request_Body__c = request.getBody();
        log.Response_Body__c = response.getBody();
        log.URL__c = request.getEndpoint();
        log.Response_Code__c = response.getStatusCode();

        return log;
    }
}