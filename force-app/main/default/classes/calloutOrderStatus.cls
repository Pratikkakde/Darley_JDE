public class calloutOrderStatus { 

    @AuraEnabled 
    //This method is called from Salesforce UI Record page.
    public static void makeCallout(String OrderRecordId) {
        String JDEOrderNumber ;
        List<Order> OrderData = [Select Id, OrderNumber, JDE_Order_Number__c , JDE_Order_Type__c, StoreStatus__c from Order where Id=: OrderRecordId];
        if(OrderData.size()>0){
            JDEOrderNumber = string.valueOf(OrderData[0].JDE_Order_Number__c); 
        }
        
        // Define the endpoint URL
        String endpoint = 'callout:JDE_Integration/ACBM_ORCH_SendSalesOrderToSF'; 
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setTimeout(60000);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        
        // Define the request body
        String requestBody = '{"Order Number": "'+JDEOrderNumber+'","Order Type": "S5"}'; 
        system.debug('requestBody'+requestBody);
        req.setBody(requestBody);
        
        // Create the HTTP object and make the callout
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('res'+res);
        system.debug('res2'+res.getStatusCode()); 
        
        String responseBody = res.getBody();
        
        // Handle the response
        if (res.getStatusCode() == 200) {
            // Successful callout
            
            system.debug('responseBody'+responseBody);
            // Process the response body here
            
            //Map<String, object> responseData = (map<String, Object>)json.deserializeUntyped(responseBody);
            //String order_Number = (String)responseData.get('Order Number');
            //String OrderStatus = (String)responseData.get('orderStatus');
            
            List<Order> updateOrderList = new List<order>();
            if(!OrderData.isEmpty()){
                for(order Od : OrderData){
                    if (responseBody.contains('Open')) {
                        Od.StoreStatus__c = 'Open';
                        updateOrderList.add(Od);
                    } else if (!responseBody.contains('Open') && responseBody.contains('Cancelled')) {
                        Od.StoreStatus__c = 'Cancelled';
                        updateOrderList.add(Od);
                    } else if (!responseBody.contains('Open') && responseBody.contains('Cancelled') && responseBody.contains('Shipped') ) {
                        Od.StoreStatus__c = 'Shipped';
                        updateOrderList.add(Od);
                    } else if (responseBody.contains('Shipped') && !responseBody.contains('Cancelled') && !responseBody.contains('Open')) {
                        Od.StoreStatus__c = 'Shipped';
                        updateOrderList.add(Od);
                    }
                }
            }
            
            if(updateOrderList.size()>0){
                try{
                    update updateOrderList; 
                }catch(exception ex){
                    system.debug('Error: '+ex.getMessage());
                }
            }
            
            //API Integration Log Generation on success
            API_Integration_Log__c ail = new API_Integration_Log__c();
            ail.JSON_Body__c= requestBody;
            ail.Endpoint__c = endpoint;
            ail.Status__c = 'Success';
            ail.Request_Type__c = 'GET';
            ail.Response_Body__c = responseBody;
            ail.Name__c = 'Order data Retrieve from JDE';
            ail.Object__c = 'Order';
            
            try{
                insert ail;
            } catch(exception ex){    
                system.debug('Error : '+ex.getMessage());
            }
        } 
        else {
            // Error handling
            System.debug('Callout error: ' + res.getStatusCode() + ' ' + res.getStatus());
            System.debug('Callout body: ' + res.getBody() );
            
            //API Integration Log Generation on success
            API_Integration_Log__c ail = new API_Integration_Log__c();
            ail.JSON_Body__c= requestBody;
            ail.Endpoint__c = endpoint;
            ail.Status__c = 'Failed';
            ail.Request_Type__c = 'GET';
            ail.Response_Body__c = responseBody;
            ail.Name__c = 'Order data Retrieve from JDE';
            ail.Object__c = 'Order';
            
            try{
                insert ail;
            } catch(exception ex){
                system.debug('Error : '+ex.getMessage());
                
            }
        }
    }   
    
    @AuraEnabled 
    //This method is called from B2BCommerce site orderDetail page.
    public static String getCalloutOrderStatus(String recordId){
        system.debug('recordId: '+recordId);
        String ordStatus = '';
        //Logic to do callout From EDarley Site.
        List<OrderSummary> ordSumm = [SELECT Id, OriginalOrderId FROM OrderSummary WHERE Id =: recordId];
        String JDEOrderNumber ;
        List<Order> OrderData ;
        if(!ordSumm.isEmpty()){
            OrderData = [Select Id, OrderNumber, JDE_Order_Number__c , JDE_Order_Type__c, StoreStatus__c from Order where Id =:ordSumm[0].OriginalOrderId];
            if(!OrderData.isEmpty() && OrderData[0].JDE_Order_Number__c != null){
                JDEOrderNumber = string.valueOf(OrderData[0].JDE_Order_Number__c); 
            }
        }
        
        // Define the endpoint URL
        String endpoint = 'callout:JDE_Integration/ACBM_ORCH_SendSalesOrderToSF'; 
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setTimeout(60000);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        
        // Define the request body
        String requestBody = '{"Order Number": "'+JDEOrderNumber+'","Order Type": "S5"}'; 
        system.debug('requestBody'+requestBody);
        req.setBody(requestBody);
        
        // Create the HTTP object and make the callout
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('res'+res);
        system.debug('res2'+res.getStatusCode()); 
        
        String responseBody = res.getBody();
        
        // Handle the response
        if (res.getStatusCode() == 200) {
            // Successful callout
            
            system.debug('responseBody'+responseBody);
            // Process the response body here
            List<Order> updateOrderList = new List<order>();
            if(!OrderData.isEmpty()){
                for(order Od : OrderData){
                    if(responseBody.contains('Open')){
                        Od.StoreStatus__c = 'Open'; 
                        ordStatus = 'Open';
                        updateOrderList.add(Od);
                    }else if(!responseBody.contains('Open') && responseBody.contains('Cancelled')){
                        Od.StoreStatus__c = 'Cancelled'; 
                        ordStatus = 'Cancelled';
                        updateOrderList.add(Od);    
                    }
                    else if(!responseBody.contains('Open') && responseBody.contains('Cancelled') && responseBody.contains('Shipped')){
                        Od.StoreStatus__c = 'Shipped'; 
                        ordStatus = 'Shipped';
                        updateOrderList.add(Od);
                    }else if(responseBody.contains('Shipped') && !responseBody.contains('Cancelled') && !responseBody.contains('Open')){
                        Od.StoreStatus__c = 'Shipped';
                        ordStatus = 'Shipped';
                        updateOrderList.add(Od);
                    }
                }
            }
            
            if(updateOrderList.size()>0){
                try{
                    update updateOrderList; 
                }catch(exception ex){
                    system.debug('Error: '+ex.getMessage());
                }
            }
            
            //API Integration Log Generation on success
            API_Integration_Log__c ail = new API_Integration_Log__c();
            ail.JSON_Body__c= requestBody;
            ail.Endpoint__c = endpoint;
            ail.Status__c = 'Success';
            ail.Request_Type__c = 'GET';
            ail.Response_Body__c = responseBody;
            ail.Name__c = 'Order Status Retrieve from JDE';
            ail.Object__c = 'Order EDarley Site';
            
            try{
                insert ail;
            } catch(exception ex){    
                system.debug('Error : '+ex.getMessage());
            }
        } 
        else {
            // Error handling
            System.debug('Callout error: ' + res.getStatusCode() + ' ' + res.getStatus());
            System.debug('Callout body: ' + res.getBody() );
            
            //API Integration Log Generation on success
            API_Integration_Log__c ail = new API_Integration_Log__c();
            ail.JSON_Body__c= requestBody;
            ail.Endpoint__c = endpoint;
            ail.Status__c = 'Failed';
            ail.Request_Type__c = 'GET';
            ail.Response_Body__c = responseBody;
            ail.Name__c = 'Order Status Retrieve from JDE';
            ail.Object__c = 'Order EDarley Site';
            
            try{
                insert ail;
            } catch(exception ex){
                system.debug('Error : '+ex.getMessage());                
            }
        }
        system.debug('@ordStatus : '+ordStatus); 
        return ordStatus;
        
    }  
    
    @AuraEnabled    
    //This method is called from B2BCommerce site orderOverView page.
    public static String  orderOverViewCallout(String orderSummaryIds) {
        
        String result ='';
        system.debug('recordIds: '+orderSummaryIds);

        //OrderList  
        //Logic to do callout From EDarley Site.
        List<OrderSummary> ordSumm = [SELECT Id, OriginalOrderId, StoreStatus__c  FROM OrderSummary WHERE Id =: orderSummaryIds];
        system.debug('ordSumm: '+ordSumm);
        Map<Id, String> orderIDStatusMap = new Map<Id, String>();
        Set<Id> orderIds = new Set<Id>();
        for(OrderSummary os : ordSumm){
            orderIds.add(os.OriginalOrderId);
            orderIDStatusMap.put(os.OriginalOrderId, os.StoreStatus__c );
        }
        
        List<Order> orderData = [Select Id, OrderNumber, JDE_Order_Number__c , JDE_Order_Type__c, StoreStatus__c from Order Where Id In: orderIds];
        system.debug('orderData: '+orderData);
        List<Order> updateOrderList = new List<Order>();
        
        
        // Define the endpoint URL
        String endpoint = 'callout:JDE_Integration/ACBM_ORCH_SendSalesOrderToSF'; 
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setTimeout(60000);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        
        // Define the request body
        String requestBody = '{"Order Number": "'+string.valueOf(orderData[0].JDE_Order_Number__c)+'","Order Type": "S5"}'; 
        system.debug('requestBody'+requestBody);
        req.setBody(requestBody);
        
        // Create the HTTP object and make the callout
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('res'+res);
        system.debug('res2'+res.getStatusCode()); 
        
        String responseBody = res.getBody();
        
        // Handle the response
        if (res.getStatusCode() == 200) {
            // Successful callout
            system.debug('responseBody'+responseBody);
            // Process the response body here
            for(order od : orderData){
                if(responseBody.contains('Open')){
                    Od.StoreStatus__c = 'Open';
                    
                    if(orderIDStatusMap.get(od.id) != 'Open'){
                        updateOrderList.add(Od);
                    }
                }else if(!responseBody.contains('Open') && responseBody.contains('Cancelled')){
                    Od.StoreStatus__c = 'Cancelled';                     
                    if(orderIDStatusMap.get(od.id) != 'Cancelled'){
                        updateOrderList.add(Od);
                    }    
                }
                else if(!responseBody.contains('Open') && responseBody.contains('Cancelled') && responseBody.contains('Shipped')){
                    Od.StoreStatus__c = 'Shipped';                     
                    if(orderIDStatusMap.get(od.id) != 'Shipped'){
                        updateOrderList.add(Od);
                    }
                }else if(responseBody.contains('Shipped') && !responseBody.contains('Cancelled') && !responseBody.contains('Open')){
                    Od.StoreStatus__c = 'Shipped';                    
                    if(orderIDStatusMap.get(od.id) != 'Shipped'){
                        updateOrderList.add(Od);
                    }
                }
               result = od.OrderNumber +','+Od.StoreStatus__c;
                system.debug('od.OrderNumber--->'+od.OrderNumber);
                system.debug('Od.StoreStatus__c--->'+Od.StoreStatus__c);
                system.debug('orderstatus--->'+result);
                
            }
            system.debug('Orders Update Size: '+updateOrderList.size());
            if(updateOrderList.size()>0){
                try{
                    
                    update updateOrderList; 
                    system.debug('Orders Updated');
                }catch(exception ex){
                    system.debug('Error: '+ex.getMessage());
                }
            }
            
            //API Integration Log Generation on success
            API_Integration_Log__c ail = new API_Integration_Log__c();
            ail.JSON_Body__c= requestBody;
            ail.Endpoint__c = endpoint;
            ail.Status__c = 'Success';
            ail.Request_Type__c = 'GET';
            ail.Response_Body__c = responseBody;
            ail.Name__c = 'Order Status Retrieve from JDE';
            ail.Object__c = 'Order EDarley Site';
            
            try{
                //insert ail;
            } catch(exception ex){    
                system.debug('Error : '+ex.getMessage());
            }
        }
        else {
            // Error handling
            System.debug('Callout error: ' + res.getStatusCode() + ' ' + res.getStatus());
            System.debug('Callout body: ' + res.getBody() );
            
            //API Integration Log Generation on success
            API_Integration_Log__c ail = new API_Integration_Log__c();
            ail.JSON_Body__c= requestBody;
            ail.Endpoint__c = endpoint;
            ail.Status__c = 'Failed';
            ail.Request_Type__c = 'GET';
            ail.Response_Body__c = responseBody;
            ail.Name__c = 'Order Status Retrieve from JDE';
            ail.Object__c = 'Order EDarley Site';
            
            try{
                //insert ail;
            } catch(exception ex){
                system.debug('Error : '+ex.getMessage());                
            }
        }
        System.debug('result --->'+result);
        if(result != null){
            return result;
            }
            return result = '';
    }    
}