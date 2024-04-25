import { LightningElement, track } from 'lwc';
import { UTILS, IS, TOAST } from 'c/b2bUtils';

const LABELS = {
    closeButtonTitle: 'Close',
};

const PESTER = 'pester';
const STICKY = 'sticky';

export default class B2bToast extends LightningElement {
    @track labels = LABELS;
    @track list = [];

    // LIFECYCLES
    connectedCallback() {
        this._addNewToast = this.addNewToast.bind(this);
        window.addEventListener(TOAST.showToastEvent, this._addNewToast);
    }

    disconnectedCallback() {
        window.removeEventListener(TOAST.showToastEvent, this._addNewToast, false);
    }
    
    // METHODS
    addNewToast(event) {
        if (IS.objectNotEmpty(event.detail)) {
            let newItem = {
                id: UTILS.random.componentId(),
                mode: event.detail.mode,
                variant: event.detail.variant,
                class: `slds-notify slds-notify_toast slds-theme_${event.detail.variant}`,
                assistiveText: event.detail.variant,
                iconClass: `slds-icon_container slds-icon-utility-${event.detail.variant} slds-m-right_small slds-no-flex slds-align-top`,
                iconName: `utility:${event.detail.variant}`,
                richtext: event.detail.richtext,
                title: event.detail.title,
                message: event.detail.message,
                duration: event.detail.duration,
                timmer: null,
                showCloseButton: true
            };

            if (newItem.mode === PESTER) {
                newItem.showCloseButton = false;
            }

            if (newItem.mode !== STICKY) {
                newItem.timmer = setTimeout(() => {
                    this.closeToast(newItem.id);
                }, newItem.duration);
            }

            this.list.unshift(newItem);
        }
    }

    closeToast(id) {
        this.list = this.list.filter((item) => item.id !== id);
    }

    // HANDLERS
    handleClickButtonClose(event) {
        this.closeToast(event.target.dataset.id);
    }

}