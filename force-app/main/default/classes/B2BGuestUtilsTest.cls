/**
 * Created by IrinaSakovich on 1.08.22.
 */

@IsTest
public with sharing class B2BGuestUtilsTest {
    @IsTest
    public static void getDefaultGuestAccount() {
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initGuestUserData();
        User user = (User)testData.get(B2BGuestCheckoutDefaultTestData.GUEST_USER);

        Account account;
        System.runAs(user) {
            account = B2BGuestUtils.getDefaultGuestAccount();
        }

        System.assertEquals(false, account == null);
    }

    @IsTest
    public static void isCurrentUserGuestTrueTest() {
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initGuestUserData();
        User user = (User)testData.get(B2BGuestCheckoutDefaultTestData.GUEST_USER);

        Boolean isGuest;
        System.runAs(user) {
            isGuest = B2BGuestUtils.isCurrentUserGuest();
        }

        System.assertEquals(true, isGuest);
    }

    @IsTest
    public static void isCurrentUserGuestFalseTest() {
        B2BGuestCheckoutTestDataFactory factory = new B2BGuestCheckoutTestDataFactory();
        Map<String, Object> testData = factory.initGuestUserData();
        User user = (User)testData.get(B2BGuestCheckoutDefaultTestData.SYS_ADMIN_USER);

        Boolean isGuest;
        System.runAs(user) {
            isGuest = B2BGuestUtils.isCurrentUserGuest();
        }

        System.assertEquals(false, isGuest);
    }
}