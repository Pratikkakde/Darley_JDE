import {LightningElement, api, track} from 'lwc';

import _initQuote from "@salesforce/apex/B2BQuoteDetailController.initQuote";
import _convertToOrder from "@salesforce/apex/B2BQuoteDetailController.convertToOrder";
import _getQuotePdf from '@salesforce/apex/B2BQuoteDetailController.getQuotePdf';
import _updateMessage from '@salesforce/apex/B2BQuoteDetailController.updateMessage';


import communityBasePath from "@salesforce/community/basePath";
import { NavigationMixin } from 'lightning/navigation';
import { UTILS, IS } from 'c/b2bUtils';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import LOADING from '@salesforce/label/c.B2B_Loading';
import ERROR_MESSAGE from '@salesforce/label/c.B2B_Something_went_wrong_Please_try_again_or_contact_us';
import SKU from '@salesforce/label/c.B2B_SKU';
import PRODUCT_NAME from '@salesforce/label/c.B2B_Product_Name';
import QUANTITY from '@salesforce/label/c.B2B_Quantity';
import UNIT_PRICE from '@salesforce/label/c.B2B_Unit_Price';
import TOTAL from '@salesforce/label/c.B2B_Total';
import QUOTE_DETAILS from '@salesforce/label/c.B2B_Quote_Details';
import PLACE_ORDER from '@salesforce/label/c.B2B_Place_order';
import QUOTE_NUMBER from '@salesforce/label/c.B2B_Quote_Number';
import REQUESTED_DATE from '@salesforce/label/c.B2B_Requested_Date';
import EXPIRATION_DATE from '@salesforce/label/c.B2B_Expiration_Date';
import STATUS from '@salesforce/label/c.B2B_Quote_Status';
import QUOTE_TOTAL from '@salesforce/label/c.B2B_Quote_Total';
import CANCEL from '@salesforce/label/c.B2B_Cancel';
import PRINT from '@salesforce/label/c.B2B_Print';
import GENERATE_PDF_ERROR from '@salesforce/label/c.B2B_Failed_to_generate_pdf_file';
import SHIPPING_INFO from '@salesforce/label/c.B2B_Shipping_Information';
import SHIPPING_ADDRESS from '@salesforce/label/c.B2B_Shipping_Address';
import BILLING_INFO from '@salesforce/label/c.B2B_Billing_Information';
import BILLING_ADDRESS from '@salesforce/label/c.B2B_Billing_Address';
import CHANGE_REQUEST from '@salesforce/label/c.B2B_Change_Request';
import SUBMIT_BUTTON from '@salesforce/label/c.B2B_Submit_Button';
import SAVE_BUTTON from '@salesforce/label/c.B2B_Save_Button';
import TOAST_SUCCESS from '@salesforce/label/c.B2B_Toast_Success';
import QUOTE_SUBTOTAL from '@salesforce/label/c.B2B_Quote_Subtotal';
import ESTIMATED_TAX from '@salesforce/label/c.B2B_Estimated_tax';
import ESTIMATED_SHIPPING from '@salesforce/label/c.B2B_Estimated_Shipping';
import QUOTE_ITEMS from '@salesforce/label/c.B2BQuoteItems'
import QUOTE_PROMOTIONS from '@salesforce/label/c.B2B_Quote_Promotions'

const TABLE_COLUMNS = [
    { field: 'productName', label: PRODUCT_NAME, sort: false, type: 'link' },
    { field: 'SKU', label: SKU, sort: false, type: 'string' },
    { field: 'quantity', label: QUANTITY, sort: false, type: 'number' },
    { field: 'unitPrice', label: UNIT_PRICE, sort: false, type: 'currency' },
    { field: 'total', label: TOTAL, sort: false, type: 'currency' }
];

const TABLE_MOBILE_HEADER = [
    { field: 'productName', type: 'link' },
    { field: 'total', type: 'currency', additionalLabel: TOTAL + ':' }
];

const TABLE_MOBILE_BODY = [
    { field: 'SKU', label: SKU, type: 'string' },
    { field: 'quantity', label: QUANTITY, type: 'number' },
    { field: 'unitPrice', label: UNIT_PRICE, type: 'currency' }
];

const CURRENCY_CODE = 'USD';
const COMPONENT_NAME = 'b2b-quotes-container';

export default class B2BQuoteDetail extends NavigationMixin(LightningElement) {

    @api recordId = null;
    @api effectiveAccountId = null;
    @api changeRequestPlaceHolder = null;

    @track quote = {};
    @track items = [];
    @track isLoading = false;
    @track isFirstRender = true;
    @track customCssContainer = UTILS.customCssContainer;
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);
    @track description = null;
    showPromotions;

    buttonDisabled = true;

    LABELS = {
        LOADING,
        QUOTE_DETAILS,
        PLACE_ORDER,
        QUOTE_NUMBER,
        REQUESTED_DATE,
        EXPIRATION_DATE,
        STATUS,
        QUOTE_TOTAL,
        CANCEL,
        PRINT,
        GENERATE_PDF_ERROR,
        SHIPPING_INFO,
        SHIPPING_ADDRESS,
        BILLING_INFO,
        BILLING_ADDRESS,
        CHANGE_REQUEST,
        SUBMIT_BUTTON,
        SAVE_BUTTON,
        TOAST_SUCCESS,
        QUOTE_SUBTOTAL,
        ESTIMATED_TAX,
        ESTIMATED_SHIPPING, 
        QUOTE_ITEMS,
        QUOTE_PROMOTIONS
    }

    get hasPlaceOrderButton() {
        return this.quote ? this.quote.status === 'Approved' : false;
    }

    get quoteNumberHeader() {
        return QUOTE_NUMBER + ': ' + (this.quote && this.quote.quoteNumber ? this.quote.quoteNumber : '');
    }
    
    get buttonLabel() {
        if(this.buttonDisabled){
            return this.LABELS.SUBMIT_BUTTON;
        }else{
            return this.LABELS.SAVE_BUTTON;
        }
    }

    async connectedCallback() {
        this.effectiveAccountId = await UTILS.getEffectiveAccountId();
        this.generateTableHeaders();
        this.initQuote();
    }

    renderedCallback() {
        if (this.isFirstRender) {
            this.isFirstRender = false;
            this.addCustomCssStyles();
        }
    }

    // METHODS
    submitForm(event){
        let textarea = this.template.querySelector('lightning-textarea');
        this.isLoading = true;
        _updateMessage({
            quoteId: this.recordId,
            description : textarea.value
        })
        .then((response) => {
            console.log('Response', JSON.stringify(response));
            if (response.isSuccess) {
                UTILS.showToast( 'success', this.LABELS.TOAST_SUCCESS);
                // this.navigateToUrl(UTILS.link(`/quote-management`))
            }
        })
        .catch((error) => {
            console.error(error);
            UTILS.showToast('error', ERROR_MESSAGE);
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    addCustomCssStyles() {
        let styleText = `
            .${this.wrapper} c-b2b-table .slds-table {
                table-layout: auto !important;
            }

            .${this.wrapper} c-b2b-table .list-table td {
                padding: 6px 12px !important;
            }

            .${this.wrapper} c-b2b-table thead tr th {
                color: #231F20;
            }

            .${this.wrapper} c-b2b-table thead tr th:not(:first-child) {
                min-width: 6rem !important;
                text-align: center !important;
            }

            .${this.wrapper} c-b2b-table tbody tr td:not(:first-child) {
                text-align: center !important;
            }

            .${this.wrapper} c-b2b-table thead tr th:first-child .list__action {
                justify-content: flex-start;
                padding-left: 12px;
            }

            .${this.wrapper} c-b2b-table tbody tr td:first-child {
                text-align: left !important;
            }

            .${this.wrapper} c-b2b-table tbody tr td:first-child .link-cell {
                font-weight: 400 !important;
                text-decoration: none !important;
                transition: color 0.1s;
            }

            .${this.wrapper} c-b2b-table tbody tr td:first-child .link-cell:hover {
                text-decoration: underline !important;
                color: var(--dxp-g-brand-1);
            }

            .${this.wrapper} .b2b-button {
                line-height: 38px;
            }

            .${this.wrapper} .b2b-changeRequest__container lightning-textarea .slds-form-element__label {
                font-size: 12px;
                color: #231F20;
            }

            .${this.wrapper} .b2b-changeRequest__container lightning-textarea .slds-textarea {
                min-height: 70px;
            }

            .${this.wrapper} lightning-button.b2b-quote__button,
            .${this.wrapper} lightning-button.b2b-quote__button .slds-button {
                width: 100%;
                max-width: 100px;
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

    handleButtonTextAreaChange(event){
        let value = event.target.value
        if(IS.stringNotEmpty(value) && IS.stringNotEmpty(value.trim())){
            this.buttonDisabled = false;
        } else{
            this.buttonDisabled = true;
        }
    }

    handlerConvertIntoOrder() {
        this.convertToOrder();
    }

    async initQuote() {
        this.isLoading = true;

        let response = await UTILS.doRequest(_initQuote, {
            quoteId: this.recordId,
            accountId: this.effectiveAccountId
        });

        if (UTILS.responseSuccess(response)) {
            let data = UTILS.responseData(response);

            if (IS.objectNotEmpty(data)) {
                this.quote = data.quote;
                this.items = data.quote ? data.quote.items : [];
                this.parseItems();
                this.showPromotions = this.quote.promotions != 0 ? true : false;
            }
        } else {
            console.error(response);
            this.showToast('error', ERROR_MESSAGE);
        }

        this.isLoading = false;
    }

    async convertToOrder() {
        this.isLoading = true;

        let response = await UTILS.doRequest(_convertToOrder, {
            quoteDto: this.quote,
            effectiveAccountId: this.effectiveAccountId
        });

        if (UTILS.responseSuccess(response)) {
            let data = UTILS.responseData(response);

            if (IS.objectNotEmpty(data)) {
                this.navigateToUrl(UTILS.link(`/checkout?recordId=${data.activeCartId}`));
            }
        } else {
            console.error(response);
            this.showToast('error', ERROR_MESSAGE);
        }

        this.isLoading = false;
    }

    navigateToUrl(url) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: { url }
        });
    }

    // B2B Table logic
    @track tableItemHeaders = [];
    @track list = [];
    @track listMobile = [];

    generateTableHeaders() {
        let result = [];

        TABLE_COLUMNS.forEach((item, index) => {
            let headerItem = {
                key: index,
                label: item.label || null,
                class: item.class || null,
                field: item.field || null,
                isSort: item.sort
            };

            headerItem.isOrder = false;
            headerItem.iconName = 'utility:arrowdown';
            headerItem.orderClass = 'list__action';

            if (!item.sort) {
                headerItem.orderClass += ' no-sort-column';
            }

            result.push(headerItem);
        });

        this.tableItemHeaders = result;
    }

    parseProductNameLink(name){
        return name.replace(/[^a-z0-9\s]/gi, '-');
    }

    parseItems() {
        let result = [];
        let mobileResult = [];

        if (this.items && this.items.length) {
            result = this.getDesktopTableItems();
            mobileResult = this.getMobileTableItems();
        }

        this.list = result;
        this.listMobile = mobileResult;
    }

    getDesktopTableItems() {
        let result = [];

        this.items.forEach((item, itemIndex) => {
            if (item.id) {
                let row = {
                    key: itemIndex,
                    data: []
                };

                let itemName = '';

                TABLE_COLUMNS.forEach((column, columnIndex) => {
                    let formattedItem = {
                        key: `${itemIndex}-${columnIndex}`
                    };

                    itemName = this.parseProductNameLink(item.productName);

                    switch (column.type) {
                        case 'string':
                            formattedItem.isString = true;
                            formattedItem.label = item[column.field];
                            break;
                        case 'number':
                            formattedItem.isNumber = true;
                            formattedItem.label = item[column.field];
                            break;
                        case 'link':
                            formattedItem.isLink = true;
                            formattedItem.label = item[column.field];
                            formattedItem.url = `${communityBasePath}/product/${itemName}/${item.productId}`;
                            break;
                        case 'currency':
                            formattedItem.isCurrency = true;
                            formattedItem.label = item[column.field];
                            formattedItem.currencyCode = item.currencyIsoCode || CURRENCY_CODE;
                            break;
                    }

                    row.data.push(formattedItem);
                });

                result.push(row);
            }
        });

        return result;
    }

    getMobileTableItems() {
        let mobileResult = [];

        this.items.forEach((item, itemIndex) => {
            if (item.id) {
                let mobileItem = {
                    id: item.id,
                    showDetails: false,
                    itemHeader: [],
                    itemBody: []
                };

                TABLE_MOBILE_HEADER.forEach((mobileHeaderItem, mobileHeaderItemIndex) => {
                    let headerItem = {
                        key: `${itemIndex}-${mobileHeaderItemIndex}`
                    };

                    switch (mobileHeaderItem.type) {
                        case 'link':
                            headerItem.isLink = true;
                            headerItem.label = item[mobileHeaderItem.field];
                            headerItem.url = `${communityBasePath}/product/${item.productId}`;
                            break;
                        case 'currency':
                            headerItem.isCurrency = true;
                            headerItem.label = mobileHeaderItem.label;
                            headerItem.value = item[mobileHeaderItem.field];
                            headerItem.hasAdditionalLabel = !!mobileHeaderItem.additionalLabel;
                            headerItem.additionalLabel = mobileHeaderItem.additionalLabel;
                            headerItem.currencyCode = CURRENCY_CODE;
                            break;
                    }

                    mobileItem.itemHeader.push(headerItem);
                });

                TABLE_MOBILE_BODY.forEach((mobileBodyItem, mobileBodyItemIndex) => {
                    let bodyItem = {
                        key: `${itemIndex}-${mobileBodyItemIndex}`
                    };

                    switch (mobileBodyItem.type) {
                        case 'string':
                            bodyItem.isString = true;
                            bodyItem.label = mobileBodyItem.label;
                            bodyItem.value = item[mobileBodyItem.field];
                            break;
                        case 'number':
                            bodyItem.isNumber = true;
                            bodyItem.label = mobileBodyItem.label;
                            bodyItem.value = item[mobileBodyItem.field];
                            break;
                        case 'currency':
                            bodyItem.isCurrency = true;
                            bodyItem.label = mobileBodyItem.label;
                            bodyItem.value = item[mobileBodyItem.field];
                            bodyItem.currencyCode = item.currencyIsoCode || CURRENCY_CODE;
                            break;
                    }

                    mobileItem.itemBody.push(bodyItem);
                });

                mobileResult.push(mobileItem);
            }
        });

        return mobileResult;
    }

    openModal(id) {
        this.template.querySelector("[data-id=" + id + "]").openModal();
    }

    closeModal(event, modalId) {
        this.template.querySelector("[data-id=" + (event == null ? modalId : event.target.value)  + "]").closeModal();
    }

    handleCancel() {
        this.closeModal(null, 'confirmation-modal');
    }

    handleClickItemTitle(event) {
        let id = event.detail;

        if (!id) return;

        this.listMobile.forEach(item => {
            if (item.id === id) {
                item.showDetails = !item.showDetails;
            }
        });
    }

    async handleClickPrintButton() {
        if (
            this.isLoading ||
            !IS.stringNotEmpty(this.recordId)
        ) {
            return;
        }

        this.isLoading = true;
        let response = await UTILS.doRequest(_getQuotePdf, {
            recordId: this.recordId
        });
        let data = UTILS.responseData(response);

        if (
            UTILS.responseSuccess(response) &&
            IS.stringNotEmpty(data)
        ) {
            let quoteDownloadLink = document.createElement('a');
            quoteDownloadLink.href = 'data:application/pdf;base64,' + data;
            quoteDownloadLink.download = `Quote - ${this.quote.quoteNumber}`;
            quoteDownloadLink.click();
        } else {
            console.error(response);
            UTILS.showToast('error', this.LABELS.GENERATE_PDF_ERROR);
        }
        this.isLoading = false;
    }

    showToast(type, message) {
        const event = new ShowToastEvent({
            variant: type,
            message: message
        });
        this.dispatchEvent(event);
    }

}