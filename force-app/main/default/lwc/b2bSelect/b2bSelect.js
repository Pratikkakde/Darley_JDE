import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

// LABELS
import B2B_Select_Default_Option from '@salesforce/label/c.B2B_Select_Default_Option';
import B2B_Select_Required_Field from '@salesforce/label/c.B2B_Select_Required_Field';

const LABELS = {
    defaultOption: B2B_Select_Default_Option,
    requiredField: B2B_Select_Required_Field,
};

const COMPONENT_NAME = 'b2b-select';
const CHANGE = 'change';
const FOCUS = 'focus';
const BLUR = 'blur';

export default class B2bSelect extends LightningElement {
    @api name = null;
    @api autocomplete = null;
    @api label = null;

    @track _value = null;
    @api
    set value(v) {
        if (IS.stringNotEmpty(v)) {
            this._value = v;
        } else {
            this._value = '';
            this.wasFirstBlur = false;
        }
        this.updateDomElement();
        this.updateValidity();
    }
    get value() {
        return IS.stringNotEmpty(this._value) ? this._value : '';
    };

    @api options = [];
    @api required = false;

    @track _disabled = false;
    @api
    set disabled(v) {
        if (IS.true(v)) {
            this._disabled = true;
            this.showError = false;
        } else {
            this._disabled = false;
        }
    };
    get disabled() {
        return this._disabled;
    }

    @api placeholder = null;
    @api defaultOption = null;
    @api errorMessage = null;

    @track labels = LABELS;
    @track isFirstRender = true;
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);
    @track componentId = UTILS.random.componentId();
    @track wrapperId = UTILS.wrapperId(COMPONENT_NAME, this.componentId);

    @track defaultValue = '';
    @track wasFirstBlur = false;
    @track showError = false;

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper} ${this.wrapperId} slds-form-element ${this.showError ? 'slds-has-error' : ''}`;
    }

    get detail() {
        return {
            value: this.value,
            dataset: JSON.parse(JSON.stringify(this.template.host.dataset))
        };
    }

    get getDefaultDisabled() {
        return this.required ? true : null;
    }

    get getDefaultOptionLabel() {
        return IS.stringNotEmpty(this.defaultOption)
            ? this.defaultOption
            : LABELS.defaultOption;
    }

    get getPlaceholder() {
        return IS.stringNotEmpty(this.placeholder)
            ? this.placeholder
            : LABELS.defaultOption;
    }

    get getErrorMessage() {
        return IS.stringNotEmpty(this.errorMessage)
            ? this.errorMessage
            : LABELS.requiredField;
    }

    // LIFECYCLES
    renderedCallback() {
        this.updateDomElement();
    }

    // METHODS
    updateValidity() {
        if (
            this.required &&
            this.wasFirstBlur &&
            !IS.stringNotEmpty(this.value) &&
            IS.arrayNotEmpty(this.options) &&
            this.options.length
        ) {
            this.showError = true;
        } else {
            this.showError = false;
        }
    }

    updateDomElement() {
        let element = this.template.querySelector('select.b2b-select__select');
        if (element) {
            element.value = this.value;
        }
    }

    // HANDLERS
    handleChange(event) {
        this.value = event.target.value;
        UTILS.dispatchEvent(this, CHANGE, this.detail);
        this.updateValidity();
    }

    handleFocus() {
        UTILS.dispatchEvent(this, FOCUS, this.detail);
    }

    handleBlur() {
        this.wasFirstBlur = true;
        UTILS.dispatchEvent(this, BLUR, this.detail);
        this.updateValidity();
    }

    // API's
    @api
    checkValidity() {
        return !this.showError;
    }

    @api
    reportValidity() {
        this.wasFirstBlur = true;
        this.updateValidity();
        return !this.showError;
    }

}