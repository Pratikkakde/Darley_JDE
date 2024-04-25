public class B2BStorePriceSetup {
	public static void setupPrices () {
        
        Id pricebookRecordTypeId = [SELECT Id, name, DeveloperName, SobjectType FROM recordtype WHERE DeveloperName = 'Equipment' and SobjectType = 'Pricebook2'].Id;
        
        Id storeId = [SELECT id, Name FROM WebStore WHERE Name = 'Enhanced Darley Store'].id;
        
        System.debug(pricebookRecordTypeId);
        
        Map<String,String> policies = new Map<String,String> {
            'All Access for Enhanced Darley Store' => '',
            'Quote Only' => ''
        };
        
        List<CommerceEntitlementPolicy> policiesEx = [SELECT Id, Name from CommerceEntitlementPolicy WHERE Name IN :policies.keySet()];
        for (CommerceEntitlementPolicy pol : policiesEx) {
            policies.put(pol.Name, pol.Id);
        }
         
        if (policies.size() != policiesEx.size()) {
            System.debug('Debug => A missing policy');
            throw new B2BPriceSetupException('Exception => A missing policy');
        }
        
        List<String> buyerGroups = new List<String>{
            	//'Catalog Buyer Group',
                'Dist I Buyer Group',
                'Dist II Buyer Group',
                'Dist III Buyer Group',
                'Dist IV Buyer Group',
                'Dist V Buyer Group',
                'Dist VI Buyer Group'
        };
        List<BuyerGroup> buyers = new List<BuyerGroup>();
        
        Integer totalBuyers = [SELECT count() FROM BuyerGroup WHERE Name IN :buyerGroups];
        if (totalBuyers > 0) {
            System.debug('Debug => Buyer groups already created');
            throw new B2BPriceSetupException('Exception => Buyer groups already created');
        }
        
        for(String buyerGroup : buyerGroups) {
            BuyerGroup buyer = new BuyerGroup(
                Name = buyerGroup,
                Description = buyerGroup
            );
            buyers.add(buyer);
        }        
        insert buyers;
        
        Map<String, String> priceBooks = new Map<String, String>{
            //'Catalog Price Book' => 'Base Pricebook',
            'Dist I Price Book' => 'Cost x 1.28', 
            'Dist II Price Book' => 'Cost x 1.25', 
            'Dist III Price Book' => 'Cost x 1.23',
            'Dist IV Price Book' => 'Cost x 1.2',
            'Dist V Price Book' => 'Cost x 1.18', 
            'Dist VI Price Book' => 'Cost x 1.15'
        };
        
        Integer totalPricebooks = [SELECT count() FROM Pricebook2 WHERE Name IN :priceBooks.keySet()];
        if (totalPricebooks > 0) {
            System.debug('Debug => Price Book already created');
            throw new B2BPriceSetupException('Exception => Price Book already created');
        }
		List<Pricebook2> pricebookRecs = new List<Pricebook2>();
        
        for (String pricebookName : priceBooks.keySet()) {
            Pricebook2 price = new Pricebook2(
                Name = pricebookName,
                IsActive = true,
                Description = priceBooks.get(pricebookName),
                RecordTypeId = pricebookRecordTypeId
            );
            pricebookRecs.add(price);
        }
        insert pricebookRecs;
        
        
        //WebStoreBuyerGroup SELECT Id, Name, WebStoreId, BuyerGroupId FROM WebStoreBuyerGroup
        //BuyerGroupPricebook SELECT Id, Name, BuyerGroupId, Pricebook2Id, IsActive, Priority FROM BuyerGroupPricebook
        //CommerceEntitlementBuyerGroup SELECT Id, Name, PolicyId, BuyerGroupId FROM CommerceEntitlementBuyerGroup
        
        List<WebStoreBuyerGroup> storeBuer = new List<WebStoreBuyerGroup>();
        List<BuyerGroupPricebook> buyerPrice = new List<BuyerGroupPricebook>();
        List<CommerceEntitlementBuyerGroup> buyerPolicy = new List<CommerceEntitlementBuyerGroup>();
        
        for (integer bgCount = 0; bgCount < buyers.size(); bgCount++) {
            BuyerGroup bg = buyers[bgCount];
            buyerPolicy.add(new CommerceEntitlementBuyerGroup(PolicyId = policies.get('All Access for Enhanced Darley Store'), BuyerGroupId = bg.Id));
            buyerPolicy.add(new CommerceEntitlementBuyerGroup(PolicyId = policies.get('Quote Only'), BuyerGroupId = bg.Id));
            storeBuer.add(new WebStoreBuyerGroup(WebStoreId = storeId, BuyerGroupId = bg.Id));
            buyerPrice.add(new BuyerGroupPricebook(Pricebook2Id = pricebookRecs[bgCount].Id, BuyerGroupId = bg.Id, IsActive = true));
        }
        
        insert storeBuer;
        insert buyerPrice;
        insert buyerPolicy;
        
    }
    
    public class B2BPriceSetupException extends Exception {}
}