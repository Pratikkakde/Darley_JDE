import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

// METHODS
import initRegisterForm from '@salesforce/apex/B2BRegisterController.initRegisterForm';
import signUp from '@salesforce/apex/B2BRegisterController.signUp';

// LABELS
import B2B_Register_Company_Email from '@salesforce/label/c.B2B_Register_Company_Email';
import B2B_Register_Loading from '@salesforce/label/c.B2B_Register_Loading';
import B2B_Register_Subtitle from '@salesforce/label/c.B2B_Register_Subtitle';
import B2B_Register_Register_New_User_Under_Existing_Account from '@salesforce/label/c.B2B_Register_Register_New_User_Under_Existing_Account';
import B2B_Register_Required_Field from '@salesforce/label/c.B2B_Register_Required_Field';
import B2B_Register_First_Name from '@salesforce/label/c.B2B_Register_First_Name';
import B2B_Register_Last_Name from '@salesforce/label/c.B2B_Register_Last_Name';
import B2B_Register_Email from '@salesforce/label/c.B2B_Register_Email';
import B2B_Register_Email_Not_Valid from '@salesforce/label/c.B2B_Register_Email_Not_Valid';
import B2B_Register_Registration_Type from '@salesforce/label/c.B2B_Register_Registration_Type';
import B2B_Register_Account_Name from '@salesforce/label/c.B2B_Register_Account_Name';
import B2B_Register_Account_Name_Complement from '@salesforce/label/c.B2B_Register_Account_Name_Complement';
import B2B_Register_Enter_Your_Company_Name from '@salesforce/label/c.B2B_Register_Enter_Your_Company_Name';
import B2B_Register_Enter_Your_Company_Name_Or_Full_Name from '@salesforce/label/c.B2B_Register_Enter_Your_Company_Name_Or_Full_Name';
import B2B_Register_Account_Number from '@salesforce/label/c.B2B_Register_Account_Number';
import B2B_Register_Phone_Number from '@salesforce/label/c.B2B_Register_Phone_Number';
import B2B_Register_Address_Title from '@salesforce/label/c.B2B_Register_Address_Title';
import B2B_Register_Street from '@salesforce/label/c.B2B_Register_Street';
import B2B_Register_City from '@salesforce/label/c.B2B_Register_City';
import B2B_Register_Postal_Code from '@salesforce/label/c.B2B_Register_Postal_Code';
import B2B_Register_Sign_Up from '@salesforce/label/c.B2B_Register_Sign_Up';
import B2B_Register_Already_Have_Account from '@salesforce/label/c.B2B_Register_Already_Have_Account';
import B2B_Register_Thank_You_Title from '@salesforce/label/c.B2B_Register_Thank_You_Title';
import B2B_Register_Thank_You_Message from '@salesforce/label/c.B2B_Register_Thank_You_Message';
import B2B_Register_Success_Button_Label from '@salesforce/label/c.B2B_Register_Success_Button_Label';
import B2B_Register_Error_Message from '@salesforce/label/c.B2B_Register_Error_Message';
import B2B_Register_Contact_Us from '@salesforce/label/c.B2B_Register_Contact_Us';
import B2B_Register_Select from '@salesforce/label/c.B2B_Register_Select';

const LABELS = {
    companyEmail: B2B_Register_Company_Email,
    loading: B2B_Register_Loading,
    subtitle: B2B_Register_Subtitle,
    registerNewUserUnderExistingAccount: B2B_Register_Register_New_User_Under_Existing_Account,
    requiredField: B2B_Register_Required_Field,
    firstName: B2B_Register_First_Name,
    lastName: B2B_Register_Last_Name,
    email: B2B_Register_Email,
    emailNotValid: B2B_Register_Email_Not_Valid,
    registrationType: B2B_Register_Registration_Type,
    accountName: B2B_Register_Account_Name,
    accountNameComplement: B2B_Register_Account_Name_Complement,
    enterYourCompanyName: B2B_Register_Enter_Your_Company_Name,
    enterYourCompanyNameOrFullName: B2B_Register_Enter_Your_Company_Name_Or_Full_Name,
    accountNumber: B2B_Register_Account_Number,
    phoneNumber: B2B_Register_Phone_Number,
    addressTitle: B2B_Register_Address_Title,
    street: B2B_Register_Street,
    city: B2B_Register_City,
    postalCode: B2B_Register_Postal_Code,
    signUp: B2B_Register_Sign_Up,
    alreadyHaveAccount: B2B_Register_Already_Have_Account,
    thankYouTitle: B2B_Register_Thank_You_Title,
    thankYouMessage: B2B_Register_Thank_You_Message,
    successButtonLabel: B2B_Register_Success_Button_Label,
    errorMessage: B2B_Register_Error_Message,
    contactUs: B2B_Register_Contact_Us,
    select: B2B_Register_Select
};

const HAS_NOT_ACCOUNT_FIELDS = ['firstName', 'lastName', 'email', 'companyName', 'companyPhoneNumber', 'streetAddress', 'city', 'postalCode'];
const HAS_ACCOUNT_FIELDS = ['firstName', 'lastName', 'email', 'companyName', 'companyNumber'];

const COMPONENT_NAME = 'b2b-register';

const MAX_LENGTH = {
    firstName: 40,
    lastName: 80,
    email: 80,
    accountName: 255,
    accountNumber: 40,
    phoneNumber: 40,
    street: 255,
    city: 40,
    postalCode: 20,
};

const REGISTRATION_TYPE_OPTION_BUSINESS = 'Business';
const REGISTRATION_TYPE_OPTION_INDIVIDUAL = 'Individual';
const REGISTRATION_TYPE_OPTION_GOVERNMENT = 'Government';

export default class B2BRegister extends LightningElement {
    @api thankYouBackgroundImage = null;

    @track isLoading = true;
    @track isUpdateLoading = false;
    @track isFirstRender = true;
    @track labels = LABELS;
    @track maxLength = MAX_LENGTH;
    @track customCssContainer = UTILS.customCssContainer;
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);

    @track registerNewUserUnderExistingAccount = false;
    @track register;
    @track errorMessage;
    @track countriesAndStatesData;
    hasCountryErrorMessage;
    isRegistrationProcess = false;
    registrationType = '';

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper}`;
    }

    get showSpinner() {
        return this.isLoading ||
            this.isUpdateLoading;
    }

    get getAccountNameHelptext() {
        return this.registerNewUserUnderExistingAccount
            ? LABELS.enterYourCompanyName
            : LABELS.enterYourCompanyNameOrFullName;
    }

    get getLoginUrl() {
        return UTILS.link('/login');
    }

    get getHomeUrl() {
        return UTILS.link('/');
    }

    get getContactUsUrl(){
        return UTILS.link('/contact-us');
    }

    get registrationTypeOptions(){
        return [
            { label: REGISTRATION_TYPE_OPTION_BUSINESS, value: REGISTRATION_TYPE_OPTION_BUSINESS },
            { label: REGISTRATION_TYPE_OPTION_INDIVIDUAL, value: REGISTRATION_TYPE_OPTION_INDIVIDUAL},
            { label: REGISTRATION_TYPE_OPTION_GOVERNMENT, value: REGISTRATION_TYPE_OPTION_GOVERNMENT}
        ];
    }

    get registrationTypeBusinessOrFederalGovernment(){
        return  (this.registrationType == REGISTRATION_TYPE_OPTION_BUSINESS || this.registrationType == REGISTRATION_TYPE_OPTION_GOVERNMENT);
    }

    // LIFECYCLES
    connectedCallback() {
        this.getInitialData();
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
            .b2b-button-container button {
                width: 100%;
                text-transform: uppercase;
            }
            
            .b2b-register-container .slds-combobox .slds-listbox.slds-listbox_vertical.slds-dropdown.slds-dropdown_fluid.slds-dropdown_left,
            .b2b-register-container .country-state-picklist-container .slds-select_container  {
                max-height: 11.5rem !important;
            }
            
            @media only screen and (max-width: 767.98px) {                
                .b2b-button-container button {
                    width: 100%;
                }

                .b2b-theme-login__wrapper .b2b-theme-login__body {
                    padding: 0 !important;
                }

                .b2b-theme-login__wrapper .b2b-theme-login__body .b2b-theme-login__container {
                    padding: 2rem 1.5rem !important;
                    border-radius: 0 !important;
                }
            }
            
            @media only screen and (max-width: 574.98px) {      
                .b2b-theme-login__wrapper .b2b-theme-login__body .b2b-theme-login__container {
                    padding: 1.5rem 1rem !important;
                }
            }

            .b2b-theme-login__wrapper {
                background-image: url(${UTILS.cmsLink(this.thankYouBackgroundImage)}) !important;
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

    getInitialData() {
        initRegisterForm()
            .then(result => {
                this.countriesAndStatesData = {
                    country: result.register.country,
                    state: result.register.state,
                    countriesAndStates: result.countriesAndStates
                };
                this.register = result.register;
            })
            .catch(error => {
                console.error(error);
                this.showErrorMessage(error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    executeSignUp() {
        this.isUpdateLoading = true;

        signUp({
            register: this.register
        })
            .then(() => {
                this.isRegistrationProcess = true;
            })
            .catch(error => {
                console.error(error);
                this.showErrorMessage(error);
            })
            .finally(() => {
                setTimeout(() => {
                    this.isUpdateLoading = false;
                }, 1000);
            });
    }

    setRegister() {
        let elements = [
            ...this.template.querySelectorAll('lightning-input'),
            ...this.template.querySelectorAll('lightning-textarea'),
            ...this.template.querySelectorAll('lightning-combobox')
        ];

        elements.forEach(element => {
            if (element.name) {
                this.register[element.name] = this.getValue(element);
            }
        });

        if(this.registrationType == REGISTRATION_TYPE_OPTION_INDIVIDUAL){
            this.register['companyName'] = `${this.register.firstName } ${this.register.lastName} ${this.labels.accountNameComplement}`;
        }
        this.register['registrationType'] = this.registrationType;
    }

    getValue(element) {
        let value = null;

        if (this.isElementAvailable(element)) {
            value = element && element.value ? element.value : null;
        }

        return value;
    }

    isElementAvailable(element) {
        return element && element.name
            && ((this.register.hasAccount && HAS_ACCOUNT_FIELDS.indexOf(element.name) !== -1)
                || (!this.register.hasAccount && HAS_NOT_ACCOUNT_FIELDS.indexOf(element.name) !== -1));
    }

    validateForm() {
        let isFormValid = true;
        let elements = [
            ...this.template.querySelectorAll('lightning-input'),
            ...this.template.querySelectorAll('lightning-textarea')
        ];

        elements.forEach(element => {
            if (this.isElementAvailable(element)) {
                if (element.type === 'email') {
                    isFormValid = !this.doValidEmail(element, LABELS.requiredField, LABELS.emailNotValid) ? false : isFormValid;
                } else {
                    isFormValid = !this.doValid(element) ? false : isFormValid;
                }
            }
        });
        isFormValid = !this.validateCountyState() || !this.validateRegistrationType() ? false : isFormValid;

        return isFormValid;
    }

    validateCountyState() {
        let countryStateElement = this.template.querySelector('c-b2b-country-state-picklists');
        let isValid = true;
        if (countryStateElement && !this.register.hasAccount) {
            isValid = countryStateElement.validateInputFields();
        }

        return isValid;
    }

    validateRegistrationType(){
        let registrationTypeElement = this.template.querySelector('c-b2b-select');
        let isValid = true;
        if (registrationTypeElement){
            isValid = registrationTypeElement.reportValidity();
        }
        return isValid;
    }

    validatePhoneKeyPress(event) {
        let regex = /[0-9]|-|\.|\(|\)/;

        let key = event.keyCode;
        key = String.fromCharCode(key);

        if( !regex.test(key) ) {
            event.returnValue = false;
            if(event.preventDefault) {
                event.preventDefault();
            }
        }
    }

    validatePhoneChange(event) {
        let element = event.target;
        element.value = element.value ? element.value.replace(/[^0-9-\(\)\.]/g, '').trim() : element.value;
    }

    showErrorMessage(error) {
        this.errorMessage = error && error.body && error.body.message
            ? error.body.message
            : UTILS.prepareLabel(LABELS.errorMessage, [LABELS.companyEmail]);
    }

    hideErrorMessage() {
        this.errorMessage = null;
    }

    doValid(element) {
        element.value = element.value ? element.value.replace(/\s{2,}/g, ' ').trim()  : element.value;
        let isValid = element.reportValidity();
    
        return isValid;
    }

    doValidEmail(element, requiredFieldLabel, notValidLabel) {
        let isEmailValid = true;
        let email = element.value ? element.value.trim() : '';
        const regExp = /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    
        if (email === '') {
            element.setCustomValidity(requiredFieldLabel);
            isEmailValid = false;
        } else {
            if (!regExp.test(String(email).toLowerCase())) {
                element.setCustomValidity(notValidLabel);
                isEmailValid = false;
            } else {
                element.setCustomValidity('');
            }
        }
        element.reportValidity();
    
        return isEmailValid;
    }

    // HANDLERS
    handleChangeRegisterNewUserUnderExistingAccount(event) {
        this.registerNewUserUnderExistingAccount = IS.true(event.detail.checked) ? true : false;
        this.register.hasAccount = event.detail.checked;
    }

    handleBlurEmail(event) {
        this.handleEmailChange(event);
    }

    handleEmailChange(event) {
        this.doValidEmail(event.target, LABELS.requiredField, LABELS.emailNotValid);
    }

    handleChangeRegistrationType(event) {
        this.registrationType = IS.stringNotEmpty(event.detail.value)
        ? event.detail.value
        : '';
    }

    handleKeypressPhoneNumber(event) {
        this.validatePhoneKeyPress(event);
    }

    handleChangePhoneNumber(event) {
        this.validatePhoneChange(event);
    }

    handleCountryChanged(event) {
        this.register.country = event.detail;
    }

    handleStateChanged(event) {
        this.register.state = event.detail;
    }

    handleClickSignUp() {
        this.hideErrorMessage();
        if (this.validateForm()) {
            this.setRegister();
            this.executeSignUp();
        }
    }

}