import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

// METHODS
import initAddressForm from '@salesforce/apex/B2BAddressBookController.initAddressForm';

//LABELS
import selectAnOption from '@salesforce/label/c.B2B_Select_an_Option';
import shippingAddress from '@salesforce/label/c.B2B_Shipping_Address';
import address from '@salesforce/label/c.B2B_Address';
import billingAddress from '@salesforce/label/c.B2B_Billing_Address';
import clickToChangeBillingAddress from '@salesforce/label/c.B2B_Click_to_change_Billing_Address';
import addAnotherShippingAddress from '@salesforce/label/c.B2B_Add_another_Shipping_address';
import addAnotherBillingAddress from '@salesforce/label/c.B2B_Add_another_Billing_address';
import clickToChooseAddress from '@salesforce/label/c.B2B_Click_to_choose_an_address';
import clickToEditAddress from '@salesforce/label/c.B2B_Click_to_edit_an_address';
import addAnotherAddress from '@salesforce/label/c.B2B_Add_another_address';
import useThisAddress from '@salesforce/label/c.B2B_Use_this_address';
import sameAsShippingAddress from '@salesforce/label/c.B2B_Same_as_shipping_address';
import change from '@salesforce/label/c.B2B_Change';
import clickToChangeAddresses from '@salesforce/label/c.B2B_Click_to_change_Address';
import addressName from '@salesforce/label/c.B2B_Name';
import streetAddress from '@salesforce/label/c.B2B_Street_Address';
import city from '@salesforce/label/c.B2B_City';
import state from '@salesforce/label/c.B2B_State_Province';
import postcodeZip from '@salesforce/label/c.B2B_Postcode_ZIP';
import country from '@salesforce/label/c.B2B_Country';
import saveAsDefaultShippingAddress from '@salesforce/label/c.B2B_Save_as_Default_Shipping_Address';
import saveAsDefaultBillingAddress from '@salesforce/label/c.B2B_Save_as_Default_Billing_Address';
import addYourAddress from '@salesforce/label/c.B2B_Add_Your_Address';
import saveYourAddress from '@salesforce/label/c.B2B_Save_Your_Address';
import cancel from '@salesforce/label/c.B2B_Cancel';
import addBillingAddress from '@salesforce/label/c.B2B_Add_Billing_Address';
import editBillingAddress from '@salesforce/label/c.B2B_Edit_Billing_Address';
import addShippingAddress from '@salesforce/label/c.B2B_Add_Shipping_Address';
import editShippingAddress from '@salesforce/label/c.B2B_Edit_Shipping_Address';


const COMPONENT_NAME = 'b2b-checkout-addresses';

const SHIPPING = 'Shipping';
const BILLING = 'Billing';

const ADD = 'ADD';
const EDIT = 'EDIT';
const DEFAULT = 'DEFAULT';

const VALID = 'valid';
const UPSERT = 'upsert';
const USE = 'use';

const LABELS = {
    selectAnOption: selectAnOption,
    shippingAddress: shippingAddress,
    address: address,
    billingAddress: billingAddress,
    clickToChangeBillingAddress: clickToChangeBillingAddress,
    addAnotherShippingAddress: addAnotherShippingAddress,
    addAnotherBillingAddress: addAnotherBillingAddress,
    clickToChooseAddress: clickToChooseAddress,
    clickToEditAddress: clickToEditAddress,
    addAnotherAddress: addAnotherAddress,
    useThisAddress: useThisAddress,
    sameAsShippingAddress: sameAsShippingAddress,
    change: change,
    clickToChangeAddresses: clickToChangeAddresses,
    addressName: addressName,
    streetAddress: streetAddress,
    city: city,
    state: state,
    postcodeZip: postcodeZip,
    country: country,
    saveAsDefaultShippingAddress: saveAsDefaultShippingAddress,
    saveAsDefaultBillingAddress: saveAsDefaultBillingAddress,
    addYourAddress: addYourAddress,
    saveYourAddress: saveYourAddress,
    cancel: cancel,
    requiredField: 'Complete this field.',
};

const MAX_LENGTH = {
    addressName: 255,
    street: 250,
    city: 40,
    postcodeZip: 20,
};

export default class B2bCheckoutAddresses extends LightningElement {
    @api isUpdateLoading = false;
    @api countryOptions = [];
    @api stateOptions = {};
    @api shippingSelected = null;
    @api shippingAddresses = [];
    @api billingSelected = null;
    @api billingAddresses = [];
    @api sameAddresses = false;
    @api isCartSecondary = false;

    @track isFirstRender = true;
    @track customCssContainer = UTILS.customCssContainer;
    @track labels = LABELS;
    @track maxLength = MAX_LENGTH;

    @track isAddressesListEmpty = true;
    @track type = null;
    @track mode = null;
    @track isChange = false;
    @track isEdit = false;

    @track addressId = null;
    @track addressName = null;
    @track viewStateOptions = [];
    @track saveAsDefaultAddress = [];

    @track shippingAddressId = null;
    @track billingAddressId = null;

    @track isDefault = false;
    @track stateDependedValues = [];
    @track countriesAndStatesData;
    @track isAddYourAddressDisabled = true;

    countryPicklistValues = [];
    selectedCountry = '';
    selectedState = '';

    // GETTERS
    get getTitleNumber() {
        return '1';
    }

    get getTitleLabel() {
        return LABELS.address;
    }

    /* VIEW */
    get showAddressesView() {
        return IS.stringNotEmpty(this.shippingSelected) &&
            IS.arrayNotEmpty(this.shippingAddresses) &&
            IS.stringNotEmpty(this.billingSelected) &&
            IS.arrayNotEmpty(this.billingAddresses) &&
            !IS.true(this.isChange) &&
            !IS.true(this.isEdit);
    }

    get showChangeViewButton() {
        return this.showAddressesView && !IS.true(this.isCartSecondary);
    }

    get getShippingName() {
        let result = null;
        if (
            IS.stringNotEmpty(this.shippingSelected) &&
            IS.arrayNotEmpty(this.shippingAddresses)
        ) {
            this.shippingAddresses.forEach((item) => {
                if (item.id === this.shippingSelected) {
                    result = item.name;
                }
            });
        }
        return result;
    }

    get getShippingAddress() {
        let result = null;
        if (
            IS.stringNotEmpty(this.shippingSelected) &&
            IS.arrayNotEmpty(this.shippingAddresses)
        ) {
            this.shippingAddresses.forEach((item) => {
                if (item.id === this.shippingSelected) {
                    result = UTILS.getInlineAddressString(item);
                }
            });
        }
        return result;
    }

    get getBillingName() {
        let result = null;
        if (
            IS.stringNotEmpty(this.billingSelected) &&
            IS.arrayNotEmpty(this.billingAddresses)
        ) {
            this.billingAddresses.forEach((item) => {
                if (item.id === this.billingSelected) {
                    result = item.name;
                }
            });
        }
        return result;
    }

    get getBillingAddress() {
        let result = null;
        if (
            IS.stringNotEmpty(this.billingSelected) &&
            IS.arrayNotEmpty(this.billingAddresses)
        ) {
            this.billingAddresses.forEach((item) => {
                if (item.id === this.billingSelected) {
                    result = UTILS.getInlineAddressString(item);
                }
            });
        }
        return result;
    }

    /* CHANGE */
    get showAddressesChange() {
        return this.isChange;
    }

    get getTabOptions() {
        return [
            {
                value: SHIPPING,
                label: LABELS.shippingAddress,
                class: this.type == SHIPPING
                    ? 'b2b-checkout__tab b2b-checkout__tab-active'
                    : 'b2b-checkout__tab'
            },
            {
                value: BILLING,
                label: LABELS.billingAddress,
                class: this.type == BILLING
                    ? 'b2b-checkout__tab b2b-checkout__tab-active'
                    : 'b2b-checkout__tab'
            },
        ];
    }

    get getAddressOptions() {
        let result = [];
        let array = null;
        let selected = null;

        if (this.type == SHIPPING) {
            array = 'shippingAddresses';
            selected = 'shippingAddressId';

        } else if (this.type == BILLING) {
            array = 'billingAddresses';
            selected = 'billingAddressId';
        }

        if (
            IS.stringNotEmpty(array) &&
            IS.stringNotEmpty(selected) &&
            IS.arrayNotEmpty(this[array])
        ) {
            this[array].forEach((item) => {
                let newItem = {
                    id: IS.stringNotEmpty(item.id) ? item.id : null,
                    name: IS.stringNotEmpty(item.name) ? item.name : null,
                    address: UTILS.getInlineAddressString(item),
                    checked: IS.stringNotEmpty(this[selected]) && this[selected] === item.id
                };

                if (newItem.id && newItem.address) {
                    result.push(newItem);
                }
            });
        }

        return result;
    }  

    get getAddAnotherButtonLabel() {
        if (this.type === SHIPPING) {
            return LABELS.addAnotherShippingAddress;
        } else if (this.type === BILLING) {
            return LABELS.addAnotherBillingAddress;
        }
        return LABELS.addAnotherAddress;
    }

    get addressSubtitle() {
        if (this.type === SHIPPING) {
            return this.mode === EDIT ? editShippingAddress : addShippingAddress;
        } else if (this.type === BILLING) {
            return this.mode === EDIT ? editBillingAddress : addBillingAddress;
        }
    }

    /* FORM */
    get saveAsDefaultAddressOptions() {
        if (this.type === SHIPPING) {
            return [{ value: DEFAULT, label: LABELS.saveAsDefaultShippingAddress }];
        } else if (this.type === BILLING) {
            return [{ value: DEFAULT, label: LABELS.saveAsDefaultBillingAddress }];
        }
        return [];
    }

    get getAddYourAddressLabel() {
        if (this.mode === EDIT) {
            return LABELS.saveYourAddress;
        }
        return LABELS.addYourAddress;
    }

    get showCancelButton() {
        if (this.type === SHIPPING) {
            return IS.arrayNotEmpty(this.shippingAddresses);
            
        } else if (this.type === BILLING) {
            return IS.arrayNotEmpty(this.billingAddresses);
        }
    }

    // LIFECYCLES
    connectedCallback() {
        this.type = SHIPPING;

        if (
            !IS.stringNotEmpty(this.shippingSelected) ||
            !IS.arrayNotEmpty(this.shippingAddresses)
        ) {
            this.showAddShippingAddress();
            UTILS.dispatchEvent(this, VALID, false);

        } else if (
            !IS.stringNotEmpty(this.billingSelected) ||
            !IS.arrayNotEmpty(this.billingAddresses)
        ) {
            let preselectedAddress = this.shippingAddresses.find(item => item.id === this.shippingSelected);
            this.showAddBillingAddress();
            UTILS.dispatchEvent(this, VALID, false);

        } else {
            this.isAddressesListEmpty = false;
            UTILS.dispatchEvent(this, VALID, true);
        }

        this.getInitialData();
    }

    renderedCallback() {
        if (this.isFirstRender) {
            this.isFirstRender = false;
            this.addCustomCssStyles();
        }
    }

    // METHODS
    getInitialData() {
        initAddressForm()
            .then(result => {
                this.countriesAndStatesData = {
                    country: result.addressBook.countryCode,
                    state: result.addressBook.stateCode,
                    countriesCode: result.countriesCode,
                    countriesStatesCode: result.countriesStatesCode
                };
                this.addressBook = result.addressBook;
                this.selectedCountry = result.addressBook.countryCode;
                this.selectedState = result.addressBook.stateCode;
                this.countryCode = result.addressBook.countryCode;
                this.stateCode = result.addressBook.stateCode;
            })
            .catch(error => {
                console.error(error);
                this.showErrorMessage(error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    addCustomCssStyles() {
        let styleText = `
            /* CHANGE */
            .${COMPONENT_NAME}__change .slds-radio {
                line-height: 1;
            }

            .${COMPONENT_NAME}__change .slds-radio + .slds-radio {
                margin-top: 1rem;
            }

            .${COMPONENT_NAME}__change .slds-radio__label {
                display: inline-flex;
                align-items: center;
                line-height: 1;
                width: 100%;
            }

            .${COMPONENT_NAME}__change .slds-radio_faux {
                display: block;
                line-height: 1;
            }

            .${COMPONENT_NAME}__change .slds-radio_faux::after {
                background-color: var(--b2b-colorAction) !important;
            }

            .${COMPONENT_NAME}__change .slds-form-element__label {
                display: block;
                width: 100%;
                padding: 0;
                margin: 0;
                line-height: 1;
                font-size: 14px;
            }

            .${COMPONENT_NAME}__change .slds-radio__label {
                cursor: pointer;
            }

            .${COMPONENT_NAME}__change .slds-radio input[type="radio"]:focus + .slds-radio__label .slds-radio_faux {
                border-color: var(--b2b-colorAction);
                box-shadow: 0 0 3px var(--b2b-colorAction)
            }

            /* FORM ELEMENTS */
            .b2b-checkout__section-form input.slds-input,
            .b2b-checkout__section-form select.slds-input {
                font-size: 14px;
            }
            
            .b2b-checkout__section-form .slds-form-element__label {
                font-size: 12px;
            }

            .slds-form-element{
                margin-bottom: 0 !important;
            }

            /* DEFAULT ADDRESS CHECKBOX */
            .${COMPONENT_NAME}__col-default-address .slds-checkbox__label {
                display: inline-flex;
                align-items: center;
                line-height: 1;
            }

            .${COMPONENT_NAME}__col-default-address .slds-checkbox_faux {
                display: block;
                line-height: 1;
            }

            .${COMPONENT_NAME}__col-default-address .slds-checkbox_faux::after {
                border-color: var(--b2b-colorAction) !important;
            }

            .${COMPONENT_NAME}__col-default-address .slds-form-element__label {
                display: block !important;
                padding: 0;
                margin: 0;
                font-size: 14px !important;
                line-height: 1;
                transform: translateY(1px);
            }

            .${COMPONENT_NAME}__col-default-address input[type="checkbox"]:focus + .slds-checkbox__label .slds-checkbox_faux,
            .${COMPONENT_NAME}__col-default-address input[type="checkbox"]:focus:checked + .slds-checkbox__label .slds-checkbox_faux {
                border-color: var(--b2b-colorAction);
                box-shadow: 0 0 3px var(--b2b-colorAction);
            }

            /* FORM BUTTONS */
            .${COMPONENT_NAME}__col-buttons {
                display: flex;
                align-items: center;
            }

            .${COMPONENT_NAME}__col-buttons .b2b-button + .b2b-button {
                margin-left: 1rem;
            }

            @media(max-width: 574.98px) {
                .${COMPONENT_NAME}__col-buttons {
                    flex-wrap: wrap;
                }

                .${COMPONENT_NAME}__col-buttons .b2b-button {
                    width: 100%;
                }

                .${COMPONENT_NAME}__col-buttons .b2b-button + .b2b-button {
                    margin-left: 0;
                    margin-top: 10px;
                }
            }

            /* BUTTON ADD ANOTHER */
            .${COMPONENT_NAME}__button-add-another {
                margin: 1rem 0;
            }

            .${COMPONENT_NAME}__button-add-another .slds-button {
                font-size: 14px;
                font-weight: 700;
                text-decoration-line: underline;
                color: var(--b2b-colorAction);
                transition: color 0.1s;
            }

            .${COMPONENT_NAME}__button-add-another svg {
                height: 18px;
                width: 19px;
                fill: #6D6E71;
                transition: fill 0.1s;
            }

            .${COMPONENT_NAME}__button-add-another .slds-button:hover,
            .${COMPONENT_NAME}__button-add-another .slds-button:active,
            .${COMPONENT_NAME}__button-add-another .slds-button:focus {
                color: var(--b2b-colorActionDarker);
                box-shadow: none;
                outline: 0;
            }

            .${COMPONENT_NAME}__button-add-another .slds-button:focus {
                outline: auto;
            }

            .${COMPONENT_NAME}__button-add-another .slds-button:hover svg,
            .${COMPONENT_NAME}__button-add-another .slds-button:active svg,
            .${COMPONENT_NAME}__button-add-another .slds-button:focus svg {
                color: var(--b2b-colorActionDarker);
            }

            /* BUTTON USE ADDRESS */
            @media(max-width: 574.98px) {
                .${COMPONENT_NAME}__button-use-address .b2b-button {
                    display: block;
                    width: 100%;
                }
            }

            /* BUTTON EDIT ADDRESS */
            .${COMPONENT_NAME}__address-content lightning-button-icon {
                display: block;
                width: 18px;
                min-width: 18px;
                height: 18px;
                min-height: 18px;
            }

            .${COMPONENT_NAME}__address-content lightning-button-icon .slds-button {
                width: 100%;
                height: 100%;
                transition: background-color 0.1s;
            }

            .${COMPONENT_NAME}__address-content lightning-button-icon .slds-button:hover,
            .${COMPONENT_NAME}__address-content lightning-button-icon .slds-button:active,
            .${COMPONENT_NAME}__address-content lightning-button-icon .slds-button:focus {
                fill: #00aeef;
            }

            .${COMPONENT_NAME}__address-content lightning-button-icon .slds-button svg {
                width: 18px;
                height: 18px;
                transform: translateY(-1px);
                fill: ##706E6B;
                transition: fill 0.1s;
            }

            .${COMPONENT_NAME}__address-content lightning-button-icon .slds-button:hover svg,
            .${COMPONENT_NAME}__address-content lightning-button-icon .slds-button:active svg,
            .${COMPONENT_NAME}__address-content lightning-button-icon .slds-button:focus svg {
                fill: #00aeef;
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

    get getProvinceOptions() {
        if (this.selectedCountry && this.countriesAndStatesData) {
            if (this.countriesAndStatesData.countriesStatesCode.hasOwnProperty(this.selectedCountry)) {
                this.stateDependedValues = this.preparePicklistOptions(this.countriesAndStatesData.countriesStatesCode[this.selectedCountry],'state');
                this.hasNoStates =  (this.stateDependedValues.length === 0);
            }
        } else {
            this.hasNoStates = true;
        }
        return this.stateDependedValues;
    }

    get getCountryOptions() {
        if (this.countriesAndStatesData) {
            this.countryPicklistValues = this.preparePicklistOptions(Object.keys(this.countriesAndStatesData.countriesStatesCode),'country');
            return this.countryPicklistValues ;
        }
    }
    preparePicklistOptions(optionsArray, type) {
        let preparedArray = optionsArray.map((item) => {
            if (type == 'country') {
                return {label: this.countriesAndStatesData.countriesCode[item], value: item, selected: item === this.selectedCountry};
            } else {
                return {label: Object.entries(item)[0][1], value: Object.entries(item)[0][0], selected: Object.entries(item)[0][0] === this.selectedState};
            }
        });
        return preparedArray;
    }

    countryChangeProcessing() {
        if (this.selectedCountry  && this.countriesAndStatesData) {
            this.stateDependedValues = this.preparePicklistOptions(Object.keys(this.countriesAndStatesData.countriesStatesCode[this.selectedCountry]),'state');
            this.hasNoStates =  (this.stateDependedValues.length === 0);
        } 
    }

    resetFormValues() {
        this.addressId = null;
        this.addressName = null;
        this.street = null;
        this.city = null;
        this.state = null;
        this.stateCode = false;
        this.viewStateOptions = [];
        this.postalCode = null;
        this.country = null;
        this.countryCode = false;
        this.saveAsDefaultAddress = [];
    }

    showAddShippingAddress() {
        this.resetFormValues();
        this.countryCode = 'US';
        this.updateStateOptions();
        this.type = SHIPPING;
        this.mode = ADD;
        this.isChange = false;
        this.isEdit = true;
    }

    showAddBillingAddress() {
        this.resetFormValues();
        this.countryCode = 'US';
        this.updateStateOptions();
        this.type = BILLING;
        this.mode = ADD;
        this.isChange = false;
        this.isEdit = true;
    }

    formValidity() {
        let isFormValid = true;
        let Name = this.template.querySelector('lightning-input[data-name="addressName"]');
        if (Name != null && address != null){
            if(!Name) {
                Name.setCustomValidity(LABELS.requiredField);
            }
            Name.reportValidity();
            const address = this.template.querySelector('lightning-input-address');
            //Country Field Validation
            var country = address.country;

            if (!country) {
                address.setCustomValidityForField(LABELS.requiredField, 'country');
            } else {
                address.setCustomValidityForField("", 'country'); //Reset previously set message
            }

             //Street Address Field Validation
             var streetAddress = address.street;

            if (!streetAddress) {
                address.setCustomValidityForField(LABELS.requiredField, 'street');
            } else {
                address.setCustomValidityForField("", 'street'); //Reset previously set message
            }

            //city Field Validation
            var city = address.city;

            if (!city) {
                address.setCustomValidityForField(LABELS.requiredField, 'city');
            } else {
                address.setCustomValidityForField("", 'city'); //Reset previously set message
            }

            //State Field Validation
            var province = address.province;
            if(this.hasNoStates === false){
                if (!province) {
                    address.setCustomValidityForField( LABELS.requiredField, 'province');
                } else {
                    address.setCustomValidityForField("", 'province'); //Reset previously set message
                }
            } else {
                address.setCustomValidityForField("", 'province'); //Reset previously set message
            }

            //PostalCode Field Validation
            var postalCode = address.postalCode;

            if (!postalCode) {
                address.setCustomValidityForField(LABELS.requiredField, 'postalCode');
            } else {
                address.setCustomValidityForField("", 'postalCode'); //Reset previously set message
            }

            address.reportValidity(); // Refreshes the component to show or remove error messages from UI

            isFormValid =
            Name.checkValidity() &&
            address.checkValidity(); //Check if the address is Valid and accordingly proceed.
        }
        return isFormValid;
    }

    collectAddressValues() {
        let result = {
            id: IS.stringNotEmpty(this.addressId) ? this.addressId : null,
            name: IS.stringNotEmpty(this.addressName) ? this.addressName : null,
            street: IS.stringNotEmpty(this.street) ? this.street : null,
            city: IS.stringNotEmpty(this.city) ? this.city : null,
            state: null,
            stateCode: IS.stringNotEmpty(this.stateCode) && !IS.false(this.stateCode)
                ? this.stateCode
                : null,
            postalCode: IS.stringNotEmpty(this.postalCode) ? this.postalCode : null,
            country: null,
            countryCode: IS.stringNotEmpty(this.countryCode) && !IS.false(this.countryCode)
                ? this.countryCode
                : null,
            addressType: this.type === SHIPPING ? SHIPPING : BILLING,
            isDefault: IS.arrayNotEmpty(this.saveAsDefaultAddress),
            parentId: null,
            mode: this.mode,
        };

        if (IS.stringNotEmpty(result.countryCode) && IS.arrayNotEmpty(this.countryOptions)) {
            this.countryOptions.forEach((item) => {
                if (item.value === result.countryCode) {
                    result.country = item.label;
                }
            });
        }

        if (
            IS.stringNotEmpty(result.countryCode) &&
            IS.stringNotEmpty(result.stateCode) &&
            IS.objectNotEmpty(this.stateOptions) &&
            IS.arrayNotEmpty(this.stateOptions[result.countryCode])
        ) {
            this.stateOptions[result.countryCode].forEach((item) => {
                if (item.value === result.stateCode) {
                    result.state = item.label;
                }
            });
        }

        return result;
    }

    updateStateOptions() {
        let viewStateOptions = [];

        if (
            IS.stringNotEmpty(this.countryCode) &&
            IS.arrayNotEmpty(this.stateOptions[this.countryCode])
        ) {
            viewStateOptions = viewStateOptions.concat(this.stateOptions[this.countryCode]);
        }
        this.viewStateOptions = viewStateOptions;
    }

    // HANDLERS
    handleClickChange() {
        this.type = SHIPPING;
        this.mode = null;
        this.isChange = true;
        this.isEdit = false;

        this.shippingAddressId = this.shippingSelected;
        this.billingAddressId = this.billingSelected;

        UTILS.dispatchEvent(this, VALID, false);
    }

    handleClickChangeBillingAddress() {
        this.type = BILLING;
        this.mode = null;
        this.isChange = true;
        this.isEdit = false;

        this.shippingAddressId = this.shippingSelected;
        this.billingAddressId = this.billingSelected;

        UTILS.dispatchEvent(this, VALID, false);
    }


    handleChangeAddressForm(event) {
        if (this.selectedCountry != event.detail.country) {
            this.selectedCountry = event.detail.country;
            this.countryChangeProcessing();
        }
        this.countryCode = event.detail.country;
        this.street = event.detail.street;
        this.city = event.detail.city;
        this.stateCode = event.detail.province;
        this.postalCode = event.target.postalCode;
    }


    handleNameChange(event) {
        this.addressName = event.detail.value;
    }

    handleChangeSaveAsDefaultAddress(event) {
        this.saveAsDefaultAddress = event.detail.value || false;
    }

    handleClickAddAddress() {
        setTimeout(() => {
            if (this.formValidity()) {
                UTILS.dispatchEvent(this, UPSERT, this.collectAddressValues());
            }
        }, 0);
    }

    handleClickCancelAddress() {
        this.mode = null;
        this.isChange = true;
        this.isEdit = false;

        UTILS.dispatchEvent(this, VALID, false);
    }

    handleClickOnTab(event) {
        let type = event.target.dataset.value;
        if (type === BILLING) this.type = BILLING;
        else this.type = SHIPPING;
    }

    handleChangeAddress(event) {
        let value = event.target.value;
        if (!IS.stringNotEmpty(value)) return;

        if (this.type === SHIPPING) {
            this.shippingAddressId = value;
            
        } else if (this.type === BILLING) {
            this.billingAddressId = value;
        }
    }

    handleClickToEditAddress(event) {
        let id = event.target.dataset.id;
        if (!IS.stringNotEmpty(id)) return;

        this.resetFormValues();

        let array = null;
        if (this.type === SHIPPING) {
            array = 'shippingAddresses';
        } else if (this.type === BILLING) {
            array = 'billingAddresses';
        }

        if (IS.stringNotEmpty(array) && IS.arrayNotEmpty(this[array])) {
            this[array].forEach((item) => {
                if (item.id === id) {
                    this.addressId = id;
                    this.addressName = IS.stringNotEmpty(item.name) ? item.name : null;
                    this.street = IS.stringNotEmpty(item.street) ? item.street : null;
                    this.city = IS.stringNotEmpty(item.city) ? item.city : null;
                    this.postalCode = IS.stringNotEmpty(item.postalCode) ? item.postalCode : null;
                    this.stateCode = IS.stringNotEmpty(item.stateCode) ? item.stateCode : null;
                    this.countryCode = IS.stringNotEmpty(item.countryCode) ? item.countryCode : null;
                    this.selectedCountry = this.countryCode;
                    this.selectedState =this.stateCode;
                    this.countryChangeProcessing();
                    this.saveAsDefaultAddress = item.isDefault ? [DEFAULT] : [];
                }
            });
        }

        this.mode = EDIT;
        this.isChange = false;
        this.isEdit = true;

        UTILS.dispatchEvent(this, VALID, false);
    }

    handleClickAddAnotherButton() {
        this.resetFormValues();
        this.countryCode = 'US';
        this.updateStateOptions();
        this.mode = ADD;
        this.isChange = false;
        this.isEdit = true;

        UTILS.dispatchEvent(this, VALID, false);
    }

    handleClickUseAddress() {
        if (
            this.shippingAddressId === this.shippingSelected &&
            this.billingAddressId === this.billingSelected
        ) {
            this.type = SHIPPING;
            this.mode = null;
            this.isChange = false;
            this.isEdit = false;

            UTILS.dispatchEvent(this, VALID, true);

        } else {
            UTILS.dispatchEvent(this, USE, {
                shippingAddressId: this.shippingAddressId,
                billingAddressId: this.billingAddressId,
            });
        }
    }

    // API's
    @api
    apiShowView() {
        this.type = null;
        this.mode = null;
        this.isChange = false;
        this.isEdit = false;
        UTILS.dispatchEvent(this, VALID, true);
    }

    @api
    apiShowChange() {
        setTimeout(() => {
            if (this.isAddressesListEmpty) {
                this.type = null;
                this.mode = null;
                this.isChange = false;
                this.isEdit = false;
                this.isAddressesListEmpty = false;
                UTILS.dispatchEvent(this, VALID, true);
    
            } else {
                this.mode = null;
                this.isChange = true;
                this.isEdit = false;
                this.shippingAddressId = this.shippingSelected;
                this.billingAddressId = this.billingSelected;
                UTILS.dispatchEvent(this, VALID, false);
            }
        }, 0);
    }

    @api
    apiAddNewShippingAddress(preselectedAddress) {
        this.showAddShippingAddress();
        UTILS.dispatchEvent(this, VALID, false);
    }

    @api
    apiAddNewBillingAddress(preselectedAddress) {
        this.showAddBillingAddress();
        UTILS.dispatchEvent(this, VALID, false);
    }

}