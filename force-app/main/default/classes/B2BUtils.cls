public without sharing class B2BUtils {
    private static final String COMMUNITY_USER_PROFILE_NAME = 'B2B Commerce User';
    private static final String COMMUNITY_USER_PERMISSION_SET_NAME = 'B2B_Commerce_User';
    public static final String PIMLY_USER_PERMISSION_SET_NAME= 'Pimly_User_External';

    public static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';

    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) {
            return '';
        }

        String validForBits = '';

        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');

            validForBits += bits;
        }

        return validForBits;
    }

    public static String decimalToBinary(Integer val) {
        String bits = '';

        while (val > 0) {
            Integer remainder = Math.mod(val, 2);

            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }

    public final static Map<String, List<Schema.PicklistEntry>> apexCache = new Map<String, List<Schema.PicklistEntry>>();

    /**
     * Retrieves picklist values for a given object and field
     * This method uses dynamic Apex and does not support record types.
     * @param objectName - Name of sObject.
     * @param fieldName - Name of field.
     * @return List of PicklistEntry records.
     * @throws System.InvalidParameterValueException if objectName or fieldName are invalid.
     */
    @AuraEnabled
    public static List<PicklistEntry> getPicklistValues(String objectName, String fieldName) {
        // Try to get entries from cache
        String cacheKey = objectName + '.' + fieldName;
        List<Schema.PicklistEntry> entries = apexCache.get(cacheKey);
        if (entries == null) {
            // Use dynamic Apex to get object description
            // Schema.describeSObjects throws System.InvalidParameterValueException if objectName is invalid
            Schema.DescribeSobjectResult objDescription = Schema.describeSObjects(new List<String>{ objectName })[0];
            // Retrieve field map and check that field exists
            Schema.SObjectField field = objDescription.fields.getMap().get(fieldName);
            if (field == null) {
                InvalidParameterValueException e = new InvalidParameterValueException('fieldName', fieldName);
                e.setMessage('Could not find field ' + fieldName + ' on object ' + objectName);
                throw e;
            }
            // Get picklist values
            entries = field.getDescribe().getPickListValues();
            // Exclude inactive picklist values
            entries = getActivePicklistEntries(entries);
            // Cache entries
            apexCache.put(cacheKey, entries);
        }

        Boolean valuesContainSubmmited = false;
        List<PicklistEntry> values = new List<PicklistEntry>();
        for (Schema.PicklistEntry entry : entries) {
            //This condition is relevant to the B2BOrdersSummaryController.get Status Options method, please do not remove.
            if (objectName == 'Order' && (entry.getValue() == 'Activated' || entry.getValue() == 'Web Hold')) {
                if (!valuesContainSubmmited) {
                    values.add(new PicklistEntry('Submitted', 'Submitted'));
                    valuesContainSubmmited = true;
                }
            } else {
                values.add(new PicklistEntry(entry.getLabel(), entry.getValue()));
            }
        }

        return values;
    }

    /**
     * Return active picklist entries.
     * @param entries - list of picklist entries.
     * @return List of Schema.PicklistEntry records.
     */
    private static List<Schema.PicklistEntry> getActivePicklistEntries( List<Schema.PicklistEntry> entries) {
        List<Schema.PicklistEntry> activeEntries = new List<Schema.PicklistEntry>();
        for (Schema.PicklistEntry entry : entries) {
            if (entry.isActive()) {
                activeEntries.add(entry);
            }
        }

        return activeEntries;
    }

    public virtual class CommonOption {
        @AuraEnabled public String label;
        @AuraEnabled public String value;

        public CommonOption (String label, String value) {
            this.label = label;
            this.value = value;
        }

        public CommonOption() {}
    }

    public class PicklistEntry extends CommonOption {
        public PicklistEntry(String label, String value) {
            super(label, value);
        }
    }

    public static Id getCommerceUserProfileId() {
        List<Profile> profiles = [
            SELECT Id
            FROM Profile
            WHERE Name = :COMMUNITY_USER_PROFILE_NAME
            LIMIT 1
        ];

        return profiles.isEmpty() ? null : profiles[0].Id;
    }

    public static Id getCommercePermissionSetId() {
        List<PermissionSet> permissionSets = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = :COMMUNITY_USER_PERMISSION_SET_NAME
            LIMIT 1
        ];

        return permissionSets.isEmpty() ? null : permissionSets[0].Id;
    }

    public static Id getPimlyPermissionSetId() {
        List<PermissionSet> permissionSets = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = :PIMLY_USER_PERMISSION_SET_NAME
            LIMIT 1
        ];

        return permissionSets.isEmpty() ? null : permissionSets[0].Id;
    }

    public static PermissionSetAssignment getPermissionSetAssignment(Id userId) {
        Id permissionSetId = B2BUtils.getCommercePermissionSetId();

        return new PermissionSetAssignment(
            PermissionSetId = permissionSetId,
            AssigneeId = userId
        );
    }

    public static PermissionSetAssignment getPimlyPermissionSetAssignment(Id userId) {
        Id permissionSetId = B2BUtils.getPimlyPermissionSetId();

        return new PermissionSetAssignment(
            PermissionSetId = permissionSetId,
            AssigneeId = userId
        );
    }

    public static String getStoreIdRelatedToCurrentUser() {
        String networkId = Network.getNetworkId();

        String webStoreQuery = 'SELECT';
        webStoreQuery += !Test.isRunningTest() ? ' WebStoreId FROM WebStoreNetwork WHERE NetworkId = :networkId ' : ' Id FROM WebStore ';
        webStoreQuery += 'LIMIT 1';

        List<sObject> webStoreData = Database.query(webStoreQuery);

        return webStoreData.isEmpty()
            ? null
            : (String) webStoreData[0].get(!Test.isRunningTest() ? 'WebStoreId' : 'Id');
    }

    public static void addProductsToCart(Map<String, String> productIdToQtyMap, String effectiveAccountId) {
        String webStoreId = getStoreIdRelatedToCurrentUser();

        List<ConnectApi.BatchInput> cartItems = new List<ConnectApi.BatchInput>();

        for (String productId : productIdToQtyMap.keySet()) {
            ConnectApi.CartItemInput cartInput = new ConnectApi.CartItemInput();
            cartInput.productId = productId;
            cartInput.quantity = productIdToQtyMap.get(productId);
            cartInput.type = ConnectApi.CartItemType.Product;
            cartItems.add(new ConnectApi.BatchInput(cartInput));
        }

        if (Test.isRunningTest() == false) {
            String cartId = ConnectApi.CommerceCart.getOrCreateActiveCartSummary(webStoreId, effectiveAccountId, 'active').cartId;
            ConnectApi.BatchResult[] batchResults = ConnectApi.CommerceCart.addItemsToCart(webStoreId, effectiveAccountId, cartId, cartItems);
        }
    }

    public static String getDefaultProductImageURLByProductId(String productId, String webStoreId) {
        ConnectApi.ProductDetail productDetail;
        String productImageUrl = '/img/b2b/default-product-image.svg';

        if (Test.isRunningTest()) {
            productDetail = new ConnectApi.ProductDetail();
            webStoreId = '0ZE7i000000GojhGAC';
        } else {
            productDetail = ConnectApi.CommerceCatalog.getProduct(webStoreId, productId, null, null, true, new List<String> {'productListImage'}, false, true, true);
            for (ConnectApi.ProductMediaGroup groupsmed : productDetail.mediaGroups) {
                if (groupsmed.usageType == ConnectApi.ProductMediaUsageType.Listing) {
                    for (ConnectApi.ProductMedia prodMedia : groupsmed.mediaItems) {
                        productImageUrl = prodMedia.url;
                    }
                    break;
                }
            }
        }

        return productImageUrl;
    }

    public static List<ConnectApi.PricingLineItemInput> getPricingLineItemInputs(Set<Id> productIds) {
        List<ConnectApi.PricingLineItemInput> pricingLineItemInputs = new List<ConnectApi.PricingLineItemInput>();

        for (String productId : productIds) {
            ConnectApi.PricingLineItemInput pricingLineItemInput = new ConnectApi.PricingLineItemInput();
            pricingLineItemInput.productId = productId;

            pricingLineItemInputs.add(pricingLineItemInput);
        }

        return pricingLineItemInputs;
    }

}