import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

// LABELS
import B2B_Home_Quick_Order_Title from '@salesforce/label/c.B2B_Home_Quick_Order_Title';
import B2B_Home_Quick_Order_Manual_Input from '@salesforce/label/c.B2B_Home_Quick_Order_Manual_Input';
import B2B_Home_Quick_Order_Upload_File from '@salesforce/label/c.B2B_Home_Quick_Order_Upload_File';

const LABELS = {
    title: B2B_Home_Quick_Order_Title,
    manualInput: B2B_Home_Quick_Order_Manual_Input,
    uploadFile: B2B_Home_Quick_Order_Upload_File,
};

const COMPONENT_NAME = 'b2b-home-quick-order';

export default class B2bHomeQuickOrder extends LightningElement {
    @api numberOfLines = null;
    @api maxNumberOfLines = null;
    @api templateDocumentId = null;

    @track isFirstRender = true;
    @track customCssContainer = UTILS.customCssContainer;
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);
    @track labels = LABELS;

    @track tabOptions = [
        { value: 'manual_input', label: LABELS.manualInput, selected: true },
        { value: 'upload_file', label: LABELS.uploadFile, selected: false },
    ];

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper}`;
    }

    get showComponent() {
        return !UTILS.isGuest;
    }

    get showManualInput() {
        let result = false;
        if (IS.arrayNotEmpty(this.tabOptions)) {
            this.tabOptions.forEach((item) => {
                if (item.value === 'manual_input' && item.selected) {
                    result = true;
                }
            });
        } else {
            result = true;
        }
        return result;
    }

    get showUploadFile() {
        let result = false;
        if (IS.arrayNotEmpty(this.tabOptions)) {
            this.tabOptions.forEach((item) => {
                if (item.value === 'upload_file' && item.selected) {
                    result = true;
                }
            });
        } else {
            result = true;
        }
        return result;
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
            c-b2b-quick-order .b2b-quick-order__title {
                display: none;
            }

            c-b2b-quick-order .b2b-quick-order__item-product {
                padding-right: 8px !important
            }

            @media (max-width: 574.98px) {
                c-b2b-quick-order .b2b-quick-order__item-product {
                    padding-right: 0 !important
                }
            }

            c-b2b-quick-order-uploader .b2b-quick-order-uploader__wrapper {
                height: 100%;
            }
        `;

        UTILS.addCustomCssStyles(this.template, styleText);
    }

    // HANDLERS
    handleClickTab(event) {
        let value = event.target.dataset.value;
        if (IS.stringNotEmpty(value)) {
            this.tabOptions.forEach((item) => {
                item.selected = item.value === value;
            });
        }
    }

}