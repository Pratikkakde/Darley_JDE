import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

// LABELS
import B2B_Quantity_Required_Field from '@salesforce/label/c.B2B_Quantity_Required_Field';
import B2B_Quantity_Decrement from '@salesforce/label/c.B2B_Quantity_Decrement';
import B2B_Quantity_Click_To_Decrement from '@salesforce/label/c.B2B_Quantity_Click_To_Decrement';
import B2B_Quantity_Increment from '@salesforce/label/c.B2B_Quantity_Increment';
import B2B_Quantity_Click_To_Increment from '@salesforce/label/c.B2B_Quantity_Click_To_Increment';
import B2B_Quantity_Item_Label from '@salesforce/label/c.B2B_Quantity_Item_Label';
import B2B_Quantity_Not_Available from '@salesforce/label/c.B2B_Quantity_Not_Available';

const LABELS = {
    requiredField: B2B_Quantity_Required_Field,
    decrement: B2B_Quantity_Decrement,
    clickToDecrement: B2B_Quantity_Click_To_Decrement,
    increment: B2B_Quantity_Increment,
    clickToIncrement: B2B_Quantity_Click_To_Increment,
    itemLabel: B2B_Quantity_Item_Label,
    notAvailable: B2B_Quantity_Not_Available,
};

const COMPONENT_NAME = 'b2b-quantity';
const CHANGE_EVENT = 'change';
const BLUR_EVENT = 'blur';
const INCREMENT = 1;
const MIN_QUANTITY = UTILS.quantityMin;
const MAX_QUANTITY = UTILS.quantityMax;

export default class B2bQuantity extends LightningElement {
    @api label = null;
    @api disabled = false;
    @api readonly = false;
    @api editable = false;
    @api required = false;
    @api increment = null;
    @api minQuantity = null;
    @api maxQuantity = null;
    @api value = null;
    @api available = null;
    @api isError = null;
    @api errorMessage = null;
    @api naLabel = null;
    @api ruletext = null;

    @track isFirstRender = true;
    @track labels = LABELS;
    @track componentId = UTILS.random.componentId();
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);
    @track wrapperId = UTILS.wrapperId(COMPONENT_NAME, this.componentId);
    @track customCssContainer = UTILS.customCssContainer;

    @track showError = false;

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper} ${this.wrapperId}`;
    }

    get formElementClass() {
        let result = 'slds-form-element';
        if (this.showError) {
            result += ' slds-has-error'
        }
        if (IS.stringNotEmpty(this.ruletext)) {
            result += ' slds-has-ruletext'
        }
        return result;
    }

    get showElementLabel() {
        return IS.stringNotEmpty(this.label)
            || IS.stringNotEmpty(this.ruletext);
    }

    get getErrorMessage() {
        return IS.stringNotEmpty(this.errorMessage)
            ? this.errorMessage
            : LABELS.requiredField
    }

    get getStep() {
        let minQuantity = IS.integer(this.minQuantity)
            ? this.minQuantity
            : MIN_QUANTITY;

        let maxQuantity = IS.integer(this.maxQuantity)
            ? this.maxQuantity
            : MAX_QUANTITY;

        if (
            IS.integer(this.increment) &&
            minQuantity < maxQuantity &&
            this.increment >= minQuantity &&
            this.increment <= maxQuantity
        ) {
            return this.increment;
        }
        return INCREMENT;
    }

    get getQuantityLabel() {
        if (
            IS.stringNotEmpty(this.value) ||
            IS.integer(this.value)
        ) {
            return this.value;
        } else if (IS.stringNotEmpty(this.naLabel)) {
            return this.naLabel;
        }
        return null;
    }

    get getMinQuantity() {
        let minQuantity = MIN_QUANTITY;
        if (IS.integer(this.minQuantity)) {
            if (this.minQuantity <= this.getStep) {
                minQuantity = this.getStep;
            } else {
                if (this.minQuantity % this.getStep === 0) {
                    minQuantity = this.minQuantity;
                } else {
                    minQuantity = this.minQuantity - (this.minQuantity % this.getStep);
                }
            }
        }
        return minQuantity;
    }

    get getMaxQuantity() {
        let maxQuantity = MAX_QUANTITY;
        if (IS.integer(this.maxQuantity)) {
            if (this.maxQuantity <= this.getStep) {
                maxQuantity = this.getStep;
            } else {
                if (this.maxQuantity % this.getStep === 0) {
                    maxQuantity = this.maxQuantity;
                } else {
                    maxQuantity = this.maxQuantity - (this.maxQuantity % this.getStep);
                }
            }
        }
        return maxQuantity;
    }

    get getAvailableQuantity() {
        let availableQuantity = this.getMaxQuantity;
        if (IS.integer(this.available)) {
            if (this.available % this.getStep === 0) {
                availableQuantity = this.available;
            } else {
                availableQuantity = this.available - (this.available % this.getStep);
            }
        }
        return availableQuantity;
    }

    get decrementButtonDisabled() {
        if (
            this.disabled ||
            this.readonly ||
            !IS.integer(this.value) ||
            this.value <= this.getMinQuantity
        ) {
            return true;
        }
        return false;
    }

    get decrementButtonTitle() {
        if (!this.decrementButtonDisabled) {
            return UTILS.prepareLabel(LABELS.clickToDecrement, [LABELS.itemLabel]);
        }
        return null;
    }

    get incrementButtonDisabled() {
        if (
            this.disabled ||
            this.readonly ||
            !IS.integer(this.value) ||
            this.value >= this.getMaxQuantity
        ) {
            return true;
        }
        return false;
    }

    get incrementButtonTitle() {
        if (!this.incrementButtonDisabled) {
            return UTILS.prepareLabel(LABELS.clickToIncrement, [LABELS.itemLabel]);
        }
        return null;
    }

    // LIFECYCLES
    renderedCallback() {
        if (this.isFirstRender) {
            this.isFirstRender = false;
            this.addCustomCssStyles();
        }
    }

    // METHODS
    addCustomCssStyles() {
        let styleText = `
            /*
            Add this style to b2bStyle.css (Static Resources)

            .b2b-quantity__wrapper .slds-form-element__label lightning-helptext,
            .b2b-quantity__wrapper .slds-form-element__label lightning-helptext .slds-form-element__icon,
            .b2b-quantity__wrapper .slds-form-element__label lightning-helptext .slds-form-element__icon .slds-button {
                display: block;
                position: absolute;
                width: 100%;
                height: 100%;
                top: 0;
                right: 0;
                bottom: 0;
                left: 0;
            }

            .b2b-quantity__wrapper .slds-form-element__label lightning-helptext lightning-primitive-icon {
                display: none;
            }

            lightning-primitive-bubble .slds-popover__body {
                white-space: pre-line;
            }
            */
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

    // HANDLERS
    handleInput(event) {
        let tmpValue = UTILS.onlyNumbers(`${event.target.value}`);
        this.value = IS.stringNotEmpty(tmpValue) ? +tmpValue : null;
    }

    handleBlur(event) {
        this.handleChange({
            target: {
                value: event.target.value
            }
        });
        UTILS.dispatchEvent(this, BLUR_EVENT, {
            value: this.value,
            dataset: JSON.parse(JSON.stringify(this.template.host.dataset))
        });
    }

    handleChange(event) {
        this.handleInput({
            target: {
                value: event.target.value
            }
        });

        if (!IS.integer(this.value)) {
            this.value = this.getMinQuantity;
        } else {
            if (this.value % this.getStep !== 0) {
                this.value = this.value - (this.value % this.getStep);
            }
            if (this.value <= this.getMinQuantity) {
                this.value = this.getMinQuantity;
            } else if (this.value >= this.getMaxQuantity) {
                this.value = this.getMaxQuantity;
            }
        }
        UTILS.dispatchEvent(this, CHANGE_EVENT, {
            value: this.value,
            dataset: JSON.parse(JSON.stringify(this.template.host.dataset))
        });
    }

    handleClickDecrement() {
        this.handleChange({
            target: {
                value: this.value - this.getStep
            }
        });
    }

    handleClickIncrement() {
        this.handleChange({
            target: {
                value: this.value + this.getStep
            }
        });
    }

}