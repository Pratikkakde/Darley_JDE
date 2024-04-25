import { LightningElement, track, api } from 'lwc';
import { UTILS, IS, DISPATCHER, STORAGE } from 'c/b2bUtils';

// METHODS
import getInitialGuestCart from '@salesforce/apex/B2BGuestCartController.getInitialGuestCart';
import deleteGuestCartItem from '@salesforce/apex/B2BGuestCartController.deleteGuestCartItem';
import changeQtyGuestCartItem from '@salesforce/apex/B2BGuestCartController.changeQtyGuestCartItem';
import clearGuestCart from '@salesforce/apex/B2BGuestCartController.clearGuestCart';
import validateCartProductsByCart from '@salesforce/apex/B2BValidateCartProductsController.validateCartProductsByCart';
import validateCartProductByCart from '@salesforce/apex/B2BValidateCartProductsController.validateCartProductByCart';

// LABELS
const LABELS = {
    loading: 'Loading',
    cancel: 'Cancel',
    cart: 'Cart',
    cartTitle: 'Cart ({0})',
    clearCart: 'Clear Cart',
    cartEmptyTitle: 'Your cart is empty',
    cartEmptyDescription: 'Search or browse products, and add them to your cart. Your selections appear here.',
    continueShopping: 'Continue Shopping',
    cartFatalError: `The cart that you requested isn't available.`,
    deleteProductSuccess: 'Product was delete successfully',
    deleteProductError: 'The product was not deleted. Try again later.',
    quantityUpdateSuccess: 'Quantity successfully updated',
    quantityUpdateError: 'Quantity not updated',
    cartRemoveAll: 'Remove all items from your cart?',
    clearCartSuccess: 'The "Shopping Card" has been successfully cleared.',
    clearCartError: 'The "Shopping Card" could not be cleared. Try again later.',
    sortBy: 'Sort By',
    newestToOldest: 'Newest to Oldest',
    oldestToNewest: 'Oldest to Newest',
    nameAtoZ: 'Name - A to Z',
    nameZtoA: 'Name - Z to A',
    subtotal: 'Subtotal',
    shipping: 'Shipping',
    tax: 'Tax',
    discount: 'Discount',
};

const COMPONENT_NAME = 'b2b-guest-cart';
const GUEST_CART_ICON_ID = 'b2b-guest-cart-icon';
const TOTAL_ITEMS_IN_CART = 'Total Items in Cart';
const TOTAL_PRODUCTS_IN_CART = 'Total Products in Cart';
const UPDATE_CART_EVENT = 'update_cart';

export default class B2bGuestCart extends LightningElement {
    @api recordId = null;
    @api fieldsetApiName = null;
    @api quantityType = null;
    @api showPromotion = false;
    @api couponsLabelColor = null;
    @api couponsBackgroundColor = null;

    @track guestCartId = null;
    @track effectiveAccountId = null;
    @track isLoading = true;
    @track isUpdateLoading = false;
    @track isFirstRender = true;
    @track isFatalError = false;
    @track labels = LABELS;
    @track customCssContainer = UTILS.customCssContainer;
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);

    @track quantity = 0;
    @track sort = 'CreatedDate DESC';
    @track sortRequired = true;
    @track sortOptions = [
        {
            value: 'CreatedDate DESC',
            label: LABELS.newestToOldest
        },
        {
            value: 'CreatedDate',
            label: LABELS.oldestToNewest
        },
        {
            value: 'Name',
            label: LABELS.nameAtoZ
        },
        {
            value: 'Name DESC',
            label: LABELS.nameZtoA
        },
    ];
    @track currencyIsoCode = null;
    @track hasUnavailableProducts = false;
    @track unavailableProductsCount = 0;
    @track products = [];
    @track totalFields = [];
    @track total = 0;
    @track modal = {
        show: false
    };

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper}`;
    }

    get getCurrencyIsoCode() {
        return this.currencyIsoCode || UTILS.currencyIsoCode;
    }

    get showFatalError() {
        return !this.isLoading
            && (
                this.isFatalError
                || (!UTILS.isGuest && !IS.stringNotEmpty(this.recordId))
                ||!IS.stringNotEmpty(this.effectiveAccountId)
            );
    }

    get showSpinner() {
        return this.isLoading ||
            this.isUpdateLoading;
    }

    get showEmptyMessage() {
        return !this.isLoading &&
            !this.showFatalError &&
            !IS.arrayNotEmpty(this.products);
    }

    get isSortDisabled() {
        return this.showFatalError ||
            this.showEmptyMessage ||
            this.showSpinner;
    }

    get showProducts() {
        return this.isUpdateLoading ||
            !this.isLoading &&
            !this.showFatalError &&
            !this.showEmptyMessage;
    }

    get isProductUpdating() {
        let result = false;
        if (IS.arrayNotEmpty(this.products)) {
            this.products.forEach((item) => {
                if (IS.true(item.isUpdating)) {
                    result = true;
                }
            });
        }
        return result;
    }

    get isProceedDisabled() {
        return !this.showProducts ||
            this.showSpinner ||
            this.isProductUpdating ||
            this.hasUnavailableProducts;
    }

    get unavailableProductsCount() {
        return this.products.filter((item) => !IS.true(item.isAvailable)).length;
    }

    get hasUnavailableProducts() {
        return this.unavailableProductsCount > 0;
    }

    get showSidebar() {
        return this.isFirstRender
            || (
                !this.isFirstRender
                && !this.showFatalError
                && IS.arrayNotEmpty(this.products)
                && this.unavailableProductsCount !== this.products.length
            );
    }

    // LIFECYCLES
    async connectedCallback() {
        this.effectiveAccountId = await UTILS.getEffectiveAccountId();
        if (UTILS.isGuest) {
            this.guestCartId = STORAGE.getGuestCartId();
            this.updateCartQuantity();
        }
        let validateCartProdResponse = await UTILS.doRequest(validateCartProductsByCart, { cartId: UTILS.isGuest ? this.guestCartId : this.recordId});
        this.getInitialData();
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
            /* WRAPPER */
            .${this.wrapper} {
                ${UTILS.generateCssVar('guestCart', 'couponsLabelColor', this.couponsLabelColor)}
                ${UTILS.generateCssVar('guestCart', 'couponsBackgroundColor', this.couponsBackgroundColor)}
            }

            /* SORT */
            .${COMPONENT_NAME}__sort .b2b-select__wrapper {
                display: flex;
                align-items: center;
            }

            .${COMPONENT_NAME}__sort .b2b-select__label {
                padding-top: 0;
                margin-bottom: 0;
                font-size: 14px;
            }

            .${COMPONENT_NAME}__sort .slds-required {
                display: none;
            }

            .${COMPONENT_NAME}__sort .b2b-select__select {
                min-width: 190px;
                font-size: 12px;
                color: #6D6E71;
            }

            /* QUANTITY */
            c-b2b-quantity .b2b-quantity__wrapper .slds-required {
                display: none;
            }

            c-b2b-quantity .b2b-quantity__wrapper .slds-input {
                width: 100px !important;
            }

            /* PROMOTION */
            .b2b-guest-cart-item__promotion .b2b-popover__button-trigger {
                color: var(--b2b-guestCart-couponsLabelColor);
                border: 1px solid var(--b2b-guestCart-couponsBackgroundColor);
                background-color: var(--b2b-guestCart-couponsBackgroundColor);
            }

            .b2b-guest-cart-item__promotion .b2b-accordion__wrapper {
                border-bottom: 0;
            }

            .b2b-guest-cart-item__promotion .b2b-accordion__header {
                justify-content: flex-start;
                grid-column-gap: 8px;
                padding-bottom: 0;
            }

            .b2b-guest-cart-item__promotion .b2b-accordion__content {
                padding-top: 10px;
                white-space: pre-line;
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

    async getInitialData() {
        if (this.showFatalError) {
            this.isLoading = false;
            return;
        }

        let response = await UTILS.doRequest(getInitialGuestCart, {
            cartId: UTILS.isGuest ? this.guestCartId : this.recordId,
            effectiveAccountId: this.effectiveAccountId,
            sortOrder: this.sort,
            fieldSet: IS.stringNotEmpty(this.fieldsetApiName)
                ? this.fieldsetApiName
                : null
        });
        let data = UTILS.responseData(response);

        if (IS.objectNotEmpty(data)) {
            this.currencyIsoCode = IS.stringNotEmpty(data.currencyIsoCode) 
                ? data.currencyIsoCode
                : null;
            this.updateCartIcon(data.cartData);
            this.products = this.parseProducts(data.items);
            this.parseTotals(data.totals);
        } else {
            this.updateCartIcon();
            this.isFatalError = true;
        }
        this.updateCartQuantity();
        
       this.isLoading = false;
        this.isUpdateLoading = false;
    }

    parseProducts(list) {
        let products = [];
        if (IS.arrayNotEmpty(list)) {
            list.forEach((item) => {
                let newItem = {
                    id: IS.stringNotEmpty(item.productId) ? item.productId : null,
                    image: IS.stringNotEmpty(item.img) ? item.img : null,
                    name: IS.stringNotEmpty(item.name) ? item.name : null,
                    sku: IS.stringNotEmpty(item.sku) ? item.sku : null,
                    price: IS.numeric(item.price) ? item.price : null,
                    priceOriginal: IS.numeric(item.originalPrice) ? item.originalPrice : null,
                    quantity: IS.numeric(item.quantity) ? item.quantity : null,
                    quantityRule: {
                        min: null,
                        max: null,
                        increment: null,
                    },
                    subtotalOriginal: IS.numeric(item.originalSubtotal) ? item.originalSubtotal : null,
                    subtotal: IS.numeric(item.subtotal) ? item.subtotal : null,
                    variations: [],
                    fields: [],
                    isUpdating: false,
                    isAvailable: true,
                    showPromotion: IS.true(this.showPromotion) && IS.numeric(item.discountAmount),
                    discountAmount: IS.numeric(item.discountAmount) ? item.discountAmount : null,
                    coupon: IS.stringNotEmpty(item.coupon) ? item.coupon : null,
                    termsAndConditions: IS.stringNotEmpty(item.termsAndConditions) ? item.termsAndConditions : null,
                };

                // Parse Variations
                if (IS.arrayNotEmpty(item.attributes)) {
                    item.attributes.forEach((attribute) => {
                        if (
                            IS.stringNotEmpty(attribute.label) &&
                            IS.stringNotEmpty(attribute.currentOption)
                        ) {
                            newItem.variations.push({
                                label: attribute.label,
                                value: attribute.currentOption
                            });
                        }
                    });
                }

                // Parse Fieldset
                if (IS.objectNotEmpty(item.fields)) {
                    for (let key in item.fields) {
                        newItem.fields.push({
                            label: key,
                            value: item.fields[key]
                        });
                    }
                }

                // Parse Quantity Rule
                if (IS.objectNotEmpty(item.qtyRule)) {
                    newItem.quantityRule.min = IS.numeric(item.qtyRule.min)
                        ? item.qtyRule.min
                        : null;
                    newItem.quantityRule.max = IS.numeric(item.qtyRule.max)
                        ? item.qtyRule.max
                        : null;
                    newItem.quantityRule.increment = IS.numeric(item.qtyRule.inc)
                        ? item.qtyRule.inc
                        : null;
                }

                if (
                    IS.stringNotEmpty(newItem.id) &&
                    IS.stringNotEmpty(newItem.name)
                ) {
                    products.push(newItem);
                }
            });
        }
        return products;
    }

    parseTotals(data) {
        if (IS.objectNotEmpty(data)) {
            let totalFields = [];

            // if (IS.numeric(data.subtotal)) {
            //     totalFields.push({ label: LABELS.subtotal, value: data.subtotal });
            // }

            // if (IS.numeric(data.shipping)) {
            //     totalFields.push({ label: LABELS.shipping, value: data.shipping });
            // }

            // if (IS.numeric(data.tax)) {
            //     totalFields.push({ label: LABELS.tax, value: data.tax });
            // }

            // if (IS.numeric(data.discount)) {
            //     totalFields.push({ label: LABELS.discount, value: data.discount });
            // }

            this.totalFields = totalFields;
            this.total = IS.numeric(data.total) ? data.total : 0;
        }
    }

    updateCartIcon(data) {
        DISPATCHER.fireEvent(GUEST_CART_ICON_ID, UPDATE_CART_EVENT, data);
        this.guestCartId = STORAGE.getGuestCartId();
    }

    updateCartQuantity() {
        if (
            !IS.stringNotEmpty(this.quantityType) ||
            (
                IS.stringNotEmpty(this.quantityType) &&
                this.quantityType !== TOTAL_ITEMS_IN_CART &&
                this.quantityType !== TOTAL_PRODUCTS_IN_CART
            )
        ) {
            this.quantityType = TOTAL_ITEMS_IN_CART;
        }

        let quantity = 0;
        if (IS.stringNotEmpty(this.quantityType)) {
            if (this.quantityType === TOTAL_ITEMS_IN_CART) {
                quantity = STORAGE.getGuestCartIconItems();
            } else if (this.quantityType === TOTAL_PRODUCTS_IN_CART) {
                quantity = STORAGE.getGuestCartIconProducts();
            }
        }
        if (IS.numeric(quantity)) {
            this.quantity = quantity;
        }
    }

    updateCartItem(id, list) {
        if (
            IS.arrayNotEmpty(this.products) &&
            IS.stringNotEmpty(id) &&
            IS.arrayNotEmpty(list)
        ) {
            let product = null;
            list.forEach((item) => {
                if (item.productId === id) {
                    product = item;
                }
            });

            if(product){
                this.products.forEach((item) => {
                    if (item.id === id) {
                        item.quantity = IS.numeric(product.quantity) ? product.quantity : null;
                        item.subtotalOriginal = IS.numeric(product.originalSubtotal) ? product.originalSubtotal : null;
                        item.subtotal = IS.numeric(product.subtotal) ? product.subtotal : null;
                        item.isAvailable = IS.true(product.isValid) ? true : false;
                    }
                });
            }
        }
    }

    // HANDLERS
    handleChangeSort(event) {
        if (this.showSpinner || !this.showProducts) return;

        this.sort = event && event.detail && IS.stringNotEmpty(event.detail.value)
            ? event.detail.value
            : 'CreatedDate DESC';

        this.isUpdateLoading = true;
        this.getInitialData();
    }

    async handleClickRemove(event) {
        if (this.showSpinner || !this.showProducts) return;

        let id = event && event.detail && IS.stringNotEmpty(event.detail.id)
            ? event.detail.id
            : null;
        
        if (IS.stringNotEmpty(id)) {
            this.isUpdateLoading = true;

            let response = await UTILS.doRequest(deleteGuestCartItem, {
                cartId: UTILS.isGuest ? this.guestCartId : this.recordId,
                effectiveAccountId: this.effectiveAccountId,
                productId: id,
                sortOrder: this.sort,
                fieldSet: IS.stringNotEmpty(this.fieldsetApiName)
                    ? this.fieldsetApiName
                    : null
            });

            if (UTILS.responseSuccess(response)) {
                let data = UTILS.responseData(response);
                if (IS.objectNotEmpty(data)) {
                    this.updateCartIcon(data.cartData);
                    this.products = this.products.filter((item) => item.id !== id);
                    this.updateCartQuantity();
                    this.parseTotals(data.totals);
                    UTILS.showToast('success', LABELS.deleteProductSuccess);
                }
            } else {
                UTILS.showToast('error', LABELS.deleteProductError);
                await this.getInitialData();
            }

            this.isUpdateLoading = false;
        }
    }

    async handleChangeQuantity(event) {
        if (this.showSpinner || !this.showProducts) return;

        if (
            IS.stringNotEmpty(event.detail.id) &&
            IS.integer(event.detail.quantity)
        ) {
            this.isUpdateLoading = true;

            let validateCartProdResponse = await UTILS.doRequest(validateCartProductByCart,
                { cartId: UTILS.isGuest ? this.guestCartId : this.recordId, prodId: event.detail.id });
            
            if(validateCartProdResponse.isSuccess && validateCartProdResponse.responseData && this.processValidationResponse(validateCartProdResponse.responseData,event.detail.id )){
                this.products = this.products.filter(item => {
                    return item.id !=  event.detail.id;
                });
            }else{

                let response = await UTILS.doRequest(changeQtyGuestCartItem, {
                    cartId: UTILS.isGuest ? this.guestCartId : this.recordId,
                    effectiveAccountId: this.effectiveAccountId,
                    productId: event.detail.id,
                    quantity: event.detail.quantity,
                    sortOrder: this.sort,
                    fieldSet: IS.stringNotEmpty(this.fieldsetApiName)
                        ? this.fieldsetApiName
                        : null
                });
                let data = UTILS.responseData(response);

                if (IS.objectNotEmpty(data)) {
                    this.updateCartIcon(data.cartData);

                    this.updateCartItem(event.detail.id, data.items);
                    this.parseTotals(data.totals);
                    this.updateCartQuantity();

                    UTILS.showToast('success', LABELS.quantityUpdateSuccess);
                } else {
                    UTILS.showToast('error', LABELS.quantityUpdateError);
                    this.products.forEach((item) => {
                        if (item.id === event.detail.id) {
                            item.quantity = event.detail.oldQuantity;
                        }
                    });
                    setTimeout(() => {
                        this.getInitialData();
                    }, 0);
                }
            }

            this.isUpdateLoading = false;
        }
    }

    handleClickClearCart() {
        this.modal.show = true;
    }

    handleClickModalCancel() {
        this.modal.show = false;
    }

    async handleClickModalSubmit() {
        if (this.showSpinner || !this.showProducts) return;
        this.modal.show = false;
        this.isUpdateLoading = true;

        let response = await UTILS.doRequest(clearGuestCart, {
            cartId: UTILS.isGuest ? this.guestCartId : this.recordId,
            effectiveAccountId: this.effectiveAccountId
        });
        let data = UTILS.responseData(response);

        if (IS.objectNotEmpty(data)) {
            this.updateCartIcon(data.cartData);
            this.products = [];
            this.updateCartQuantity();
            this.parseTotals(data.totals);
            UTILS.showToast('success', LABELS.clearCartSuccess);
        } else {
            UTILS.showToast('error', LABELS.clearCartError);
            this.getInitialData();
        }

        this.isUpdateLoading = false;
    }

    processValidationResponse(records, prodId) {
        let result = records.find(item => item.Product2Id == prodId);
        return !!result;
    }

}