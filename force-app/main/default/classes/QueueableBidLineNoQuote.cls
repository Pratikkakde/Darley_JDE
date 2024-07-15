public class QueueableBidLineNoQuote implements Schedulable {
    /* Crone Exp for every hr
*  QueueableBidLineNoQuote job = new QueueableBidLineNoQuote();
String scheduleId = System.schedule('QueueableBidLineNoQuote', '0 0 * * * ?', job);
String scheduleId = System.schedule('QueueableBidLineNoQuote30min', '0 30 * * * ?', job);

*/
    
    public void execute(SchedulableContext context) {
        
        Datetime oneHourPluse = Datetime.now().addHours(2);
        Datetime currentTime = Datetime.now();
        
        List<Bid_line_item__c> listbidLineDueisgreate = new List<Bid_Line_Item__c>([select id,Status__C ,Due_Date__c, Quote_Type__c, NO_Quote_Reason__c, Bid_Supplier__c, Bid_Supplier__r.Email_Address__c, Lead__c, Lead__r.Email_Address__c, CreatedDate
                                                                                    from Bid_line_item__c 
                                                                                    WHERE Due_Date__c <= :oneHourPluse AND Due_Date__c > :currentTime    ]);
        Map<Id,Bid_LIne_Item__c> mapBidLineUpda = new Map<Id,Bid_LIne_Item__c>();
        For (Bid_line_item__c bidLineVar : listbidLineDueisgreate  ) {
            If (bidLineVar.Status__C == 'New'  ) {
                bidLineVar.Quote_Type__c = 'No Quote';
                bidLineVar.NO_Quote_Reason__c = 'Supplier POC Missing';
            }
            else if (bidLineVar.Status__C == 'Sent to Supplier'){
                //finding the diff bw createddate and today date
                date d=date.valueof(bidLineVar.CreatedDate);
                integer createdAgo=d.daysBetween(date.today());
                bidLineVar.Quote_Type__c = 'No Quote';
                if(bidLineVar.lead__c!=null && createdAgo<=10){
                    bidLineVar.NO_Quote_Reason__c  ='New Supplier Did not Provide Quote';
                }
                else{
                    bidLineVar.NO_Quote_Reason__c = 'Supplier Did Not Response';
                    
                }                
            }
            else if (bidLineVar.Status__C == 'Supplier Responded'){
                bidLineVar.Quote_Type__c = 'No Quote';
                bidLineVar.NO_Quote_Reason__c = 'Missing Information';
            }
            
            /*   If (bidLineVar.Unit_Cost__c == null  ) {
bidLineVar.Quote_Type__c = 'No Quote';
if (bidLineVar.Bid_Supplier__c != null ) {
If (String.isBlank( bidLineVar.NO_Quote_Reason__c)) {
bidLineVar.NO_Quote_Reason__c = 'Supplier Did Not Response';

} else {
If (!bidLineVar.NO_Quote_Reason__c.contains('Supplier Did Not Response')){
bidLineVar.NO_Quote_Reason__c= bidLineVar.NO_Quote_Reason__c+';Supplier Did Not Response';
}
}
If (bidLineVar.Bid_Supplier__r.Email_Address__c != null ) {
bidLineVar.NO_Quote_Reason__c = bidLineVar.NO_Quote_Reason__c+'Supplier POC Missing';
}

} else {
If (String.isBlank( bidLineVar.NO_Quote_Reason__c)) {
bidLineVar.NO_Quote_Reason__c = 'New Supplier Did not Provide Quote';

} else {
If (!bidLineVar.NO_Quote_Reason__c.contains('New Supplier Did not Provide Quote')){
bidLineVar.NO_Quote_Reason__c = bidLineVar.NO_Quote_Reason__c+';New Supplier Did not Provide Quote';
}

}
If (bidLineVar.Lead__r.Email_Address__c != null ) {
bidLineVar.NO_Quote_Reason__c = bidLineVar.NO_Quote_Reason__c+'Supplier POC Missing';
}


} */
            mapBidLineUpda.put(bidLineVar.id, bidLineVar);
            
            
        }
        If(!mapBidLineUpda.isEmpty()) {
            Update mapBidLineUpda.values();
        }
        
    }
}