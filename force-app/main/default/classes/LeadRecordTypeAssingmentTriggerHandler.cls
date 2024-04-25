public class LeadRecordTypeAssingmentTriggerHandler {
    
    public Static void RecordTypeAssignment (List<Lead> Leadlist){
        Id CustomerRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id EquipmentProspectRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Equipment Prospect').getRecordTypeId();
        Id InnovationProspectRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Innovation Prospect').getRecordTypeId();
        Id PumpProspectRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Pump Prospect').getRecordTypeId();
        
        for(Lead s:Leadlist){
            if(s.Region__c=='Army'||s.Region__c=='Navy'||s.Region__c=='USAF'||s.Region__c=='USCG'||s.Region__c=='USMC'||s.Region__c=='Federal Agency'){
                s.RecordTypeId=CustomerRecordTypeId;
            }
            
            if(s.Region__c=='Law Enforcement'|| s.Region__c=='EMS/Ambulance' ){
                s.RecordTypeId=EquipmentProspectRecordTypeId;
            }
            if(s.Region__c=='Municipality'|| s.Region__c=='Fire Department'|| s.Region__c=='OEM' ){
                s.RecordTypeId=PumpProspectRecordTypeId;
            }
            if(s.Region__c=='Schools' ){
                s.RecordTypeId=InnovationProspectRecordTypeId;
            }
            
        }
    }
    
}