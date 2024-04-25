public without sharing class B2BPayPal {
    private B2B_PayPalConfiguration__mdt payPalConfiguration;
    private Id recordId;
    
    public static Id staticRecordId;

    public B2BPayPal() {
        this.payPalConfiguration = B2B_PayPalConfiguration__mdt.getInstance('PayPal_Configuration');
    }

    public void setRecordId(Id recordId){
        this.recordId = recordId;
    }

    public B2BPayPalWrapper.PaymentInfoResponse authorize(B2BPayPalWrapper.paymentInfo paymentInfo){
        String body = B2BPayPalService.authorizeRequestBody( this.payPalConfiguration, paymentInfo);
        B2BHttpUtils request = new B2BHttpUtils(this.recordId, this.payPalConfiguration.EndPoint__c, B2BHttpUtils.CONTENT_TYPE.FORM, body, true);
        request.method = B2BHttpUtils.REQUEST_TYPE.POST;

        HttpResponse response = request.submitRequest();
        if (request.requestErrors) {
            B2BHttpLogService.saveLogs();
            throw new B2BPayPalException(request.requestException.getMessage());
        }

        if (response.getBody() == '' && response.getStatusCode() == 404) {
            B2BHttpLogService.saveLogs();
            throw new B2BPayPalException('Response body is empty. Please check you PayPal configuration settings.');

        }

        return  B2BPayPalService.processPayflowInfoResponse(response.getBody());
    }

    public static B2BPayPalWrapper.PaymentInfoResponse validateCard(B2BPayPalWrapper.paymentInfo paymentInfo) {
        B2BPayPal payflow = new B2BPayPal();
        payflow.setRecordId(staticRecordId);
        paymentInfo.savePaymentMethod = true;
        paymentInfo.amount = 0;
        B2BPayPalWrapper.PaymentInfoResponse payflowResponse = payflow.authorize(paymentInfo);

        return payflowResponse;
    }

    public List<CreditCardDto> getCustomerCards(Id contactId){
        List<CreditCardDto> creditCards = new List<CreditCardDto>();
        for (CustomerCardPayment__c customerCard : [
            SELECT
                Id,
                Name,
                Card_Type__c,
                Is_Default__c,
                Card_Last_Four__c,
                Expiration_Month__c,
                Expiration_Year__c
            FROM CustomerCardPayment__c
            WHERE Contact__c = :contactId
                AND Is_Token_Expired__c = FALSE
        ]) {
            creditCards.add(new CreditCardDto(customerCard));
        }

        return creditCards;
    }

    public class CreditCardDto {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String cardType { get; set; }
        @AuraEnabled public Boolean isDefault { get; set; }

        @AuraEnabled public String lastFour { get; set; }
        @AuraEnabled public String expirationDate { get; set; }
        @AuraEnabled public String cardNumber { get; set; }
        @AuraEnabled public String cvv { get; set; }

        @AuraEnabled public Decimal amount { get; set; }
        @AuraEnabled public Boolean isSaveCard { get; set; }

        private CustomerCardPayment__c customerCardPayment;
        private String token;
        private B2BPayPalWrapper.paymentInfo paymentInfo;
        private B2BPayPalWrapper.PaymentInfoResponse payflowResponse;

        public CreditCardDto(CustomerCardPayment__c customerCard) {
            id = customerCard.Id;
            name = customerCard.Name;
            cardType = customerCard.Card_Type__c;
            isDefault = customerCard.Is_Default__c;

            lastFour = customerCard.Card_Last_Four__c;
            expirationDate = customerCard.Expiration_Month__c + '/' + customerCard.Expiration_Year__c;
        }

        public CreditCardDto() {}

        public void decrypt() {
            B2BRSA rsa = new B2BRSA();
            cardNumber = cardNumber == null ? cardNumber : rsa.decrypt(cardNumber);
            expirationDate = expirationDate == null ? expirationDate : rsa.decrypt(expirationDate);
            cvv = cvv == null ? cvv : rsa.decrypt(cvv);
        }

        public String pay(Id contactId) {
            initPaymentInfo();
            validate(contactId);

            paymentInfo.amount = amount;
            paymentInfo.savePaymentMethod = isSaveCard;

            B2BPayPal payflow = new B2BPayPal();
            payflow.setRecordId(contactId);
            if(token == null) {
                CustomerCardPayment__c customerCardPayment  = [
                    SELECT
                        Token__c,
                        Card_Type__c,
                        Card_Last_Four__c
                    FROM CustomerCardPayment__c
                    WHERE Id = :id
                ];
                token = customerCardPayment.Token__c;
                cardType = customerCardPayment.Card_Type__c;
                lastFour = customerCardPayment.Card_Last_Four__c;
            }

            paymentInfo.originalTransactionReferencedId = token;
            payflowResponse =  payflow.authorize(paymentInfo);

            if (payflowResponse.result != '0') {
                throw new B2BPayPalException('An error occurred. Please try again or use a different payment method');
            }

            return payflowResponse.pnref;
        }

        public void saveCard(Id contactId) {
            List<CustomerCardPayment__c> cards = new List<CustomerCardPayment__c>();
            if (isSaveCard) {
                cards.add(customerCardPayment);
                if (isDefault) {
                    for (CustomerCardPayment__c existedCard : [
                        SELECT Id, Is_Default__c
                        FROM CustomerCardPayment__c
                        WHERE Is_Default__c = TRUE
                            AND Contact__c = :contactId
                    ]) {
                        existedCard.Is_Default__c = false;
                        cards.add(existedCard);
                    }
                }

                if (!cards.isEmpty()) {
                    upsert cards;
                }
            }
        }

        public String getCardName() {
            return this.cardType + ' ending in ' + this.lastFour;
        }

        private void initPaymentInfo() {
            paymentInfo = new B2BPayPalWrapper.paymentInfo();

            paymentInfo.crediCardNumber = cardNumber;
            paymentInfo.crediCardExpirationDate = expirationDate;
            paymentInfo.crediCardCVC = cvv;
            paymentInfo.amount = amount;

            paymentInfo.savePaymentMethod = isSaveCard;
            paymentInfo.cartType = cardType;
            paymentInfo.cardHolderName = name;
            paymentInfo.isDefault = isDefault;
        }

        private void initCustomerCardPayment(Id contactId) {
            token = payflowResponse.pnref;
            customerCardPayment = new CustomerCardPayment__c(
                Contact__c = contactId,
                Card_Type__c = cardType,
                Card_Last_Four__c = lastFour,
                Name = name,
                Is_Default__c = isDefault,
                Token__c = token,
                Expiration_Month__c = expirationDate == null ? '' : expirationDate.left(2),
                Expiration_Year__c = expirationDate == null ? '' : '20' + expirationDate.right(2)
            );
        }

        private void validate(Id contactId) {
            if (id == null) {
                B2BPayPal payflow = new B2BPayPal();
                payflow.setRecordId(contactId);
                paymentInfo.amount = 0;
                payflowResponse = payflow.authorize(paymentInfo);
                if (payflowResponse.result == '0') {
                    initCustomerCardPayment(contactId);
                } else {
                    throw new B2BPayPalException('An error occurred. Please try again or use a different payment method');
                }
            }
        }
    }

    public class B2BPayPalException extends Exception {}
}