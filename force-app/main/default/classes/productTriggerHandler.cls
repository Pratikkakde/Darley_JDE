public class productTriggerHandler {
    //before insert
    public static void handleBeforeInsert(List<product2> proList){
        system.debug('productList: '+proList);
        set<string> vendorSet = new set<string>();
        if(!proList.isEmpty()){
            for(product2 prd : proList){
                vendorSet.add(prd.vendor__c);
            }
        }
        system.debug('vendorNameSet: '+vendorSet);
        Map<string, id> accIDMap = new Map<string, id>();
        if(!vendorSet.isEmpty()){
            List<Account> accList = [select id, name from Account where Name In: vendorSet];
            if(!accList.isEmpty()){
                for(Account acc1 : accList){
                    accIDMap.put(acc1.Name , acc1.id);
                }
            }
        }
        
        if(!proList.isEmpty()){
            for(product2 pro : proList){
                if(pro.Vendor__c != null){
                    pro.Vendor_Account__c = accIDMap.get(pro.Vendor__c) ;
                }
                if(pro.JDE_Stocking_Type__c != '' && pro.JDE_Stocking_Type__c == 'Obsolete'){
                    pro.IsActive = false;
                    pro.Stocking_Type__c = 'Obsolete';
                }else if(pro.JDE_Stocking_Type__c != '' && pro.JDE_Stocking_Type__c == 'Obsolete - Use Up' ){
                    pro.IsActive = false;
                    pro.Stocking_Type__c = 'Use-Up';
                }else if(pro.JDE_Stocking_Type__c != '' && pro.JDE_Stocking_Type__c != 'Obsolete - Use Up' && pro.JDE_Stocking_Type__c != 'Obsolete'){
                    pro.IsActive = true;
                    pro.Stocking_Type__c = 'Active';
                }
            }
        }
    }
    
    public static void changeRecordType(List<product2> newList){
        if(!newList.isEmpty()){
            //Id profileId = UserInfo.getProfileId();
            //String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
            
            //if(profileName == 'Salesforce API Only System Integrations'){
                
                    Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Product2.getRecordTypeInfosByName();
                
                
                for(product2 pro : newList){
                    if (pro.Record_Type__c != '' && pro.Record_Type__c == 'Equipment') {
                        pro.recordtypeId = recordTypes.get('Equipment Products').getRecordTypeId();
                    } else if (pro.Record_Type__c != '' && pro.Record_Type__c == 'Defense') {
                        pro.recordtypeId = recordTypes.get('Defense').getRecordTypeId();
                    } else if (pro.Record_Type__c != '' && pro.Record_Type__c == 'Pump') {
                        pro.recordtypeId = recordTypes.get('Pump').getRecordTypeId();
                    }else{
                        pro.recordtypeId = recordTypes.get('Other').getRecordTypeId();
                    }
                //}
            }
        }
    }
}