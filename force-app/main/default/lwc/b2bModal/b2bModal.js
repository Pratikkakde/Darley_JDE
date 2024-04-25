import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

const LABELS = {
    close: 'Close',
    closeLabel: 'Close',
    submitLabel: 'Submit',
};

const SMALL = 'small';
const MEDIUM = 'medium';
const LARGE = 'large';
const LEFT = 'left';
const RIGHT = 'right';
const FULL_WIDTH = 'full_width';
const CLOSE_EVENT = 'close';
const SUBMIT_EVENT = 'submit';

export default class B2bModal extends LightningElement {
    @api isLoading = false;
    @api submitDisabled = false;

    @track labels = LABELS;
    @track show = false;
    @track detail = null;
    // @track detail = {
    //     size: 'String',
    //     hideHeader: 'Boolean',
    //     title: 'String',
    //     hideFooter: 'Boolean',
    //     buttonsAlign: 'String', // 'left', 'right', 'full_width'
    //     closeLabel: 'String',
    //     submitLabel: 'String',
    // };

    // GETTERS
    get modalClass() {
        let result = 'b2b-modal__wrapper slds-modal slds-fade-in-open';
        if (
            IS.objectNotEmpty(this.detail)
            && IS.stringNotEmpty(this.detail.size)
        ) {
            if (this.detail.size === SMALL) {
                result += ' slds-modal_small';
            } else if (this.detail.size === MEDIUM) {
                result += ' slds-modal_medium';
            } else if (this.detail.size === LARGE) {
                result += ' slds-modal_large';
            }
        }
        return result;
    }

    get hideHeader() {
        return IS.objectNotEmpty(this.detail) && IS.true(this.detail.hideHeader);
    }

    get title() {
        return IS.objectNotEmpty(this.detail) && IS.stringNotEmpty(this.detail.title)
            ? this.detail.title
            : null;
    }

    get contentClass() {
        let result = 'slds-modal__content';
        if (this.hideHeader || !IS.stringNotEmpty(this.title)) {
            result += ' slds-modal__content_headless';
        }
        return result;
    }

    get hideFooter() {
        return IS.objectNotEmpty(this.detail) && IS.true(this.detail.hideFooter);
    }

    get footerClass() {
        let result = 'slds-modal__footer';
        if (
            IS.objectNotEmpty(this.detail)
            && IS.stringNotEmpty(this.detail.buttonsAlign)
        ) {
            if (this.detail.buttonsAlign === LEFT) {
                result += ' b2b-modal__footer_left';
            } else if (this.detail.buttonsAlign === RIGHT) {
                result += ' b2b-modal__footer_right';
            } else if (this.detail.buttonsAlign === FULL_WIDTH) {
                result += ' b2b-modal__footer_full-width';
            }
        }
        return result;
    }

    get closeLabel() {
        return IS.objectNotEmpty(this.detail) && IS.stringNotEmpty(this.detail.closeLabel)
            ? this.detail.closeLabel
            : LABELS.closeLabel;
    }

    get submitLabel() {
        return IS.objectNotEmpty(this.detail) && IS.stringNotEmpty(this.detail.submitLabel)
            ? this.detail.submitLabel
            : LABELS.submitLabel;
    }

    get isSubmitDisabled() {
        return this.isLoading
            || this.submitDisabled;
    }

    // METHODS
    showModal() {
        document.body.style.overflowY = 'hidden';
        this.show = true;
    }

    hideModal() {
        this.show = false;
        this.detail = null;
        document.body.style.overflowY = 'auto';
    }

    // HANDLERS
    handleClickHeaderClose() {
        let detail = Object.assign({}, JSON.parse(JSON.stringify(this.detail)));
        detail.isHeaderClose = true;
        UTILS.dispatchEvent(this, CLOSE_EVENT, detail);
        this.hideModal();
    }

    handleClickModalClose() {
        UTILS.dispatchEvent(this, CLOSE_EVENT, this.detail);
        this.hideModal();
    }

    handleClickModalSubmit() {
        if (this.isLoading) {
            return;
        }
        UTILS.dispatchEvent(this, SUBMIT_EVENT, this.detail);
    }

    // API's
    @api
    open(detail) {
        if (IS.objectNotEmpty(detail)) {
            this.detail = detail;
            this.showModal();
        }
    }

    @api
    hide() {
        this.hideModal();
    }

}