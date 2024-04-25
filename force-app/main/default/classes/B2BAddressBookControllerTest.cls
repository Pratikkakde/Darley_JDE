@IsTest
public with sharing class B2BAddressBookControllerTest {

    @IsTest
    static void initAddressFormTest() {
        new B2BDefaultTestData().initAllData();
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        Map<String, Object> result;

        System.runAs(communityUser) {
            Test.startTest();
            result = B2BAddressBookController.initAddressForm();
            Test.stopTest();
        }
		B2BAddressBook addresBook = (B2BAddressBook)result.get('addressBook');
        System.assertEquals('US', addresBook.countryCode); 
    } 

    @IsTest
    static void createContactPointAddressTest() {
        new B2BDefaultTestData().initAllData();
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        Map<String, Object> newContactPointAddress = B2BTestDataFactory.createContactPointAddress(false, communityUser.AccountId, 'Shipping', true);
        B2BResponse result;
        String newContactPointAddressName = (String)newContactPointAddress.get('name'); 

        System.runAs(communityUser) {
            Test.startTest();
            result = B2BAddressBookController.createContactPointAddress(newContactPointAddress);
            Test.stopTest();
        }

        System.assert(true, result.isSuccess);
        List<ContactPointAddress> createdContactPointAddress = [SELECT Name FROM ContactPointAddress WHERE Name =:newContactPointAddressName];
        System.assertEquals(newContactPointAddressName, createdContactPointAddress[0].Name); 
    } 

    @IsTest
    static void getAddressDataTest() {
        new B2BDefaultTestData().initAllData();
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        Map<String, Object> newContactPointAddress = B2BTestDataFactory.createContactPointAddress(true, communityUser.AccountId, 'Shipping', true);
        B2BResponse result;
        String newContactPointAddressName = (String)newContactPointAddress.get('name'); 
        Id newContactPointAddressId = (Id)newContactPointAddress.get('id'); 

        System.runAs(communityUser) {
            Test.startTest();
            result = B2BAddressBookController.getAddressData(newContactPointAddressId);
            Test.stopTest();
        }

        System.assert(true, result.isSuccess);
        List<ContactPointAddress> createdContactPointAddress = [SELECT Name FROM ContactPointAddress WHERE Id =:newContactPointAddressId];
        System.assertEquals(1, createdContactPointAddress.size());
    }

    @IsTest
    static void updateContactPointAddressTest() {
        new B2BDefaultTestData().initAllData();
        User communityUser = [SELECT Id, AccountId FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];
        Map<String, Object> newContactPointAddress = B2BTestDataFactory.createContactPointAddress(true, communityUser.AccountId, 'Billing', true);
        B2BResponse result;
        newContactPointAddress.put('name','Address Name Test');
        Id newContactPointAddressId = (Id)newContactPointAddress.get('id'); 

        System.runAs(communityUser) {
            Test.startTest();
            result = B2BAddressBookController.updateContactPointAddress(newContactPointAddress, newContactPointAddressId);
            Test.stopTest();
        }

        System.assert(true, result.isSuccess);
        List<ContactPointAddress> createdContactPointAddress = [SELECT Name FROM ContactPointAddress WHERE Id =:newContactPointAddressId];
        System.assertEquals('Address Name Test', createdContactPointAddress[0].Name); 
    } 
}