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
            
            }
        
        
		List<Account> acc = [SELECT Id, Name, RecordTypeId From Account WHERE Id =:AccountId ];
        //List<CustomerCardPayment__c> CCdetail = [Select Id, Contact__c, Contact__r.Name, Card_Type__c, Card_Last_Four__c  from CustomerCardPayment__c where id=: creCardId];
        SalesOrderWrapper.creditCardDetail wrapperObj = new SalesOrderWrapper.creditCardDetail();
        if(!newList.isEmpty() && !acc.isEmpty()){
            for(order ord : newList){    
                if(ord.B2BGrandTotal__c !=null && ord.JDE_Order_Number__c != null && ord.B2BCreditCardName__c != null){
                    wrapperObj.orderNumber = string.valueOf(ord.JDE_Order_Number__c);
                    wrapperObj.SFAmount = string.valueOf(ord.B2BGrandTotal__c);
                    wrapperObj.SFCCNumber = ord.B2BCreditCardName__c.right(4);
                    wrapperObj.SFCustomerName = acc[0].Name;
                    wrapperObj.SFCardName = ord.B2BCreditCardName__c.substringBefore(' ');
                    wrapperObj.SFAuthCode = '';
                    wrapperObj.SFAuthID = ord.Payment_Transaction_Id__c;
                }
            }
        }
        
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
        
        // Handle the response
        if (res.getStatusCode() == 200) {
            // Successful callout
            
            system.debug('responseBody'+responseBody);
            // Process the response body here
            
            
            //API Integration Log Generation on success
            API_Integration_Log__c ail = new API_Integration_Log__c();
            ail.JSON_Body__c= wrapperList;
            ail.Endpoint__c = endpoint;
            ail.Status__c = 'Success';
            ail.Request_Type__c = 'POST';
            ail.Response_Body__c = responseBody;
            ail.Name__c = ObjOpperation;
            ail.Object__c = ObjectName;
            
            try{
                insert ail;
            } catch(exception ex){ 
                system.debug('Error : '+ex.getMessage());
            }
            
            
        }
        else {
            // Error handling
            System.debug('Callout error: ' + res.getStatusCode() + ' ' + res.getStatus());
            
            //API Integration Log Generation on Failure
            API_Integration_Log__c ail = new API_Integration_Log__c();
            ail.JSON_Body__c= wrapperList;
            ail.Endpoint__c = endpoint;
            ail.Status__c = 'Failed';
            ail.Request_Type__c = 'POST';
            ail.Response_Body__c = responseBody;
            ail.Name__c = ObjOpperation;
            ail.Object__c = ObjectName;
            
            try{
                insert ail;
            } catch(exception ex){
                system.debug('Error : '+ex.getMessage());
            }
            //}
        }
    }
    
}