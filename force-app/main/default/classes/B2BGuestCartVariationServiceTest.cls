/**
 * Created by IrinaSakovich on 9.08.22.
 */

@IsTest
public with sharing class B2BGuestCartVariationServiceTest {

    @IsTest
    public static void checkSettingAttributesData() {
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initGuestUserData();
        User user = (User)testData.get(B2BGuestCheckoutDefaultTestData.GUEST_USER);

        Set<Id> productIds = new Set<Id>{'01t7F000009xyHRQAY', '01t7F000009xyHVQAY', '01t7F000009xyHaQAI'};
        Map<Id, Id> productIdToParentId = new Map<Id, Id>{
            '01t7F000009xyHRQAY'=>'01t7F000009xyHQQAY',
            '01t7F000009xyHVQAY'=>'01t7F000009xyHQQAY',
            '01t7F000009xyHaQAI'=>'01t7F000009xyHQQAY'
        };
        Map<Id, Id> parentIdToAttributeSetId = new Map<Id,Id>{'01t7F000009xyHQQAY'=>'0iY7F0000004C93UAE'};
        Map<Id, List<B2BGuestCartVariationService.Attribute>> attributeSetIdToAttributes = new Map<Id, List<B2BGuestCartVariationService.Attribute>>{
            '0iY7F0000004C93UAE' => (List<B2BGuestCartVariationService.Attribute>)JSON.deserialize(
                '[{"apiName":"Name", "currentOption":null, "label":"Color", "options":[], "value":"color"}]',
                List<B2BGuestCartVariationService.Attribute>.class
            )
        };
        List<ProductAttribute> productAttributes = (List<ProductAttribute>)JSON.deserialize(
            '[{"Id":"0iU7F0000000006UAA", "ProductId":"01t7F000009xyHRQAY", "VariantParentId":"01t7F000009xyHQQAY", "Name":"White"}, '+
                '{"Id":"0iU7F0000000001UAA", "ProductId":"01t7F000009xyHVQAY", "VariantParentId":"01t7F000009xyHQQAY", "Name":"Black"}, ' +
                '{"Id":"0iU7F000000000BUAQ", "ProductId":"01t7F000009xyHaQAI", "VariantParentId":"01t7F000009xyHQQAY", "Name":"Silver"}]',
            List<ProductAttribute>.class
        );

        Map<Id, List<B2BGuestCartVariationService.Attribute>> attributes;
        System.runAs(user) {
            attributes = B2BGuestCartVariationService.setAttributesData(productIds, productIdToParentId, parentIdToAttributeSetId, attributeSetIdToAttributes, productAttributes);
        }

        System.assertEquals(false, attributes == null);
        System.assertEquals(3, attributes.keySet().size());
    }

    @IsTest
    public static void checkGettingAttributes() {
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initGuestUserData();
        User user = (User)testData.get(B2BGuestCheckoutDefaultTestData.GUEST_USER);

        Product2 testParentProduct = new Product2(
                Name = 'Parent Product',
                IsActive = true,
                ProductCode = 'PARENT-CODE',
                Type = 'Base'
        );

        Product2 testChildProduct = new Product2(
                Name = 'Test Product',
                IsActive = true,
                ProductCode = 'CHILD-CODE'
        );
        insert new List<Product2> { testParentProduct, testChildProduct };

        ProductAttributeSet productAttributeSet = [
                SELECT Id, DeveloperName
                FROM ProductAttributeSet
                WHERE DeveloperName = 'AS_ColorSize'
        ];

        ProductAttributeSetProduct prodAttrSetProd = new ProductAttributeSetProduct(
                ProductAttributeSetId = productAttributeSet.Id,
                ProductId = testParentProduct.Id
        );
        insert prodAttrSetProd;

        ProductAttribute prodAttr = new ProductAttribute(
                ProductId = testChildProduct.Id,
                VariantParentId = testParentProduct.Id,
                Color__c = 'Blue',
                Size__c = 'L'
        );
        insert prodAttr;

        Map<Id, List<B2BGuestCartVariationService.Attribute>> attributes;

        System.runAs(user) {
            attributes = B2BGuestCartVariationService.getAttributesByProductIds(new List<Id> { testParentProduct.Id });
        }

        System.assert(attributes != null, 'Attributes are empty.');
        System.assertEquals(1, attributes.keySet().size());
    }

}