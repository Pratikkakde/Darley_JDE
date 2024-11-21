/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 11-07-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public class CalloutToRestOrderCCUpdateQue implements Queueable, Database.AllowsCallouts {
    
    public List<order> newList;
    public List<order> oldList;
    
    public CalloutToRestOrderCCUpdateQue(List<order> newOrdList, List<order> oldOrdList){
        this.newList = newOrdList;
        this.oldList = oldOrdList;
    }
    
    public void execute(QueueableContext context) {
        //your code including the callout
        Id creCardId ;
        String accRecordTypeId;
        String AccountId;
        //Boolean CalloutToJde;
        if(!newList.isEmpty() && !oldList.isEmpty()){
            for(order ord : newList){
                creCardId = ord.B2BCreditCardId__c;
                AccountId = ord.AccountId;
                accRecordTypeId = ord.Account.RecordTypeId;
                System.debug('accRecordTypeId:= '+accRecordTypeId);
            }
        }      List<Account> acc = [SELECT Id, Name, RecordTypeId From Account WHERE Id =:AccountId ];
        //List<CustomerCardPayment__c> CCdetail = [Select Id, Contact__c, Contact__r.Name, Card_Type__c, Card_Last_Four__c  from CustomerCardPayment__c where id=: creCardId];
        SalesOrderWrapper.creditCardDetail wrapperObj = new SalesOrderWrapper.creditCardDetail();
        if(!newList.isEmpty() ){
            for(order ord : newList){
                system.debug('ord --->'+ord);
                if(ord.B2BGrandTotal__c !=null && ord.JDE_Order_Number__c != null && ord.B2BCreditCardName__c != null){
                    wrapperObj.orderNumber = string.valueOf(ord.JDE_Order_Number__c);
                    wrapperObj.SFAmount = string.valueOf(ord.B2BGrandTotal__c);
                    wrapperObj.SFCCNumber = ord.B2BCreditCardName__c.right(4);
                    wrapperObj.SFCustomerName = ord.Payment_Type__c != 'Invoice' && ord.Cardholder_Name__c != 'Failed to capture cardholder name' ? ord.Cardholder_Name__c:'';
                    wrapperObj.SFCardName = ord.B2BCreditCardName__c.substringBefore(' ');
                    //System.debug('Auth Code'+ord.B2B_CreditCard_AuthCode__c);
                    //System.debug('Exp Date'+ord.B2B_CreditCard_ExpDate__c);
                    wrapperObj.SFAuthCode = ord.B2B_CreditCard_AuthCode__c;
                    wrapperObj.SFCCExpDate = ord.B2B_CreditCard_ExpDate__c;f
                    wrapperObj.SFAuthID = ord.Payment_Transaction_Id__c;
                }
            }
        }
        system.debug('JSON String:= '+JSON.serialize(wrapperObj));
        // convert the wrapper objects to a JSON string
        String jsonStr = JSON.serialize(wrapperObj).replace('_', ' ');
        String jsonSt = jsonStr.replace('null', '""');
        system.debug('JSON String:= '+jsonSt);
        String EquipmentCustomer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Equipment Customer').getRecordTypeId();
        system.debug('JDE_Order_Number__c: '+newList[0].JDE_Order_Number__c);
        //Creating New Order with orderLineItems in JDE.
        if(!newList.isEmpty() && !acc.isEmpty()){
            if(newList[0].JDE_Order_Number__c != null && acc[0].RecordTypeId == EquipmentCustomer){
                system.debug('JDE_Order_Number__c: '+newList[0].JDE_Order_Number__c);
                calloutToUpdateCcDetails(jsonSt, 'Order-Credit Card', 'CreditCard Detail to JDE');
            }
        }
    }
    
    public static void calloutToUpdateCcDetails(String wrapperList, String ObjectName, String ObjOpperation){
        //String endpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_autoCreateCCPrepaymentRecord';
        String endpoint = 'callout:JDE_Integration/ACBM_ORCH_autoCreateCCPrepaymentRecord';
        HttpRequest req = new HttpRequest();
        req.setTimeout(85000);
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        
        // Define the request body
        system.debug('wrapperList'+ wrapperList);
        req.setBody(wrapperList);
        
        // Create the HTTP object and make the callout
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('Response Status: '+res);
        system.debug('Response StatusCode: '+res.getStatusCode());
        String responseBody = res.getBody();
        Map<String, object> resquestData = (map<String, Object>)json.deserializeUntyped(wrapperList);
        
        if (res.getStatusCode() == 200) {
            system.debug('responseBody'+responseBody);
            Map<String, object> responseData = (map<String, Object>)json.deserializeUntyped(responseBody);
            
            //API Integration Log Generation on success
            Exception_Handler.createAilRecordonSuccess(JSON.serializePretty(resquestData),endpoint,'POST',ObjOpperation,ObjectName,JSON.serializePretty(responseData));
        } else {
            // Error handling
            System.debug('Callout error: ' + res.getStatusCode() + ' ' + res.getStatus());
            String callOutError = 'StatusCode: '+ res.getStatusCode() + '\n '+ 'Status: '+res.getStatus();
            
            //API Integration Log Generation on Failure
            Exception_Handler.createAilRecordonFail(JSON.serializePretty(resquestData),endpoint,'POST',ObjOpperation,ObjectName,responseBody,callOutError);
            
        }
    }
    
}