public without sharing class B2BOrdersSummaryController {

    @AuraEnabled
    public static Map<String, Object> initializeFilter(FilterDto filter) {
        return new Map<String, Object> {
            'storeStatusOptions' => getStatusOptions(),
            'orders' => getOrdersSummary(filter),
            'subAccountOptions' => getSubAccountOptions(filter.accountId)
        };
    }

    @AuraEnabled
    public static Map<String, Object> getOrderSummary(Id orderSummaryId) {
        List<OrderSummary> orderSummaries = [
            SELECT OrderNumber
            FROM OrderSummary
            WHERE Id = :orderSummaryId
        ];

        return new Map<String, Object> {
            'orderSummary' => orderSummaries.size() == 0 ? null : orderSummaries[0]
        };
    }

    @AuraEnabled
    public static List<OrderSummary> getOrdersSummary(FilterDto filter) {
        filter.checkStatus();
        String accountId = filter.accountId;
        Boolean isB2BSuperUser = isB2BSuperUser();
        String userId = UserInfo.getUserId();

        String query = 'SELECT Id, OrderNumber, AccountId, PoNumber, TotalAmount, OrderedDate, StoreStatus__c, B2BGrandTotal__c ' +
            'FROM OrderSummary ' +
            'WHERE AccountId =: accountId ';

        if (!isB2BSuperUser) {
            query += ' AND OwnerId =: userId';
        }

        if (String.isNotBlank(filter.search)) {
            String toSearch = '%' + String.escapeSingleQuotes(filter.search) + '%';
            query += ' AND (OrderNumber LIKE: toSearch OR PoNumber LIKE: toSearch)';
        }

        if (String.isNotBlank(filter.status)) {
            query += ' AND StoreStatus__c = \'' + filter.status + '\' ';
        }

        String dateCondition = '';
        String fieldCondition =  'AND DAY_ONLY(OrderedDate)';

        if ( filter.dateFrom != null) {
            dateCondition += ' ' + fieldCondition + ' >= ' + filter.dateFrom + ' ';
        }

        if (filter.dateTo != null) {
            dateCondition += ' ' + fieldCondition + ' <= ' + filter.dateTo + ' ';
        }

        if (String.isNotBlank(dateCondition)) {
            query += dateCondition;
        }

        if (String.isNotBlank(filter.sortValue) && String.isNotBlank(filter.sortType)) {
            query += ' ORDER BY ' + filter.sortValue + ' ' + filter.sortType + ' NULLS LAST ';
        }

        query += ' LIMIT 50000';

        return Database.query(query);
    }

    /**
    * Get options for Store Status field.
    * @return List of Picklist Entry records.
    */
    private static List<B2BUtils.PicklistEntry> getStatusOptions() {
        List<B2BUtils.PicklistEntry> entries = new List<B2BUtils.PicklistEntry>{
            new B2BUtils.PicklistEntry(Label.B2B_Status_All, Label.B2B_Status_All)
        };
        entries.addAll(B2BUtils.getPicklistValues('Order', 'StoreStatus__c'));
        return entries;
    }

    /**
    * Get options for Sub Accounts picklist.
    * @param accountId - parent Account Id value,
    * @return List of Picklist Entry records.
    */
    private static List<B2BUtils.PicklistEntry> getSubAccountOptions(Id accountId) {
        List<B2BUtils.PicklistEntry> entries = new List<B2BUtils.PicklistEntry> {
            new B2BUtils.PicklistEntry(Label.B2B_My_Orders, accountId.to15())
        };

        for (Account subAccount : [
            SELECT Id, AccountFullName__c
            FROM Account
            WHERE ParentId = :accountId
        ]) {
            entries.add(new B2BUtils.PicklistEntry(subAccount.AccountFullName__c, subAccount.Id.to15()));
        }

        return entries;
    }

    private static Boolean isB2BSuperUser() {
        List<PermissionSetAssignment> psAssignments = [
            SELECT Id
            FROM PermissionSetAssignment
            WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = 'B2B_Commerce_Super_User'
        ];

        return !psAssignments.isEmpty();
    }

    public class FilterDto {
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String sortValue { get; set; }
        @AuraEnabled public String sortType { get; set; }
        @AuraEnabled public String search { get; set; }
        @AuraEnabled public String dateTo { get; set; }
        @AuraEnabled public String dateFrom { get; set; }
        @AuraEnabled public String accountId { get; set; }

        public void checkStatus() {
            this.status = this.status == Label.B2B_Status_All ? null : this.status;
        }
    }

}