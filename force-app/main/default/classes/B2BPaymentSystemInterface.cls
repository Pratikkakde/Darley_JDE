public interface B2BPaymentSystemInterface {

    Object createCustomer();
    void createPaymentMethod(Object paymentMethodData);
    void setPaymentMethodAsDefault(Object paymentMethodData);
    void deletePaymentMethod(Object paymentMethodData);
    Object getPaymentMethods();
    Object getPaymentCards();
    Object getPaymentACHs();
    Object createPayment(Object paymentMethodData);
    Object confirmPayment(Object paymentMethodData, Decimal amount);
    Object cancelPayment(Object paymentMethodData);
    Object refundPayment(Object paymentMethodData, Decimal amount);
    Object getAdditionalData(String parameter); //For specific things, for example to get Stripe Public Key

}