public without sharing class B2BRegister {

    private static final String COUNTRY_DEFAULT = 'United States';

    @AuraEnabled public Boolean hasAccount { get; set; }
    @AuraEnabled public String firstName { get; set; }
    @AuraEnabled public String lastName { get; set; }
    @AuraEnabled public String email { get; set; }


    @AuraEnabled public String companyName { get; set; }
    @AuraEnabled public String companyPhoneNumber { get; set; }
    @AuraEnabled public String streetAddress { get; set; }

    @AuraEnabled public String country { get; set; }
    @AuraEnabled public String state { get; set; }
    @AuraEnabled public String city { get; set; }
    @AuraEnabled public String postalCode { get; set; }
    @AuraEnabled public String registrationType { get; set; }

    public B2BRegister() {
        this.hasAccount = false;
        this.country = COUNTRY_DEFAULT;
    }

    public void makeRegistration() {
        validateExistingUser();

        try {
            Account account =  B2BRegisterService.createCommerceAccount(this);
            Contact contact =  B2BRegisterService.createCommerceUser(this, account);
            B2BDarleyDollarController.addDarleyDollarForRegistration(contact.Id);
        } catch (Exception ex) {
            throw ex;
        }
    }

    private void validateExistingUser() {
        List<User> users = B2BRegisterService.selectUserByEmailOrUsername(email);

        if (!users.isEmpty()) {
            throw new B2BRegisterException(Label.B2B_A_user_with_this_email_already_exists);
        }
    }


    public class B2BRegisterException extends Exception {}

}