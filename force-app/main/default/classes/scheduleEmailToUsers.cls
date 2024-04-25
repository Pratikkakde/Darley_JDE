/*
* Name - scheduleEmailToUsers
* Author - Melonleaf Consulting
* Created Date - 25/08/2022
* Purpose -  Batch for Sending Emails.
* -----------Change Log---------
* Last Modified by - Niketan Singh
* Last Modified Date -4/11/2022
*/


global class scheduleEmailToUsers  implements Database.Batchable<sObject>,Schedulable  {
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'Select id, Name,Invoice_sent__c,Invoice_Paid__c,Payment_Reminder_Date_2__c,Payment_Reminder_Date_1__c,Payment_Reminder_Date_3__c,Subscription_contracts_end_date__c,CX_Survey_Complete__c,Subscription_Type__c,ownerid,On_Boarding_Task_Raise__c,Contact_First_Name__c, Subscription_contracts_start_date__c,Status__c,Customer_Email__c,Account__r.name,Account__r.phone ,owner.Name from Subscription__c ';
        System.debug(query);
        return Database.getQueryLocator(query);   
    }
    
    global void execute(Database.BatchableContext BC, List<Subscription__c> subList) {
        
        System.debug('subList'+subList);
        List<subscription__c> subRecordList = new List<subscription__C>();
        List<Messaging.SingleEmailMessage> mailList;
        // List<Account> acc=new List<Account>();
        //List<Task> tskList = new List<Task>();
        //User ur =[Select id, Email From User where Firstname='Sean' Limit 1];
        //  Account acc2;
        //Email template use we can use any demo template    
        Set<Id> userIds = new Set<Id>(); 
        
        EmailTemplate emailTemp = [SELECT id, Subject ,Body,HtmlValue  FROM EmailTemplate WHERE DeveloperName='Welcome_email_2'];
        EmailTemplate emailTemp1 = [SELECT id, Subject ,Body,HtmlValue FROM EmailTemplate WHERE DeveloperName='six_months_email'];
        EmailTemplate emailTemp2 = [SELECT id, Subject ,Body,HtmlValue FROM EmailTemplate WHERE DeveloperName='Nine_months_email'];
        //  EmailTemplate emailTemp3 = [SELECT id, Subject ,Body,HtmlValue FROM EmailTemplate WHERE DeveloperName='NPS_email_triggered_after_the_call_done_4_weeks_after_purchase'];
        EmailTemplate emailTemp4 = [SELECT id, Subject ,Body,HtmlValue FROM EmailTemplate WHERE DeveloperName='Three_months_Email'];
        EmailTemplate PaymentReminderEmail = [SELECT id, Subject ,Body,HtmlValue FROM EmailTemplate WHERE DeveloperName='Payment_Reminder_1'];
        EmailTemplate emailTemp5 = [SELECT id, Subject ,Body,HtmlValue FROM EmailTemplate WHERE DeveloperName='Subscription_expires_in_30_days'];  
        EmailTemplate emailTemp6 = [SELECT id, Subject ,Body,HtmlValue FROM EmailTemplate WHERE DeveloperName='Expiration_Day_Email'];  
        EmailTemplate emailTemp7 = [SELECT id, Subject ,Body,HtmlValue FROM EmailTemplate WHERE DeveloperName='subscription_renewal_email'];  
        EmailTemplate emailTemp8 = [SELECT id, Subject ,Body,HtmlValue FROM EmailTemplate WHERE DeveloperName='Subscription_email_4_weeks_after_expiry'];  
        
        EmailTemplate outofSub = [SELECT id, Subject ,Body,HtmlValue FROM EmailTemplate WHERE DeveloperName='Subscription_email_4_weeks_after_expiry'];   
        
        
        
        //Code for sending mail after Purchase(welcome) ,4weeks ,12 weeks, 6 months , 9 months
        for(Subscription__c sub: subList){
            System.debug('subList'+sub);
            Date d=Date.today(); 
            
            //  if(sub.Status__c == 'Active-New'){
            System.debug('Customer_Email__c'+sub.Customer_Email__c);   
            //Welcome Email
            if(d == sub.Subscription_contracts_start_date__c && sub.Status__c == 'Active-New' )
            { System.debug('Customer_Email__c'+sub.Customer_Email__c);   
             if(sub.Customer_Email__c !=null)
             {  System.debug('Customer_Email__c'+sub.Customer_Email__c);   
              String emailAddress=sub.Customer_Email__c;
              System.debug(emailAddress);
              List<String> sendTo = new List<String>(); 
              sendTo.add(sub.Customer_Email__c);
              system.debug('sendTo'+sendTo);
              Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
              string body =emailTemp.HtmlValue;
              body = body.replace('{!Subscription__c.Contact_First_Name__c}',sub.Contact_First_Name__c );
              if(sub.Subscription_Type__c!=null){
                  body = body.replace('{!Subscription__c.Subscription_Type__c}',sub.Subscription_Type__c );
                  body = body.replace('{!Subscription__c.Subscription_Type__c}',sub.Subscription_Type__c );
              }
              string subject = emailTemp.Subject;
              subject = subject.replace('{!Subscription__c.Contact_First_Name__c}',sub.Contact_First_Name__c );
              mail.setHtmlBody(body);
              mail.setToAddresses(sendTo);
              mail.setTemplateId(emailTemp.id); 
              mail.setSubject(subject);
              mailList = new List <Messaging.SingleEmailMessage>();
              mailList.add(mail); 
              System.debug('mailList'+mailList); 
              
              Messaging.sendEmail(mailList); 
             }
             task checkinTask = new task();
             checkinTask.Subject = 'Week 1 Check-In via Phone';
             checkinTask.ActivityDate = date.today();
             string usernameRecord = system.label.PaymentDueTaskUsername;
             list<user> userRecord = [select id from user where username =:usernameRecord];
             checkinTask.OwnerId = userRecord[0].id;
             checkinTask.WhatId = sub.id;
             insert checkinTask; 
             system.debug('checkinTask'+checkinTask.id);
             
             
             
            }
            
            
            // After 4 weeks
            else if(d == (sub.Subscription_contracts_start_date__c.addDays(28)) )
                
            {
                system.debug('d==='+(sub.Subscription_contracts_start_date__c));
                if(sub.Customer_Email__c!=null)
                {
                    /*    System.debug('Sending Mail week 4');   
String emailAddress=sub.Customer_Email__c;
System.debug(emailAddress);
List<String> sendTo = new List<String>(); 
sendTo.add(sub.Customer_Email__c);
system.debug('sendTo'+sendTo);
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

string body =emailTemp3.Body;

body = body.replace('{!Subscription__c.Contact_First_Name__c}',sub.Contact_First_Name__c );
body = body.replace('{!Subscription__c.Subscription_Type__c}',sub.Subscription_Type__c );
string subject = emailTemp3.Subject;
subject = subject.replace('{!Subscription__c.Contact_First_Name__c}',sub.Contact_First_Name__c );


mail.setToAddresses(sendTo);
mail.setTemplateId(emailTemp3.id);
mail.setSubject(subject);
mail.setHtmlBody(Body); 
mailList = new List <Messaging.SingleEmailMessage>();
mailList.add(mail); 
System.debug('mailList'+mailList);
// Messaging.sendEmail(mailList);
*/
                }
                
                
                task checkinTask2 = new task();
                checkinTask2.Subject = 'Week 4 Check-In via Phone';
                checkinTask2.ActivityDate = date.today();
                string usernameRecord = system.label.PaymentDueTaskUsername;
                list<user> userRecord = [select id from user where username =:usernameRecord];
                checkinTask2.OwnerId = userRecord[0].id;
                checkinTask2.WhatId = sub.id;
                insert checkinTask2; 
                system.debug('checkinTask2'+checkinTask2.id);
                
            }
            
            // After 3 months ( 12 Weeks) 
            else if(d == sub.Subscription_contracts_start_date__c.addMonths(3)  )
            {
                if(sub.Customer_Email__c!=null)
                {
                    
                    
                    
                    System.debug('Sending Mail week 4');   
                    String emailAddress=sub.Customer_Email__c;
                    System.debug(emailAddress);
                    List<String> sendTo = new List<String>(); 
                    sendTo.add(sub.Customer_Email__c);
                    system.debug('sendTo'+sendTo);
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    string body =emailTemp4.Body;
                    //System.debug(sub.Contact_First_Name__c);
                    body = body.replace('{!Subscription__c.Contact_First_Name__c}',sub.Contact_First_Name__c );
                    if(sub.Subscription_Type__c!=null){
                        body = body.replace('{!Subscription__c.Subscription_Type__c}',sub.Subscription_Type__c );
                    }
                    string subject = emailTemp4.Subject;
                    subject = subject.replace('{!Subscription__c.Contact_First_Name__c}',sub.Contact_First_Name__c );
                    
                    
                    mail.setHtmlBody(body);
                    
                    mail.setToAddresses(sendTo);
                    mail.setTemplateId(emailTemp4.id); 
                    mail.setSubject(subject);
                    
                    // mail.setHtmlBody(emailTemp.HtmlValue); 
                    mailList = new List <Messaging.SingleEmailMessage>();
                    mailList.add(mail); 
                    System.debug('mailList'+mailList); 
                    Messaging.sendEmail(mailList); 
                    
                    
                    
                    
                    
                    
                    
                }
            }
            
            
            //After 6 months
            
            else if(d == sub.Subscription_contracts_start_date__c.addMonths(6) )
            {     
                if(sub.Customer_Email__c!=null)
                {    
                    String emailAddress=sub.Customer_Email__c;
                    List<String> sendTo = new List<String>(); 
                    sendTo.add(sub.Customer_Email__c);
                    system.debug('sendTo'+sendTo);
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(sendTo);
                    mail.setTemplateId(emailTemp1.id);
                    
                    string body =emailTemp1.Body;
                    body = body.replace('{!Subscription__c.Contact_First_Name__c}',sub.Contact_First_Name__c );
                    mail.setHtmlBody(emailTemp1.Body);
                    mail.setHtmlBody(body);
                    
                    string subject = emailTemp1.Subject;
                    subject = subject.replace('{!Subscription__c.Contact_First_Name__c}',sub.Contact_First_Name__c );
                    mail.setSubject(subject);
                    // mail.setPlainTextBody('message');
                    mailList = new List <Messaging.SingleEmailMessage>();
                    mailList.add(mail); 
                    System.debug('mailList'+mailList);
                    Messaging.sendEmail(mailList);
                    
                }
            }
            
            //After 9 months
            else if(d == sub.Subscription_contracts_start_date__c.addMonths(9))
            {
                if(sub.Customer_Email__c!=null)
                {
                    
                    String emailAddress=sub.Customer_Email__c;
                    List<String> sendTo = new List<String>(); 
                    sendTo.add(sub.Customer_Email__c);
                    system.debug('sendTo'+sendTo);
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    string body =emailTemp2.Body;
                    body = body.replace('{!Subscription__c.Contact_First_Name__c}',sub.Contact_First_Name__c );
                    if(sub.owner.Name!=null){
                        body = body.replace('{!Account.OwnerFullName}',sub.owner.Name);
                    }
                    string subject = emailTemp2.Subject;
                    subject = subject.replace('{!Subscription__c.Contact_First_Name__c}',sub.Contact_First_Name__c );  
                    
                    mail.setToAddresses(sendTo);
                    mail.setTemplateId(emailTemp2.id);
                    mail.setSubject(Subject);
                    mail.setHtmlBody(Body);
                    // mail.setPlainTextBody('message'); 
                    mailList = new List <Messaging.SingleEmailMessage>();
                    mailList.add(mail);                         
                    System.debug('mailList'+mailList);
                    Messaging.sendEmail(mailList);
                    
                }
            }
            //   }
            if(sub.Subscription_contracts_end_date__c-30<=System.today()){
                system.debug('30inpymtIf');
                if(sub.CX_Survey_Complete__c==false && sub.On_Boarding_Task_Raise__c==false)
                {     
                    Date dw = date.today();
                    Date nextWeek = dw.addDays(14); 
                    task CXSurvey = new task();
                    CXSurvey.Subject = 'Onboarding Training';
                    CXSurvey.ActivityDate = nextWeek;
                    CXSurvey.OwnerId = sub.ownerid;
                    CXSurvey.WhatId = sub.id;
                    insert CXSurvey; 
                    System.debug(CXSurvey);
                    
                    subscription__c subRecord= new subscription__c();  
                    subRecord.On_Boarding_Task_Raise__c=true;
                    subRecord.id = sub.Id;
                    subRecordList.add(subRecord);
                } 
                
                else if(sub.CX_Survey_Complete__c==true && sub.Invoice_sent__c==true && sub.Invoice_Paid__c==false){
                    system.debug('inpymtIf');
                    
                    // Email for 30 days before expiration
                    if((sub.Subscription_contracts_end_date__c-30)==date.today()  && sub.Customer_Email__c!=null){
                        String emailAddress=sub.Customer_Email__c;
                        List<String> sendTo = new List<String>(); 
                        sendTo.add(sub.Customer_Email__c);
                        system.debug('sendTo'+sendTo);
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(sendTo);
                        mail.setTemplateId(emailTemp5.id);
                        
                        string body = emailTemp5.HtmlValue;
                        body = body.replace('{!Subscription__c.Contact_First_Name__c}',sub.Contact_First_Name__c);
                        if(sub.Account__r.Name!=null){
                            body = body.replace('{!Subscription__c.Account__c}',sub.Account__r.name);
                        }
                        
                        
                        if(sub.owner.Name!=null){
                            body = body.replace('{!Account.OwnerFullName}',sub.owner.Name);
                        }                          system.debug('body'+body);
                        
                        string subject  =emailTemp5.Subject;
                        subject = subject.replace('{!Subscription__c.Contact_First_Name__c}',sub.Contact_First_Name__c);
                        mail.setSubject(subject); 
                        mail.setHtmlBody(body);
                        mailList = new List <Messaging.SingleEmailMessage>();
                        mailList.add(mail);                         
                        System.debug('mailList'+mailList);
                        Messaging.sendEmail(mailList);
                    }
                    
                    
                    
                    
                    if((sub.Subscription_contracts_end_date__c)==date.today()  && sub.Customer_Email__c!=null){
                        String emailAddress=sub.Customer_Email__c;
                        List<String> sendTo = new List<String>(); 
                        sendTo.add(sub.Customer_Email__c);
                        system.debug('sendTo'+sendTo);
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        
                        string body =emailTemp6.Body;
                        body = body.replace('{!Subscription__c.Contact_First_Name__c}',sub.Contact_First_Name__c );
                        if(sub.owner.Name!=null){
                            body = body.replace('{!Account.OwnerFullName}',sub.owner.Name);
                        }
                        if(sub.Account__r.Name!=null){
                            body = body.replace('{!Account.Name}',sub.Account__r.name);
                        }
                        if(sub.owner.Name!=null){
                            body = body.replace('{!Account.Phone}',sub.Account__r.Phone);
                        }
                        string subject = emailTemp6.Subject;
                        subject = subject.replace('{!Subscription__c.Contact_First_Name__c}',sub.Contact_First_Name__c );  
                        
                        mail.setToAddresses(sendTo);
                        mail.setTemplateId(emailTemp6.id);
                        mail.setSubject(Subject);
                        mail.setHtmlBody(Body);
                        // mail.setPlainTextBody('message'); 
                        mailList = new List <Messaging.SingleEmailMessage>();
                        mailList.add(mail);                         
                        System.debug('mailList'+mailList);
                        Messaging.sendEmail(mailList);
                        
                        
                    }
                    if((sub.Subscription_contracts_end_date__c.adddays(+28))==date.today()  && sub.Customer_Email__c!=null){
                        system.debug('sub.Subscription_contracts_end_date__c.adddays(+28))==date.today()'+sub.Subscription_contracts_end_date__c.adddays(+28));
                        System.debug('Sending Mail week 4');   
                        String emailAddress=sub.Customer_Email__c;
                        System.debug(emailAddress);
                        List<String> sendTo = new List<String>(); 
                        sendTo.add(sub.Customer_Email__c);
                        system.debug('sendTo'+sendTo);
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        string body =emailTemp8.Body;
                        //System.debug(sub.Contact_First_Name__c);
                        body = body.replace('{!Subscription__c.Contact_First_Name__c}',sub.Contact_First_Name__c );
                        body = body.replace('{!Subscription__c.Subscription_Type__c}',sub.Subscription_Type__c );
                        string subject = emailTemp8.Subject;
                        subject = subject.replace('{!Subscription__c.Contact_First_Name__c}',sub.Contact_First_Name__c );
                        
                        
                        mail.setHtmlBody(body);
                        
                        mail.setToAddresses(sendTo);
                        mail.setTemplateId(emailTemp8.id); 
                        // mail.setSubject(subject);
                        
                        // mail.setHtmlBody(emailTemp.HtmlValue); 
                        mailList = new List <Messaging.SingleEmailMessage>();
                        mailList.add(mail); 
                        System.debug('mailList'+mailList); 
                        Messaging.sendEmail(mailList); 
                        
                        
                        
                        
                        
                        
                    }
                    //Renewal Email
                    
                    
                    
                    
                }                 
            }
            
            if(sub.Payment_Reminder_Date_1__c == date.today() && sub.Customer_Email__c!=null){
                system.debug('in paymentreminder1--->');
                system.debug('in paymentreminder1--->');
                
                Integer reminderDate1 = sub.Payment_Reminder_Date_1__c.daysBetween(sub.Subscription_contracts_end_date__c);
                String MyString = String.valueOf(reminderDate1);
                system.debug('reminderDate1--->'+reminderDate1);
                system.debug('paymentreminderDate1--->');
                // integer reminderDate1=sub.Subscription_contracts_end_date__c-sub.Payment_Reminder_Date_1__c;
                String emailAddress=sub.Customer_Email__c;
                List<String> sendTo = new List<String>(); 
                sendTo.add(sub.Customer_Email__c);
                system.debug('sendTo'+sendTo);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                string body =PaymentReminderEmail.Body;
                body = body.replace('{!Subscription__c.Contact_First_Name__c}',sub.Contact_First_Name__c );
                if(sub.owner.Name!=null){
                    body = body.replace('{!Account.OwnerFullName}',sub.owner.Name);
                }
                string subject = PaymentReminderEmail.Subject;
                subject = subject.replace('{!Subscription__c.Contact_First_Name__c}',sub.Contact_First_Name__c );  
                
                mail.setToAddresses(sendTo);
                mail.setTemplateId(PaymentReminderEmail.id);
                mail.setSubject(Subject);
                mail.setHtmlBody(Body);
                // mail.setPlainTextBody('message'); 
                mailList = new List <Messaging.SingleEmailMessage>();
                mailList.add(mail);                         
                System.debug('mailList'+mailList);
                Messaging.sendEmail(mailList);
                
            }
            
            if(date.today()==sub.Payment_Reminder_Date_2__c && sub.Customer_Email__c!=null){
                Integer reminderDate2 = sub.Payment_Reminder_Date_2__c.daysBetween(sub.Subscription_contracts_end_date__c);
                system.debug('reminderDate2--->'+reminderDate2);
                
                String emailAddress=sub.Customer_Email__c;
                List<String> sendTo = new List<String>(); 
                sendTo.add(sub.Customer_Email__c);
                system.debug('sendTo'+sendTo);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                string body =PaymentReminderEmail.Body;
                body = body.replace('{!Subscription__c.Contact_First_Name__c}',sub.Contact_First_Name__c );
                if(sub.owner.Name!=null){
                    body = body.replace('{!Account.OwnerFullName}',sub.owner.Name);
                }
                string subject = PaymentReminderEmail.Subject;
                subject = subject.replace('{!Subscription__c.Contact_First_Name__c}',sub.Contact_First_Name__c );  
                
                mail.setToAddresses(sendTo);
                mail.setTemplateId(PaymentReminderEmail.id);
                mail.setSubject(Subject);
                mail.setHtmlBody(Body);
                // mail.setPlainTextBody('message'); 
                mailList = new List <Messaging.SingleEmailMessage>();
                mailList.add(mail);                         
                System.debug('mailList'+mailList);
                Messaging.sendEmail(mailList);
            }
            
            if(date.today()==sub.Payment_Reminder_Date_3__c && sub.Customer_Email__c!=null){
                Integer reminderDate3 = sub.Payment_Reminder_Date_3__c.daysBetween(sub.Subscription_contracts_end_date__c);
                system.debug('reminderDate3--->'+reminderDate3);
                
                String emailAddress=sub.Customer_Email__c;
                List<String> sendTo = new List<String>(); 
                sendTo.add(sub.Customer_Email__c);
                system.debug('sendTo'+sendTo);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                string body =PaymentReminderEmail.Body;
                body = body.replace('{!Subscription__c.Contact_First_Name__c}',sub.Contact_First_Name__c );
                if(sub.owner.Name!=null){
                    body = body.replace('{!Account.OwnerFullName}',sub.owner.Name);
                }
                string subject = PaymentReminderEmail.Subject;
                subject = subject.replace('{!Subscription__c.Contact_First_Name__c}',sub.Contact_First_Name__c );  
                
                mail.setToAddresses(sendTo);
                mail.setTemplateId(PaymentReminderEmail.id);
                mail.setSubject(Subject);
                mail.setHtmlBody(Body);
                // mail.setPlainTextBody('message'); 
                mailList = new List <Messaging.SingleEmailMessage>();
                mailList.add(mail);                         
                System.debug('mailList'+mailList);
                Messaging.sendEmail(mailList);
                
            }
            
            if(date.today()==sub.Payment_Reminder_Date_3__c && sub.Customer_Email__c!=null){
                Date ds = date.today();
                Date nextWeek = ds.addDays(7); 
                task checkinTask = new task();
                checkinTask.Subject = 'Payment due';
                checkinTask.ActivityDate = nextWeek;
                
                string usernameRecord = system.label.PaymentDueTaskUsername;
                list<user> userRecord = [select id from user where username =:usernameRecord];
                checkinTask.OwnerId = userRecord[0].id;
                checkinTask.WhatId = sub.id;
                insert checkinTask; 
                
                
                String emailAddress=sub.Customer_Email__c;
                List<String> sendTo = new List<String>(); 
                sendTo.add(sub.Customer_Email__c);
                system.debug('sendTo'+sendTo);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                string body =PaymentReminderEmail.Body;
                body = body.replace('{!Subscription__c.Contact_First_Name__c}',sub.Contact_First_Name__c );
                if(sub.owner.Name!=null){
                    body = body.replace('{!Account.OwnerFullName}',sub.owner.Name);
                }
                string subject = PaymentReminderEmail.Subject;
                subject = subject.replace('{!Subscription__c.Contact_First_Name__c}',sub.Contact_First_Name__c );  
                
                mail.setToAddresses(sendTo);
                mail.setTemplateId(PaymentReminderEmail.id);
                mail.setSubject(Subject);
                mail.setHtmlBody(Body);
                // mail.setPlainTextBody('message'); 
                mailList = new List <Messaging.SingleEmailMessage>();
                mailList.add(mail);                         
                System.debug('mailList'+mailList);
                Messaging.sendEmail(mailList);
            }
            
            if(sub.Status__c == 'Active-Renewed'){
                
                system.debug('Renewed');
                if(date.today() == sub.Subscription_contracts_start_date__c && sub.Customer_Email__c !=null ){
                    system.debug('Renewed');
                    
                    String emailAddress=sub.Customer_Email__c;
                    List<String> sendTo = new List<String>(); 
                    sendTo.add(sub.Customer_Email__c);
                    system.debug('sendTo'+sendTo);
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(sendTo);
                    mail.setTemplateId(emailTemp7.id);
                    
                    string body =emailTemp7.Body;
                    body = body.replace('{!Subscription__c.Contact_First_Name__c}',sub.Contact_First_Name__c );
                    mail.setHtmlBody(emailTemp7.Body);
                    mail.setHtmlBody(body);
                    
                    string subject = emailTemp7.Subject;
                    subject = subject.replace('{!Subscription__c.Contact_First_Name__c}',sub.Contact_First_Name__c );
                    mail.setSubject(subject);
                    // mail.setPlainTextBody('message');
                    mailList = new List <Messaging.SingleEmailMessage>();
                    mailList.add(mail); 
                    System.debug('mailList'+mailList);
                    Messaging.sendEmail(mailList);
                    
                }
            }  
        }
        if(!subRecordList.isEmpty())
        {
            update subRecordList;
        }
    }     
    
    global void finish(Database.BatchableContext BC) {
        
    }
    global void execute(SchedulableContext SC){
        scheduleEmailToUsers SEU = new scheduleEmailToUsers(); 
        Database.executeBatch(SEU);
        
    }
}