public without sharing class B2BAddressBook {
    private static final String COUNTRY_DEFAULT = 'US';

    @AuraEnabled public String name { get; set; }
    @AuraEnabled public String street { get; set; }
    @AuraEnabled public String countryCode { get; set; }
    @AuraEnabled public String stateCode { get; set; }
    @AuraEnabled public String city { get; set; }
    @AuraEnabled public String postalCode { get; set; }

    public B2BAddressBook() {
        this.name = '';
        this.street = '';
        this.countryCode = COUNTRY_DEFAULT;
        this.stateCode = '';
        this.city = '';
        this.postalCode = '';
    }
}