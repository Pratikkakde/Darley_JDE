@istest
public class LeadRecordTypeAssignmentTest {
    
static testMethod void testLead() {  
          
        Lead objLead = new Lead( FirstName = 'Test', LastName = 'Sample', Company = 'Testing Sample Co',Region__c='Army' );  
        insert objLead;  
        Lead objLead1 = new Lead( FirstName = 'Test', LastName = 'Sample', Company = 'Testing Sample Co',Region__c='Schools' );  
        insert objLead1; 
         Lead objLead2 = new Lead( FirstName = 'Test', LastName = 'Sample', Company = 'Testing Sample Co',Region__c='EMS/Ambulance' );  
        insert objLead2;
        
    
  }    
    
    

}