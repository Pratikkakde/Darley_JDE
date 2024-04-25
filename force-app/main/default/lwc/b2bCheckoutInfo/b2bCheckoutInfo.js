import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

//LABELS
import shippingInfo from '@salesforce/label/c.B2B_Shipping_Method';
import message from '@salesforce/label/c.B2B_Please_specify_your_preferred_Shipping_Method_or_other_shipping_details';
import specialInstructions from '@salesforce/label/c.B2B_Special_Instructions';
import upsGround from '@salesforce/label/c.B2B_UPS_Ground';

const COMPONENT_NAME = 'b2b-checkout-info';
const BLUR_SPECIAL_INSTRUCTIONS = 'blurspecialinstructions';

const LABELS = {
    shippingInfo: shippingInfo,
    message: message,
    specialInstructions: specialInstructions,
    upsGround: upsGround
};

const MAX_LENGTH = {
    specialInstructions: 2000,
};

export default class B2bCheckoutInfo extends LightningElement {
    @api isUpdateLoading = false;
    @api specialInstructions = null;

    @track isFirstRender = true;
    @track customCssContainer = UTILS.customCssContainer;
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);
    @track labels = LABELS;
    @track maxLength = MAX_LENGTH;

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper}`;
    }

    get getTitleNumber() {
        return '2';
    }

    get getTitleLabel() {
        return LABELS.shippingInfo;
    }

    get getMethod() {
        return this.labels.upsGround;
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
            .${this.wrapper} lightning-textarea .slds-form-element__label {
                padding: 0;
                font-size: 12px;
                color: var(--b2b-colorText);
            }
            
            .${this.wrapper} lightning-textarea {
                margin-bottom: 0;
            }

            .${this.wrapper} lightning-textarea .slds-textarea {
                min-height: 81px;
                font-size: 14px;
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

    // HANDLERS
    handleBlurSpecialInstructions(event) {
        if (this.isUpdateLoading) {
            return;
        }

        let oldSpecialInstructions = this.specialInstructions;
        this.specialInstructions = IS.stringNotEmpty(event.target.value)
            ? event.target.value.trim()
            : null;

        let element = this.template.querySelector('[data-name="special_instructions"]');
        if (element) {
            element.value = this.specialInstructions;
        }

        if (this.specialInstructions !== oldSpecialInstructions) {
            UTILS.dispatchEvent(this, BLUR_SPECIAL_INSTRUCTIONS, this.specialInstructions);
        }
    }

}