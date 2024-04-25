/**
 * Created by faruck on 25/04/23.
 * Updated by Piotr Harbunou 07/06/23
 */

public with sharing class B2BAmazonPayment {

	private static final String RETURN_URL = '/checkout';

	private static Id getContactId(){
		User currentUser = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
		return currentUser.ContactId;
	}

	@AuraEnabled
	public static B2BResponse getButtonSignature(String amount, String merchantReferenceId) {
		try {
			WebCart cart = [
				SELECT
					Id,
					B2BCheckoutShippingAddress__r.Name,
					B2BCheckoutShippingAddress__r.Street,
					B2BCheckoutShippingAddress__r.City,
					B2BCheckoutShippingAddress__r.State,
					B2BCheckoutShippingAddress__r.PostalCode,
					B2BCheckoutShippingAddress__r.CountryCode,
					AccountId,
					IsSecondary
				FROM WebCart
				WHERE Id = :merchantReferenceId LIMIT 1
			];
			Account account = [SELECT Phone FROM Account WHERE Id = :cart.AccountId];

			B2BAmazonConfiguration__mdt configurations = B2BAmazonConfiguration__mdt.getInstance('AmazonConfiguration');
			if (configurations.EndpointCheckout__c == null
				|| configurations.EndpointSign__c == null
				|| configurations.MerchantId__c == null
				|| configurations.PublicKey__c == null
				|| configurations.StoreId__c == null
				|| configurations.SubscriptionKey__c == null
			) {
				throw new B2BAmazonPaymentException('Something went wrong with Amazon Payment. Please try again later.');
			}

			//This PhoneNumber is mandatory, otherwise set a default phone to prevent payment failure
			String phoneNumber =  String.isNotBlank(account.Phone) ? account.Phone : '888000000';
			B2BAmazonPayment.AddressDetails addressDetails = new AddressDetails(cart.B2BCheckoutShippingAddress__r.Name, cart.B2BCheckoutShippingAddress__r.Street, cart.B2BCheckoutShippingAddress__r.City, cart.B2BCheckoutShippingAddress__r.State, cart.B2BCheckoutShippingAddress__r.PostalCode, cart.B2BCheckoutShippingAddress__r.CountryCode, phoneNumber);
			String buttonSignature =  getPayloadSignRequest(amount, merchantReferenceId,addressDetails, configurations, cart.IsSecondary, cart.Id);
			System.debug(buttonSignature);
			return new B2BResponse(true, new Map<String, String> { 'buttonSignature' => buttonSignature }, 'Success');
		} catch (Exception exp) {
			return new B2BResponse(false, exp.getMessage());
		}
	}

	@TestVisible
	private static String getPayloadSignRequest(String amount, String merchantReferenceId, B2BAmazonPayment.AddressDetails addressDetails, B2BAmazonConfiguration__mdt configurations, Boolean isSecondaryCard, Id cartId) {
		B2BAmazonPayment.PaymentDetails paymentDetails = new PaymentDetails('AuthorizeWithCapture', new ChargeAmount(amount, 'USD'), 'USD');
		B2BAmazonPayment.MerchantMetadata merchantMetadata = new MerchantMetadata(merchantReferenceId, 'Darley-Store', 'Thank you for your order');
		CreateCheckoutSessionConfig sessionConfig =  getPayloadSign(paymentDetails, merchantMetadata, addressDetails, configurations, merchantReferenceId, isSecondaryCard, cartId);
		return createJSonStructure(sessionConfig, configurations);
	}

	private static String createJSonStructure(CreateCheckoutSessionConfig sessionConfig, B2BAmazonConfiguration__mdt configurations) {
		// Create a new JsonResponse object
		JsonResponse response = new JsonResponse();

		// Fill in the fields
		response.ledgerCurrency = 'USD';
		response.merchantId = configurations.MerchantId__c;
		response.placement = 'Checkout';
		response.productType = 'PayAndShip';
		response.checkoutLanguage = 'en_US';
		response.buttonColor = 'Gold';
		response.publicKeyId = configurations.PublicKey__c;
		response.popup = true;
		// Create a new CreateCheckoutSessionConfig object
		response.createCheckoutSessionConfig = sessionConfig;

		// Convert the JsonResponse object into a JSON string
		return JSON.serialize(response);
	}

	@TestVisible
	private static CreateCheckoutSessionConfig getPayloadSign(
		B2BAmazonPayment.PaymentDetails paymentDetails,
		B2BAmazonPayment.MerchantMetadata merchantMetadata,
		B2BAmazonPayment.AddressDetails addressDetails,
		B2BAmazonConfiguration__mdt configurations,
		String merchantReferenceId,
		Boolean isSecondaryCard,
		Id cartId
	) {
		// Construct the request
		HttpRequest request = new HttpRequest();
		request.setEndpoint(configurations.EndpointSign__c);
		request.setMethod('POST');
		request.setHeader('subscription_key', configurations.SubscriptionKey__c);
		request.setHeader('Content-Type', 'application/json');
		PayloadSignRequest payload = new PayloadSignRequest();

		B2BSettings__c b2BSettings = B2BSettings__c.getInstance();

		String returnParameters = isSecondaryCard ? RETURN_URL + '?recordId=' + merchantReferenceId : RETURN_URL;
		String returnUrl = b2BSettings != null ? b2BSettings.CommunityURL__c + returnParameters : '';
		if (String.isEmpty(returnUrl)) {
			throw new B2BAmazonPaymentException('Something went wrong with Amazon Payment. Please try again later.');
		}
		payload.webCheckoutDetails = new WebCheckoutDetails(returnUrl, 'ProcessOrder');

		payload.storeId = configurations.StoreId__c;
		payload.scopes = new List<String>{
			'name', 'email', 'phoneNumber', 'billingAddress'
		};
		payload.paymentDetails = paymentDetails;

		payload.merchantMetadata = merchantMetadata;
		payload.addressDetails = addressDetails;
		request.setBody(JSON.serialize(payload));
		System.debug(JSON.serialize(payload));

		CreateCheckoutSessionConfig sessionConfig = new CreateCheckoutSessionConfig(null,null);
		sessionConfig.payloadJSON = JSON.serialize(payload);

		// Send the request
		Http http = new Http();
		HttpResponse response = http.send(request);

		// Process the response
		if (response.getStatusCode() == 200) {
			// Success!
			System.debug(response.getBody());
			Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
			Map<String, Object> dataMap = (Map<String, Object>) responseData.get('data');
			String signResult = (String) dataMap.get('signResult');
			sessionConfig.signature = signResult;
		} else {
			System.debug('Error: ' + response.getStatusCode() + ' ' + response.getStatus());
			Id contactId = getContactId();
			Rest_Log__c log = B2BHttpLogService.createLog(contactId, response, request);
			log.Cart__c = cartId;
			B2BHttpLogService.addLog(log);
			B2BHttpLogService.saveLogs();
		}

		return sessionConfig;
	}

	public static CheckoutResponse completeCheckout(String sessionId, String amount, Id cartId) {
		B2BAmazonConfiguration__mdt configurations = B2BAmazonConfiguration__mdt.getInstance('AmazonConfiguration');
		if (configurations.EndpointCheckout__c == null
			|| configurations.SubscriptionKey__c == null
		) {
			throw new B2BAmazonPaymentException('Something went wrong with Amazon Payment. Please try again later.');
		}

		Payload payload = new Payload();
		payload.chargeAmount = new ChargeAmount(amount, 'USD');

		HttpRequest request = new HttpRequest();
		request.setEndpoint(configurations.EndpointCheckout__c);
		request.setMethod('POST');
		request.setHeader('subscription_key', configurations.SubscriptionKey__c);
		request.setHeader('Content-Type', 'application/json');

		Map<String, Object> requestData = new Map<String, Object>{
			'sessionID' => sessionId,
			'payload' => payload
		};

		String requestBody = JSON.serialize(requestData);
		request.setBody(requestBody);
		System.debug(requestBody);

		Http http = new Http();
		HttpResponse response = http.send(request);
		System.debug(response.getBody());
		CheckoutResponse checkoutResponse = new CheckoutResponse();
		if (response.getStatusCode() == 200) {
			String jsonString = response.getBody(); // Replace with your actual JSON string.
			JsonCheckoutResponse deserializedResponse = (JsonCheckoutResponse) JSON.deserialize(jsonString, JsonCheckoutResponse.class);
			String chargeId = deserializedResponse.chargeId;
			//save the charge Id to message response
			//Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
			checkoutResponse.success = true;
			checkoutResponse.message = chargeId;
		} else {
			checkoutResponse.success = false;
			checkoutResponse.message = 'HTTP ' + response.getStatusCode() + ' ' + response.getStatus();
		}

		Id contactId = getContactId();
		Rest_Log__c log = B2BHttpLogService.createLog(contactId, response, request);
		log.Cart__c = cartId;
		B2BHttpLogService.addLog(log);
		B2BHttpLogService.saveLogs();
		return checkoutResponse;
	}


	//Wrapper CheckoutComplete Payment session json response
	public class JsonCheckoutResponse {
		public String chargeId;
	}

	//--------------------------------------------------------------------------
	//button Payload Wrapper
	public class JsonResponse {
		public String ledgerCurrency;
		public String merchantId;
		public String placement;
		public String productType;
		public String checkoutLanguage;
		public String buttonColor;
		public String publicKeyId;
		public Boolean popup;
		public CreateCheckoutSessionConfig createCheckoutSessionConfig;

		public  JsonResponse parse(String json) {
			return (JsonResponse) System.JSON.deserialize(json, JsonResponse.class);
		}

		public String toJson() {
			return System.JSON.serialize(this);
		}
	}

	public class CreateCheckoutSessionConfig {
		public String payloadJSON;
		public String signature;

		public CreateCheckoutSessionConfig(String payloadJSON,String signature){
			this.payloadJSON = payloadJSON;
			this.signature = signature;
		}
	}

	//--------------------------------------------------------------------------
	//Checkout Session Payload Wrapper
	public class Payload {
		public ChargeAmount chargeAmount;
	}

	public class CheckoutResponse {
		public Boolean success { get; set; }
		public String message  { get; set; }
	}

	//--------------------------------------------------------------------------
	//Sign Request Payload Wrapper
	public class PayloadSignRequest {
		public WebCheckoutDetails webCheckoutDetails;
		public String storeId;
		public List<String> scopes;
		public PaymentDetails paymentDetails;
		public MerchantMetadata merchantMetadata;
		public AddressDetails addressDetails;
	}

	public class WebCheckoutDetails {
		public String checkoutResultReturnUrl;
		public String checkoutMode;

		public WebCheckoutDetails(String checkoutResultReturnUrl, String checkoutMode) {
			this.checkoutResultReturnUrl = checkoutResultReturnUrl;
			this.checkoutMode = checkoutMode;
		}
	}

	public class PaymentDetails {
		public String paymentIntent;
		public ChargeAmount chargeAmount;
		public String presentmentCurrency;

		public PaymentDetails(String paymentIntent, ChargeAmount chargeAmount, String presentmentCurrency) {
			this.paymentIntent = paymentIntent;
			this.chargeAmount = chargeAmount;
			this.presentmentCurrency = presentmentCurrency;
		}
	}

	public class ChargeAmount {
		public String amount;
		public String currencyCode;

		public ChargeAmount(String amount, String currencyCode) {
			this.amount = amount;
			this.currencyCode = currencyCode;
		}
	}

	public class MerchantMetadata {
		public String merchantReferenceId;
		public String merchantStoreName;
		public String noteToBuyer;

		public MerchantMetadata(String merchantReferenceId, String merchantStoreName, String noteToBuyer) {
			this.merchantReferenceId = merchantReferenceId;
			this.merchantStoreName = merchantStoreName;
			this.noteToBuyer = noteToBuyer;
		}
	}

	public class AddressDetails {
		public String name;
		public String addressLine1;
		public String city;
		public String stateOrRegion;
		public String postalCode;
		public String countryCode;
		public String phoneNumber;

		public AddressDetails(String name, String addressLine1, String city, String stateOrRegion, String postalCode, String countryCode, String phoneNumber ) {
			this.name = name;
			this.addressLine1 = addressLine1;
			this.city = city;
			this.stateOrRegion = stateOrRegion;
			this.postalCode = postalCode;
			this.countryCode = countryCode;
			this.phoneNumber = phoneNumber;
		}
	}

	public class B2BAmazonPaymentException extends Exception {}
}