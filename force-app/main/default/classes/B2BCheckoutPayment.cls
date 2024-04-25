public without sharing class B2BCheckoutPayment {

    private static final String METHOD_CREDIT_CARD = 'Credit Card';
    private static final String METHOD_INVOICE = 'Invoice';
    private static final Decimal DARLEY_DOLLAR_MAX_PERCENT = 0.25;

    @AuraEnabled public Map<String, Object> metadata { get; set; }
    @AuraEnabled public String selectedCreditCardId { get; set; }
    @AuraEnabled public String paymentMethod { get; set; }
    @AuraEnabled public String poNumber { get; set; }

    @AuraEnabled public Boolean isInvoiceMyCompany { get; set; }
    @AuraEnabled public Boolean isAccountCreditTerms { get; set; }
    @AuraEnabled public Boolean hasInvoicePayment { get; set; }
    @AuraEnabled public Decimal darleyDollarAmount { get; set; }

    @AuraEnabled public Boolean hasDarleyDollars { get; set; }
    @AuraEnabled public Decimal expirationDateMin { get; set; }
    @AuraEnabled public List<B2BPayPal.CreditCardDto> creditCards { get; set; }

    @AuraEnabled public String publicKey { get; set; }
    @AuraEnabled public String publicExponent { get; set; }

    private Decimal darleyDollarAll;
    private Id contactId;

    public B2BCheckoutPayment(Id webCartId) {
        initAccountCreditTerms();
        initMetadata();
        initCreditCards();
        initPaymentData(webCartId);
    }

    private void initAccountCreditTerms() {
        List<User> users = [
            SELECT
                ContactId,
                Contact.Total_Darley_Dollars__c,
                Account.Credit_Terms__c,
                Account.B2BHasInvoicePayment__c,
                Account.OptoutFromDarleyDollars__c
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];

        contactId = users.isEmpty() ? null : users[0].ContactId;
        isAccountCreditTerms = users.isEmpty() ? false : users[0].Account.Credit_Terms__c;
        hasInvoicePayment = users.isEmpty() ? false : users[0].Account.B2BHasInvoicePayment__c;
        darleyDollarAll = (users.isEmpty() || users[0].Account?.OptoutFromDarleyDollars__c == true || users[0].Contact?.Total_Darley_Dollars__c < 0) ? 0 : users[0].Contact?.Total_Darley_Dollars__c;
    }

    private void initMetadata() {
        metadata = new Map<String, Object> {
            'methodCreditCard' => METHOD_CREDIT_CARD,
            'methodInvoice' => METHOD_INVOICE
        };
    }

    private void initCreditCards() {
        creditCards = new B2BPayPal().getCustomerCards(contactId);
    }

    private void initPaymentData(Id webCartId) {
        expirationDateMin = Decimal.valueOf(Datetime.now().format('YYMM'));

        WebCart cart = [
            SELECT
                Id,
                B2BCreditCardId__c,
                PoNumber,
                B2BHasDarleyDollars__c,
                Payment_Type__c,
                B2BCreditCardName__c,
                TotalProductAmount
            FROM WebCart
            WHERE Id = :webCartId
        ];

        Boolean isCardChanged = false;
        if (cart.Payment_Type__c == null) {
            cart.Payment_Type__c = hasInvoicePayment ? METHOD_INVOICE : METHOD_CREDIT_CARD;
            isCardChanged = true;
        }

        if (cart.B2BCreditCardId__c == null && !creditCards.isEmpty()) {
            cart.B2BCreditCardId__c = initCreditCardId();
            cart.B2BCreditCardName__c = null;
            isCardChanged = true;
        } else if (cart.B2BCreditCardId__c != null) {
            Boolean creditCardExisted = false;
            for (B2BPayPal.CreditCardDto card : creditCards) {
                if (cart.B2BCreditCardId__c == card.id) {
                    creditCardExisted = true;
                    break;
                }
            }

            if (!creditCardExisted) {
                cart.B2BCreditCardId__c = initCreditCardId();
                cart.B2BCreditCardName__c = null;
                isCardChanged = true;
            }
        }

        if (isCardChanged) {
            update cart;
        }

        poNumber = cart.PoNumber;
        hasDarleyDollars = cart.B2BHasDarleyDollars__c;
        paymentMethod = cart.Payment_Type__c;
        selectedCreditCardId = cart.B2BCreditCardId__c;
        isInvoiceMyCompany = cart.Payment_Type__c == null ? false : cart.Payment_Type__c == METHOD_INVOICE;
        darleyDollarAmount = Math.min(darleyDollarAll, Math.floor(cart.TotalProductAmount * DARLEY_DOLLAR_MAX_PERCENT));
        publicKey = B2BRSA.MODULE;
        publicExponent = B2BRSA.PUBLIC_EXPONENT;
    }

    private String initCreditCardId() {
        if (!creditCards.isEmpty()) {
            B2BPayPal.CreditCardDto selectedCreditCard = creditCards[0];
            for (B2BPayPal.CreditCardDto card : creditCards) {
                if (card.isDefault) {
                    selectedCreditCard = card;
                    break;
                }
            }

            return selectedCreditCard.id;
        }

        return null;
    }

    public class B2BCheckoutPaymentException extends Exception {}

}