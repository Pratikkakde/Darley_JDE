@isTest
public class B2BAmazonPaymentTest {

	@isTest
	static void testGetPayloadSignRequest() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new B2BAmazonPaymentMockGenerator(false));
		B2BAmazonConfiguration__mdt amazonConfiguration = new B2BAmazonConfiguration__mdt();
		amazonConfiguration.put('EndpointCheckout__c', 'https://darley-amz.herokuapp.com/completeCheckout');
		amazonConfiguration.put('EndpointSign__c', 'https://darley-amz.herokuapp.com/payloadSign');
		amazonConfiguration.put('MerchantId__c', 'test');
		amazonConfiguration.put('PublicKey__c', 'test');
		amazonConfiguration.put('StoreId__c', 'test');
		amazonConfiguration.put('SubscriptionKey__c', 'test');

		String payloadSign = B2BAmazonPayment.getPayloadSignRequest('100', 'test', null, amazonConfiguration, true, null);
		Test.stopTest();

		System.assert(payloadSign != null, 'Payload Sign should not be empty');
	}

	@isTest
	static void testGetPayloadSign() {
		B2BAmazonConfiguration__mdt amazonConfiguration = new B2BAmazonConfiguration__mdt();
		amazonConfiguration.put('EndpointCheckout__c', 'https://darley-amz.herokuapp.com/completeCheckout');
		amazonConfiguration.put('EndpointSign__c', 'https://darley-amz.herokuapp.com/payloadSign');
		amazonConfiguration.put('MerchantId__c', 'test');
		amazonConfiguration.put('PublicKey__c', 'test');
		amazonConfiguration.put('StoreId__c', 'test');
		amazonConfiguration.put('SubscriptionKey__c', 'test');

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new B2BAmazonPaymentMockGenerator(false));

		B2BAmazonPayment.PaymentDetails paymentDetails = new B2BAmazonPayment.PaymentDetails('AuthorizeWithCapture', new B2BAmazonPayment.ChargeAmount('10', 'USD'), 'USD');
		B2BAmazonPayment.MerchantMetadata merchantMetadata = new B2BAmazonPayment.MerchantMetadata('Merchant-order-123', 'test', 'Thank you for your order');
		B2BAmazonPayment.AddressDetails addressDetails = new B2BAmazonPayment.AddressDetails('Christopher C. Conn', '4996 Rockford Mountain Lane', 'Appleton', 'WI', '54911', 'US', '4259415758');

		B2BAmazonPayment.getPayloadSign(paymentDetails, merchantMetadata, addressDetails, amazonConfiguration, 'testId', true, null);

		Test.stopTest();
	}

	@isTest
	static void testCompleteCheckout() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new B2BAmazonPaymentMockGenerator(false));

		String sessionId = 'some-session-id';
		String amount = '10';

		B2BAmazonPayment.CheckoutResponse response = B2BAmazonPayment.completeCheckout(sessionId, amount, null);
		System.assertEquals(true, response.success);
		System.assertEquals('Checkout completed successfully', response.message);

		Test.stopTest();
	}

	public class B2BAmazonPaymentMockGenerator implements HttpCalloutMock {
		public Boolean isFailed { get; set; }

		public B2BAmazonPaymentMockGenerator(Boolean isFailed) {
			this.isFailed = isFailed;
		}

		public HttpResponse respond(HttpRequest request) {
			HttpResponse response = new HttpResponse();
			response.setHeader('Content-Type', 'application/json');
			response.setStatusCode(200);

			System.debug('111 request.getEndpoint()' + request.getEndpoint());

			if (request.getEndpoint().contains('payloadSign')) {
				if (isFailed == false) {
					response.setBody('{"success": true, "message": "Payload signed successfully", "data": {"signResult": "testSign"}}');
				}
			} else if (request.getEndpoint().contains('completeCheckout')) {
				if (isFailed == false) {
					response.setBody('{"success": true, "chargeId": "Checkout completed successfully"}');
				}
			}

			return response;
		}
	}
}