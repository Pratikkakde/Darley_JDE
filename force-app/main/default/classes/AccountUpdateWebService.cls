/******************************************************************************************************************************************************

Name 			    : AccountUpdateWebService
Author 			    : Pratik Kakade
Purpose			    : This Apex class is designed to update Account records in Salesforce based on data received from JDE Environment.

Description		    : The AccountUpdateWebService class provides a RESTful web service endpoint for updating Account records in Salesforce. 
					  It receives JSON data containing account information from JDE Environment and updates the corresponding Account records in Salesforce based on the provided data. If the account exists, it checks for any changes in the received data and updates the fields accordingly. If no changes are found, it returns a success message indicating that the account is already updated. If the account does not exist, it returns a failure message. It also logs API integration events for successful updates and failures.

Version			    : 1.2
Change Log		    : Change by Pratik - 19-Feb-24
Test Class  		: AccountUpdateWebServiceTest
CreateDate		    : 04 Jan 2024
LastModifiedDate	: 19-Feb-24

******************************************************************************************************************************************************/

@RestResource(urlMapping='/updateAccountInSF')
global class AccountUpdateWebService {
    
    @HttpPost
    global static String UpdateAccount(){
        String returnMessage = '';
        try{ 
            // Account List TO update Data
            List<Account> accUpdateList = new List<Account>();
            // Deserialize the JSON request into a Map<String, Object>
            Map<String, Object> requestData = (Map<String, Object>)JSON.deserializeUntyped(RestContext.request.requestBody.tostring());
            
            // Extract relevant data from the request
            
            Integer Address_Number = (Integer)requestData.get('Address Number');
            String Name = (String)requestData.get('Alpha Name') ;
            String BusinessUnit = (String)requestData.get('Business Unit'); 
            String DOM_or_EXP = (String)requestData.get('DOM or EXP');
            String BillingCity = (String)requestData.get('City') ;
            String BillingState = (String)requestData.get('State') ;
            String BillingStreet = (String)requestData.get('Address Line 1');
            String BillingPostalCode = (String)requestData.get('Postal Code') ;
            String Primary_POC_Email = (String)requestData.get('Electronic Address') ;
            String Phone = (String)requestData.get('Phone Number') ; 
            String Payment_Terms = (String)requestData.get('Payment Terms'); 
            String AccountId = (string)requestData.get('Account id');
            String Customer_Price_Group = (String)requestData.get('Customer Price Group'); 
            String Adjustment_Schedule = (String)requestData.get('Adjustment Schedule');
            String Customer_Type = (String)requestData.get('Customer Type') ; 
           /* String Amount_Due = (String)requestData.get('Amount Due') ; 
            String Open_Order_Amount = (String)requestData.get('Open Order Amount'); 
            String Average_Days_Late = (String)requestData.get('Average Days Late'); */
            
            
            
            Customer_Price_Group = Customer_Price_Group == '*Blanks'? null : Customer_Price_Group;
            Adjustment_Schedule = Adjustment_Schedule == '*Blanks'? null : Adjustment_Schedule;
            Customer_Type = Customer_Type == '*Blanks'? null : Customer_Type;
            DOM_or_EXP = DOM_or_EXP == '                             .' || DOM_or_EXP == ' .' || DOM_or_EXP == '*Blanks'? null : DOM_or_EXP;
            BillingState = BillingState == ' .'? null : BillingState;
            Integer Credit_Limit = (Integer)requestData.get('Credit Limit');
            
            
            //fetch Acccount Data based on Accountid
            List<Account> accList = [Select Id, Name, Primary_Division__c, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, Primary_POC_Email__c,
                                     Phone, Payment_Terms2__c, ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, JDE_Address_Number__c,
                                     Region__c, Customer_Distribution_Channel__c, Customer_Price_Group__c,Amount_Due__c,Open_Order_Amount__c,Average_Days_Late__c, Credit_Limit__c, Adjustment_Schedule__c from Account where Id=:AccountId];
            
            //Check Account is present or not
            if(!accList.isEmpty()) {  
                for(Account a : accList){
                    if(a.Name != Name || a.Primary_Division__c != BusinessUnit || a.BillingCity != BillingCity || a.BillingState != BillingState || a.BillingStreet!= BillingStreet || a.BillingPostalCode != BillingPostalCode || a.Primary_POC_Email__c != Primary_POC_Email || a.Phone!= phone || a.JDE_Address_Number__c != string.valueOf(Address_Number)  || a.Payment_Terms2__c != Payment_Terms || a.Region__c != Customer_Type || a.Credit_Limit__c != Credit_Limit || a.Customer_Distribution_Channel__c != DOM_or_EXP || a.Customer_Price_Group__c != Customer_Price_Group ||a.Adjustment_Schedule__c != Adjustment_Schedule /*|| a.Amount_Due__c != Decimal.valueOf(Amount_Due) || a.Open_Order_Amount__c != Decimal.valueOf(Open_Order_Amount) || a.Average_Days_Late__c != Integer.valueOf(Average_Days_Late)*/ ){
                        a.Name = Name;
                        a.Primary_Division__c = BusinessUnit;
                        a.BillingCity = BillingCity ;
                        a.BillingState = BillingState ;
                        a.BillingStreet = BillingStreet;
                        a.BillingPostalCode = BillingPostalCode ;
                        a.Primary_POC_Email__c = Primary_POC_Email;
                        a.Customer_Distribution_Channel__c = DOM_or_EXP ;
                        a.Phone = phone;
                        a.JDE_Address_Number__c = String.valueOf(Address_Number);
                        a.Credit_Limit__c = Credit_Limit ;
                        a.Customer_Price_Group__c = Customer_Price_Group;
                        a.Adjustment_Schedule__c = Adjustment_Schedule;
                        a.Payment_Terms2__c = Payment_Terms;
                        a.Region__c = Customer_Type ;
                       /* a.Amount_Due__c = Amount_Due != null ? Decimal.valueOf(Amount_Due) : 0.0;
                        a.Open_Order_Amount__c = Open_Order_Amount != null ? Decimal.valueOf(Open_Order_Amount) : 0.0;
                        a.Average_Days_Late__c = Average_Days_Late != null ? Integer.valueOf(Average_Days_Late) : 0;*/
                        
                        accUpdateList.add(a);
                    }     
                }
                if (accUpdateList.size()>0){  
                    try{
                        update accUpdateList;
                        returnMessage = 'Success: Account update Succesfully';
                        
                        //API Integration Log Generation on success update
                        Exception_Handler.createAilRecordonSuccess(JSON.serializePretty(requestData),URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/updateAccountInSF','POST','Account Data Update from JDE','Account',returnMessage);
                        
                    }catch(Exception ex){
                        system.debug('Error: '+ex.getMessage());
                        system.debug('Error stack tace: '+ex.getStackTraceString());
                        returnMessage =  'Error: Failed to Update Account';
                        String ErrorsException = ex.getMessage(); 
                        
                        //API Integration Log Generation on Failed
                        Exception_Handler.createAilRecordonFail(JSON.serializePretty(requestData),URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/updateAccountInSF','POST','Account Data Update from JDE','Account',returnMessage,ErrorsException);
                        
                    } 
                } else {
                    returnMessage = 'Success: Account already updated, No changes found';
                    Exception_Handler.createAilRecordonSuccess(JSON.serializePretty(requestData),URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/updateAccountInSF','POST','Account Data Update from JDE','Account',returnMessage);
                    
                }
                
            }else{
                returnMessage = 'Failed: Account was Not found in salesforce';
                Exception_Handler.createAilRecordonFail(JSON.serializePretty(requestData),URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/updateAccountInSF','POST','Account Data Update from JDE','Account',returnMessage,returnMessage);
                
            }
        }catch(Exception e){
            returnMessage = '['+e.getStackTraceString()+']: ' +e.getMessage();
            //system.debug('Error : '+e.getMessage());
            
            Exception_Handler.createAilRecordonFail(RestContext.request.requestBody.tostring(),URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/updateAccountInSF','POST','Account Data Update from JDE','Account',returnMessage,returnMessage);
            
        }
        return returnMessage;
    }
}