/**
* Class Name: Exception_HandlerTest
* Purpose:
*   This Apex test class is designed to test the functionality of the Exception_Handler class.
*   It includes test methods to ensure that the Api integration record is  correctly inserting or not 
*   
* Description:
*   This test class contains comprehensive test cases to validate the behavior of the 
*   Exception_Handler class. It covers scenarios such as successful insert
*
* TestClass for
*   Exception_Handler
*
* @author
*   Melonleaf Consulting
*
* @version
*   1.0
*
* @created on
*   Date: 11 Jan 2024
*
* Change Log:
*   Pratik Kakade - 11 Jan 2024 - Developed the first version of the test class.
*/
@isTest
public  class Exception_HandlerTest {
@isTest
private Static void testcreateAilRecordonSucceess(){

    String body = '{"Payment Terms":"NET 15","Country":"United States","Customer Price Group":"*Blanks","State":"Hawaii","Adjustment Schedule":"*Blanks","Division":"Apparatus","Customer Type":"Darley Employee","Account id":"00101000019bKYOAA2","Address Number":40928621,"Alpha Name":"MATT LONG INDIVIDUAL (TEST5)","Business Unit Code":"         200","Search Type":"C","Sold_Bill_To":40928621,"Division Code":"200","DOM or EXP Code":"DOM","Customer Type Code":"FIR","Category Code_15":"WEB","Equipment Customer Type Code":"EMP","Address Line 1":"8889 SPRING LAKE DRIVE","Address Line 2":" ","Address Line 3":" ","Address Line 4":" ","Postal Code":"60525","City":"NEW YORK","County":" ","Line_Number_Phone":1,"Phone Number":"630-625-4561","Credit Limit":1,"Business Unit":"Apparatus","Payment Instrument":"!","DOM or EXP":"Domestic Export"}';
    String endpoint = 'https://darley--partial.sandbox.my.salesforce.com/services/apexrest/updateAccountInSF';
    String requestType = 'Post'; 
    String Event = 'Account update from Jde';
    String obj = 'Account';
    String retMsg = 'Account update succesfully';

    test.startTest();
    Exception_Handler.createAilRecordonSuccess(body,endpoint,requestType,Event,obj,retMsg);

    test.stopTest();
}
    @isTest
private Static void testcreateAilRecordonfail(){

    String body = '{"Payment Terms":"NET 15","Country":"United States","Customer Price Group":"*Blanks","State":"Hawaii","Adjustment Schedule":"*Blanks","Division":"Apparatus","Customer Type":"Darley Employee","Account id":"00101000019bKYOAA2","Address Number":40928621,"Alpha Name":"MATT LONG INDIVIDUAL (TEST5)","Business Unit Code":"         200","Search Type":"C","Sold_Bill_To":40928621,"Division Code":"200","DOM or EXP Code":"DOM","Customer Type Code":"FIR","Category Code_15":"WEB","Equipment Customer Type Code":"EMP","Address Line 1":"8889 SPRING LAKE DRIVE","Address Line 2":" ","Address Line 3":" ","Address Line 4":" ","Postal Code":"60525","City":"NEW YORK","County":" ","Line_Number_Phone":1,"Phone Number":"630-625-4561","Credit Limit":1,"Business Unit":"Apparatus","Payment Instrument":"!","DOM or EXP":"Domestic Export"}';
    String endpoint = 'https://darley--partial.sandbox.my.salesforce.com/services/apexrest/updateAccountInSF';
    String requestType = 'Post'; 
    String Event = 'Account update from Jde';
    String obj = 'Account';
    String retMsg = 'Fail to Udate Account';
    String error = 'type error';

    test.startTest();
    Exception_Handler.createAilRecordonFail(body,endpoint,requestType,Event,obj,retMsg,error);

    test.stopTest();
}
}