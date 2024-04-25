import {LightningElement, track, api, wire} from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';
import { loadScript } from 'lightning/platformResourceLoader';

import b2bStaticPayment from '@salesforce/resourceUrl/b2bStaticPayment';
import checkout from '@salesforce/resourceUrl/Checkout';

import _getButtonSignature from '@salesforce/apex/B2BAmazonPayment.getButtonSignature';
import _saveHasDarleyDollars from '@salesforce/apex/B2BCheckoutController.saveHasDarleyDollars';

//LABELS
import payment from '@salesforce/label/c.B2B_Payment';
import change from '@salesforce/label/c.B2B_Change';
import clickToChangePayment from '@salesforce/label/c.B2B_Click_to_change_Credit_Card';
import cancel from '@salesforce/label/c.B2B_Cancel';
import clickToChooseCreditCard from '@salesforce/label/c.B2B_Click_to_choose_Credit_Card';
import addCreditCard from '@salesforce/label/c.B2B_Add_new_Credit_Card';
import addAnotherCreditCard from '@salesforce/label/c.B2B_Add_another_payment_method';
import useThisCreditCard from '@salesforce/label/c.B2B_Use_this_Payment_Method';
import invoiceMyCompany from '@salesforce/label/c.B2B_Invoice_my_company';
import poNumber from '@salesforce/label/c.B2B_P_O_Number';
import placeOrderError from '@salesforce/label/c.B2B_It_was_not_possible_to_place_the_order';
import {CurrentPageReference} from "lightning/navigation";

const COMPONENT_NAME = 'b2b-checkout-payment';
const VALID = 'valid';
const USE = 'use';
const CHANGE_PO_NUMBER = 'changeponumber';
const CHANGE_PAYMENT_METHOD = 'changepaymentmethod';
const CHANGE_HAS_DARLEY_DOLLAR = 'changehasdarleydollar';
const CLICK_BUTTON_PLACE_ORDER = 'clickplaceorder';

const INVOICE_VALID = 'invoice_valid';
const FRAME_LOADED = 'frame_loaded';
const RESIZE = 'resize';
const UPDATE_PO_NUMBER = 'update_po_number';
const UPDATE_PAYMENT_METHOD = 'update_payment_method';
const SET_HAS_DARLEY_DOLLAR = 'set_has_darley_dollar';
const CLICK_PLACE_ORDER = 'click_place_order';
const SET_DISABLED_PLACE_ORDER_BUTTON = 'set_disabled_place_order_button';
const HIDE_SPINNER = 'hide_spinner';
const SHOW_SPINNER = 'show_spinner';
const SET_TOTAL = 'set_total';
const SET_AMAZON = 'set_amazonSignature';
const INIT_DATA = 'init_data';
const UPDATE_AMAZON_MODE = 'update_amazon_mode';
const SELECT_CREDIT_CARD = 'select_credit_card';
const SELECT_AMAZON = 'select_amazon';

const LABELS = {
    payment: payment,
    change: change,
    clickToChangePayment: clickToChangePayment,
    creditCard: 'Pay with Credit or Debit Card',
    cancel: cancel,
    clickToChooseCreditCard: clickToChooseCreditCard,
    addCreditCard: addCreditCard,
    addAnotherCreditCard: addAnotherCreditCard,
    useThisCreditCard: useThisCreditCard,
    invoiceMyCompany: invoiceMyCompany,
    poNumber: poNumber,
    amazonButtonInitialization: 'Authorize with Amazon',
    amazonButtonPay: 'Pay with Amazon'
};

const MAX_LENGTH = {
    poNumber: 80,
};

export default class B2bCheckoutPayment extends LightningElement {
    @api isUpdateLoading = false;
    @api paymentSelected = null;
    @api paymentList = [];
    @api paymentTypes = {};
    @api isInvoiceMyCompany = false;
    @api darleyDollarAmount = 0;
    @api hasDarleyDollar = false;
    @api poNumber = null;
    @api paymentMethod = null;
    @api recordId = null;
    @api isCreditTerms = false;
    @api isDisabledPlaceOrder;
    @api expirationDateMin = null;
    @api publicKey = null;
    @api publicExponent = null;

    @track isFirstRender = true;
    @track customCssContainer = UTILS.customCssContainer;
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);
    @track labels = LABELS;
    @track maxLength = MAX_LENGTH;

    @track type = null;
    @track isChange = false;
    @track isEdit = false;

    @track paymentId = null;
    @track isInvoiceMyCompanyValue = false;
    @track poNumberValue = null;

    @track isShowModal = false;
    @track isDefault = false;

    checkoutData = {};
    card = {};
    amazonCheckoutSessionId = null;

    amazonButtonData = null;
    isAmazonStaticLoaded = false;
    isAmazonTabActive = false;

    // GETTERS
    get getB2bStaticPayment() {
        return b2bStaticPayment;
    }

    _hasInvoicePayment = false;
    @api
    get hasInvoicePayment() {
        return this._hasInvoicePayment;
    }
    set hasInvoicePayment(value) {
        this._hasInvoicePayment = !!value;
        this.frameDispatchEvent(INVOICE_VALID, {
            hasInvoicePayment: this._hasInvoicePayment
        });
    }

    _total;
    @api
    get total() {
        return this._total;
    }
    set total(value) {
        this._total = value;
        this.frameDispatchEvent(SET_TOTAL, {
            total: this._total
        });
    }

    _amazonSignature;
    @api
    get amazonSignature() {
        return this._amazonSignature;
    }
    set amazonSignature(value) {
        this._amazonSignature = value;
        this.frameDispatchEvent(SET_AMAZON, {
            amazonSignature: this._amazonSignature
        });
    }

    @api
    get amazonLinkData() { return; }
    set amazonLinkData(value) {
        if (!value) return;

        this.amazonLink = value;
        this.frameDispatchEvent(SELECT_AMAZON, {});
    }

    @api
    apiShowView() {
        setTimeout(() => {
            if (
                IS.stringNotEmpty(this.paymentSelected) ||
                IS.arrayNotEmpty(this.paymentList)
            ) {
                this.isChange = false;
                this.isEdit = false;
                this.componentValidity(true);

            } else {
                this.showAddCreditCart();
                this.componentValidity(false);
            }
        }, 0);
    }

    @api
    apiShowChange() {
        setTimeout(() => {
            if (IS.stringNotEmpty(this.paymentSelected)
                && IS.arrayNotEmpty(this.paymentList)
                && this.paymentList.length > 1
            ) {
                this.paymentId = this.paymentSelected;
                this.isChange = true;
                this.isEdit = false;
                this.componentValidity(false);
            } else if (IS.stringNotEmpty(this.paymentSelected)
                && IS.arrayNotEmpty(this.paymentList)
                && this.paymentList.length === 1
            ) {
                this.isChange = false;
                this.isEdit = false;
                this.componentValidity(true);
            } else {
                this.showAddCreditCart();
                this.componentValidity(false);
            }
        }, 0);
    }

    @api
    setButtonPlaceOrderDisabled(isDisabled) {
        this.isDisabledPlaceOrder = isDisabled;
        this.frameDispatchEvent(SET_DISABLED_PLACE_ORDER_BUTTON, {
            isDisabledPlaceOrder: isDisabled
        });
    }

    @api
    hideSpinner() {
        this.frameDispatchEvent(HIDE_SPINNER, {});
    }

    @api
    showSpinner() {
        this.frameDispatchEvent(SHOW_SPINNER, {});
    }

    @api
    clearAmazonSession() {
        this.amazonCheckoutSessionId = null;
        UTILS.addUrlParams({});
        this.frameDispatchEvent(UPDATE_AMAZON_MODE, {
            amazonButtonLabel: this.getAmazonButtonLabel()
        });
    }

    @api
    async initAmazonButton() {
        this.showSpinner();

        await this.refreshAmazonButton();
        await this.getAmazonData();
        this.renderAmazonButton();

        this.hideSpinner();
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.amazonCheckoutSessionId = currentPageReference.state?.amazonCheckoutSessionId;
        }
    }

    // LIFECYCLES
    async connectedCallback() {
        this.poNumberValue = this.poNumber;
        this.isInvoiceMyCompanyValue = this.isInvoiceMyCompany;

        this._iframeListener = this.iframeListener.bind(this);
        window.addEventListener('message', this._iframeListener);

        this._resizeEventListener = this.resizeEventListener.bind(this);
        window.addEventListener('resize', this._resizeEventListener);

        await this.initAmazonStatic();
        if (this.paymentMethod === 'Amazon Pay') {
            await this.initAmazonButton();
        }
    }

    renderedCallback() {
        if (this.isFirstRender) {
            this.isFirstRender = false;
            this.addCustomCssStyles();
        }
    }

    disconnectedCallback() {
        window.removeEventListener('message', this._iframeListener, false);
        window.removeEventListener('resize', this._resizeEventListener, false);
    }

    sendDataToFrame() {
        this.setButtonPlaceOrderDisabled(this.isDisabledPlaceOrder);

        this.frameDispatchEvent(INIT_DATA, {
            hasInvoicePayment: this.hasInvoicePayment,
            poNumber: this.poNumber,
            darleyDollarAmount: this.darleyDollarAmount,
            hasDarleyDollar: this.hasDarleyDollar,
            total: this.total,
            cards: JSON.parse(JSON.stringify(this.paymentList)),
            paymentMethod: this.paymentMethod,
            selectedCreditCardId: this.paymentSelected,
            expirationDateMin: this.expirationDateMin,
            amazonButtonLabel: this.getAmazonButtonLabel(),
            publicKey: this.publicKey,
            publicExponent: this.publicExponent
        });
    }

    frameDispatchEvent(methodType, data) {
        setTimeout(() => {
            let iframe = this.template.querySelector('iframe.b2b-checkout-payment__iframe');
            if (iframe && iframe.contentWindow && methodType && data) {
                iframe.contentWindow.postMessage(
                    Object.assign(
                        {
                            methodType,
                            originUrl: window.location.origin
                        },
                        data
                    ),
                    window.location.origin
                );
            }
        }, 0);
    }

    async iframeListener(event) {
        if (event.data.methodType === FRAME_LOADED) {
            this.sendDataToFrame();
        } else if (event.data.methodType === RESIZE) {
            this.updateIframeHeight(event.data.formHeight);
        } else if (event.data.methodType ===  UPDATE_PO_NUMBER) {
            event.preventDefault();
            event.stopImmediatePropagation();
            this.handleBlurPoNumber(event.data.poNumber);
        } else if (event.data.methodType === UPDATE_PAYMENT_METHOD) {
            event.preventDefault();
            event.stopImmediatePropagation();
            this.handleUpdatePaymentMethod(event.data.paymentMethod);

            if (event.data.currentTab === 'amazon-pay') {
                await this.initAmazonButton();
            }
        } else if (event.data.methodType === SET_HAS_DARLEY_DOLLAR) {
            this.handleHasDarleyDollar(event.data.hasDarleyDollar);

            if (event.data.currentTab === 'amazon-pay') {
                this.clearAmazonSession();
                await this.initAmazonButton();
            }
        } else if (event.data.methodType === CLICK_PLACE_ORDER) {
            event.preventDefault();
            event.stopImmediatePropagation();
            this.handleClickPlaceOrder(event.data);
        } else if (event.data.methodType === SELECT_CREDIT_CARD) {
            event.preventDefault();
            event.stopImmediatePropagation();
            this.handleUseCreditCard(event.data);
        }
    }

    // METHODS
    addCustomCssStyles() {
        let styleText = `
            .b2b-static-payment__tab {
                background-color: black;
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

    updateIframeHeight(formHeight) {
        let iframe = this.template.querySelector('iframe');
        if (iframe && IS.number(+formHeight)) {
            iframe.style.height = `${formHeight + 20}px`;
        }
    }

    getAmazonButtonLabel() {
        return this.amazonCheckoutSessionId ? LABELS.amazonButtonPay : LABELS.amazonButtonInitialization;
    }

    resizeEventListener() {
        this.frameDispatchEvent(RESIZE, {
            innerWidth: window.innerWidth
        });
    }

    componentValidity(flag) {
        UTILS.dispatchEvent(this, VALID, flag);
    }

    showAddCreditCart() {
        this.isChange = false;
        this.isEdit = true;
    }

    handleBlurPoNumber(poNumber) {
        this.poNumberValue = UTILS.prepareString(poNumber);
        UTILS.dispatchEvent(this, CHANGE_PO_NUMBER, this.poNumberValue);
    }

    handleUpdatePaymentMethod(paymentMethod) {
        UTILS.dispatchEvent(this, CHANGE_PAYMENT_METHOD, paymentMethod);
    }

    handleHasDarleyDollar(hasDarleyDollar) {
        this.hasDarleyDollar = hasDarleyDollar;
        UTILS.dispatchEvent(this, CHANGE_HAS_DARLEY_DOLLAR, hasDarleyDollar);
    }

    handleLWCPlaceOrder() {
        let amazonButton = this.template.querySelector('.amazon-pay-button');
        if (amazonButton && this.amazonButtonData && this.amazonButtonData.createCheckoutSessionConfig && this.amazonButtonData.createCheckoutSessionConfig.signature) {
            amazonButton.click();
        } else {
            UTILS.showToast('error', placeOrderError);
        }
    }

    async handleClickPlaceOrder(data) {
        this.checkoutData = {
            currentTab: data.currentTab,
            mode: data.mode,
            card: data.card
        };

        this.card = data.card;
        if (data.currentTab === 'credit-card' && data.mode === 'new') {
            this.isShowModal = true;
        } else if (data.currentTab === 'credit-card' && data.mode !== 'new') {
            UTILS.dispatchEvent(this, CLICK_BUTTON_PLACE_ORDER, this.checkoutData);
        } else if (data.currentTab === 'pay-with-po') {
            UTILS.dispatchEvent(this, CLICK_BUTTON_PLACE_ORDER, this.checkoutData);
        } else if (data.currentTab === 'amazon-pay') {
            if(this.amazonCheckoutSessionId) {
                UTILS.dispatchEvent(this, CLICK_BUTTON_PLACE_ORDER, this.checkoutData);
            } else {
                await this.saveHasDarleyDollars();
                this.handleLWCPlaceOrder();
            }
        }
    }

    handleUseCreditCard(data) {
        UTILS.dispatchEvent(this, USE, {
            creditCardId: data.creditCardId,
            creditCardName: data.creditCardName
        });
    }


    clickModalClose() {
        this.isShowModal = false;
    }

    clickModalNo() {
        this.checkoutData.card = this.card;
        this.checkoutData.card.isSaveCard = false;
        UTILS.dispatchEvent(this, CLICK_BUTTON_PLACE_ORDER, this.checkoutData);
        this.isShowModal = false;
    }

    clickModalYes() {
        this.checkoutData.card = this.card;
        this.checkoutData.card.isSaveCard = true;
        UTILS.dispatchEvent(this, CLICK_BUTTON_PLACE_ORDER, this.checkoutData);
        this.isShowModal = false;
    }

    handleChangeIsDefault(event) {
        this.card.isDefault = event.target.checked;
    }

    async initAmazonStatic() {
        await loadScript(this, checkout)
            .then(() => {
                this.isAmazonStaticLoaded = true;
            })
            .catch(err => {
                console.error(err);
            });
    }

    async refreshAmazonButton() {
        return new Promise((resolve, reject) => {
            let interval = setInterval(() => {
                let amazonButtonContainer = this.template.querySelector('.amazon-pay-button-container');
                let amazonButton = this.template.querySelector('.amazon-pay-button');

                if (
                    amazonButtonContainer
                    && amazonButton
                    && amazonButton.classList.value.includes('amazonpay-button-parent-container')
                ) {
                    clearInterval(interval);

                    let newButtonDiv = document.createElement('div');
                    newButtonDiv.classList.add('amazon-pay-button');

                    amazonButtonContainer.removeChild(amazonButton);
                    amazonButtonContainer.appendChild(newButtonDiv);

                    resolve();

                } else if (
                    amazonButton
                    && !amazonButton.classList.value.includes('amazonpay-button-parent-container')
                ) {
                    clearInterval(interval);
                    resolve();
                }
            }, 50);
        });
    }

    async saveHasDarleyDollars() {
        let saveHasDarleyDollarsResponse = await UTILS.doRequest(_saveHasDarleyDollars, {
            cartId: this.recordId,
            hasDarleyDollars: this.hasDarleyDollar
        });

        if (!saveHasDarleyDollarsResponse.isSuccess) {
            console.error('Has Darley Dollar field did not saved.');
        }
    }

    async getAmazonData() {
        let buttonSignatureResponse = await UTILS.doRequest(_getButtonSignature, {
            amount: this.total.toFixed(2),
            merchantReferenceId: this.recordId
        });

        if (UTILS.responseSuccess(buttonSignatureResponse)) {
            this.amazonButtonData = JSON.parse(buttonSignatureResponse.responseData.buttonSignature);
        } else {
            this.setButtonPlaceOrderDisabled(true);
            UTILS.showToast('error', 'Something went wrong with Amazon Payment. Please try again later.');
        }
    }

    renderAmazonButton() {
        let interval = setInterval(() => {
            let amazonButton = this.template.querySelector('.amazon-pay-button');
            if (amazonButton) {
                clearInterval(interval);
                amazon.Pay.renderButton(amazonButton, this.amazonButtonData);
            }
        }, 50);
    }
}