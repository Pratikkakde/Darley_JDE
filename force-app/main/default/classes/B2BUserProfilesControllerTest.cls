@IsTest
public with sharing class B2BUserProfilesControllerTest {
	
	@IsTest
	private static void getProfileTest() {
		new B2BDefaultTestData().initCustomerUserData();
		User communityUser = [SELECT Id FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];

		System.runAs(communityUser) {
			B2BResponse result = B2BUserProfilesController.getProfileInfo(null);
			System.assertEquals(false, result.isSuccess);

			result = B2BUserProfilesController.getProfileInfo(communityUser.Id);
			System.assertEquals(true, result.isSuccess);
			
			B2BUserProfilesController.ProfileDto profDto = (B2BUserProfilesController.ProfileDto) result.responseData;
			System.assertEquals('testemail@test.coom', profDto.email);
			System.assertEquals('Ivan', profDto.firstName);
			System.assertEquals('Ivanov', profDto.lastName);
			System.assertEquals('Ivan Ivanov', profDto.name);
			System.assertEquals(null, profDto.phone);
			System.assertEquals(null, profDto.title);

			System.assertNotEquals('', profDto.mediumPhotoUrl);
			System.assertNotEquals('', profDto.userId);

			result = B2BUserProfilesController.deleteProfilePhoto(null);
			System.assertEquals(false, result.isSuccess);
		}
	}
	
	@IsTest
	private static void setProfileTest() {
		new B2BDefaultTestData().initCustomerUserData();
		User communityUser = [SELECT Id FROM User WHERE Username = :B2BDefaultTestData.COMMUNITY_USER_NAME];

		System.runAs(communityUser) {
			B2BResponse result = B2BUserProfilesController.setProfilePhoto('', communityUser.Id, 'image/jpeg', 'logo.jpg');
			System.assertEquals(true, result.isSuccess);

			B2BUserProfilesController.ProfileDto profDto = new B2BUserProfilesController.ProfileDto();
			profDto.email = 'test.email.profile@gmail.com';
			profDto.userId = communityUser.Id;
			profDto.firstName = 'firstName';
			profDto.lastName = 'lastName';
			profDto.phone = '000000';

			result = B2BUserProfilesController.setProfileInfo(profDto);
			System.assertEquals(true, result.isSuccess);

			result = B2BUserProfilesController.setProfileInfo(null);
			System.assertEquals(false, result.isSuccess);

			result = B2BUserProfilesController.resetUserPassword(null);
			System.assertEquals(false, result.isSuccess);
		}
	}
}