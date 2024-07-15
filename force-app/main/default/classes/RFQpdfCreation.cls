public class RFQpdfCreation {
    public List<Bid_Line_Item__c> recordList { get; set; }
    public String rfqNumber { get; set; }
    public Date todayDate { get; set; }
        public Id groupId { get; set; }

    public String bidLineId { get; set; }
    public DateTime beforeDueDate { get; set; }
    public string beforeDueDateString { get; set; }
    public Boolean hasSupplierUnitPrice { get; set; }
    public Boolean boolenStrign { get; set; }
    public String requestedDeliverDate { get; set; }
    public String deliverDestination { get; set; }
    public String supplierName {get; set;}
    
    
    public RFQpdfCreation() {
        boolenStrign= false;
        bidLineId = ApexPages.currentPage().getParameters().get('id');
        groupId=ApexPages.currentPage().getParameters().get('gid');
        System.debug('BidRecordId-->' + bidLineId);
        
        List<String> quoteNumberList = new List<String>();
        Set<ID> accountIdList = new Set<Id>();
        Id recordTypeId1 = Schema.SObjectType.Bid_Line_Item__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
        
        /*List<Bid_Line_Item__c> bidLineItemQuery = [SELECT Name, Id, Before_due_date__c, Bid_Supplier__c, Quote_Numbers__c, PEL_Price__c , Due_Date__c, Delivery_Address__c, City__c, ServiceNow_State__c,
                                                   ZIP_Postal_Code__c, Country__c,RFQ_Number__r.Record_Source__c,RFQ_Number__r.Due_Date__c,Lead__c,Lead__r.Name,PEL_Price_Cost__c
                                                   FROM Bid_Line_Item__c WHERE RecordTypeId = :recordTypeId1 AND Id = :bidLineId];*/
        List<Bid_Line_Item__c> bidLineItemQuery = new  List<Bid_Line_Item__c>();
        if(bidLineId!=null){
            bidLineItemQuery = [SELECT Name, Id, Before_due_date__c, Bid_Supplier__c, Quote_Numbers__c, PEL_Price__c , Due_Date__c, Delivery_Address__c, City__c, ServiceNow_State__c,
                                                   ZIP_Postal_Code__c, Country__c,RFQ_Number__r.Record_Source__c,RFQ_Number__r.Due_Date__c,Lead__c,Lead__r.Name,PEL_Price_Cost__c
                                                   FROM Bid_Line_Item__c WHERE RecordTypeId = :recordTypeId1 AND Id = :bidLineId];
        }
        else{
            
            bidLineItemQuery = [SELECT Name, Id, Before_due_date__c, Bid_Supplier__c, Quote_Numbers__c, PEL_Price__c , Due_Date__c, Delivery_Address__c, City__c, ServiceNow_State__c,
                                ZIP_Postal_Code__c, Country__c,RFQ_Number__r.Record_Source__c,RFQ_Number__r.Due_Date__c,Lead__c,Lead__r.Name,PEL_Price_Cost__c
                                FROM Bid_Line_Item__c WHERE   Bid_Group_Items__c =: groupId ];       
        }
            
        
        
        If(!bidLineItemQuery.isEmpty()){  
            system.debug('bidLineItemQuery zero index value'+bidLineItemQuery[0].Before_due_date__c);
            If(bidLineItemQuery[0].RFQ_Number__r.Due_Date__c!=null){  
                system.debug('the due date of the rfq is '+ bidLineItemQuery[0].RFQ_Number__r.Due_Date__c.format('MM/dd/yyyy'));
                Date beforeDueDate = (Date)bidLineItemQuery[0].get('Before_due_date__c');
                system.debug('beforeDueDate'+beforeDueDate);
                
                if (beforeDueDate != null) {
                    // Format the date
                    beforeDueDateString = Datetime.newInstance(beforeDueDate.year(), beforeDueDate.month(), beforeDueDate.day()).format('M/d/yyyy');
                    System.debug('Formatted Date: ' + beforeDueDateString);
                }
            }
        }
        for (Bid_Line_Item__c bidRecords : bidLineItemQuery) {
            quoteNumberList.add(bidRecords.Quote_Numbers__c);
            IF(bidRecords.Bid_Supplier__c!=null){
                accountIdList.add(bidRecords.Bid_Supplier__c);
                
            } else {
                accountIdList.add(bidRecords.Lead__c);
                
            }
            
            System.debug('Account Id-->' + accountIdList);
            System.debug('QuoteNumber-->' + quoteNumberList);
        }
        
        Id recordTypeId = Schema.SObjectType.Bid_Line_Item__c.getRecordTypeInfosByName().get('TLS').getRecordTypeId();
        //
        recordList = [SELECT Id, Line_Item_ID__c,country_of_origin__c, Name,	TAA_Compliant_if_applicable__c, Bid_Supplier__r.Name, Additional_Information__c, Quote_Numbers__c, Lead__c, Lead__r.Name, 
                      Item_Description__c, Quantity__c, Berry_Applies__c, RFQ_Number__r.Record_Source__c,City__c,Country__c,Supplier_Name_Text__c, PEL_Price_Cost__c,
                      Delivery_Address__c, RFID_Required__c, Requested_Delivery_Date__c, Ship_To_DoDAAC__c, Unit_of_Issue__c,Record_Source__c, ServiceNow_State__c,Lead__r.Company,
                      PEL_Price__c, Supplier_Part_Number__c, DoDAAC_Number_Text__c, Before_due_date__c ,ZIP_Postal_Code__c
                      FROM Bid_Line_Item__c WHERE RecordTypeId = :recordTypeId AND Quote_Numbers__c IN :quoteNumberList AND (Bid_Supplier__c IN :accountIdList OR Lead__c In :accountIdList) ORDER by Line_Item_ID__c ASC,Id ];
        system.debug('This is the size of the R#cord List'+recordList.size());
        If(!recordList.isEmpty()){
            rfqNumber = String.valueOf(recordList[0].Quote_Numbers__c);
            rfqNumber=rfqNumber.remove('RFQ');
            System.debug('RFQ Number-->' + rfqNumber);
            System.debug('List of Records that matches the Account-->' + recordList);
            for(Bid_Line_Item__c bidVar : recordList ){
                
                if(bidVar.Bid_Supplier__r.Name==Null){
                    supplierName=bidVar.Lead__r.Company;
                } else {
                    supplierName=bidVar.Bid_Supplier__r.Name;
                }
                
                String dateSrtr; 
                If(bidVar.RFQ_Number__r.Record_Source__c=='ServiceNow' && (bidVar.Delivery_Address__c!=null || bidVar.City__c!=null ||bidVar.ServiceNow_State__c!=null || bidVar.ZIP_Postal_Code__c!=null || bidVar.Country__c!=null)){
                    bidVar.Delivery_Address__c = bidVar.Delivery_Address__c+', '+bidVar.City__c+', '+bidVar.ServiceNow_State__c+', '+bidVar.ZIP_Postal_Code__c+', '+bidVar.Country__c;
                }
                
                if(bidVar.Requested_Delivery_Date__c!=null){
                Datetime myDatetime = Datetime.newInstance(bidVar.Requested_Delivery_Date__c, Time.newInstance(0, 0, 0, 0));
                system.debug('myDatetime-->'+ myDatetime);
                dateSrtr = myDatetime.format('M/d/yyyy');
                
                dateSrtr=dateSrtr.replace('-','/');
                requestedDeliverDate=dateSrtr;
                }
                if(bidvar.PEL_Price_Cost__c!=null){
                    boolenStrign=true; 
                }
                //boolenStrign.add(bidVar.PEL_Price__c) ;
                System.debug('boolenStrign-->' + boolenStrign);
            }
        }
        
        
        // Check if any record in recordList has a non-null Supplier value
        // hasSupplierUnitPrice = checkForSupplierPriceValue();
    }
    
    // Helper method to check for the presence of a non-null Supplier value in recordList
    /* public Boolean checkForSupplierPriceValue() {
If(recordList.size() > 0){  
for (Bid_Line_Item__c record : recordList) {
if (record.PEL_Price__c != null) {
return true;
}
}
}
return false;
*/
    
}