@IsTest
private class B2BCountryStatePicklistsTest {

    @IsTest
    private static void checkCountries() {
        Test.startTest();
        Map<String, List<String>> countryStates = B2BCountryStatePicklists.getCountryStatePicklists();
        System.assert(!countryStates.isEmpty(), 'Country-State picklist should not be empty');

        Map<String, String> countries = B2BCountryStatePicklists.getCountryByCode();
        System.assert(!countries.isEmpty(), 'Countries should not be empty');

        Map<String, List<Map<String, String>>> states = B2BCountryStatePicklists.getStatesByCountryCode(countries);
        System.assert(!states.isEmpty(), 'States should not be empty');
        Test.stopTest();
    }

}