import { LightningElement, api } from 'lwc';
import { UTILS } from 'c/b2bUtils';

const CUSTOM_CSS_STYLES = `
    .b2b-qty-container svg {
        fill: #000 !important;
    }
`;

export default class B2BQuantitySelector extends LightningElement {
    LIMIT_MIN = 1;
    LIMIT_MAX = 100000000;

    @api label;
    @api value = this.LIMIT_MIN;

    isFirstRender = true;
    renderedCallback() {
        if (this.isFirstRender) {
            let styleText = UTILS.prepareString(CUSTOM_CSS_STYLES);
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
            this.isFirstRender = false;
        }
    }

    get isMinusButtonDisabled() {
        return this.value <= 1;
    }

    get isAddButtonDisabled() {
        return this.value >= 100000000;
    }

    @api
    getValue() {
        return this.value;
    }

    changeValue(event) {
        this.value = event.target.value ? parseInt(event.target.value) : this.LIMIT_MIN;

        if (this.value > this.LIMIT_MAX) {
            this.value = this.LIMIT_MAX;
        } else if (this.value < this.LIMIT_MIN) {
            this.value = this.LIMIT_MIN;
        }
    }

    increaseValue() {
        if (this.value) {
            this.value += 1
        } else {
            this.value = 1;
        }
    }

    decreaseValue() {
        if (this.value) {
            this.value -= 1
        }
    }

}