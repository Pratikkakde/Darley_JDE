public class IntegrationLogDataController {
    @AuraEnabled
    Public static String processData(String recordID){
        String Message;
        List< API_Integration_Log__c> apiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c,
                                                      Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c where id =:recordID limit 1 ];
        
        String JSONBody= apiLogRecord[0].JSON_Body__c;
        String Endpoint= apiLogRecord[0].Endpoint__c;
        String Method= apiLogRecord[0].Request_Type__c;
        String ObjOperation= apiLogRecord[0].Name__c;
        String ObjName= apiLogRecord[0].Object__c;
        String Status= apiLogRecord[0].Status__c;
        
        
        //For CalloutTORestAPI, which retrieve, product item information.
        if(Endpoint == 'callout:JDE_Integration/ACBM_ORCH_GetItem' && Status == 'Failed'){
            HttpRequest req = new HttpRequest();
            req.setBody(JSONBody);
            req.setTimeout(60000);
            req.setEndpoint(Endpoint);
            req.setMethod(Method);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf('SFAPI:SFAPI123')));
            
            Http h = new Http();
            
            HttpResponse res = h.send(req);
            system.debug('Status: '+res.getStatus());
            system.debug('StatusCode: '+res.getStatusCode());
            String ResponseBody = res.getBody();
            
            Map<String, Object> productCodeMap = (Map<String, Object>) JSON.deserializeUntyped(JSONBody);
            String reqProductCode = (String)productCodeMap.get('2nd Item Number');
            system.debug('Product Code= '+reqProductCode);
            
            
            //API_Integration_Log__c apiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c, Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c where id =:recordID limit 1 ];
            List<API_Integration_Log__c> updateAPILog = new List<API_Integration_Log__c>();
            
            
            if (res.getStatusCode() == 200) {
                // Successful callout
                system.debug('responseBody'+responseBody);
                
                // Process the response body here      
                // Parse the JSON string into a map 
                String Cat_Code_8;
                String Second_Item_Number;
                String Third_Item_Number;
                String Stocking_Type;
                decimal UnitPrice;
                decimal UnitCost;
                String baseDISTI;
                String baseDISTII;
                String baseDISTIII;
                String baseDISTIV;
                String baseDISTV;
                String baseDISTVI;
                Integer Available;
                Integer On_Hand;
                Integer Committed;
                Integer Backorder;
                
                //Old Response Handling
                /*Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                
                if(data.containsKey('ACBM_ORCH_SendItemInformationToSF_Repeating')) {
                    
                    List<Object> priceBookEntryList = (List<Object>)data.get('ACBM_ORCH_SendItemInformationToSF_Repeating');
                    for(Object objIns : priceBookEntryList) {
                        Map<String, Object> innerMap = (Map<String, Object>) objIns;
                        if(innerMap.containsKey('ACBM_ORCH_SendItemInformationToSF')) {
                            Object mapObj = (Object) innerMap.get('ACBM_ORCH_SendItemInformationToSF');
                            Map<String, Object> mapResult = (Map<String, Object>) mapObj;
                            
                            Cat_Code_8 = (String) mapResult.get('Cat Code 8');
                            Second_Item_Number = (String) mapResult.get('Second Item Number');
                            Third_Item_Number = (String)mapResult.get('Third Item Number');
                            Description = (String)mapResult.get('Description');
                            UnitPrice = (String) mapResult.get('Unit Price');
                            UnitCost = (String) mapResult.get('Unit Cost');
                            baseDISTI = (String) mapResult.get('baseDISTI');
                            baseDISTII= (String) mapResult.get('baseDISTII');
                            baseDISTIII= (String) mapResult.get('baseDISTIII');
                            baseDISTIV= (String) mapResult.get('baseDISTIV');
                            baseDISTV= (String) mapResult.get('baseDISTV');
                            baseDISTVI= (String) mapResult.get('baseDISTIV');
                            
                            system.debug('Cat_Code_8 : '+Cat_Code_8);
                        }
                    }
                } */
                
                //New Response Handling
                Map<String, Object> responseDataMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                if(responseDataMap.containsKey('ACBM_ORCH_SendItemInformationToSF')){
                    Object mapObj = (Object)responseDataMap.get('ACBM_ORCH_SendItemInformationToSF');
                    Map<String, Object> mapResult = (Map<String, Object>) mapObj;
                    Cat_Code_8 = (String) mapResult.get('Cat Code 8');
                    Second_Item_Number = (String) mapResult.get('Second Item Number');
                    Third_Item_Number = (String)mapResult.get('Third Item Number');
                    Stocking_Type = (String)mapResult.get('Stocking Type');
                    UnitPrice = (Integer) mapResult.get('Unit Price');
                    UnitCost = (Integer) mapResult.get('Unit Cost');
                    baseDISTI = (String) mapResult.get('baseDISTI');
                    baseDISTII= (String) mapResult.get('baseDISTII');
                    baseDISTIII= (String) mapResult.get('baseDISTIII');
                    baseDISTIV= (String) mapResult.get('baseDISTIV');
                    baseDISTV= (String) mapResult.get('baseDISTV');
                    baseDISTVI= (String) mapResult.get('baseDISTIV');
                    Available= (Integer) mapResult.get('Available');
                    On_Hand= (Integer) mapResult.get('On Hand');
                    Committed= (Integer) mapResult.get('Committed');
                    Backorder= (Integer) mapResult.get('Backorder');
                    
                    system.debug('Cat_Code_8 : '+Cat_Code_8);
                    system.debug('Stocking_Type : '+Stocking_Type);
                    system.debug('Second_Item_Number : '+Second_Item_Number);
                    system.debug('baseDISTI : '+baseDISTI);
                    system.debug('UnitCost : '+UnitCost);
                }
                
                list<Product2> ProductData = [Select id, Name, JDE_Part_Number__c, productCode, isActive, Stocking_Type__c, Vendor_Part_Number__c, Quantity_Available__c, Quantity_On_Hand__c, Quantity_Commited__c, Quantity_Backorder__c from Product2 where (productCode =: reqProductCode OR JDE_Part_Number__c =:reqProductCode)];
                
                List<Product2> updateProductList = new List<Product2>();
                Boolean ProductDataChanged = false ;
                //Loop On Product2 record
                if(!ProductData.isEmpty()){
                    for(product2 pro : ProductData){
                        if(Stocking_Type == 'Obsolete - Use Up'){
                            pro.IsActive = false;
                            pro.JDE_Stocking_Type__c = Stocking_Type;
                            pro.Stocking_Type__c = 'Use-Up';
                            ProductDataChanged = true ;
                        }
                        if(Stocking_Type == 'Obsolete'){
                            pro.IsActive = false;
                            pro.JDE_Stocking_Type__c = Stocking_Type;
                            pro.Stocking_Type__c = 'Obsolete';
                            ProductDataChanged = true ;
                        }
                        if(Stocking_Type != 'Obsolete' && Stocking_Type != 'Obsolete - Use Up'){
                            pro.IsActive = true;
                            pro.JDE_Stocking_Type__c = Stocking_Type;
                            pro.Stocking_Type__c = 'Active';
                            ProductDataChanged = true ;
                        }
                        if(pro.Vendor_Part_Number__c !=  Third_Item_Number || pro.ProductCode != Second_Item_Number || pro.JDE_Part_Number__c != Second_Item_Number || pro.Quantity_Available__c != Available || pro.Quantity_On_Hand__c != On_Hand || pro.Quantity_Commited__c != Committed || pro.Quantity_Backorder__c != Backorder){
                            //pro.Description = Description;
                            pro.Vendor_Part_Number__c = Third_Item_Number;
                            pro.ProductCode = Second_Item_Number;
                            pro.JDE_Part_Number__c = Second_Item_Number;
                            pro.Quantity_Available__c = Available;
                            pro.Quantity_On_Hand__c = On_Hand;
                            pro.Quantity_Commited__c = Committed;
                            pro.Quantity_Backorder__c = Backorder;
                            
                            ProductDataChanged = true ;
                            system.debug('Product Value Changed');
                            
                        }
                        if(ProductDataChanged){
                            updateProductList.add(pro);
                        }  
                    }
                    system.debug('updateProductList:= '+updateProductList);
                    system.debug('updateProductList size:= '+updateProductList.size());
                    if(updateProductList.size()> 0){
                        try{
                            update updateProductList;  // Update Product Record.
                            system.debug('Product values Updated.');
                        }catch (exception ex){
                            system.debug('Error: '+ex.getMessage());
                        }
                    }
                }
                
                
                
                
                //Retriving pricebook entries which are related to Product code and JDE
                List<PricebookEntry> pricebookEntries = [SELECT Pricebook2Id, Pricebook2.Name, Pricebook2.isActive, ProductCode, product2Id, product2.JDE_Part_Number__c, IsActive 
                                                         FROM PricebookEntry 
                                                         where (ProductCode =: Second_Item_Number OR product2.JDE_Part_Number__c =: Second_Item_Number) AND isActive = true];
                
                system.debug('pricebookEntries= '+pricebookEntries);
                List<PricebookEntry> pbeToUpdate = new  List<PricebookEntry>();
                
                //loop on priceBookEntries to update priceBookEntry associated with Product
                for(PricebookEntry pbe : pricebookEntries){
                    if(pbe.Pricebook2.Name == 'Dist I Price Book' && pbe.Pricebook2.isActive == true){
                        if(baseDISTI != null && baseDISTI != ''){
                            pbe.UnitPrice = decimal.valueOf(baseDISTI);
                            pbe.Standard_Cost__c = unitCost;
                            pbeToUpdate.add(pbe); 
                        }
                    }
                    else if(pbe.Pricebook2.Name == 'Dist II Price Book' && pbe.Pricebook2.isActive == true){
                        if(baseDISTII != null && baseDISTII != ''){
                            pbe.UnitPrice = decimal.valueOf(baseDISTII);
                            pbe.Standard_Cost__c = unitCost;
                            pbeToUpdate.add(pbe);   
                        }
                    }
                    else if(pbe.Pricebook2.Name == 'Dist III Price Book' && pbe.Pricebook2.isActive == true){
                        if(baseDISTIII != null && baseDISTIII != ''){
                            pbe.UnitPrice = decimal.valueOf(baseDISTIII);
                            pbe.Standard_Cost__c = unitCost;
                            pbeToUpdate.add(pbe);  
                        }
                    }
                    else if(pbe.Pricebook2.Name == 'Dist IV Price Book' && pbe.Pricebook2.isActive == true){
                        if(baseDISTIV != null && baseDISTIV != ''){
                            pbe.UnitPrice = decimal.valueOf(baseDISTIV);
                            pbe.Standard_Cost__c = unitCost;
                            pbeToUpdate.add(pbe); 
                        }
                    }
                    else if(pbe.Pricebook2.Name == 'Dist V Price Book' && pbe.Pricebook2.isActive == true){
                        if(baseDISTV != null && baseDISTV != ''){
                            pbe.UnitPrice = decimal.valueOf(baseDISTV);
                            pbe.Standard_Cost__c = unitCost;
                            pbeToUpdate.add(pbe); 
                        }
                    }
                    else if(pbe.Pricebook2.Name == 'Dist VI Price Book' && pbe.Pricebook2.isActive == true){
                        if(baseDISTVI != null && baseDISTVI != ''){
                            pbe.UnitPrice = decimal.valueOf(baseDISTVI);
                            pbe.Standard_Cost__c =unitCost;
                            pbeToUpdate.add(pbe);   
                        }
                    }
                    else if(pbe.Pricebook2.Name != 'Dist I Price Book' &&
                            pbe.Pricebook2.Name != 'Dist II Price Book' &&
                            pbe.Pricebook2.Name != 'Dist III Price Book' &&
                            pbe.Pricebook2.Name != 'Dist IV Price Book' &&
                            pbe.Pricebook2.Name != 'Dist V Price Book' &&
                            pbe.Pricebook2.Name != 'Dist VI Price Book' && pbe.Pricebook2.isActive){
                                if(unitCost != null && unitPrice != null ){
                                    pbe.UnitPrice = unitPrice;
                                    pbe.Standard_Cost__c = unitCost;
                                    pbeToUpdate.add(pbe);
                                }
                            }
                }
                
                if(pbeToUpdate.size()>0){
                    try{
                        update pbeToUpdate;   
                    }catch(exception ex){
                        system.debug('Error: '+ex.getMessage());
                    }
                }
                // Successful callout 
                for(API_Integration_Log__c apiLog : apiLogRecord){      
                    apiLog.JSON_Body__c = JSONBody;
                    apiLog.Response_Body__c = ResponseBody;
                    apiLog.Status__c = 'Success';
                    updateAPILog.add(apiLog);
                }
                try{
                    update  updateAPILog;
                    system.debug('Updated Success apiLogRecord= '+apiLogRecord);
                    Message = 'Success' ;
                } catch(exception ex){               
                    system.debug('Error : '+ex.getMessage());
                    Message = 'Failed' ;
                }               
            }
            else {
                // Error handling
                System.debug('Callout error: ' + res.getStatusCode() + ' ' + res.getStatus());
                System.debug('Callout body: ' + res.getBody() );
                
                // For Failed callout
                for(API_Integration_Log__c apiLog : apiLogRecord){         
                    apiLog.JSON_Body__c = JSONBody;
                    apiLog.Response_Body__c = ResponseBody;
                    apiLog.Status__c = 'Failed';
                    updateAPILog.add(apiLog);
                }
                try{
                    update  updateAPILog;
                    system.debug('Updated Failed apiLogRecord= '+apiLogRecord);
                    Message = 'Failed' ;
                } catch(exception ex){               
                    system.debug('Error : '+ex.getMessage());
                    Message = 'Failed' ;
                }    
            }
        }
        
        
        
        
        //For CalloutRestAPiRetriveAB Class, which retrieve Account Information.
        if(Endpoint == 'callout:JDE_Integration/ACBM_ORCH_GetABWhosWhoCustomerInformation' && Status == 'Failed'){
            
            HttpRequest req = new HttpRequest();
            req.setBody(JSONBody);
            req.setTimeout(80000);
            req.setEndpoint(Endpoint);
            req.setMethod(Method);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf('SFAPI:SFAPI123')));
            
            Http h = new Http();
            
            HttpResponse res = h.send(req);
            system.debug('Status: '+res.getStatus());
            system.debug('StatusCode: '+res.getStatusCode());
            String ResponseBody = res.getBody();
            
            Map<String, Object> accountIdMap = (Map<String, Object>) JSON.deserializeUntyped(JSONBody);
            String accountId = (String)accountIdMap.get('Account id');
            system.debug('Account id= '+accountId);
            
            List<API_Integration_Log__c> updateAPILog = new List<API_Integration_Log__c>();
            
            if(res.getStatusCode() == 200) {
                Map<String, object> responseData = (map<String, Object>)json.deserializeUntyped(responseBody);
                
                Integer Address_Number = (Integer)responseData.get('Address Number');
                String Name= (String)responseData.get('Alpha Name');
                String BusinessUnit= (String)responseData.get('Business Unit');
                String DOM_or_EXP= (String)responseData.get('DOM or EXP');
                String BillingCity  = (String)responseData.get('City');
                String BillingState = (String)responseData.get('State');
                String BillingStreet = (String)responseData.get('Address Line 1');
                String BillingPostalCode = (String)responseData.get('Postal Code');
                String Customer_Type = (String)responseData.get('Customer Type');
                String Primary_POC_Email = (String)responseData.get('Electronic Address');
                String Phone = (String)responseData.get('Phone Number');
                String Customer_Price_Group = (String)responseData.get('Customer Price Group');
                String Adjustment_Schedule = (String)responseData.get('Adjustment Schedule');
                Integer Credit_Limit = (Integer)responseData.get('Credit Limit');
                String Payment_Terms = (String)responseData.get('Payment Terms');
                
                if(Customer_Price_Group == '*Blanks'){
                    Customer_Price_Group = null ;
                }
                if(Adjustment_Schedule == '*Blanks'){
                    Adjustment_Schedule = null ;
                }
                if(Customer_Type == '*Blanks'){
                    Customer_Type = null ;
                }
                if(DOM_or_EXP == '                             .'){
                    DOM_or_EXP = null ;
                }
                
                
                List<Account> accList = [Select Id, Name, Primary_Division__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, Primary_POC_Email__c,
                                         Phone, Payment_Terms2__c, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, JDE_Address_Number__c,
                                         Region__c, Customer_Distribution_Channel__c, Customer_Price_Group__c, Credit_Limit__c, Adjustment_Schedule__c from Account where Id=:accountId ];
                
                system.debug('accList= '+accList);
                
                List<Account> accUpdateList = new List<Account>();
                if(accList.size()>0){
                    for(Account a : accList){
                        if(a.Name!= Name || a.Primary_Division__c != BusinessUnit || a.BillingCity != BillingCity || a.BillingState != BillingState || a.BillingStreet!= BillingStreet || a.BillingPostalCode != BillingPostalCode || a.Primary_POC_Email__c != Primary_POC_Email || a.Phone!= phone || a.JDE_Address_Number__c != string.valueOf(Address_Number)  || a.Payment_Terms2__c != Payment_Terms || a.Region__c != Customer_Type || a.Credit_Limit__c != Credit_Limit || a.Customer_Distribution_Channel__c != DOM_or_EXP || a.Customer_Price_Group__c != Customer_Price_Group ||a.Adjustment_Schedule__c != Adjustment_Schedule){
                            a.Name = Name;
                            a.Primary_Division__c = BusinessUnit;
                            a.BillingCity = BillingCity;
                            a.BillingState = BillingState;
                            a.BillingStreet = BillingStreet;
                            a.BillingPostalCode = BillingPostalCode;
                            a.Primary_POC_Email__c = Primary_POC_Email;
                            a.Customer_Distribution_Channel__c = DOM_or_EXP;
                            a.Phone= phone;
                            a.JDE_Address_Number__c = string.valueOf(Address_Number);
                            a.Credit_Limit__c = Credit_Limit;
                            a.Customer_Price_Group__c = Customer_Price_Group;
                            a.Adjustment_Schedule__c = Adjustment_Schedule;
                            a.Payment_Terms2__c = Payment_Terms;
                            a.Region__c = Customer_Type;
                            
                            accUpdateList.add(a);
                        }
                    }
                }
                system.debug('accUpdateList= '+accUpdateList);
                system.debug('accUpdateList Size = '+accUpdateList.size());
                if(accUpdateList.size()>0){
                    try{
                        update accUpdateList;
                    } catch(exception ex){
                        system.debug('Error : '+ex.getMessage());
                    }                           
                }
                
                
                // Successful callout 
                for(API_Integration_Log__c apiLog : apiLogRecord){      
                    apiLog.JSON_Body__c = JSONBody;
                    apiLog.Response_Body__c = ResponseBody;
                    apiLog.Status__c = 'Success';
                    updateAPILog.add(apiLog);
                }
                try{
                    update  updateAPILog;
                    system.debug('Updated Success apiLogRecord= '+apiLogRecord);
                    Message = 'Success' ;
                } catch(exception ex){               
                    system.debug('Error : '+ex.getMessage());
                    Message = 'Failed' ;
                }
                
            } else {
                
                // Error handling
                System.debug('Callout error: ' + res.getStatusCode() + ' ' + res.getStatus());
                System.debug('Callout body: ' + res.getBody() );
                
                // For Failed callout
                for(API_Integration_Log__c apiLog : apiLogRecord){         
                    apiLog.JSON_Body__c = JSONBody;
                    apiLog.Response_Body__c = ResponseBody;
                    apiLog.Status__c = 'Failed';
                    updateAPILog.add(apiLog);
                }
                try{
                    update  updateAPILog;
                    system.debug('Updated Failed apiLogRecord= '+apiLogRecord);
                    Message = 'Failed' ;
                } catch(exception ex){               
                    system.debug('Error : '+ex.getMessage());
                    Message = 'Failed' ;
                }
                
            }
            
        }
        
        
        
        //For calloutOrderStatus, which retrieve order Status.
        //if(Endpoint == 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_GetSalesOrderStatus' && Status == 'Failed'){
        if(Endpoint ==  'callout:JDE_Integration/ACBM_ORCH_SendSalesOrderToSF'&& Status == 'Failed'){
            HttpRequest req = new HttpRequest();
            req.setBody(JSONBody);
            req.setTimeout(80000);
            req.setEndpoint(Endpoint);
            req.setMethod(Method);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf('SFAPI:SFAPI123')));
            
            Http h = new Http();
            
            HttpResponse res = h.send(req);
            system.debug('Status: '+res.getStatus());
            system.debug('StatusCode: '+res.getStatusCode());
            String responseBody = res.getBody();
            
            
            Map<String, Object> orderMap = (Map<String, Object>) JSON.deserializeUntyped(JSONBody);
            String Ord_Number = (String)orderMap.get('Order Number');
            system.debug('Order Number= '+Ord_Number);
            
            
            List<API_Integration_Log__c> updateAPILog = new List<API_Integration_Log__c>();
            
            system.debug('apiLogRecord= '+apiLogRecord);
            
            
            if (res.getStatusCode() == 200) {
                // Successful callout
                
                system.debug('responseBody'+responseBody);
                // Process the response body here
                
                List<Order> updateOrderList = new List<order>(); 
                List<Order> orderList = [Select Id, Name, OrderNumber, StoreStatus__c, JDE_Order_Number__c  from Order where JDE_Order_Number__c =: integer.valueOf(Ord_Number)];
                for(order Od : orderList){
                    if(responseBody.contains('Open')){
                        Od.StoreStatus__c = 'Open';
                        updateOrderList.add(Od);
                    }else if(!responseBody.contains('Open') && responseBody.contains('Cancelled')){
                        Od.StoreStatus__c = 'Cancelled';
                        updateOrderList.add(Od);
                    }else if(responseBody.contains('Shipped') && !responseBody.contains('Cancelled') && !responseBody.contains('Open')){
                        Od.StoreStatus__c = 'Shipped';
                        updateOrderList.add(Od);
                    }
                }
                
                if(updateOrderList.size()>0){
                    try{
                        update updateOrderList; 
                    }catch(exception ex){
                        system.debug('Error: '+ex.getMessage());
                    }
                }
                // Successful callout 
                for(API_Integration_Log__c apiLog : apiLogRecord){      
                    apiLog.JSON_Body__c = JSONBody;
                    apiLog.Response_Body__c = ResponseBody;
                    apiLog.Status__c = 'Success';
                    updateAPILog.add(apiLog);
                }
                try{
                    update  updateAPILog;
                    system.debug('Updated Success apiLogRecord= '+apiLogRecord);
                    Message = 'Success' ;
                } catch(exception ex){               
                    system.debug('Error : '+ex.getMessage());
                    Message = 'Failed' ;
                }
                
            } else {
                
                // Error handling
                System.debug('Callout error: ' + res.getStatusCode() + ' ' + res.getStatus());
                System.debug('Callout body: ' + res.getBody() );
                Message = 'Failed' ;
                
                // For Failed callout
                for(API_Integration_Log__c apiLog : apiLogRecord){         
                    apiLog.JSON_Body__c = JSONBody;
                    apiLog.Response_Body__c = ResponseBody;
                    apiLog.Status__c = 'Failed';
                    updateAPILog.add(apiLog);
                }
                try{
                    update  updateAPILog;
                    system.debug('Updated Failed apiLogRecord= '+apiLogRecord);
                    Message = 'Failed' ;
                } catch(exception ex){               
                    system.debug('Error : '+ex.getMessage());
                    Message = 'Failed' ;
                }  
                
            }
            
        }
        
        
        //For, Account and Contact Insert/Update, and order product insert.
        if((Endpoint == 'callout:JDE_Integration/ACBM_ORCH_AddAB' ||
            Endpoint == 'callout:JDE_Integration/ACBM_ORCH_UpdateAB') && Status == 'Failed'){
                
                //For All Callouts Except Retrieve APIs.
                HttpRequest req = new HttpRequest();
                req.setBody(JSONBody);
                req.setTimeout(80000);
                req.setEndpoint(Endpoint);
                req.setMethod(Method);
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf('SFAPI:SFAPI123')));
                
                Http h = new Http();
                
                HttpResponse res = h.send(req);
                system.debug('Status: '+res.getStatus());
                system.debug('StatusCode: '+res.getStatusCode());
                String ResponseBody = res.getBody();
                
                //API_Integration_Log__c apiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c, Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c where id =:recordID limit 1 ];
                List<API_Integration_Log__c> updateAPILog = new List<API_Integration_Log__c>();
                
                system.debug('apiLogRecord= '+apiLogRecord);
                if (res.getStatusCode() == 200) {
                    
                    // Successful callout 
                    for(API_Integration_Log__c apiLog : apiLogRecord){      
                        apiLog.JSON_Body__c = JSONBody;
                        apiLog.Response_Body__c = ResponseBody;
                        apiLog.Status__c = 'Success';
                        updateAPILog.add(apiLog);
                    }
                    try{
                        update  updateAPILog;
                        system.debug('Updated Success apiLogRecord= '+apiLogRecord);
                        Message = 'Success' ;
                    } catch(exception ex){               
                        system.debug('Error : '+ex.getMessage());
                        Message = 'Failed' ;
                    }
                    
                    
                } else {
                    // Error handling.
                    // For Failed callout
                    for(API_Integration_Log__c apiLog : apiLogRecord){         
                        apiLog.JSON_Body__c = JSONBody;
                        apiLog.Response_Body__c = ResponseBody;
                        apiLog.Status__c = 'Failed';
                        updateAPILog.add(apiLog);
                    }
                    try{
                        update  updateAPILog;
                        system.debug('Updated Failed apiLogRecord= '+apiLogRecord);
                        Message = 'Failed' ;
                    } catch(exception ex){               
                        system.debug('Error : '+ex.getMessage());
                        Message = 'Failed' ;
                    }
                    
                }
                
            }
        
        
        if(Endpoint == 'callout:JDE_Integration/ACBM_ORCH_AddSalesOrder' && Status == 'Failed'){
            //For All Callouts Except Retrieve APIs.
            HttpRequest req = new HttpRequest();
            req.setBody(JSONBody);
            req.setTimeout(80000);
            req.setEndpoint(Endpoint);
            req.setMethod(Method);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf('SFAPI:SFAPI123')));
            
            Http h = new Http();
            
            HttpResponse res = h.send(req);
            system.debug('Status: '+res.getStatus());
            system.debug('StatusCode: '+res.getStatusCode());
            String ResponseBody = res.getBody();
            
            //API_Integration_Log__c apiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c, Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c where id =:recordID limit 1 ];
            List<API_Integration_Log__c> updateAPILog = new List<API_Integration_Log__c>();
            
            Map<String, Object> reqdata = (Map<String, Object>) JSON.deserializeUntyped(JSONBody);
            string sf_order_number = (string)reqdata.get('SalesForce Order Number');
            system.debug('Salesforce Order Number: '+sf_order_number);
            
            system.debug('apiLogRecord= '+apiLogRecord);
            if (res.getStatusCode() == 200) {
                system.debug('ResponseBody'+ResponseBody);
                // Process the response body here
                Map<String, Object> resdata = (Map<String, Object>) JSON.deserializeUntyped(ResponseBody);
                Integer order_number = (Integer)resdata.get('Order Number');
                //String order_status = (string)resdata.get('status');
                system.debug('order_number: '+order_number);
                List<order> odList = [select id, name, status, OrderNumber from order where OrderNumber =: sf_order_number];
                List<order> odUpdateList = new List<order>();
                for(order od : odList){
                    od.JDE_Order_Number__c = decimal.valueOf(order_number);
                    odUpdateList.add(od);
                }
                
                try{
                    update odUpdateList;
                }catch(exception ex){
                    system.debug('Error: '+ex.getMessage());
                }
                // Successful callout 
                for(API_Integration_Log__c apiLog : apiLogRecord){      
                    apiLog.JSON_Body__c = JSONBody;
                    apiLog.Response_Body__c = ResponseBody;
                    apiLog.Status__c = 'Success';
                    updateAPILog.add(apiLog);
                }
                try{
                    update  updateAPILog;
                    system.debug('Updated Success apiLogRecord= '+apiLogRecord);
                    Message = 'Success' ;
                } catch(exception ex){               
                    system.debug('Error : '+ex.getMessage());
                    Message = 'Failed' ;
                }
                
                
            } else {
                // Error handling.
                // For Failed callout
                for(API_Integration_Log__c apiLog : apiLogRecord){         
                    apiLog.JSON_Body__c = JSONBody;
                    apiLog.Response_Body__c = ResponseBody;
                    apiLog.Status__c = 'Failed';
                    updateAPILog.add(apiLog);
                }
                try{
                    update  updateAPILog;
                    system.debug('Updated Failed apiLogRecord= '+apiLogRecord);
                    Message = 'Failed' ;
                } catch(exception ex){               
                    system.debug('Error : '+ex.getMessage());
                    Message = 'Failed' ;
                }
                
            }
            
        }
      
        
        // order product quantity update.
        if(Endpoint == 'callout:JDE_Integration/ACBM_ORCH_UpdateSalesOrder' && Status == 'Failed'){
            
            //For All Callouts Except Retrieve APIs.
            HttpRequest req = new HttpRequest();
            req.setBody(JSONBody);
            req.setTimeout(80000);
            req.setEndpoint(Endpoint);
            req.setMethod(Method);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf('SFAPI:SFAPI123')));
            
            Http h = new Http();
            
            HttpResponse res = h.send(req);
            system.debug('Status: '+res.getStatus());
            system.debug('StatusCode: '+res.getStatusCode());
            String ResponseBody = res.getBody();
            
            //API_Integration_Log__c apiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c, Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c where id =:recordID limit 1 ];
            List<API_Integration_Log__c> updateAPILog = new List<API_Integration_Log__c>();
            
            system.debug('apiLogRecord= '+apiLogRecord);
            if (res.getStatusCode() == 200) {
                
                // Successful callout 
                for(API_Integration_Log__c apiLog : apiLogRecord){      
                    apiLog.JSON_Body__c = JSONBody;
                    apiLog.Response_Body__c = ResponseBody;
                    apiLog.Status__c = 'Success';
                    updateAPILog.add(apiLog);
                }
                try{
                    update  updateAPILog;
                    system.debug('Updated Success apiLogRecord= '+apiLogRecord);
                    Message = 'Success' ;
                } catch(exception ex){               
                    system.debug('Error : '+ex.getMessage());
                    Message = 'Failed' ;
                }
                
                
            } else {
                // Error handling.
                // For Failed callout
                for(API_Integration_Log__c apiLog : apiLogRecord){         
                    apiLog.JSON_Body__c = JSONBody;
                    apiLog.Response_Body__c = ResponseBody;
                    apiLog.Status__c = 'Failed';
                    updateAPILog.add(apiLog);
                }
                try{
                    update  updateAPILog;
                    system.debug('Updated Failed apiLogRecord= '+apiLogRecord);
                    Message = 'Failed' ;
                } catch(exception ex){               
                    system.debug('Error : '+ex.getMessage());
                    Message = 'Failed' ;
                }
                
            }
            
        }
        
        
         // Order credit card update.
        if(Endpoint == 'callout:JDE_Integration/ACBM_ORCH_autoCreateCCPrepaymentRecord' && Status == 'Failed'){
            
            //For All Callouts Except Retrieve APIs.
            HttpRequest req = new HttpRequest();
            req.setBody(JSONBody);
            req.setTimeout(80000);
            req.setEndpoint(Endpoint);
            req.setMethod(Method);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf('SFAPI:SFAPI123')));
            
            Http h = new Http();
            
            HttpResponse res = h.send(req);
            system.debug('Status: '+res.getStatus());
            system.debug('StatusCode: '+res.getStatusCode());
            String ResponseBody = res.getBody();
            
            //API_Integration_Log__c apiLogRecord = [SELECT id, name__c, Endpoint__c, JSON_Body__c, Object__c, Request_Type__c, Response_Body__c, Status__c from API_Integration_Log__c where id =:recordID limit 1 ];
            List<API_Integration_Log__c> updateAPILog = new List<API_Integration_Log__c>();
            
            system.debug('apiLogRecord= '+apiLogRecord);
            if (res.getStatusCode() == 200) {
                
                // Successful callout 
                for(API_Integration_Log__c apiLog : apiLogRecord){      
                    apiLog.JSON_Body__c = JSONBody;
                    apiLog.Response_Body__c = ResponseBody;
                    apiLog.Status__c = 'Success';
                    updateAPILog.add(apiLog);
                }
                try{
                    update  updateAPILog;
                    system.debug('Updated Success apiLogRecord= '+apiLogRecord);
                    Message = 'Success' ;
                } catch(exception ex){               
                    system.debug('Error : '+ex.getMessage());
                    Message = 'Failed' ;
                }
                
                
            } else {
                // Error handling.
                // For Failed callout
                for(API_Integration_Log__c apiLog : apiLogRecord){         
                    apiLog.JSON_Body__c = JSONBody;
                    apiLog.Response_Body__c = ResponseBody;
                    apiLog.Status__c = 'Failed';
                    updateAPILog.add(apiLog);
                }
                try{
                    update  updateAPILog;
                    system.debug('Updated Failed apiLogRecord= '+apiLogRecord);
                    Message = 'Failed' ;
                } catch(exception ex){               
                    system.debug('Error : '+ex.getMessage());
                    Message = 'Failed' ;
                }
                
            }
            
        }
        
        return message;     
    }
    
}