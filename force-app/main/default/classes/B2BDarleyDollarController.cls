public without sharing class B2BDarleyDollarController {
    public class B2BDarleyDollarControllerException extends Exception { }

    public static void addDarleyDollarForRegistration(Id contactId) {
        Decimal valueDarleyDollarForRegistration = getDarleyDollarsForRegistration();
        DarleyDollar__c newDarleydollar = createDarleyDollar(valueDarleyDollarForRegistration, 'Registration', contactId, null);
        insert newDarleydollar;
    }

    @TestVisible
    private static DarleyDollar__c createDarleyDollar(Decimal value, String source, Id contactId, Id orderId) {
        if (value == null || contactId == null) {
            throw new B2BDarleyDollarControllerException('Amount and ContactId are required'); 
        }
        else {
            DarleyDollar__c newDarleyDollar = new DarleyDollar__c(
                Amount__c = value,
                Contact__c = contactId
            );
            if (source != null) {
                newDarleyDollar.Origin__c = source;
            }
            if (source == 'Order' && orderId == null) {
                throw new B2BDarleyDollarControllerException('Order is required');
            } 
            else if (orderId != null) {
                newDarleyDollar.Order__c = orderId;
            }
            return newDarleyDollar;
        }
    }

    public static Decimal getDarleyDollarsForRegistration(){
        String valueDarleyDollar = [
            SELECT Value__c 
            FROM B2B_Commerce_Setting__mdt 
            WHERE DeveloperName = 'Darley_Dollars_For_Registration' 
            LIMIT 1].Value__c;
        return Decimal.valueOf(valueDarleyDollar);
    }
}