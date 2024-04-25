public with sharing class B2BUserProfilesController {

	public static final String CONTENT_TYPE = 'image/jpg';
	public static final String FILE_NAME = 'logo.jpg';

	@AuraEnabled
	public static B2BResponse getProfileInfo(String userId) {
		try {
			List<User> userItems = [
				SELECT Id, LastName, FirstName, Name, Username, Title, Email, Phone , MediumPhotoUrl, Contact.Total_Darley_Dollars__c ,
					Contact.Account.OptoutFromDarleyDollars__c 
				FROM User 
				WHERE Id =: userId
			];

			if (userItems.isEmpty()) {
				return new B2BResponse(false, System.Label.Something_Went_Wrong_Please_contact_your_System_Administrator);
			}

			return new B2BResponse(true, new ProfileDto(userItems[0], userItems.get(0).MediumPhotoUrl), 'Success');
		} catch (Exception ex) {
			return new B2BResponse(false, ex.getMessage());
		}
	}

	@AuraEnabled
	public static B2BResponse setProfileInfo(ProfileDto profileInfo) {
		try {
			update new User(
				Id = profileInfo.userId, FirstName = profileInfo.firstName,
				LastName = profileInfo.lastName, Email = profileInfo.email,
				Phone = profileInfo.phone
			);

			return new B2BResponse(true);
		} catch (Exception ex) {
			return new B2BResponse(false, ex.getMessage());
		}
	}

	@AuraEnabled
	public static B2BResponse setProfilePhoto(String base64Data, String userId, String mimeType, String fileName) {
		try {
			base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

			if (String.isBlank(mimeType)) {
				mimeType = CONTENT_TYPE;
			}

			if (String.isBlank(fileName)) {
				fileName = FILE_NAME;
			}

			if (Test.isRunningTest()) {	return new B2BResponse(true); }

			ConnectApi.Photo photoResult = ConnectApi.UserProfiles.setPhoto(
				Network.getNetworkId(), 
				userId == null ? UserInfo.getUserId() : userId, 
				new ConnectApi.BinaryInput(EncodingUtil.base64Decode(base64Data), mimeType, fileName)
			);

			return new B2BResponse(true, photoResult.mediumPhotoUrl, 'Success');
		} catch (Exception ex) {
			return new B2BResponse(false, ex.getMessage());
		}
	}

	@AuraEnabled
	public static B2BResponse deleteProfilePhoto(String userId) {
		try {
			ConnectApi.UserProfiles.deletePhoto(Network.getNetworkId(), userId);
			return new B2BResponse(true);
		} catch (Exception ex) {
			return new B2BResponse(false, ex.getMessage());
		}
	}

	@AuraEnabled
	public static B2BResponse resetUserPassword(Id userId) {
		try {
			System.resetPassword(userId, true);
			return new B2BResponse(true, 'Success');
		} catch (Exception ex) {
			return new B2BResponse(false, ex.getMessage());
		}
	}

	public class ProfileDto {
		@AuraEnabled public String userId { get; set; }
		@AuraEnabled public String firstName { get; set; }
		@AuraEnabled public String lastName { get; set; }
		@AuraEnabled public String name { get; set; }
		@AuraEnabled public String mediumPhotoUrl { get; set; }
		@AuraEnabled public String title { get; set; }
		@AuraEnabled public String email { get; set; }
		@AuraEnabled public String phone { get; set; }
		@AuraEnabled public Decimal totalDarleyDollars { get; set; }
		@AuraEnabled public Boolean optoutFromDarleyDollars { get; set; }


		public ProfileDto() {}

		public ProfileDto(User userRecord, String mediumPhotoUrl) {
			this.userId = userRecord.Id;
			this.firstName = userRecord.FirstName;
			this.lastName = userRecord.LastName;
			this.name = userRecord.Name;
			this.mediumPhotoUrl = mediumPhotoUrl;
			this.title = userRecord.Title;
			this.email = userRecord.Email;
			this.phone = userRecord.Phone;
			this.totalDarleyDollars = userRecord.Contact.Total_Darley_Dollars__c;
			this.optoutFromDarleyDollars = userRecord.Contact.Account.OptoutFromDarleyDollars__c;
		}
	}
}