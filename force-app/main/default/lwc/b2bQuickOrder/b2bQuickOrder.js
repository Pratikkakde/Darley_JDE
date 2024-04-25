import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { UTILS, IS } from 'c/b2bUtils';

// METHODS
import getRecordsWithInitialSearchString from '@salesforce/apex/B2BSearchRecordController.getRecordsWithInitialSearchString';
// import submitQuickOrder from '@salesforce/apex/B2BQuickOrderController.submitQuickOrder';

// LABELS
import B2B_Quick_Order_Loading from '@salesforce/label/c.B2B_Quick_Order_Loading';
import B2B_Quick_Order_Title from '@salesforce/label/c.B2B_Quick_Order_Title';
import B2B_Quick_Order_Column_Product_Label from '@salesforce/label/c.B2B_Quick_Order_Column_Product_Label';
import B2B_Quick_Order_Column_Quantity_Label from '@salesforce/label/c.B2B_Quick_Order_Column_Quantity_Label';
import B2B_Quick_Order_Add_Line_Button_Label from '@salesforce/label/c.B2B_Quick_Order_Add_Line_Button_Label';
import B2B_Quick_Order_Add_To_Cart_Button_Label from '@salesforce/label/c.B2B_Quick_Order_Add_To_Cart_Button_Label';
import B2B_Quick_Order_Rule_Min_Text from '@salesforce/label/c.B2B_Quick_Order_Rule_Min_Text';
import B2B_Quick_Order_Rule_Max_Text from '@salesforce/label/c.B2B_Quick_Order_Rule_Max_Text';
import B2B_Quick_Order_Rule_Increment_Text from '@salesforce/label/c.B2B_Quick_Order_Rule_Increment_Text';
import B2B_Quick_Order_Add_Product_Error from '@salesforce/label/c.B2B_Quick_Order_Add_Product_Error';
import B2B_Quick_Order_Close from '@salesforce/label/c.B2B_Quick_Order_Close';
import B2B_Quick_Order_Success_Modal_Title from '@salesforce/label/c.B2B_Quick_Order_Success_Modal_Title';
import B2B_Quick_Order_Success_Modal_Title_Many_Products from '@salesforce/label/c.B2B_Quick_Order_Success_Modal_Title_Many_Products';
import B2B_Quick_Order_Success_Modal_View_Cart from '@salesforce/label/c.B2B_Quick_Order_Success_Modal_View_Cart';
import B2B_Quick_Order_Success_Modal_Continue_Shopping from '@salesforce/label/c.B2B_Quick_Order_Success_Modal_Continue_Shopping';
import B2B_Quick_Order_Limit_Exceeded from '@salesforce/label/c.B2B_Quick_Order_Limit_Exceeded';

const LABELS = {
    loading: B2B_Quick_Order_Loading,
    title: B2B_Quick_Order_Title,
    columnProductLabel: B2B_Quick_Order_Column_Product_Label,
    columnQuantityLabel: B2B_Quick_Order_Column_Quantity_Label,
    addLineButtonLabel: B2B_Quick_Order_Add_Line_Button_Label,
    addToCartButtonLabel: B2B_Quick_Order_Add_To_Cart_Button_Label,
    ruleMinText: B2B_Quick_Order_Rule_Min_Text,
    ruleMaxText: B2B_Quick_Order_Rule_Max_Text,
    ruleIncrementText: B2B_Quick_Order_Rule_Increment_Text,
    addProductError: B2B_Quick_Order_Add_Product_Error,
    close: B2B_Quick_Order_Close,
    successModalTitleFor1Product: B2B_Quick_Order_Success_Modal_Title,
    successModalTitleForManyProducts: B2B_Quick_Order_Success_Modal_Title_Many_Products,
    successModalViewCart: B2B_Quick_Order_Success_Modal_View_Cart,
    successModalContinueShopping: B2B_Quick_Order_Success_Modal_Continue_Shopping,
    limitExceeded: B2B_Quick_Order_Limit_Exceeded,
};

const COMPONENT_NAME = 'b2b-quick-order';
const TIMMER_DELAY = 300;
const LIMIT_EXCEEDED = 'LIMIT_EXCEEDED';

export default class B2BQuickOrder extends NavigationMixin(LightningElement) {
    @api numberOfLines = null;
    @api maxNumberOfLines = null;
    @api showImageInResults = false;
    
    @track effectiveAccountId = null;
    @track isUpdateLoading = false;
    @track isFirstRender = true;
    @track customCssContainer = UTILS.customCssContainer;
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);
    @track labels = LABELS;

    @track list = [];
    @track quantityEditable = true;
    @track showModal = false;
    @track cartId = null;
    @track productsCountAddedToCart = 0;

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper}`;
    }

    get showComponent() {
        return !UTILS.isGuest;
    }

    get showListSubtitle() {
        return IS.arrayNotEmpty(this.list);
    }

    get modalTitleLabel() {
        return (IS.numeric(this.productsCountAddedToCart) && this.productsCountAddedToCart <= 1)
            ? this.labels.successModalTitleFor1Product
            : this.labels.successModalTitleForManyProducts;
    }

    get isFormDisabled() {
        return this.isUpdateLoading;
    }

    get isAddLineDisabled() {
        return this.isFormDisabled ||
        !(
            IS.numeric(this.maxNumberOfLines) &&
            this.list.length < this.maxNumberOfLines
        );
    }

    get isAddToCartDisabled() {
        if (this.isUpdateLoading) {
            return true;
        }

        let isValid = false;
        this.list.forEach((item) => {
            if (
                IS.stringNotEmpty(item.productId) &&
                IS.numeric(item.quantity)
            ) {
                isValid = true;
            }
        });
        return isValid ? null : true;
    }

    // LIFECYCLES
    async connectedCallback() {
        this.effectiveAccountId = await UTILS.getEffectiveAccountId();
        this.fillinFormDefaultLines();
    }

    renderedCallback() {
        if (this.isFirstRender) {
            this.isFirstRender = false;
            this.addCustomCssStyles();

            // this._eventListenerKeyup = this.eventListenerKeyup.bind(this);
            // window.addEventListener('keyup', this._eventListenerKeyup);
        }
    }

    // METHODS
    addCustomCssStyles() {
        let styleText = `
            .${this.wrapper} .slds-form-element {
                margin-bottom: 0;
            }

            /* SEARCH PRODUCT */
            .${this.wrapper} c-b2b-quick-order-search-product lightning-input .slds-form-element__control > lightning-primitive-icon {
                display: none;
            }

            .${this.wrapper} c-b2b-quick-order-search-product lightning-input .slds-input {
                padding: 0 12px;
                font-size: 14px;
            }

            /* QUANTITY */
            .${this.wrapper} c-b2b-quantity .slds-button.slds-button_icon {
                display: none;
            }

            .${this.wrapper} c-b2b-quantity .slds-form-element__control,
            .${this.wrapper} c-b2b-quantity .slds-form-element__control input.slds-input {
                width: 100% !important;
                height: 32px !important;
            }

            .${this.wrapper} c-b2b-quantity .slds-form-element__control input.slds-input {
                font-size: 14px !important;
                font-weight: 400 !important;
                border-radius: 0;
            }

            .${this.wrapper} c-b2b-quantity .slds-form-element__control input.slds-input:focus {
                border-color: var(--b2b-colorAction) !important;
                box-shadow: 0 0 3px var(--b2b-colorAction) !important;
            }

            /* ACTION BUTTONS */
            .${COMPONENT_NAME}__item-quantity-rule lightning-helptext,
            .${COMPONENT_NAME}__item-quantity-rule lightning-helptext .slds-form-element__icon,
            .${COMPONENT_NAME}__item-quantity-rule lightning-helptext .slds-button_icon,
            .${COMPONENT_NAME}__item-quantity-rule lightning-helptext .slds-button_icon lightning-primitive-icon,
            .${COMPONENT_NAME}__item-remove-line lightning-button-icon,
            .${COMPONENT_NAME}__item-remove-line lightning-button-icon .slds-button,
            .${COMPONENT_NAME}__item-remove-line lightning-button-icon .slds-button lightning-primitive-icon {
                display: block;
                width: 18px;
                height: 18px;
                border: 0;
            }

            .${COMPONENT_NAME}__item-quantity-rule lightning-helptext .slds-button lightning-primitive-icon,
            .${COMPONENT_NAME}__item-remove-line lightning-button-icon .slds-button lightning-primitive-icon {
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .${COMPONENT_NAME}__item-quantity-rule lightning-helptext .slds-form-element__icon {
                padding: 0;
            }

            .${COMPONENT_NAME}__item-quantity-rule lightning-helptext svg,
            .${COMPONENT_NAME}__item-remove-line lightning-button-icon .slds-button svg {
                width: 15px;
                height: 15px;
                fill: var(--b2b-colorAction);
                transition: fill 0.1s;
            }

            .${COMPONENT_NAME}__item-quantity-rule lightning-helptext .slds-button:hover svg,
            .${COMPONENT_NAME}__item-remove-line lightning-button-icon .slds-button:hover svg {
                fill: var(--b2b-colorActionDarker);
            }

            /* BUTTONS */
            .${this.wrapper} .${COMPONENT_NAME}__buttons .slds-button {
                font-size: 13px;
                line-height: 38px;
                font-weight: 600;
                transition: color 0.1s, border-color 0.1s, background-color 0.1s;
            }

            .${this.wrapper} .${COMPONENT_NAME}__buttons .slds-button svg {
                transform: translateY(-1px);
            }

            .${this.wrapper} .${COMPONENT_NAME}__buttons lightning-button:first-child .slds-button{
                font-size: 14px;
                font-weight: 700;
                text-decoration-line: underline;
                text-transform: uppercase;
            }

            .${this.wrapper} .${COMPONENT_NAME}__buttons lightning-button:last-child,
            .${this.wrapper} .${COMPONENT_NAME}__buttons lightning-button:last-child .slds-button {
                width: 100%;
                max-width: 136px;
            }

            @media (max-width: 574.98px) {
                .${this.wrapper} .${COMPONENT_NAME}__buttons lightning-button:last-child,
                .${this.wrapper} .${COMPONENT_NAME}__buttons .slds-button.slds-button_brand {
                    width: 100%;
                }
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

    navigateTo(url) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: { url }
        });
    }

    fillinFormDefaultLines() {
        for (let i = 1; i <= this.numberOfLines; i++) {
            this.handleClickAddLine();
        }
    }

    parseResponse(data, lineItem) {
        if (IS.arrayNotEmpty(data) && IS.objectNotEmpty(lineItem)) {
            let options = [];
            data.forEach((item) => {
                let newItem = {
                    id: IS.stringNotEmpty(item.id) ? item.id : null,
                    name: IS.stringNotEmpty(item.name) ? item.name : null,
                    sku: IS.stringNotEmpty(item.sku) ? item.sku : null,
                    increment: null,
                    minQuantity: null,
                    maxQuantity: null,
                };

                if (IS.objectNotEmpty(item.qtyRule)) {
                    newItem.increment = IS.numeric(item.qtyRule.increment) ? item.qtyRule.increment : null;
                    newItem.minQuantity = IS.numeric(item.qtyRule.min) ? item.qtyRule.min : null;
                    newItem.maxQuantity = IS.numeric(item.qtyRule.max) ? item.qtyRule.max : null;
                }

                if (
                    IS.stringNotEmpty(newItem.id) &&
                    IS.stringNotEmpty(newItem.name) &&
                    IS.stringNotEmpty(newItem.sku)
                ) {
                    options.push(newItem);
                }
            });
            lineItem.options = options;
        }
    }

    // HANDLERS
    handleClickAddLine() {
        if (
            IS.arrayNotEmpty(this.list) &&
            IS.integer(this.maxNumberOfLines) &&
            this.list.length === this.maxNumberOfLines
        ) {
            return;
        }

        this.list.push({
            itemId: `item_${UTILS.random.componentId()}`,
            isUpdateLoading: false,
            search: null,
            searchTimmer: null,
            options: [],
            productId: null,
            name: null,
            sku: null,
            quantity: 1,
            increment: null,
            minQuantity: null,
            maxQuantity: null,
            helptext: null,
        });
    }

    async handleChangeSearchProduct(event) {
        if (IS.stringNotEmpty(event.detail.itemId)) {
            // Find Item
            let item = null;
            let filter = this.list.filter((item) => item.itemId === event.detail.itemId);
            if (IS.arrayNotEmpty(filter)) {
                item = filter[0];
            }
            if (!IS.objectNotEmpty(item)) {
                return;
            }

            // Reset Options/Timmer
            item.options = [];
            if (item.searchTimmer) {
                clearTimeout(item.searchTimmer);
            }

            // Set search value
            if (IS.stringNotEmpty(event.detail.value)) {
                item.search = event.detail.value;
            } else {
                item.search = null;
                item.isUpdateLoading = false;
                return;
            }

            // Check search string valid
            let prepareSearch = UTILS.prepareString(item.search);
            if (IS.stringNotEmpty(prepareSearch)) {
                prepareSearch = prepareSearch.trim();
            }
            if(!IS.stringNotEmpty(prepareSearch)) {
                item.isUpdateLoading = false;
                return;
            }

            // Execute search
            item.isUpdateLoading = true;
            item.searchTimmer = setTimeout(async () => {
                let response = await UTILS.doRequest(getRecordsWithInitialSearchString, {
                    searchString: UTILS.prepareString(item.search).trim().toLowerCase()
                    // TODO: add this.effectiveAccountId
                });
                let data = UTILS.responseData(response);
                if (IS.objectNotEmpty(data)) {
                    this.parseResponse(data.records, item);
                }
                item.isUpdateLoading = false;
            }, TIMMER_DELAY);
        }
    }

    handleSelectSearchProduct(event) {
        if (
            IS.stringNotEmpty(event.detail.itemId) &&
            IS.stringNotEmpty(event.detail.selectedId)
        ) {
            let productId = event.detail.selectedId;
            this.list.forEach((item) => {
                if (item.itemId === event.detail.itemId) {
                    if (IS.arrayNotEmpty(item.options)) {
                        item.options.forEach((product) => {
                            if (product.id === productId) {

                                item.productId = IS.stringNotEmpty(productId) ? productId : null;
                                item.name = IS.stringNotEmpty(productId) ? product.name : null;
                                item.sku = IS.stringNotEmpty(productId) ? product.sku : null;
                                item.quantity = IS.stringNotEmpty(productId) ? item.quantity : 1;

                                // Quantity Rule
                                item.increment = IS.stringNotEmpty(productId) && IS.numeric(product.increment)
                                    ? product.increment
                                    : null;
                                item.minQuantity = IS.stringNotEmpty(productId) && IS.numeric(product.minQuantity)
                                    ? product.minQuantity
                                    : null;
                                item.maxQuantity = IS.stringNotEmpty(productId) && IS.numeric(product.maxQuantity)
                                    ? product.maxQuantity
                                    : null;
                                item.helptext = null;

                                if (IS.numeric(item.minQuantity)) {
                                    item.quantity = item.minQuantity;
                                }

                                // Quantity Rule Helptext
                                let helptext = [];
                                if (IS.numeric(item.minQuantity)) {
                                    helptext.push(UTILS.prepareLabel(LABELS.ruleMinText, [item.minQuantity]));
                                }
                                if (IS.numeric(item.maxQuantity)) {
                                    helptext.push(UTILS.prepareLabel(LABELS.ruleMaxText, [item.maxQuantity]));
                                }
                                if (IS.numeric(item.increment)) {
                                    helptext.push(UTILS.prepareLabel(LABELS.ruleIncrementText, [item.increment]));
                                }
                                if (IS.arrayNotEmpty(helptext)) {
                                    item.helptext = helptext.join('\r\n');
                                }
                            }
                        });
                    }
                }
            });
        }
    }

    handleQuantityChange(event) {
        let detail = JSON.parse(JSON.stringify(event.detail));
        if (IS.objectNotEmpty(detail)) {
            let itemId = detail.dataset.itemid;
            let value = detail.value;

            if (IS.stringNotEmpty(itemId) && IS.numeric(value)) {
                this.list.forEach((item) => {
                    if (item.itemId === itemId) {
                       item.quantity = value;
                    }
                });
            }
        }
    }

    handleClickRemove(event) {
        let itemId = event.target.dataset.itemid;
        if (IS.stringNotEmpty(itemId)) {
            this.list = this.list.filter((item) => item.itemId !== itemId);
        }
    }

    // Backend adding
    // async handleClickAddToCart() {
    //     if (this.isUpdateLoading) {
    //         return;
    //     }

    //     // Collect the product id and quantity
    //     let result = [];
    //     if (IS.arrayNotEmpty(this.list)) {
    //         this.list.forEach((item) => {
    //             if (
    //                 IS.stringNotEmpty(item.productId) &&
    //                 IS.numeric(item.quantity)
    //             ) {
    //                 result.push({
    //                     'id': item.productId,
    //                     'finalQuantity': item.quantity
    //                 });
    //             }
    //         });
    //     }

    //     if (IS.arrayNotEmpty(result)) {
    //         this.isUpdateLoading = true;
    //         this.productsCountAddedToCart = result.length;

    //         let response = await UTILS.doRequest(submitQuickOrder, {
    //             products: JSON.stringify(result),
    //             effectiveAccountId: this.effectiveAccountId
    //         });
    //         let data = UTILS.responseData(response);

    //         if (
    //             UTILS.responseSuccess(response) &&
    //             IS.stringNotEmpty(data)
    //         ) {
    //             this.cartId = data;
    //             this.showModal = true;
    //             window.document.body.style.overflowY = 'hidden';
    //             this.list = [];
    //             this.fillinFormDefaultLines();
    //         } else {
    //             UTILS.showToast('error', IS.stringNotEmpty(response.responseMessage)
    //                 ? response.responseMessage
    //                 : LABELS.addProductError
    //             );
    //             console.error(response.responseData);
    //         }

    //         UTILS.updateCartQuantity(this);
    //         this.isUpdateLoading = false;
    //     }
    // }

    async handleClickAddToCart() {
        if (this.isUpdateLoading) {
            return;
        }

        // Collect the product id and quantity
        let result = {};
        if (IS.arrayNotEmpty(this.list)) {
            this.list.forEach((item) => {
                if (IS.stringNotEmpty(item.productId) && IS.numeric(item.quantity)) {
                    result[item.productId] = item.quantity;
                }
            });
        }

        if (IS.objectNotEmpty(result)) {
            this.isUpdateLoading = true;
            this.productsCountAddedToCart = Object.keys(result).length;

            let response = await UTILS.addItemsToCart(result);
            let data = UTILS.responseData(response);

            if (UTILS.responseSuccess(response) && IS.arrayNotEmpty(data)) {
                this.cartId = data[0].cartId;
                this.showModal = true;
                window.document.body.style.overflowY = 'hidden';
                this.list = [];
                this.fillinFormDefaultLines();
            } else {
                console.error(response);
                if (IS.stringIncludes(response.responseData, LIMIT_EXCEEDED)) {
                    UTILS.showToast('error', LABELS.limitExceeded);
                } else {
                    UTILS.showToast('error', IS.stringNotEmpty(response.responseMessage)
                        ? response.responseMessage
                        : LABELS.addProductError
                    );
                }
            }
            this.isUpdateLoading = false;
        }
    }
    
    handleClickModalClose() {
        this.showModal = false;
        this.cartId = null;
        window.document.body.style.overflowY = 'auto';
    }

    handleClickModalViewCart() {
        this.navigateTo(UTILS.link(`/cart`));
        this.handleClickModalClose();
    }

}