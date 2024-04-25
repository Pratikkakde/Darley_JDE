public class Batch_on_opportunity_and_forecast implements Database.Batchable<sObject> {
    
    Integer yearValue = Integer.valueOf(system.label.yearValue);
    public Database.QueryLocator start(Database.BatchableContext bc)
    { 
        
        list< RecordType> RecType = [Select Id From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'Pump'];
        
        return Database.getQueryLocator([select id,name,(select amount,CloseDate  from Opportunities  where Accountid!=null  AND 
                                                         Parent_Opportunity__c=null AND StageName='Closed/Won'AND RecordTypeId=:RecType[0].id  AND Closed_Year__c = :yearValue) from Account
                                         where id in (select accountid from opportunity where Accountid!=null  AND 
                                                      Parent_Opportunity__c=null AND StageName='Closed/Won' AND RecordTypeId=:RecType[0].id AND Closed_Year__c = :yearValue )]);
    }
     
    public void execute(Database.BatchableContext bc, List<Account> acclist){
        system.debug('acclist'+acclist); 
        string dateValue = system.label.yearValue;
        Map<id,Decimal> AccMap=new Map<Id,Decimal>();
        for(account acc:acclist){ 
            system.debug('acc'+acclist);
            decimal exp=0;
            for(opportunity opp:acc.Opportunities){
                
                if(opp.amount!=null) {
                    exp=exp+opp.Amount;    
                    system.debug(exp);                  
                }  
            }
            AccMap.put(acc.Id,exp); 
        }
        
        map<id,Forecast__c> accountForecast = new  map<id,Forecast__c>();
        for(Forecast__c foreC:[select id,Total_Opportunity_Sales_Achieved__c,Account__c from Forecast__c Where Year__c=:dateValue AND Account__c IN :AccMap.keySet()])
        {
            accountForecast.put(forec.account__c,forec);
        }
        list<Forecast__c> updateForecast = new list<Forecast__c>();
        list<Forecast__c> InsertForecast = new list<Forecast__c>();
        
        for(account acc1: acclist) 
        { 
            if(accountForecast.get(acc1.id)!=null)
            {
                
                Forecast__c fore = new Forecast__c();
                fore.id = accountForecast.get(acc1.id).id;
                fore.Total_Opportunity_Sales_Achieved__c=AccMap.get(acc1.ID);
                updateForecast.add(fore);
                system.debug(AccMap.get(acc1.id));
                
            }
            //    else
            //    {
            //        Forecast__c fet= new Forecast__c();  
            //        fet.Year__c=dateValue;
            //        fet.Total_Opportunity_Sales_Achieved__c=AccMap.get(acc1.id);
            //        fet.Account__c=acc1.id;
            //        InsertForecast.add(fet); 
            //    } 
        }
        update updateForecast;
        //insert InsertForecast;
    }
    public void finish(Database.BatchableContext bc){
        
    }
    
}