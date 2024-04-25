/**
 * Created by IrinaSakovich on 30/11/2022.
 */

public without sharing class B2BQuickOrderProductService {
    public static Map<String, ProductQuantityRule> getProductSkuQuantityRuleMap(Set<String> validSKUs) {
        Map<String, ProductQuantityRule> productRuleMap = new Map<String, ProductQuantityRule>();
        List<ProductQuantityRule> productRules = [
            SELECT
                Id,
                Product.StockKeepingUnit,
                PurchaseQuantityRuleId,
                PurchaseQuantityRule.Minimum,
                PurchaseQuantityRule.Maximum,
                PurchaseQuantityRule.Increment
            FROM ProductQuantityRule
            WHERE Product.StockKeepingUnit IN :validSKUs AND IsDeleted = FALSE
        ];

        for (ProductQuantityRule rule : productRules) {
            productRuleMap.put(rule.Product.StockKeepingUnit.toLowerCase(), rule);
        }

        return productRuleMap;
    }

    public static Set<Id> getListOfEntitlementPoliciesOfAccount(String accountId) {
        Set<Id> buyerGroups = new Set<Id>();
        Set<Id> policyIds = new Set<Id>();

        List<BuyerGroupMember> buyerGroupMembers = [
            SELECT Id, BuyerGroupId
            FROM BuyerGroupMember
            WHERE BuyerId = :accountId
        ];

        for (BuyerGroupMember item : buyerGroupMembers) {
            buyerGroups.add(item.BuyerGroupId);
        }

        if (buyerGroups.isEmpty()) {
            return policyIds;
        }

        List<CommerceEntitlementBuyerGroup> commerceEntitlementBuyerGroups = [
            SELECT Id, PolicyId
            FROM CommerceEntitlementBuyerGroup
            WHERE BuyerGroupId IN :buyerGroups
        ];

        for (CommerceEntitlementBuyerGroup item : commerceEntitlementBuyerGroups) {
            policyIds.add(item.PolicyId);
        }

        return policyIds;
    }

    public static Map<Id, List<Id>> getEntitlementPoliciesByProductMap (Set<Id> productIds) {
        List<CommerceEntitlementProduct> commerceEntitlementProducts = [
            SELECT
                Id,
                ProductId,
                PolicyId
            FROM CommerceEntitlementProduct
            WHERE ProductId IN :productIds AND Policy.IsActive = true
        ];

        Map<Id, List<Id>> policiesByProductMap = new Map<Id, List<Id>>();

        for (CommerceEntitlementProduct item : commerceEntitlementProducts) {
            if (policiesByProductMap.get(item.ProductId) == null) {
                policiesByProductMap.put(item.ProductId, new List<Id>{item.PolicyId});
            } else {
                policiesByProductMap.get(item.ProductId).add(item.PolicyId);
            }
        }

        return policiesByProductMap;
    }

    public static Set<Id> getAvailableProductIds(Set<Id> policiesByAccount, Map<Id, List<Id>> policiesByProduct) {
        Set<Id> productAvailableByPolicy = new Set<Id>();

        //first step - check availability by Entitlement policy
        for (Id productId : policiesByProduct.keySet()) {
            for (Id policyId : policiesByProduct.get(productId)) {
                if (policiesByAccount.contains(policyId)) {
                    productAvailableByPolicy.add(productId);
                    break;
                }
            }
        }

        //second step - check availability by assigment to the category
        return getAvailableProductIdsFromCategories(productAvailableByPolicy);
    }

    public static Set<Id> getAvailableProductIdsFromCategories(Set<Id> productIds) {
        //second step - check availability by assigment to the category
        Set<Id> availableProductIds = new Set<Id>();

        Set<Id> relatedToCategoryProduct = new Set<Id>();
        Map<Id, Set<Id>> parentVariantMap = new Map<Id, Set<Id>>();

        List<ProductAttribute> productAttributes = [
            SELECT Id, ProductId, VariantParentId
            FROM ProductAttribute
            WHERE ProductId IN :productIds
        ];

        if (productAttributes.size() > 0) {
            for (ProductAttribute productAttribute : productAttributes) {
                if (productIds.contains(productAttribute.ProductId)) {
                    if (parentVariantMap.containsKey(productAttribute.VariantParentId)) {
                        parentVariantMap.get(productAttribute.VariantParentId).add(productAttribute.ProductId);
                    } else {
                        parentVariantMap.put(productAttribute.VariantParentId, new Set<Id>{productAttribute.ProductId});
                    }
                }
                if (productIds.contains(productAttribute.VariantParentId)) {
                    if (parentVariantMap.containsKey(productAttribute.VariantParentId)) {
                        parentVariantMap.get(productAttribute.VariantParentId).add(productAttribute.VariantParentId);
                    } else {
                        parentVariantMap.put(productAttribute.VariantParentId, new Set<Id>{productAttribute.VariantParentId});
                    }
                }

                productIds.add(productAttribute.VariantParentId);
            }
        }

        List<ProductCategoryProduct> relatedCategories = [
            SELECT Id, ProductId
            FROM ProductCategoryProduct
            WHERE ProductId IN :productIds
            AND ProductCategory.IsNavigational = TRUE
        ];

        for (ProductCategoryProduct item : relatedCategories) {
            relatedToCategoryProduct.add(item.ProductId);
        }

        for (String prodId : relatedToCategoryProduct) {
            if (parentVariantMap.containsKey(prodId)) {
                availableProductIds.addAll(parentVariantMap.get(prodId));
            } else {
                availableProductIds.add(prodId);
            }
        }

        return availableProductIds;
    }

    public static Map<Id, QtyRule> getProductsQtyRulesById(Set<Id> productIds) {
        Map<Id, QtyRule> qtyRulesMap = new Map<Id, QtyRule>();
        List<ProductQuantityRule> productQtyRules = [
            SELECT
                Id,
                Product.Id,
                PurchaseQuantityRuleId,
                PurchaseQuantityRule.Minimum,
                PurchaseQuantityRule.Maximum,
                PurchaseQuantityRule.Increment
            FROM ProductQuantityRule
            WHERE Product.Id IN :productIds AND IsDeleted = FALSE
        ];

        if (productQtyRules.isEmpty()) {
            return qtyRulesMap;
        }

        for (ProductQuantityRule productQuantityRule : productQtyRules) {
            qtyRulesMap.put(
                productQuantityRule.Product.Id,
                new QtyRule(
                    Integer.valueOf(productQuantityRule.PurchaseQuantityRule.Minimum),
                    Integer.valueOf(productQuantityRule.PurchaseQuantityRule.Maximum),
                    Integer.valueOf(productQuantityRule.PurchaseQuantityRule.Increment)
                )
            );
        }

        return qtyRulesMap;
    }

    public class ProductData {
        @AuraEnabled public String status;
        @AuraEnabled public String id;
        @AuraEnabled public String sku;
        @AuraEnabled public String name;
        @AuraEnabled public Integer quantity;
        @AuraEnabled public Integer finalQuantity;
        @AuraEnabled public String qtyTooltip;
        @AuraEnabled public String errorMsg;
        @AuraEnabled public QtyRule qtyRule;
    }

    public class QtyRule {
        QtyRule(Integer min, Integer max, Integer increment) {
            this.min = min;
            this.max = max;
            this.increment = increment;
        }

        @AuraEnabled public Integer min;
        @AuraEnabled public Integer max;
        @AuraEnabled public Integer increment;
    }
}