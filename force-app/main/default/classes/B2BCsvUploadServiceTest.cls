@IsTest
public class B2BCsvUploadServiceTest {

    public static String TEST_CSV_DATA =
        'SKU' + ',' + 'Quantity' + '\n' +
        '10000-min' + ',' + '10' + '\n' +
        '10000-max' + ',' + '4' + '\n' +
        '10000-px' + ',' + '10' + '\n' +
        '10000-ss' + ',' + '3' + '\n' +
        '10001' + ',' + '15' + '\n';

    @TestSetup
    private static void setupTestData() {
        B2BQuickOrderTestData.setupQuickOrderTestData();
    }

    @IsTest
    private static void parseUploadedCSVTest() {
        User testUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BQuickOrderTestData.TEST_USER_NAME LIMIT 1];

        List<B2BQuickOrderProductService.ProductData> parseCsvData;
        System.runAs(testUser) {
            parseCsvData = B2BCsvUploadService.parseUploadedCSV(TEST_CSV_DATA, testUser.AccountId);
        }

        System.assert(!parseCsvData.isEmpty());
    }

    @IsTest
    private static void parseUploadedEmptyCSVTest() {
        User testUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BQuickOrderTestData.TEST_USER_NAME LIMIT 1];
        TEST_CSV_DATA = 'SKU' + ',' + 'Quantity' + '\n';

        List<B2BQuickOrderProductService.ProductData> parseCsvData;
        System.runAs(testUser) {
            parseCsvData = B2BCsvUploadService.parseUploadedCSV(TEST_CSV_DATA, null);
        }

        System.assert(parseCsvData.isEmpty());
    }

    @IsTest
    private static void parseUploadedCSVFailColumnsTest() {
        User testUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BQuickOrderTestData.TEST_USER_NAME LIMIT 1];
        TEST_CSV_DATA = 'SKU' + ',' + 'Quantity' + ',' + 'Quantity' + '\n';

        String errorMsg;
        System.runAs(testUser) {
            try {
                List<B2BQuickOrderProductService.ProductData> parseCsvData = B2BCsvUploadService.parseUploadedCSV(TEST_CSV_DATA, testUser.AccountId);

            } catch (Exception ex) {
                errorMsg = ex.getMessage();
            }
        }

        System.assert(errorMsg != null);
        System.assertEquals(B2BCsvUploadService.SOMETHING_WENT_WRONG_DURING_UPLOAD, errorMsg);
    }

    @IsTest
    private static void parseUploadedCSVFailValuesTest() {
        User testUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BQuickOrderTestData.TEST_USER_NAME LIMIT 1];
        TEST_CSV_DATA = 'SKU' + ',' + 'Quantity' + '\n' +
            '10000-min' + ',' + '10' + '\n' +
            '10000-max' + ',' + '4' + '\n' +
            '10000-px' + ',' + '10' + '\n' +
            '10000-ss' + ',' + '3' + '\n' +
            '10001' + ',' + 'bb' + '\n';

        String errorMsg;
        System.runAs(testUser) {
            try {
                List<B2BQuickOrderProductService.ProductData> parseCsvData = B2BCsvUploadService.parseUploadedCSV(TEST_CSV_DATA, testUser.AccountId);

            } catch (Exception ex) {
                errorMsg = ex.getMessage();
            }
        }

        System.assert(errorMsg != null);
        System.assertEquals(B2BCsvUploadService.SOMETHING_WENT_WRONG_DURING_UPLOAD, errorMsg);
    }

    @IsTest
    private static void parseUploadedCSVExistedCartTest() {
        User testUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BQuickOrderTestData.TEST_USER_NAME LIMIT 1];
        List<Product2> products = [SELECT Id FROM Product2 WHERE Name LIKE 'Test4%'];

        WebStore webStore = new WebStore(Name = 'Test Store Name');
        insert webStore;

        WebCart testCart = new WebCart(
            WebStoreId = webStore.Id,
            Name = 'Cart',
            AccountId = testUser.AccountId,
            Status = 'Active',
            OwnerId = testUser.Id
        );
        insert testCart;

        CartDeliveryGroup grp = new CartDeliveryGroup(
            Name = 'Cart Delivery Group',
            CartId = testCart.Id,
            DeliverToPostalCode = '606060',
            DeliverToState = 'Illinois',
            DeliverToStateCode = 'IL',
            DeliverToStreet = 'mail street',
            DeliverToCity = 'Chicago',
            DeliverToCountry = 'United States',
            DeliverToCountryCode = 'US'
        );
        insert grp;

        CartItem cartItem = new CartItem();
        cartItem.Product2Id = products[0].Id;
        cartItem.Quantity = 10;
        cartItem.SalesPrice = 100;
        cartItem.CartId = testCart.Id;
        cartItem.CartDeliveryGroupId = grp.Id;
        cartItem.Name = 'CartItem';
        cartItem.Type = 'Product';
        insert cartItem;

        List<B2BQuickOrderProductService.ProductData> parseCsvData;
        System.runAs(testUser) {
            parseCsvData = B2BCsvUploadService.parseUploadedCSV(TEST_CSV_DATA, testUser.AccountId);
        }

        System.assert(!parseCsvData.isEmpty());
    }
}