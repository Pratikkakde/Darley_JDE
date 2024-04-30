/******************************************************************************************************************************************************

Name 			    : OrderUpdateWebService
Author 			    : Pratik Kakade
Purpose			    : This Apex class is designed to update Account records in Salesforce based on data received from JDE Environment.

Description		    : The AccountUpdateWebService class provides a RESTful web service endpoint for updating Account records in Salesforce. 
					  It receives JSON data containing account information from JDE Environment and updates the corresponding Account records in Salesforce based on the provided data. If the account exists, it checks for any changes in the received data and updates the fields accordingly. If no changes are found, it returns a success message indicating that the account is already updated. If the account does not exist, it returns a failure message. It also logs API integration events for successful updates and failures.

Version			    : 1.1
Change Log		    : Change by Pratik - 30-Apr-24
Test Class  		: AccountUpdateWebServiceTest
CreateDate		    : 30 Apr 2024
LastModifiedDate	: 30-Apr-24

******************************************************************************************************************************************************/
@RestResource(urlMapping='/updateOrderInSF')
global  class OrderUpdateWebService {
  
}