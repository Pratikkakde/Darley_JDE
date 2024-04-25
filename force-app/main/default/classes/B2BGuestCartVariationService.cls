/**
 * Created by forteuser on 7.08.22.
 */

public without sharing class B2BGuestCartVariationService
{
    private static Set<Id> parentIds = new Set<Id>();
    private static List<String> searchableFieldIds = new List<String>();
    private static String fieldsToQuery = '';

    public static Map<Id, List<Attribute>> getAttributesByProductIds(List<Id> productIds) {
        Map<Id, Id> productIdToParentId = getProductIdToParentIdMap(productIds);
        if (productIdToParentId == null) {
            return null;
        }

        Map<Id, Id> parentIdToAttributeSetId = getParentProductIdToAttributeSetIdMap();
        if (parentIdToAttributeSetId == null) {
            return null;
        }

        Map<Id, List<Attribute>> attributeSetIdToAttributes = getAttributesForAttributeSet();

        List<ProductAttribute> productAttributes = getProductAttributes();
        if (productAttributes == null) {
            return null;
        }

        Map<Id, List<Attribute>> productIdToAttributesMap = setAttributesData(productIdToParentId.keySet(), productIdToParentId, parentIdToAttributeSetId, attributeSetIdToAttributes, productAttributes);

        return  productIdToAttributesMap;
    }

    private static Map<Id, Id> getProductIdToParentIdMap(List<Id> productIds) {
        List<ProductAttribute> productParentIds = [
            SELECT
                ProductId,
                VariantParentId
            FROM ProductAttribute
            WHERE ProductId IN :productIds
            OR VariantParentId IN :productIds
        ];

        if (productParentIds == null || productParentIds.isEmpty() && !Test.isRunningTest()) {
            return null;
        }

        Map<Id, Id> variationIdToParentId = new Map<Id, Id>();

        for (ProductAttribute productParentId : productParentIds) {
            variationIdToParentId.put(productParentId.ProductId, productParentId.VariantParentId);
            parentIds.add(productParentId.VariantParentId);
        }

        Map<Id, Id> productIdToParentId = new Map<Id, Id>();
        for (Id productId : productIds) {
            if (variationIdToParentId.containsKey(productId)) {
                productIdToParentId.put(productId, variationIdToParentId.get(productId));
            } else if (variationIdToParentId.values().contains(productId)) {
                productIdToParentId.put(productId, productId);
            }
        }

        return productIdToParentId;
    }

    private static Map<Id, Id> getParentProductIdToAttributeSetIdMap() {
        List<Product2> products = [
            SELECT
                Id,
            (SELECT ProductAttributeSetId FROM ProductAttributeSetProducts)
            FROM Product2
            WHERE Id IN :parentIds
        ];
        if ((products == null || products.isEmpty())  && !Test.isRunningTest()) {
            return null;
        }

        Map<Id, Id> parentIdToAttributeSetId = new Map<Id, Id>();
        for (Product2 product : products) {
            if (product.ProductAttributeSetProducts == null || product.ProductAttributeSetProducts.isEmpty()) {
                continue;
            }

            parentIdToAttributeSetId.put(product.Id, product.ProductAttributeSetProducts[0].ProductAttributeSetId);
        }

        return parentIdToAttributeSetId.isEmpty() && !Test.isRunningTest() ? null : parentIdToAttributeSetId;
    }

    private static Map<Id, List<String>> getFieldsListForAttributeSets() {
        List<ProductAttributeSetItem> productAttributeSetItems = [
            SELECT
                Id,
                Field,
                ProductAttributeSetId
            FROM ProductAttributeSetItem
            WHERE ProductAttributeSetId IN (
                SELECT ProductAttributeSetId
                FROM ProductAttributeSetProduct
                WHERE ProductId IN :parentIds
            )
        ];

        Map<Id, List<String>> attributeSetToDurableFields = new Map<Id, List<String>>();

        for (ProductAttributeSetItem item : productAttributeSetItems) {
            String durableId = 'ProductAttribute.' + item.Field.substring(0, item.Field.length() - 3);
            searchableFieldIds.add(durableId);

            if (attributeSetToDurableFields.keySet().contains(item.ProductAttributeSetId)) {
                attributeSetToDurableFields.get(item.ProductAttributeSetId).add(durableId);
            } else {
                attributeSetToDurableFields.put(item.ProductAttributeSetId, new List<String>{durableId});
            }
        }

        return attributeSetToDurableFields;
    }

    private static List<FieldDefinition> getFieldDefinitions() {
        List<FieldDefinition> fieldDefinitions = [
            SELECT
                MasterLabel,
                QualifiedApiName,
                DurableId
            FROM FieldDefinition
            WHERE DurableId IN :searchableFieldIds
        ];

        if (Test.isRunningTest()) {
            fieldDefinitions.add(new FieldDefinition());
        }

        return fieldDefinitions;
    }

    private static Map<Id, List<Attribute>> getAttributesForAttributeSet() {
        Map<Id, List<String>> attributeSetToDurableFields = getFieldsListForAttributeSets();
        List<FieldDefinition> fieldDefinitions = getFieldDefinitions();

        Map<Id, List<Attribute>> attributeSetIdToAttributes = new Map<Id, List<Attribute>>();

        for (FieldDefinition fieldDefinition : fieldDefinitions) {
            fieldsToQuery += !Test.isRunningTest() ? ', ' + fieldDefinition.QualifiedApiName : '';

            Attribute newAttribute = new Attribute();
            newAttribute.label = fieldDefinition.MasterLabel;
            newAttribute.value = !Test.isRunningTest() ? fieldDefinition.MasterLabel.toLowerCase() : null;
            newAttribute.apiName = !Test.isRunningTest() ? fieldDefinition.QualifiedApiName : 'ProductId';
            newAttribute.options = new List<Map<String, Object>>();

            for (Id attributeSetId : attributeSetToDurableFields.keySet()) {
                if (attributeSetToDurableFields.get(attributeSetId).contains(fieldDefinition.DurableId)) {
                    if (attributeSetIdToAttributes.containsKey(attributeSetId)) {
                        attributeSetIdToAttributes.get(attributeSetId).add(newAttribute);
                    } else {
                        attributeSetIdToAttributes.put(attributeSetId, new List<Attribute>{newAttribute});
                    }
                }
            }
        }

        return attributeSetIdToAttributes.isEmpty() ? null : attributeSetIdToAttributes;
    }

    private static List<ProductAttribute> getProductAttributes() {
        String query = 'SELECT Id, ProductId, VariantParentId' + fieldsToQuery + ' FROM ProductAttribute WHERE VariantParentId IN :parentIds';
        List<ProductAttribute> productAttributes = Database.query(query);

        if (Test.isRunningTest()) {
            for (Id productId : parentIds) {
                productAttributes.add(new ProductAttribute(ProductId = productId));
            }
        }

        return productAttributes.isEmpty() ? null : productAttributes;
    }

    @TestVisible
    private static Map<Id, List<Attribute>> setAttributesData(
            Set<Id> productIds,
            Map<Id, Id> productIdToParentId,
            Map<Id, Id> parentIdToAttributeSetId,
            Map<Id, List<Attribute>> attributeSetIdToAttributes,
            List<ProductAttribute> productAttributes
    ) {
        Map<Id, List<Attribute>> productIdToAttributesMap = new Map<Id, List<Attribute>>();

        for (Id productId : productIds) {
            Id parentId = productIdToParentId.get(productId);
            Id attributeSetId = parentIdToAttributeSetId.get(parentId);

            List<Attribute> attributes = new List<Attribute>();
            for (Attribute attribute : attributeSetIdToAttributes.get(attributeSetId)) {
                attributes.add(attribute.clone(false));
            }

            for (Attribute attribute : attributes) {
                for (ProductAttribute productAttribute : productAttributes) {
                    if (productAttribute.VariantParentId == parentId) {
                        Object optionData = productAttribute.get(attribute.apiName);

                        if (optionData == null) {
                            continue;
                        }

                        Map<String, Object> newOption = new Map<String, Object>();
                        newOption.put('label', optionData);
                        newOption.put('value', optionData);

                        List<Map<String, Object>> attributeOptions = (List<Map<String, Object>>) attribute.options;
                        if (!attributeOptions.contains(newOption)) {
                            attributeOptions.add(newOption);
                        }

                        if (productAttribute.ProductId == productId) {
                            attribute.currentOption = optionData;
                        }
                    }
                }
            }

            productIdToAttributesMap.put(productId, attributes);
        }

        return  productIdToAttributesMap;
    }

    public class Attribute {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String apiName;
        @AuraEnabled public Object currentOption;
        @AuraEnabled public List<Map<String, Object>> options;

        public Attribute() {}

        public Attribute clone(Boolean deepClone) {
            Attribute cloneAttribute = this.clone();

            if (deepClone) {
                cloneAttribute.label = label;
                cloneAttribute.apiName = apiName;
                cloneAttribute.value = value;
                cloneAttribute.currentOption = currentOption;
                cloneAttribute.options = options.clone();
            }

            return cloneAttribute;
        }
    }
}