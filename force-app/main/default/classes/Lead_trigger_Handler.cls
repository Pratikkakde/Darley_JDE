/******************************************************************************************************************************************************
Name                    : Lead_trigger_Handler
Author                  : Melonleaf
Purpose                 : This method is fired  by the Lead trigger on update event only 
Description             : When the email addresses is added to the fields we are sending the RFQ pdf to the supplier bases on the criteria 
                          that due date is greater than today . also we are creating the link between the Bid LIne Items  and account when the lead is converted to Account 

Version                 : 1.0
Change Log              : 
Test Class              : Lead_trigger_Handler_Test
CreateDate              : 25-05-2024
LastModifiedDate        : 25-05-2024
******************************************************************************************************************************************************/

public class Lead_trigger_Handler {
    /******************************************************************************************************************************************************
    The method triggers on the after update event when an email is added to the lead.
     It then sends emails to suppliers whose due date is greater than today, based on the Bid Line Items record.
    ******************************************************************************************************************************************************/
    public static void whentheEmailAreAddtotheEmailfield(List<Lead> listLeadNewVer, Map<Id,Lead> mapleadoldver){
        Id leadRecordTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Supply Partner Application').getRecordTypeId();
        Id recordTypeIdBidLine = Schema.SObjectType.Bid_Line_Item__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
        
        Map<Id,String> setLeadId = new Map<Id,String>();
        If(!listLeadNewVer.isEmpty()){
            For(Lead ledvar : listLeadNewVer){
                system.debug('recordType'+leadRecordTypeID);
                system.debug('the trugger reocrd type id '+ledvar.recordtypeId );
                system.debug('email old is null   +>'+mapleadoldver.get(ledVar.Id).Email_Address__c);
                system.debug('new eamil is present=> '+ledVar.Email_Address__c);
                system.debug(mapleadoldver.get(ledVar.Id).Email_Address__c);
                
                
                If(ledVar.Email_Address__c!=Null && mapleadoldver.get(ledVar.Id).Email_Address__c==Null && ledVar.recordtypeId==leadRecordTypeID){
                    system.debug(ledVar);
                    system.debug('Lead ID Sorted'+ledvar.id);
                    
                    setLeadId.put(ledvar.id,ledVar.Email_Address__c);
                } else  If (ledvar.Email_Address__c!=null && mapleadoldver.get(ledvar.id).Email_Address__c != null && ledVar.recordtypeId==leadRecordTypeID){
                    If(ledvar.Email_Address__c.length() > mapleadoldver.get(ledvar.id).Email_Address__c.length()){
                       // setLeadId.Put(ledvar.Id,ledvar.Email_Address__c.remove(mapleadoldver.get(ledvar.id).Email_Address__c).removeStart(';'));
                    }
                }  
            }
        }
        
        Set<id> setRfqId = new Set<id>();
        Map<String,Bid_Line_Item__c> mapNameBidLine = new Map<String,Bid_Line_Item__c>();
        IF(!setLeadId.isEmpty()){
            system.debug('List of the setLed we are query the bid line item from Lead id '+setLeadId);
            For(Bid_Line_Item__c bidVar :[SELECT  Id, Name, RecordTypeId, Bid_Supplier__c, Lead__c,Status__c,RFQ_Number__r.Contract__c ,Supplier_Name_Text__c, Quote_Numbers__c, Before_due_date__c, Due_Date__c,
                                          Lead__r.Email_Address__c,Lead__r.Company,Bid_supplier__r.Email_Address__c,lead__r.Name,Bid_Supplier__r.Name,Bid_Group_Items__c
                                          FROM Bid_Line_Item__c
                                          WHERE Lead__c IN :setLeadId.keySet() AND Due_Date__c >= TODAY AND RecordTypeId =:recordTypeIdBidLine ]){
                                              bidVar.Lead__r.Email_Address__c=setLeadId.get(bidVar.lead__c);                
                                              setRfqId.add(bidVar.RFQ_Number__c);
                                              mapNameBidLine.put(bidVar.lead__r.Company+'_'+bidVar.Quote_Numbers__c+'.pdf',bidVar);
                                              system.debug(bidVar);
                                          }
        }
        Map<Attachment,Bid_line_item__c> mapAttachBidLie = new Map<Attachment,Bid_line_item__c>();
        If(!setRfqId.isEmpty()){
            system.debug('we are queruying the Attachment by filter ing the recodd from bid line item  '+setRfqId);
            For(Attachment attachVar : [SELECT Id, parentID, Name, Body, ContentType FROM Attachment WHERE ParentID In: setRfqId AND Name In : mapNameBidLine.keySet()]){
                IF (mapNameBidLine.containskey(attachVar.Name)){
                    mapAttachBidLie.put(attachVar,mapNameBidLine.get(attachVar.Name));
                }
            }
            
        }
        
        If(!mapAttachBidLie.isEmpty()){
            // for the code sorthing calling the second method and passing the Attachment to the method 
            System.debug('Map of bid line item and '+mapAttachBidLie);
            Lead_trigger_Handler.sendEmailTotheSupplierWithAttachMent(mapAttachBidLie);
        }  
        
    }
    //this method is created to send the mail to the supplier 
    public static void sendEmailTotheSupplierWithAttachMent(Map<Attachment,Bid_line_item__c> mapAttachwithBidLine){
        try{ 
            Set<Id> setIdBidGroup = new Set<Id>();
            system.debug('Parameter Of the method'+mapAttachwithBidLine);
            For ( Bid_LIne_Item__c bidVar : mapAttachwithBidLine.values()) {
                setIdBidGroup.add(bidVar.Bid_Group_Items__c);
            }
            Map<Id,Bid_LIne_ITem__c> mapIdBidLine = new Map<Id,Bid_Line_Item__c>();
            For (Bid_LIne_Item__c bidVar : [select id,Status__c,Bid_Supplier__r.Email_Address__c,Lead__r.Email_Address__c from Bid_LIne_Item__c where Bid_Group_Items__c IN : setIdBidGroup ]) {
                If(bidVar.Bid_Supplier__r.Email_Address__c != null || bidVar.Lead__r.Email_Address__c != null ) {
                    bidVar.Status__c = 'Sent to Supplier';
                    mapIdBidLine.put(bidVar.Id,bidVar);
                }
                
            }
            if (!mapIdBidLine.isEmpty()){
                system.debug('List update Sendto tSupplier'+mapIdBidLine.Values());
                update mapIdBidLine.Values();
            }
            
        EmailTemplate template = [SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate
                                  WHERE DeveloperName = 'Template_for_Darley_RFQ' Limit 1 ];
        EmailTemplate nullEmailAddress = [SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate 
                                          WHERE DeveloperName = 'Missing_Supplier_Email' Limit 1];
        OrgWideEmailAddress orgWideEmailAddresses = [SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Darley Defense TLS' LIMIT 1];

        // for the id........
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
           Map<string,List<Messaging.EmailFileAttachment>> mapStrListAttch = new Map<string,List<Messaging.EmailFileAttachment>>();
            
            For(Attachment cversion : mapAttachwithBidLine.keySet()){
                If(mapAttachwithBidLine.get(cversion).Lead__r.Email_Address__c!=null  || mapAttachwithBidLine.get(cversion).Bid_Supplier__r.Email_Address__c!=null ){
                    Blob attachmentBody = cversion.Body;
                    Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
                    emailAttachment.setFileName(cversion.Name);
                    emailAttachment.setBody(attachmentBody);
                    emailAttachment.setContentType(cversion.ContentType);
                    If (mapAttachwithBidLine.get(cversion).Bid_Supplier__r.Email_Address__c!=null ){
                        If (mapStrListAttch.containsKey((String)mapAttachwithBidLine.get(cversion).Bid_Supplier__c+(String)mapAttachwithBidLine.get(cversion).Bid_Group_Items__c)){
                            mapStrListAttch.get((String)mapAttachwithBidLine.get(cversion).Bid_Supplier__c+(String)mapAttachwithBidLine.get(cversion).Bid_Group_Items__c).add(emailAttachment);
                        }else{
                            mapStrListAttch.put((String)mapAttachwithBidLine.get(cversion).Bid_Supplier__c+(String)mapAttachwithBidLine.get(cversion).Bid_Group_Items__c, new List<Messaging.EmailFileAttachment>{emailAttachment});

                        }

                    } else {
                             If (mapStrListAttch.containsKey((String)mapAttachwithBidLine.get(cversion).Lead__c+(String)mapAttachwithBidLine.get(cversion).Bid_Group_Items__c)){
                            mapStrListAttch.get((String)mapAttachwithBidLine.get(cversion).Lead__c+(String)mapAttachwithBidLine.get(cversion).Bid_Group_Items__c).add(emailAttachment);
                        }else{
                            mapStrListAttch.put((String)mapAttachwithBidLine.get(cversion).Lead__c+(String)mapAttachwithBidLine.get(cversion).Bid_Group_Items__c, new List<Messaging.EmailFileAttachment>{emailAttachment});

                        }

                    }
                }

            }

        For(Attachment cversion : mapAttachwithBidLine.keySet()){
            If(mapAttachwithBidLine.get(cversion).Lead__r.Email_Address__c!=null  || mapAttachwithBidLine.get(cversion).Bid_Supplier__r.Email_Address__c!=null ){
      
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                // format the due date and replace the text in the classic template with the due date ..............
                
                Datetime dueDate = mapAttachwithBidLine.get(cversion).Before_due_date__c;
                String dueDateString = dueDate.format('MM/dd/yyyy');
                String body = template.HtmlValue.replace('{!Bid_Line_Item__c.Before_due_date__c}', dueDateString);
                email.setHtmlBody(body);
                email.setUseSignature(false);
                If(mapAttachwithBidLine.get(cversion).Lead__r.Email_Address__c!=null){
                    email.setToAddresses(mapAttachwithBidLine.get(cversion).Lead__r.Email_Address__c.split(';'));
                    system.debug('this is the lead trigger email '+mapAttachwithBidLine.get(cversion).Lead__r.Email_Address__c.split(';'));
                    email.Subject = 'Darley_'+mapAttachwithBidLine.get(cversion).RFQ_Number__r.Contract__c+' _RFQ_(' + mapAttachwithBidLine.get(cversion).Lead__r.Company +')_' +  mapAttachwithBidLine.get(cversion).Quote_Numbers__c;
                } else if (mapAttachwithBidLine.get(cversion).Bid_Supplier__r.Email_Address__c!=null) {
                    system.debug('this is the Account trigger email '+mapAttachwithBidLine.get(cversion).Bid_Supplier__r.Email_Address__c.split(';'));
                    email.setToAddresses(mapAttachwithBidLine.get(cversion).Bid_Supplier__r.Email_Address__c.split(';'));
                    email.Subject = 'Darley_'+mapAttachwithBidLine.get(cversion).RFQ_Number__r.Contract__c+' _RFQ_(' + mapAttachwithBidLine.get(cversion).Bid_Supplier__r.Name +')_' +  mapAttachwithBidLine.get(cversion).Quote_Numbers__c;
                }
                email.setTemplateId(template.Id);
                email.setOrgWideEmailAddressId(orgWideEmailAddresses.Id);
                email.setBccSender(true);
                email.setBccAddresses(new String[] { orgWideEmailAddresses.Address });
                email.setTargetObjectId(UserInfo.getUserId());
                email.setSaveAsActivity(false);
                If (mapAttachwithBidLine.get(cversion).Bid_Supplier__r.Email_Address__c!=null ){
                    email.setFileAttachments(mapStrListAttch.get((String)mapAttachwithBidLine.get(cversion).Bid_Supplier__c+(String)mapAttachwithBidLine.get(cversion).Bid_Group_Items__c) );
                } else {
                    email.setFileAttachments( mapStrListAttch.get((String)mapAttachwithBidLine.get(cversion).Lead__c+(String)mapAttachwithBidLine.get(cversion).Bid_Group_Items__c));
                }
                If (mapStrListAttch.containskey((String)mapAttachwithBidLine.get(cversion).Bid_Supplier__c+(String)mapAttachwithBidLine.get(cversion).Bid_Group_Items__c)){
                    emailList.add(email);
                    mapStrListAttch.remove((String)mapAttachwithBidLine.get(cversion).Bid_Supplier__c+(String)mapAttachwithBidLine.get(cversion).Bid_Group_Items__c);
                } else If (mapStrListAttch.containskey((String)mapAttachwithBidLine.get(cversion).Lead__c+(String)mapAttachwithBidLine.get(cversion).Bid_Group_Items__c)){
                    emailList.add(email);
                    mapStrListAttch.remove((String)mapAttachwithBidLine.get(cversion).Lead__c+(String)mapAttachwithBidLine.get(cversion).Bid_Group_Items__c);


                }
               // rfqStatusList.add(mapAttachwithBidLine.get(cversion).status__c);
                
                system.debug(emailList);
            } else {
                    Messaging.SingleEmailMessage email1 = new Messaging.SingleEmailMessage();
                    String body = nullEmailAddress.body; 
                    list<string> nullEmailList=new  list<string>();
                    string specificRecord = System.Label.Null_Email_Address;
                    nullEmailList.add(specificRecord);
                    system.debug('specificRecord'+specificRecord);
                    email1.setUseSignature(false);
                    email1.setToAddresses(specificRecord.split(';'));
                    email1.setTemplateId(template.Id);
                  If(mapAttachwithBidLine.get(cversion).Bid_Supplier__r.Email_Address__c == null &&  mapAttachwithBidLine.get(cversion).Bid_Supplier__c != null){
                    email1.Subject = ' Error while finding the Email Address-->Darley_'+mapAttachwithBidLine.get(cversion).RFQ_Number__r.Contract__c+'_RFQ_(' + mapAttachwithBidLine.get(cversion).Bid_Supplier__r.Name+ ')_' + mapAttachwithBidLine.get(cversion).Quote_Numbers__c;
                    String recordUrl = URL.getOrgDomainUrl().toExternalForm() + '/' + mapAttachwithBidLine.get(cversion).Bid_Supplier__c;
                      email1.setHtmlBody(body+'<br/>'+'<a href="'+recordUrl+'">'+ recordUrl + '</a>');

                  } else If(mapAttachwithBidLine.get(cversion).Lead__r.Email_Address__c == null &&  mapAttachwithBidLine.get(cversion).Lead__c != null){
                      email1.Subject = ' Error while finding the Email Address-->Darley_'+mapAttachwithBidLine.get(cversion).RFQ_Number__r.Contract__c+'_RFQ_(' + mapAttachwithBidLine.get(cversion).Lead__r.Company+ ')_' + mapAttachwithBidLine.get(cversion).Quote_Numbers__c;
                      String recordUrl = URL.getOrgDomainUrl().toExternalForm() + '/' + mapAttachwithBidLine.get(cversion).Lead__c;
                      email1.setHtmlBody(body+'<br/>'+'<a href="'+recordUrl+'">'+ recordUrl + '</a>');
                  }

                    email1.setOrgWideEmailAddressId(orgWideEmailAddresses.Id);
                    email1.setBccSender(true);
                    email1.setBccAddresses(new String[] { orgWideEmailAddresses.Address });
                    email1.setTargetObjectId(UserInfo.getUserId());
                    email1.setSaveAsActivity(false);
                    emailList.add(email1);
                    system.debug('email donot have the email address-->'+ email1);
                }
        }

        
        //messaging.sendEmail(emailList);
        If(!emailList.isEmpty()){
                    system.debug('the size of the email list ===.>>'+emailList.size());
            system.debug(emailList);
            Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
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
        } catch (exception e ){
            system.debug('the messsage '+ e.getMessage());
        }
        
    }
      /******************************************************************************************************************************************************
     This method is call when we converter the lead. the converted lead Account is link  with the exlet recod
    ******************************************************************************************************************************************************/
    public static void linkAccountTOXLTAfterConveert(List<Lead> listNewRecLead,Map<Id,Lead> mapoldLead){
        List<Supplier_XLAT__c> supplierXltUpdate = new List<Supplier_XLAT__c>();
        set<id> leadSetID = new Set<id>();
        If(!listNewRecLead.isEMpty()){
            For(Lead ledvar :listNewRecLead ){
                system.debug(ledvar.ConvertedAccountId);
                system.debug(ledvar);
                If(ledvar.IsConverted==true)
                    leadSetID.add(ledvar.id);        
            }
                                            
             
        }
        IF(!listNewRecLead.isEmpty()){
            For(Supplier_XLAT__c suppXLTVar : [SELECT Id, Account__c, Lead__c,Lead__r.convertedAccountId FROM Supplier_XLAT__c   where  Lead__c IN :leadSetID ]){
                system.debug('This is the  trigger handler in the lead '+suppXLTVar.Lead__r.convertedAccountId);
                IF(suppXLTVar.Account__c==Null){
                    suppXLTVar.Account__c = suppXLTVar.Lead__r.convertedAccountId ;
                    supplierXltUpdate.add(suppXLTVar);
                    system.debug(''+supplierXltUpdate);
                }
            }
        }
        If(!supplierXltUpdate.isEmpty()){
            DataBase.saveResult[] saveResult = database.update(supplierXltUpdate,False);
            for (Database.SaveResult sr : saveResult) {
                if (sr.isSuccess()) { 
                    System.debug( sr.getId()); 
                }else{
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(err.getStatusCode() + ' : ' +err.getMessage() + ' : ' + err.getFields());
                    }
                }
            }
        }
    }
    
}