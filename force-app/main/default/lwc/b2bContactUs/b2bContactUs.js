import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

// METHODS
import createCase from '@salesforce/apex/B2BContactUsController.createCase';
import _getCaseFieldsPicklistOptions from '@salesforce/apex/B2BContactUsController.getCaseFieldsPicklistOptions';

// LABELS
import B2B_Contact_Us_Loading from '@salesforce/label/c.B2B_Contact_Us_Loading';
import B2B_Contact_Us_Form_Title from '@salesforce/label/c.B2B_Contact_Us_Form_Title';
import B2B_Contact_Us_Form_Subtitle from '@salesforce/label/c.B2B_Contact_Us_Form_Subtitle';
import B2B_Contact_Us_First_Name from '@salesforce/label/c.B2B_Contact_Us_First_Name';
import B2B_Contact_Us_Last_Name from '@salesforce/label/c.B2B_Contact_Us_Last_Name';
import B2B_Contact_Us_Email from '@salesforce/label/c.B2B_Contact_Us_Email';
import B2B_Contact_Us_Company_Name from '@salesforce/label/c.B2B_Contact_Us_Company_Name';
import B2B_Contact_Us_Phone_Number from '@salesforce/label/c.B2B_Contact_Us_Phone_Number';
import B2B_Contact_Us_Subject from '@salesforce/label/c.B2B_Contact_Us_Subject';
import B2B_Contact_Us_Description from '@salesforce/label/c.B2B_Contact_Us_Description';
import B2B_Contact_Us_Button_Cancel from '@salesforce/label/c.B2B_Contact_Us_Button_Cancel';
import B2B_Contact_Us_Button_Submit from '@salesforce/label/c.B2B_Contact_Us_Button_Submit';
import B2B_Contact_Us_Required_Field from '@salesforce/label/c.B2B_Contact_Us_Required_Field';
import B2B_Contact_Us_Invalid_Format from '@salesforce/label/c.B2B_Contact_Us_Invalid_Format';
import B2B_Contact_Us_Success_Message from '@salesforce/label/c.B2B_Contact_Us_Success_Message';
import B2B_Contact_Us_Contact_Company_Name from '@salesforce/label/c.B2B_Contact_Us_Contact_Company_Name';
import B2B_Contact_Us_Error_Message from '@salesforce/label/c.B2B_Contact_Us_Error_Message';
import B2B_Contact_Us_Contact_Email from '@salesforce/label/c.B2B_Contact_Us_Contact_Email';
import B2B_Contact_Us_Sidebar_Title from '@salesforce/label/c.B2B_Contact_Us_Sidebar_Title';
import B2B_Contact_Us_Sidebar_Toll_Free from '@salesforce/label/c.B2B_Contact_Us_Sidebar_Toll_Free';
import B2B_Contact_Us_Sidebar_Phone from '@salesforce/label/c.B2B_Contact_Us_Sidebar_Phone';
import B2B_Contact_Us_Sidebar_Fax from '@salesforce/label/c.B2B_Contact_Us_Sidebar_Fax';
import B2B_Contact_Us_Sidebar_Email from '@salesforce/label/c.B2B_Contact_Us_Sidebar_Email';
import B2B_Contact_Us_Contact_Method from '@salesforce/label/c.B2B_Contact_Us_Contact_Method';
import B2B_Contact_Us_Contact_Time from '@salesforce/label/c.B2B_Contact_Us_Contact_Time';
import B2B_Contact_Us_Contact_Reason from '@salesforce/label/c.B2B_Contact_Us_Contact_Reason';
import B2B_Contact_Us_Existing_Order from '@salesforce/label/c.B2B_Contact_Us_Existing_Order';
import B2B_Register_Select from '@salesforce/label/c.B2B_Register_Select';

const LABELS = {
    loading: B2B_Contact_Us_Loading,
    formTitle: B2B_Contact_Us_Form_Title,
    formSubtitle: B2B_Contact_Us_Form_Subtitle,
    firstName: B2B_Contact_Us_First_Name,
    lastName: B2B_Contact_Us_Last_Name,
    email: B2B_Contact_Us_Email,
    companyName: B2B_Contact_Us_Company_Name,
    phoneNumber: B2B_Contact_Us_Phone_Number,
    subject: B2B_Contact_Us_Subject,
    description: B2B_Contact_Us_Description,
    buttonCancel: B2B_Contact_Us_Button_Cancel,
    buttonSubmit: B2B_Contact_Us_Button_Submit,
    requiredField: B2B_Contact_Us_Required_Field,
    invalidFormat: B2B_Contact_Us_Invalid_Format,
    successMessage: B2B_Contact_Us_Success_Message,
    contactCompanyName: B2B_Contact_Us_Contact_Company_Name,
    errorMessage: B2B_Contact_Us_Error_Message,
    contactEmail: B2B_Contact_Us_Contact_Email,
    sidebarTitle: B2B_Contact_Us_Sidebar_Title,
    sidebarTollFree: B2B_Contact_Us_Sidebar_Toll_Free,
    sidebarPhone: B2B_Contact_Us_Sidebar_Phone,
    sidebarFax: B2B_Contact_Us_Sidebar_Fax,
    sidebarEmail: B2B_Contact_Us_Sidebar_Email,
    contactMethod: B2B_Contact_Us_Contact_Method,
    contactTime: B2B_Contact_Us_Contact_Time,
    contactReason: B2B_Contact_Us_Contact_Reason,
    existingOrder: B2B_Contact_Us_Existing_Order,
    select: B2B_Register_Select
}

const COMPONENT_NAME = 'b2b-contact-us';

const MAX_LENGTH = {
    firstName: 40,
    lastName: 40,
    email: 80,
    companyName: 80,
    phoneNumber: 40,
    subject: 255,
    description: 31900,
};

export default class B2bContactUs extends LightningElement {
    @api formTitle = null;
    @api formSubtitle = null;
    @api showSidebar = false;
    @api sidebarTitle = null;
    @api streetLine1 = null;
    @api streetLine2 = null;
    @api tollFreeLabel = null;
    @api tollFreeNumber = null;
    @api phoneLabel = null;
    @api phoneNumber = null;
    @api faxLabel = null;
    @api faxNumber = null;
    @api emailLabel = null;
    @api email = null;
    @api googleMapUrl = null;

    @track isGuest = UTILS.isGuest;
    @track isUpdateLoading = false;
    @track isFirstRender = true;
    @track customCssContainer = UTILS.customCssContainer;
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);
    @track labels = LABELS;
    @track maxLength = MAX_LENGTH;
    contactMethodOptions; //To bring picklist values for contact method 
    contactTimeOptions; //To bring picklist values for contact time
    contactReasonOptions; //To bring picklist values for contact reason
    countriesAndStatesData; //Data to show country and state
    countriesCodeData; //Data to get country code
    countriesStatesCodeData; //Data to get country and state code
    hasCountryErrorMessage; //Data brought from component b2b-country-state-picklists
    existingOrderOn; //To show field of orders
    existingOrderOptions; //To show 5 last orders

    @track form = {
        isGuestUser: UTILS.isGuest,
        firstName: null,
        lastName: null,
        email: null,
        companyName: null,
        phoneNumber: null,
        subject: null,
        description: null,
        contactMethod: null,
        contactTime: null,
        country: null,
        state: null,
        contactReason: null,
        existingOrder: null
    };

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper}`;
    }

    get getFormTitle() {
        return IS.stringNotEmpty(this.formTitle)
            ? this.formTitle
            : LABELS.formTitle;
    }

    get getFormSubtitle() {
        return IS.stringNotEmpty(this.formSubtitle)
            ? this.formSubtitle
            : LABELS.formSubtitle;
    }

    get getShowSidebar() {
        return this.showSidebar
            && (
                this.showCompanyStreet
                || this.showTollFreeNumber
                || this.showPhoneNumber
                || this.showFaxNumber
                || this.showEmail
            );
    }

    get getSidebarTitle() {
        return IS.stringNotEmpty(this.sidebarTitle)
            ? this.sidebarTitle
            : LABELS.sidebarTitle;
    }

    get showCompanyStreet() {
        return IS.stringNotEmpty(this.streetLine1)
            || IS.stringNotEmpty(this.streetLine2);
    }

    get showTollFreeNumber() {
        return IS.stringNotEmpty(this.tollFreeNumber);
    }

    get getTollFreeNumberLabel() {
        return IS.stringNotEmpty(this.tollFreeLabel)
            ? this.tollFreeLabel
            : LABELS.sidebarTollFree;
    }

    get getTollFreeNumberLink() {
        return this.showTollFreeNumber
            ? `tel:${this.tollFreeNumber}`
            : null;
    }

    get showPhoneNumber() {
        return IS.stringNotEmpty(this.phoneNumber);
    }

    get getPhoneNumberLabel() {
        return IS.stringNotEmpty(this.phoneLabel)
            ? this.phoneLabel
            : LABELS.sidebarPhone;
    }

    get showFaxNumber() {
        return IS.stringNotEmpty(this.faxNumber);
    }

    get getFaxNumberLabel() {
        return IS.stringNotEmpty(this.faxLabel)
            ? this.faxLabel
            : LABELS.sidebarFax;
    }

    get showEmail() {
        return IS.stringNotEmpty(this.email);
    }

    get getEmailLink() {
        return this.email
            ? `mailto:${this.email}`
            : null;
    }

    // LIFECYCLE
    async connectedCallback() {
        this.getCaseFieldsPicklistOptions()
    }

    renderedCallback() {
        if (this.isFirstRender) {
            this.addCustomCssStyles();
            this.isFirstRender = false;
        }
    }

    // METHODS
    addCustomCssStyles() {
        let styleText = `
            ${this.isGuest
                ? `
                    .b2b-layout__content {
                        width: 100% !important;
                        max-width: 100% !important;
                    }
                `
                : ''
            }

            .${this.wrapper} .slds-input,
            .${this.wrapper} .slds-textarea {
                font-size: 0.875rem;
            }

            .${this.wrapper} .slds-textarea {
                display: block;
            }

            .${this.wrapper}[data-guest="true"] .slds-textarea {
                min-height: 5.0625rem;
            }

            .${this.wrapper}[data-guest="false"] .slds-textarea {
                min-height: 4rem;
            }

            @media (max-width: 1349.98px) {
                .${this.wrapper}[data-guest="false"] .slds-textarea {
                    height: 0;
                    min-height: 4rem;
                }
            }

            @media (max-width: 1023.98px) {
                .${this.wrapper}[data-guest="false"] .slds-textarea {
                    min-height: 5.0625rem;
                }
            }

            /* B2B COUNTRY STATE PICKLISTS */

            .${this.wrapper} c-b2b-country-state-picklists .country-state-picklist-container {
                flex-direction: column;
            }

            .${this.wrapper} c-b2b-country-state-picklists .country-state-picklist-container > div {
                width: 100%;
                margin-top: 0 !important;
                padding: 0 !important;
            }

            /* FORM ELEMENTS */

            .${this.wrapper} lightning-input,
            .${this.wrapper} lightning-combobox,
            .${this.wrapper} lightning-textarea,
            .${this.wrapper} .slds-form-element {
                --dxp-g-destructive: #ea001e;
                --sds-c-input-color-border: #DDDBDA;
            }

            .${this.wrapper} lightning-input .slds-form-element__label,
            .${this.wrapper} lightning-combobox .slds-form-element__label,
            .${this.wrapper} lightning-textarea .slds-form-element__label,
            .${this.wrapper} .slds-form-element label.field-label {
                font-size: 12px;
                color: #231F20;
            }

            .${this.wrapper} lightning-input .slds-required,
            .${this.wrapper} lightning-combobox .slds-required,
            .${this.wrapper} lightning-textarea .slds-required,
            .${this.wrapper} .slds-form-element label.field-label > span {
                color: #ea001e;
            }

            .${this.wrapper} lightning-input input.slds-input,
            .${this.wrapper} lightning-combobox button.slds-combobox__input,
            .${this.wrapper} lightning-textarea textarea.slds-textarea,
            .${this.wrapper} .slds-form-element select.slds-select {
                font-size: 14px;
                color: #231F20;
                border-radius: 0 !important;
            }

            .${this.wrapper} .slds-form-element select.slds-select {
                padding: 0 32px 0 12px;
            }

            .${this.wrapper} lightning-input input.slds-input:focus,
            .${this.wrapper} lightning-input input.slds-input:active,
            .${this.wrapper} lightning-combobox button.slds-combobox__input:focus,
            .${this.wrapper} lightning-combobox button.slds-combobox__input:active,
            .${this.wrapper} lightning-textarea textarea.slds-textarea:focus,
            .${this.wrapper} lightning-textarea textarea.slds-textarea:active,
            .${this.wrapper} .slds-form-element select.slds-select:focus,
            .${this.wrapper} .slds-form-element select.slds-select:active {
                border-color: rgb(218, 41, 28);
                box-shadow: 0 0 3px rgb(182, 34, 23);
            }

            .${this.wrapper} lightning-input input.slds-input::placeholder,
            .${this.wrapper} lightning-combobox button.slds-input_faux:not(.slds-combobox__input-value),
            .${this.wrapper} lightning-textarea textarea.slds-textarea::placeholder,
            .${this.wrapper} .slds-form-element select.slds-select::placeholder {
                font-size: 14px;
                color: rgba(35, 31, 32, 0.5);
            }
        `;

        styleText =  UTILS.prepareString(styleText);
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

    clearForm() {
        // TODO: Update and remove ...
        let elements = [
            ...this.template.querySelectorAll('lightning-input'),
            ...this.template.querySelectorAll('lightning-textarea'),
            ...this.template.querySelectorAll('lightning-combobox'),
        ];

        elements.forEach((element) => {
            element.value = element.name === 'email' ? 'a@a.aa' : '1';
            element.setCustomValidity('');
            element.reportValidity();
            this.form[element.name] = null;
            element.value = null;
        });

        this.existingOrderOn = false;
        this.form.state = null;
        let countryStateElement = this.template.querySelector('c-b2b-country-state-picklists');
        countryStateElement.initCountryAndState(this.countriesAndStatesData);
        countryStateElement.resetError();
    }

    validateForm() {
        let isFormValid = true;

        // TODO: Update and remove ...
        let elements = [
            ...this.template.querySelectorAll('lightning-input'),
            ...this.template.querySelectorAll('lightning-textarea'),
            ...this.template.querySelectorAll('lightning-combobox')
        ];

        elements.forEach((element) => {
            let value = IS.stringNotEmpty(element.value)
                ? element.value.trim()
                : null;
            this.form[element.name] = value;
            element.value = value;

            if (!IS.stringNotEmpty(this.form[element.name])) {
                isFormValid = false;
            }

            if (element.name === 'phoneNumber' && !IS.phoneNumber(this.form[element.name])) {
                isFormValid = false;
            }

            if (element.name === 'email' && !IS.email(this.form[element.name])) {
                isFormValid = false;
            }

            if (!element.reportValidity()) {
                isFormValid = false;
            }
        });
        isFormValid = !this.validateCountryState() ? false : isFormValid;

        return isFormValid;
    }
    
    validateCountryState() {
        let countryStateElement = this.template.querySelector('c-b2b-country-state-picklists');
        let isValid = true;
        if (countryStateElement) {
            isValid = countryStateElement.validateInputFields();
        }

        return isValid;
    }

    getCaseFieldsPicklistOptions() { //To assign picklist values from .cls to contactMethodOptions in js
        _getCaseFieldsPicklistOptions()
        .then((response) => {
            this.contactMethodOptions = response.storeContactMethodOptions;
            this.contactMethodOptions.forEach((method, index) => {
                method.id = `status-${index}`;
                method.cssClasses = (index === 0)
                    ? 'slds-button sort-button sort-button-click'
                    : 'slds-button sort-button'
            });

            this.contactTimeOptions = response.storeContactTimeOptions;
            this.contactTimeOptions.forEach((time, index) => {
                time.id = `status-${index}`;
                time.cssClasses = (index === 0)
                    ? 'slds-button sort-button sort-button-click'
                    : 'slds-button sort-button'
            });

            this.contactReasonOptions = response.storeContactReasonOptions;
            if(this.isGuest){this.contactReasonOptions.splice(2, 1)};
            this.contactReasonOptions.forEach((reason, index) => {
                reason.id = `status-${index}`;
                reason.cssClasses = (index === 0)
                    ? 'slds-button sort-button sort-button-click'
                    : 'slds-button sort-button'
            });

            let countriesAndStatesRawData = response.countriesAndStates;
            for (let key in countriesAndStatesRawData){
                if(key !== 'United States') {countriesAndStatesRawData[key] = []};
            }

            this.countriesAndStatesData = { 
                countriesAndStates: countriesAndStatesRawData
            };
            
            var codeCountryObject = response.countriesCode;
            this.countriesCodeData = this.invertKeyValue(codeCountryObject);
            this.countriesStatesCodeData = response.countriesStatesCode;

            this.existingOrderOptions = response.storeLastFiveOrders;
            this.existingOrderOptions.forEach((order, index) => {
                order.id = `status-${index}`;
                order.cssClasses = (index === 0)
                    ? 'slds-button sort-button sort-button-click'
                    : 'slds-button sort-button'
            });
        })
        .catch((error) => {
            console.error(error);
            UTILS.showToast( 'error', B2B_Contact_Us_Error_Message);
        })
    }

    invertKeyValue(object) {
        var invertedObject = {};
        Object.keys(object).forEach(
            key => {
                invertedObject[object[key]] = key;
            }
        )
        return invertedObject
    }

    getStateCode(countryCode, stateName) {
        var statesObject = this.countriesStatesCodeData[countryCode];
        let invObj = {};
        let stateCode;
        for (let stateObject of statesObject){
            invObj = this.invertKeyValue(stateObject);
            var includesName = invObj.hasOwnProperty(stateName);
            if(includesName){
                stateCode = Object.values(invObj)[0];
            }
        }
        return stateCode
    }

    // HANDLERS
    handleChangeFormElement(event) {
        let name = event.target.name;
        let value = event.target.value;

        if (IS.stringNotEmpty(name)) {
            if (name !== 'description') {
                value = UTILS.prepareString(value);
            }

            if (name === 'phoneNumber') {
                value = IS.stringNotEmpty(value)
                    ? value.replace(/[^0-9\+\-\.\(\) ]/, '')
                    : value;
                if (IS.stringEmpty(value) || IS.null(value)) {
                    event.target.setCustomValidity(LABELS.requiredField);
                } else if (!IS.phoneNumber(value)) {
                    event.target.setCustomValidity(LABELS.invalidFormat);
                } else {
                    event.target.setCustomValidity('');
                }
            }

            if (name === 'email') {
                if (IS.stringEmpty(value) || IS.null(value)) {
                    event.target.setCustomValidity(LABELS.requiredField);
                } else if (!IS.email(value)) {
                    event.target.setCustomValidity(LABELS.invalidFormat);
                } else {
                    event.target.setCustomValidity('');
                }
            }

            if (name === 'contactReason' && value != 'Existing order') {this.form.existingOrder = null};
            
            this.form[name] = value;
            event.target.value = value;
            event.target.reportValidity();
            this.existingOrderOn = (this.form.contactReason === 'Existing order' || (this.form.existingOrder != null)) ? true : false;
        }
    }

    handleCountryChanged(event) {
        this.form.country = this.countriesCodeData[event.detail];
    }

    handleStateChanged(event) {
        var stateName = event.detail;
        this.form.state = this.getStateCode(this.form.country, stateName);
    }

    handleClickCancelButton() {
        this.clearForm();
    }

    async handleClickSubmitButton() {
        if (!this.validateForm()) {
            return;
        }

        this.isUpdateLoading = true;
        let response = await UTILS.doRequest(createCase, {
            request: this.form
        });

        if (UTILS.responseSuccess(response)) {
            UTILS.showToast('success', UTILS.prepareLabel(LABELS.successMessage, [LABELS.contactCompanyName]));
            this.clearForm();
        } else {
            UTILS.showToast('error', UTILS.prepareLabel(LABELS.errorMessage, [LABELS.contactEmail]));
        }

        this.isUpdateLoading = false;
    }

}