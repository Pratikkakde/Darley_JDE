/**
* Class Name - opportunityProduct
* Purpose -  Here we fecth data from object present in salesforce org and to write specific methods to execute the actions of the object.
* @author  Melonleaf Consulting
* @version 1.0
* @Created on - Date - 18 Oct 2022
*
*Change Log
*
*Harivansh - 18 Oct 2022 Developed the first version of the class  
* 
*/



public with sharing class opportunityProduct {
    
    @AuraEnabled(cacheable=true)
    public static list<Product_Bundle__c> searchProduct( string p1){
        if(p1!=''){
            
            String keyString = '%'+p1+'%';
            
            list<Product_Bundle__c>  p2 = [select id,name,Pump_Image__c, Description__c 
                                           from Product_Bundle__c 
                                           WHERE Name like:keyString  LIMIT 10 ];
            return p2;  
        }
        else{
            list<Product_Bundle__c> p2 = new list<Product_Bundle__c>();
            return p2;
        }
        
    }
    
    // /////////////////////////////////////////////////////
    
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> findOpportunity(String opps) {
        String key = opps + '%';
        list<RecordType>forrecordId = [Select Id From RecordType Where SobjectType = 'Opportunity' AND DeveloperName = 'Pump'];
        string recordID = forrecordId[0].Id;
        return [SELECT Id, Name FROM Opportunity
                WHERE Name LIKE :key AND RecordTypeId =: recordID LIMIT 5];
    }
    
    
    //wrapper to show pump model and it's description with it's image
    @AuraEnabled(cacheable=true)
    public static list<pumpModelWrapper> ProductDetails( string productId){
        list<pumpModelWrapper>ProductDetail = new list<pumpModelWrapper>();
        list<Product_Bundle__c>pblist2 = [select Id,name, Description__c, Pump_Image__c from Product_Bundle__c Where Id =: productId];
        //System.debug('pblist2'+pblist2);
        
        for(Product_Bundle__c PD : pblist2){
            ProductDetail.add(new pumpModelWrapper (PD.Id, PD.name, PD.Description__c, PD.Pump_Image__c));
        }
        return ProductDetail;
    }
    
    public class pumpModelWrapper{
        @AuraEnabled 
        public String Id{get;set;}
        @AuraEnabled 
        public string name {get;set;}
        @AuraEnabled
        public string Description {get;set;}
        @AuraEnabled 
        public string ImageURL {get;set;}
        
        public pumpModelWrapper(string Id, String name, string Description, string ImageURL){
            this.Id = Id;
            this.name = name;
            this.Description = Description;
            this.ImageURL = ImageURL;
        }
    }
    
    
    //to show main Required Bundle 02/03/2023.........................................................
    @AuraEnabled()
    public static list<bundleWrapper> reqBundle( string pumpID){
        list<bundleWrapper> bundlelist = new list<bundleWrapper>();
        
        list<Product_Bundle__c>toGetPumpName = [SELECT id, name FROM Product_Bundle__c WHERE id =:pumpID];
        
        string pumpName= string.valueof(toGetPumpName[0].name);
        
        list<Bundle_Attributes__c>bundleName =[SELECT id, name, Bundle_Sequence__c,Default_Product__c, Product_Bundle__c, Is_Numeric__c 
                                               from Bundle_Attributes__c 
                                               where (NOT Attributes__r.name LIKE '%QTY') AND Product_Bundle__c =: pumpID AND Required__c= 'R' ORDER BY  Bundle_Sequence__c];
        
        system.debug('bundleName-->'+ bundleName);
        system.debug('bundleName size-->'+ bundleName.size());
        for(Bundle_Attributes__c BA : bundleName){
            list<allProductWrapper> allProduct = new list<allProductWrapper>();
            set<string> noDuplicate  = new set<string>();
            list<allProductWrapperCombo> allProductComboList = new list <allProductWrapperCombo>();
            
            for(Default_products__c D: [SELECT id,Product_name__c, name, Bundle_Sequence__c, JDE_component__c FROM Default_products__c WHERE Bundle_Sequence__c =:BA.Bundle_Sequence__c AND name =: pumpName ORDER BY JDE_component__c ]){
                if(D.Bundle_Sequence__c==BA.Bundle_Sequence__c){
                    allProduct.add(new allProductWrapper(D.Product_name__c,D.JDE_component__c,D.id));
                    allProductComboList.add(new allProductWrapperCombo('('+D.JDE_component__c+') '+D.Product_name__c, D.JDE_component__c ));
                    
                }
            }
            // system.debug('allProduct.size()...................'+allProduct.size());
            string Name = BA.Bundle_Sequence__c+'  '+BA.name;
            
            if((allProduct.size()==1)&&(BA.Bundle_Sequence__c != 5)){
                for(allProductWrapper onlySingleOption : allProduct){
                    if(BA.Is_Numeric__c == 'Y'){
                        bundlelist.add(new bundleWrapper(Name, BA.name, BA.id,onlySingleOption.ProductCode, BA.Bundle_Sequence__c, allProduct, allProductComboList, true));
                    }
                    else{
                        bundlelist.add(new bundleWrapper(Name, BA.name, BA.id,onlySingleOption.ProductCode, BA.Bundle_Sequence__c, allProduct, allProductComboList, false));
                    }
                }
            }
            else{
                if(BA.Is_Numeric__c == 'Y'){
                    bundlelist.add(new bundleWrapper(Name, BA.name, BA.id,BA.Default_Product__c, BA.Bundle_Sequence__c, allProduct, allProductComboList, true));
                }
                else{
                    bundlelist.add(new bundleWrapper(Name, BA.name, BA.id,BA.Default_Product__c, BA.Bundle_Sequence__c, allProduct, allProductComboList, false));
                }
            }
            
        }
        
        system.debug('bundlelist.size()........'+bundlelist.size());
        system.debug('bundlelist........'+bundlelist);
        return bundlelist;
    }
    
    public class bundleWrapper{
        @AuraEnabled 
        public String Bname{get;set;}
        @AuraEnabled 
        public String name{get;set;}
        @AuraEnabled 
        public id id {get;set;}
        @AuraEnabled 
        public String value{get;set;}
        @AuraEnabled
        public Decimal BSProductBundle {get;set;}
        @AuraEnabled
        public list<allProductWrapper> ProductName {get;set;}
        @AuraEnabled
        public list<allProductWrapperCombo> forcombo {get;set;}
        @AuraEnabled
        public boolean IsNumeric {get;set;}
        
        
        public bundleWrapper(String Bname, String name,id id,String value,Decimal BSProductBundle , list<allProductWrapper> ProductName, list<allProductWrapperCombo> forcombo, boolean IsNumeric){
            this.Bname= Bname;
            this.name= name;
            this.id = id;
            this.value = value;
            this.BSProductBundle = BSProductBundle;
            this.ProductName = ProductName;
            this.forcombo = forcombo;
            this.IsNumeric = IsNumeric;
        }
    }
    
    
    public class allProductWrapper{
        @AuraEnabled 
        public String Productname{get;set;}
        @AuraEnabled 
        public String ProductCode{get;set;}
        @AuraEnabled 
        public string Productid {get;set;}
        
        
        public allProductWrapper(String Productname, string ProductCode,string Productid){
            this.Productname= Productname;
            this.ProductCode= ProductCode;
            this.Productid = Productid;
        }
    }
    public class allProductWrapperCombo{
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String value {get;set;}
        
        public allProductWrapperCombo(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
    
    
    //to show main optional Bundle .................................02/03/2023........................
    
    @AuraEnabled()
    public static list<optionalbundleWrapper> OptBundle(string pumpID){
        list<optionalbundleWrapper> bundlelist = new list<optionalbundleWrapper>();
        Map<String, Default_products__c> defaultmap = new Map<String, Default_products__c>();
        list<Product_Bundle__c>toGetPumpName = [SELECT id, name from Product_Bundle__c where id =:pumpID];
        
        string pumpName= string.valueof(toGetPumpName[0].name);
        system.debug('pump Name...'+pumpName);
        list<Bundle_Attributes__c>bundleName = [SELECT id, name, Bundle_Sequence__c, Default_Product__c,Product_Bundle__c , Attributes__r.name, Is_Numeric__c
                                                from Bundle_Attributes__c 
                                                where (NOT Attributes__r.name LIKE '%QTY') AND Product_Bundle__c =: pumpID AND Required__c= 'O' ORDER BY  Bundle_Sequence__c];
        
        set<decimal>bundleseq = new set<decimal>();
        for(Bundle_Attributes__c BSeq : bundleName){
            bundleseq.add(BSeq.Bundle_Sequence__c);
        }
        system.debug('pump bundleseq...'+bundleseq);
        
        for(Bundle_Attributes__c BA : bundleName){
            
            list<optallProductWrapper> allProduct = new list<optallProductWrapper>();
            set<string> noDuplicate  = new set<string>();
            list<alloptWrapperCombo> alloptComboList = new list <alloptWrapperCombo>();
            
            for(Default_products__c D: [SELECT Product_name__c, name, Bundle_Sequence__c, JDE_component__c FROM Default_products__c WHERE Bundle_Sequence__c =:BA.Bundle_Sequence__c  AND name =: pumpName ORDER BY JDE_component__c]){
                
                if(!noDuplicate.contains(D.Product_name__c)){
                    noDuplicate.add(D.Product_name__c);
                    if(D.Bundle_Sequence__c == BA.Bundle_Sequence__c){
                        allProduct.add(new optallProductWrapper(D.Product_name__c,D.JDE_component__c,D.id));
                        alloptComboList.add(new alloptWrapperCombo('('+D.JDE_component__c+') '+D.Product_name__c, D.JDE_component__c));
                    }
                }
            }
            string Name = BA.Bundle_Sequence__c+'  '+BA.name;
            
            
            if(allProduct.size()==1){
                for(optallProductWrapper onlySingleOption : allProduct){
                    
                    if(BA.Is_Numeric__c == 'Y'){
                        
                        bundlelist.add(new optionalbundleWrapper(Name, BA.id, onlySingleOption.ProductCode, BA.Bundle_Sequence__c, allProduct, alloptComboList, true));
                    }
                    else{
                        
                        bundlelist.add(new optionalbundleWrapper(Name, BA.id, onlySingleOption.ProductCode, BA.Bundle_Sequence__c, allProduct, alloptComboList, false));
                    }
                }
            }
            else{
                if(BA.Is_Numeric__c == 'Y'){
                    bundlelist.add(new optionalbundleWrapper(Name, BA.id, BA.Default_Product__c, BA.Bundle_Sequence__c, allProduct, alloptComboList, true));
                }
                else{
                    
                    bundlelist.add(new optionalbundleWrapper(Name, BA.id, BA.Default_Product__c, BA.Bundle_Sequence__c, allProduct, alloptComboList, false));
                }
            }
            
        }
        system.debug('result bundlelist...'+bundlelist);
        return bundlelist;
    }
    
    public class optionalbundleWrapper{
        @AuraEnabled 
        public String name{get;set;}
        @AuraEnabled 
        public id id {get;set;}
        @AuraEnabled 
        public String value{get;set;}
        @AuraEnabled
        public Decimal BSProductBundle {get;set;}
        @AuraEnabled
        public list<optallProductWrapper> ProductName {get;set;}
        @AuraEnabled
        public list<alloptWrapperCombo> forcombo {get;set;}
        @AuraEnabled
        public boolean IsNumeric {get;set;}
        
        public optionalbundleWrapper(String name,id id, String value,Decimal BSProductBundle , list<optallProductWrapper> ProductName , list<alloptWrapperCombo> forcombo, boolean IsNumeric ){
            this.name= name;
            this.id = id;
            this.value = value;
            this.BSProductBundle = BSProductBundle;
            this.ProductName = ProductName;
            this.forcombo = forcombo;
            this.IsNumeric = IsNumeric;
        }
    }
    
    public class optallProductWrapper{
        @AuraEnabled 
        public String Productname{get;set;}
        @AuraEnabled 
        public String ProductCode{get;set;}
        @AuraEnabled 
        public string Productid {get;set;}
        
        
        public optallProductWrapper(String Productname, string ProductCode,string Productid){
            this.Productname= Productname;
            this.ProductCode= ProductCode;
            this.Productid = Productid;
        }
    }
    
    public class alloptWrapperCombo{
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String value {get;set;}
        
        public alloptWrapperCombo(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
    
    // for then after selecting if ..................................................................................................
    @AuraEnabled()
    public static list<outerWrapperBSThen> forThenLogic(string comboName ,string Pumpname, string productBundleNameString, string stringBundlecode){
        system.debug('comboName of THEN...'+comboName);
        system.debug('Pumpname in forThenLogic...>'+Pumpname);
        system.debug('productBundleName in forThenLogic...>'+productBundleNameString);
        system.debug('stringBundlecode in forThenLogic...>'+stringBundlecode);
        set<decimal>onlyRule = new set<decimal>();
        
        list<Product_Bundle__c>togetpumpID = [SELECT id, name from Product_Bundle__c where name =:Pumpname];
        string getProductBundleID = togetpumpID[0].id;
        System.debug('togetpumpID--> '+togetpumpID);
        
        
        String[] bundleParts = productBundleNameString.split(' ');
        System.debug('bundleParts ---> '+bundleParts);
        String firstNumber = bundleParts[0];
        System.debug('firstNumber---> '+firstNumber);
        decimal bunsequencetoLimit = decimal.valueOf(firstNumber);
        
        List<Object> listPriceproduct = (List<Object>) JSON.deserializeUntyped(stringBundlecode);
        system.debug('listPriceproduct in forThenLogic...>'+listPriceproduct);
        Map<String, string> mapBundleCode = new map<string, string>();
        for (Object obj : listPriceproduct) {
            Map<String, Object> jsonObj = (Map<String, Object>) obj;
            String key = (String) jsonObj.get('key');
            String value = (String) jsonObj.get('value');
            mapBundleCode.put(key, value);
        }
        system.debug('mapBundleCode in forThenLogic...>'+mapBundleCode);
        
        Map<decimal, String> BScode = new Map<decimal, String>();
        for (String key : mapBundleCode.keySet()) {
            String[] parts = key.split(' ');
            String newKey = parts[0].replaceAll('[^0-9.]', '');
            decimal deciKey = decimal.valueOf(newKey);
            String newValue = mapBundleCode.get(key);
            BScode.put(deciKey, newValue);
        }
        system.debug('BS code map....'+BScode);
        // ...........................................................................................................................
        
        list<outerWrapperBSThen> outerThenWrapper = new list<outerWrapperBSThen>();
        
        list<Product_Bundle_Rule_Engine__c>forandRule=[SELECT id, rule__c, Rule_Seq__c, pump__c, product__r.name, Bundle_Sequence__c, JDE_Component__c, Logic__c, Component_Type__c, Logic_Releationship__c, Is_Conditional_List__c, Is_Blank__c FROM Product_Bundle_Rule_Engine__c WHERE (Logic__c='if' OR Logic__c = 'And') AND Bundle_Sequence__c =:bunsequencetoLimit AND pump__c=:Pumpname AND Logic_Releationship__c ='EQ' ORDER BY JDE_Component__c];
        set<decimal> whenConditionalListTRUE = new set<decimal>();
        list<Rule_Picklist__c> secondForRule0 = [SELECT id,rule__c, Rule_Seq__c, Pump_Bundle__c ,product__r.name, Bundle_Sequence__c, component__c, Component_Type__c
                                                 from rule_picklist__c WHERE component__c =:comboName  AND Pump_Bundle__c=:Pumpname AND Bundle_Sequence__c =: bunsequencetoLimit ORDER BY component__c];
        System.debug('forandRule size---> ' +forandRule.size());
        System.debug('secondForRule0 size---> ' +secondForRule0.size());
        if(!forandRule.isEmpty()){
            for(Product_Bundle_Rule_Engine__c forruleNumber :forandRule){
                if((forruleNumber.JDE_Component__c == comboName)&&(forruleNumber.Is_Conditional_List__c == false)){
                    System.debug('forruleNumber.rule__c---> '+forruleNumber.rule__c);
                    onlyRule.add(forruleNumber.rule__c);
                    
                    
                }
                
                if(forruleNumber.Is_Conditional_List__c == true){
                    for(Rule_Picklist__c sr : secondForRule0){
                        System.debug('sr.rule__c---> '+sr.rule__c +' AND ' +' forruleNumber.rule__c-->>'+ forruleNumber.rule__c);
                        if(sr.rule__c == forruleNumber.rule__c){
                            System.debug('sr.rule__c---> '+sr.rule__c);
                            onlyRule.add(sr.rule__c);
                        }
                        
                    }
                    
                    // if(secondForRule0.isEmpty()){
                    //     System.debug('break---> ');
                    //     break;
                    
                    // }
                    
                }
            }
        }
        
        list<Product_Bundle_Rule_Engine__c>forNERule=[SELECT id, rule__c, Rule_Seq__c, pump__c, product__r.name, Bundle_Sequence__c, JDE_Component__c, Logic__c, Component_Type__c, Logic_Releationship__c, Is_Conditional_List__c, Is_Blank__c FROM Product_Bundle_Rule_Engine__c WHERE (Logic__c='if' OR Logic__c = 'And') AND Bundle_Sequence__c =: bunsequencetoLimit AND pump__c=:Pumpname AND Logic_Releationship__c ='NE' AND JDE_Component__c !=: comboName ORDER BY JDE_Component__c];
        if(forNERule!= null){
            for(Product_Bundle_Rule_Engine__c NEinRUleEngine : forNERule){
                onlyRule.add(NEinRUleEngine.rule__c);
                
            }
        }
        system.debug('all rule number for in thenlogic ...'+onlyRule);
        // onlyRule.clear();
        // onlyRule.add(69);
        
        system.debug('all rule number for in thenlogic ...'+onlyRule);
        system.debug('lenght of all rule number for in thenlogic ...'+onlyRule.size());
        
        list<thenWraper> wholeThen = new list <thenWraper>();
        list <Default_products__c> fromDefault = [SELECT id,Product_name__c, name, Bundle_Sequence__c, JDE_component__c, Component_Type__c FROM Default_products__c 
                                                  WHERE name =: pumpName ORDER BY JDE_component__c];
        list<Rule_Picklist__c> secondForRule = [SELECT id, name, rule__c, Rule_Seq__c, Pump_Bundle__c ,product__r.name, Bundle_Sequence__c, component__c, Component_Type__c
                                                from rule_picklist__c WHERE Pump_Bundle__c=:Pumpname AND rule__c IN: onlyRule ORDER BY Rule_Seq__c];
        
        list<Product_Bundle_Rule_Engine__c > thenList=[SELECT id, name,rule__c, Rule_Seq__c, pump__c, product__r.name, Product_Bundle__c, Bundle_Sequence__c, JDE_Component__c, Logic__c, Component_Type__c, 
                                                       Is_Conditional_List__c, Is_Blank__c, Logic_Releationship__c FROM Product_Bundle_Rule_Engine__c
                                                       WHERE rule__c IN: onlyRule AND pump__c=: Pumpname ORDER BY Rule_Seq__c];
        System.debug('thenList  --->'+thenList);
        System.debug('thenList size --->'+thenList.size());
        system.debug('secondForRule-->'+secondForRule);
        system.debug('secondForRule size-->'+secondForRule.size());
        map<string, string> defaultMap = new map<string, string>();
        map<string, string> NeMap = new map<string, string>();
        Map<String,Default_products__c> fDMap = new Map<String,Default_products__c>();     
        System.debug('fromDefault Size --->'+fromDefault.Size());
                                 
        for(Default_products__c dMap : fromDefault){
            String defaultMapKey = dMap.JDE_component__c+'-'+dMap.Bundle_Sequence__c;
            defaultMap.put(defaultMapKey, dMap.Product_name__c);
            fDMap.put(defaultMapKey,dMap);
        }
        System.debug('fDMap Size --->'+fDMap.Size());

        
        map<string, decimal> secondForRuleMap = new map<string, decimal>();
        for(Rule_Picklist__c sMap : secondForRule){
            String secondForRuleMapKey = sMap.component__c +'-'+ sMap.rule__c;
            secondForRuleMap.put(secondForRuleMapKey, sMap.rule__c);
            
            // system.debug('Bundle sequence in Map Loop ---> '+sMap.Bundle_Sequence__c);
            
        }
        String StringsecondForRuleMap = JSON.serialize(secondForRuleMap);
        system.debug('secondForRuleMap String i ---> '+StringsecondForRuleMap);
        // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>.
        system.debug('onlyRule--->'+ onlyRule);
        String fDMapKey ='';
        for( decimal ruleInLoop : onlyRule){
            system.debug('rule number in loop....'+ruleInLoop);
            
            map<string, decimal> mapToCheck = new map<string, decimal>();
            
            for(Product_Bundle_Rule_Engine__c ThenL : thenList){
                if(ThenL.rule__c == ruleInLoop){
                    
                    //system.debug('thenL...'+ThenL);
                    system.debug('thenL...'+ThenL.rule__c);
                    // system.debug('ThenL.Logic...'+ThenL.Logic__c);
                    
                    if((ThenL.Logic__c=='If')||(ThenL.Logic__c=='And')||(ThenL.logic__c=='NE')){
                        system.debug('ThenL.Logic__c== ...'+ThenL.Logic__c);
                        //system.debug('ruleInLoop...'+ruleInLoop);
                        
                        if((ThenL.Is_Conditional_List__c == false)&&(ThenL.Logic_Releationship__c == 'EQ')&&((ThenL.JDE_Component__c != null)||(ThenL.Is_Blank__c == true))){
                            
                            // system.debug('ThenL.Bundle_Sequence__c--->'+ThenL.Bundle_Sequence__c);
                            mapToCheck.put(ThenL.JDE_Component__c, ThenL.Bundle_Sequence__c);
                            system.debug('map to check. in list is false and relation is EQ ...'+mapToCheck);
                        }
                        
                        if((ThenL.Is_Conditional_List__c == false)&&(ThenL.Logic_Releationship__c == 'NE')){
                            System.debug('inside NE');
                            if (ThenL.JDE_Component__c == '*BLANK') {
                                if (bsCode.containsKey(ThenL.Bundle_Sequence__c)) {
                                    fDMapKey = bsCode.get(ThenL.Bundle_Sequence__c)+'-'+ThenL.Bundle_Sequence__c;
                                    System.debug('fDMapKey--->'+fDMapKey);
                                    System.debug('fDMap Contains--->'+fDMap.containsKey(fDMapKey));
                                    if(fDMap.containsKey(fDMapKey)) {
                                        System.debug('inside FDMAP');
                                        Default_products__c FD = fDMap.get(fDMapKey);
                                        System.debug('FD---> '+FD);
                                        if((FD.JDE_component__c != null)&&((FD.JDE_component__c != ThenL.JDE_Component__c)||(ThenL.Is_Blank__c == true))&&(FD.Bundle_Sequence__c == ThenL.Bundle_Sequence__c)&&(BScode.containsKey(FD.Bundle_Sequence__c))){
                                            
                                            string value = BScode.get(FD.Bundle_Sequence__c);
                                            if(value == FD.JDE_component__c){
                                                mapToCheck.put(FD.JDE_component__c, FD.Bundle_Sequence__c);
                                                System.debug('mapToCheck inside NE ---> '+mapToCheck);
                                            }
                                            // system.debug('map to check if condition list is false and relation is NE...'+mapToCheck);
                                        }
                                    } 
                                }
                               
                            }
                                                     
                        }
                        
                        if((ThenL.Is_Conditional_List__c == true)&&(ThenL.Logic_Releationship__c == 'EQ') ){
                            
                            for(Rule_Picklist__c SR : secondForRule){
                                if((SR.component__c != null)&&(SR.rule__c == ThenL.rule__c)&&(SR.Bundle_Sequence__c == ThenL.Bundle_Sequence__c)&&(BScode.containsKey(SR.Bundle_Sequence__c))){
                                    
                                    string value = BScode.get(SR.Bundle_Sequence__c)+'-'+ruleInLoop;
                                    
                                    System.debug('value....'+ value);
                                    //System.debug('SR.component__c....'+ SR.component__c);
                                    System.debug('secondForRuleMap.key present....'+ secondForRuleMap.containsKey(value));
                                    System.debug('secondForRuleMap.get(value)....'+ secondForRuleMap.get(value));
                                    if((secondForRuleMap.containsKey(value))&&(secondForRuleMap.get(value) == ruleInLoop)){
                                        system.debug('secondForRuleMap.containsKey(value)...'+secondForRuleMap.containsKey(value));
                                        List<String> ValueCheckList = value.split('-');
                                        String ValueCheck = ValueCheckList[1];
                                        if(ValueCheckList[0] == SR.component__c){
                                            System.debug('In if cond....');
                                            mapToCheck.put(SR.component__c, SR.Bundle_Sequence__c);
                                        }
                                        // else if(!secondForRuleMap.containsKey(value)){
                                        // System.debug('In else if cond....');
                                        // mapToCheck.put('noCode', 0);
                                        // }
                                    }
                                    else{
                                        System.debug('In else cond....');
                                        mapToCheck.put('noCode', 0);
                                    }
                                    
                                    system.debug('map to check if condition list is ture and relation is EQ...'+mapToCheck);
                                }
                            }
                        }
                        
                        if((ThenL.Is_Conditional_List__c == true)&&(ThenL.Logic_Releationship__c == 'NE')){
                            System.debug('Comes in Cond True And NE ---> ');
                            for(Rule_Picklist__c SR : secondForRule){
                                if((SR.component__c != null)&&(SR.rule__c == ThenL.rule__c)&&(SR.Bundle_Sequence__c == ThenL.Bundle_Sequence__c)){
                                    fDMapKey = ThenL.JDE_Component__c+'-'+ThenL.Bundle_Sequence__c;
                                    System.debug('fDMapKey --- > '+fDMapKey);
                                    if (fDMap.containsKey(fDMapKey)) {
                                        Default_products__c FD = fDMap.get(fDMapKey);
                                        System.debug('FD ---> '+FD);
                                        System.debug('SR ---> '+SR);
                                        System.debug('Bs Code Present ---> '+BScode.containsKey(FD.Bundle_Sequence__c));
                                        if((FD.JDE_component__c != null)&&(FD.JDE_component__c != SR.component__c)&&(FD.Bundle_Sequence__c == SR.Bundle_Sequence__c)&&(BScode.containsKey(FD.Bundle_Sequence__c))){
                                            
                                            string value = BScode.get(FD.Bundle_Sequence__c);
                                            system.debug('value in conditional list true and relation is NE...'+ value);
                                            System.debug('FD.JDE_component__c ---> '+FD.JDE_component__c);
                                            // if()
                                            if(value == FD.JDE_component__c){
                                                system.debug('FD.JDE_component__c in if, conditional list true and relation is NE...'+ FD.JDE_component__c);
                                                mapToCheck.put(FD.JDE_component__c, FD.Bundle_Sequence__c);
                                                //NeMap.put(FD.JDE_component__c,ThenL.Logic_Releationship__c);
                                            } 
                                            String newComp =  BScode.get(ThenL.Bundle_Sequence__c) ;
                                            system.debug('newComp in NE in conditional list true and relation is NE...'+ newComp);
                                            System.debug('Sr Component ---> '+SR.component__c);
                                            if ( (SR.rule__c == ThenL.rule__c) && (SR.Bundle_Sequence__c == ThenL.Bundle_Sequence__c) && (BScode.containsKey(ThenL.Bundle_Sequence__c)) && (newComp == SR.component__c)) {
                                               System.debug('Ne Matched');
                                                NeMap.put(SR.component__c,ThenL.Logic_Releationship__c);

                                            }
                                            // else{
                                            //     system.debug('FD.JDE_component__c in else,  conditional list true and relation is NE...'+ FD.JDE_component__c);
                                            //     mapToCheck.put('noCode', 0);
                                            // }
                                        }
                                        //  else{
                                        //         mapToCheck.put('noCode', 0);
                                        //     }
                                    }
                                        
                                    
                                    system.debug('map to check if condition list is true and relation is NE...'+mapToCheck);
                                }
                            }
                        }
                        
                    }
                    
                    Boolean allElementsPresent = true;
                    system.debug('mapToCheck--->'+mapToCheck);
                    system.debug('BScode--->'+BScode);
                    system.debug('allElementsPresent '+ allElementsPresent);
                    if (!mapToCheck.isEmpty()){
                        for (String key : mapToCheck.keySet()) {
                            decimal value = mapToCheck.get(key);
                            system.debug('value---> '+ value);
                            if (!BScode.containsKey(value) || !BScode.get(value).equals(key)) {
                                allElementsPresent = false;
                                system.debug('allElementsPresent '+ allElementsPresent);
                                // break;
                            } 
                            String NeStrng = NeMap.get(key);
                            system.debug('allElementsPresent '+ allElementsPresent);
                            System.debug('NeStrng --->'+NeStrng);
                            if (NeStrng == 'NE'  ) {
                                allElementsPresent = false;
                                system.debug('allElementsPresent '+ allElementsPresent);
                            }
                        }
                        system.debug('mapToCheck is not null...');
                        system.debug('allElementsPresent '+ allElementsPresent);
                    }
                    else{
                        system.debug('mapToCheck is NULL...');
                        allElementsPresent = false;
                    }
                    system.debug('allElementsPresent '+ allElementsPresent);
                    if (allElementsPresent == true) {
                        system.debug('hey ! All elements of mapToCheck are present in BScode');
                        System.debug('ThenL --->'+ThenL);
                        System.debug('thenList  --->'+thenList);
                        System.debug('thenList size --->'+thenList.size());
                        System.debug('ThenL.Logic__c --->'+ThenL.Logic__c);
                        System.debug('ThenL.rule__c --->'+ThenL.rule__c);
                        System.debug('ruleInLoop--->'+ruleInLoop);
                        if((ThenL.Logic__c=='Then')&&(ThenL.rule__c == ruleInLoop)){
                            system.debug('then bundle seq '+ ThenL.rule__c);
                            if((ThenL.Is_Conditional_List__c == false)&&(ThenL.JDE_Component__c != null)){
                                system.debug('ThenL.rule__c '+ ThenL.rule__c);
                                if(ThenL.product__r.name != null){
                                    system.debug('then bundle seq in (((ThenL.Is_Conditional_List__c == false)&&(ThenL.JDE_Component__c != null)))..... '+ ThenL.Bundle_Sequence__c);
                                    system.debug('ThenL.JDE_Component__c--->'+ThenL.JDE_Component__c);
                                    wholeThen.add(new thenWraper(ThenL.id, ThenL.name, ThenL.Bundle_Sequence__c, ThenL.JDE_Component__c, ThenL.Product__c, ThenL.product__r.name, ThenL.pump__c, ThenL.rule__c, ThenL.Component_Type__c));
                                    system.debug('wholeThen add--->'+wholeThen);
                                }
                                
                                if(ThenL.product__r.name == null){
                                    String defaultMapKeyChecker = ThenL.JDE_Component__c+'-'+ThenL.Bundle_Sequence__c;
                                    System.debug('defaultMapKeyChecker--->'+defaultMapKeyChecker);
                                    if(defaultMap.containsKey(defaultMapKeyChecker)){
                                        
                                        string productName = defaultMap.get(defaultMapKeyChecker);
                                        system.debug('then bundle seq in ThenL.product__r.name...... '+productName);
                                        system.debug('JDE_Component__c...'+ThenL.JDE_Component__c);
                                        wholeThen.add(new thenWraper(ThenL.id, ThenL.name, ThenL.Bundle_Sequence__c, ThenL.JDE_Component__c, ThenL.Product__c, productName, ThenL.pump__c, ThenL.rule__c, ThenL.Component_Type__c));
                                        system.debug('wholeThen add--->'+wholeThen);
                                    }
                                    
                                }
                            }
                            System.debug('ThenL --->'+ThenL);
                            if((ThenL.Is_Conditional_List__c == true)&&(ThenL.JDE_Component__c == null)){
                                for(Rule_Picklist__c SR2 : secondForRule){
                                    if((SR2.product__r.name != null)&&(SR2.rule__c == ThenL.rule__c)&&(SR2.Bundle_Sequence__c == ThenL.Bundle_Sequence__c)){
                                        system.debug('then bundle seq in ((ThenL.Is_Conditional_List__c == true)&&(ThenL.JDE_Component__c == null))..... '+ SR2.Bundle_Sequence__c);
                                        wholeThen.add(new thenWraper(SR2.id, SR2.name, SR2.Bundle_Sequence__c, SR2.component__c, SR2.Product__c, SR2.product__r.name, SR2.Pump_Bundle__c, SR2.rule__c, SR2.Component_Type__c));   
                                    }
                                    String defaultMapKeyChecker1 = SR2.component__c+'-'+sr2.Bundle_Sequence__c;
                                    if((SR2.product__r.name == null)&&(SR2.component__c != null)&&(SR2.Bundle_Sequence__c == ThenL.Bundle_Sequence__c) && (SR2.rule__c == ThenL.rule__c) &&((defaultMap.containsKey(defaultMapKeyChecker1)))){
                                        
                                        string productName = defaultMap.get(defaultMapKeyChecker1);
                                        System.debug('productName---->'+productName);
                                        wholeThen.add(new thenWraper(SR2.id, SR2.name, SR2.Bundle_Sequence__c, SR2.component__c, SR2.Product__c, productName, SR2.Pump_Bundle__c, SR2.rule__c, SR2.Component_Type__c));   
                                        system.debug('wholeThen add--->'+wholeThen);
                                        
                                    }
                                }
                            }
                        }
                    } 
                    else {
                        system.debug('Not all elements of mapToCheck are present in BScode.');
                    }
                }
            }
            system.debug('final map to check...'+mapToCheck);
        }
        
        
        // ............................................................................................................................................................................................................................................................................................
        system.debug('whole then data...>'+ wholeThen);
        set<decimal> bundleSequenceSet = new set<decimal>();
        set<decimal> ruleTestSet = new set<decimal>();
        for(thenWraper forBS : wholeThen){
            // system.debug('forBS.....'+forBS);
            bundleSequenceSet.add(forBS.BSeq);
            ruleTestSet.add(forBS.rule);
        }
        system.debug('bundleSequenceSet.....'+bundleSequenceSet);
        system.debug('ruleTestSet.....'+ruleTestSet);
        system.debug('getProductBundleID.....'+getProductBundleID);
        
        list<Bundle_Attributes__c>ProductBundleName = [SELECT id, name, Bundle_Sequence__c, Product_Bundle__c 
                                                       from Bundle_Attributes__c 
                                                       where Product_Bundle__c =: getProductBundleID And
                                                       Bundle_Sequence__c IN:bundleSequenceSet ORDER BY Bundle_Sequence__c];
        system.debug('Product bundle-->>>> '+ ProductBundleName);
        for(Bundle_Attributes__c PBName : ProductBundleName){
            //system.debug('Product bundle-  product bundle name id ....->>>> '+ PBName.Product_Bundle__c); 
        }
        // and Bundle_Sequence__c IN:bundleSequenceSet
        system.debug('wholeThen.....'+wholeThen);
        system.debug('wholeThen size.....'+wholeThen.size());
        
        
        for(Bundle_Attributes__c PN :ProductBundleName ){
            list<innerWrapperBSThen> productOfAnd = new list<innerWrapperBSThen>();
            list<innerThenOptions> optionOfAnd = new list<innerThenOptions>();
            set<string> andJDEname  = new set<string>();
            
            for(thenWraper AL : wholeThen){
                if(AL.BSeq == PN.Bundle_Sequence__c){
                    
                    if (!andJDEname.contains(AL.componentCode)) {
                        
                        andJDEname.add(AL.componentCode);
                        
                        productOfAnd.add(new innerWrapperBSThen(AL.productname, AL.componentCode));
                        optionOfAnd.add(new innerThenOptions('('+AL.componentCode+') '+AL.productname, AL.componentCode));
                        
                    }
                }
            }
            
            if(productOfAnd.size()<1){
                productOfAnd.add(new innerWrapperBSThen('NO selection','*BLANK'));
                optionOfAnd.add(new innerThenOptions('NO selection','*BLANK'));
            }
            
            string Name = PN.Bundle_Sequence__c+'  '+PN.name;
            if(productOfAnd.size()==1){
                for(innerWrapperBSThen onlyOne : productOfAnd){
                    
                    outerThenWrapper.add(new outerWrapperBSThen(Name,PN.id, PN.Bundle_Sequence__c, onlyOne.Productcode, productOfAnd, optionOfAnd));
                }
            }
            else{
                outerThenWrapper.add(new outerWrapperBSThen(Name,PN.id, PN.Bundle_Sequence__c, Null,productOfAnd, optionOfAnd));
            } 
            
        }
        
        
        system.debug('outerThenWrapper.....'+outerThenWrapper);
        return outerThenWrapper;
    }
    
    public class outerWrapperBSThen{
        @AuraEnabled 
        public String name{get;set;}
        @AuraEnabled 
        public string id {get;set;}
        @AuraEnabled
        public Decimal BS {get;set;}
        @AuraEnabled 
        public String value{get;set;}
        @AuraEnabled
        public list<innerWrapperBSThen> thenProductName {get;set;}
        @AuraEnabled 
        public list<innerThenOptions> innerLabelOptions {get;set;}
        
        public outerWrapperBSThen(String name,string id,Decimal BS , String value,list<innerWrapperBSThen> thenProductName ,list<innerThenOptions> innerLabelOptions  ){
            this.name= name;
            this.id = id;
            this.BS = BS;
            this.value = value;
            this.thenProductName = thenProductName;
            this.innerLabelOptions = innerLabelOptions;
        }
    }
    
    
    public class innerWrapperBSThen{
        @AuraEnabled 
        public String Productname{get;set;}
        @AuraEnabled 
        public string Productcode {get;set;}
        
        
        public innerWrapperBSThen(String Productname,string Productcode ){
            this.Productname= Productname;
            this.Productcode = Productcode;
            
        }
    }
    
    public class innerThenOptions{
        @AuraEnabled 
        public String label{get;set;}
        @AuraEnabled 
        public string value {get;set;}
        
        public innerThenOptions(String label,string value ){
            this.label= label;
            this.value = value;
            
        }
    }
    
    public class thenWraper{
        @AuraEnabled 
        public String id{get;set;}
        @AuraEnabled 
        public string name {get;set;}
        @AuraEnabled
        public decimal BSeq {get;set;}
        @AuraEnabled
        public string componentCode {get;set;}
        @AuraEnabled 
        public string productID {get;set;}
        @AuraEnabled 
        public string productname {get;set;}
        @AuraEnabled 
        public string bundleName {get;set;}
        @AuraEnabled 
        public decimal rule {get;set;}
        @AuraEnabled 
        public string componentType {get;set;}
        
        public thenWraper(String id,string name, decimal BSeq, string componentCode, string productID, string productname, string bundleName, decimal rule, string componentType) {
            this.id = id;
            this.name = name;
            this.BSeq = BSeq;
            this.componentCode = componentCode;
            this.productID = productID;
            this.productname = productname;
            this.bundleName = bundleName;
            this.rule = rule;
            this.componentType = componentType;
        }
    }

    // ................................................................................
        //////////////////////////******************************************** PSP 2024 Rule 35 Bug Fix /////////////////////////********************************************/
        @AuraEnabled
        public Static list<outerWrapperBSThen> ThenValidate (string comboNames, string Pumpname, string productBundleNameString, string stringBundlecode) {
            
            String[] bundleParts = productBundleNameString.split(' ');
            System.debug('bundleParts ---> '+bundleParts);
            String firstNumber = bundleParts[0];
            System.debug('firstNumber---> '+firstNumber);
            decimal bunsequencetoLimit = decimal.valueOf(firstNumber);

            system.debug('stringBundlecode in ThenValidate...>'+stringBundlecode);
            List<Object> listPriceproduct = (List<Object>) JSON.deserializeUntyped(stringBundlecode);
            system.debug('listPriceproduct in forThenLogic...>'+listPriceproduct);
            Map<String, string> mapBundleCode = new map<string, string>();
            for (Object obj : listPriceproduct) {
                Map<String, Object> jsonObj = (Map<String, Object>) obj;
                String key = (String) jsonObj.get('key');
                String value = (String) jsonObj.get('value');
                mapBundleCode.put(key, value);
            }
           
            system.debug('mapBundleCode in forThenLogic...>'+mapBundleCode);
            list<Product_Bundle__c>togetpumpID = [SELECT id, name from Product_Bundle__c where name =:Pumpname];
            string getProductBundleID = togetpumpID[0].id;
            
            Map<decimal, String> BScode = new Map<decimal, String>();
            for (String key : mapBundleCode.keySet()) {
                String[] parts = key.split(' ');
                String newKey = parts[0].replaceAll('[^0-9.]', '');
                decimal deciKey = decimal.valueOf(newKey);
                String newValue = mapBundleCode.get(key);
                BScode.put(deciKey, newValue);
            }
            BScode.put(bunsequencetoLimit, comboNames);
            system.debug('BS code map....'+BScode);
            list<outerWrapperBSThen> outerThenWrapper = new list<outerWrapperBSThen>();

            list<Product_Bundle_Rule_Engine__c>forandRule=[SELECT id, rule__c, Rule_Seq__c, pump__c, product__r.name, Bundle_Sequence__c, JDE_Component__c, Logic__c, Component_Type__c, Logic_Releationship__c, Is_Conditional_List__c, Is_Blank__c FROM Product_Bundle_Rule_Engine__c WHERE (Logic__c='if' OR Logic__c = 'And') AND Bundle_Sequence__c In:BsCode.keyset() AND pump__c=:Pumpname AND Logic_Releationship__c ='EQ' ORDER BY JDE_Component__c];
            set<decimal> whenConditionalListTRUE = new set<decimal>();
            list<Rule_Picklist__c> secondForRule0 = [SELECT id,rule__c, Rule_Seq__c, Pump_Bundle__c ,product__r.name, Bundle_Sequence__c, component__c, Component_Type__c
                                                     from rule_picklist__c WHERE component__c In:BsCode.values()  AND Pump_Bundle__c=:Pumpname AND Bundle_Sequence__c In: BsCode.keyset() ORDER BY component__c];
            System.debug('forandRule size---> ' +forandRule.size());
            System.debug('secondForRule0 size---> ' +secondForRule0.size());
            Set<Decimal> onlyRule = new Set<Decimal>();
            if(!forandRule.isEmpty()){
                for(Product_Bundle_Rule_Engine__c forruleNumber :forandRule){
                    String comboName = bsCode.get(forruleNumber.Bundle_Sequence__c);
                    if((bsCode.containsKey(forruleNumber.Bundle_Sequence__c) && bsCode.get(forruleNumber.Bundle_Sequence__c) == comboName && forruleNumber.JDE_Component__c == comboName)&&(forruleNumber.Is_Conditional_List__c == false)){
                        System.debug('forruleNumber.rule__c---> '+forruleNumber.rule__c);
                        onlyRule.add(forruleNumber.rule__c);
                    }
                    
                    if(forruleNumber.Is_Conditional_List__c == true){
                        for(Rule_Picklist__c sr : secondForRule0){
                            System.debug('sr.rule__c---> '+sr.rule__c +' AND ' +' forruleNumber.rule__c-->>'+ forruleNumber.rule__c);
                            if(sr.rule__c == forruleNumber.rule__c){
                                System.debug('sr.rule__c---> '+sr.rule__c);
                                onlyRule.add(sr.rule__c);
                            }
                            
                        }
                        
                        // if(secondForRule0.isEmpty()){
                        //     System.debug('break---> ');
                        //     break;
                        
                        // }
                        
                    }
                }
            }
            System.debug('onlyRule---> '+onlyRule+'\n'+'onlyRule Size()--->'+onlyRule.size());
              
            list<thenWraper> wholeThen = new list <thenWraper>();
            list <Default_products__c> fromDefault = [SELECT id,Product_name__c, name, Bundle_Sequence__c, JDE_component__c, Component_Type__c FROM Default_products__c 
                                                      WHERE name =: pumpName ORDER BY JDE_component__c];
            list<Rule_Picklist__c> secondForRule = [SELECT id, name, rule__c, Rule_Seq__c, Pump_Bundle__c ,product__r.name, Bundle_Sequence__c, component__c, Component_Type__c
                                                    from rule_picklist__c WHERE Pump_Bundle__c=:Pumpname AND rule__c IN: onlyRule ORDER BY Rule_Seq__c];
            
            list<Product_Bundle_Rule_Engine__c > thenList=[SELECT id, name,rule__c, Rule_Seq__c, pump__c, product__r.name, Product_Bundle__c, Bundle_Sequence__c, JDE_Component__c, Logic__c, Component_Type__c, 
                                                           Is_Conditional_List__c, Is_Blank__c, Logic_Releationship__c FROM Product_Bundle_Rule_Engine__c
                                                           WHERE rule__c IN: onlyRule AND pump__c=: Pumpname ORDER BY Rule_Seq__c];
            
            System.debug('thenList  --->'+thenList);
            System.debug('thenList size --->'+thenList.size());
            system.debug('secondForRule-->'+secondForRule);
            system.debug('secondForRule size-->'+secondForRule.size());
            map<string, string> defaultMap = new map<string, string>();
            map<string, string> NeMap = new map<string, string>();
            Map<String,Default_products__c> fDMap = new Map<String,Default_products__c>();     
        System.debug('fromDefault Size --->'+fromDefault.Size());
                                 
        for(Default_products__c dMap : fromDefault){
            String defaultMapKey = dMap.JDE_component__c+'-'+dMap.Bundle_Sequence__c;
            defaultMap.put(defaultMapKey, dMap.Product_name__c);
            fDMap.put(defaultMapKey,dMap);
        }
        System.debug('fDMap Size --->'+fDMap.Size());
            
            map<string, decimal> secondForRuleMap = new map<string, decimal>();
            for(Rule_Picklist__c sMap : secondForRule){
                String secondForRuleMapKey = sMap.component__c +'-'+ sMap.rule__c;
                secondForRuleMap.put(secondForRuleMapKey, sMap.rule__c);
                
                // system.debug('Bundle sequence in Map Loop ---> '+sMap.Bundle_Sequence__c);
                // String StringsecondForRuleMap = JSON.serialize(secondForRuleMap);
                // system.debug('secondForRuleMap String i ---> '+StringsecondForRuleMap);
            }
            
            // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>.
            system.debug('onlyRule--->'+ onlyRule);
            String fDMapKey ='';
            for( decimal ruleInLoop : onlyRule){
                system.debug('rule number in loop....'+ruleInLoop);
                
                map<string, decimal> mapToCheck = new map<string, decimal>();
                
                for(Product_Bundle_Rule_Engine__c ThenL : thenList){
                    if(ThenL.rule__c == ruleInLoop){
                        
                        //system.debug('thenL...'+ThenL);
                        system.debug('thenL...'+ThenL.rule__c);
                        // system.debug('ThenL.Logic...'+ThenL.Logic__c);
                        
                        if((ThenL.Logic__c=='If')||(ThenL.Logic__c=='And')){
                            system.debug('ThenL.Logic__c== ...'+ThenL.Logic__c);
                            //system.debug('ruleInLoop...'+ruleInLoop);
                            
                            if((ThenL.Is_Conditional_List__c == false)&&(ThenL.Logic_Releationship__c == 'EQ')&&((ThenL.JDE_Component__c != null)||(ThenL.Is_Blank__c == true))){
                                
                                // system.debug('ThenL.Bundle_Sequence__c--->'+ThenL.Bundle_Sequence__c);
                                mapToCheck.put(ThenL.JDE_Component__c, ThenL.Bundle_Sequence__c);
                                system.debug('map to check. in list is false and relation is EQ ...'+mapToCheck);
                            }
                            
                            if((ThenL.Is_Conditional_List__c == false)&&(ThenL.Logic_Releationship__c == 'NE')){
                                fDMapKey = ThenL.JDE_Component__c+'-'+ThenL.Bundle_Sequence__c;
                                if (fDMap.containsKey(fDMapKey)) {
                                    Default_products__c FD = fDMap.get(fDMapKey);
                                    if((FD.JDE_component__c != null)&&((FD.JDE_component__c != ThenL.JDE_Component__c)||(ThenL.Is_Blank__c == true))&&(FD.Bundle_Sequence__c == ThenL.Bundle_Sequence__c)&&(BScode.containsKey(FD.Bundle_Sequence__c))){
                                        
                                        string value = BScode.get(FD.Bundle_Sequence__c);
                                        if(value == FD.JDE_component__c){
                                            mapToCheck.put(FD.JDE_component__c, FD.Bundle_Sequence__c);
                                        }
                                        // system.debug('map to check if condition list is false and relation is NE...'+mapToCheck);
                                    }
                                
                                }

                            }
                            
                            if((ThenL.Is_Conditional_List__c == true)&&(ThenL.Logic_Releationship__c == 'EQ') ){
                                
                                for(Rule_Picklist__c SR : secondForRule){
                                    if((SR.component__c != null)&&(SR.rule__c == ThenL.rule__c)&&(SR.Bundle_Sequence__c == ThenL.Bundle_Sequence__c)&&(BScode.containsKey(SR.Bundle_Sequence__c))){
                                        
                                        string value = BScode.get(SR.Bundle_Sequence__c)+'-'+ruleInLoop;
                                        
                                        //System.debug('value....'+ value);
                                        //System.debug('SR.component__c....'+ SR.component__c);
                                        //System.debug('secondForRuleMap.key present....'+ secondForRuleMap.containsKey(value));
                                        System.debug('secondForRuleMap.get(value)....'+ secondForRuleMap.get(value));
                                        if((secondForRuleMap.containsKey(value))&&(secondForRuleMap.get(value) == ruleInLoop)){
                                            system.debug('secondForRuleMap.containsKey(value)...'+secondForRuleMap.containsKey(value));
                                            List<String> ValueCheckList = value.split('-');
                                            String ValueCheck = ValueCheckList[1];
                                            if(ValueCheckList[0] == SR.component__c){
                                                System.debug('In if cond....');
                                                mapToCheck.put(SR.component__c, SR.Bundle_Sequence__c);
                                            }
                                            // else if(!secondForRuleMap.containsKey(value)){
                                            // System.debug('In else if cond....');
                                            // mapToCheck.put('noCode', 0);
                                            // }
                                        }
                                        else{
                                            System.debug('In else cond....');
                                            mapToCheck.put('noCode', 0);
                                        }
                                        
                                        system.debug('map to check if condition list is ture and relation is EQ...'+mapToCheck);
                                    }
                                }
                            }
                            
                            if((ThenL.Is_Conditional_List__c == true)&&(ThenL.Logic_Releationship__c == 'NE')){
                                System.debug('Comes in Cond True And NE ---> ');
                                for(Rule_Picklist__c SR : secondForRule){
                                    if((SR.component__c != null)&&(SR.rule__c == ThenL.rule__c)&&(SR.Bundle_Sequence__c == ThenL.Bundle_Sequence__c)){
                                        fDMapKey = ThenL.JDE_Component__c+'-'+ThenL.Bundle_Sequence__c;
                                        if (fDMap.containsKey(fDMapKey)) {
                                            Default_products__c FD = fDMap.get(fDMapKey);
                                            if((FD.JDE_component__c != null)&&(FD.JDE_component__c != SR.component__c)&&(FD.Bundle_Sequence__c == SR.Bundle_Sequence__c)&&(BScode.containsKey(FD.Bundle_Sequence__c))){
                                                
                                                string value = BScode.get(FD.Bundle_Sequence__c);
                                                system.debug('value in conditional list true and relation is NE...'+ value);
                                                System.debug('FD.JDE_component__c ---> '+FD.JDE_component__c);
                                                // if()
                                                if(value == FD.JDE_component__c){
                                                    system.debug('FD.JDE_component__c in if, conditional list true and relation is NE...'+ FD.JDE_component__c);
                                                    mapToCheck.put(FD.JDE_component__c, FD.Bundle_Sequence__c);
                                                    //NeMap.put(FD.JDE_component__c,ThenL.Logic_Releationship__c);
                                                } 
                                                String newComp =  BScode.get(ThenL.Bundle_Sequence__c) ;
                                                system.debug('newComp in NE in conditional list true and relation is NE...'+ newComp);
                                                System.debug('Sr Component ---> '+SR.component__c);
                                                if ( (SR.rule__c == ThenL.rule__c) && (SR.Bundle_Sequence__c == ThenL.Bundle_Sequence__c) && (BScode.containsKey(ThenL.Bundle_Sequence__c)) && (newComp == SR.component__c)) {
                                                   System.debug('Ne Matched');
                                                    NeMap.put(SR.component__c,ThenL.Logic_Releationship__c);
    
                                                }
                                                // else{
                                                //     system.debug('FD.JDE_component__c in else,  conditional list true and relation is NE...'+ FD.JDE_component__c);
                                                //     mapToCheck.put('noCode', 0);
                                                // }
                                            }
                                            //  else{
                                            //         mapToCheck.put('noCode', 0);
                                            //     }
                                        
                                        system.debug('map to check if condition list is true and relation is NE...'+mapToCheck);
                                        }
                                            
                                    }
                                }
                            }
                            
                        }
                        
                        Boolean allElementsPresent = true;
                        system.debug('mapToCheck--->'+mapToCheck);
                        system.debug('BScode--->'+BScode);
                        system.debug('allElementsPresent '+ allElementsPresent);
                        if (!mapToCheck.isEmpty()){
                            for (String key : mapToCheck.keySet()) {
                                decimal value = mapToCheck.get(key);
                                system.debug('value---> '+ value);
                               
                                if (!BScode.containsKey(value) || !BScode.get(value).equals(key)) {
                                    allElementsPresent = false;
                                    system.debug('allElementsPresent '+ allElementsPresent);
                                    // break;
                                
                            }
                                String NeStrng = NeMap.get(key);
                                system.debug('allElementsPresent '+ allElementsPresent);
                                System.debug('NeStrng --->'+NeStrng);
                                if (NeStrng == 'NE'  ) {
                                    allElementsPresent = false;
                                    system.debug('allElementsPresent '+ allElementsPresent);
                                }
                            }
                            system.debug('mapToCheck is not null...');
                            system.debug('allElementsPresent '+ allElementsPresent);
                        } else { 
                            system.debug('mapToCheck is NULL...');
                            allElementsPresent = false;
                        }
                        system.debug('allElementsPresent '+ allElementsPresent);
                        if (allElementsPresent == true) {
                            system.debug('hey ! All elements of mapToCheck are present in BScode');
                            System.debug('ThenL --->'+ThenL);
                            System.debug('thenList  --->'+thenList);
                            System.debug('thenList size --->'+thenList.size());
                            System.debug('ThenL.Logic__c --->'+ThenL.Logic__c);
                            System.debug('ThenL.rule__c --->'+ThenL.rule__c);
                            System.debug('ruleInLoop--->'+ruleInLoop);
                            if((ThenL.Logic__c=='Then')&&(ThenL.rule__c == ruleInLoop) && (!bsCode.containsKey(ThenL.Bundle_Sequence__c))){
                                system.debug('then bundle seq '+ ThenL.rule__c);
                                if((ThenL.Is_Conditional_List__c == false)&&(ThenL.JDE_Component__c != null)){
                                    system.debug('ThenL.rule__c '+ ThenL.rule__c);
                                    if(ThenL.product__r.name != null){
                                        system.debug('then bundle seq in (((ThenL.Is_Conditional_List__c == false)&&(ThenL.JDE_Component__c != null)))..... '+ ThenL.Bundle_Sequence__c);
                                        system.debug('ThenL.JDE_Component__c--->'+ThenL.JDE_Component__c);
                                        wholeThen.add(new thenWraper(ThenL.id, ThenL.name, ThenL.Bundle_Sequence__c, ThenL.JDE_Component__c, ThenL.Product__c, ThenL.product__r.name, ThenL.pump__c, ThenL.rule__c, ThenL.Component_Type__c));
                                        system.debug('wholeThen add--->'+wholeThen);
                                    }
                                    if(ThenL.product__r.name == null){
                                        String defaultMapKeyChecker = ThenL.JDE_Component__c+'-'+ThenL.Bundle_Sequence__c;
                                        System.debug('defaultMapKeyChecker--->'+defaultMapKeyChecker);
                                        if(defaultMap.containsKey(defaultMapKeyChecker)){
                                            string productName = defaultMap.get(defaultMapKeyChecker);
                                            system.debug('then bundle seq in ThenL.product__r.name...... '+productName);
                                            system.debug('JDE_Component__c...'+ThenL.JDE_Component__c);
                                            wholeThen.add(new thenWraper(ThenL.id, ThenL.name, ThenL.Bundle_Sequence__c, ThenL.JDE_Component__c, ThenL.Product__c, productName, ThenL.pump__c, ThenL.rule__c, ThenL.Component_Type__c));
                                            system.debug('wholeThen add--->'+wholeThen);
                                        }
                                        
                                    }
                                }
                                
                                if((ThenL.Is_Conditional_List__c == true)&&(ThenL.JDE_Component__c == null)){
                                    for(Rule_Picklist__c SR2 : secondForRule){
                                        if((SR2.product__r.name != null)&&(SR2.rule__c == ThenL.rule__c)&&(SR2.Bundle_Sequence__c == ThenL.Bundle_Sequence__c)){
                                            system.debug('then bundle seq in ((ThenL.Is_Conditional_List__c == true)&&(ThenL.JDE_Component__c == null))..... '+ SR2.Bundle_Sequence__c);
                                            wholeThen.add(new thenWraper(SR2.id, SR2.name, SR2.Bundle_Sequence__c, SR2.component__c, SR2.Product__c, SR2.product__r.name, SR2.Pump_Bundle__c, SR2.rule__c, SR2.Component_Type__c));   
                                        }
                                        String defaultMapKeyChecker1 = SR2.component__c+'-'+sr2.Bundle_Sequence__c;
                                        if((SR2.product__r.name == null)&&(SR2.component__c != null)&&(SR2.Bundle_Sequence__c == ThenL.Bundle_Sequence__c) && (SR2.rule__c == ThenL.rule__c) &&((defaultMap.containsKey(defaultMapKeyChecker1)))){
                                            string productName = defaultMap.get(defaultMapKeyChecker1);
                                            System.debug('productName---->'+productName);
                                            wholeThen.add(new thenWraper(SR2.id, SR2.name, SR2.Bundle_Sequence__c, SR2.component__c, SR2.Product__c, productName, SR2.Pump_Bundle__c, SR2.rule__c, SR2.Component_Type__c));   
                                            system.debug('wholeThen add--->'+wholeThen);
                                        }
                                    }
                                }
                            }
                        } 
                        else {
                            system.debug('Not all elements of mapToCheck are present in BScode.');
                        }
                    }
                }
                system.debug('final map to check...'+mapToCheck);
            }
            system.debug('whole then data...>'+ wholeThen);
    
            set<decimal> bundleSequenceSet = new set<decimal>();
            set<decimal> ruleTestSet = new set<decimal>();
            for(thenWraper forBS : wholeThen){
                // system.debug('forBS.....'+forBS);
                bundleSequenceSet.add(forBS.BSeq);
                ruleTestSet.add(forBS.rule);
            }
            system.debug('bundleSequenceSet.....'+bundleSequenceSet);
        system.debug('ruleTestSet.....'+ruleTestSet);
        system.debug('getProductBundleID.....'+getProductBundleID);
        
        list<Bundle_Attributes__c>ProductBundleName = [SELECT id, name, Bundle_Sequence__c, Product_Bundle__c 
                                                       from Bundle_Attributes__c 
                                                       where Product_Bundle__c =: getProductBundleID And
                                                       Bundle_Sequence__c IN:bundleSequenceSet ORDER BY Bundle_Sequence__c];
        system.debug('Product bundle-->>>> '+ ProductBundleName);
        for(Bundle_Attributes__c PBName : ProductBundleName){
            //system.debug('Product bundle-  product bundle name id ....->>>> '+ PBName.Product_Bundle__c); 
        }
        // and Bundle_Sequence__c IN:bundleSequenceSet
        system.debug('wholeThen.....'+wholeThen);
        system.debug('wholeThen size.....'+wholeThen.size());
        for(Bundle_Attributes__c PN :ProductBundleName ){
            list<innerWrapperBSThen> productOfAnd = new list<innerWrapperBSThen>();
            list<innerThenOptions> optionOfAnd = new list<innerThenOptions>();
            set<string> andJDEname  = new set<string>();
            
            for(thenWraper AL : wholeThen){
                if(AL.BSeq == PN.Bundle_Sequence__c){
                    
                    if (!andJDEname.contains(AL.componentCode)) {
                        
                        andJDEname.add(AL.componentCode);
                        
                        productOfAnd.add(new innerWrapperBSThen(AL.productname, AL.componentCode));
                        optionOfAnd.add(new innerThenOptions('('+AL.componentCode+') '+AL.productname, AL.componentCode));
                        
                    }
                }
            }
            
            if(productOfAnd.size()<1){
                productOfAnd.add(new innerWrapperBSThen('NO selection','*BLANK'));
                optionOfAnd.add(new innerThenOptions('NO selection','*BLANK'));
            }
            
            string Name = PN.Bundle_Sequence__c+'  '+PN.name;
            if(productOfAnd.size()==1){
                for(innerWrapperBSThen onlyOne : productOfAnd){
                    
                    outerThenWrapper.add(new outerWrapperBSThen(Name,PN.id, PN.Bundle_Sequence__c, onlyOne.Productcode, productOfAnd, optionOfAnd));
                  
                }
            }
            else{
                outerThenWrapper.add(new outerWrapperBSThen(Name,PN.id, PN.Bundle_Sequence__c, Null,productOfAnd, optionOfAnd));
            } 
            
        }
        
        system.debug('stringBundlecode in ThenValidate...>'+stringBundlecode);
        system.debug('outerThenWrapper.....'+outerThenWrapper);

        return outerThenWrapper;
            
            
    
        } 
        
        
    
        //////////////////////////******************************************** PSP 2024 Rule 35 Bug Fix /////////////////////////********************************************/
    
    // for redo selection .....=============================>>>>>>>>>>>>>>
    
    @AuraEnabled
    public static list<Bundle_Attributes__c> bundlenameRefresh(string comboName ,string Pumpname, string productBundleNameString){
        
        system.debug('productBundleNameString...'+productBundleNameString);
        system.debug('comboName...'+comboName);
        set<decimal>onlyRule = new set<decimal>();
        
        list<Product_Bundle__c>togetpumpID = [SELECT id, name from Product_Bundle__c where name =:Pumpname];
        string getProductBundleID = togetpumpID[0].id;
        system.debug('getProductBundleID...'+getProductBundleID);
        String[] bundleParts = productBundleNameString.split(' ');
        String firstNumber = bundleParts[0];
        
        decimal bunsequencetoLimit = decimal.valueOf(firstNumber);
        list<Product_Bundle_Rule_Engine__c>forandRule=[SELECT id, rule__c, Rule_Seq__c, pump__c, product__r.name, Bundle_Sequence__c, JDE_Component__c, Logic__c, Component_Type__c, Logic_Releationship__c, Is_Conditional_List__c, Is_Blank__c FROM Product_Bundle_Rule_Engine__c WHERE (Logic__c='if' OR Logic__c = 'And') AND JDE_Component__c =: comboName AND pump__c=:Pumpname AND Logic_Releationship__c ='EQ' ORDER BY JDE_Component__c];
        System.debug('FornadRule Size ---->'+forandRule.Size());
        if(!forandRule.isEmpty()){
            for(Product_Bundle_Rule_Engine__c forruleNumber :forandRule){
                onlyRule.add(forruleNumber.rule__c);
                System.debug('Rule Number --->'+forruleNumber.rule__c);
                System.debug('Inside True ---> '+forruleNumber.Is_Conditional_List__c);
                if(forruleNumber.Is_Conditional_List__c == true){
                    System.debug('Inside True ---> '+forruleNumber.Is_Conditional_List__c);
                    list<Rule_Picklist__c> secondForRule = [SELECT id,rule__c, Rule_Seq__c, Pump_Bundle__c ,product__r.name, Bundle_Sequence__c, component__c, Component_Type__c
                                                            from rule_picklist__c WHERE component__c =:comboName  AND Pump_Bundle__c=:Pumpname AND rule__c =:forruleNumber.rule__c AND Bundle_Sequence__c =: forruleNumber.Bundle_Sequence__c ORDER BY component__c];
                    System.debug('secondForRule Size ---->'+secondForRule.Size());
                    if(secondForRule.isEmpty()){
                        list<Product_Bundle_Rule_Engine__c>forandRuleFromBlank=[SELECT id, rule__c, Rule_Seq__c, pump__c, product__r.name, Bundle_Sequence__c, JDE_Component__c, Logic__c, Component_Type__c, Logic_Releationship__c, Is_Conditional_List__c, Is_Blank__c FROM Product_Bundle_Rule_Engine__c WHERE (Logic__c='if' OR Logic__c = 'And') AND Bundle_Sequence__c =: bunsequencetoLimit AND pump__c=:Pumpname AND Is_Blank__c = true AND Logic_Releationship__c = 'NE' ORDER BY JDE_Component__c];
                        
                        onlyRule.add(forandRuleFromBlank[0].rule__c);
                    }
                    for(Rule_Picklist__c sr : secondForRule){
                        System.debug('sr.rule__c --->'+sr.rule__c);
                        onlyRule.add(sr.rule__c);   
                    }
                }
            } 
        } else {
            list<Rule_Picklist__c> secondForRule = [SELECT id,rule__c, Rule_Seq__c, Pump_Bundle__c ,product__r.name, Bundle_Sequence__c, component__c, Component_Type__c
                                                    from rule_picklist__c WHERE component__c =:comboName  AND Pump_Bundle__c=:Pumpname  ORDER BY component__c];
                System.debug('secondForRule Size ---->'+secondForRule.Size());
                if(!secondForRule.isEmpty()){
                    for (Rule_Picklist__c RP : secondForRule) {
                        onlyRule.add(RP.rule__c);
                    }
                   
                }
        }
        
        list<Product_Bundle_Rule_Engine__c>forNERule=[SELECT id, rule__c, Rule_Seq__c, pump__c, product__r.name, Bundle_Sequence__c, JDE_Component__c, Logic__c, Component_Type__c, Logic_Releationship__c, Is_Conditional_List__c, Is_Blank__c FROM Product_Bundle_Rule_Engine__c WHERE (Logic__c='if' OR Logic__c = 'And') AND Bundle_Sequence__c =: bunsequencetoLimit AND pump__c=:Pumpname AND Logic_Releationship__c ='NE' AND JDE_Component__c !=: comboName ORDER BY JDE_Component__c];
        if(forNERule!= null){
            for(Product_Bundle_Rule_Engine__c NEinRUleEngine : forNERule){
                onlyRule.add(NEinRUleEngine.rule__c);
                
            }
        }
        
        system.debug('all rule number for in refresh logic ...'+onlyRule);
        
        set<decimal>BSequence = new set<decimal>();
        list<Product_Bundle_Rule_Engine__c>togetBS=[SELECT id, Bundle_Sequence__c, rule__c FROM Product_Bundle_Rule_Engine__c WHERE  Logic__c = 'Then' AND rule__c IN: onlyRule AND pump__c=:Pumpname  ORDER BY JDE_Component__c];
        for(Product_Bundle_Rule_Engine__c toaddBS : togetBS){
            BSequence.add(toaddBS.Bundle_Sequence__c);
        }
        system.debug('BSequence....'+BSequence);
        list<Bundle_Attributes__c>ProductBundleName = [SELECT id, name, Bundle_Sequence__c, Product_Bundle__c 
                                                       from Bundle_Attributes__c 
                                                       where Product_Bundle__c =: getProductBundleID 
                                                       and Bundle_Sequence__c IN:BSequence ORDER BY Bundle_Sequence__c];
        system.debug('ProductBundleName....'+ProductBundleName);
        return ProductBundleName;
    }
    
    //  ...............................................................................
    
    @AuraEnabled()
    public static map<string,decimal> forThenLogicPriceRule(string comboName ,string Pumpname, string stringPriceproduct, string productBundleNameString){
        system.debug('comboName of forThenLogicPriceRule...'+comboName);
        system.debug('Pumpname in forThenLogicPriceRule...>'+Pumpname);
        system.debug(' stringPriceproduct in forThenLogicPriceRule...>'+stringPriceproduct);
        system.debug(' productBundleNameString in forThenLogicPriceRule...>'+productBundleNameString);
        
        List<Object> listPriceproduct = (List<Object>) JSON.deserializeUntyped(stringPriceproduct);
        system.debug('listPriceproduct in forThenLogic...>'+listPriceproduct);
        Map<String, string> mapPriceRule = new map<string, string>();
        for (Object obj : listPriceproduct) {
            Map<String, Object> jsonObj = (Map<String, Object>) obj;
            String key = (String) jsonObj.get('key');
            String value = (String) jsonObj.get('value');
            mapPriceRule.put(key, value);
        }
        system.debug('mapPriceRule in forThenLogic...>'+mapPriceRule);
        
        Decimal price = 0;
        
        String[] keyParts = productBundleNameString.split(' ');
        String firstNumber = keyParts[0];
        system.debug('firstNumber...'+firstNumber);
        
        
        list<PricebookEntry> ruleOnePrice = [SELECT id,Product2.Name,Product2Id, UnitPrice, Pricebook2.name, ProductCode FROM PricebookEntry WHERE ProductCode =:comboName and Pricebook2.name = 'Pump Price Book'];
        
        // bundle seq of selected product   
        decimal bunsequenceofChoosen = decimal.valueOf(firstNumber);
        
        set<decimal>priceRuleSet = new set<decimal>();
        list <Price_rule_obj__c> selectedRule = [SELECT JDE_Component__c, Rule__c, Bundle_sequence__c FROM Price_rule_obj__c WHERE Pump__c =: pumpName AND Bundle_sequence__c =: bunsequenceofChoosen];
        if(selectedRule != null){
            for(Price_rule_obj__c PRules : selectedRule){
                priceRuleSet.add(PRules.Rule__c);
            }
        }
        system.debug('price rule set.'+priceRuleSet);
        system.debug('bunsequenceofChoosen...>'+bunsequenceofChoosen);
        
        set<decimal>exactPriceRule = new set<decimal>();
        set<string>codeSet = new set<string>();
        
        list <Price_rule_obj__c> accToRule = [SELECT JDE_Component__c, Rule__c, Bundle_sequence__c, Logic_Relationship__c FROM Price_rule_obj__c WHERE Pump__c =: pumpName AND Rule__c IN: priceRuleSet AND Bundle_sequence__c =: bunsequenceofChoosen];
        list <Rule_Picklist__c> forRuleType = [SELECT id, name, Bundle_Sequence__c, Component__c, Product__c, Product__r.name, Pump_Bundle__c, Rule__c, Rule_Type__c, Component_Type__c FROM Rule_Picklist__c WHERE  Pump_Bundle__c =: pumpName AND Bundle_sequence__c =: bunsequenceofChoosen AND Component__c =: comboName];
        
        if(accToRule != null){
            for(Price_rule_obj__c acc1 : accToRule){
                if((acc1.JDE_Component__c == null)&&(acc1.Logic_Relationship__c == null)){
                    system.debug('in 1st if');
                    exactPriceRule.add(acc1.Rule__c);
                }
                
                if((acc1.JDE_Component__c == comboName)&&(acc1.Logic_Relationship__c == 'EQ')){
                    system.debug('in 2nd if');
                    exactPriceRule.add(acc1.Rule__c);
                }
                if((acc1.JDE_Component__c == comboName)&&(acc1.Logic_Relationship__c == 'NE')){
                    system.debug('in 3rd if');
                    exactPriceRule.add(acc1.Rule__c);
                }
                // else {
                //     system.debug('in else');
                if(acc1.JDE_Component__c == '*VALUES'){
                    for(Rule_Picklist__c RP : forRuleType){
                        
                        if((RP.Rule_Type__c == 'Selection')&&(acc1.JDE_Component__c == '*VALUES')&&(acc1.Logic_Relationship__c == 'NE')){
                            exactPriceRule.add(acc1.Rule__c);
                        }
                        if((RP.Rule_Type__c == 'Price')&&(acc1.JDE_Component__c == '*VALUES')&&(acc1.Logic_Relationship__c == 'EQ')){
                            exactPriceRule.add(acc1.Rule__c);
                        }
                    }
                }
                // }
            }
        }
        system.debug('exact price rule...'+exactPriceRule);
        
        set<decimal>BSIfAnd = new set<decimal>();
        list <Price_rule_obj__c> rulelist = [SELECT id,  Pump__c, Component_Type__c, Bundle_sequence__c, JDE_Component__c, Logic_Relationship__c, Product__c, Logic__c, Rule__c FROM Price_rule_obj__c WHERE Bundle_sequence__c =: bunsequenceofChoosen AND Pump__c =: pumpName AND rule__c IN: exactPriceRule ORDER BY rule__c];
        for(Price_rule_obj__c byruleset : rulelist){
            if(byruleset.Rule__c == 1){
                price = ruleOnePrice[0].UnitPrice;
            }
            if(byruleset.Rule__c != 1){
                system.debug('when rule is not equal to 1 ');
                //  set<decimal>setBS = new set<decimal>();
                list <Price_rule_obj__c> byPriceRuleIf = [SELECT id,  Pump__c, Component_Type__c, Bundle_sequence__c, Logic__c,JDE_Component__c, Logic_Relationship__c, Product__c, Rule__c FROM Price_rule_obj__c WHERE  Pump__c =: pumpName AND rule__c =: byruleset.Rule__c AND (logic__c = 'And' OR logic__c = 'If')];
                system.debug('byPriceRuleIf...'+byPriceRuleIf);
                system.debug('byPriceRuleIf.size....'+byPriceRuleIf.size());
                // for(Price_rule_obj__c getBS: byPriceRuleIf){
                //     setBS.add(getBS.Bundle_sequence__c);
                // }
                // list <Price_rule_obj__c> byBS = [SELECT id,  Pump__c, Component_Type__c, Bundle_sequence__c, Logic__c,JDE_Component__c, Logic_Relationship__c, Product__c, Rule__c FROM Price_rule_obj__c WHERE  Pump__c =: pumpName AND rule__c =: byruleset.Rule__c AND Bundle_sequence__c =: setBS];
                string componentName = byPriceRuleIf[0].JDE_Component__c;
                
                string logicRelation = byPriceRuleIf[0].Logic_Relationship__c;
                decimal bundleSequence =  byPriceRuleIf[0].Bundle_sequence__c;
                // for(string value : mapPriceRule.values()) {
                for(String key : mapPriceRule.keySet()) {
                    String value = mapPriceRule.get(key);
                    
                    String[] parts = key.split(' ');
                    String newKey = parts[0].replaceAll('[^0-9.]', '');
                    decimal deciKey = decimal.valueOf(newKey);
                    system.debug('componentName...'+componentName);    
                    system.debug('value...'+value);    
                    system.debug('deciKey...'+deciKey);
                    if ((value == componentName)&&(logicRelation == 'EQ')&&(byruleset.logic__c == 'Then')) {
                        //if ((value == componentName)&&(logicRelation == 'EQ')) {
                        price = ruleOnePrice[0].UnitPrice;
                        system.debug('in == and EQ......and price'+price);
                        break;
                    }
                    // if((value == componentName)&&(logicRelation == 'NE')&&(deciKey == bundleSequence)&&(byruleset.logic__c == 'Then')){
                    //     list<Default_products__c> fromDefaultList = [SELECT id,Product_name__c, name, Bundle_Sequence__c, JDE_component__c, Component_Type__c FROM Default_products__c 
                    //     WHERE name =: pumpName AND Bundle_Sequence__c == deciKey AND JDE_component__c != componentName ORDER BY JDE_component__c];
                    // //if((value == componentName)&&(logicRelation == 'NE')&&(deciKey == bundleSequence)){
                    //     price = ruleOnePrice[0].UnitPrice;
                    //     system.debug('in == and NE......and price'+price);
                    //     break;
                    // }
                    if((value != componentName)&&(logicRelation == 'NE')&&(deciKey == bundleSequence)&&(byruleset.logic__c == 'Then')){
                        list<Default_products__c> fromDefaultList = [SELECT id,Product_name__c, name, Bundle_Sequence__c, JDE_component__c, Component_Type__c FROM Default_products__c 
                                                                     WHERE name =: pumpName AND Bundle_Sequence__c =: deciKey AND JDE_component__c !=: componentName ORDER BY JDE_component__c];
                        for (Default_products__c productCode : fromDefaultList){
                            if((productCode.JDE_component__c == value)&&(productCode.Bundle_Sequence__c== deciKey)){
                                price = ruleOnePrice[0].UnitPrice;
                                system.debug('in == and NE......and price'+price);
                                break;
                            }
                        }
                    }
                }
                
                if((componentName == '*VALUES')&&(logicRelation == 'EQ')){
                    list <Rule_Picklist__c> toGetNamelist = [SELECT id, name, Bundle_Sequence__c, Component__c, Product__c, Product__r.name, Pump_Bundle__c, Rule__c, Rule_Type__c, Component_Type__c FROM Rule_Picklist__c WHERE  Pump_Bundle__c =: pumpName AND Rule_Type__c = 'Price' AND Bundle_Sequence__c =: bundleSequence ];
                    set<string> nameOfComponent = new set <string>();
                    for(Rule_Picklist__c nameList : toGetNamelist){
                        nameOfComponent.add(nameList.Component__c);
                    }
                    for (string value : mapPriceRule.values()) {
                        if (nameOfComponent.contains(value)) {
                            price = ruleOnePrice[0].UnitPrice;
                            break;
                        }
                    }
                }
                
                if((componentName == '*VALUES')&&(logicRelation == 'NE')){
                    list <Rule_Picklist__c> toGetNamelist = [SELECT id, name, Bundle_Sequence__c, Component__c, Product__c, Product__r.name, Pump_Bundle__c, Rule__c, Rule_Type__c, Component_Type__c FROM Rule_Picklist__c WHERE  Pump_Bundle__c =: pumpName AND Rule_Type__c = 'Selection' AND Bundle_Sequence__c =: bundleSequence ];
                    set<string> nameOfComponent = new set <string>();
                    for(Rule_Picklist__c nameList : toGetNamelist){
                        nameOfComponent.add(nameList.Component__c);
                    }
                    system.debug('nameOfComponent....'+nameOfComponent);
                    for (string value : mapPriceRule.values()) {
                        if (nameOfComponent.contains(value)) {
                            price = ruleOnePrice[0].UnitPrice;
                            break;
                        }
                    }
                }
                
            }
        }
        map<string,decimal>codeWithPrice = new map<string,decimal>();
        codeWithPrice.put(productBundleNameString,price);
        system.debug('price....'+price);
        system.debug('codeWithPrice....'+codeWithPrice);
        return codeWithPrice;
    }
    
    
    // /////////////////////////////////..........     second screen ..................////////////////////////////////////////////////////////////////    
    
    @AuraEnabled(cacheable=true)
    public static list<outerwrapper> getAllsummary(string pumpId , string choosenarray ){
        list<Product_Bundle__c>getPumpName = [SELECT id, name from Product_Bundle__c where id =:pumpID];
        string pumpName= string.valueof(getPumpName[0].name);
        system.debug('pump Name...'+pumpName);
        system.debug('pumpId in getAllsummary'+pumpId);
        system.debug('choosenarray in getAllsummary ...'+choosenarray);
        List<Object> listchoosenarray = (List<Object>) JSON.deserializeUntyped(choosenarray);
        system.debug('listchoosenarray in getAllsummary...>'+listchoosenarray);
        Map<String, string> mapChoosenarray = new map<string, string>();
        for (Object obj : listchoosenarray) {
            Map<String, Object> jsonObj = (Map<String, Object>) obj;
            String key = (String) jsonObj.get('key');
            String value = (String) jsonObj.get('value');
            mapChoosenarray.put(key, value);
        }
        system.debug('mapChoosenarray in getAllsummary...>'+mapChoosenarray);
        list<decimal>bundleSeq = new list<decimal>();
        list<string>codename = new list<string>();
        
        Map<decimal, String> BScode = new Map<decimal, String>();
        for (String key : mapChoosenarray.keySet()) {
            String[] parts = key.split(' ');
            String newKey = parts[0].replaceAll('[^0-9.]', '');
            decimal deciKey = decimal.valueOf(newKey);
            String newValue = mapChoosenarray.get(key);
            bundleSeq.add(deciKey);
            codename.add(newValue);
            BScode.put(deciKey, newValue);
        }
        
        list<Allsummarywrapperdata>getAlldata = new list<Allsummarywrapperdata>();
        
        list<Bundle_Attributes__c>bundleAtt= [SELECT id, name, Bundle_Sequence__c, Product_Bundle__c from Bundle_Attributes__c where Product_Bundle__c =: pumpId AND Bundle_Sequence__c IN:bundleSeq ORDER BY Bundle_Sequence__c];
        list<Default_products__c>codeNameByDefault = [SELECT id,Product_name__c, name, Bundle_Sequence__c, JDE_component__c, Component_Type__c, Price__c FROM Default_products__c WHERE JDE_component__c IN:codename AND name =: pumpName AND Bundle_Sequence__c IN:bundleSeq ORDER BY Bundle_Sequence__c];
        system.debug('codeNameByDefault....'+codeNameByDefault);
        Set<String> jdeComponents = new Set<String>();
        for(Default_products__c CBD : codeNameByDefault){
            if((BScode.containsKey(CBD.Bundle_Sequence__c))&&(BScode.get(CBD.Bundle_Sequence__c) == CBD.JDE_component__c)){
                getAlldata.add(new Allsummarywrapperdata(CBD.id, CBD.Bundle_Sequence__c, CBD.Product_name__c, CBD.JDE_component__c, CBD.Component_Type__c,0));
            }
            
            jdeComponents.add(CBD.JDE_component__c);
        }
        
        for(decimal key : BScode.keySet()){
            String value = BScode.get(key);
            if(!jdeComponents.contains(value)){
                system.debug('code not in default list ....'+value);
                getAlldata.add(new Allsummarywrapperdata(null, key, value, '------', 'Attribute',0));
            }
        }
        
        system.debug('getAlldata ....'+getAlldata);
        system.debug('size of getAlldata ....'+getAlldata.size());
        list <Price_rule_obj__c> byPriceRuleOne = [SELECT id,  Pump__c, Component_Type__c, Bundle_sequence__c, Logic__c,JDE_Component__c, Logic_Relationship__c, Product__c, Rule__c FROM Price_rule_obj__c WHERE  Pump__c =: pumpName AND Rule__c = 1];
        
        for(Price_rule_obj__c pro : byPriceRuleOne){
            for(Allsummarywrapperdata aswd : getAlldata){
                if (pro.Bundle_sequence__c == aswd.bunSequence){
                    for (Default_products__c cbd : codeNameByDefault) {
                        if (cbd.Bundle_Sequence__c == aswd.bunSequence && cbd.JDE_component__c == aswd.JDEcomponent) {
                            aswd.price = cbd.Price__c;
                            break; 
                        }
                    }
                    break;
                }
            }
        }
        
        list <Price_rule_obj__c> byPriceRuleIf = [SELECT id,  Pump__c, Component_Type__c, Bundle_sequence__c, Logic__c,JDE_Component__c, Logic_Relationship__c, Product__c, Rule__c FROM Price_rule_obj__c WHERE  Pump__c =: pumpName AND (logic__c = 'And' OR logic__c = 'If') AND Rule__c != 1];
        map<string, decimal> ifMap = new map<string, decimal>();
        for(Price_rule_obj__c forMapCodeWithSeq : byPriceRuleIf){
            // system.debug('in for loop');
            if((forMapCodeWithSeq.Logic_Relationship__c == 'EQ')&&(forMapCodeWithSeq.JDE_Component__c == '*VALUES')){
                system.debug('in eq if');
                list <Rule_Picklist__c> toGetNamelist = [SELECT id, name, Bundle_Sequence__c, Component__c, Product__c, Product__r.name, Pump_Bundle__c, Rule__c, Rule_Type__c, Component_Type__c FROM Rule_Picklist__c WHERE  Pump_Bundle__c =: pumpName AND Rule_Type__c = 'Price' AND Bundle_Sequence__c =: forMapCodeWithSeq.Bundle_sequence__c ]; 
                for(Rule_Picklist__c priceRule : toGetNamelist){
                    ifMap.put(priceRule.Component__c,priceRule.Bundle_Sequence__c);
                }
                
            }
            if((forMapCodeWithSeq.Logic_Relationship__c == 'NE')&&(forMapCodeWithSeq.JDE_Component__c == '*VALUES')){
                // system.debug('in NE if');
                list <Rule_Picklist__c> toGetNamelist2 = [SELECT id, name, Bundle_Sequence__c, Component__c, Product__c, Product__r.name, Pump_Bundle__c, Rule__c, Rule_Type__c, Component_Type__c FROM Rule_Picklist__c WHERE  Pump_Bundle__c =: pumpName AND Rule_Type__c = 'Selection' AND Bundle_Sequence__c =: forMapCodeWithSeq.Bundle_sequence__c ]; 
                for(Rule_Picklist__c priceRule : toGetNamelist2){
                    ifMap.put(priceRule.Component__c,priceRule.Bundle_Sequence__c);
                }
                
            }
            if((forMapCodeWithSeq.JDE_Component__c != '*VALUES')&&(forMapCodeWithSeq.Logic_Relationship__c == 'EQ')){
                system.debug('in not *value if');
                ifMap.put(forMapCodeWithSeq.JDE_Component__c,forMapCodeWithSeq.Bundle_Sequence__c);
                
            }
            if((forMapCodeWithSeq.JDE_Component__c != '*VALUES')&&(forMapCodeWithSeq.Logic_Relationship__c == 'NE')){
                system.debug('in not *value if and relation is NE');
                system.debug('forMapCodeWithSeq.JDE_Component__c.....'+forMapCodeWithSeq.JDE_Component__c);
                list<Product_Bundle_Rule_Engine__c > forCode = [SELECT name, pump__c, Product_Bundle__c, Bundle_Sequence__c, JDE_Component__c, Logic__c, Component_Type__c, Is_Conditional_List__c, rule__c FROM Product_Bundle_Rule_Engine__c where  pump__c=: pumpName AND Bundle_Sequence__c =: forMapCodeWithSeq.Bundle_Sequence__c AND JDE_Component__c !=: forMapCodeWithSeq.JDE_Component__c];
                set<decimal>BSFromEngine = new set<decimal>();
                set<decimal>ruleFromEngine = new set<decimal>();
                for(Product_Bundle_Rule_Engine__c getCode : forCode){
                    if(getCode.Is_Conditional_List__c == false){
                        ifMap.put(getCode.JDE_Component__c,getCode.Bundle_Sequence__c);
                    }
                    else{
                        BSFromEngine.add(getCode.Bundle_Sequence__c);
                        ruleFromEngine.add(getCode.rule__c);
                    }
                    
                }
                list <Rule_Picklist__c> toGetNamelist3 = [SELECT name, Bundle_Sequence__c, Component__c, Product__c, Product__r.name, Pump_Bundle__c FROM Rule_Picklist__c WHERE  Pump_Bundle__c =: pumpName AND Bundle_Sequence__c IN: BSFromEngine AND Component__c !=: forMapCodeWithSeq.JDE_Component__c AND Rule__c IN: ruleFromEngine];  
                if(toGetNamelist3 != null){
                    for(Rule_Picklist__c priceRule : toGetNamelist3){
                        ifMap.put(priceRule.Component__c,priceRule.Bundle_Sequence__c);
                    }
                }
                
            }
        }
        system.debug('if map ...'+ ifMap);
        system.debug('if map size ...'+ ifMap.size());
        // if(ifMap.containsKey()){
        //     system.debug('it has that key ');
        // }
        
        set<decimal>BStoGetRule = new set<decimal>();
        for (String key : ifMap.keySet()) {
            if (BScode.containsKey(ifMap.get(key)) && BScode.get(ifMap.get(key)) == key) {
                //                 if((((ifMap.get(key)) == 604))&&(key == '1141102')){
                // system.debug('....................................................'+ifMap.get(key) + key);
                //                 }
                system.debug('Key..... to check it contains or not?? ' + key + ' with value ' + ifMap.get(key) + ' exists in BScode');
                BStoGetRule.add(ifMap.get(key));
            }
        }
        system.debug('BStoGetRule ...'+ BStoGetRule);
        list <Price_rule_obj__c> forRulePriceRuleIf = [SELECT id,  Pump__c, Component_Type__c, Bundle_sequence__c, Logic__c,JDE_Component__c, Logic_Relationship__c, Product__c, Rule__c FROM Price_rule_obj__c WHERE  Pump__c =: pumpName AND (logic__c = 'And' OR logic__c = 'If') AND Rule__c != 1 AND Bundle_sequence__c IN: BStoGetRule];
        system.debug('forRulePriceRuleIf ...'+ forRulePriceRuleIf);
        set<decimal>ruleSet = new set<decimal>();
        for(Price_rule_obj__c onlyruleFromIf : forRulePriceRuleIf){
            ruleSet.add(onlyruleFromIf.Rule__c);
        }
        system.debug('ruleSet.....'+ruleSet);
        
        set<decimal>BSfromThen = new set<decimal>();
        list <Price_rule_obj__c> byPriceRuleThen = [SELECT id,  Pump__c, Component_Type__c, Bundle_sequence__c, Logic__c,JDE_Component__c, Logic_Relationship__c, Product__c, Rule__c FROM Price_rule_obj__c WHERE  Pump__c =: pumpName AND logic__c = 'Then' AND Rule__c IN:ruleSet ];
        for(Price_rule_obj__c addingPrice : byPriceRuleThen){
            BSfromThen.add(addingPrice.Bundle_sequence__c);
        }
        
        system.debug('byPriceRuleThen...'+byPriceRuleThen);
        system.debug('BSfromThen.....'+BSfromThen);
        for(Allsummarywrapperdata priceInwrapper : getAlldata){
            if(BSfromThen.contains(priceInwrapper.bunSequence)){
                list<Default_products__c>forprice = [SELECT id,Product_name__c, name, Bundle_Sequence__c, JDE_component__c, Component_Type__c, Price__c FROM Default_products__c WHERE  name =: pumpName AND Bundle_Sequence__c =: priceInwrapper.bunSequence AND JDE_component__c =: priceInwrapper.JDEcomponent];
                for(Default_products__c FP : forprice){
                    if(FP.JDE_component__c == priceInwrapper.JDEcomponent){
                        priceInwrapper.price = FP.Price__c;
                    }
                }
            }
        }
        
        
        
        // /////////////  wrapping start here .....////////////////////////////////////////////////////////////////////
        list<outerwrapper>forBundle = new list<outerwrapper>();
        for(Bundle_Attributes__c BA : bundleAtt){
            list<insideBundleWrapper>insideBundle = new list<insideBundleWrapper>();
            for(Allsummarywrapperdata GADinsidebun : getAlldata){
                if(GADinsidebun.bunSequence==BA.Bundle_Sequence__c){
                    insideBundle.add(new insideBundleWrapper(GADinsidebun.id, GADinsidebun.bunSequence, GADinsidebun.name, GADinsidebun.JDEcomponent, GADinsidebun.componentType,GADinsidebun.price));
                }
            }
            forBundle.add(new outerwrapper(BA.id, BA.name, BA.Bundle_Sequence__c, BA.Product_Bundle__c, insideBundle));
        }
        
        system.debug('forBundle...'+forBundle);
        return forBundle;
    }
    
    public class outerwrapper{
        @AuraEnabled 
        public String id{get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled 
        public decimal seqBundle {get;set;}
        @AuraEnabled
        public string productbundleID {get;set;}
        @AuraEnabled
        public list<insideBundleWrapper> selectedlist {get;set;}
        
        public outerwrapper(String id, String name, decimal seqBundle, string productbundleID, list<insideBundleWrapper> selectedlist){
            this.id= id;
            this.name = name;
            this.seqBundle = seqBundle;
            this.productbundleID = productbundleID;
            this.selectedlist = selectedlist;
        }
    }
    
    public class insideBundleWrapper{
        @AuraEnabled 
        public String id{get;set;}
        @AuraEnabled 
        public decimal seqBundle {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public string component {get;set;}
        @AuraEnabled
        public string componentTypeInside {get;set;}
        @AuraEnabled
        public decimal price {get;set;}
        
        public insideBundleWrapper(String id,decimal seqBundle,String name , string component, string componentTypeInside,decimal price ){
            this.id= id;
            this.seqBundle = seqBundle;
            this.name = name;
            this.component = component;
            this.componentTypeInside = componentTypeInside;
            this.price = price;
        }
    }
    
    public class Allsummarywrapperdata{
        @AuraEnabled 
        public String id{get;set;}
        @AuraEnabled 
        public Decimal bunSequence {get;set;}
        @AuraEnabled 
        public string name {get;set;}
        @AuraEnabled 
        public string JDEcomponent {get;set;}
        @AuraEnabled 
        public string componentType {get;set;}
        @AuraEnabled
        public decimal price {get;set;}
        
        public Allsummarywrapperdata(String id, decimal bunSequence,string name, string JDEcomponent, string componentType,decimal price ){
            this.id= id;
            this.bunSequence = bunSequence;
            this.name =  name;
            this.JDEcomponent = JDEcomponent;
            this.componentType = componentType;
            this.price = price;
        }
    }
    
    // //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @AuraEnabled
    public static list<String>createQuote(string Opportunityid , string maincmp ,string requireddata, decimal totalDiscount, decimal totalPrice){ 
        List<quotepriceWrapperrequired> requireddatalist = (List<quotepriceWrapperrequired>)JSON.deserialize(requireddata, List<quotepriceWrapperrequired>.class);
        system.debug('requireddatalist'+requireddatalist);
        system.debug('Opportunityid'+Opportunityid);
        system.debug('maincmp'+maincmp);
        system.debug('totalPrice'+totalPrice);        
        
        string quoteDescrip = '';
        for(quotepriceWrapperrequired attributeType : requireddatalist){
            if(attributeType.componentType == 'Attribute'){
                quoteDescrip += 'Bundle name: '+attributeType.Bundleattribute + ' ' +'Product name: '+ attributeType.productName + ',' + '  ';
            } 
        }
        system.debug('string quoteDescrip'+ quoteDescrip);
        
        list<Quote> qlist=new list<Quote>();
        List<QuoteLineItem> lstQLI = new List<QuoteLineItem>();
        Quote qu=new Quote();        
        list< RecordType> RecType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote' and DeveloperName = 'Pump']; 
        list<pricebook2> pumppricebook = [SELECT IsActive ,Description, IsStandard, Id, Name, SystemModstamp FROM Pricebook2 WHERE IsActive=True and Name='Pump Price Book'];   
        Quote qo=new Quote();
        qo.RecordTypeId=RecType[0].Id;
        qo.Pricebook2Id= pumppricebook[0].Id ;         
        qo.OpportunityId=Opportunityid;
        qo.Name=maincmp;
        qo.Status='Draft';
        qo.Description = quoteDescrip;
        // qo.Discount_On_Total__c = totalDiscount;
        qo.Total_Price_w_Total_Discount__c = totalPrice;
        qlist.add(qo);
        
        insert qlist;
        
        system.debug('qlistid....'+qlist[0].Id);
        //   string forReturn;
        
        //   product which are missing...................................
        set<string> beforeReturn = new set<string>();
        set<string>missingProductName = new set<string>();
        // end...........................................................
        
        if(requireddatalist.size()>0){
            
            for(quotepriceWrapperrequired requiredproducts:requireddatalist ){
                if(requiredproducts.componentType == 'Product'){
                    system.debug('requiredproducts.Productid....'+requiredproducts.Productid);
                    system.debug('requiredproducts.productcode....'+requiredproducts.productcode);
                    system.debug('requiredproducts.productName....'+requiredproducts.productName);
                    list<Product2>productList = [SELECT id, name, ProductCode FROM Product2 WHERE ProductCode =: requiredproducts.productcode];
                    if (!productList.isEmpty()) {
                    system.debug('productList[0].id...'+productList[0].id);
                    List<PriceBookEntry> pEntries = [Select id, product2.name, product2.id, ProductCode, Unitprice from Pricebookentry where pricebook2.name = 'Pump Price Book' and product2.id =: productList[0].id];
                    //  List<PriceBookEntry> pEntries = [select id, product2.name,product2.id, ProductCode, Unitprice from Pricebookentry where pricebook2.name = 'Pump Price Book' and ProductCode = ' ABC '];
                    system.debug('pEntries'+pEntries);
                    
                    QuoteLineItem qli = new QuoteLineItem();
                    if(!pEntries.isEmpty()){
                        qli.quoteId =  qlist[0].Id;
                        qli.UnitPrice =  requiredproducts.price;
                        qli.Product2Id = pEntries[0].product2.id;
                        qli.Quantity = requiredproducts.quantity;
                        qli.PriceBookentryid = pEntries[0].id;
                        qli.Discount = requiredproducts.discount;
                        lstQLI.add(qli);
                        beforeReturn.add(qlist[0].id);
                    } else {
                        //  forReturn =  'No ID';
                        string errorElement = requiredproducts.productName + ' '+ '('+requiredproducts.productcode+')';
                        system.debug('errorElement'+errorElement);
                        missingProductName.add(errorElement);
                        system.debug('missingProductName'+missingProductName);
                        
                     }
                } else {
                    string errorElement = requiredproducts.productName + ' '+ '('+requiredproducts.productcode+')';
                        system.debug('errorElement'+errorElement);
                        missingProductName.add(errorElement);
                        system.debug('missingProductName'+missingProductName);
                }
                    
                }  
                
            }  
        }
        system.debug('beforeReturn./...forReturn...'+beforeReturn);
        List<String> beforeReturnList = new list<String>(beforeReturn);
        List<String> missingProductNameList = new list<String>(missingProductName);
        if(lstQLI.size()>0){     
            insert lstQLI;
        }
        system.debug('qlist'+qlist);
        if(missingProductName.isEmpty()){
            system.debug('not missing product');
            return beforeReturnList; 
        }
        else{
            system.debug('missing product');
            return missingProductNameList; 
        }
        
        // return forReturn;
    }
    
    public class quotepriceWrapperrequired{
        @AuraEnabled
        public String Bundleattribute {get;set;} 
        @AuraEnabled 
        public string bundleid {get;set;}
        @AuraEnabled
        public string productid {get;set;}
        @AuraEnabled 
        public string productName {get;set;}
        @AuraEnabled 
        public string productcode {get;set;}
        @AuraEnabled 
        public string componentType {get;set;}
        @AuraEnabled 
        public Decimal price {get;set;}
        @AuraEnabled 
        public Decimal quantity {get;set;}
        @AuraEnabled 
        public Decimal discount {get;set;}
        @AuraEnabled 
        public Decimal finalprice {get;set;}
        
        public quotepriceWrapperrequired(String Bundleattribute,string bundleid,  string productid, string productName, string productcode, string componentType, Decimal price,Decimal quantity,Decimal discount,Decimal finalprice){
            this.Bundleattribute = Bundleattribute;
            this.bundleid = bundleid;
            this.productid = productid;
            this.productName = productName;
            this.productcode = productcode;
            this.componentType = componentType;
            this.price = price;
            this.quantity = quantity;
            this.discount = discount;
            this.finalprice = finalprice;
            
        }
    }
    
}