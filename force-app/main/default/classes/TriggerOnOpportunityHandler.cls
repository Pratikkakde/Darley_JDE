public class TriggerOnOpportunityHandler {     
    
    public static boolean firstRun = true; 
    
    public Static void afterInsert(List<opportunity> newopplist){
        system.debug('newopplist' +newopplist);
        Set<ID> setID=new Set<ID>();
        List<id> accid= new List<id>();
        String year;
        Double ClosedYear;
        list<Opportunity> acclist=new list<Opportunity>();        
        list< RecordType> RecType = [Select Id From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'Pump'];
        system.debug('RecordtypeId' +RecType);
        for(opportunity opp1:newopplist){
            if( opp1.RecordTypeId==RecType[0].id) { 
                if(opp1.accountid!=null && opp1.StageName=='Closed/Won' && opp1.Parent_Opportunity__c==null ){
                    setID.add(opp1.accountid);
                    accid.add(opp1.accountid);
                    year = String.valueOf(opp1.CloseDate.year());
                    ClosedYear = opp1.CloseDate.year();
                }                   
            }
            System.debug('opp.CloseDate.year-->'+opp1.CloseDate.year());  
        } 
        
        system.Debug('year'+year); 
        
        // acclist=[select id,name,(select amount ,StageName,CloseDate from Opportunities where RecordTypeId=:RecType[0].id AND StageName='Closed/Won' ) from account where ID IN:setID];
        acclist=[select amount ,StageName,CloseDate, Closed_Year__c,AccountId from Opportunity where RecordTypeId=:RecType[0].id AND Parent_Opportunity__c=null AND StageName='Closed/Won' AND Closed_Year__c=:ClosedYear AND accountid IN:setID];
        system.debug('acclist'+acclist);       
        // Map<id,Decimal> AccMap=new Map<Id,Decimal>();
        
        map<id,decimal> accountTotalAmount = new map<id,decimal>();
        decimal exp=0;
        for(opportunity opp:acclist){
            if(opp.amount!=null) {
                if(accountTotalAmount.containsKey(opp.AccountId))
                {
                    accountTotalAmount.put(opp.AccountId,opp.amount+accountTotalAmount.get(opp.AccountId));
                }
                else
                {
                    accountTotalAmount.put(opp.AccountId,opp.amount);
                }          
            } 
        } 
        
        system.debug('expense'+exp);            
        
        list<Forecast__c> ftlist=[select id,Total_Opportunity_Sales_Achieved__c,Account__c,Year__c from Forecast__c Where Year__c=:year AND Account__c IN: setID];
        for (Forecast__c ft:ftlist){
            if(ft.Year__c==year){
                ft.Total_Opportunity_Sales_Achieved__c = accountTotalAmount.get(ft.Account__c);
            } 
        }
        if(ftlist.size() > 0)
        {
            update ftlist;
        } 
    }
    
    public Static void afterupdate(List<opportunity> newopplist ,List<opportunity> oldMapList,Map<id,opportunity> newMapList,Map<id,opportunity> oldMap){
        system.debug('newopplist'+newopplist);
        system.debug('oldMapList'+oldMapList);
        Set<ID> setID=new Set<ID>();
        Set<ID> OldAccID = new Set<ID>();
        List<id> accid= new List<id>();
        list<Opportunity> OldOpplist=new list<Opportunity>(); 
        list< RecordType> RecType = [Select Id From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'Pump'];
        list<Opportunity> acclist=new list<Opportunity>(); 
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Pump').getRecordTypeId();       
        map<id,opportunity> oppMap = new Map<id,Opportunity>();
        
        String year;
        Double ClosedYear;
        String Oldyear;
        Double OldClosedYear;
        
        
        for(opportunity opp:oldMapList){           
            if((opp.accountid!=null || opp.accountid!=oldMap.get(opp.id).accountid) && (opp.StageName=='Closed/Won' || oldMap.get(opp.id).stageName=='Closed/Won') && (opp.Parent_Opportunity__c==null || opp.Parent_Opportunity__c!=oldMap.get(opp.id).Parent_Opportunity__c)) {
                OldAccID.add(opp.AccountId);            
            }
            Oldyear = String.valueOf(opp.CloseDate.year());
            OldClosedYear = opp.CloseDate.year();
        }
        
        system.debug('OldAccID'+OldAccID);
        OldOpplist=[select amount ,StageName,CloseDate, Closed_Year__c,AccountId from Opportunity where RecordTypeId=:RecType[0].id AND Parent_Opportunity__c=null AND  StageName='Closed/Won' AND Closed_Year__c=:OldClosedYear AND accountid IN:OldAccID];
        system.debug('OldOpplist'+OldOpplist);  
        decimal Oldexp=0;  
        for(opportunity opp:newopplist){  
            
            if((opp.accountid!=null || opp.accountid!=oldMap.get(opp.id).accountid) && (opp.StageName=='Closed/Won' || oldMap.get(opp.id).stageName=='Closed/Won') && (opp.Parent_Opportunity__c==null || opp.Parent_Opportunity__c!=oldMap.get(opp.id).Parent_Opportunity__c)) {
                setID.add(opp.AccountId);  
                accid.add(opp.accountid);
            }
            
            
            year = String.valueOf(opp.CloseDate.year());
            system.debug('year1'+year);
            ClosedYear = opp.CloseDate.year();
        }
        acclist=[select amount ,StageName,CloseDate, Closed_Year__c,AccountId from Opportunity where RecordTypeId=:RecType[0].id  AND Parent_Opportunity__c=null AND StageName='Closed/Won' AND Closed_Year__c=:ClosedYear AND accountid IN:setID];
       system.debug('acclist'+acclist);
        map<id,decimal> accountTotalAmount = new map<id,decimal>();
        
        decimal exp=0;
        for(opportunity opp:acclist){
            if(opp.amount!=null){
            system.debug('opp.accountid'+opp.AccountId);
             system.debug('opp.id'+opp.id);
            
            if(accountTotalAmount.containsKey(opp.AccountId))
            {
                  system.debug('in if');
                accountTotalAmount.put(opp.AccountId,opp.amount+accountTotalAmount.get(opp.AccountId));
                system.debug('accountTotalAmount in if'+accountTotalAmount);
                
            }
            else
            {
                system.debug('else');
                accountTotalAmount.put(opp.AccountId,opp.amount);
                system.debug('accountTotalAmountin else'+accountTotalAmount);
            }
             system.debug('accountTotalAmount'+accountTotalAmount);
            }
        } 
        list<Forecast__c> ftlist=[select id,Total_Opportunity_Sales_Achieved__c,Account__c from Forecast__c Where Year__c=:year AND Account__c IN :setID] ;
        System.debug('ftlist'+ftlist); 
        
        if(ftlist.size() > 0){
            List<Forecast__c> forcastList = new List<Forecast__c>();
            for (Forecast__c ft:ftlist){            
                Forecast__c forcast = new Forecast__c();
                forcast.id = ft.id;
                forcast.Total_Opportunity_Sales_Achieved__c = accountTotalAmount.get(ft.Account__c);
                system.debug('Record-->'+forcast);
                forcastList.add(forcast); 
                
            }
            update forcastList;
        }
        
        
    } 
    
    public Static void afterDelete(List<opportunity> oldopplist){
        Set<ID> setID=new Set<ID>();
        list<Opportunity> acclist=new list<Opportunity>();    
        list< RecordType> RecType = [Select Id From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'Pump'];
        String year;
        Double ClosedYear;
        for(opportunity opp1:oldopplist){
            if( opp1.RecordTypeId==RecType[0].id) { 
                if(opp1.accountid!=null && opp1.StageName=='Closed/Won'  && opp1.Parent_Opportunity__c==null ){
                    setID.add(opp1.accountid);
                } 
                year = String.valueOf(opp1.CloseDate.year());
                ClosedYear = opp1.CloseDate.year();
            } 
        }
        
        acclist=[select amount ,StageName,CloseDate, Closed_Year__c,AccountId from Opportunity where RecordTypeId=:RecType[0].id AND Parent_Opportunity__c=null AND StageName='Closed/Won' AND Closed_Year__c=:ClosedYear AND accountid IN:setID];
        system.debug('acclist'+acclist);
        list<opportunity> opplist=new list<opportunity>();
        map<id,decimal> accountTotalAmount = new map<id,decimal>();
        decimal exp=0;
        for(opportunity opp:acclist){
            if(accountTotalAmount.containsKey(opp.AccountId))
            {
                        system.debug('in if');

                accountTotalAmount.put(opp.AccountId,opp.amount+accountTotalAmount.get(opp.AccountId));
            }
            else
            {
                system.debug('else');
                accountTotalAmount.put(opp.AccountId,opp.amount);
            }        
        }
        
        list<Forecast__c> ftlist=[select id,Total_Opportunity_Sales_Achieved__c,Account__c from Forecast__c Where Year__c=:year AND Account__c IN :setID] ;
       system.debug('ftlist'+ftlist);
        for (Forecast__c ft:ftlist){
            ft.Total_Opportunity_Sales_Achieved__c = accountTotalAmount.get(ft.Account__c);
           system.debug('ft.Total_Opportunity_Sales_Achieved__c'+accountTotalAmount.get(ft.Account__c));  
        }
        
        update ftlist; 
    }  
}