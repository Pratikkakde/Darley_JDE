/******************************************************************************************************************************************************

Name 			    : OrderUpdateWebService
Author 			    : Pratik Kakade
Purpose			    : This Apex class is designed to update Order records in Salesforce based on data received from JDE Environment

Description		    : The OrderUpdateWebService class provides a RESTful web service endpoint for updating Order records in Salesforce. 
                      It receives JSON data containing order information from JDE Environment and updates the corresponding Order records in Salesforce based on the provided data. 
                      If the order exists, it checks for any changes in the received data and updates the fields accordingly. If no changes are found, it returns a success message indicating that the order is already updated. 
                      If the order does not exist, it returns a failure message. It also logs API integration events for successful updates and failures.

Version			    : 1.1
Change Log		    : Change by Pratik - 30-Apr-24
Test Class  		: OrderUpdateWebService_test
CreateDate		    : 30 Apr 2024
LastModifiedDate	: 30-Apr-24

******************************************************************************************************************************************************/
@RestResource(urlMapping='/updateOrderInSF')
global  class OrderUpdateWebService {
  
/****************************************************************************************************************************************************************************************************************************
     * @description This method updates the Order records in Salesforce based on data received from JDE Environment.
     * @return String A message indicating the success or failure of the update operation.
****************************************************************************************************************************************************************************************************************************/

    @HttpPost
    global static String UpdateOrder(){
        String returnMessage = '';
        try{

            List<Order> OrdUpdateList = new List<Order> ();
            //Conveting Requested Data imto Map to utilise and add its value to Variables
            Map<String,Object> requestData = (Map<String,object>)JSON.deserializeUntyped(RestContext.request.requestBody.tostring());

            //Asssigning Values to variable
            Integer JDE_Order_Number = Integer.valueOf((String)requestData.get('JDE_Order_Number__c'));
            String Order_Status = (String)requestData.get('Order Status');
            String Tracking_Number = (String)requestData.get('Tracking Number');
            String Ship_Date = (String)requestData.get('Ship Date');
            String Invoice_Date = (String)requestData.get('Invoice Date');
            String Cancle_date = (String)requestData.get('Cancle Date');
            String Line_Number = (String)requestData.get('Line Number');

            //get the Order Data Based on JDE Order Number
            List<Order> OrderData = [SELECT Id, StoreStatus__c, JDE_Order_Number__c, Tracking_Links__c FROM Order WHERE JDE_Order_Number__c  =: JDE_Order_Number];

            //Itrate Over the Order Data if its Found in database
            if ( !OrderData.isEmpty()) {
                for (Order ord: OrderData) {
                    ord.StoreStatus__c = Order_Status;
                    ord.Tracking_Links__c =  ord.Tracking_Links__c == Null ? Tracking_Number : ord.Tracking_Links__c;
                    OrdUpdateList.add(ord);
                }
                //update the Order Record based on updated value 
                if (!OrdUpdateList.isEmpty()){
                update OrdUpdateList;

                //On Success update Creating Api Integration Log Record to track all the Transaction
                returnMessage = 'Success: Order update Succesfully';
                //Exception_Handler.createAilRecordonSuccess(JSON.serializePretty(requestData),URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/updateOrderInSF','POST','Order Data Update from JDE','Order',returnMessage);

                }

            } else {
                //When No Order Found Return Message and Create ail record for this
                returnMessage = 'Not Found: No order found in Salesforce for this JDE Order Number - '+JDE_Order_Number;
                //Exception_Handler.createAilRecordonFail(JSON.serializePretty(requestData),URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/updateOrderInSF','POST','Order Data Update from JDE','Order',returnMessage,returnMessage);

            }
        } catch(Exception e){
             // An error occurred during the execution
             returnMessage = '['+e.getStackTraceString()+']: '+'\n'+ +e.getMessage();
             System.debug('returnMessage --->'+returnMessage);
             // Log the error for further investigation
            //Exception_Handler.createAilRecordonFail(RestContext.request.requestBody.tostring(),URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/updateOrderInSF','POST','Order Data Update from JDE','Order',returnMessage,returnMessage);
        }
        return returnMessage;
    }
}