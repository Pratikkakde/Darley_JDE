/**
 * Created by IrinaSakovich on 29/11/2022.
 */

public without sharing class B2BQuickOrderController {
    @AuraEnabled
    public static B2BResponse getUserProfile() {
        try {
            return new B2BResponse(true, getCurrentUser()?.Profile.Name, 'Success');
        } catch (Exception ex) {
            return new B2BResponse(false, ex.getStackTraceString(), ex.getMessage());
        }
    }

    @AuraEnabled
    public static B2BResponse getSampleFileLink(String documentId) {
        try {
            List<ContentDistribution> contentDistributions = getContentDistributionByDocumentId(documentId);

            if (contentDistributions == null || contentDistributions.isEmpty()) {
                List<ContentVersion> files = [SELECT Id, Title FROM ContentVersion WHERE ContentDocumentId = :documentId];

                /* Creating ContentDistribution record */
                ContentDistribution contentDistribution = new ContentDistribution(
                    Name = files[0].Title,
                    ContentVersionId = files[0].Id,
                    PreferencesAllowViewInBrowser= true
                );
                insert contentDistribution;

                contentDistributions = getContentDistributionByDocumentId(documentId);
            }

            return new B2BResponse(true, contentDistributions[0].ContentDownloadUrl, '');
        } catch (Exception ex) {
            return new B2BResponse(false, ex.getStackTraceString(), ex.getMessage());
        }
    }

    @AuraEnabled
    public static B2BResponse parseUploadedCSV(String documentBody, String accountId) {
        List<B2BQuickOrderProductService.ProductData> parseCsvData;

        try {
            if (accountId == null) {
                User user = getCurrentUser();
                accountId = user.AccountId;
            }

            parseCsvData = B2BCsvUploadService.parseUploadedCSV(documentBody, accountId);

            if (parseCsvData == null) {
                return new B2BResponse(false);
            }
        } catch (B2BCsvUploadService.MaxRowsQtyException ex) {
            return new B2BResponse(false, 'MaxRowsQtyException', ex.getMessage());
        } catch (Exception ex) {
            return new B2BResponse(false, ex.getStackTraceString() + ex.getMessage(), '');
        }
        return new B2BResponse(true, parseCsvData, '');
    }

    @AuraEnabled
    public static B2BResponse submitQuickOrder(String products, String effectiveAccountId) {
        try {
            List<B2BQuickOrderProductService.ProductData> productDataList = (List<B2BQuickOrderProductService.ProductData>) JSON.deserialize(products, List<B2BQuickOrderProductService.ProductData>.class);
            if (productDataList.isEmpty()) {
                return new B2BResponse(false, 'Error');
            }

            Id webStoreId = B2BUtils.getStoreIdRelatedToCurrentUser();
            if (effectiveAccountId == null) {
                User user = getCurrentUser();
                effectiveAccountId = user.AccountId;
            }

            List<List<ConnectApi.BatchInput>> inputBatches = new List<List<ConnectApi.BatchInput>>();
            List<ConnectApi.BatchInput> inputs = new List<ConnectApi.BatchInput>();

            String shoppingCartId;
            if (!Test.isRunningTest()) {
                ConnectApi.CartSummary cartSummary = ConnectApi.CommerceCart.getOrCreateActiveCartSummary(
                    webStoreId, effectiveAccountId, 'active'
                );
                shoppingCartId = cartSummary.cartId;
            } else {
                shoppingCartId = [SELECT Id, AccountId, Status FROM WebCart LIMIT 1].Id;
            }

            List<B2BQuickOrderProductService.ProductData> productsList = excludeDuplicatesAndErrors(productDataList, shoppingCartId);
            Integer recordsProcessed = 0;
            for (B2BQuickOrderProductService.ProductData productData : productsList) {
                if (productData.status != 'error') {
                    ConnectApi.CartItemInput cartItemInput = new ConnectApi.CartItemInput();
                    cartItemInput.productId = productData.id;
                    cartItemInput.quantity = String.valueOf(productData.finalQuantity);
                    cartItemInput.type = ConnectApi.CartItemType.Product;
                    ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(cartItemInput);
                    inputs.add(batchInput);
                    Integer listLimit = recordsProcessed + inputs.size() == productsList.size() ? inputs.size() : 100;
                    if (inputs.size() == listLimit) {
                        inputBatches.add(inputs);
                        recordsProcessed += inputs.size();
                        inputs = new List<ConnectApi.BatchInput>();
                    }
                }
            }
            List<ConnectApi.BatchResult> addToCartResults;
            if (!Test.isRunningTest()) {
                if (inputBatches.isEmpty()) {
                    addToCartResults = ConnectApi.CommerceCart.addItemsToCart(webStoreId, effectiveAccountId, shoppingCartId, inputs);
                } else {
                    for (List<ConnectApi.BatchInput> inputBatch : inputBatches) {
                        addToCartResults = ConnectApi.CommerceCart.addItemsToCart(webStoreId, effectiveAccountId, shoppingCartId, inputBatch);
                    }
                }
            }

            if (addToCartResults[0].isSuccess) {
                //TODO: NEED TO FIND JavaScript EVENT TO REFRESH Cart Icon Counter. ResponseData with 1st Product in a Cart - temporary solution.
                Map<String, String> responseData = new Map<String, String>();
                responseData.put('cartId', shoppingCartId);
                responseData.putAll(getCartItemsData(shoppingCartId));

                return new B2BResponse(true, responseData, 'Success');
            } else {
                String errorMessage = addToCartResults[0].error.getMessage().containsIgnoreCase('cart size limit exceeded')
                    ? System.Label.B2B_Your_Cart_Is_Full
                    : addToCartResults[0].error.getMessage();

                return new B2BResponse(false, addToCartResults[0].error, errorMessage);
            }
        } catch (Exception ex) {
            return new B2BResponse(false, ex.getStackTraceString(), ex.getMessage());
        }

    }

    @TestVisible
    private static Map<String, String> getCartItemsData(String cartId) {
        Map<String, String> cartItemsData = new Map<String, String>();

        List<CartItem> cartItems = [
            SELECT Id, Product2Id, Quantity
            FROM CartItem
            WHERE CartId = :cartId
            AND Type = 'Product'
        ];

        if (cartItems.isEmpty() == false) {
            cartItemsData.put('cartItemId', cartItems[0].Id);
            cartItemsData.put('cartItemQuantity', String.valueOf(cartItems[0].Quantity));
        } else {
            cartItemsData.put('cartItemId', null);
            cartItemsData.put('cartItemQuantity', null);
        }

        return cartItemsData;
    }

    private static List<B2BQuickOrderProductService.ProductData> excludeDuplicatesAndErrors(List<B2BQuickOrderProductService.ProductData> productDataList, String shoppingCartId) {
        Map<Id, B2BQuickOrderProductService.ProductData> newProductData = new Map<Id, B2BQuickOrderProductService.ProductData>();
        if (productDataList == null || productDataList.isEmpty()) {
            return null;
        }

        Map<Id, CartItem> existedCartItems = getExistedCartItems(shoppingCartId);
        Map<Id, B2BQuickOrderProductService.QtyRule> qtyRules = B2BQuickOrderProductService.getProductsQtyRulesById(existedCartItems.keySet());

        for (B2BQuickOrderProductService.ProductData productItem : productDataList) {
            if (productItem.status == 'error') {
                continue;
            }

            if (newProductData.containsKey(productItem.id)) {
                newProductData.get(productItem.id).finalQuantity += productItem.finalQuantity;
            } else {
                newProductData.put(productItem.id, productItem);
            }

            CartItem existedItem = existedCartItems.get(productItem.id);
            B2BQuickOrderProductService.QtyRule qtyRule = qtyRules.get(productItem.id);

            if (existedItem != null && qtyRule != null) {
                Integer maxQtyToAdd = qtyRule.max - Integer.valueOf(existedItem.Quantity);
                B2BQuickOrderProductService.ProductData itemToChange = newProductData.get(productItem.id);
                itemToChange.finalQuantity = itemToChange.finalQuantity > maxQtyToAdd ? maxQtyToAdd : itemToChange.finalQuantity;
            }
        }

        return newProductData.values();
    }

    private static Map<Id, CartItem> getExistedCartItems(String shoppingCartId) {
        Map<Id, CartItem> existedItems = new Map<Id, CartItem>();
        List<CartItem> cartItems = [
            SELECT
                Product2Id,
                Quantity
            FROM CartItem
            WHERE CartId = :shoppingCartId
        ];

        if (cartItems == null || cartItems.isEmpty()) {
            return existedItems;
        }

        for (CartItem cartItem : cartItems) {
            existedItems.put(cartItem.Product2Id, cartItem);
        }

        return existedItems;
    }

    private static List<ContentDistribution> getContentDistributionByDocumentId(String documentId) {
        List<ContentDistribution> contentDistributions = [
            SELECT ContentDownloadUrl
            FROM ContentDistribution
            WHERE ContentDocumentId = :documentId
        ];

        return contentDistributions;
    }

    private static User currentUser;
    public static User getCurrentUser() {
        if (Test.isRunningTest() || currentUser == null) {
            List<User> currentUsers = [
                SELECT
                    AccountId, ContactId, Email, Profile.Name
                FROM User
                WHERE Id = :UserInfo.getUserId()
                LIMIT 1
            ];
            currentUser = currentUsers[0];
        }
        return currentUser;
    }
}