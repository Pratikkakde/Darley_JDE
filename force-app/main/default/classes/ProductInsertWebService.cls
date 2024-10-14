                /******************************************************************************************************************************************************
                
                Name 			    : ProductInsertWebService
                    Author 			    : Pratik Kakade
                    Purpose             : This Apex class provides a RESTful web service endpoint for inserting Product records into Salesforce based on data received from JDE Environment.
                    Description         : The ProductInsertWebService class serves as a RESTful web service endpoint designed to handle incoming JSON data containing product information from a JDE (JD Edwards) Environment.
                    Upon receiving the data, it deserializes the JSON payload, creates a new Product2 record in Salesforce with the provided data fields, and attempts to insert it into the database.
                    If successful, it logs an integration event and returns a JSON response indicating the success along with the newly created Product Id. If an error occurs during the insertion process, it catches the exception, logs the error details, and returns a JSON response with the error message and stack trace.
                    Version			    : 1.1
                    Change Log		    : Change by Pratik - 15-Jul-2024
                    Test Class  		: ProductInsertWebService_test
                    CreateDate		    : 15 Jul 2024
                    LastModifiedDate	: 15-Jul-2024
                    
                 ******************************************************************************************************************************************************/
                @RestResource(urlMapping='/AddProductInSF')
                global class ProductInsertWebService {
                    
                    /****************************************************************************************************************************************************************************************************************************
                     *     @description This method Insert the Product records in Salesforce based on data received from JDE Environment.
                     *     @return String A message indicating the success or failure of the Insert operation.
                     ****************************************************************************************************************************************************************************************************************************/
                    @HttpPost
                    global static String AddProduct(){
                        
                        String returnMessage = '';
                        try{
                            Map<String,Object> requestData = (Map<String,Object>)JSON.deserializeuntyped(RestContext.request.RequestBody.tostring());
                            System.debug('requestData ----> '+requestData);
                            String ProdSKU = String.valueOf(requestData.get('StockKeepingUnit'));
                            List<Product2> prdList= [SELECT id ,Vendor_Part_Number__c,JDE_Stocking_Type__c,Quantity_Available__c,Vendor__c, Record_Type__c, Quantity_On_Hand__c, Quantity_Commited__c, Quantity_Backorder__c, Line_Type__c FROM Product2 WHERE StockKeepingUnit =:ProdSKU];
                            if (!prdList.isEmpty()){
                                Product2 prd = new Product2();
                                prd.Id = prdList[0].id;
                                prd.Vendor_Part_Number__c = String.valueOf(requestData.get('Vendor_Part_Number__c'));
                                prd.JDE_Stocking_Type__c = String.valueOf(requestData.get('JDE_Stocking_Type__c'));
                                prd.Quantity_Available__c = Integer.valueOf(requestData.get('Quantity_Available__c'));
                                prd.Vendor__c = String.valueOf(requestData.get('Vendor__c'));
                                prd.Branch_Plant__C = String.valueOf(requestData.get('Branch_Plant__C'));
                                prd.Record_Type__c = String.valueOf(requestData.get('Record_Type_Calculation'));
                                prd.Quantity_On_Hand__c = Integer.valueOf(requestData.get('onHand'));
                                prd.Quantity_Commited__c = Integer.valueOf(requestData.get('committed'));
                                prd.Quantity_Backorder__c = Integer.valueOf(requestData.get('backorder'));
                                prd.Line_Type__c = String.valueOf(requestData.get('LineType'));
                                prd.Quote_Description__c = String.valueOf(requestData.get('Description'));
                                try{
                                    update prd ;
                                returnMessage = '{\n'+'\"Status\":\"Product Update Successfully\",\n'+'\"Product Id\": '+prd.Id+'\n}';
                                System.debug('returnMessage --->'+returnMessage);
                                Exception_Handler.createAilRecordonSuccess(JSON.serializePretty(requestData),URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/updateOrderInSF','POST','Product Update from JDE','Product',returnMessage);
                            }catch(exception e){
                            returnMessage = '{\n'+'\"Status\": \" Failed to Update product details\",\n'+'"Error\": ' +'\"'+e.getStackTraceString()+'\",'+'\n'+'"Error Message\": '+'\"' +e.getMessage()+'\"'+'\n}';
                            System.debug('returnMessage --->'+returnMessage);
                            Exception_Handler.createAilRecordonFail(JSON.serializePretty(requestData),URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/updateOrderInSF','POST','Product Update from JDE','Product',returnMessage,returnMessage);
                        }
                        
                    }else{
                        Product2 pr = new Product2();
                        pr.ProductCode = String.valueOf(requestData.get('ProductCode'));
                        pr.Vendor_Part_Number__c = String.valueOf(requestData.get('Vendor_Part_Number__c'));
                        pr.Name = String.valueOf(requestData.get('Name'));
                        pr.Description = String.valueOf(requestData.get('Description'));
                        pr.JDE_Stocking_Type__c = String.valueOf(requestData.get('JDE_Stocking_Type__c'));
                        pr.StockKeepingUnit =String.valueOf(requestData.get('StockKeepingUnit'));
                        pr.Quantity_Available__c = Integer.valueOf(requestData.get('Quantity_Available__c'));
                        pr.Vendor__c = String.valueOf(requestData.get('Vendor__c'));
                        pr.Branch_Plant__C = String.valueOf(requestData.get('Branch_Plant__C'));
                        pr.Record_Type__c = String.valueOf(requestData.get('Record_Type_Calculation'));
                        pr.JDE_Part_Number__c = String.valueOf(requestData.get('JDE_Part_Number__c'));
                        pr.Quantity_On_Hand__c = Integer.valueOf(requestData.get('onHand'));
                        pr.Quantity_Commited__c = Integer.valueOf(requestData.get('committed'));
                        pr.Quantity_Backorder__c = Integer.valueOf(requestData.get('backorder'));
                        pr.Line_Type__c = String.valueOf(requestData.get('LineType'));
                        pr.Quote_Description__c = String.valueOf(requestData.get('Description'));
                        pr.Description = String.valueOf(requestData.get('Description'));
                        try{
                            insert pr ;
                        returnMessage = '{\n'+'\"Status\":\"Product Insert Successfully\",\n'+'\"Product Id\": '+pr.Id+'\n}';
                        System.debug('returnMessage --->'+returnMessage);
                        Exception_Handler.createAilRecordonSuccess(JSON.serializePretty(requestData),URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/updateOrderInSF','POST','Product Insert from JDE','Product',returnMessage);
                    }catch(exception e){
                    returnMessage = '{\n'+'\"Status\": \" Failed to insert product details\",\n'+'"Error\": ' +'\"'+e.getStackTraceString()+'\",'+'\n'+'"Error Message\": '+'\"' +e.getMessage()+'\"'+'\n}';
                    System.debug('returnMessage --->'+returnMessage);
                    Exception_Handler.createAilRecordonFail(JSON.serializePretty(requestData),URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/updateOrderInSF','POST','Product Insert from JDE','Product',returnMessage,returnMessage);
                }
            }
            
        } catch(exception ex){
            returnMessage = '['+ex.getStackTraceString()+']: '+'\n'+ +ex.getMessage();
            Exception_Handler.createAilRecordonFail(RestContext.request.requestBody.tostring(),URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/updateOrderInSF','POST','Product Insert from JDE','Product',returnMessage,returnMessage);
            
        }
        return returnMessage;
    }
}