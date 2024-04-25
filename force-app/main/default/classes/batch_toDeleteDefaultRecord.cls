global class batch_toDeleteDefaultRecord Implements Database.Batchable <sObject> { 
    global Database.queryLocator start(Database.BatchableContext bc) { 
        String query = 'SELECT Id FROM Default_products__c'; 
        return Database.getQueryLocator( query ); 
    }
    global void execute( Database.BatchableContext bc, List < sObject > scope ) {
        system.debug('scope'+scope);
        delete scope; 
    }
    global void finish( Database.BatchableContext bc ) { 
    }
}