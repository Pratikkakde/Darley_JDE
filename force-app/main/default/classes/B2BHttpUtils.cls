public with sharing class B2BHttpUtils {
    public class B2BHttpUtilsException extends Exception {
    }

    public enum CONTENT_TYPE {
        JSON, XML, FORM
    }
    private Map<CONTENT_TYPE, String> contentTypeMap = new Map<CONTENT_TYPE, String>{
        CONTENT_TYPE.JSON => 'application/json',
        CONTENT_TYPE.XML => 'text/xml; charset=UTF-8',
        CONTENT_TYPE.FORM => 'application/x-www-form-urlencoded; charset=UTF-8'
    };
    public enum REQUEST_TYPE {
        GET, POST, PUT
    }

    public Boolean requestErrors { get; set; }
    public Exception requestException { get; private set; }
    public String errorMessage { get; set; }

    public CONTENT_TYPE requestContentType { get; set; }
    public String endpoint { get; set; }
    public String body { get; set; }
    public REQUEST_TYPE method { get; set; }
    public Integer timeout { get; set; }

    private Map<String, String> headerMap = new Map<String, String>();
    public Map<String, String> queryParameterMap = new Map<String, String>();
    public HttpRequest request { get; private set; }
    public HttpResponse response { get; set; }

    private Id objectId;
    private Boolean avoidSaveRequest = false;

    Map<String, String> responseHeaderMap = new Map<String, String>();

    // Contains just the cookie name and the cookie value, not any other Cookie elements
    Map<String, String> cookieMap = new Map<String, String>();

    public Integer statusCode {
        get {
            if (response != null) {
                return response.getStatusCode();
            }
            return null;
        }
    }

    public String status {
        get {
            if (response != null) {
                return response.getStatus();
            }
            return null;
        }
    }

    public B2BHttpUtils(Id objectId) {
        requestErrors = false;
        method = REQUEST_TYPE.GET;
        responseHeaderMap = new Map<String, String>();
        this.objectId = objectId;
    }

    public B2BHttpUtils(Id objectId, String endpoint, CONTENT_TYPE contentType, String body) {
        this(objectId);
        this.endpoint = endpoint;
        this.requestContentType = contentType;
        this.body = body;
    }

    public B2BHttpUtils(Id objectId, String endpoint, CONTENT_TYPE contentType, String body, Boolean avoidSaveRequest) {
        this(objectId);
        this.endpoint = endpoint;
        this.requestContentType = contentType;
        this.body = body;
        this.avoidSaveRequest = avoidSaveRequest;
    }

    public void resetState() {
        requestErrors = false;
        requestException = null;
        errorMessage = null;
        requestContentType = null;
        endpoint = null;
        body = null;
        method = null;
        headerMap.clear();
        queryParameterMap.clear();
        request = null;
        response = null;
        responseHeaderMap.clear();
        cookieMap.clear();
    }

    public void addCookie(String key, String value) {
        addHeader('Cookie', key + '=' + value);
    }
    public void addHeader(String key, String value) {
        headerMap.put(key, value);
    }

    public void setBody(String body) {
        this.body = body;
    }

    public void addQueryParameter(String key, String value) {
        queryParameterMap.put(key, value);
    }

    public void addBasicAuthorization(String username, String password) {

        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        this.addHeader('Authorization', authorizationHeader);
    }

    public String formatQueryParameters() {
        String parameterString = '';
        if (queryParameterMap.size() > 0) {
            parameterString = '?';
            for (String key : queryParameterMap.keySet()) {
                if (parameterString.length() > 1) {
                    parameterString += '&';
                }
                parameterString += key + '=' + EncodingUtil.urlEncode(queryParameterMap.get(key), 'UTF-8');
            }
        }
        return parameterString;
    }

    private void setHeaders() {
        if (headerMap.size() > 0) {
            for (String key : headerMap.keySet()) {
                request.setHeader(key, headerMap.get(key));
            }
        }
    }

    public String getResponseHeader(String key) {
        return responseHeaderMap.get(key.toLowerCase());
    }

    private void populateCookieMap() {
        String cookie = getResponseHeader('set-cookie');

        if (cookie != null) {
            List<String> values = cookie.split(';')[0].split('=');
            if (values != null && values.size() > 1) {
                cookieMap.put(values[0].toLowerCase(), values[1]);
            }
        }
    }

    public String getCookieValue(String key) {
        return cookieMap.get(key.toLowerCase());
    }

    public HttpResponse submitRequest() {
        Rest_Log__c log = B2BHttpLogService.createLog(objectId);
        request = new HttpRequest();
        response = null;
        request.setMethod(method.name());
        if (timeout != null) {
            request.setTimeout(timeout);
        }
        if (requestContentType != null) {
            request.setHeader('Content-Type', contentTypeMap.get(requestContentType));
        }
        setHeaders();

        request.setEndpoint(endpoint + formatQueryParameters());
        log.URL__c = request.getEndpoint();
        if (body != null) {
            request.setBody(body);
            if (!this.avoidSaveRequest){
                log.Request_Body__c = body;
            }
        }

        try {
            Http objHttp = new Http();
            response = objHttp.send(request);
            log.Response_Code__c = response.getStatusCode();
            log.Response_Body__c = response.getBody();
            for (String key : response.getHeaderKeys()) {
                if (key != null) {
                    String value = response.getHeader(key);
                    key = key.toLowerCase();
                    if (value != null) {
                        responseHeaderMap.put(key.toLowerCase(), value);
                    }
                }
            }
            populateCookieMap();

        } catch (Exception e) {
            log.Error__c = e.getMessage() + '\r\n' + e.getStackTraceString();
            requestErrors = true;
            requestException = e;
        } finally {
            B2BHttpLogService.addLog(log);
        }

        return response;
    }
}