public without sharing class B2BAvalaraConfiguration {

    private static final String CALCULATE_PATH = 'transactions/create';

    public String licenseKey { get; private set; }
    public String accountId { get; private set; }
    public String requestURI { get; private set; }
    public String companyCode { get; private set; }

    public String calculatePath { get; private set; }
    public String endpoint {
        get {
            return this.requestURI + this.calculatePath;
        }

        private set;
    }

    private static B2BAvalaraConfiguration instance;

    private B2BAvalaraConfiguration() {
        List<B2BAvalaraConfiguration__mdt> connections = [
            SELECT
                LicenseKey__c,
                AccountId__c,
                CompanyCode__c,
                URI__c
            FROM B2BAvalaraConfiguration__mdt
            LIMIT 1
        ];

        if (connections.isEmpty() && !Test.isRunningTest()) {
            throw new B2BAvalaraConfigurationException('Configuration was not set up in \'B2B Avalara Configuration\' custom metadata.');
        } else {
            this.licenseKey = Test.isRunningTest() ? 'LicenseKey' : connections[0].LicenseKey__c;
            this.accountId = Test.isRunningTest() ? 'AccountId' : connections[0].AccountId__c;
            this.requestURI = Test.isRunningTest() ? 'URI' : connections[0].URI__c;
            this.companyCode = Test.isRunningTest() ? 'CompanyCode' : connections[0].CompanyCode__c;
            this.calculatePath = CALCULATE_PATH;
        }

    }

    public static B2BAvalaraConfiguration getInstance() {
        if (instance == null) {
            instance = new B2BAvalaraConfiguration();
        }

        return instance;
    }

    public class B2BAvalaraConfigurationException extends Exception {}
}