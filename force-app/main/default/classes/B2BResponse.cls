public with sharing class B2BResponse {
    @AuraEnabled public Boolean isSuccess { get; set; }
    @AuraEnabled public Object responseData { get; set; }
    @AuraEnabled public String responseMessage { get; set; }
    @AuraEnabled public List<Object> debugLogs { get; set; }

    public B2BResponse() {
        this.debugLogs = FSystem.logs;
        this.isSuccess = true;
        this.responseMessage = '';
        B2BHttpLogService.saveLogs();
    }

    public B2BResponse(Boolean isSuccess) {
        this();
        this.isSuccess = isSuccess;
    }

    public B2BResponse(Boolean isSuccess, String responseMessage) {
        this(isSuccess);
        this.responseMessage = responseMessage;
    }

    public B2BResponse(Boolean isSuccess, Object responseData, String responseMessage) {
        this(isSuccess, responseMessage);
        this.responseData = responseData;
    }
}