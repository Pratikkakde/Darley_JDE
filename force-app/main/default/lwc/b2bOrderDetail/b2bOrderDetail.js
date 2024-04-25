// TODO: Update custom labels and put in separate file
// TODO: Update style when "Reorder" modal has correct AccoiuntId and OrderSummaryId

import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';
import { NavigationMixin } from 'lightning/navigation';
import communityBasePath from '@salesforce/community/basePath';

// METHODS
import _getOrderSummary from '@salesforce/apex/B2BOrderDetailsController.getOrderSummary';
import _getCalloutOrderStatus from '@salesforce/apex/calloutOrderStatus.getCalloutOrderStatus';

import loading from '@salesforce/label/c.B2B_Loading';
import order from '@salesforce/label/c.B2B_Order';
import number from '@salesforce/label/c.B2B_Number';
import orderDate from '@salesforce/label/c.B2B_Order_Date';
import orderStatus from '@salesforce/label/c.B2B_Order_Status';
import shippingInformation from '@salesforce/label/c.B2B_Shipping_Information';
import shippingAddress from '@salesforce/label/c.B2B_Shipping_Address';
import specialInstruction from '@salesforce/label/c.B2B_Special_Instructions';
import trackingNumber from '@salesforce/label/c.B2B_Tracking_Number';
import billingInformation from '@salesforce/label/c.B2B_Billing_Information';
import billingAddress from '@salesforce/label/c.B2B_Billing_Address';
import paymentMethod from '@salesforce/label/c.B2B_Payment_Methods';
import creditCard from '@salesforce/label/c.B2B_Credit_Card';
import invoice from '@salesforce/label/c.B2B_Invoice';
import bankTransfer from '@salesforce/label/c.B2B_Bank_Transfer';
import poNumber from '@salesforce/label/c.B2B_PO_Number';
import orderedProducts from '@salesforce/label/c.B2B_Ordered_Products';
import product from '@salesforce/label/c.B2B_Product';
import sku from '@salesforce/label/c.B2B_SKU';
import quantity from '@salesforce/label/c.B2B_Quantity';
import unitPrice from '@salesforce/label/c.B2B_Unit_Price';
import discountedTotal from '@salesforce/label/c.B2B_Total';
import subtotal from '@salesforce/label/c.B2B_Order_Subtotal';
import darleyDollars from '@salesforce/label/c.B2B_Order_Darley_Dollars';
import estimatedShipping from '@salesforce/label/c.B2B_Order_Estimated_Shipping';
import discount from '@salesforce/label/c.B2B_Discount';
import shipping from '@salesforce/label/c.B2B_Shipping';
import tax from '@salesforce/label/c.B2B_Estimated_tax';
import promotions from '@salesforce/label/c.B2B_Order_Promotions';
import orderTotal from '@salesforce/label/c.B2B_Order_Total';
import noRecordsToDisplay from '@salesforce/label/c.B2B_No_items_to_display';
import emptyTrackingNumbersMessage from '@salesforce/label/c.B2B_Tracking_number_will_be_added_soon';
import product_name from '@salesforce/label/c.B2B_Product_Name';
import B2B_Order_Details_Total_Message from '@salesforce/label/c.B2B_Order_Details_Total_Message';
import amazonPay from '@salesforce/label/c.B2B_Amazon_Pay';
import youDoNotHaveAccess from '@salesforce/label/c.B2B_You_Do_Not_Have_Access_To_This_Record';

const COMPONENT_NAME = 'b2b-order-detail';

const TABLE_COLUMNS = [
    { field: 'name', label: product_name, sort: false, type: 'link' },
    { field: 'sku', label: sku, sort: false, type: 'string' },
    { field: 'quantity', label: quantity, sort: false, type: 'number' },
    { field: 'price', label: unitPrice, sort: false, type: 'currency' },
    { field: 'total', label: discountedTotal, sort: false, type: 'currency' }
];

const TABLE_MOBILE_HEADER = [
    { field: 'name', type: 'link' },
    { field: 'total', type: 'currency', additionalLabel: `${discountedTotal}:` }
];

const TABLE_MOBILE_BODY = [
    { field: 'sku', label: sku, type: 'string' },
    { field: 'quantity', label: quantity, type: 'number' },
    { field: 'price', label: unitPrice, type: 'currency' }
];

export default class B2bOrderDetails extends NavigationMixin(LightningElement) {
  
    @track OrdStat = null;
    @api recordId = null;
    @track effectiveAccountId = null;

    @track ordStatLoading = true;
    @track isLoading = true;
    @track isUpdateLoading = false;
    @track hasAccess = true;
    @track isFirstRender = true;
    @track customCssContainer = UTILS.customCssContainer;
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);
    @track labels = {
        loading,
        order,
        number,
        orderDate,
        orderStatus,
        shippingInformation,
        shippingAddress,
        specialInstruction,
        trackingNumber,
        billingInformation,
        billingAddress,
        paymentMethod,
        creditCard,
        invoice,
        bankTransfer,
        poNumber,
        orderedProducts,
        product,
        quantity,
        unitPrice,
        discountedTotal,
        subtotal,
        darleyDollars,
        tax,
        estimatedShipping,
        promotions,
        discount,
        shipping,
        orderTotal,
        noRecordsToDisplay,
        emptyTrackingNumbersMessage,
        totalMessage: B2B_Order_Details_Total_Message,
        amazonPay,
        youDoNotHaveAccess
    }

    @track currencyIsoCode = null;

    @track cartId = null;

    @track order = {
        number: null,
        orderDate: null,
        status: null,
    };

    @track shipping = {
        accountName: null,
        address: null,
        carrier: null,
        method: null,
    };

    @track billing = {
        accountName: null,
        address: null,
    };

    @track payment = {
        creditCard: null,
        bankTransfer: null,
        poNumber: null,
    };

    @track tracking = [];

    @track tableOrdersHeaders = [];
    @track list = [];
    @track listMobile = [];

    @track totals = {
        subtotal: null,
        darleyDollars: null,
        tax: null,
        estimatedShipping:null,
        discount: null,
        shipping: null,
        promotions: null,
        total: null,
    };

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper}`;
    }

    get getCurrencyIsoCode() {
        return this.currencyIsoCode || UTILS.currencyIsoCode;
    }

    get hasDarleyDollars() {
        return this.totals.darleyDollars === 0 || this.totals.darleyDollars === null ? false : true;
    }

    get hasPromotions() {
        return this.totals.promotions === 0 || this.totals.promotions === null ? false : true;
    }

    get isCreditCard() {
        return this.payment && this.payment.paymentType === 'Credit Card';
    }

    get isPONumberAvailable() {
        return this.payment && this.payment.paymentType === 'Invoice' && this.payment.poNumber;
    }

    get isInvoice() {
        return this.payment && this.payment.paymentType === 'Invoice';
    }

    get isAmazonPay() {
        return this.payment && this.payment.paymentType === 'Amazon Pay';
    }

    get isTrackingNumbersEmpty() {
        return Array.isArray(this.tracking) && !this.tracking.length;
    }

    // LIFECYCLES
    async connectedCallback() {
        console.log("in connectedCallback");
        this.generateTableHeaders(TABLE_COLUMNS);
        console.log("this.generateTableHeaders() succeeded");
        this.effectiveAccountId = await UTILS.getEffectiveAccountId();
        console.log("this.effectiveAccountId process succeeded");
        this.getInitialData();
        console.log("this.getInitialData() succeeded");
    }

    renderedCallback() {
        if (this.isFirstRender) {
            this.isFirstRender = false;
            this.addCustomCssStyles();
        }
    }

    // METHODS
    addCustomCssStyles() {
        let styleText = `
            /* REODER MODAL WINDOW */
            .uiContainerManager .modal-container {
                max-width: 40rem;
            }

            .uiContainerManager .slds-modal__content {
                padding-bottom: 1.5rem;
                padding-top: 1.5rem;
            }

            .uiContainerManager .uiButton--modal-closeBtn {
                display: flex;
                justify-content: center;
                align-items: center;
            }

            .uiContainerManager .uiButton--modal-closeBtn .slds-icon_container {
                display: flex;
                justify-content: center;
                align-items: center;
                line-height: 1;
                font-size: 1rem;
            }

            .uiContainerManager .forceIcon .slds-icon_xx-small {
                width: 28px;
                height: 28px;
            }

            .uiContainerManager .forceCommunityCommerceReorder {
                grid-row-gap: 1.5rem;
                min-height: auto !important;
                max-height: auto !important;
            }

            .uiContainerManager .forceCommunityCommerceReorder .slds-col {
                padding-bottom: 0;
            }

            .uiContainerManager .forceCommunityCommerceReorder .slds-col:first-child {
                padding-left: 0;
            }

            .uiContainerManager .forceCommunityCommerceReorder .slds-col:last-child {
                padding-right: 0;
            }

            @media (max-width: 1023.98px) {
                .uiContainerManager .forceCommunityCommerceReorder .slds-col {
                    padding: 0;
                }

                .uiContainerManager .forceCommunityCommerceReorder .slds-col + .slds-col {
                    padding-top: 1rem;
                }
            }

            .uiContainerManager .forceCommunityCommerceReorder .slds-modal__content.slds-p-around_medium,
            .uiContainerManager .forceCommunityCommerceReorder p.slds-p-around_small,
            .uiContainerManager .forceCommunityCommerceReorder h2.slds-p-around_small,
            .uiContainerManager .forceCommunityCommerceReorder li > .slds-p-around_medium {
                padding-left: 0;
                padding-right: 0;
            }

            .uiContainerManager .forceCommunityCommerceReorder .slds-modal__content.slds-p-around_medium {
                padding-top: 0;
            }

            .uiContainerManager .forceCommunityCommerceReorder .screenHeader {
                margin-top: 0;
                font-size: 18px;
                line-height: 1.4;
                font-weight: 700;
                text-transform: uppercase !important;
            }

            .uiContainerManager .forceCommunityCommerceReorder .errorScreenInfoText {
                font-size: 14px;
            }

            .uiContainerManager .forceCommunityCommerceReorder .errorScreenButton {
                display: flex;
                justify-content: center;
                align-items: flex-end;
            }

            .uiContainerManager .forceCommunityCommerceReorder .successScreen {
                min-height: auto;
                padding-bottom: 1rem;
            }

            .uiContainerManager .forceCommunityCommerceReorder .slds-button {
                display: block;
                width: 100%;
                min-width: 120px;
                margin: 0 auto;
                font-size: 14px;
                font-weight: 700;
                line-height: 38px;
                text-transform: uppercase;
                border-radius: 5px;
                border: 1px solid var(--b2b-colorAction);
            }

            /* B2B TABLE */
            c-b2b-table .slds-table {
                table-layout: auto !important;
            }

            c-b2b-table td:not(:first-child) span,
            c-b2b-table td:not(:first-child) lightning-formatted-number {
                white-space: nowrap;
            }

            c-b2b-table .list-table .slds-table td {
                padding: 6px 16px !important;
            }

            c-b2b-table .list-table .slds-table td:first-child {
                text-align: left !important;
            }

            c-b2b-table .list-table .slds-table th:first-child .list__action {
                padding-left: 16px !important;
            }

            c-b2b-table .list-table .slds-table th:first-child .list__action {
                justify-content: flex-start;
            }

            c-b2b-table .list-table .slds-table td[data-type="link"] .link-cell {
                font-weight: 400;
                text-decoration: none;
                text-transform: none;
            }

            c-b2b-table .list-table .slds-table td span,
            c-b2b-table .list-table .slds-table td lightning-formatted-number {
                display: inline-block;
                min-width: 4vw;
            }
          
            /* START REORDER MODAL */

            @media (min-width: 48em){
                .slds-modal__container {
                    width: 30% !important;
                    max-width: 362px;
                }
            }

            .slds-modal__header p, .slds-modal__content, .modal-body.slds-modal__content{
                padding:1rem;
            }

            .commerce_my_account-reorderModalContents_reorderModalContents{
                text-transform: uppercase;
                font-size: 18px;
            }
          
            .continue-shopping.commerce_my_account-reorderModalContents_reorderModalContents{
                font-size: 14px;
                color: var(--sds-c-button-text-color,var(--dxp-s-button-color,var(--dxp-g-default,#0176d3)));
                background-color: var(--sds-c-button-outline-brand-color-background,var(--dxp-g-root,#fff));
                border-color: var(--sds-c-button-outline-brand-color-border,var(--dxp-s-button-color,var(--dxp-g-brand,#0176d3)));
            }

            .continue-shopping.commerce_my_account-reorderModalContents_reorderModalContents:hover{
                background-color: var(--sds-c-button-outline-brand-color-background-hover,var(--dxp-g-root-1,#f3f3f3));
                border-color: var(--sds-c-button-outline-brand-color-border-hover,var(--dxp-s-button-color-hover,var(--dxp-g-brand-1,#0176d3)));
                color: var(--sds-c-button-text-color-hover,var(--dxp-s-button-color-hover,var(--dxp-g-brand-1,#014486)));
            }

            .view-cart.commerce_my_account-reorderModalContents_reorderModalContents{
                font-size: 14px;
                color:white;
                background-color: var(--sds-c-button-brand-color-background,var(--dxp-s-button-color,var(--dxp-g-brand,#0176d3)));
                border-color: var(--sds-c-button-brand-color-background,var(--dxp-s-button-color,var(--dxp-g-brand,#0176d3)));
            }

            .view-cart.commerce_my_account-reorderModalContents_reorderModalContents:hover{
                color:white;
                background-color: var(--sds-c-button-brand-color-background-hover,var(--dxp-s-button-color-hover,var(--dxp-g-brand-1,#014486)));
                border-color: var(--sds-c-button-brand-color-background-hover,var(--dxp-s-button-color-hover,var(--dxp-g-brand-1,#014486)));
            }

            view-cart.commerce_my_account-reorderModalContents_reorderModalContents a{
                text-transform:lowercase;
            }

            view-cart.commerce_my_account-reorderModalContents_reorderModalContents a:first-letter,{
                text-transform: capitalize;
            }
            
            commerce_my_account-reorder-modal-contents > h1,
            commerce_my_account-reorder-modal-contents > h2,
            commerce_my_account-reorder-modal-contents h3 {
                text-transform: uppercase !important;
                font-size: 18px !important;
                color: rgb(35,31,32) !important;
            }
            
            commerce_my_account-reorder-modal-contents .unadded-product-list-column {
                text-transform: uppercase !important;
                font-size: 18px !important;
            }
            
            commerce_my_account-reorder-modal-contents a.view-cart {
                font-size: 14px;
                color: white !important;
                background-color: rgb(35, 31, 32);
                border-color: rgb(35, 31, 32);
            }
            
            commerce_my_account-reorder-modal-contents a.view-cart:hover {
                background-color: rgb(218, 41, 28);
                border-color: rgb(218, 41, 28);
            }
            
            commerce_my_account-reorder-modal-contents button.continue-shopping {
                background-color: rgb(255, 255, 255) !important;
                border-color: rgb(35, 31, 32) !important;
                color: rgb(35, 31, 32) !important;
            }
            
            commerce_my_account-reorder-modal-contents button.continue-shopping:hover {
                background-color: rgba(19, 156, 216, 0.07) !important;
                border-color: rgb(218, 41, 28) !important;
                color: rgb(218, 41, 28) !important;
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

    addCssForUnavailableRecord() {
        let styleText = `
            community_layout-section:has(.commerce_my_account-reorderButton_reorderButton) {
                    display: none !important;
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

    generateTableHeaders(TABLE_COLUMNS) {
        let result = [];

        TABLE_COLUMNS.forEach((item, index) => {
            let headerItem = {
                key: index,
                label: item.label || null,
                class: item.class || null,
                field: item.field || null,
                isSort: item.sort,
                orderClass: 'list__action no-sort-column'
            };

            result.push(headerItem);
        });

        this.tableOrdersHeaders = result;
    }


    //need to add calloutOrderStatus.getCalloutOrderStatus(String recordId)
    getInitialData() {
        if (!this.recordId) {
            console.log("this.recordId is null");
            return;
        }
        console.log("this.recordId: " , this.recordId);
        
        _getOrderSummary({
            orderSummaryId: this.recordId,
            accountId: this.effectiveAccountId
        })
        .then((response) => {
            if (response && response.isSuccess && response.responseData) {
                this.parseResponse(response.responseData);
                _getCalloutOrderStatus({
                    recordId: this.recordId
                })
                .then((result) => {
                    console.log('1st this.order.status:= ', this.order.status);
                    console.log('1st this.OrdStat Before Value:= ', this.OrdStat);
                    this.ordStatLoading = false;
                    this.OrdStat = result;
                    console.log('2nd this.OrdStat after Value:= ', this.OrdStat);
                    
                 
                    // if(result != this.order.status){
                    //     console.log('2nd this.order.status:= ', this.order.status);
                    //     this.order.status = result;
                    //     console.log('3rd this.order.status:= ', this.order.status);
                    //     console.log('Inner Response:= ', result);
                    //     //eval("$A.get('e.force:refreshView').fire();");
                    //     console.log("_getCalloutOrderStatus() result block successful");
                    // }
                })
                .catch((error) => {
                    console.log(error);
                });
            }
            this.isLoading = false;
        })
        .catch((error) => {
            console.error(error);
            this.isLoading = false;
        });
    }

    parseResponse(data) {
        if (!data.order) {
            this.hasAccess = false;
            this.addCssForUnavailableRecord();
        } else {
            if (data.order) this.parseOrder(data.order);
            if (data.shipping) this.parseShipping(data.shipping);
            if (data.billing) this.parseBilling(data.billing);
            if (data.payment) this.parsePayment(data.payment);
            if (data.trackingLinks) this.parseTracking(data.trackingLinks);
            if (data.products && data.products.length) this.parseTableProducts(data.products);
            if (data.totals) this.parseTotals(data.totals);
        }
    }

    parseProductNameLink(name){
        return name.replace(/[^a-z0-9\s]/gi, '-');
    }

    parsePayment(payment) {
        this.payment.poNumber = payment.poNumber || null;
        this.payment.creditCard = payment.creditCard || null;
        this.payment.paymentType = payment.paymentType || null;
    }

    parseOrder(order) {
        this.order.number = order.orderNumber || null;
        this.order.orderDate = order.orderDate || null;
        this.order.status = order.status || null;
        this.currencyIsoCode = order.currencyIsoCode || null;
    }

    parseShipping(shipping) {
        this.shipping.specialInstruction = shipping.specialInstruction || null;
        this.shipping.address = UTILS.getInlineAddressString({
            street: shipping.street,
            city: shipping.city,
            state: shipping.state,
            stateCode: '',
            postalCode: shipping.postalCode,
            country: shipping.country,
            countryCode: '',
        });
    }

    parseBilling(billing) {
        this.billing.accountName = billing.accountName || null;
        this.billing.address = UTILS.getInlineAddressString({
            street: billing.billingStreet,
            city: billing.billingCity,
            state: billing.billingState,
            stateCode: null,
            postalCode: billing.billingPostalCode,
            country: billing.billingCountry,
            countryCode: null,
        });
    }

    parseTracking(tracking) {
        this.tracking = tracking;
    }

    parseTableProducts(list) {
        let result = [];
        let mobileResult = [];

        if (list && list.length) {
            result = this.getDesktopTableItems(list);
            mobileResult = this.getMobileTableItems(list);
        }

        this.list = result;
        this.listMobile = mobileResult;
    }

    getDesktopTableItems(list) {
        let result = [];

        list.forEach((item, itemIndex) => {
            let row = {
                key: itemIndex,
                data: []
            };

            let itemName = '';

            TABLE_COLUMNS.forEach((column, columnIndex) => {
                let formattedItem = {
                    key: `${itemIndex}-${columnIndex}`
                };

                itemName = this.parseProductNameLink(item.name);

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
                        formattedItem.url = `${communityBasePath}/product/${itemName}/${item.id}`;
                        break;
                    case 'date':
                        formattedItem.isDate = true;
                        formattedItem.label = item[column.field];
                        break;
                    case 'currency':
                        formattedItem.isCurrency = true;
                        formattedItem.label = item[column.field];
                        formattedItem.currencyCode = this.getCurrencyIsoCode;
                        break;
                }

                row.data.push(formattedItem);
            });

            result.push(row);
        });

        return result;
    }

    getMobileTableItems(list) {
        let mobileResult = [];

        list.forEach((item, itemIndex) => {
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
                    case 'string':
                        headerItem.isString = true;
                        headerItem.label = item[mobileHeaderItem.field];
                        break;
                    case 'link':
                        headerItem.isLink = true;
                        headerItem.label = item[mobileHeaderItem.field];
                        headerItem.url = `${communityBasePath}/product/${item.id}`;
                        break;
                    case 'currency':
                        headerItem.isCurrency = true;
                        headerItem.label = mobileHeaderItem.label;
                        headerItem.value = item[mobileHeaderItem.field];
                        headerItem.hasAdditionalLabel = !!mobileHeaderItem.additionalLabel;
                        headerItem.additionalLabel = mobileHeaderItem.additionalLabel;
                        headerItem.currencyCode = this.getCurrencyIsoCode;
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
                    case 'date':
                        bodyItem.isDate = true;
                        bodyItem.label = mobileBodyItem.label;
                        bodyItem.value = item[mobileBodyItem.field];
                        break;
                    case 'currency':
                        bodyItem.isCurrency = true;
                        bodyItem.label = mobileBodyItem.label;
                        bodyItem.value = item[mobileBodyItem.field];
                        bodyItem.currencyCode = this.getCurrencyIsoCode;
                        break;
                }

                mobileItem.itemBody.push(bodyItem);
            });

            mobileResult.push(mobileItem);
        });

        return mobileResult;
    }

    parseTotals(totals) {
        this.totals.subtotal = totals.subtotal || totals.subtotal === 0 ? totals.subtotal : null;
        this.totals.darleyDollars = totals.darleyDollars || totals.darleyDollars === 0 ? (-1)*(totals.darleyDollars) : null;
        this.totals.discount = totals.discount || totals.discount === 0 ? totals.discount : null;
        this.totals.shipping = totals.shipping || totals.shipping === 0 ? totals.shipping : null;
        this.totals.tax = totals.tax || totals.tax === 0 ? totals.tax : null;
        this.totals.estimatedShipping = totals.estimatedShipping || totals.estimatedShipping === 0 ? totals.estimatedShipping : null;
        this.totals.promotions = totals.promotions || totals.promotions === 0 ? totals.promotions : null;
        this.totals.total = totals.total || totals.total === 0 ? totals.total : null;
    }

    // HANDLERS
    handleClickOrderTitle(event) {
        let id = event.detail;
        if (!id) return;
        this.listMobile.forEach(item => {
            if (item.id === id) {
                item.showDetails = !item.showDetails;
            }
        });
    }

}