trigger TirggerOnBundleAttribute on Bundle_Attributes__c (before insert, before update) {
    
    if(trigger.isInsert || trigger.isupdate)
    {
        if(trigger.isbefore)
        {  
            Handler_TriggerOnBundleAttribute.populateProductBundle(Trigger.new, Trigger.oldMap);
        }
    } 
}