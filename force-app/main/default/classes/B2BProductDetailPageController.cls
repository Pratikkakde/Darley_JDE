public without sharing class B2BProductDetailPageController {

    @AuraEnabled
    public static B2BResponse getProductDetails (String productId) {
        try{
            List<ConnectApi.ProductMediaGroup> mediaGroups;
            List<ConnectApi.ProductMedia> mediaItems;
            List<AttachementDetail> attachmentDetails = new List<AttachementDetail>();
            ConnectApi.ProductDetail productDetails;
            String webStoreId = B2BUtils.getStoreIdRelatedToCurrentUser();

            productDetails = !Test.isRunningTest() ? ConnectApi.CommerceCatalog.getProduct(
                webStoreId, productId, null, new List<String>{'FAQ__c','ShippingDetails__c','Articles__c'}, false, new List<String>{'Attachment'}, false, true, true) 
                : B2BProductDetailPageControllerTest.mockConnectApiProductDetails() ;

            mediaGroups = (List<ConnectApi.ProductMediaGroup>) productDetails.mediaGroups;
            B2BSettings__c settings = B2BSettings__c.getOrgDefaults();
            for (ConnectApi.ProductMediaGroup mediaGroup : mediaGroups ) {
                mediaItems = (List<ConnectApi.ProductMedia>) mediaGroup.mediaItems;  
                for(ConnectApi.ProductMedia mediaItem : mediaItems){
                    String url = settings.CommunityURL__c +'/sfsites/c'+ mediaItem.url;
                    attachmentDetails.add(new AttachementDetail (mediaItem.title, url));
                }
            }

            ProductDetail productDetail = new ProductDetail();
            productDetail.faq = productDetails.fields.get('FAQ__c');
            productDetail.shippindDetails = productDetails.fields.get('ShippingDetails__c');
            productDetail.articles = productDetails.fields.get('Articles__c');
            productDetail.attachments = attachmentDetails;
            return new B2BResponse(true, ProductDetail, 'Success');
        } catch (Exception exp) {
            System.debug('***Error');
            return new B2BResponse(false, exp.getMessage());
        }
        
    }

    public class ProductDetail {
        @AuraEnabled public String faq;
        @AuraEnabled public String shippindDetails;
        @AuraEnabled public String articles;
        @AuraEnabled public List<AttachementDetail> attachments;
    }

    public class AttachementDetail {
        @AuraEnabled public String fileName;
        @AuraEnabled public String fileUrl;
        public AttachementDetail (String fileName, String fileUrl) {
            this.fileName = fileName;
            this.fileUrl = fileUrl;
        }
    }
}