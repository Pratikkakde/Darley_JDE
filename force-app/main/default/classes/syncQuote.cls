/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 11-15-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public class syncQuote implements Queueable {
    Map<Id, Id> quoteMap = new Map<Id, Id> ();
    public syncQuote(Map<Id, Id> quoteMap1) {
        this.quoteMap = quoteMap1;
    }
    public void execute(QueueableContext context) {
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        for(Id currentQuote : quoteMap.keyset()){
            System.debug('currentQuote -->'+currentQuote);
            Opportunity opp = new Opportunity();
            opp.Id = quoteMap.get(currentQuote);
            opp.SyncedQuoteId = currentQuote;
            oppMap.put(opp.Id, opp);
        }
        database.update (oppMap.values(),false);
        System.debug('oppList --->'+oppMap.values());
    }
}