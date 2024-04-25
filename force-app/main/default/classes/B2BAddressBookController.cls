/**
 * description: Controller Class for Address Book component.
 */
public without sharing class B2BAddressBookController {

    @AuraEnabled
    public static Map<String, Object> initAddressForm() {
        return new Map<String, Object> {
            'addressBook' => new B2BAddressBook(),
            'countriesCode' => B2BCountryStatePicklists.getCountryByCode(),
            'countriesStatesCode' => B2BCountryStatePicklists.getStatesByCountryCode(B2BCountryStatePicklists.getCountryByCode())
        };
    }

    @AuraEnabled
    public static B2BResponse createContactPointAddress(Map<String,Object> request) {
        try {
            List<User> users = [
                SELECT
                    Id,
                    AccountId
                FROM User
                WHERE Id = :UserInfo.getUserId()
            ];

            ContactPointAddress contactPointAddress = new ContactPointAddress();
            contactPointAddress.AddressType = (String)request.get('addressType');
            contactPointAddress.Name =(String)request.get('name');
            contactPointAddress.CountryCode = (String)request.get('countryCode');
            contactPointAddress.Street = (String)request.get('streetAddress');
            contactPointAddress.City = (String)request.get('city');
            contactPointAddress.StateCode = (String)request.get('provinceCode');
            contactPointAddress.PostalCode = (String)request.get('postalCode');
            contactPointAddress.ParentId = users[0].AccountId;
            contactPointAddress.isDefault = (Boolean)request.get('isDefault');
            contactPointAddress.OwnerId = users[0].Id;

            insert contactPointAddress;

            return new B2BResponse(true);

        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage());
        }
    }
    
    @AuraEnabled
    public static B2BResponse getAddressData(String recordId) {
   
        try {
            ContactPointAddress addressData = [
                SELECT
                    Name,
                    AddressType,
                    Street, 
                    City,
                    PostalCode,
                    StateCode,
                    CountryCode,
                    IsDefault
                FROM ContactPointAddress
                WHERE Id = :recordId
                LIMIT 1
            ];

            return new B2BResponse(true, addressData, 'isSuccess');
        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage());
        }
    }

    @AuraEnabled
    public static B2BResponse updateContactPointAddress(Map<String,Object> request, Id recordId) {
        try {
            ContactPointAddress contactPointAddress = [
            SELECT
                Name,
                AddressType,
                Street, 
                City,
                PostalCode,
                StateCode,
                CountryCode,
                IsDefault
            FROM ContactPointAddress
            WHERE Id = :recordId
            ];

            contactPointAddress.AddressType = (String)request.get('addressType');
            contactPointAddress.Name =(String)request.get('name');
            contactPointAddress.CountryCode = (String)request.get('countryCode');
            contactPointAddress.Street = (String)request.get('streetAddress');
            contactPointAddress.City = (String)request.get('city');
            contactPointAddress.StateCode = (String)request.get('provinceCode');
            contactPointAddress.PostalCode = (String)request.get('postalCode');
            contactPointAddress.isDefault = (Boolean)request.get('isDefault');

            update contactPointAddress;

            return new B2BResponse(true);

        } catch (Exception e) {
            return new B2BResponse(false, e.getMessage());
        }
    }
}