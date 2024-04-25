import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

// METHODS
import initAddressForm from '@salesforce/apex/B2BAddressBookController.initAddressForm';
import createAddress from '@salesforce/apex/B2BRequestForQuoteController.createAddress';

// LABELS
const LABELS = {
    loading: 'Loading',
    shippingAddress: 'Shipping Address',
    change: 'Change',
    billingAddress: 'Billing Address',
    sameAsShippingAddress: 'Same as shipping address.',
    clickToChooseAddress: 'Click to choose an address',
    clickToEditAddress: 'Click to edit an address',
    addAnotherAddress: 'Add another {0} Address',
    useThisAddress: 'Use this Address',
    formTitle: '{0} {1} address',
    cancel: 'Cancel',
    upsertYourAddress: '{0} your Address',
    add: 'Add',
    save: 'Save',
    edit: 'Edit',
    requiredField: 'Complete this field.',
    name: 'Name',
    street: 'Street Address',
    city: 'City',
    state: 'State / Province',
    defaultOption: 'None',
    postalCode: 'Postcode / ZIP',
    country: 'Country',
    isDefault: 'Save as default address',
    addSuccess: 'The address was successfully {0}',
    addError: 'The address was not saved',
};

const VIEW = 'view';
const CHANGE = 'change';
const FORM = 'form';
const SHIPPING = 'Shipping';
const BILLING = 'Billing';
const ADD = 'add';
const EDIT = 'edit';

const MAX_LENGTH = {
    name: 255,
    street: 250,
    city: 40,
    postalCode: 20,
};

const DEFAULT_COUNTRY_CODE = 'US';
const ADDRESS_CHANGE_EVENT = 'addresschange';

export default class B2bRequestForQuoteAddresses extends LightningElement {
    @api effectiveAccountId = null;

    @track isRequestForQuoteOrCheckout = true;
    @track labels = LABELS;
    @track maxLength = MAX_LENGTH;
    @track customCssContainer = UTILS.customCssContainer;
    @track isAddessesEmpty = true;
    @track isFirstRender = true;
    @track isLoading = true;
    @track isUpdateLoading = false;

    @track mode = null; // VIEW, CHANGE, FORM
    @track type = null; // SHIPPING, BILLING
    @track upsertType = null; // ADD, EDIT

    @track shippingAddresses = [];
    @track selectedShippingAddress = null;
    @track shippingAddressValue = null;
    @track billingAddresses = [];
    @track selectedBillingAddress = null;
    @track billingAddressValue = null;
    @track countries = [];
    @track states = {};

    @track addressId = null;
    @track countryRequired = true;

    @track isDefault = false;
    @track stateDependedValues = [];
    @track countriesAndStatesData;
    @track form = {
        id: null,
        name: null,
        streetAddress: null,
        city: null,
        postalCode: null,
        isDefault: false,
        countryCode: null,
        provinceCode: null
    };

    selectedCountry = '';
    selectedState = '';

    // GETTERS
    get showView() {
        return IS.stringNotEmpty(this.mode)
            && IS.arrayNotEmpty(this.shippingAddresses)
            && IS.stringNotEmpty(this.selectedShippingAddress)
            && IS.arrayNotEmpty(this.billingAddresses)
            && IS.stringNotEmpty(this.selectedBillingAddress)
            && this.mode === VIEW;
    }

    get getShippingAddress() {
        let result = null;
        if (
            IS.arrayNotEmpty(this.shippingAddresses)
            && IS.stringNotEmpty(this.selectedShippingAddress)
        ) {
            let items = this.shippingAddresses.filter((item) => item.id === this.selectedShippingAddress);
            if (IS.arrayNotEmpty(items) && items.length === 1) {
                result = JSON.parse(JSON.stringify(items[0]));
            }
        }
        return result;
    }

    get getShippingAddressName() {
        return IS.objectNotEmpty(this.getShippingAddress)
            ? this.getShippingAddress.name
            : null;
    }

    get getShippingAddressString() {
        return IS.objectNotEmpty(this.getShippingAddress)
            ? UTILS.getInlineAddressString(this.getShippingAddress)
            : null;
    }

    get getBillingAddress() {
        let result = null;
        if (
            IS.arrayNotEmpty(this.billingAddresses)
            && IS.stringNotEmpty(this.selectedBillingAddress)
        ) {
            let items = this.billingAddresses.filter((item) => item.id === this.selectedBillingAddress);
            if (IS.arrayNotEmpty(items) && items.length === 1) {
                result = JSON.parse(JSON.stringify(items[0]));
            }
        }
        return result;
    }

    get getBillingAddressName() {
        return IS.objectNotEmpty(this.getBillingAddress)
            ? this.getBillingAddress.name
            : null;
    }

    get getBillingAddressString() {
        return IS.objectNotEmpty(this.getBillingAddress)
            ? UTILS.getInlineAddressString(this.getBillingAddress)
            : null;
    }

    get showSameAddress() {
        if (
            IS.objectNotEmpty(this.getShippingAddress)
            && IS.objectNotEmpty(this.getBillingAddress)
            && this.getShippingAddress.street === this.getBillingAddress.street
            && this.getShippingAddress.city === this.getBillingAddress.city
            && this.getShippingAddress.state === this.getBillingAddress.state
            && this.getShippingAddress.stateCode === this.getBillingAddress.stateCode
            && this.getShippingAddress.postalCode === this.getBillingAddress.postalCode
            && this.getShippingAddress.country === this.getBillingAddress.country
            && this.getShippingAddress.countryCode === this.getBillingAddress.countryCode
            && this.getShippingAddressString === this.getBillingAddressString
        ) {
            return true;
        }
        return false;
    }

    // CHANGE
    get showChange() {
        return IS.stringNotEmpty(this.mode)
            && IS.stringNotEmpty(this.shippingAddressValue)
            && IS.stringNotEmpty(this.billingAddressValue)
            && this.mode === CHANGE;
    }

    get getTabOptions() {
        return [
            {
                value: SHIPPING,
                label: LABELS.shippingAddress,
                class: this.type === SHIPPING
                    ? 'b2b-request-for-quote-addresses__tab b2b-request-for-quote-addresses__tab-active'
                    : 'b2b-request-for-quote-addresses__tab'
            },
            {
                value: BILLING,
                label: LABELS.billingAddress,
                class: this.type === BILLING
                    ? 'b2b-request-for-quote-addresses__tab b2b-request-for-quote-addresses__tab-active'
                    : 'b2b-request-for-quote-addresses__tab'
            },
        ];
    }

    get getAddressOptions() {
        let result = [];
        let array = null;
        let selected = null;

        if (this.type === SHIPPING) {
            array = 'shippingAddresses';
            selected = 'shippingAddressValue';

        } else if (this.type === BILLING) {
            array = 'billingAddresses';
            selected = 'billingAddressValue';
        }

        if (
            IS.stringNotEmpty(array)
            && IS.stringNotEmpty(selected)
            && IS.arrayNotEmpty(this[array])
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

    get getAddAnotherAddressLabel() {
        return UTILS.prepareLabel(LABELS.addAnotherAddress, [
            this.type === BILLING ? BILLING : SHIPPING
        ]);
    }

    // FORM
    get showForm() {
        return !this.isLoading
            && IS.stringNotEmpty(this.mode)
            && this.mode === FORM;
    }

    get getFormTitle() {
        return UTILS.prepareLabel(LABELS.formTitle, [
            this.upsertType === ADD ? LABELS.add : LABELS.edit,
            this.type === BILLING ? BILLING : SHIPPING
        ]);
    }

    get getStateOptions() {
        return this.states[this.countryCode];
    }

    get getStateRequired() {
        return IS.arrayNotEmpty(this.getStateOptions);
    }

    get getStateDisabled() {
        return !this.getStateRequired || this.isFormDisabled;
    }

    get getDefaultCountry() {
        let result = null;
        if (IS.arrayNotEmpty(this.countries)) {
            this.countries.forEach((item) => {
                if (item.value === DEFAULT_COUNTRY_CODE) {
                    result = item.label;
                }
            });
        }
        return result;
    }

    get isFormDisabled() {
        return this.isUpdateLoading;
    }

    get showUpsertCancelButton() {
        if (
            (this.type === SHIPPING && IS.arrayNotEmpty(this.shippingAddresses))
            || (this.type === BILLING && IS.arrayNotEmpty(this.billingAddresses))
        ) {
            return true;
        }
        return false;
    }

    get getUpsertYourAddressLabel() {
        return UTILS.prepareLabel(LABELS.upsertYourAddress, [
            this.upsertType === ADD ? LABELS.add : LABELS.save
        ]);
    }

    get isFormValid() {
        let isValid = true;

        let fields = ['name', 'street', 'country', 'countryCode', 'city', 'postalCode'];
        if (this.getStateRequired) {
            fields.push('state');
            fields.push('stateCode');
        }

        fields.forEach((item) => {
            if (!IS.stringNotEmpty(this[item])) {
                isValid = false;
            }
        });

        return isValid;
    }

    get isUpsertButtonDisabled() {
        return !this.formValidity;
    }

    // LIFECYCLES
    async connectedCallback() {
        // await this.getInitialData();
        this.resetForm();
        this.isLoading = true;
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
                this.form.countryCode = result.addressBook.countryCode;
                this.form.stateCode = result.addressBook.stateCode;
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
            /* EDIT BUTTON */
            c-b2b-request-for-quote-addresses .b2b-request-for-quote-addresses__change .b2b-request-for-quote-addresses__address-content + lightning-button-icon .slds-button__icon {
                width: 19px;
                height: 19px;
            }

            .b2b-request-for-quote-addresses__add-another-address .slds-button {
                font-size: 14px;
                font-weight: 600;
                line-height: 38px;
                text-decoration: underline;
            }

            /* FORM */
            .b2b-request-for-quote-addresses__form-fields lightning-input,
            .b2b-request-for-quote-addresses__form-fields c-b2b-select {
                margin-bottom: 0;
            }

            .b2b-request-for-quote-addresses__form-fields lightning-input slds-form-element{
                margin-bottom: 0 !important;
            }

            .b2b-request-for-quote-addresses__form-fields lightning-input .slds-form-element__label,
            .b2b-request-for-quote-addresses__form-fields c-b2b-select .b2b-select__label {
                font-size: 12px;
                line-height: 1.3;
                color: #231F20;
            }

            .b2b-request-for-quote-addresses__form-fields lightning-input .slds-input,
            .b2b-request-for-quote-addresses__form-fields c-b2b-select .b2b-select__select {
                font-size: 14px;
                color: #231F20;
            }

            .b2b-request-for-quote-addresses__form-fields lightning-input[data-name="isDefault"] {
                margin-bottom: 0;
            }
        `;

        UTILS.addCustomCssStyles(this.template, styleText);
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

    parseNewAddress(data) {
        let newAddress = {};
        if (IS.objectNotEmpty(data)) {
            newAddress.id = IS.stringNotEmpty(data.Id) ? data.Id : null;
            newAddress.type = IS.stringNotEmpty(data.AddressType)
                && (data.AddressType === SHIPPING || data.AddressType === BILLING)
                    ? data.AddressType
                    : null;
            newAddress.isDefault = IS.true(data.IsDefault) ? true : false;
            newAddress.isPrimary = IS.true(data.IsPrimary) ? true : false;
            newAddress.name = IS.stringNotEmpty(data.Name) ? data.Name : null;
            newAddress.street = IS.stringNotEmpty(data.Street) ? data.Street : null;
            newAddress.city = IS.stringNotEmpty(data.City) ? data.City : null;
            newAddress.stateCode = IS.stringNotEmpty(data.StateCode) ? data.StateCode : null;
            newAddress.postalCode = IS.stringNotEmpty(data.PostalCode) ? data.PostalCode : null;
            newAddress.countryCode = IS.stringNotEmpty(data.CountryCode) ? data.CountryCode : null;
        }

        let isAddressValid = false;
        if (
            IS.objectNotEmpty(newAddress)
            && IS.stringNotEmpty(newAddress.id)
            && IS.stringNotEmpty(newAddress.type)
            && IS.stringNotEmpty(newAddress.name)
            && IS.stringNotEmpty(newAddress.street)
            && IS.stringNotEmpty(newAddress.city)
            && IS.stringNotEmpty(newAddress.postalCode)
            && IS.stringNotEmpty(newAddress.countryCode)
        ) {
            isAddressValid = true;
        }
      
        if (isAddressValid) {
            if (newAddress.type === SHIPPING) {

                // Reset default
                if (newAddress.isDefault) {
                    this.shippingAddresses.forEach((item) => {
                        item.isDefault = false;
                    });
                }

                // Add / Edit address
                if (this.upsertType === ADD) {
                    this.shippingAddresses = [].concat(this.shippingAddresses).concat([newAddress]);
                } else {
                    this.shippingAddresses.forEach((item) => {
                        if (item.id === newAddress.id) {
                            item.name = newAddress.name;
                            item.street = newAddress.street;
                            item.city = newAddress.city;
                            item.state = newAddress.state;
                            item.stateCode = newAddress.stateCode;
                            item.postalCode = newAddress.postalCode;
                            item.country = newAddress.country;
                            item.countryCode = newAddress.countryCode;
                            item.isDefault = newAddress.isDefault;
                        }
                    });
                }

                // Sort by default
                if (IS.arrayNotEmpty(this.shippingAddresses)) {
                    this.shippingAddresses.sort((a, b) => {
                        if (a.isDefault < b.isDefault) return 1;
                        if (a.isDefault > b.isDefault) return -1;
                        return 0;
                    });
                }

                // Set new value
                this.shippingAddressValue = newAddress.id;

                // Open list or form
                if (!IS.arrayNotEmpty(this.billingAddresses)) {
                    this.prepapulateFormById(SHIPPING, newAddress.id);
                    this.type = BILLING;
                    this.upsertType = ADD;
                    this.mode = FORM;
                } else {
                    if (this.isAddessesEmpty) {
                        this.isAddessesEmpty = false;
                        if (
                            IS.arrayNotEmpty(this.shippingAddresses)
                            && IS.stringNotEmpty(this.shippingAddressValue)
                            && IS.arrayNotEmpty(this.billingAddresses)
                            && IS.stringNotEmpty(this.billingAddressValue)
                        ) {
                            this.selectedShippingAddress = this.shippingAddressValue;
                            this.selectedBillingAddress = this.billingAddressValue;
                            this.mode = VIEW;
                            return;
                        } else {
                            this.type = BILLING;
                        }
                    }
                    this.mode = CHANGE;
                }

            } else if (newAddress.type === BILLING) {

                // Reset default
                if (newAddress.isDefault) {
                    this.billingAddresses.forEach((item) => {
                        item.isDefault = false;
                    });
                }

                // Add / Edit address
                if (this.upsertType === ADD) {
                    this.billingAddresses = [].concat(this.billingAddresses).concat([newAddress]);
                } else {
                    this.billingAddresses.forEach((item) => {
                        if (item.id === newAddress.id) {
                            item.name = newAddress.name;
                            item.street = newAddress.street;
                            item.city = newAddress.city;
                            item.state = newAddress.state;
                            item.stateCode = newAddress.stateCode;
                            item.postalCode = newAddress.postalCode;
                            item.country = newAddress.country;
                            item.countryCode = newAddress.countryCode;
                            item.isDefault = newAddress.isDefault;
                        }
                    });
                }

                // Sort by default
                if (IS.arrayNotEmpty(this.billingAddresses)) {
                    this.billingAddresses.sort((a, b) => {
                        if (a.isDefault < b.isDefault) return 1;
                        if (a.isDefault > b.isDefault) return -1;
                        return 0;
                    });
                }

                // Set new value
                this.billingAddressValue = newAddress.id;

                // Open list or form
                if (!IS.arrayNotEmpty(this.shippingAddresses)) {
                    this.prepapulateFormById(BILLING, newAddress.id);
                    this.type = SHIPPING;
                    this.upsertType = ADD;
                    this.mode = FORM;
                } else {

                    // If there were no addresses when opening the page
                    if (this.isAddessesEmpty) {
                        this.isAddessesEmpty = false;
                        if (
                            IS.arrayNotEmpty(this.shippingAddresses)
                            && IS.stringNotEmpty(this.shippingAddressValue)
                            && IS.arrayNotEmpty(this.billingAddresses)
                            && IS.stringNotEmpty(this.billingAddressValue)
                        ) {
                            this.selectedShippingAddress = this.shippingAddressValue;
                            this.selectedBillingAddress = this.billingAddressValue;
                            this.mode = VIEW;
                            return;
                        } else {
                            this.type = SHIPPING;
                        }
                    }
                    this.mode = CHANGE;
                }
            }
        }
    }

    resetForm() {
        this.form.id = null;
        this.form.name = null;
        this.form.streetAddress = null;
        this.form.city = null;
        this.form.provinceCode = null;
        this.form.postalCode = null;
        this.form.countryCode = DEFAULT_COUNTRY_CODE;
        this.isDefault = false;
    }

    prepapulateFormById(type, id) {
        this.resetForm();

        if (this.upsertType === EDIT) {
            this.form.id = IS.stringNotEmpty(id) ? id : null;
        }

        let address = {};
        if (IS.stringNotEmpty(id)) {
            if (type === SHIPPING) {
                this.shippingAddresses.forEach((item) => {
                    if (item.id === id) {
                        address = JSON.parse(JSON.stringify(item));
                    }
                });
            } else if (type === BILLING) {
                this.billingAddresses.forEach((item) => {
                    if (item.id === id) {
                        address = JSON.parse(JSON.stringify(item));
                    }
                });
            }
        }
        if (IS.objectNotEmpty(address)) {
            this.form.name = IS.stringNotEmpty(address.name) ? address.name : null;
            this.form.streetAddress = IS.stringNotEmpty(address.street) ? address.street : null;
            this.form.city = IS.stringNotEmpty(address.city) ? address.city : null;
            this.form.provinceCode = IS.stringNotEmpty(address.stateCode) ? address.stateCode : null;
            this.form.postalCode = IS.stringNotEmpty(address.postalCode) ? address.postalCode : null;
            this.form.countryCode = IS.stringNotEmpty(address.countryCode) ? address.countryCode : DEFAULT_COUNTRY_CODE;
            this.isDefault = IS.true(address.isDefault) ? true : false;
        }
    }

    formValidity() {
        let isFormValid = true;
        let Name = this.template.querySelector('lightning-input[data-name="name"]');
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
       
            return isFormValid;
    }

    executeStatus() {
        UTILS.dispatchEvent(this, ADDRESS_CHANGE_EVENT, {
            isValid: this.mode === VIEW,
            shippingAddressId: IS.stringNotEmpty(this.selectedShippingAddress) && this.mode === VIEW
                ? this.selectedShippingAddress
                : null,
            billingAddressId: IS.stringNotEmpty(this.selectedBillingAddress) && this.mode === VIEW
                ? this.selectedBillingAddress
                : null,
        });
    }

    // HANDLERS
    handleChangeAddressForm(event) {
        if (this.selectedCountry != event.detail.country) {
            this.selectedCountry = event.detail.country;
            this.countryChangeProcessing();
        }
        this.form.countryCode = event.detail.country;
        this.form.streetAddress = event.detail.street;
        this.form.city = event.detail.city;
        this.form.provinceCode = event.detail.province;
        this.form.postalCode = event.target.postalCode;
    }


    handleNameChange(event) {
        this.form.name = event.detail.value;
    }

    handleClickViewShippingAddress(event) {
        event.preventDefault();
        this.shippingAddressValue = this.selectedShippingAddress;
        this.billingAddressValue = this.selectedBillingAddress;
        this.type = SHIPPING;
        this.mode = CHANGE;
        this.executeStatus();
    }

    handleClickViewChange(event) {
        event.preventDefault();
        this.shippingAddressValue = this.selectedShippingAddress;
        this.billingAddressValue = this.selectedBillingAddress;
        this.type = SHIPPING;
        this.mode = CHANGE;
        this.executeStatus();
    }

    handleClickViewBillingAddress(event) {
        event.preventDefault();
        this.shippingAddressValue = this.selectedShippingAddress;
        this.billingAddressValue = this.selectedBillingAddress;
        this.type = BILLING;
        this.mode = CHANGE;
        this.executeStatus();
    }

    handleClickTab(event) {
        let type = event.target.dataset.value;
        this.type = IS.stringNotEmpty(type) && type === BILLING ? BILLING : SHIPPING;
    }

    handleChangeAddress(event) {
        let value = event.target.value;
        if (!IS.stringNotEmpty(value)) {
            return;
        }

        if (this.type === SHIPPING) {
            this.shippingAddressValue = value;
            
        } else if (this.type === BILLING) {
            this.billingAddressValue = value;
        }
    }

    handleClickEditAddress(event) {
        let id = event.target.dataset.id;
        if (!IS.stringNotEmpty(id)) {
            return;
        }
        this.upsertType = EDIT;
        this.prepapulateFormById(this.type, id);
        this.selectedCountry = this.form.countryCode;
        this.selectedState = this.form.provinceCode;
        this.countryChangeProcessing();
        this.mode = FORM;
        this.executeStatus();
    }

    handleClickAddAnotherAddress() {
        this.resetForm();
        this.upsertType = ADD;
        this.mode = FORM;
        this.executeStatus();
    }

    handleClickUseThisAddress() {
        if (
            IS.arrayNotEmpty(this.shippingAddresses)
            && IS.stringNotEmpty(this.shippingAddressValue)
            && IS.arrayNotEmpty(this.billingAddresses)
            && IS.stringNotEmpty(this.billingAddressValue)
        ) {
            this.selectedShippingAddress = this.shippingAddressValue;
            this.selectedBillingAddress = this.billingAddressValue;
            this.mode = VIEW;
        }
        this.executeStatus();
    }

    handleChangeFormElement(event) {
        let name = event.target.name;
        let value = event.target.value;

        if (IS.stringNotEmpty(name)) {
            if (name !== 'street') {
                value = UTILS.prepareString(value);
            }
            this[name] = value;
            event.target.value = value;
            event.target.reportValidity();
        }
    }

    handleChangeState(event) {
        let detail = event.detail;
        if (
            IS.objectNotEmpty(detail)
            && IS.stringNotEmpty(detail.value)
        ) {
            this.stateCode = detail.value;
            this.states[this.countryCode].forEach((item) => {
                if (item.value === this.stateCode) {
                    this.state = item.label;
                }
            });
        }
    }

    handleChangeCountry(event) {
        let detail = event.detail;
        if (
            IS.objectNotEmpty(detail)
            && IS.stringNotEmpty(detail.value)
        ) {
            this.countryCode = detail.value;
            this.countries.forEach((item) => {
                if (item.value === this.countryCode) {
                    this.country = item.label;
                }
            });

            this.state = null;
            this.stateCode = null;
        }
    }

    handleChangeIsDefault(event) {
        this[event.target.dataset.name] = event.target.checked;
    }

    handleClickUpsertCancel() {
        this.mode = CHANGE;
        this.resetForm();
        this.executeStatus();
    }

    async handleClickUpsertAddress() {
        if (
            this.isFormDisabled ||
            !this.formValidity()
        ) return;
        this.isUpdateLoading = true;
       
        let address = {
            'Id': IS.stringNotEmpty(this.form.id) ? this.form.id : null,
            'AddressType': this.type,
            'Name': IS.stringNotEmpty(this.form.name) ? this.form.name: null,
            'Street': IS.stringNotEmpty(this.form.streetAddress) ? this.form.streetAddress : null,
            'City': IS.stringNotEmpty(this.form.city) ? this.form.city : null,
            // 'State': IS.stringNotEmpty(this.form.state) ? this.state : null,
            'StateCode': IS.stringNotEmpty(this.form.provinceCode) ? this.form.provinceCode : null,
            'PostalCode': IS.stringNotEmpty(this.form.postalCode) ? this.form.postalCode : null,
            // 'Country': IS.stringNotEmpty(this.form.country) ? this.country : null,
            'CountryCode': IS.stringNotEmpty(this.form.countryCode) ? this.form.countryCode : null,
            'IsDefault': IS.true(this.isDefault) ? true : false,
            'ParentId': this.effectiveAccountId
        };
        let response = await UTILS.doRequest(createAddress, { address });
        
        if (UTILS.responseSuccess(response)) {
            this.parseNewAddress(UTILS.responseData(response));
            UTILS.showToast('success', UTILS.prepareLabel(LABELS.addSuccess, [
                this.upsertType === ADD ? 'added' : 'updated'
            ]));
        } else {
            UTILS.showToast('error', LABELS.addError);
        }
        this.isUpdateLoading = false;
        this.executeStatus();
    }

    // API's
    @api
    initial(data) {
        if (IS.objectNotEmpty(data)) {
            this.shippingAddresses = IS.arrayNotEmpty(data.shippingAddresses)
                ? data.shippingAddresses
                : [];
            this.selectedShippingAddress = IS.stringNotEmpty(data.selectedShippingAddress)
                ? data.selectedShippingAddress
                : null;
            this.shippingAddressValue = IS.stringNotEmpty(data.selectedShippingAddress)
                ? data.selectedShippingAddress
                : null;
            this.billingAddresses = IS.arrayNotEmpty(data.billingAddresses)
                ? data.billingAddresses
                : [];
            this.selectedBillingAddress = IS.stringNotEmpty(data.selectedBillingAddress)
                ? data.selectedBillingAddress
                : null;
            this.billingAddressValue = IS.stringNotEmpty(data.selectedBillingAddress)
                ? data.selectedBillingAddress
                : null;

            // If there were no addresses when opening the page
            this.isAddessesEmpty = !IS.arrayNotEmpty(this.shippingAddresses)
                || !IS.arrayNotEmpty(this.billingAddresses);

            // Set mode
            if (
                IS.arrayNotEmpty(this.shippingAddresses)
                && IS.stringNotEmpty(this.selectedShippingAddress)
                && IS.arrayNotEmpty(this.billingAddresses)
                && IS.stringNotEmpty(this.selectedBillingAddress)
            ) {
                this.mode = VIEW;

            } else if (!IS.arrayNotEmpty(this.shippingAddresses)) {
                this.resetForm();
                this.type = SHIPPING;
                this.upsertType = ADD;
                this.mode = FORM;

            } else if (
                IS.arrayNotEmpty(this.shippingAddresses)
                && IS.stringNotEmpty(this.selectedShippingAddress)
                && !IS.arrayNotEmpty(this.billingAddresses)
            ) {
                this.prepapulateFormById(SHIPPING, this.selectedShippingAddress);
                this.type = BILLING;
                this.upsertType = ADD;
                this.mode = FORM;

            } else if (!IS.arrayNotEmpty(this.billingAddresses)) {
                this.type = BILLING;
                this.upsertType = ADD;
                this.mode = FORM;
            }
        }
    }

    @api
    openChange() {
        this.type = SHIPPING;
        this.mode = CHANGE;
    }

}