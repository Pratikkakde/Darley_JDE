public class ReminderEmailSupplier implements Schedulable {
    //to send the reminderEmail to supplier for the quote 
    public void execute(SchedulableContext context) {
        
        Id recordTypeId = Schema.SObjectType.Bid_Line_Item__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
        EmailTemplate template = [
            SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body
            FROM EmailTemplate
            WHERE DeveloperName = 'ReminderEmailSupplier'
        ];
        
        List<Messaging.Email> sendEmailList = new  List<Messaging.Email>();
        
        
        Datetime currentDateTime= Datetime.now();
        system.debug(currentDateTime);
        //
        Integer desiredHour1 = 16;//this is for the prefered supplier 4pm 
        Integer desiredHour2 = 9; //this is for the non prefered supplier at 9AM 
        
        Integer desiredHour3 = 10;// THIS IS for the prefered supplier 10 am
        If (test.isRunningTest()) {
             desiredHour1 = currentDateTime.hour();//this is for the prefered supplier 4pm 
         desiredHour2 = currentDateTime.hour(); //this is for the non prefered supplier at 9AM 
        
         desiredHour3 = currentDateTime.hour();
        }
        system.debug('desiredHour1=> '+desiredHour1+'   desiredHour2 =>'+desiredHour2+'   desiredHour3 =>'+desiredHour3);
        //Datetime currentDateTime = Datetime.now();
        String dayOfWeek = currentDateTime.format('EEEEEE');
        System.debug(dayOfWeek);
        system.debug(currentDateTime.hour()== desiredHour1);
        if (currentDateTime.hour() == desiredHour1 ) {
            List<Account> accListSendEamilPreffSupp = new List<Account>();
            string rfqNum;
            /*  If(dayOfWeek=='Friday'){
accListSendEamilPreffSupp=[Select Id, Name , Email_Address__c,(select Quote_Numbers__c	 from Bid_Line_Items1__r  )
from Account where id in(select Bid_Supplier__c from Bid_Line_Item__c where  (Vendor_Price__c = null OR Vendor_Price__c=0.00 OR Vendor_Price__c=0 ) and Due_Date__c = next_n_days:3 and RecordType.Id=:recordTypeId and Quote_Type__c='Quoted')
and Preferred_Supplier__c = 'Yes' ];

}else
if(dayOfWeek!='Friday'){
accListSendEamilPreffSupp=[Select Id, Name , Email_Address__c	,(select Quote_Numbers__c	 from Bid_Line_Items1__r  )
from Account where id in(select Bid_Supplier__c from Bid_Line_Item__c where  (Vendor_Price__c = null OR Vendor_Price__c=0.00 OR Vendor_Price__c=0 )  and Due_Date__c = next_n_days:1 and RecordType.Id=:recordTypeId   and Quote_Type__c='Quoted')
and Preferred_Supplier__c = 'Yes' ];
}*/
            accListSendEamilPreffSupp=[Select Id, Name , Email_Address__c	,(select Quote_Numbers__c	 from Bid_Line_Items1__r  )
                                       from Account where id in(select Bid_Supplier__c from Bid_Line_Item__c where  (Unit_Cost__c = null OR Unit_Cost__c=0.00 OR Unit_Cost__c=0 )  and Due_Date__c = next_n_days:1 and RecordType.Id=:recordTypeId   and Quote_Type__c='Quoted')
                                       and Preferred_Supplier__c = 'Yes' ];
            System.debug('accListSendEamilPreffSupp ---->'+accListSendEamilPreffSupp);
            
            set<Account> removeDuplicate = new Set<Account>(accListSendEamilPreffSupp);
            List<Account> filterAccount = new List<Account>(removeDuplicate);
            system.debug(filterAccount);
            For(Account acc : filterAccount ){
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                List<String> emailListaddre = new List<String>();
                If (!string.isBlank(acc.Email_Address__c)) {
                     emailListaddre =acc.Email_Address__c.split(';');
                
              
                
                
                email.setToAddresses(emailListaddre);
                // Set the email subject
                email.setSubject('Follow-up: Request for Quote('+acc.Name+'-'+acc.Bid_Line_Items1__r[0].Quote_Numbers__c	+')');
                // email.setPlainTextBody('Hi,\n\nWe hope this message finds you well. We wanted to follow up on our previous request for a quote . As of  we have not received the requested quote from your end.\n\n If you anticipate any further delays or if you require any additional information to complete the quotation, please do not hesitate to contact us.\n\nWarm regards,\nDarley\n');
                // Set the email template ID
                // Id templateId = 'Id'; 
                //email.setTemplateId(templateId);
                email.setTemplateId(template.Id);
                email.setplainTextBody(template.body);
                
                // email.setWhatId(acc.Id);
                
                sendEmailList.add(email);
                system.debug(email);
                
                }
            }
            
        }  
        if (currentDateTime.hour() == desiredHour2) {
            system.debug('Preferred_Supplier__c nO');
            List<Account> accListSendEamilSupp =  [Select Id, Name, Email_Address__c, (select Quote_Numbers__c	 from Bid_Line_Items1__r  )	
                                                   from Account where id in(select Bid_Supplier__c from Bid_Line_Item__c where  (Unit_Cost__c = null OR Unit_Cost__c=0.00 OR Unit_Cost__c=0 ) and Due_Date__c = today and RecordType.Id=:recordTypeId  and Quote_Type__c='Quoted')
                                                   and Preferred_Supplier__c = 'No'   ];
            set<Account> removeDuplicate = new Set<Account>(accListSendEamilSupp);
            List<Account> filterAccount = new List<Account>(removeDuplicate);
            
            
            For(Account acc : filterAccount ){
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                If (acc.Email_Address__c != null ) { 
                List<String> emailListaddre =acc.Email_Address__c.split(';');
                
                email.setToAddresses(emailListaddre);
                
                // Set the email subject
                email.setSubject('Follow-up: Request for Quote('+acc.Name+'-'+acc.Bid_Line_Items1__r[0].Quote_Numbers__c	+')');
                // email.setPlainTextBody('Hi,\n\nWe hope this message finds you well. We wanted to follow up on our previous request for a quote . As of  we have not received the requested quote from your end.\n\n If you anticipate any further delays or if you require any additional information to complete the quotation, please do not hesitate to contact us.\n\nWarm regards,\nDarley\n');
                // Set the email template ID
                //Id templateId = 'Id'; 
                email.setTemplateId(template.id);
                email.setplainTextBody(template.body);
                
                //email.setWhatId(acc.Id);
                
                sendEmailList.add(email);
                }
                
            }
            
            
        } 
        if (currentDateTime.hour() == desiredHour3 ) {
            system.debug('Preferred_Supplier__c yes');
            
            List<Account> accListSendEamilPreffSupp = [Select Id, Name , Email_Address__c, (select Quote_Numbers__c	 from Bid_Line_Items1__r  )	
                                                       from Account where id in(select Bid_Supplier__c from Bid_Line_Item__c where (Unit_Cost__c = null OR Unit_Cost__c=0.00 OR Unit_Cost__c=0 )  and Due_Date__c = today and RecordType.Id=:recordTypeId  and Quote_Type__c='Quoted')
                                                       and Preferred_Supplier__c = 'Yes' ];
            
            set<Account> removeDuplicate = new Set<Account>(accListSendEamilPreffSupp);
            List<Account> filterAccount = new List<Account>(removeDuplicate);
            
            For(Account acc : filterAccount ){
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                If (acc.Email_Address__c != null) { 
                List<String> emailListaddre =acc.Email_Address__c.split(';');
                
                
                email.setToAddresses(emailListaddre);
                
                // Set the email subject
                email.setSubject('Follow-up: Request for Quote('+acc.Name+'-'+acc.Bid_Line_Items1__r[0].Quote_Numbers__c	+')');
                // email.setPlainTextBody('Hi,\n\nWe hope this message finds you well. We wanted to follow up on our previous request for a quote . As of  we have not received the requested quote from your end.\n\n If you anticipate any further delays or if you require any additional information to complete the quotation, please do not hesitate to contact us.\n\nWarm regards,\nDarley\n');
                // Set the email template ID
                // Id templateId = 'Id'; 
                email.setTemplateId(template.id);
                email.setplainTextBody(template.body);
                
                // email.setWhatId(acc.Id);
                
                sendEmailList.add(email);
                
                }
            }
            
            
            
            
        }
        
        If(!sendEmailList.isEmpty()){
            Messaging.SendEmailResult[] result = Messaging.sendEmail(sendEmailList);
            system.debug(result);
            for (Messaging.SendEmailResult result1 : result) {
                if (result1.isSuccess()) {
                    System.debug('Email sent successfully');
                } else {
                    // Handle email sending failure
                    for (Messaging.SendEmailError error : result1.getErrors()) {
                        System.debug('Email sending failed: ' + error.getStatusCode() + ' - ' + error.getMessage());
                        
                    }
                }
            }
        }
        
        
        
        
        
        /* String cronExp = '0 31 6 ? * *'; // Cron expression for daily execution at midnight
ReminderEmailSupplier varBat= new ReminderEmailSupplier();
System.schedule('ReminderEmailSupplier', cronExp, varBat);
String cronExp = '0 0 0 ? * MON-FRI *';
*/
        
        
        
    }
}