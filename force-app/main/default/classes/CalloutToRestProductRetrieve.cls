public class CalloutToRestProductRetrieve {
    
    @AuraEnabled    
    public static Void makeCallout(String recordId) {
        list<Product2>ProductData = [Select id, Name, JDE_Part_Number__c, productCode, isActive, Stocking_Type__c, Vendor_Part_Number__c, Quantity_Available__c, Quantity_On_Hand__c, Quantity_Commited__c, Quantity_Backorder__c from Product2 where id=: recordId];
        
        String  ProductCode;
        if(ProductData.size()>0){   
            if(ProductData[0].JDE_Part_Number__c == null){
                ProductCode = ProductData[0].productCode;
            }else{
                ProductCode = ProductData[0].JDE_Part_Number__c;
            }
        }  
        system.debug('ProductCode= '+ProductCode);
        
        // Define the endpoint URL
        //String endpoint = 'https://jdeuxdv1.darley.com:4444/jderest/v3/orchestrator/ACBM_ORCH_GetItem'; 
        String endpoint = 'callout:JDE_Integration/ACBM_ORCH_GetItem'; 
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setTimeout(60000);
        req.setHeader('Content-Type', 'application/json');
        //req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf('SFAPI:SFAPI123')));
        
        // Define the request body
        String requestBody = '{"2nd Item Number": "' + ProductCode + '"}'; 
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
            
            //API Integration Log Generation on success
            API_Integration_Log__c ail = new API_Integration_Log__c();
            ail.JSON_Body__c= requestBody;
            ail.Endpoint__c = endpoint;
            ail.Status__c = 'Success';
            ail.Request_Type__c = 'GET';
            ail.Response_Body__c = responseBody;
            ail.Name__c = 'Product data retrieve from JDE';
            ail.Object__c = 'Price Book Entry';
            
            try{
                insert ail;
            }
            catch(exception ex){
                system.debug('Error : '+ex.getMessage());
            }
            
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
            
            //Old Response handling
            /* Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
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
                UnitPrice = (decimal) mapResult.get('Unit Price');
                UnitCost = (decimal) mapResult.get('Unit Cost');
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
            List<Product2> updateProductList = new List<Product2>();
            Boolean ProductDataChanged = false ;
            //Loop On Product2 record
            if(!ProductData.isEmpty()){
                for(product2 pro : ProductData){
                    if(Stocking_Type == 'Obsolete - Use Up' || Stocking_Type == 'Use Up'){
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
                        pbe.Standard_Cost__c = unitCost;
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
            system.debug('updateProductList:= '+updateProductList);
            system.debug('updateProductList size:= '+updateProductList.size());
            if(pbeToUpdate.size()>0){
                try{
                    update pbeToUpdate;   
                }catch(exception ex){
                    system.debug('Error: '+ex.getMessage());
                }
            }
            
            
        }
        else {
            // Error handling
            System.debug('Callout error: ' + res.getStatusCode() + ' ' + res.getStatus());
            System.debug('Callout body: ' + res.getBody() );
            
            //API Integration Log Generation on Fail.
            API_Integration_Log__c ail = new API_Integration_Log__c();
            ail.JSON_Body__c = requestBody;
            ail.Endpoint__c = endpoint;
            ail.Status__c = 'Failed';
            ail.Request_Type__c = 'GET';
            ail.Response_Body__c = responseBody;
            ail.Name__c = 'Product data retrieve from JDE';
            ail.Object__c = 'Price Book Entry';
            
            try{
                insert ail;
            } 
            catch(exception ex){    
                system.debug('Error : '+ex.getMessage());  
            }               
        }   
    }
}