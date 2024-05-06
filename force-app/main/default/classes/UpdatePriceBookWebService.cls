@RestResource(urlMapping='/updatePriceBook')
global class UpdatePriceBookWebService {
    
    public class ItemWrapper { 
        public String secondItemNumber { get; set; }
        public String thirdItemNumber { get; set; }
        public String description { get; set; }
        public String descriptionLine2 { get; set; }
        public String stockingType { get; set; }
        public String costMeth { get; set; }
        public String unitCost { get; set; }
        public String unitPrice { get; set; }
        public String baseDISTI { get; set; }
        public String baseDISTII { get; set; }
        public String baseDISTIII { get; set; }
        public String baseDISTIV { get; set; }
        public String baseDISTV { get; set; }
        public String baseDISTVI { get; set; }
        public String available { get; set; }
        public String onHand { get; set; }
        public String committed { get; set; }
        public String backorder { get; set; }    
    }
    
    
    @HttpPost
    global static String updatePriceBook() {
        String returnMessage ;
        String secondItemNumber ;
        String thirdItemNumber;
        String unitCost;
        String unitPrice;
        String baseDISTI;
        String baseDISTII;
        String baseDISTIII;
        String baseDISTIV;
        String baseDISTV;
        String baseDISTVI;
        String available ;
        String onHand; 
        String committed;
        String backorder;
        
        ItemWrapper pricedata = (ItemWrapper)System.JSON.deserialize(RestContext.request.requestBody.tostring(), ItemWrapper.class);
        system.debug('pricedata'+pricedata);
        
        secondItemNumber = pricedata.secondItemNumber;
        thirdItemNumber = pricedata.thirdItemNumber;
        unitCost = pricedata.unitCost;
        unitPrice = pricedata.unitPrice;        
        baseDISTI = pricedata.baseDISTI;
        baseDISTII = pricedata.baseDISTII;
        baseDISTIII = pricedata.baseDISTIII;
        baseDISTIV = pricedata.baseDISTIV;
        baseDISTV = pricedata.baseDISTV;
        baseDISTVI = pricedata.baseDISTVI;
        available = pricedata.available ;
        onHand = pricedata.onHand; 
        committed = pricedata.committed;
        backorder = pricedata.backorder;        
        
        // Query the product based on secondItemNumber
        map<Id,String> pbMap = new map<id,String>();
        Map<Id, PricebookEntry> existingEntriesMap = new Map<Id, PricebookEntry>();
        List<PricebookEntry> insertPriceBookEntryList = new List<priceBookEntry>();
        String prCode = secondItemNumber;
        List<Id> allPricebookIds = new List<Id>();
        List<PricebookEntry> pbeToUpdate = new  List<PricebookEntry>();
        
        //Set of string of PriceBook Name
        Set<String> priceBookNames = new Set<String>();
        for(PriceBookName__mdt pbName : [SELECT Name__c From PriceBookName__mdt]){
            priceBookNames.add(pbName.Name__c);
        }
        
        //Map of PriceBook Name with price; 
        System.debug('baseDISTI--->'+baseDISTI);
            Map<String, Decimal> priceBookUnitPrices = new Map<String, Decimal>();
        if(String.isNotBlank(baseDISTI)){
            priceBookUnitPrices.put('Dist I Price Book',Decimal.valueOf(baseDISTI));
        }
        if(String.isNotBlank(baseDISTII)){
            priceBookUnitPrices.put('Dist II Price Book',Decimal.valueOf(baseDISTII));
        }
         if(String.isNotBlank(baseDISTIII)){
            priceBookUnitPrices.put('Dist III Price Book',Decimal.valueOf(baseDISTIII));
        }
         if(String.isNotBlank(baseDISTIV)){
            priceBookUnitPrices.put('Dist IV Price Book',Decimal.valueOf(baseDISTIV));
        }
         if(String.isNotBlank(baseDISTV)){
            priceBookUnitPrices.put('Dist V Price Book',Decimal.valueOf(baseDISTV));
        }
         if(String.isNotBlank(baseDISTVI)){
            priceBookUnitPrices.put('Dist VI Price Book',Decimal.valueOf(baseDISTVI));
        }
         if(String.isNotBlank(unitPrice)){
            priceBookUnitPrices.put('Enhanced Darley Store Price Book',Decimal.valueOf(unitPrice));
             priceBookUnitPrices.put('Standard Price Book',Decimal.valueOf(unitPrice));
             priceBookUnitPrices.put('Pump Price Book',Decimal.valueOf(unitPrice));
             priceBookUnitPrices.put('Equipment Price Book',Decimal.valueOf(unitPrice));
        }
                
        system.debug('priceBookNames--->'+priceBookNames);
        system.debug('priceBookUnitPrices--->'+priceBookUnitPrices);
        
        List<Pricebook2> Pblist= [SELECT Id, Name, IsActive FROM Pricebook2 WHERE IsActive = True  AND Name IN :priceBookNames];
        for(Pricebook2 pb : Pblist){
            pbMap.put(pb.Id,pb.name);
            allPricebookIds.add(pb.Id);
        }
        
        List<Product2> products = (List<Product2>) Database.query('SELECT Id, ProductCode FROM Product2 WHERE ProductCode = :prCode LIMIT 1');
        if (!products.isEmpty()) {
            Product2 prod = products[0];
            System.debug(prod);
            
            
            //Query existing entries for the product
            List<PricebookEntry> existingEntries = [SELECT Pricebook2Id, Pricebook2.Name, Pricebook2.isActive, ProductCode, product2Id, product2.JDE_Part_Number__c, IsActive 
                                                    FROM PricebookEntry 
                                                    where (ProductCode =: prod.ProductCode OR product2.JDE_Part_Number__c =:prod.ProductCode) AND Pricebook2Id IN :allPricebookIds];
            
            system.debug('pricebookEntries= '+existingEntries);
            if(!existingEntries.isEmpty()){
                // Add piceBookEntries in Map 
                for (PricebookEntry existingEntry : existingEntries) {
                    existingEntriesMap.put(existingEntry.Pricebook2Id, existingEntry);
                }
                //ittrating over All PriceBookl Id
                for (Id pricebookId : allPricebookIds) {
                    PricebookEntry existingEntry = existingEntriesMap.get(pricebookId);
                    
                    if (existingEntry != null && pbMap.get(pricebookId) != null ) {
                        if(unitCost != null && priceBookUnitPrices.get(pbMap.get(pricebookId)) != null && unitCost.trim() != '' ){
                            existingEntry.Standard_Cost__c = decimal.valueOf(unitCost);  
                        }
                        if(priceBookUnitPrices.containsKey(pbMap.get(pricebookId))){
                            existingEntry.UnitPrice = priceBookUnitPrices.get(pbMap.get(pricebookId));
                        }
                        pbeToUpdate.add(existingEntry);
                        System.debug('pbeToUpdate --->'+pbeToUpdate);
                        
                        
                    } else {
                        PricebookEntry newEntry = new PricebookEntry();
                        newEntry.Pricebook2Id = pricebookId;
                        newEntry.Product2Id = prod.id;
                        newEntry.isActive = true;
                        newEntry.UseStandardPrice = false;
                        if(unitCost != null  && priceBookUnitPrices.get(pbMap.get(pricebookId)) != null  && unitCost.trim() != ''){
                            newEntry.Standard_Cost__c = decimal.valueOf(unitCost);
                        }
                        if(priceBookUnitPrices.containsKey(pbMap.get(pricebookId)) != null){
                               newEntry.UnitPrice = priceBookUnitPrices.get(pbMap.get(pricebookId)); 
                         }
                        
                        pbeToUpdate.add(newEntry);
                        //System.debug('pbeToUpdate --->'+pbeToUpdate);
                    }
                }
                
            } else {
                // there is No price book entries found for the product     
                // Iterate over active Pricebooks
                for(PriceBook2 pb: [SELECT Id, name,isactive FROM Pricebook2 Where isactive = true AND Name In :priceBookNames ORDER BY IsStandard DESC ]){
                    
                    PricebookEntry pbstdEntry = new PricebookEntry(); 
                    if(pb.name == pbMap.get(pb.id) ){
                        pbstdEntry.product2Id = prod.id;
                        
                        pbstdEntry.isActive = true;
                        pbstdEntry.UseStandardPrice = false;    
                        pbstdEntry.Pricebook2Id = pb.id;
                        if(String.isNotBlank(unitCost)){
                            pbstdEntry.Standard_Cost__c = decimal.valueOf(unitCost);
                        }
                        if(priceBookUnitPrices.containsKey(pbMap.get(pb.id))){
                        pbstdEntry.UnitPrice = priceBookUnitPrices.get(pbMap.get(pb.id));
                        }
                        insertPriceBookEntryList.add(pbstdEntry);
                    }
                    
                }
                system.debug('insertPriceBookEntryList---> '+insertPriceBookEntryList);
                // Check if there are new Pricebook Entries to insert
                if(!insertPriceBookEntryList.isEmpty()){
                    try{
                        // Insert the new Pricebook Entries
                        insert insertPriceBookEntryList;
                        returnMessage = 'PriceBookEntries are succesfully inserted ';
                        API_Integration_Log__c ail = new API_Integration_Log__c();
                        ail.JSON_Body__c = RestContext.request.requestBody.tostring();
                        ail.Endpoint__c = URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/updatePriceBook';
                        ail.Status__c = 'Success';
                        ail.Request_Type__c = 'POST';
                        ail.Response_Body__c = returnMessage;
                        ail.Name__c = 'updatePricebook webservice';
                        ail.Object__c = 'Price Book Entry';
                        
                        try{
                            insert ail;    
                        } 
                        catch(exception ex){    
                            system.debug('Error : '+ex.getMessage());   
                        }
                    }catch(exception ex){
                        system.debug('Error: '+ex.getMessage());
                        returnMessage = 'Failed to insert pricebook Entries';
                        API_Integration_Log__c ail = new API_Integration_Log__c();
                        ail.JSON_Body__c = RestContext.request.requestBody.tostring();
                        ail.Endpoint__c = URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/updatePriceBook';
                        ail.Status__c = 'Failed';
                        ail.Request_Type__c = 'POST';
                        ail.Response_Body__c = returnMessage;
                        ail.Name__c = 'updatePricebook webservice';
                        ail.Object__c = 'Price Book Entry';
                        
                        try{
                            insert ail;    
                        } 
                        catch(exception ex1){    
                            system.debug('Error : '+ex1.getMessage());   
                        }
                    }
                }
                
            }
            System.debug('pbeToUpdate--> '+pbeToUpdate);
            if(pbeToUpdate.size()>0){
                try{
                    upsert pbeToUpdate;
                    returnMessage = 'PriceBookEntries are succesfully updated ';
                    API_Integration_Log__c ail = new API_Integration_Log__c();
                    ail.JSON_Body__c = RestContext.request.requestBody.tostring();
                    ail.Endpoint__c = URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/updatePriceBook';
                    ail.Status__c = 'Success';
                    ail.Request_Type__c = 'POST';
                    ail.Response_Body__c = returnMessage;
                    ail.Name__c = 'updatePricebook webservice';
                    ail.Object__c = 'Price Book Entry';
                    
                    try{
                        insert ail;    
                    } 
                    catch(exception ex){    
                        system.debug('Error : '+ex.getMessage());   
                    }
                }catch(exception ex){
                    system.debug('Error: '+ex.getMessage());
                    returnMessage = 'Failed';
                    API_Integration_Log__c ail = new API_Integration_Log__c();
                    ail.JSON_Body__c = RestContext.request.requestBody.tostring();
                    ail.Endpoint__c = URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/updatePriceBook';
                    ail.Status__c = 'Failed';
                    ail.Request_Type__c = 'POST';
                    ail.Response_Body__c = returnMessage;
                    ail.Name__c = 'updatePricebook webservice';
                    ail.Object__c = 'Price Book Entry';
                    ail.Fatal_Errors__c = ex.getMessage();
                    
                    try{
                        insert ail;    
                    } 
                    catch(exception ex1){    
                        system.debug('Error : '+ex1.getMessage());   
                    }
                }
            }
            
        } else {
            returnMessage = 'No product found for the given product code.Check the product code.';  
        }
        return returnMessage; 
        
    }   
    
}