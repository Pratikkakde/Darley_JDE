public with sharing class B2BRegisterController {

    @AuraEnabled
    public static Map<String, Object> initRegisterForm() {
        return new Map<String, Object> {
            'register' => new B2BRegister(),
            'countriesAndStates' => B2BCountryStatePicklists.getCountryStatePicklists()
        };
    }

    @AuraEnabled
    public static void signUp(B2BRegister register) {
        register.makeRegistration();
    }

}