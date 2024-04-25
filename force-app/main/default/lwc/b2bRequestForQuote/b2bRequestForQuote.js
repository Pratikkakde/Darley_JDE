import { LightningElement, track, api, wire } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';
import { CartSummaryAdapter, deleteCurrentCart } from 'commerce/cartApi';

// METHODS
import isRequestQuoteEnabled from '@salesforce/apex/B2BRequestForQuoteController.isRequestQuoteEnabled';
import getQuoteRequestDetail from '@salesforce/apex/B2BRequestForQuoteController.getQuoteRequestDetail';
import updateCartCheckoutShippingAddress from '@salesforce/apex/B2BRequestForQuoteController.updateCartCheckoutShippingAddress';
import saveQuoteRequest from '@salesforce/apex/B2BRequestForQuoteController.saveQuoteRequest';
import getCustomerTaxInfo from '@salesforce/apex/B2BRequestForQuoteController.getCustomerTaxInfo';
import saveCusomerNumber from '@salesforce/apex/B2BRequestForQuoteController.saveCusomerNumber';
import deleteAllTaxes from '@salesforce/apex/B2BRequestForQuoteController.deleteAllTaxes';
import initTaxes from '@salesforce/apex/B2BRequestForQuoteController.calculateTaxes';
import initAddresses from '@salesforce/apex/B2BRequestForQuoteController.initAddresses';

const LABELS = {
    loading: 'Loading',
    loadingError: 'Could not get quota data',
    title: 'Request for Quote',
    quoteItems: 'Quote Items',
    sku: 'SKU:',
    quantity: 'QTY:',
    message: 'Message',
    editQuote: 'Edit Quote',
    submit: 'Submit',
    titleSummary: 'Quote summary',
    subtotal: 'Quote Subtotal',
    tax: 'Estimated Tax',
    shipping: 'Estimated Shipping',
    promotions: 'Promotions',
    total: 'Estimated Quote Total',
    areYou: 'Are you',
    taxExempt: 'Tax Exempt?',
    modalTaxExemptTitle: 'Tax Exempt',
    modalClose: 'Close',
    modalSubmit: 'Save',
    warningTitle: 'Warning',
    warningText: 'Please add products to your cart to request a quote.',
    continueShopping: 'Continue Shopping',
    successTitle: 'Thank You',
    successText: 'Your request for Quote {0} has been submitted.',
    quoteDetails: 'Quote Details',
    createError: 'Something went wrong. Please try to submit the form again or contact us at edarleycustomerservice@darley.com',
    selectSuccess: 'The address was successfully selected',
};

const SHIPPING = 'Shipping';
const BILLING = 'Billing';

export default class B2bRequestForQuote extends LightningElement {
    @api removeCartItems = false;

    @track labels = LABELS;
    @track customCssContainer = UTILS.customCssContainer;
    @track effectiveAccountId = null;
    @track cartId = null;
    @track isLoading = true;
    @track isUpdateLoading = false;
    @track isFirstRender = true;
    @track isAddressesValid = false;
    @track isRequestQuoteEnabled = false;
    @track shippingAddresses = [];
    @track selectedShippingAddress = null;
    @track billingAddresses = [];
    @track selectedBillingAddress = null;
    @track showQuoteItems = false;
    @track currencyIsoCode = UTILS.currencyIsoCode;
    @track items = [];
    @track message = null;
    @track subtotal = null;
    @track tax = null;
    @track shipping = null;
    @track promotions = null;
    @track total = null;
    @track isModalLoading = false;
    @track quoteId = null;
    @track quoteNumber = null;
    @track customerTaxInformation = {};
    @track showTaxExempt;

    @wire(CartSummaryAdapter, {'cartStateOrId': 'active'})
    async wiredCartSummaryData(result) {
        if (
            IS.objectNotEmpty(result) 
            && IS.objectNotEmpty(result.data)
            && IS.stringNotEmpty(result.data.cartId)
        ) {
            this.cartId = result.data.cartId;
            this.getInitialData();
        }
    }

    // GETTERS
    get showSpinner() {
        return this.isLoading
            || this.isUpdateLoading;
    }

    get showQuoteDisabled() {
        return !this.isLoading
            && !this.isRequestQuoteEnabled;
    }

    get getHomeLink() {
        return UTILS.link('/');
    }

    get showQuoteDetails() {
        return this.isRequestQuoteEnabled
            && !IS.stringNotEmpty(this.quoteId)
            && !IS.stringNotEmpty(this.quoteNumber);
    }

    get getCartLink() {
        return UTILS.link('/cart');
    }

    get summaryOptions() {
        let result = [];
        ['subtotal', 'tax', 'shipping', 'promotions'].forEach((item) => {
            if (
                (item !== 'promotions' && IS.numeric(this[item]))
                || (item === 'promotions' && IS.numeric(this[item]) && this[item] !== 0)
            ) {
                result.push({
                    key: item,
                    label: LABELS[item],
                    value: this[item]
                });
            }
        });
        return result;
    }

    get showTotal() {
        return IS.numeric(this.total);
    }
    
    get isSubmitButtonDisabled() {
        return this.isLoading
            || this.isUpdateLoading
            || !this.isAddressesValid
            || !IS.arrayNotEmpty(this.items);
    }

    get showSuccessInformatoin() {
        return !this.isLoading
            && this.isRequestQuoteEnabled
            && IS.stringNotEmpty(this.quoteId)
            && IS.stringNotEmpty(this.quoteNumber);
    }

    get getSuccessText() {
        return UTILS.prepareLabel(LABELS.successText, [this.quoteNumber]);
    }

    get getQuoteDetailLink() {
        return UTILS.link(`quote-detail?recordId=${this.quoteId}`);
    }

    // LIFECYCLES
    async connectedCallback() {
        this.effectiveAccountId = await UTILS.getEffectiveAccountId();
    }

    renderedCallback() {
        if (this.isFirstRender) {
            this.isFirstRender = false;
            this.addCustomCssStyles();
        }
    }

    // METHODS
    addCustomCssStyles() {
        let styleText = `
            /* B2B ACCORDION */
            c-b2b-request-for-quote c-b2b-accordion .b2b-accordion__header {
                align-items: center !important;
                justify-content: flex-start !important;
                grid-column-gap: 0.5rem !important;
            }

            c-b2b-request-for-quote c-b2b-accordion .b2b-accordion__header svg[data-open="true"] {
                transform: translateY(1px) rotate(0deg) !important;
            }

            c-b2b-request-for-quote c-b2b-accordion .b2b-accordion__header svg[data-open="false"] {
                transform: translateY(0px) rotate(-90deg) !important;
            }

            /* B2B REQUEST FOR QUOTE */

            c-b2b-request-for-quote .b2b-request-for-quote__message lightning-textarea .slds-form-element__label {
                font-size: 12px;
            }

            c-b2b-request-for-quote .b2b-request-for-quote__message lightning-textarea .slds-textarea {
                display: block;
                min-height: 70px;
            }

            /* B2B REQUEST FOR QUOTE ADDRESSES */

            c-b2b-request-for-quote-addresses lightning-input label.slds-form-element__label,
            c-b2b-request-for-quote-addresses lightning-lookup-address label.slds-form-element__label,
            c-b2b-request-for-quote-addresses lightning-combobox label.slds-form-element__label,
            c-b2b-request-for-quote-addresses lightning-textarea label.slds-form-element__label {
                font-size: 12px;
                color: #231F20;
            }
        `;

        UTILS.addCustomCssStyles(this.template, styleText);
    }

    async getInitialData() {
        if (IS.stringNotEmpty(this.effectiveAccountId)) {
            let isRequestQuoteEnabledResponse = await UTILS.doRequest(isRequestQuoteEnabled, {
                effectiveAccountId: this.effectiveAccountId
            });

            if (
                UTILS.responseSuccess(isRequestQuoteEnabledResponse)
                && UTILS.responseData(isRequestQuoteEnabledResponse)
                && IS.true(UTILS.responseData(isRequestQuoteEnabledResponse).isCartAvailable)
            ) {
                this.isRequestQuoteEnabled = true;

                let deleteTaxesResponse = await UTILS.doRequest(deleteAllTaxes, {
                    cartId: this.cartId
                });

                let initAddressesResponse = await UTILS.doRequest(initAddresses, {
                    cartId: this.cartId
                });

                let initTaxesResponse = await UTILS.doRequest(initTaxes, {
                    cartId: this.cartId
                });

                let getQuoteRequestDetailResponse = await UTILS.doRequest(getQuoteRequestDetail, {
                    effectiveAccountId: this.effectiveAccountId,
                    cartId: this.cartId
                });

                if (UTILS.responseSuccess(getQuoteRequestDetailResponse)) {
                    this.parseResponse(UTILS.responseData(getQuoteRequestDetailResponse));
                    this.initAddesses();
                } else {
                    UTILS.showToast('error', LABELS.loadingError);
                }

                let getCustomerTaxInfoResponse = await UTILS.doRequest(getCustomerTaxInfo, {
                    cartId: this.cartId
                });

                if (UTILS.responseSuccess(getCustomerTaxInfoResponse)) {
                    let customerInfoResponse = UTILS.responseData(getCustomerTaxInfoResponse);
                    this.customerTaxInformation = customerInfoResponse.customerTaxInformation;
                    this.showTaxExempt = IS.objectNotEmpty(customerInfoResponse) &&  IS.objectNotEmpty(this.customerTaxInformation) ? this.customerTaxInformation.isBusinessAccountType && this.tax > 0: false;
                }

            } else {
                UTILS.showToast('error', LABELS.loadingError);
            }
        }
        this.isLoading = false;
    }

    parseResponse(data) {
        // Parse Quote Details
        this.parseSummary(data);
        if (IS.objectNotEmpty(data.quoteDetail)) {
            this.message = IS.stringNotEmpty(data.quoteDetail.message)
                ? data.quoteDetail.message
                : null;

            // Parse Quote items
            let items = [];
            if (IS.arrayNotEmpty(data.quoteDetail.quoteLineItemDetails)) {
                data.quoteDetail.quoteLineItemDetails.forEach((item) => {
                    if (
                        IS.stringNotEmpty(item.quoteLineItemProductId)
                        && IS.stringNotEmpty(item.productName)
                        && IS.integer(item.productQuantity)
                        && IS.numeric(item.totalAmount)
                    ) {
                        items.push({
                            id: item.quoteLineItemProductId,
                            name: item.productName,
                            link: UTILS.link(`/product/${item.quoteLineItemProductId}`),
                            sku: IS.stringNotEmpty(item.productSku) ? item.productSku : null,
                            quantity: item.productQuantity,
                            total: item.totalAmount,
                        });
                    }
                });
            }
            this.items = items;
        }
        this.showQuoteItems = IS.arrayNotEmpty(this.items);

        // Parse Shipping Addresses
        let shippingAddresses = [];
        if (IS.arrayNotEmpty(data.availableShippingAddresses)) {
            data.availableShippingAddresses.forEach((item) => {
                let newItem = this.parseAddressItem(item);
                if (IS.objectNotEmpty(newItem)) {
                    shippingAddresses.push(newItem);
                }
            });
        }
        this.shippingAddresses = shippingAddresses;
        this.selectedShippingAddress = IS.stringNotEmpty(data.selectedShippingAddress)
            ? data.selectedShippingAddress
            : null;

        // Parse Billing Addresses
        let billingAddresses = [];
        if (IS.arrayNotEmpty(data.availableBillingAddresses)) {
            data.availableBillingAddresses.forEach((item) => {
                let newItem = this.parseAddressItem(item);
                if (IS.objectNotEmpty(newItem)) {
                    billingAddresses.push(newItem);
                }
            });
        }
        this.billingAddresses = billingAddresses;
        this.selectedBillingAddress = IS.stringNotEmpty(data.selectedBillingAddress)
            ? data.selectedBillingAddress
            : null;

        // Get default ids
        if (!IS.stringNotEmpty(this.selectedShippingAddress) && IS.arrayNotEmpty(this.shippingAddresses)) {
            let defaultShippingAddressId = null;
            let isSelectedtShippingAddressExist = false;

            this.shippingAddresses.forEach((item) => {
                if (IS.true(item.isDefault)) {
                    defaultShippingAddressId = item.id;
                }
                if (
                    IS.stringNotEmpty(this.selectedShippingAddress)
                    && item.id === this.selectedShippingAddress
                ) {
                    isSelectedtShippingAddressExist = true;
                }
            });

            if (
                !isSelectedtShippingAddressExist
                && IS.stringNotEmpty(defaultShippingAddressId)
            ) {
                this.selectedShippingAddress = defaultShippingAddressId;
            } else {
                this.selectedShippingAddress = this.shippingAddresses[0].id;
            }
        }

        if (!IS.stringNotEmpty(this.selectedBillingAddress) && IS.arrayNotEmpty(this.billingAddresses)) {
            let defaultBillingAddressId = null;
            let isSelectedtBillingAddressExist = false;

            this.billingAddresses.forEach((item) => {
                if (IS.true(item.isDefault)) {
                    defaultBillingAddressId = item.id;
                }
                if (
                    IS.stringNotEmpty(this.selectedShippingAddress)
                    && item.id === this.selectedShippingAddress
                ) {
                    isSelectedtBillingAddressExist = true;
                }
            });

            if (
                !isSelectedtBillingAddressExist
                && IS.stringNotEmpty(defaultBillingAddressId)
            ) {
                this.selectedBillingAddress = defaultBillingAddressId;
            } else {
                this.selectedBillingAddress = this.billingAddresses[0].id;
            }
        }

        // Sort by default
        if (IS.arrayNotEmpty(this.shippingAddresses)) {
            this.shippingAddresses.sort((a, b) => {
                if (a.isDefault < b.isDefault) return 1;
                if (a.isDefault > b.isDefault) return -1;
                return 0;
            });
        }

        if (IS.arrayNotEmpty(this.billingAddresses)) {
            this.billingAddresses.sort((a, b) => {
                if (a.isDefault < b.isDefault) return 1;
                if (a.isDefault > b.isDefault) return -1;
                return 0;
            });
        }

        // Check addresses validity
        if (
            IS.arrayNotEmpty(this.shippingAddresses)
            && IS.stringNotEmpty(this.selectedShippingAddress)
            && IS.arrayNotEmpty(this.billingAddresses)
            && IS.stringNotEmpty(this.selectedBillingAddress)
        ) {
            this.isAddressesValid = true;
        }
    }

    parseAddressItem(item) {
        let newItem = {};
        if (IS.objectNotEmpty(item)) {
            newItem.id = IS.stringNotEmpty(item.Id) ? item.Id : null;
            newItem.type = IS.stringNotEmpty(item.AddressType)
                && (item.AddressType === SHIPPING || item.AddressType === BILLING)
                    ? item.AddressType
                    : null;
            newItem.isDefault = IS.true(item.IsDefault) ? true : false;
            newItem.isPrimary = IS.true(item.IsPrimary) ? true : false;
            newItem.name = IS.stringNotEmpty(item.Name) ? item.Name : null;
            newItem.street = IS.stringNotEmpty(item.Street) ? item.Street : null;
            newItem.city = IS.stringNotEmpty(item.City) ? item.City : null;
            newItem.state = IS.stringNotEmpty(item.State) ? item.State : null;
            newItem.stateCode = IS.stringNotEmpty(item.StateCode) ? item.StateCode : null;
            newItem.postalCode = IS.stringNotEmpty(item.PostalCode) ? item.PostalCode : null;
            newItem.country = IS.stringNotEmpty(item.Country) ? item.Country : null;
            newItem.countryCode = IS.stringNotEmpty(item.CountryCode) ? item.CountryCode : null;
        }

        return IS.objectNotEmpty(newItem)
            && IS.stringNotEmpty(newItem.id)
            && IS.stringNotEmpty(newItem.type)
            && IS.stringNotEmpty(newItem.name)
            && IS.stringNotEmpty(newItem.street)
            && IS.stringNotEmpty(newItem.city)
            && IS.stringNotEmpty(newItem.postalCode)
            && IS.stringNotEmpty(newItem.country)
            && IS.stringNotEmpty(newItem.countryCode)
                ? newItem
                : null;
    }

    parseSummary(data) {
        if (IS.objectNotEmpty(data) && IS.objectNotEmpty(data.quoteDetail)) {
            this.subtotal = IS.numeric(data.quoteDetail.quoteSubtotal)
                ? data.quoteDetail.quoteSubtotal
                : null;
            this.tax = IS.numeric(data.quoteDetail.quoteEstimatedTax)
                ? data.quoteDetail.quoteEstimatedTax
                : null;
            this.shipping = IS.numeric(data.quoteDetail.quoteEstimatedShipping)
                ? data.quoteDetail.quoteEstimatedShipping
                : null;
            this.promotions = IS.numeric(data.quoteDetail.quotePromotions)
                ? data.quoteDetail.quotePromotions
                : null;
            this.total = IS.numeric(data.quoteDetail.quoteTotal)
                ? data.quoteDetail.quoteTotal
                : null;
        }
    }

    initAddesses() {
        setTimeout(() => {
            let component = this.template.querySelector('c-b2b-request-for-quote-addresses');
            if (component) {
                let data = JSON.parse(JSON.stringify({
                    shippingAddresses: this.shippingAddresses,
                    selectedShippingAddress: this.selectedShippingAddress,
                    billingAddresses: this.billingAddresses,
                    selectedBillingAddress: this.selectedBillingAddress,
                }));
                component.initial(data);
            }
        }, 0);
    }

    // HANDLERS
    async handleAddressChange(event) {
        this.isUpdateLoading = true;
        let component = this.template.querySelector('c-b2b-request-for-quote-addresses');
        if (
            component
            && IS.objectNotEmpty(event.detail)
            && IS.true(event.detail.isValid)
            && IS.stringNotEmpty(event.detail.shippingAddressId)
            && IS.stringNotEmpty(event.detail.billingAddressId)
        ) {
            if (
                this.selectedShippingAddress !== event.detail.shippingAddressId
                || this.selectedBillingAddress !== event.detail.billingAddressId
            ) {
                let updateCartCheckoutShippingAddressResponse = await UTILS.doRequest(updateCartCheckoutShippingAddress, {
                    cartId: this.cartId,
                    shippingAddressId: event.detail.shippingAddressId,
                    billingAddressId: event.detail.billingAddressId
                });

                if (UTILS.responseSuccess(updateCartCheckoutShippingAddressResponse)) {
                    let deleteTaxesResponse = await UTILS.doRequest(deleteAllTaxes, {
                        cartId: this.cartId
                    });

                    let initTaxesResponse = await UTILS.doRequest(initTaxes, {
                        cartId: this.cartId
                    });

                    let taxesData = UTILS.responseData(initTaxesResponse) || initTaxesResponse.responseMessage;
                    if (taxesData && taxesData.customerTaxInformation) {
                        this.customerTaxInformation = taxesData.customerTaxInformation;
                    }

                    let getQuoteRequestDetailResponse = await UTILS.doRequest(getQuoteRequestDetail, {
                        effectiveAccountId: this.effectiveAccountId,
                        cartId: this.cartId
                    });
                    if (UTILS.responseSuccess(getQuoteRequestDetailResponse)) {
                        this.parseSummary(UTILS.responseData(getQuoteRequestDetailResponse));

                        this.showTaxExempt = IS.objectNotEmpty(this.customerTaxInformation) ? this.customerTaxInformation.isBusinessAccountType && this.tax > 0: false;
                        UTILS.showToast('success', LABELS.selectSuccess);
                    }
                } else {
                    this.isAddressesValid = false;
                    component.openChange();
                    return;
                }
            }

            this.isAddressesValid = true;
            this.selectedShippingAddress = event.detail.shippingAddressId;
            this.selectedBillingAddress = event.detail.billingAddressId;
        } else {
            this.isAddressesValid = false;
        }
        this.isUpdateLoading = false;
    }

    handleExpandQuoteItems() {
        this.showQuoteItems = !this.showQuoteItems;
    }

    handleChangeMessage(event) {
        this.message = event.target.value;
    }

    handleClickTaxExempt(event) {
        event.preventDefault();

        let modal = this.template.querySelector('c-b2b-modal');
        if (this.isLoading || !this.isRequestQuoteEnabled || !modal) {
            return;
        }

        modal.open({
            id: 'tax_exempt',
            title: LABELS.modalTaxExemptTitle,
            buttonsAlign: 'right',
            hideFooter: true
        });
    }

    handleCloseModal(event) {
        console.group('HANDLE CLOSE MODAL');
        console.log('event.detail', event.detail);
        console.groupEnd();
    }

    handleSubmitModal(event) {
        console.group('HANDLE SUBMIT MODAL');
        console.log('event.detail', event.detail);
        console.groupEnd();
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

    handleCloseExemptModal(event) {
        console.log('event.detail', event.detail);
        let modal = this.template.querySelector('c-b2b-modal');
        this.isLoading = true;
        this.getInitialData();
        setTimeout(() => {
            modal.hide();
        }, 7000);
    }

    async handleClickSubmit() {
        if (this.isSubmitButtonDisabled) {
            return;
        }
        this.isUpdateLoading = true;

        let response = await UTILS.doRequest(saveQuoteRequest, {
            saveQuoteResquet: {
                effectiveAccountId: this.effectiveAccountId,
                cartId: this.cartId,
                message: this.message,
                shippingAddressId: this.selectedShippingAddress,
                billingAddressId: this.selectedBillingAddress,
                quoteEstimatedTax: this.tax,
            }
        });

        let data = UTILS.responseData(response);
        if (
            UTILS.responseSuccess(response)
            && IS.stringNotEmpty(data.id)
            && IS.stringNotEmpty(data.name)
        ) {
            this.quoteId = data.id;
            this.quoteNumber = data.name;

            // Deleting the current cart
            deleteCurrentCart().catch((error) => {
                console.error(error);
            });

        } else {
            UTILS.showToast('error', LABELS.createError);
        }

        this.isUpdateLoading = false;
    }

}