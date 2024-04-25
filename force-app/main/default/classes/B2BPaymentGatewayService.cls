public with sharing class B2BPaymentGatewayService {

    public class MethodNotImplementedException extends Exception {}

    private static Map<String, String> PaymentSystems = new Map<String, String>{
        'stripe' => 'B2BStripe',
        'authorize' => 'B2BAuthorizeNet'
    };

    public static Object createCustomer(String paymentSystem, Id objectId) {
        return getPaymentServiceInstance(paymentSystem, objectId).createCustomer();
    }
    public static void createPaymentMethod(String paymentSystem, Id objectId, Object paymentMethodData) {
        getPaymentServiceInstance(paymentSystem, objectId).createPaymentMethod(paymentMethodData);
    }
    public static void setPaymentMethodAsDefault(String paymentSystem, Id objectId, Object paymentMethodData) {
        getPaymentServiceInstance(paymentSystem, objectId).setPaymentMethodAsDefault(paymentMethodData);
    }
    public static void deletePaymentMethod(String paymentSystem, Id objectId, Object paymentMethodData) {
        getPaymentServiceInstance(paymentSystem, objectId).deletePaymentMethod(paymentMethodData);
    }
//    public static Object getPaymentMethods(String paymentSystem, Id objectId) {
//        return getPaymentServiceInstance(paymentSystem, objectId).getPaymentMethods();
//    }
    public static Object getPaymentCards(String paymentSystem, Id objectId) {
        return getPaymentServiceInstance(paymentSystem, objectId).getPaymentCards();
    }
//    public static Object getPaymentACHs(String paymentSystem, Id objectId) {
//        return getPaymentServiceInstance(paymentSystem, objectId).getPaymentACHs();
//    }
    public static Object createPayment(String paymentSystem, Id objectId, Object paymentMethodData) {
        return getPaymentServiceInstance(paymentSystem, objectId).createPayment(paymentMethodData);
    }
//    public static Object confirmPayment(String paymentSystem, Id objectId, Object paymentData) {
//        return getPaymentServiceInstance(paymentSystem, objectId).confirmPayment(paymentData, 0);
//    }
//    public static Object cancelPayment(String paymentSystem, Id objectId, Object paymentData) {
//        return getPaymentServiceInstance(paymentSystem, objectId).cancelPayment(paymentData);
//    }
//    public static Object refundPayment(String paymentSystem, Id objectId, Object paymentData) {
//        return getPaymentServiceInstance(paymentSystem, objectId).refundPayment(paymentData, 0);
//    }
    public static Object getAdditionalData(String paymentSystem, String parameter) {
        return getPaymentServiceInstance(paymentSystem, null).getAdditionalData(parameter);
    }

    private static B2BPaymentSystemInterface getPaymentServiceInstance(String paymentSystem, String objectId) {
        String configParameters;
        if (String.isNotBlank(objectId)) {
            configParameters = String.format('"objectId": "{0}"', new List<String>{objectId});
        } else {
            configParameters = '"objectId": null';
        }
        String paymentGateway = PaymentSystems.get(paymentSystem);
        if (String.isBlank(paymentGateway)) {
            paymentGateway = PaymentSystems.get('stripe');
        }
        return (B2BPaymentSystemInterface) JSON.deserialize('{' + configParameters + '}', Type.forName(paymentGateway));
    }
}