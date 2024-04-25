public without sharing class B2BQuoteManagementController {

    private static final String SOMETHING_WENT_WRONG_MESSAGE = System.Label.Something_Went_Wrong_Please_contact_your_System_Administrator;
    private static final String SORT_FIELD_DEFAULT = 'CreatedDate';
    private static final String SORT_ORDER_DEFAULT = 'DESC';

    @AuraEnabled
    public static B2BResponse getCartItem(Id cartId) {
        try {
            List<Id> prodIds = new List<Id>();
            for (CartItem rec : [SELECT Id, Product2Id FROM CartItem WHERE CartId = :cartId]) {
                prodIds.add(rec.Product2Id);
            }

            List<Id> listActiveProducts = new List<Id>();
            List<Product2> listProd = [
                SELECT Id, Name, Type, ProductClass,
                    (
                        SELECT Id,
                            ProductId,
                            VariantParentId
                        FROM ProductAttributes
                    ),
                    (
                        SELECT Id 
                        FROM ProductCategoryProducts
                    ),
                    (
                        SELECT Id 
                        FROM CommerceEntitlementProducts 
                        WHERE Policy.IsActive = TRUE AND Policy.CanViewProduct = TRUE
                    )
                FROM Product2
                WHERE Id IN :prodIds AND IsActive = TRUE
            ];

            Map<Id, Id> variationProducts = new Map<Id, Id>();
            for (Product2 rec : listProd) {
                if (rec.ProductClass == 'Variation') {
                    for (ProductAttribute atrRec : rec.ProductAttributes) {
                        variationProducts.put(atrRec.ProductId, atrRec.VariantParentId);
                    }
                } else if (rec.ProductCategoryProducts.size() > 0 && rec.CommerceEntitlementProducts.size() > 0) {
                    listActiveProducts.add(rec.Id);
                }
            }

            if (!variationProducts.isEmpty()) {
                Map<Id, Product2> mapIdToProduct = new Map<Id, Product2>([
                    SELECT Id, Name, Type, ProductClass,
                        (
                            SELECT Id 
                            FROM ProductCategoryProducts
                        ),
                        (
                            SELECT Id 
                            FROM CommerceEntitlementProducts 
                            WHERE Policy.IsActive = TRUE AND Policy.CanViewProduct = TRUE
                        )
                    FROM Product2
                    WHERE Id IN :variationProducts.values() AND IsActive = TRUE
                ]);

                for (Id varProdId : variationProducts.keySet()) {
                    Id ParentProductId = variationProducts.get(varProdId);
                    if (mapIdToProduct.containsKey(ParentProductId)) {
                        Product2 parentProd = mapIdToProduct.get(ParentProductId);
                        if (parentProd.ProductCategoryProducts.size() > 0 && parentProd.CommerceEntitlementProducts.size() > 0) {
                            listActiveProducts.add(varProdId);
                        }
                    }
                }
            }

            List<CartItem> cartItems = [
                SELECT Id, Product2Id, Quantity, SalesPrice 
                FROM CartItem 
                WHERE CartId = :cartId AND Product2Id IN :listActiveProducts
            ];

            return new B2BResponse(true, cartItems, 'Success');
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage() + ' ' + e.getLineNumber(), SOMETHING_WENT_WRONG_MESSAGE);
        }
    }

    @AuraEnabled
    public static B2BResponse createQuote(Id cartId, Id accountId, String comment) {
        try {
            User currentUser = getCurrentUserInfo();

            List<CartItem> listCartItems = [
                SELECT Id, Product2Id, Quantity, SalesPrice
                FROM CartItem
                WHERE CartId = :cartId
            ];

            Quote__c quote = new Quote__c(
                Contact__c = currentUser.ContactId,
                Account__c = accountId,
                Status__c = 'Pending',
                DateRequested__c = Date.today(),
                Description__c = comment
            );
            insert quote;

            List<QuoteItem__c> listQuoteItem = new List<QuoteItem__c>();

            B2BResponse cartItemResult = getCartItem(cartId);
            if (cartItemResult.isSuccess) {
                List<CartItem> listCartItem = (List<CartItem>)cartItemResult.responseData;
                for (CartItem rec : listCartItem) {
                    QuoteItem__c quoteItem = new QuoteItem__c(
                        UnitPrice__c = rec.SalesPrice,
                        OriginalPrice__c = rec.SalesPrice,
                        Product__c = rec.Product2Id,
                        Quantity__c = rec.Quantity,
                        Quote__c = quote.Id
                    );

                    listQuoteItem.add(quoteItem);
                }

                if (!listQuoteItem.isEmpty()) {
                    insert listQuoteItem;
                }

                quote = [SELECT Id, Name FROM Quote__c WHERE Id = :quote.Id];

                return new B2BResponse(true, new Map<String, String>{'id' => quote.Id, 'name' => quote.Name}, 'Success');
            } else {
                return new B2BResponse(false, cartItemResult.responseMessage);
            }
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage() + ' ' + e.getLineNumber(), SOMETHING_WENT_WRONG_MESSAGE);
        }
    }

    @AuraEnabled
    public static B2BResponse initFilter(Id accountId) {
        try {
            B2BResponse resultResponse = getQuotes(new FilterDto(accountId));
            
            if (resultResponse.isSuccess) {
                List<Quote__c> listQuotes = (List<Quote__c>)resultResponse.responseData;

                return new B2BResponse(
                    true, 
                    new Map<String, Object> {
                        'statusOptions' => getStatusOptions(),
                        'quotes' => listQuotes
                    },
                    'Success'
                );
            } else {
                return new B2BResponse(false, resultResponse.responseMessage);
            }
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage() + ' ' + e.getLineNumber(), SOMETHING_WENT_WRONG_MESSAGE);
        }
    }

    @AuraEnabled
    public static B2BResponse getQuotes(FilterDto filter) {
        try {
            filter.checkStatus();
            String accountId = filter.accountId;
            Boolean isB2BSuperUser = isB2BSuperUser();

            String query =
            'SELECT Id, Name, DateRequested__c, ExpirationDate__c, Status__c, Estimated_Quote_Total__c ' +
            'FROM Quote__c ' +
            'WHERE Contact__r.AccountId =: accountId';

            List<User> storeUser = [
                SELECT ContactId 
                FROM User 
                WHERE Id = :UserInfo.getUserId()
            ];
            String contactId = storeUser[0].ContactId;

            if (!isB2BSuperUser) {
                query += ' AND Contact__c =: contactId';
            }

            if (String.isNotBlank(filter.search)) {
                String toSearch = '%' + String.escapeSingleQuotes(filter.search) + '%';
                query += ' AND (Name LIKE: toSearch)';
            }

            if (String.isNotBlank(filter.status)) {
                query += ' AND Status__c = \'' + filter.status + '\' ';
            }

            String fieldCondition =  ' AND DateRequested__c';

            if (filter.dateFrom != null) {
                query += fieldCondition + ' >= ' + filter.dateFrom;
            }

            if (filter.dateTo != null) {
                query += fieldCondition + ' <= ' + filter.dateTo;
            }

            if (String.isNotBlank(filter.sortValue) && String.isNotBlank(filter.sortType)) {
                if (filter.sortValue == 'DateRequested__c') {
                    filter.sortValue = 'CreatedDate';
                }
                query += ' ORDER BY ' + filter.sortValue + ' ' + filter.sortType + ' NULLS LAST';
            }

            query += ' LIMIT 50000';

            List<Quote__c> listQuotes = Database.query(query);

            return new B2BResponse(true, listQuotes, 'Success');
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage() + ' ' + e.getLineNumber(), SOMETHING_WENT_WRONG_MESSAGE);
        }
    }

    private static User getCurrentUserInfo() {
        List<User> users = [
            SELECT
                Id,
                Name,
                Email,
                ContactId,
                AccountId,
                Account.Name,
                Contact.Name
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];

        return users.isEmpty()
            ? null
            : users[0];
    }

    private static List<B2BUtils.PicklistEntry> getStatusOptions() {
        List<B2BUtils.PicklistEntry> entries = new List<B2BUtils.PicklistEntry>{
            new B2BUtils.PicklistEntry(Label.B2B_Status_All, Label.B2B_Status_All)
        };

        String orderObjectName = Quote__c.SObjectType.getDescribe().getName();
        String orderStatusFieldName = Quote__c.Status__c.getDescribe().getName();
        entries.addAll(B2BUtils.getPicklistValues(orderObjectName, orderStatusFieldName));

        return entries;
    }

    public class FilterDto {
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String sortValue { get; set; }
        @AuraEnabled public String sortType { get; set; }
        @AuraEnabled public String search { get; set; }
        @AuraEnabled public String dateTo { get; set; }
        @AuraEnabled public String dateFrom { get; set; }
        @AuraEnabled public String accountId { get; set; }

        public FilterDto() {}

        public FilterDto(Id accountId) {
            this.accountId = accountId;
            this.sortValue = SORT_FIELD_DEFAULT;
            this.sortType = SORT_ORDER_DEFAULT;
        }

        public void checkStatus() {
            this.status = this.status == Label.B2B_Status_All ? null : this.status;
        }
    }

    private static Boolean isB2BSuperUser() {
        List<PermissionSetAssignment> psAssignments = [
            SELECT Id
            FROM PermissionSetAssignment
            WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = 'B2B_Commerce_Super_User'
        ];

        return !psAssignments.isEmpty();
    }
}