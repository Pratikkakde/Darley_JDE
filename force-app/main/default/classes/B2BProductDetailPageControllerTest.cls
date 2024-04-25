@IsTest
public class B2BProductDetailPageControllerTest {
    @TestSetup
    private static void makeData() {
        new B2BDefaultTestData().initAllData();
    }

    @IsTest
    static void getProductDetailsTest() {
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1 ];

        Test.startTest();
        System.runAs(communityUser) {
            B2BResponse resultResponse = B2BProductDetailPageController.getProductDetails(product.Id);
            System.assert(resultResponse.isSuccess,'Response must be success');
            
            B2BProductDetailPageController.ProductDetail productDetail =  (B2BProductDetailPageController.ProductDetail) resultResponse.responseData;
            System.assertEquals('TestId', productDetail.articles , 'The articles must be \'TestId\'');
            System.assertEquals('Shipping descriptions will be displayed late', productDetail.shippindDetails , 'The shippindDetails must be \'Shipping descriptions will be displayed late\'');
            System.assertEquals(1, productDetail.attachments.size() , 'The attachments size must be 1');
        }
        Test.stopTest();
    }

    public static ConnectApi.ProductDetail  mockConnectApiProductDetails(){
        ConnectApi.ProductDetail  productDetail = new ConnectApi.ProductDetail();
        productDetail.fields = new Map<String, String>{
            'FAQs__c' => null,
            'ShippingDetails__c' => 'Shipping descriptions will be displayed late',
            'Articles__c' => 'TestId'
        };

        ConnectApi.ProductMediaGroup  productMediaGroup = new ConnectApi.ProductMediaGroup();
        productMediaGroup.developerName = 'developerName';

        ConnectApi.ProductMedia productMedia = new ConnectApi.ProductMedia();
        productMedia.title = 'darleyFlyers';
        productMedia.url = '/cms/delivery/media/MC5RVOEB6JYFBVZGVV3HMFRISPME?recordId=01t0200000CJgfB&buyerId=00000000000000';
    
        productMediaGroup.mediaItems = new List<ConnectApi.ProductMedia>{productMedia};
        productDetail.mediaGroups = new List<ConnectApi.ProductMediaGroup>{productMediaGroup};
        return productDetail;
    }
}