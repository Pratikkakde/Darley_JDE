public without sharing class B2BProductDetailVariationController {
    public static final String CLASS_VARIATION_PARENT  = 'VariationParent';
    private static final String CLASS_VARIATION = 'Variation';
    private static final String PRODUCT_ATTRIBUTE_PREFIX = 'ProductAttribute.';

    private static Map<String,Schema.SObjectField> productAttributefields = Schema.ProductAttribute.SObjectType.getDescribe().fields.getMap();
    
    @auraEnabled
    public static B2BResponse getVariations(Id productId) {
        // POPULATE WRAPPER
        ProductDetailVariation productDetailVariation = new ProductDetailVariation();
        productDetailVariation.hasVariations = false;
        try{
            Product2 productDetail = getProductDetails(productId);
            //VALIDATE PARENT
            Id productIdToValidate = productDetail.ProductClass == CLASS_VARIATION_PARENT ? productDetail.Id :
                                        productDetail.ProductClass == CLASS_VARIATION ? getVariatParent(productId) : null ;
            if(productIdToValidate != null) {
                List<ProductAttributeSetProduct> productAttributeSetProducts = getProductAttributeSetProduct(productIdToValidate);
                if (!productAttributeSetProducts.isEmpty()) {                

                    List<ProductAttributeSetItem> productAttributeSetItems = getProductAttributeSetItems(productAttributeSetProducts.get(0).ProductAttributeSetId);
                    productDetailVariation.hasVariations = !productAttributeSetItems.isEmpty();
                    
                    List<String> durableIds = new List<String>();
                    List<String> fieldIds = new List<String>();
                    for(ProductAttributeSetItem prodAttributeSetItem: productAttributeSetItems) {
                        String fieldId = Id.valueOf(prodAttributeSetItem.Field).to15();
                        durableIds.add(PRODUCT_ATTRIBUTE_PREFIX + fieldId);
                        fieldIds.add(fieldId);
                    }

                    Map<String,String> fieldDefinitions = getfieldDefinitions(durableIds);
                    List<ProductAttribute> productAttributes = getProductAttributes(productIdToValidate, fieldDefinitions.values());
                    
                    List<Variation> variations = new List<Variation>();            
                    for(ProductAttributeSetItem prodAttributeSetItem: productAttributeSetItems) {
                        String fieldId = Id.valueOf(prodAttributeSetItem.Field).to15();
                        String fieldDeveloperName = fieldDefinitions.get(fieldId);
                        Schema.DescribeFieldResult fieldResult = productAttributefields.get(fieldDeveloperName).getDescribe();

                        //ADDING VARIATION
                        Variation variation = new Variation();
                        variation.fieldDeveloperName = fieldDeveloperName;
                        variation.fieldLabel = fieldResult.getLabel();
                        variation.order = prodAttributeSetItem.Sequence;
                        
                        //ADDING VALUES 
                        List<VariationPickList> values = new List<VariationPickList>();
                        for (ProductAttribute prodtAtt : productAttributes ){
                            VariationPickList variationPickList = new VariationPickList();
                            variationPickList.label = String.valueOf(prodtAtt.get(fieldDeveloperName));
                            variationPickList.value = String.valueOf(prodtAtt.get(fieldDeveloperName));
                            values.add(variationPickList);
                        }
                        variation.values = values;
                        variations.add(variation);
                    }

                    //ADDING DEPENDENCY
                    List<Map<String,Object>> dependencies = new List<Map<String,Object>>();
                    for (ProductAttribute prodtAtt : productAttributes ){
                        Map<String,Object> dependency = new  Map<String,Object>();
                        for (String fieldApiName: fieldDefinitions.values()){
                            dependency.put(fieldApiName, String.valueOf(prodtAtt.get(fieldApiName)));
                            dependency.put('productId',prodtAtt.ProductId);
                            dependency.put('default',productId == prodtAtt.ProductId);
                        }
                        dependencies.add(dependency);
                    }   
                
                    //fieldDefinitions
                    productDetailVariation.variations = variations;
                    productDetailVariation.dependencies = dependencies;
                }
            }

            return new B2BResponse(true, productDetailVariation, '');
        }catch( Exception e){
            return new B2BResponse(false, e.getMessage());
        }
    }

    private static Product2 getProductDetails(Id productId) {
        return [
            SELECT Id, ProductClass
            FROM Product2
            WHERE
            Id =: productId
        ];
    }

    private static Id getVariatParent(Id productId) {
        List<ProductAttribute> productAttributes = [SELECT VariantParentId FROM ProductAttribute WHERE ProductId =: productId ];
        Id parentId = !productAttributes.isEmpty() ? productAttributes.get(0).VariantParentId : null;
        return parentId;
    }

    private static List<ProductAttributeSetProduct> getProductAttributeSetProduct(Id productId) {
        return [
            SELECT Id, Name, ProductAttributeSetId, ProductId, Product.Name 
            FROM ProductAttributeSetProduct
            WHERE ProductId =: productId
        ];
    }

    private static List<ProductAttributeSetItem> getProductAttributeSetItems(Id productAttributeSetId) {
        return [
            SELECT Id, ProductAttributeSetId, Field, Sequence
            FROM ProductAttributeSetItem
            WHERE ProductAttributeSetId =: productAttributeSetId ORDER BY Sequence ASC
        ];
    }

    private static Map<String,String> getFieldDefinitions(List<String> durableIds) {
        Map<String,String> fields = new Map<String,String> ();
        for(FieldDefinition fieldDef: [SELECT QualifiedApiName, DurableId FROM FieldDefinition 
                                        WHERE DurableId  IN: durableIds AND EntityDefinition.QualifiedApiName = 'ProductAttribute']){
            String fieldId = fieldDef.DurableId.replace(PRODUCT_ATTRIBUTE_PREFIX,'');
            fields.put(fieldId ,fieldDef.QualifiedApiName);
        }
        return fields;
    }
 
    private static List<ProductAttribute> getProductAttributes(Id productId, List<String> fields) {
        fields.add('Id');
        fields.add('Name');
        fields.add('ProductId');
        fields.add('Product.Name');
        fields.add('Product.ProductClass');
        fields.add('VariantParentId');
        fields.add('VariantParent.ProductClass');
        fields.add('Sequence');

        return  (List<ProductAttribute>) Database.query('SELECT '+  String.join(fields,',') +' FROM ProductAttribute WHERE VariantParentId = \''+productId+'\' AND Product.IsActive = TRUE');
    }

    public class ProductDetailVariation{
        @auraEnabled public boolean hasVariations{get;set;}
        @auraEnabled public List<Variation> variations{get;set;}
        @auraEnabled public List<Map<String,Object>> dependencies{get;set;}
    }

    public class Variation {
        @auraEnabled public String fieldDeveloperName{get;set;} //Size__c
        @auraEnabled public String fieldLabel{get;set;} //Size
        @auraEnabled public Integer order{get;set;} //0
        @auraEnabled public List<VariationPickList> values{get;set;}
    }

    public class VariationPickList {
        @auraEnabled public String label;   //S
        @auraEnabled public String value;   //S
    }
}