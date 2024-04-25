import { LightningElement, api, track } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';

import completeField from '@salesforce/label/c.B2B_General_Message_For_Required_Field';
import country from '@salesforce/label/c.B2B_Country';
import state from '@salesforce/label/c.B2B_State_Province';
import { UTILS } from 'c/b2bUtils';

export default class B2bCountryStatePicklist extends LightningElement {
    @api hasNoStates = false;

    LABELS = {
        completeField,
        country,
        state
    }

    @track countryPicklistValues = [];
    @track stateDependedValues = [];

    countriesAndStates;
    @track countriesAndStatesData = {};
    country = '';
    state = '';
    isCountyNotSelectedOrStateEmpty = true;

    hasCountryError = false;
    hasStateError = false;
    isCityInputHasError = false;

    get countryClass() {
        return `${this.hasCountryError ? 'slds-has-error' : ''} slds-form-element  slds-m-top_medium slds-size--3-of-5 b2b-mobile-full-width slds-p-bottom_small slds-p-right_small`;
    }

    get stateClass() {
        return `${this.hasStateError ? 'slds-has-error' : ''} slds-form-element  slds-m-top_medium slds-size--2-of-5 b2b-mobile-full-width`;
    }

    get stateSelected() {
        return this.state === '' || this.state === undefined;
    }

    get selectCssStyles() {
        return (FORM_FACTOR === 'Small') ? 'slds-select input mobile' : 'slds-select input';
    }

    get countryPicklistCssStyles() {
        return (this.isCityInputHasError && this.country) ? 'slds-form-element__control error-margin' : 'slds-form-element__control';
    }

    @api
    get isErrorCityInput() {
        return this.isCityInputHasError;
    }

    set isErrorCityInput(value) {
        this.isCityInputHasError = value;
    }

    @api
    get countriesAndStatesInfo() {
        return this.countriesAndStatesData;
    }

    set countriesAndStatesInfo(value) {
        if (value) {
            this.countriesAndStatesData = JSON.parse(JSON.stringify(value));
            this.initCountryAndState(this.countriesAndStatesData);
        }
    }

    handleCountryChange(event) {
        this.countryChangeProcessing(event.target.name, event.target.value);
    }

    handleStateChange(event) {
        this.stateChangeProcessing(event.target.name, event.target.value);
    }

    countryChangeProcessing(name, value) {
        this[name] = value;

        if (value) {
            this.stateDependedValues = this.preparePicklistOptions(this.countriesAndStates[value], '', 'state');
            this.hasCountryError = !value;
            this.isCountyNotSelectedOrStateEmpty = (this.stateDependedValues.length === 1);
            this.hasNoStates = this.isCountyNotSelectedOrStateEmpty;

            if (this.isCountyNotSelectedOrStateEmpty && this.hasStateError) {
                this.hasStateError = false;
            }

            this.countryPicklistValues.forEach(country => {
                country.selected = (country.value === this.country)
            });

            this.stateDependedValues.forEach((state) => {
                if (state.value === '') {
                    state.selected = true;
                }
            });

            this.state = '';

            this.dispatchEvent(new CustomEvent("countrychange", { detail: value }));
            this.dispatchEvent(new CustomEvent("statechange", { detail: '' }));
        } else {
            this.stateDependedValues = [{
                label: 'Select State',
                value: '',
                selected: true
            }];

            this.country = '';
            this.state = '';

            this.hasCountryError = true;
            this.hasStateError = true;

            this.dispatchEvent(new CustomEvent("countrychange", { detail: '' }));
            this.dispatchEvent(new CustomEvent("statechange", { detail: '' }));

            this.isCountyNotSelectedOrStateEmpty = true;
        }
    }

    stateChangeProcessing(name, value) {
        this[name] = value;

        this.stateDependedValues.forEach((state) => {
            state.selected = (state.value === this.state);
        });

        this.dispatchEvent(new CustomEvent("statechange", { detail: value }));
        this.hasStateError = !value;
    }

    @api
    validateInputFields() {
        let isValid = false;

        if (!this.country) {
            this.hasCountryError = true;
            this.hasStateError = true;

        } else if (this.countriesAndStates[this.country].length) {
            this.hasCountryError = !this.country;
            this.hasStateError = !this.state;

            isValid = !this.hasCountryError && !this.hasStateError;

        } else {
            this.hasCountryError = !this.country;
            this.hasStateError = false;

            isValid = !this.hasCountryError;
        }

        return isValid;
    }

    @api
    initCountryAndState(countriesAndStatesData) {
        this.countriesAndStates = countriesAndStatesData.countriesAndStates;
        this.country = countriesAndStatesData.country || 'United States';
        this.state = countriesAndStatesData.state;

        this.countryPicklistValues = this.preparePicklistOptions(Object.keys(countriesAndStatesData.countriesAndStates), '', 'country');
        let countrySelectTag = this.template.querySelector('[name="country"]');
        if (countrySelectTag && countrySelectTag.value && this.country && UTILS.isBrowserFirefox()) {
            countrySelectTag.value = this.country;
        }

        if (this.country) {
            this.stateDependedValues = this.preparePicklistOptions(this.countriesAndStates[this.country], '', 'state');

            let stateSelectTag = this.template.querySelector('[name="state"]');
            if (stateSelectTag && stateSelectTag.value && UTILS.isBrowserFirefox()) {
                stateSelectTag.value = !this.state ? '' : this.state;
            }

            this.isCountyNotSelectedOrStateEmpty = (this.stateDependedValues.length === 1);
            this.hasNoStates = this.isCountyNotSelectedOrStateEmpty;
        }

        this.dispatchEvent(new CustomEvent("countrychange", { detail: this.country }));
        this.dispatchEvent(new CustomEvent("statechange", { detail: this.state }));
        this.dispatchEvent(new CustomEvent("hidespinner"));
    }

    preparePicklistOptions(optionsArray, selectedValue, type) {
        let preparedArray = optionsArray.map((item) => {
            return {label: item, value: item, selected: item === ((type === 'country') ? this.country : this.state)};
        });

        preparedArray.unshift({
            label: (type === 'country') ? 'Select Country' : 'Select State',
            value: '',
            selected: (selectedValue === '')
        });
        return preparedArray;
    }

    @api
    resetError() {
        this.hasCountryError = false;
        this.hasStateError = false;
    }
}