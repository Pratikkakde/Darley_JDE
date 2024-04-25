public without sharing class B2BCheckoutAddress {

    public static final String BILLING_TYPE = 'Billing';
    public static final String SHIPPING_TYPE = 'Shipping';

    @AuraEnabled public List<AddressDto> shippingAddresses { get; set; }
    @AuraEnabled public List<AddressDto> billingAddresses { get; set; }
    @AuraEnabled public Id selectedBillingAddressId { get; set; }

    @AuraEnabled public Id selectedShippingAddressId { get; set; }
    @AuraEnabled public Boolean isSameWithBilling { get; set; }

    private ContactPointAddress defaultBillingAddress;
    private ContactPointAddress defaultShippingAddress;

    public B2BCheckoutAddress(Id cartId) {
        WebCart webCart = B2BCheckoutService.getWebCartById(cartId);
        isSameWithBilling = false;
        initAddresses(webCart);
        setAddressesInCart(webCart);

        if (!isSameWithBilling) {
            checkAddressesIsSame();
        }
    }

    private void setAddressesInCart(WebCart webCart) {
        if (webCart.B2BCheckoutBillingAddress__c != selectedBillingAddressId || webCart.B2BCheckoutShippingAddress__c != selectedShippingAddressId) {
            webCart.B2BCheckoutBillingAddress__c = selectedBillingAddressId;
            webCart.B2BCheckoutShippingAddress__c = selectedShippingAddressId;

            update webCart;
        }
    }

    private void initAddresses(WebCart webCart) {
        shippingAddresses = new List<AddressDto>();
        billingAddresses = new List<AddressDto>();
        Set<Id> existedAddressIds = new Set<Id>();
        for (ContactPointAddress contactPointAddress : B2BCheckoutService.getContactPointAddressesByParentId(webCart.AccountId)) {
            if (contactPointAddress.AddressType == BILLING_TYPE) {
                defaultBillingAddress = contactPointAddress.IsDefault ? contactPointAddress : defaultBillingAddress;
                billingAddresses.add(new AddressDto(contactPointAddress));
            } else if (contactPointAddress.AddressType == SHIPPING_TYPE) {
                defaultShippingAddress = contactPointAddress.IsDefault ? contactPointAddress : defaultShippingAddress;
                shippingAddresses.add(new AddressDto(contactPointAddress));
            }

            existedAddressIds.add(contactPointAddress.Id);
        }

        if (!billingAddresses.isEmpty()) {
            checkDefaultBillingAddress(billingAddresses);
        }

        if (!shippingAddresses.isEmpty()) {
            checkDefaultShippingAddress(shippingAddresses);
        }

        selectedBillingAddressId = getSelectedAddressId(webCart.B2BCheckoutBillingAddress__c, defaultBillingAddress, existedAddressIds);
        selectedShippingAddressId = getSelectedAddressId(webCart.B2BCheckoutShippingAddress__c, defaultShippingAddress, existedAddressIds);
    }

    private void checkDefaultShippingAddress(List<AddressDto> addresses) {
        defaultShippingAddress = defaultShippingAddress == null ? addresses[0].getContactPointAddress() : defaultShippingAddress;
    }

    private void checkDefaultBillingAddress(List<AddressDto> addresses) {
        defaultBillingAddress = defaultBillingAddress == null ? addresses[0].getContactPointAddress() : defaultBillingAddress;
    }

    private Id getSelectedAddressId(Id selectedId, ContactPointAddress defaultAddress, Set<Id> existedIds) {
        Id defaultAddressId = defaultAddress == null ? null : defaultAddress.Id;
        return existedIds.contains(selectedId) ? selectedId : defaultAddressId;
    }

    private ContactPointAddress cloneAddress(ContactPointAddress address) {
        ContactPointAddress clonedAddress = address.clone(false, false, false, false);
        clonedAddress.AddressType = address.AddressType == SHIPPING_TYPE ? BILLING_TYPE : SHIPPING_TYPE;
        B2BCheckoutService.upsertAddress(new List<ContactPointAddress> { clonedAddress });
        isSameWithBilling = true;

        return clonedAddress;
    }

    private void checkAddressesIsSame() {
        AddressDto billingAddress = getSelectedAddress(billingAddresses, selectedBillingAddressId);
        AddressDto shippingAddress = getSelectedAddress(shippingAddresses, selectedShippingAddressId);

        if (billingAddress != null && shippingAddress != null) {
            isSameWithBilling = billingAddress.isSameRecords(shippingAddress);
        }
    }

    private AddressDto getSelectedAddress(List<AddressDto> addresses, Id selectedAddressId) {
        AddressDto selectedAddress;
        for (AddressDto address : addresses) {
            if (address.id == selectedAddressId) {
                selectedAddress = address;
                break;
            }
        }

        return selectedAddress;
    }

    public class AddressDto {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String street { get; set; }
        @AuraEnabled public String city { get; set; }

        @AuraEnabled public String state { get; set; }
        @AuraEnabled public String stateCode { get; set; }
        @AuraEnabled public String postalCode { get; set; }
        @AuraEnabled public String country { get; set; }

        @AuraEnabled public String countryCode { get; set; }
        @AuraEnabled public String addressType { get; set; }
        @AuraEnabled public String parentId { get; set; }
        @AuraEnabled public Boolean isDefault { get; set; }

        public AddressDto(ContactPointAddress contactPointAddress) {
            id = contactPointAddress.Id;
            name = contactPointAddress.Name;
            street = contactPointAddress.Street;
            city = contactPointAddress.City;
            state = contactPointAddress.State;
            stateCode = contactPointAddress.StateCode;
            postalCode = contactPointAddress.PostalCode;
            country = contactPointAddress.Country;
            countryCode = contactPointAddress.CountryCode;
            addressType = contactPointAddress.AddressType;
            parentId = contactPointAddress.ParentId;
            isDefault = contactPointAddress.IsDefault;
        }

        public AddressDto() {}

        public ContactPointAddress getContactPointAddress() {
            return new ContactPointAddress(
                Id = id,
                Name = name,
                Street = street,
                City = city,
                State = state,
                StateCode = stateCode,
                PostalCode = postalCode,
                Country = country,
                CountryCode = countryCode,
                AddressType = addressType,
                ParentId = parentId,
                IsDefault = isDefault
            );
        }

        public Boolean isSameRecords(AddressDto comparedAddress) {
            Boolean isSame = true;
            if (!isSameField(name, comparedAddress.name)) {
                isSame = false;
            } else if (!isSameField(street, comparedAddress.street)) {
                isSame = false;
            } else if (!isSameField(city, comparedAddress.city)) {
                isSame = false;
            } else if (!isSameField(state, comparedAddress.state)) {
                isSame = false;
            } else if (!isSameField(stateCode, comparedAddress.stateCode)) {
                isSame = false;
            } else if (!isSameField(postalCode, comparedAddress.postalCode)) {
                isSame = false;
            } else if (!isSameField(country, comparedAddress.country)) {
                isSame = false;
            } else if (!isSameField(countryCode, comparedAddress.countryCode)) {
                isSame = false;
            }

            return isSame;
        }

        private Boolean isSameField(String originalField, String comparedField) {
            return originalField != null && comparedField != null ? originalField.trim().equalsIgnoreCase(comparedField) : originalField == comparedField;
        }
    }

}