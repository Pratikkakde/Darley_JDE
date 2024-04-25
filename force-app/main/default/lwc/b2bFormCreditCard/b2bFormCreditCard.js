import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';
import { Card } from './libs/card';
import { Payment } from './libs/payment';

// LABELS
import B2B_Form_Credit_Card_Card_Name from '@salesforce/label/c.B2B_Form_Credit_Card_Card_Name';
import B2B_Form_Credit_Card_Card_Holder_Name from '@salesforce/label/c.B2B_Form_Credit_Card_Card_Holder_Name';
import B2B_Form_Credit_Card_Card_Holder_Name_Not_Valid from '@salesforce/label/c.B2B_Form_Credit_Card_Card_Holder_Name_Not_Valid';
import B2B_Form_Credit_Card_Card_Number from '@salesforce/label/c.B2B_Form_Credit_Card_Card_Number';
import B2B_Form_Credit_Card_Card_Number_Placeholder from '@salesforce/label/c.B2B_Form_Credit_Card_Card_Number_Placeholder';
import B2B_Form_Credit_Card_Card_Number_Not_Valid from '@salesforce/label/c.B2B_Form_Credit_Card_Card_Number_Not_Valid';
import B2B_Form_Credit_Card_Card_Expiration from '@salesforce/label/c.B2B_Form_Credit_Card_Card_Expiration';
import B2B_Form_Credit_Card_Card_Expiration_Placeholder from '@salesforce/label/c.B2B_Form_Credit_Card_Card_Expiration_Placeholder';
import B2B_Form_Credit_Card_Card_Expiration_Not_Valid from '@salesforce/label/c.B2B_Form_Credit_Card_Card_Expiration_Not_Valid';
import B2B_Form_Credit_Card_Card_Cvv from '@salesforce/label/c.B2B_Form_Credit_Card_Card_Cvv';
import B2B_Form_Credit_Card_Card_Cvv_Placeholder from '@salesforce/label/c.B2B_Form_Credit_Card_Card_Cvv_Placeholder';
import B2B_Form_Credit_Card_Card_Cvv_Not_Valid from '@salesforce/label/c.B2B_Form_Credit_Card_Card_Cvv_Not_Valid';
import B2B_Form_Credit_Card_Card_Default from '@salesforce/label/c.B2B_Form_Credit_Card_Card_Default';

const CHANGE_FORM_EVENT = 'changeform';

export default class B2bFormCreditCard extends LightningElement {
    @track labels = {
        cardName: B2B_Form_Credit_Card_Card_Name,
        cardNamePlaceholder: B2B_Form_Credit_Card_Card_Name,
        cardHolderName: B2B_Form_Credit_Card_Card_Holder_Name,
        cardHolderNamePlaceholder: B2B_Form_Credit_Card_Card_Holder_Name,
        cardHolderNameNotValid: B2B_Form_Credit_Card_Card_Holder_Name_Not_Valid,
        cardNumber: B2B_Form_Credit_Card_Card_Number,
        cardNumberPlaceholder: B2B_Form_Credit_Card_Card_Number_Placeholder,
        cardNumberNotValid: B2B_Form_Credit_Card_Card_Number_Not_Valid,
        cardExpiration: B2B_Form_Credit_Card_Card_Expiration,
        cardExpirationPlaceholder: B2B_Form_Credit_Card_Card_Expiration_Placeholder,
        cardExpirationNotValid: B2B_Form_Credit_Card_Card_Expiration_Not_Valid,
        cardCvv: B2B_Form_Credit_Card_Card_Cvv,
        cardCvvPlaceholder: B2B_Form_Credit_Card_Card_Cvv_Placeholder,
        cardCvvNotValid: B2B_Form_Credit_Card_Card_Cvv_Not_Valid,
        cardDefault: B2B_Form_Credit_Card_Card_Default,
    };

    @api showCardName = false;
    @api isCardNameRequired = false;
    @api showCardHolderName = false;
    @api isCardHolderNameRequired = false;
    @api showCardIcon = false;
    @api showCardImage = false;
    @api showCardDefault = false;
    @api disabled = false;

    @track card = null;
    @track cardName = null;
    // CARD HOLDER NAME
    @track cardHolderName = null;
    @track cardHolderNameBlur = false;
    @track cardHolderNameValid = false;
    // CARD NUMBER
    @track cardNumber = null;
    @track cardNumberBlur = false;
    @track cardNumberValid = false;
    // CARD EXPIRATION
    @track cardExpiration = null;
    @track cardExpirationBlur = false;
    @track cardExpirationValid = false;
    // CARD CVV
    @track cardCvv = null;
    @track cardCvvBlur = false;
    @track cardCvvValid = false;
    // CARD DEFAULT
    @track cardDefault = false;

    // GETTERS
    get isCardHolderNameError() {
        return this.isCardHolderNameRequired
            && this.cardHolderNameBlur
            && !this.cardHolderNameValid;
    }

    get getCardHolderNameClass() {
        return `b2b-credit-card-form__card-holder-name slds-form-element${
            this.isCardHolderNameError ? ' slds-has-error' : ''
        }`;
    }

    get isCardNumberError() {
        return this.cardNumberBlur && !this.cardNumberValid;
    }

    get getCardNumberClass() {
        return `b2b-credit-card-form__card-number slds-form-element${
            this.isCardNumberError ? ' slds-has-error' : ''
        }${
            this.showCardIcon ? ' b2b-credit-card-form__card-number-has-icon' : ''
        }`;
    }

    get getCardIconType() {
        return this.card
            && IS.stringNotEmpty(this.card.cardType)
            && IS.stringNotEmpty(this.cardNumber)
                ? this.card.cardType
                : null;
    }

    get isCardExpirationError() {
        return this.cardExpirationBlur && !this.cardExpirationValid;
    }

    get getCardExpirationClass() {
        return `b2b-credit-card-form__card-expiration slds-form-element${
            this.isCardExpirationError ? ' slds-has-error' : ''
        }`;
    }

    get isCardCvvError() {
        return this.cardCvvBlur && !this.cardCvvValid;
    }

    get getCardCvvClass() {
        return `b2b-credit-card-form__card-cvv slds-form-element${
            this.isCardCvvError ? ' slds-has-error' : ''
        }`;
    }

    // LIFECYCLES
    connectedCallback() {
        // Сopy public attributes to private ones
        window.setTimeout(() => {
            this.card = new Card({
                // Reference to this object so will work with web components
                context: this,
                // A selector or DOM element for the form where users will
                // be entering their information
                form: this.template.querySelector('.b2b-credit-card-form__form'),
                // A selector or DOM element for the container
                // where you want the card to appear (required)
                container: '.b2b-credit-card-form__image',
                width: 300, // default 350px
                formatting: true,
                // Strings for translation
                messages: {
                    validDate: "valid\ndate", // default 'valid\nthru'
                    monthYear: "mm/yy" //  default 'month/year'
                },
                // Default placeholders for rendered fields - optional
                placeholders: {
                    name: this.showCardHolderName ? 'CARDHOLDER NAME' : ' ',
                    number: '•••• •••• •••• ••••',
                    expiry: 'MM/YY',
                    cvc: '•••'
                },
                masks: {
                    cardNumber: 'X' // mask card number
                },
                // If true, will log helpful messages for setting up Card
                debug: true // default false
            });
        }, 50);
    }

    // METHODS
    executeChangeEvent() {
        let detail = this.collectData();
        detail.validity = this.checkValidity();
        UTILS.dispatchEvent(this, CHANGE_FORM_EVENT, detail);
    }

    // HANDLERS
    handleChangeCardName(event) {
        this.cardName = event.target.value;
        this.executeChangeEvent();
    }

    handleInputCardHolderName(event) {
        this.cardHolderName = event.target.value;
        this.cardHolderNameValid = IS.stringNotEmpty(this.cardHolderName);
        if (event.type === 'blur') {
            this.cardHolderNameBlur = true;
        }
        this.executeChangeEvent();
    }

    handleInputCardNumber(event) {
        this.cardNumber = event.target.value;
        this.cardNumberValid = Payment.fns.validateCardNumber(this.cardNumber);
        if (event.type === 'blur') {
            this.cardNumberBlur = true;
        }
        this.executeChangeEvent();
    }

    handleInputCardExpiration(event) {
        this.cardExpiration = event.target.value;
        this.cardExpirationValid = Payment.fns.validateCardExpiry(this.cardExpiration);
        if (event.type === 'blur') {
            this.cardExpirationBlur = true;
        }
        this.executeChangeEvent();
    }

    handleInputCardCvv(event) {
        this.cardCvv = event.target.value;
        this.cardCvvValid = Payment.fns.validateCardCVC(this.cardCvv);
        if (event.type === 'blur') {
            this.cardCvvBlur = true;
        }
        this.executeChangeEvent();
    }

    handleChangeCardDefault(event) {
        this.cardDefault = IS.true(event.target.checked) ? true : false;
    }

    // API's
    @api
    checkValidity() {
        let cardNameElement = this.template.querySelector('lightning-input[data-name="cardName"]');
        return (this.showCardName && this.isCardNameRequired
                ? cardNameElement && cardNameElement.checkValidity() && IS.stringNotEmpty(this.cardName)
                : true
            )
            && (this.showCardHolderName && this.isCardHolderNameRequired
                ? IS.stringNotEmpty(this.cardHolderName)
                : true
            )
            && Payment.fns.validateCardNumber(this.cardNumber)
            && Payment.fns.validateCardExpiry(this.cardExpiration)
            && Payment.fns.validateCardCVC(this.cardCvv);
    }

    @api
    reportValidity() {
        if (this.showCardName) {
            let cardNameElement = this.template.querySelector('lightning-input[data-name="cardName"]');
            if (cardNameElement) {
                cardNameElement.reportValidity();
            }
        }

        if (this.showCardHolderName) {
            this.handleInputCardHolderName({
                type: 'blur',
                target: { value: this.cardHolderName }
            });
        }

        this.handleInputCardNumber({
            type: 'blur',
            target: { value: this.cardNumber }
        });
        
        this.handleInputCardExpiration({
            type: 'blur',
            target: { value: this.cardExpiration }
        });

        this.handleInputCardCvv({
            type: 'blur',
            target: { value: this.cardCvv }
        });

        return this.checkValidity();
    }

    @api
    collectData() {
        let expirationDate = IS.stringNotEmpty(this.cardExpiration)
            ? Payment.fns.cardExpiryVal(this.cardExpiration)
            : null;

        if (
            IS.objectNotEmpty(expirationDate)
            && IS.numeric(expirationDate.year)
            && `${expirationDate.year}`.length === 2
        ) {
            let prefix = new Date().getFullYear();
            prefix = prefix.toString().slice(0, 2);
            expirationDate.year = +`${prefix}${expirationDate.year}`;
        }

        let result = {
            type: this.card && IS.stringNotEmpty(this.card.cardType)
                ? this.card.cardType
                : null,
            number: IS.stringNotEmpty(this.cardNumber)
                ? UTILS.onlyNumbers(this.cardNumber)
                : null,
            month: IS.objectNotEmpty(expirationDate) && IS.numeric(expirationDate.month)
                ? `${expirationDate.month}`
                : null,
            year: IS.objectNotEmpty(expirationDate) && IS.numeric(expirationDate.year)
                ? `${expirationDate.year}`
                : null,
            cvv: IS.stringNotEmpty(this.cardCvv)
                ? this.cardCvv
                : null,
        };

        if (result.type === 'unknown') {
            result.type = null;
        }

        if (this.showCardName) {
            result.name = IS.stringNotEmpty(this.cardName) ? this.cardName : null;
        }

        if (this.showCardHolderName) {
            result.holderName = IS.stringNotEmpty(this.cardHolderName) ? this.cardHolderName : null;
        }

        if (this.showCardDefault) {
            result.isDefault = IS.true(this.cardDefault) ? true : false;
        }

        return result;
    }

    @api
    resetForm() {
        this.cardName = null;
        // CARD HOLDER NAME
        this.cardHolderName = null;
        this.cardHolderNameBlur = false;
        this.cardHolderNameValid = false;
        // CARD NUMBER
        this.cardNumber = null;
        this.cardNumberBlur = false;
        this.cardNumberValid = false;
        // CARD EXPIRATION
        this.cardExpiration = null;
        this.cardExpirationBlur = false;
        this.cardExpirationValid = false;
        // CARD CVV
        this.cardCvv = null;
        this.cardCvvBlur = false;
        this.cardCvvValid = false;
        // CARD DEFAULT
        this.cardDefault = false;
    }

}