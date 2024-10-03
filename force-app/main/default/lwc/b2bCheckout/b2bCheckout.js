// TODO: Develop "B2B Checkout Section" component
// TODO: Replace Custom labels
// TODO: Check styles position

import { LightningElement, track, api, wire } from 'lwc';
import { UTILS, IS, DISPATCHER } from 'c/b2bUtils';
import { NavigationMixin } from 'lightning/navigation';
import { CartSummaryAdapter } from 'commerce/cartApi'; // USED TO GET ACTIVE CART DATA
import { CurrentPageReference } from 'lightning/navigation';

// METHODS
import initAddresses from '@salesforce/apex/B2BCheckoutController.initAddresses';
import initCartItems from '@salesforce/apex/B2BCheckoutController.initCartItems';
import initOrderSummary from '@salesforce/apex/B2BCheckoutController.initOrderSummary';
import initTaxes from '@salesforce/apex/B2BCheckoutController.calculateTaxes';
import deleteAllTaxes from '@salesforce/apex/B2BCheckoutController.deleteAllTaxes';
import initInstruction from '@salesforce/apex/B2BCheckoutController.initInstruction';
import initPayment from '@salesforce/apex/B2BCheckoutController.initPayment';
import addAddress from '@salesforce/apex/B2BCheckoutController.addAddress';
import useAddress from '@salesforce/apex/B2BCheckoutController.useAddress';
import updateInstruction from '@salesforce/apex/B2BCheckoutController.updateInstruction';
import useCard from '@salesforce/apex/B2BCheckoutController.useCard';
import setPaymentMethod from '@salesforce/apex/B2BCheckoutController.setPaymentMethod';
import updatePoNumber from '@salesforce/apex/B2BCheckoutController.updatePoNumber';
import placeOrder from '@salesforce/apex/B2BCheckoutController.placeOrder';
import calculateShipping from '@salesforce/apex/B2BCheckoutController.calculateShipping';

import saveCusomerNumber from '@salesforce/apex/B2BRequestForQuoteController.saveCusomerNumber';
// import getSavedCreditCards from '@salesforce/apex/B2BCheckoutController.getSavedCreditCards';

//To use subscription functionality uncomment this part
// import clearSubscriptionInfo from '@salesforce/apex/B2BSubscriptionController.saveSubscriptionInfo';
//-----------------------------------------------------

//LABELS
import checkout from '@salesforce/label/c.B2B_Checkout';
import checkoutError from '@salesforce/label/c.B2B_An_internal_error_has_occurred_Continuation_is_impossible';
import placeOrderLabel from '@salesforce/label/c.B2B_Place_order';
import placeOrderTitle from '@salesforce/label/c.B2B_Click_to_place_an_order';
import payOrderSuccess from '@salesforce/label/c.B2B_The_payment_was_successful';
import payOrderError from '@salesforce/label/c.B2B_Payment_was_declined_Please_check_your_credit_card_details';
import placeOrderError from '@salesforce/label/c.B2B_It_was_not_possible_to_place_the_order';
import updateInstructionSuccess from '@salesforce/label/c.B2B_The_Special_Instructions_was_successfully_added';
import updateInstructionSuccessDeleted from '@salesforce/label/c.B2B_The_Special_Instructions_was_successfully_deleted';
import updateInstructionError from '@salesforce/label/c.B2B_Failed_to_add_a_Special_Instructions_Try_again_later';
import addYourAddressSuccess from '@salesforce/label/c.B2B_The_address_was_successfully_added';
import addYourAddressError from '@salesforce/label/c.B2B_Failed_to_add_a_new_address_Try_again_later';
import editYourAddressSuccess from '@salesforce/label/c.B2B_The_address_was_successfully_updated';
import editYourAddressError from '@salesforce/label/c.B2B_Failed_to_update_the_address_Try_again_later';
import useYourAddressSuccess from '@salesforce/label/c.B2B_The_address_was_successfully_selected';
import useYourAddressError from '@salesforce/label/c.B2B_The_address_was_not_selected_Try_again_later';
import addCreditCardSuccess from '@salesforce/label/c.B2B_The_Credit_Card_was_successfully_added';
import addCreditCardError from '@salesforce/label/c.B2B_Failed_to_add_a_new_Credit_Card_Try_again_later';
import useCreditCardSuccess from '@salesforce/label/c.B2B_The_Credit_Card_was_successfully_selected';
import useCreditCardError from '@salesforce/label/c.B2B_The_Credit_Card_was_not_selected_Try_again_later';
import poNumberSuccess from '@salesforce/label/c.B2B_PO_Number_saved_successfully';
import poNumberError from '@salesforce/label/c.B2B_Failed_to_save_PO_Number_Try_again_later';
import failedToSaveData from '@salesforce/label/c.B2B_Failed_to_save_data';
import orderSummary from '@salesforce/label/c.B2B_Order_Summary';
import subtotal from '@salesforce/label/c.B2B_Subtotal';
import estimatedTax from '@salesforce/label/c.B2B_Estimated_tax';
import orderTotal from '@salesforce/label/c.B2B_Order_Total';
import promotions from '@salesforce/label/c.B2B_Promotions';
import estimatedShipping from '@salesforce/label/c.B2B_Estimated_Shipping';

// STATIC RESOURCES
const COMPONENT_NAME = 'b2b-checkout';
const CHECKOUT_PAGE = 'checkout_page';
const UPDATE_CHECKOUT_HEADER = 'update_checkout_header';
const ADD = 'ADD';
const CREDIT_CARD = 'Credit Card';
const INVOICE = 'Invoice';

const FRAME_LOADED = 'DOMContentLoadedForPaymentConfirmation';
const SEND_PUBLIC_KEY = 'handlePubKey';
const CONFIRM_PAYMENT = 'confirmPayment';

const LABELS = {
    selectAnOption: 'Select an Option', // B2B_Select_an_Option

    // CHECKOUT
    checkout: checkout,
    checkoutError: checkoutError,
    placeOrder: placeOrderLabel,
    placeOrderTitle: placeOrderTitle,
    payOrderSuccess: payOrderSuccess,
    payOrderError: payOrderError,
    placeOrderError: placeOrderError,

    // INFO
    updateInstructionSuccess: updateInstructionSuccess,
    updateInstructionSuccessDeleted: updateInstructionSuccessDeleted,
    updateInstructionError: updateInstructionError,

    // ADDRESSES
    addYourAddressSuccess: addYourAddressSuccess,
    addYourAddressError: addYourAddressError,
    editYourAddressSuccess: editYourAddressSuccess,
    editYourAddressError: editYourAddressError,
    useYourAddressSuccess : useYourAddressSuccess,
    useYourAddressError: useYourAddressError,

    // PAYMENT
    addCreditCardSuccess : addCreditCardSuccess,
    addCreditCardError: addCreditCardError,
    useCreditCardSuccess : useCreditCardSuccess,
    useCreditCardError: useCreditCardError,
    poNumberSuccess: poNumberSuccess,
    poNumberError: poNumberError,
    failedToSaveData: failedToSaveData,

    // ORDER SUMMARY
    orderSummary: orderSummary,
    items: subtotal,
    salesTax: estimatedTax,
    orderTotal: orderTotal,
    promotions: promotions,
    estimatedShipping: estimatedShipping,

    //TAX EXEMPT
    areYou: 'Are you',
    taxExempt: 'Tax Exempt?',
    modalTaxExemptTitle: 'Tax Exempt'
};

export default class B2bCheckout extends NavigationMixin(LightningElement) {
    @api recordId = null;
    @api enableSubscriptions = false;

    @track effectiveAccountId = null;
    @track isBuilder = UTILS.isBuilder();
    @track isLoading = true;
    @track isUpdateLoading = false;
    @track isFirstRender = true;
    @track customCssContainer = UTILS.customCssContainer;
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);

    @track labels = LABELS;
    @track isFatalError = false;
    @track isFatalMessage = null;
    @track currencyIsoCode = null;
    urlRecordId = null;
    amazonCheckoutSessionId = null;

    // ADDRESSES
    @track isAddressUpdating = false;
    @track isAddressValid = false;
    @track isTaxesValid = false;
    @track isAddressError = false;
    @track countryOptions = [];
    @track stateOptions = {};
    @track shippingSelected = null;
    @track shippingAddresses = [];
    @track billingSelected = null;
    @track billingAddresses = [];
    @track sameAddresses = false;

    // INFO
    @track isInfoUpdating = false;
    @track specialInstructions = null;

    // PAYMENT
    @track isPaymentUpdating = false;
    @track isPaymentValid = false;
    @track paymentSelected = null;
    @track paymentTypes = {
        card: CREDIT_CARD,
        invoice: INVOICE,
    };
    @track paymentList = [];
    @track isInvoiceMyCompany = false;
    @track poNumber = null;
    @track isAccountCreditTerms = false;
    @track hasInvoicePayment = false;
    @track paymentMethod;
    @track expirationDateMin;
    @track darleyDollarAmount = 0;
    @track hasDarleyDollar = false;
    @track hasPaymentSection = false;
    publicKey = null;
    publicExponent = null;

    // REVIEW
    @track products = [];
    @track isCartSecondary = false;
    
    // ORDER SUMMARY
    @track items = 0;
    @track salesTax = 0;
    @track promotion = 0;
    @track total = 0;
    @track totalChargeAmount = 0;
    displayCertificateModal = false;
    certElement;

    // STRIPE
    @track showStripeModal = false;
    @track stripeFormLink = null;
    @track stripePublicKey = null;
    @track paymentClientSecret = null;

    //TAX EXEMPT
    @track customerInfo = {};
    @track customerTaxInformation = {};
    avalaraCustomerCode;
    isNewAvalaraCustomer;
    @track showTaxExempt;
    urlRecordId = null;
    amazonCheckoutSessionId = null;

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper}`;
    }

    get getTotal() {
        return this.hasDarleyDollar ? this.total - this.darleyDollarAmount : this.total;
    }

    get showReviewSpinner() {
        return this.isLoading || this.isUpdateLoading;
    }

    get getCurrencyIsoCode() {
        return this.currencyIsoCode || UTILS.currencyIsoCode;
    }

    get getAddressValidty() {
        return !this.isAddressUpdating &&
            this.isAddressValid &&
            !this.isAddressError &&
            IS.stringNotEmpty(this.shippingSelected) &&
            IS.stringNotEmpty(this.billingSelected);
    }

    get getPaymentValidty() {
        return !this.isPaymentUpdating &&
            this.isPaymentValid;
    }

    get getMethodValidty() {
        return !this.isInfoUpdating;
    }

    get isPlaceOrderButtonDisabled() {
        let isPlaceOrderDisabled = this.isLoading ||
            this.isUpdateLoading ||
            !this.getAddressValidty ||
            !this.getMethodValidty ||
            !IS.arrayNotEmpty(this.products);
        const checkoutPayment = this.template.querySelector('c-b2b-checkout-payment');

        if (checkoutPayment) {
            checkoutPayment.setButtonPlaceOrderDisabled(isPlaceOrderDisabled);
        }

        return isPlaceOrderDisabled;
    }

    //To use subscription functionality uncomment this part
//     @track subscriptionValid = true;
//
//     get showSubscription() {
//         //show for credit card only
//         return this.enableSubscriptions && IS.stringNotEmpty(this.paymentSelected) && !this.isInvoiceMyCompany;
//     }
//
//     handleSubscriptionValidity(event) {
//         this.subscriptionValid = event.detail;
//     }
//-----------------------------------------------------

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlRecordId = currentPageReference.state?.recordId;
            this.amazonCheckoutSessionId = currentPageReference.state?.amazonCheckoutSessionId;
        }
    }

    isDataInitialized = false;
    @wire(CartSummaryAdapter, {'cartStateOrId': 'active'})
    async wiredCartSummaryData(result) {
        if (result.loaded) {
            if (IS.stringNotEmpty(this.recordId) && this.isDataInitialized === false) {
                this.getInitialData();
            } else if (
                IS.objectNotEmpty(result)
                && IS.objectNotEmpty(result.data)
                && IS.stringNotEmpty(result.data.cartId)
                && this.isDataInitialized === false
            ) {
                this.recordId = result.data.cartId;
                this.getInitialData();
            }
        }
    }

    // LIFECYCLES
    async connectedCallback() {}
    
    renderedCallback() {
        if (this.isFirstRender) {
            this.isFirstRender = false;
            this.addCustomCssStyles();
            this.isPlaceOrderButtonDisabled;
        }
    }

    disconnectedCallback() {}

    // METHODS
    addCustomCssStyles() {
        let styleText = `
            /* SECTION */
            .${COMPONENT_NAME}__section {
                position: relative;
                display: flex;
                flex-wrap: wrap;
                border-bottom: 1px solid transparent;
            }

            .${COMPONENT_NAME}__section-title {
                order: 1;
                width: 35%;
            }

            @media(max-width: 1199.98px) {
                .${COMPONENT_NAME}__section-title {
                    width: calc(100% - 80px);
                }
            }

            .${COMPONENT_NAME}__section-content {
                position: relative;
                order: 2;
                width: 57%;
                padding: 5px 0.5rem 0 0.5rem;
            }

            @media(max-width: 1199.98px) {
                .${COMPONENT_NAME}__section-content {
                    order: 3;
                    width: 100%;
                    padding: 1rem 0 0 0;
                }
            }

            .${COMPONENT_NAME}__section-action {
                order: 3;
                width: 8%;
            }

            @media(max-width: 1199.98px) {
                .${COMPONENT_NAME}__section-action {
                    order: 2;
                    width: 80px;
                }
            }

            .${COMPONENT_NAME}__section-form {
                position: relative;
                order: 4;
                width: 100%;
            }

            .${COMPONENT_NAME}__section-form-wrapper {
                padding: 1rem 0 0 0;
            }

            @media(max-width: 1199.98px) {
                .${COMPONENT_NAME}__section-form-wrapper {
                    padding: 0;
                }
            }

            /* SECTION TITLE */
            .${COMPONENT_NAME}__section-title-wrapper {
                display: flex;
                align-items: center;
                justify-content: flex-start;
            }

            .${COMPONENT_NAME}__section-title-number {
                display: flex;
                align-items: center;
                justify-content: center;
                width: 32px;
                height: 32px;
                font-size: 14px;
                line-height: 1;
                font-weight: 700;
                color: #ffffff;
                background-color: #231F20;
                border-radius: 50%;
            }

            @media(max-width: 574.98px) {
                .${COMPONENT_NAME}__section-title-number {
                    display: none;
                }
            }

            .${COMPONENT_NAME}__section-title-label {
                margin-left: 1rem;
                font-size: 18px;
                line-height: 1;
                font-weight: 700;
                text-transform: uppercase;
            }

            @media(max-width: 574.98px) {
                .${COMPONENT_NAME}__section-title-label {
                    margin-left: 0;
                    font-size: 16px;
                }
            }

            /* SECTION ACTION */
            .${COMPONENT_NAME}__section-action {
                padding-top: 5px;
                line-height: 1;
                text-align: right;
            }

            @media(max-width: 574.98px) {
                .${COMPONENT_NAME}__section-action {
                    padding-top: 0;
                }
            }

            .${COMPONENT_NAME}__section-action-item {
                --dxp-c-link-text-decoration: underline;
                display: inline-block;
                font-size: 14px;
                line-height: 1;
                font-weight: 600;
                text-decoration-line: underline;
                color: #231F20;
                cursor: pointer;
                transition: color 0.1s;
            }

            .${COMPONENT_NAME}__section-action-item:hover {
                color: var(--b2b-colorActionDarker);
            }

            /* TABS */
            .${COMPONENT_NAME}__tabs {
                display: flex;
                padding-bottom: 25px;
            }

            .${COMPONENT_NAME}__tab {
                padding: 10px 12px;
                font-size: 14px;
                line-height: 1.5;
                font-weight: 400;
                background-color: #ffffff;
                border: 0;
                border-radius: 0;
                box-shadow: inset 0px -1px 0px #DDDBDA;
            }

            .${COMPONENT_NAME}__tab-active {
                font-weight: 700;
                box-shadow: inset 0px -2px 0px #00AEEF;
            }

            @media(max-width: 767.98px) {
                .${COMPONENT_NAME}__tab {
                    font-size: 14px;
                    padding: 6px 12px;
                }
            }
        `;

        styleText = UTILS.prepareString(styleText);
        if (IS.stringNotEmpty(styleText)) {
            let styleElement = document.createElement('style');
            styleElement.innerText = styleText;
            let parenNode = this.template.querySelector(`.${UTILS.customCssContainer}`);
            if (parenNode) {
                while (parenNode.firstChild) {
                    parenNode.removeChild(parenNode.firstChild);
                }
                parenNode.appendChild(styleElement);
            }
        }
    }

    async getInitialData() {
        if (!IS.stringNotEmpty(this.recordId)) return;
        this.isDataInitialized = true;

        let deleteAllTaxesResponse = await UTILS.doRequest(deleteAllTaxes, {
            cartId: this.recordId
        });

        let initAddressesResponse = await UTILS.doRequest(initAddresses, {
            cartId: this.recordId
        });

        let initTaxesResponse = await UTILS.doRequest(initTaxes, {
            cartId: this.recordId
        });


        let calculateShippingResponse = await UTILS.doRequest(calculateShipping, {
            cartId: this.recordId
        });

        if(!UTILS.responseSuccess(calculateShippingResponse)){
            console.error(calculateShippingResponse);
        }

        let responses = null;
        await Promise.all([
            initCartItems({ cartId: this.recordId }),
            initOrderSummary({ cartId: this.recordId }),
            initInstruction({ cartId: this.recordId }),
            initPayment({ cartId: this.recordId }),
        ])
            .then((values) => {
                responses = values;
            })
            .catch((error) => {
                console.error(error);
            });

        if (!IS.arrayNotEmpty(responses)) {
            this.showFatalError();
        }

        // PARSE RESPONSES
        let addressesData = UTILS.responseData(initAddressesResponse) || initAddressesResponse.responseMessage;
        let taxesData = UTILS.responseData(initTaxesResponse) || initTaxesResponse.responseMessage;


        let cartItemsData = UTILS.responseData(responses[0]) || responses[0].responseMessage;
        let orderSummaryData = UTILS.responseData(responses[1]) || responses[1].responseMessage;
        let infoData = UTILS.responseData(responses[2]);
        let initPaymentData = UTILS.responseData(responses[3]);

        if (
            IS.objectNotEmpty(addressesData) &&
            IS.objectNotEmpty(cartItemsData) &&
            IS.objectNotEmpty(initPaymentData)
        ) {
            this.currencyIsoCode = IS.stringNotEmpty(addressesData.currencyIsoCode)
                ? addressesData.currencyIsoCode
                : UTILS.currencyIsoCode;

            if (IS.objectNotEmpty(addressesData.addresses)) this.parseAddresses(addressesData.addresses);
            if (IS.objectNotEmpty(addressesData.countryOptions)) this.parseCountries(addressesData.countryOptions);
            if (IS.objectNotEmpty(addressesData.stateOptions)) this.parseStates(addressesData.stateOptions);
            this.parseInfo(infoData);
            if (IS.objectNotEmpty(initPaymentData.payment)) this.parsePayments(initPaymentData.payment);
            if (IS.arrayNotEmpty(cartItemsData.cartItems)) this.parseProducts(cartItemsData.cartItems, cartItemsData.isCartSecondary);
            this.validateTaxes(taxesData);
            this.parseTotals(orderSummaryData);

            if (!this.isCartSecondary) {
                this.customerTaxInformation = taxesData.customerTaxInformation;
                this.showTaxExempt = IS.objectNotEmpty(taxesData) && IS.objectNotEmpty(this.customerTaxInformation) ? this.customerTaxInformation.isBusinessAccountType && this.salesTax > 0 : false;
            }
        } else {
            if (IS.stringNotEmpty(addressesData)) {
                this.isFatalMessage = addressesData;
            } else if (IS.stringNotEmpty(cartItemsData)) {
                this.isFatalMessage = cartItemsData;
            } else if (IS.stringNotEmpty(orderSummaryData)) {
                this.isFatalMessage = orderSummaryData;
            } else {
                this.isFatalMessage = LABELS.checkoutError;
            }
            this.isFatalError = true;
        }

        DISPATCHER.fireEvent(CHECKOUT_PAGE, UPDATE_CHECKOUT_HEADER, {
            recordId: this.recordId,
            isCartSecondary: this.isCartSecondary
        });

        this.effectiveAccountId = await UTILS.getEffectiveAccountId();
        this.isLoading = false;
    }

    showFatalError() {
        this.isFatalError = true;
        this.isLoading = false;
    }

    parseAddresses(addresses) {
        if (!IS.objectNotEmpty(addresses)) return;

        // SHIPPING ADDRESSES
        this.shippingSelected = IS.stringNotEmpty(addresses.selectedShippingAddressId)
            ? addresses.selectedShippingAddressId
            : null;

        if (this.shippingSelected && IS.arrayNotEmpty(addresses.shippingAddresses)) {
            this.shippingAddresses = []
                .concat(addresses.shippingAddresses.filter((item) => item.id == this.shippingSelected))
                .concat(addresses.shippingAddresses.filter((item) => item.id != this.shippingSelected));
        } else {
            this.shippingAddresses = [];
        }

        // BILLING ADDRESSES
        this.billingSelected = IS.stringNotEmpty(addresses.selectedBillingAddressId)
            ? addresses.selectedBillingAddressId
            : null;

        if (this.billingSelected && IS.arrayNotEmpty(addresses.billingAddresses)) {
            this.billingAddresses = []
                .concat(addresses.billingAddresses.filter((item) => item.id === this.billingSelected))
                .concat(addresses.billingAddresses.filter((item) => item.id !== this.billingSelected));
        } else {
            this.billingAddresses = [];
        }
        console.log('Billing Addresses:', JSON.stringify(this.billingAddresses, null, 2));
        this.sameAddresses = IS.true(addresses.isSameWithBilling) ? true : false;

        // Check same ids and if billing list is empty
        if (
            this.shippingSelected && this.billingSelected &&
            this.shippingSelected === this.billingSelected &&
            IS.arrayNotEmpty(this.shippingAddresses) &&
            !IS.arrayNotEmpty(this.billingAddresses)
        ) {
            this.billingAddresses = [].concat(
                this.shippingAddresses.filter((item) => item.id === this.billingSelected)
            );
        }
    }

    parseCountries(countries) {
        let countryOptions = [];

        if (IS.objectNotEmpty(countries)) {
            for (let key in countries) {
                let newItem = {
                    value: IS.stringNotEmpty(key) ? key : null,
                    label: IS.stringNotEmpty(countries[key]) ? countries[key] : null,
                };

                if (newItem.value && newItem.label) {
                    countryOptions.push(newItem);
                }
            }
        }
        this.countryOptions = countryOptions;
    }

    parseStates(states) {
        let stateOptions = {};
        if (IS.objectNotEmpty(states)) {
            for (let countryCode in states) {
                if (IS.stringNotEmpty(countryCode) && IS.arrayNotEmpty(states[countryCode])) {
                    let statesList = [];

                    states[countryCode].forEach((item) => {
                        for (let stateCode in item) {
                            if (IS.stringNotEmpty(stateCode) && IS.stringNotEmpty(item[stateCode])) {
                                let newItem = {
                                    value: IS.stringNotEmpty(stateCode) ? stateCode : null,
                                    label: IS.stringNotEmpty(item[stateCode]) ? item[stateCode] : null,
                                };
                                if (newItem.value && newItem.label) {
                                    statesList.push(newItem);
                                }
                            }
                        }
                    });

                    if (IS.arrayNotEmpty(statesList)) {
                        stateOptions[countryCode] = statesList;
                    }
                }
            }
        }
        this.stateOptions = stateOptions;
    }

    parseInfo(data) {
        if (IS.objectNotEmpty(data)) {
            this.specialInstructions = IS.stringNotEmpty(data.instruction)
                ? data.instruction
                : null;
        }
    }

    parsePayments(payment) {
        if (!IS.objectNotEmpty(payment)) return;

        this.paymentSelected = IS.stringNotEmpty(payment.selectedCreditCardId)
            ? payment.selectedCreditCardId
            : null;

        this.isInvoiceMyCompany = payment.isInvoiceMyCompany ? true : false;
        this.poNumber = IS.stringNotEmpty(payment.poNumber) ? payment.poNumber : null;
        if (this.amazonCheckoutSessionId) {
            this.hasDarleyDollar = !!payment.hasDarleyDollars;
        }
        this.hasInvoicePayment = !!payment.hasInvoicePayment;
        this.paymentMethod = payment.paymentMethod;
        this.expirationDateMin = payment.expirationDateMin;
        this.darleyDollarAmount = payment.darleyDollarAmount;
        this.isAccountCreditTerms = payment.isAccountCreditTerms ? true : false;
        this.publicKey = payment.publicKey;
        this.publicExponent = payment.publicExponent;

        if (IS.objectNotEmpty(payment.metadata)) {
            this.paymentTypes.card = IS.stringNotEmpty(payment.metadata.methodCreditCard)
                ? payment.metadata.methodCreditCard
                : CREDIT_CARD;
            this.paymentTypes.invoice = IS.stringNotEmpty(payment.metadata.methodInvoice)
                ? payment.metadata.methodInvoice
                : INVOICE;
        }

        if (IS.arrayNotEmpty(payment.creditCards)) {
            this.paymentList = payment.creditCards;
        }

        this.hasPaymentSection = true;
    }

    parseProducts(products, isCartSecondary) {
        let result = [];
        if (IS.arrayNotEmpty(products)) {
            products.forEach((item) => {
                let newItem = {
                    id: IS.stringNotEmpty(item.id) ? item.id : null,
                    image: IS.stringNotEmpty(item.image) ? item.image : null,
                    name: IS.stringNotEmpty(item.name) ? item.name : null,
                    sku: IS.stringNotEmpty(item.sku) ? item.sku : null,
                    productVariant: IS.arrayNotEmpty(item.productVariant) ? item.productVariant : null,
                    quantity: IS.numeric(item.quantity) ? item.quantity : null,
                    price: IS.numeric(item.totalPrice) ? item.totalPrice : null,
                    currencyIsoCode: IS.stringNotEmpty(item.currencyIsoCode)
                        ? item.currencyIsoCode
                        : this.getCurrencyIsoCode,
                };

                if (newItem.id && newItem.name) {
                    result.push(newItem);
                }
            });
        }
        this.products = result;
        this.isCartSecondary = isCartSecondary;
    }

    async updateTotals() {
        let deleteTaxesResponse = await UTILS.doRequest(deleteAllTaxes, {
            cartId: this.recordId
        });

        let initTaxesResponse = await UTILS.doRequest(initTaxes, {
            cartId: this.recordId
        });
        let taxesData = UTILS.responseData(initTaxesResponse) || initTaxesResponse.responseMessage;
        this.validateTaxes(taxesData);

        let initOrderSummaryResponse = await UTILS.doRequest(initOrderSummary, {
            cartId: this.recordId
        });
        let initOrderSummaryData = UTILS.responseData(initOrderSummaryResponse) || initOrderSummaryResponse.responseMessage;
        this.parseTotals(initOrderSummaryData);

        const checkoutPayment = this.template.querySelector('c-b2b-checkout-payment');
        if (checkoutPayment) {
            checkoutPayment.clearAmazonSession();
            checkoutPayment.initAmazonButton();
        }

        this.customerTaxInformation = taxesData.customerTaxInformation;
        this.showTaxExempt = IS.objectNotEmpty(taxesData) && IS.objectNotEmpty(this.customerTaxInformation) ? this.customerTaxInformation.isBusinessAccountType && this.salesTax > 0 : false;
    }

    validateTaxes(taxesData) {
        if (IS.stringNotEmpty(taxesData)) {
            this.isTaxesValid = false;
            UTILS.showToast('error', taxesData, {
                mode: 'sticky'
            });
        } else {
            this.isTaxesValid = true;
        }
    }

    parseTotals(data) {
        if (IS.stringNotEmpty(data)) {
            if (
                IS.stringNotEmpty(this.shippingSelected) ||
                IS.arrayNotEmpty(this.shippingAddresses) ||
                IS.stringNotEmpty(this.billingSelected) ||
                IS.arrayNotEmpty(this.billingAddresses)
            ) {
                UTILS.showToast('error', data, {
                    mode: 'sticky'
                });
            }
            this.items = 0;
            this.salesTax = 0;
            this.promotion = 0;
            this.total = 0;
            this.isAddressError = true;
            
        } else if (
            IS.objectNotEmpty(data) &&
            IS.objectNotEmpty(data.orderSummary)
        ) {
            this.items = IS.numeric(data.orderSummary.items)? data.orderSummary.items : 0;
            this.salesTax = IS.numeric(data.orderSummary.salesTax) ? data.orderSummary.salesTax : 0;
            this.promotion = IS.numeric(data.orderSummary.promotion) ? data.orderSummary.promotion : 0;
            this.total = IS.numeric(data.orderSummary.orderTotal) ? data.orderSummary.orderTotal : 0;
            this.totalChargeAmount = IS.numeric(data.orderSummary.totalChargeAmount) ? data.orderSummary.totalChargeAmount : 0;
            this.isAddressError = false;
        }
    }

    async executePlaceOrder(paymentIntentId, creditCard, amount) {
        let response = await UTILS.doRequest(placeOrder, {
            cartId: this.recordId,
            paymentIntentId: paymentIntentId,
            darleyDollarAmount: this.hasDarleyDollar ? this.darleyDollarAmount : 0,
            creditCard: creditCard,
            amazonCheckoutId: this.amazonCheckoutSessionId,
            amount: amount
        });
        let data = UTILS.responseData(response);

        if (
            IS.objectNotEmpty(data) &&
            IS.stringNotEmpty(data.orderSummaryId)
        ) {
            UTILS.refreshCartLWR();
            this.navigateToUrl(UTILS.link(`/order-confirmation?recordId=${data.orderSummaryId}`));
        } else {
            this.isUpdateLoading = false;
            console.error(response.responseMessage);
            UTILS.showToast('error', LABELS.placeOrderError);
        }
    }

    navigateToUrl(url) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: { url }
        });
    }

    displayStripeModal() {
        this.showStripeModal = true;
        document.body.style.overflowY = 'hidden';
    }

    hideStripeModal() {
        this.showStripeModal = false;
        document.body.style.overflowY = 'auto';
    }

    // HANDLERS
    async handleUpsertAddress(event) {
        let address = event.detail;
        let component = this.template.querySelector('c-b2b-checkout-addresses');
        if (!address || !component) return;

        address.parentId = this.effectiveAccountId;

        this.isAddressUpdating = true;

        let addAddressResponse = await UTILS.doRequest(addAddress, {
            address,
            cartId: this.recordId
        });
        let addAddressData = UTILS.responseData(addAddressResponse);

        if (addAddressData) {
            if (IS.objectNotEmpty(addAddressData.addresses)) this.parseAddresses(addAddressData.addresses);

            if (IS.arrayEmpty(this.shippingAddresses) && IS.arrayNotEmpty(this.billingAddresses) && this.billingSelected) {
                let preselectedAddress = this.billingAddresses.find(item => item.id === this.billingSelected);
                component.apiAddNewShippingAddress(preselectedAddress);
            } else if (IS.arrayEmpty(this.billingAddresses) && IS.arrayNotEmpty(this.shippingAddresses) && this.shippingSelected) {
                let preselectedAddress = this.shippingAddresses.find(item => item.id === this.shippingSelected);
                component.apiAddNewBillingAddress(preselectedAddress);
            } else {
                component.apiShowChange();
            }
            UTILS.showToast('success',
                address.mode === ADD
                    ? LABELS.addYourAddressSuccess
                    : LABELS.editYourAddressSuccess
            );
        } else {
            UTILS.showToast('error',
                address.mode === ADD
                    ? LABELS.addYourAddressError
                    : LABELS.editYourAddressError
            );
        }

        await this.updateTotals();
        this.isAddressUpdating = false;
    }

    async handleUseAddress(event) {
        let detail = event.detail;
        let component = this.template.querySelector('c-b2b-checkout-addresses');

        if (detail &&
            IS.stringNotEmpty(detail.shippingAddressId) &&
            IS.stringNotEmpty(detail.billingAddressId) &&
            component
        ) {
            this.isAddressUpdating = true;

            let useAddressResponse = await UTILS.doRequest(useAddress, {
                cartId: this.recordId,
                shippingAddressId: detail.shippingAddressId,
                billingAddressId: detail.billingAddressId,
            });
            let useAddressData = UTILS.responseData(useAddressResponse);

            if (useAddressData) {
                if (IS.objectNotEmpty(useAddressData.addresses)) this.parseAddresses(useAddressData.addresses);
                component.apiShowView();
                UTILS.showToast('success', LABELS.useYourAddressSuccess);
            } else {
                UTILS.showToast('error', LABELS.useYourAddressError);
            }

            await this.updateTotals();
            this.isAddressUpdating = false;
        }
    }

    handleValidAddress(event) {
        this.isAddressValid = event.detail ? true : false;
    }

    async handleBlurSpecialInstructions(event) {
        this.isInfoUpdating = true;
        this.specialInstructions = event.detail;

        let updateInstructionResponse = await UTILS.doRequest(updateInstruction, {
            cartId: this.recordId,
            instruction: this.specialInstructions,
        });

        if (UTILS.responseSuccess(updateInstructionResponse)) {
            if (IS.stringNotEmpty(this.specialInstructions)) {
                UTILS.showToast('success', LABELS.updateInstructionSuccess);
            } else {
                UTILS.showToast('success', LABELS.updateInstructionSuccessDeleted);
            }
        } else {
            UTILS.showToast('error', LABELS.updateInstructionError);
        }

        this.isInfoUpdating = false;
    }

    async handleChangeInvoice(event) {
        if (!this.recordId || this.isPaymentUpdating) return;
        
        this.isPaymentUpdating = true;
        let isInvoiceMyCompany = event.detail ? true : false;

        let paymentMethod = null;
        if (isInvoiceMyCompany) {
            paymentMethod = this.paymentTypes.invoice
        } else if (
            IS.stringNotEmpty(this.paymentSelected) &&
            IS.arrayNotEmpty(this.paymentList)
        ) {
            paymentMethod = this.paymentTypes.card
        }

        let setPaymentMethodResponse = await UTILS.doRequest(setPaymentMethod, {
            cartId: this.recordId,
            paymentMethod
        });

        if (UTILS.responseSuccess(setPaymentMethodResponse)) {
            this.isInvoiceMyCompany = isInvoiceMyCompany;
        } else {
            this.isInvoiceMyCompany = !isInvoiceMyCompany;
            UTILS.showToast('error', LABELS.failedToSaveData);
        }

        this.checkPaymentValidity();

        this.isPaymentUpdating = false;
    }

    checkPaymentValidity() {
        if (
            this.isInvoiceMyCompany ||
            (
                IS.stringNotEmpty(this.paymentSelected) &&
                IS.arrayNotEmpty(this.paymentList)
            )
        ) {
            this.isPaymentValid = true;
        } else {
            this.isPaymentValid = false;
        }
    }

    async handleChangePoNumber(event) {
        let poNumber = event.detail || null;

        let updatePoNumberResponse = await UTILS.doRequest(updatePoNumber, {
            cartId: this.recordId,
            poNumber
        });

        if (UTILS.responseSuccess(updatePoNumberResponse)) {
            this.poNumber = poNumber;
            UTILS.showToast('success', LABELS.poNumberSuccess);
        } else {
            UTILS.showToast('error', LABELS.poNumberError);
        }

        this.checkPaymentValidity();

        setTimeout(() => {
            const checkoutPayment = this.template.querySelector('c-b2b-checkout-payment');
            if (checkoutPayment) {
                checkoutPayment.hideSpinner();
            }
        }, 0);
    }

    async handleUpdatePaymentMethod(event) {
        let paymentMethod = event.detail;

        let setPaymentMethodResponse = await UTILS.doRequest(setPaymentMethod, {
            cartId: this.recordId,
            paymentMethod
        });
    }

    async handleUpsertPayment(event) {
        let paymentId = event.detail;
        let component = this.template.querySelector('c-b2b-checkout-payment');
        if (!IS.stringNotEmpty(paymentId) || !component) return;

        this.isPaymentUpdating = true;

        let initPaymentResponse = await UTILS.doRequest(initPayment, {
            cartId: this.recordId
        });
        let initPaymentData = UTILS.responseData(initPaymentResponse);

        if (initPaymentData && IS.objectNotEmpty(initPaymentData.payment)) {
            this.parsePayments(initPaymentData.payment);
        }
        component.apiShowChange();
        this.isPaymentUpdating = false;
    }

    async handleUsePayment(event) {
        let detail = event.detail;

        let useCardResponse = await UTILS.doRequest(useCard, {
            cartId: this.recordId,
            creditCardId: detail.creditCardId,
            creditCardName: detail.creditCardName,
        });
    }

    handleChangeHasDarleyDollar(event) {
        this.hasDarleyDollar = event.detail;
    }

    handleValidPayment(event) {
        this.isPaymentValid = event.detail ? true : false;
       
        if (this.isPaymentValid) {
            this.checkPaymentValidity();
        }
    }

    handleStripeIframeResponses(event) {
        try {
            if (
                !event ||
                !IS.objectNotEmpty(event.data) ||
                !IS.stringNotEmpty(event.data.methodType)
            ) {
                throw new Error('Frame response is failed');
            } else {
                if (
                    event.data.methodType === FRAME_LOADED &&
                    event.data.isIframeLoaded
                ) {

                } else if (event.data.methodType === CONFIRM_PAYMENT) {
                    this.handleConfirmPaymentResult(event.data);
                }
            }
        } catch (error) {
            this.isStripeError = true;
            UTILS.showToast('error', UTILS.reduceErrors(error));
            console.error(error);
        }
    }

    async handleClickPlaceOrderButton(event) {
        let detail = event.detail;
        this.isUpdateLoading = true;
        if (detail.currentTab === 'credit-card' && detail.mode === 'view') {
            this.executePlaceOrder(null, detail.card);
        } else if (detail.currentTab === 'credit-card' && detail.mode === 'new') {
            this.executePlaceOrder(null, detail.card);
        } else if (detail.currentTab === 'credit-card' && detail.mode === 'new_no_save') {
        } else if (detail.currentTab === 'pay-with-po') {
            this.executePlaceOrder(null);
        }else if (detail.currentTab === 'amazon-pay') {
            this.executePlaceOrder(null, null, detail.card && detail.card.amount ? detail.card.amount : 0);
        }
    }

    handleConfirmPaymentResult(result) {
        if (result.isError) {
            UTILS.showToast('error', LABELS.payOrderError);
            this.isUpdateLoading = false;
            
        } else {
            UTILS.showToast('success', LABELS.payOrderSuccess);
            this.executePlaceOrder(result.id);
        }
        this.hideStripeModal();
    }

    handleClickTaxExempt(event) {
        event.preventDefault();

        let modal = this.template.querySelector('c-b2b-modal');
        if(this.isLoading || !modal) {
            return;
        }

        modal.open({
            id: 'tax_exempt',
            title: LABELS.modalTaxExemptTitle,
            buttonsAlign:'right',
            hideFooter: true
        });
    }

    async handleSaveCustomer(event) {
        let saveCustomerResponse = await UTILS.doRequest(saveCusomerNumber, {
            effectiveAccountId:this.effectiveAccountId,
            customerNumber: event.detail
        });

        if(!UTILS.responseSuccess(saveCustomerResponse)) {
            console.error('Error updating customerNumber');
        }
    }

    handleCloseModal(event) {
        console.group('HANDLE CLOSE MODAL');
        console.groupEnd();
    }

    handleCloseExemptModal(event) {
        let modal = this.template.querySelector('c-b2b-modal');
        this.isLoading = true;
        this.getInitialData();
        setTimeout(() => {
            modal.hide();
        }, 7000);
    }

}