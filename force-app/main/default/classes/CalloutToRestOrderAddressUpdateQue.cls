public class CalloutToRestOrderAddressUpdateQue implements Queueable, Database.AllowsCallouts {
    
    
    Public List<order> newOrdList;
    Public List<order> oldOrdList;
    Boolean inCCDet ;
    
    public CalloutToRestOrderAddressUpdateQue(List<Order> newList, List<Order> oldList, Boolean insertCCDetail){
        
        this.newOrdList = newList;
        this.oldOrdList = oldList;
        this.inCCDet = insertCCDetail;
    }
  
    public void execute(QueueableContext context) {
        //your code including the callout  
        SalesOrderWrapper.update_Address wrapperObj = new SalesOrderWrapper.update_Address(); 
        String accRecordTypeId;
        List<Account> acc = [SELECT id, RecordTypeId from Account where Id =:newOrdList[0].AccountId ];
        system.debug('acc.RecordTypeId= '+ acc[0].RecordTypeId);
        //Boolean CalloutToJde = false;
        if(!newOrdList.isEmpty()){
            for(order ordNew : newOrdList ){
                accRecordTypeId = ordNew.Account.RecordTypeId;
                
                wrapperObj.Order_Number = string.valueOf(ordNew.JDE_Order_Number__c);
                wrapperObj.Order_Type = 'S5';
                wrapperObj.Billing_Address = ordNew.billingStreet;
                wrapperObj.Billing_city = ordNew.billingCity;
                wrapperObj.Billing_State = ordNew.billingState;
                wrapperObj.Billing_country = ordNew.billingCountry;
                wrapperObj.Billing_postalCode = ordNew.billingPostalCode;
                wrapperObj.Shipping_Address = ordNew.ShippingStreet;
                wrapperObj.Shipping_city = ordNew.ShippingCity;
                wrapperObj.Shipping_State = ordNew.ShippingState;
                wrapperObj.Shipping_country = ordNew.ShippingCountry;
                wrapperObj.Shipping_postalCode = ordNew.ShippingPostalCode;               
            }
            
            String jsonStr = JSON.serialize(wrapperObj).replace('_', ' ');
            String jsonSt = jsonStr.replace('null', '""');
            system.debug('JSON String:= '+jsonSt);
            system.debug('accRecordTypeId:= '+accRecordTypeId);
            
            //system.debug('JDE_Order_Number__c: '+newOrdList[0].JDE_Order_Number__c);
            
            string EquipmentCustomer = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Equipment Customer').getRecordTypeId();
  			system.debug('EquipmentCustomer: '+EquipmentCustomer);
            
            
            //Creating New Order with orderLineItems in JDE.
            if(!newOrdList.isEmpty() && !acc.isEmpty()){
                if(newOrdList[0].JDE_Order_Number__c != null && acc[0].RecordTypeId == EquipmentCustomer){
                    system.debug('JDE_Order_Number__c: '+newOrdList[0].JDE_Order_Number__c);   
                    calloutToUpdateAddress(jsonSt, 'Order', 'Order Address Update');
                }
            }
            
            //Queue another job to update cc data to jde.
            if(!Test.isRunningTest() && inCCDet == true){
                System.enqueueJob(new CalloutToRestOrderCCUpdateQue(newOrdList, oldOrdList));    
            }    
        }
    }
    
    
    public static void calloutToUpdateAddress(String wrapperList, String ObjectName, String ObjOpperation){
        //String endpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_UpdateSalesOrder'; 
        String endpoint = 'callout:JDE_Integration/ACBM_ORCH_UpdateSalesOrder';
        
        HttpRequest req = new HttpRequest();
        req.setTimeout(85000);
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        //req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf('SFAPI:SFAPI123')));
        
        // Define the request body 
        system.debug('wrapperList'+ wrapperList);
        system.debug('wrapperList'+ JSON.serialize(wrapperList));
        //req.setBody('{"Alpha Name":"Batman2","Business Unit":"Equipment","Billing Address 1":"555 easy rd","Billing City":"Houston","Billing State":"TX","Billing Postal Code":"77089","Division":"Equipment","DOM or EXP":"Domestic Export","Customer Type":"Individuals","Equipment Customer Type":"Individuals","Phone Number":"9998887456","Electronic Address Type":"","Electronic Address":"test@test.com","Contact Information": "", "Account_id":"Newtest11","Contact_id":"Newtest22","First Name":"First","Last Name":"Last","Middle Name":"Middle","Shipping Address 1":"654 northgate","Shipping City":"Alvin","Shipping State":"TX","Contact Address 1":"777 vegas","Contact City":"Las Vegas","Contact State":"NV","Contact Postal Code":"32156","Contact Title":"CEO","Payment Terms":"Net 30","Shipping Postal Code":"77388"}');
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
        } 
    }
}