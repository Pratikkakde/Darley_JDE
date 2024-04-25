import { LightningElement,api,track,wire } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

// METHODS
import createContactPointAddress from '@salesforce/apex/B2BAddressBookController.createContactPointAddress';
import getAddressData from '@salesforce/apex/B2BAddressBookController.getAddressData';
import updateContactPointAddress from '@salesforce/apex/B2BAddressBookController.updateContactPointAddress';
import initAddressForm from '@salesforce/apex/B2BAddressBookController.initAddressForm';
import { NavigationMixin } from 'lightning/navigation';

// LABELS
import B2B_Address_Form_Label from '@salesforce/label/c.B2B_Address_Form_Label';
import B2B_Added_Form_Toast from '@salesforce/label/c.B2B_Added_Form_Toast';
import B2B_Updated_Added_Form_Toast from '@salesforce/label/c.B2B_Updated_Added_Form_Toast';
import B2B_Edit_Form_Label from '@salesforce/label/c.B2B_Edit_Form_Label';
import B2B_Address_Type_Select from '@salesforce/label/c.B2B_Address_Type_Select';
import B2B_Address_Type_Title from '@salesforce/label/c.B2B_Addres_Type_Title';
import B2B_Addres_Book_Required_Field from '@salesforce/label/c.B2B_Addres_Book_Required_Field';
import B2B_Name from '@salesforce/label/c.B2B_Name';
import B2B_Make_Default_Address_Label from '@salesforce/label/c.B2B_Make_Default_Address_Label';
import B2B_Edit_Address_Form_Label from '@salesforce/label/c.B2B_Edit_Address_Form_Label';
import B2B_Save_Button from '@salesforce/label/c.B2B_Save_Button';
import B2B_Cancel_Button from '@salesforce/label/c.B2B_Cancel';
import B2B_Error_Message from '@salesforce/label/c.B2B_Something_went_wrong_Please_try_again_or_contact_us';

const LABELS ={
    select: B2B_Address_Type_Select,
    addressType: B2B_Address_Type_Title,
    requiredField: B2B_Addres_Book_Required_Field,
    Name: B2B_Name,
    makeDefaultAddressLabel: B2B_Make_Default_Address_Label,
    newAddressLabel: B2B_Address_Form_Label,
    editAddressLabel: B2B_Edit_Form_Label,
    saveButton: B2B_Save_Button,
    cancel: B2B_Cancel_Button,
    editLabel: B2B_Edit_Address_Form_Label,
    errorMessage: B2B_Error_Message,
    toastAdded: B2B_Added_Form_Toast,
    toastUpdated: B2B_Updated_Added_Form_Toast,
}

const COMPONENT_NAME = 'b2b-address-book';

const SHIPPING = 'Shipping';
const BILLING = 'Billing';
const DEFAULT = 'DEFAULT';
const ADDRESS_ROUTE = 'addresses';
const MAX_LENGTH = {
    Name: 255,
};
export default class B2bAddressBook extends NavigationMixin(LightningElement) {
    @api newAddressLabel = null;
    @api editAddressLabel = null;
    @api recordId = null;

    @track wrapper = UTILS.wrapper(COMPONENT_NAME);
    @track labels = LABELS;
    @track maxLength = MAX_LENGTH;
    @track saveAsDefaultAddress = [];
    @track addressBook;
    @track countriesAndStatesData;
    @track countryPicklistValues = [];
    @track stateDependedValues = [];
    @track isUpdateLoading = false;
    @track editForm = [];
    
    @track form = {
        Name: null,
        addressType: SHIPPING,
        streetAddress: null,
        city: null,
        postalCode: null,
        isDefault: false,
        countryCode: null,
        provinceCode: null
    }

    addressType = SHIPPING;
    selectedCountry = '';
    selectedState = '';
    editMode;

    // GETTERS
    get addressTypeOptions(){
        return [
            { label: SHIPPING, value: SHIPPING},
            { label: BILLING, value: BILLING},
        ];
    }

    get saveAsDefaultAddressOptions() {
        return [{ value: DEFAULT, label: LABELS.makeDefaultAddressLabel}];
    }

    get getFormTitle() {
        return IS.stringNotEmpty(this.newAddressLabel)
            ? this.newAddressLabel
            : LABELS.newAddressLabel;
    }

    get getEditFormTitle() {
        return IS.stringNotEmpty(this.editAddressLabel)
            ? this.editAddressLabel
            : LABELS.editAddressLabel;
    }


    // // LIFECYCLES
    connectedCallback() {
        this.isUpdateLoading = true;
        this.getInitialData();
    }

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
                if(this.recordId) {
                    this.editMode = true;
                    this.getEditFormData();
                }else {
                    this.editMode = false;
                    this.isUpdateLoading = false;
                }
            })
            .catch(error => {
                console.error(error);
                this.showErrorMessage(error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    async getEditFormData() {
        let response = await UTILS.doRequest(getAddressData, {
            recordId: this.recordId
        });
        if (UTILS.responseSuccess(response)) {
            let data = UTILS.responseData(response);
            this.form.name = data.Name;
            this.form.addressType = data.AddressType;
            this.form.streetAddress = data.Street;
            this.form.city = data.City;
            this.form.postalCode = data.PostalCode;
            this.form.provinceCode = data.StateCode;
            this.form.countryCode = data.CountryCode;
            this.form.isDefault = data.IsDefault;
            if(this.form.isDefault) {
                this.saveAsDefaultAddress =  DEFAULT;
            }
        } else {
            console.error(response);
        }
        this.isUpdateLoading = false;
        this.selectedCountry =  this.form.countryCode;
        this.selectedState = this.form.provinceCode;
        this.countryChangeProcessing();
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

    navigateTo(url) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: { url }
        });
    }

    validateForm() {
        let isFormValid = true;
        let Name = this.template.querySelector('lightning-input[data-name="Name"]');
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

    // HANDLERS
    handleChangeAddress(event) {
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

    handleChangeAddressType(event) {
        this.addressType = IS.stringNotEmpty(event.detail.value)
        ? event.detail.value
        : '';
        this.form.addressType = event.detail.value;
    }

    handleNameChange(event) {
        this.form.name = event.detail.value;
    }

    handleChangeSaveAsDefaultAddress(event) {
        if(event.detail.value[0]) {
            this.form.isDefault = true;
        } else{
            this.form.isDefault = false;
        }
    }

    // BUTTONS
    handleClickCancelButton() {
        this.navigateTo(
            UTILS.link(`/${ADDRESS_ROUTE}`)
        );
    }

    async handleClickSubmitButton() {
        if (!this.validateForm()) {
            return;
        }

        this.isUpdateLoading = true;
       if(this.editMode) {
            let response = await UTILS.doRequest(updateContactPointAddress, {
                request: this.form,
                recordId: this.recordId
            });

            if (UTILS.responseSuccess(response)) {
                UTILS.showToast( 'success', LABELS.toastUpdated);
            } else {
                UTILS.showToast('error', LABELS.errorMessage);
            }
            this.isUpdateLoading = false;
            this.navigateTo(
                UTILS.link(`/${ADDRESS_ROUTE}`)
            );

       }else{
            let response = await UTILS.doRequest(createContactPointAddress, {
                request: this.form
            });

            if (UTILS.responseSuccess(response)) {
                UTILS.showToast( 'success', LABELS.toastAdded);
            } else {
                UTILS.showToast('error', LABELS.errorMessage);
            }
            this.isUpdateLoading = false;
            this.navigateTo(
                UTILS.link(`/${ADDRESS_ROUTE}`)
            );
       }
    }
}