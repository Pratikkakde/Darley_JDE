/******************************************************************************************************************************************************

Name                : UpdatePriceBookWebService
    Author              : Pratik Kakade
    Purpose             : This Apex class provides a RESTful web service endpoint for updating or inserting PricebookEntry records in Salesforce.
    Description         : The UpdatePriceBookWebService class processes incoming HTTP POST requests containing product and price information.
    It updates existing PricebookEntry records or inserts new ones if they do not exist.
    The class ensures that the PricebookEntry records are updated with the correct price data based on the provided input.
    It handles various scenarios such as updating entries for multiple price books, inserting new entries when none exist, and logging success or failure of the operations.
    Version             : 1.2
    Change Log          : Created by Pratik Kakade - 26 Jul 2024
    Test Class          : UpdatePriceBookWebServiceTest
    CreateDate          : 13 Oct 2023
    LastModifiedDate    : 26 Jul 2024
    
 ******************************************************************************************************************************************************/
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
        
        Map<String,Object> requestData = (Map<String,Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());
        String returnMessage ;
        String secondItemNumber = String.valueOf(requestData.get('secondItemNumber'));
        String thirdItemNumber = String.valueOf(requestData.get('thirdItemNumber'));
        String unitCost =  String.valueOf(requestData.get('unitCost'));
        String unitPrice =  String.valueOf(requestData.get('unitPrice'));
        String baseDISTI =  String.valueOf(requestData.get('baseDISTI'));
        String baseDISTII =  String.valueOf(requestData.get('baseDISTII'));
        String baseDISTIII =  String.valueOf(requestData.get('baseDISTIII'));
        String baseDISTIV =  String.valueOf(requestData.get('baseDISTIV'));
        String baseDISTV =  String.valueOf(requestData.get('baseDISTV'));
        String baseDISTVI =  String.valueOf(requestData.get('baseDISTVI'));
        String available =  String.valueOf(requestData.get('available'));
        String onHand =  String.valueOf(requestData.get('onHand'));
        String committed =  String.valueOf(requestData.get('committed'));
        String backorder =  String.valueOf(requestData.get('backorder'));
        String RuralMetro =  String.valueOf(requestData.get('baseRuralMetro'));
        String basePump =  String.valueOf(requestData.get('basePump'));
        
        // Query the product based on secondItemNumber
        map<Id,String> pbMap = new map<id,String>();
        Map<Id, PricebookEntry> existingEntriesMap = new Map<Id, PricebookEntry>();
        List<PricebookEntry> insertPriceBookEntryList = new List<priceBookEntry>();
        String prCode = secondItemNumber;
        List<Id> allPricebookIds = new List<Id>();
        List<PricebookEntry> pbeToUpdate = new  List<PricebookEntry>();
        
        //Set of string of PriceBook Name
        Set<String> priceBookNames = new Set<String>();
        for(PriceBookName__mdt pbName : [SELECT Name__c,isActive__c From PriceBookName__mdt WHERE isActive__c = TRUE Order BY Order__c]){
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
        if(String.isNotBlank(RuralMetro)){
            priceBookUnitPrices.put('Rural Metro',Decimal.valueOf(RuralMetro));
        }
        if(String.isNotBlank(basePump)){
            priceBookUnitPrices.put('Pump Price Book',Decimal.valueOf(basePump));
        }
        if(String.isNotBlank(unitPrice)){
            priceBookUnitPrices.put('Enhanced Darley Store Price Book',Decimal.valueOf(unitPrice));
            priceBookUnitPrices.put('Standard Price Book',Decimal.valueOf(unitPrice));
            priceBookUnitPrices.put('Equipment Price Book',Decimal.valueOf(unitPrice));
        }
        
        system.debug('priceBookNames--->'+priceBookNames);
        system.debug('priceBookUnitPrices--->'+priceBookUnitPrices.get('Pump Price Book'));
        
        List<Pricebook2> Pblist= [SELECT Id, Name, IsActive FROM Pricebook2 WHERE IsActive = True  AND Name IN :priceBookNames];
        for(Pricebook2 pb : Pblist){
            pbMap.put(pb.Id,pb.name);
            allPricebookIds.add(pb.Id);
        }
        List<Product2> products = (List<Product2>) Database.query('SELECT Id, ProductCode FROM Product2 WHERE ProductCode = :prCode AND Manual_Price_Update__c = false LIMIT 1');
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
                    } else if(priceBookUnitPrices.get(pbMap.get(pricebookId)) != null) {
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
            }
            else{
                // there is No price book entries found for the product
                // Iterate over active Pricebooks
                for(PriceBook2 pb: [SELECT Id, name,isactive FROM Pricebook2 Where isactive = true AND Name In :priceBookNames ORDER BY IsStandard DESC ]){
                    
                    PricebookEntry pbstdEntry = new PricebookEntry();
                    if(pb.name == pbMap.get(pb.id)&& priceBookUnitPrices.get(pbMap.get(pb.id)) == null && pb.name == 'Standard Price Book'){
                        pbstdEntry.product2Id = prod.id;
                        
                        pbstdEntry.isActive = false;
                        pbstdEntry.UseStandardPrice = false;
                        pbstdEntry.Pricebook2Id = pb.id;
                        if(String.isNotBlank(unitCost)){
                            pbstdEntry.Standard_Cost__c = priceBookUnitPrices.get('Pump Price Book');
                        }
                        System.debug('Is contains Key -->'+priceBookUnitPrices.containsKey('Pump Price Book'));
                        if(priceBookUnitPrices.containsKey('Pump Price Book')){
                            System.debug('Is contains Key -->'+priceBookUnitPrices.containsKey(pbMap.get(pb.id)));
                            System.debug('Get Unit cost --->'+priceBookUnitPrices.get('Pump Price Book'));
                            pbstdEntry.UnitPrice = priceBookUnitPrices.get('Pump Price Book');
                        }
                        insertPriceBookEntryList.add(pbstdEntry);
                    }
                    else if(pb.name == pbMap.get(pb.id)&& priceBookUnitPrices.get(pbMap.get(pb.id)) != null ){
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
                        Exception_Handler.createAilRecordonSuccess(JSON.serializePretty(requestData),URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/updatePriceBook','POST','Update Pricebook from JDE','Price Book Entry',returnMessage);
                        
                    }catch(exception ex){
                        system.debug('Error: '+ex.getMessage());
                        returnMessage = 'Failed to insert pricebook Entries'+ex.getMessage();
                        Exception_Handler.createAilRecordonFail(JSON.serializePretty(requestData),URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/updatePriceBook','POST','Update Pricebook from JDE','Price Book Entry',returnMessage,returnMessage);
                    }
                }
            }
            System.debug('pbeToUpdate--> '+pbeToUpdate);
            if(pbeToUpdate.size()>0){
                try{
                    upsert pbeToUpdate;
                    returnMessage = 'PriceBookEntries are succesfully updated ';
                    Exception_Handler.createAilRecordonSuccess(JSON.serializePretty(requestData),URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/updatePriceBook','POST','Update Pricebook from JDE','Price Book Entry',returnMessage);
                    
                }catch(exception ex){
                    system.debug('Error: '+ex.getMessage());
                    returnMessage = 'Failed '+ex.getMessage();
                    Exception_Handler.createAilRecordonFail(JSON.serializePretty(requestData),URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/updatePriceBook','POST','Update Pricebook from JDE','Price Book Entry',returnMessage,returnMessage);
                }
            }
        }
        else {
            returnMessage = 'No product found for the given product code.Check the product code.';
        }
        return returnMessage;
    }
}