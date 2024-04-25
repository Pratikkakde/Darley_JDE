public without sharing class B2BCountryStatePicklists {

    private static Boolean isSCPEnabled {
        get {
            Map<String, Schema.SObjectField> accountFields = Account.sObjectType.getDescribe().fields.getMap();
            isSCPEnabled = accountFields.containsKey('BillingStateCode');

            return isSCPEnabled;
        }
        set;
    }

    public static Map<String, String> getCountryByCode() {
        Map<String, String> countryByCode = new Map<String, String>();
        if (isSCPEnabled) {
            List<Schema.PicklistEntry> countryOptions = Account.sObjectType.getDescribe().fields.getMap().get('BillingCountryCode').getDescribe().getPicklistValues();
            for (Schema.PicklistEntry countryOption : countryOptions) {
                countryByCode.put(countryOption.getValue(), countryOption.getLabel());
            }
        }

        return countryByCode;
    }

    public static Map<String, List<Map<String, String>>> getStatesByCountryCode(Map<String, String> countryByCode) {
        Map<String, List<Map<String, String>>> statesByCountryCode = new Map<String, List<Map<String, String>>>();
        if (isSCPEnabled) {

            for (String countryCode : countryByCode.keySet()) {
                statesByCountryCode.put(countryCode, new List<Map<String, String>>());
            }
            List<String> countries = new List<String>(countryByCode.keySet());

            Schema.SObjectField stateField = Account.sObjectType.getDescribe().fields.getMap().get('BillingStateCode');
            List<CountryStatePicklistEntry> stateOptions = wrapPicklistEntries(stateField.getDescribe().getPicklistValues());

            for (CountryStatePicklistEntry state : stateOptions) {
                String validForBits = B2BUtils.base64ToBits(state.validFor);

                for (Integer i = 0; i < validForBits.length(); i++) {
                    String bit = validForBits.mid(i, 1);

                    if (bit == '1') {
                        statesByCountryCode.get(countries.get(i)).add(new Map<String, String> { state.value => state.label});
                    }
                }


            }
        }

        return statesByCountryCode;
    }

    public static Map<String, List<String>> getCountryStatePicklists() {
        Map<String, List<String>> objResults = new Map<String, List<String>>();
        List<String> controllingValues = new List<String>();

        if (isSCPEnabled) {
            Schema.SObjectField theField = Account.sObjectType.getDescribe().fields.getMap().get('BillingStateCode');
            Schema.SObjectField ctrlField = Account.sObjectType.getDescribe().fields.getMap().get('BillingCountryCode');

            // validFor property cannot be accessed via a method or a property,
            // so we need to serialize the PicklistEntry object and then deserialize into a wrapper.
            List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
            List<CountryStatePicklistEntry> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());

            for (Schema.PicklistEntry ple : contrEntries) {
                String label = ple.getLabel();

                objResults.put(label, new List<String>());
                controllingValues.add(label);
            }

            for (CountryStatePicklistEntry plew : depEntries) {
                String label = plew.label;
                String validForBits = B2BUtils.base64ToBits(plew.validFor);

                for (Integer i = 0; i < validForBits.length(); i++) {
                    String bit = validForBits.mid(i, 1);

                    if (bit == '1') {
                        objResults.get(controllingValues.get(i)).add(label);
                    }
                }
            }
        }

        return objResults;
    }

    private static List<CountryStatePicklistEntry> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<CountryStatePicklistEntry>)
            JSON.deserialize(JSON.serialize(PLEs), List<CountryStatePicklistEntry>.class);
    }

    public class CountryStatePicklistEntry {
        public String active { get; set; }
        public String defaultValue { get; set; }
        public String label { get; set; }
        public String value { get; set; }
        public String validFor { get; set; }
    }

}