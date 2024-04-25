import { LightningElement, track, api, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { UTILS, IS, DISPATCHER, STORAGE } from 'c/b2bUtils';

// LABELS
import B2B_Guest_Cart_Icon_Button_Title from '@salesforce/label/c.B2B_Guest_Cart_Icon_Button_Title';
import B2B_Guest_Cart_Icon_Item_Label from '@salesforce/label/c.B2B_Guest_Cart_Icon_Item_Label';

const LABELS = {
    buttonTitle: B2B_Guest_Cart_Icon_Button_Title,
    itemLabel: B2B_Guest_Cart_Icon_Item_Label,
};

// METHODS
import getCartData from '@salesforce/apex/B2BGuestCartController.getCartData';

const COMPONENT_NAME = 'b2b-guest-cart-icon';
const GUEST_CART_ROUTE = '/guest-cart';
const GUEST_CART_PAGE_API_NAME = 'Guest_Cart__c';
const GUEST_CHECKOUT_PAGE_API_NAME = 'Guest_Checkout__c';
const GUEST_ORDER_CONFIRMATION_PAGE_API_NAME = 'Guest_Order_Confirmation__c';
const UPDATE_CART = 'update_cart';
const TOTAL_ITEMS_IN_CART = 'Total Items in Cart';
const TOTAL_PRODUCTS_IN_CART = 'Total Products in Cart';
const HIDDEN_ON_PAGES = [];

export default class B2bGuestCartIcon extends NavigationMixin(LightningElement) {
    @api effectiveAccountId = null;
    @api quantityType = null;
    @api buttonWidth = null;
    @api iconColor = null;
    @api iconColorHover = null;
    @api quantityColor = null;
    @api quantityBackgroundColor = null;

    @track guestCartId = null;
    @track currentPage = null;
    @track oldCurrentPage = null;
    @track isLoading = false;
    @track isLoaded = false;
    @track isFirstRender = true;
    @track customCssContainer = UTILS.customCssContainer;
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);

    @track quantity = null;

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        let newCurrentPage = null;
        if (
            IS.objectNotEmpty(currentPageReference) &&
            IS.objectNotEmpty(currentPageReference.attributes)
        ) {
            if (IS.stringNotEmpty(currentPageReference.attributes.name)) {
                newCurrentPage = currentPageReference.attributes.name;
            } else if (IS.stringNotEmpty(currentPageReference.attributes.recordId)) {
                newCurrentPage = currentPageReference.attributes.recordId;
            }

            if (!IS.stringNotEmpty(this.currentPage)) {
                this.currentPage = newCurrentPage;
            } else {
                this.oldCurrentPage = `${this.currentPage}`;
                this.currentPage = newCurrentPage;
            }

            this.guestCartId = STORAGE.getGuestCartId();
            if (
                IS.stringNotEmpty(this.currentPage) &&
                IS.stringNotEmpty(this.oldCurrentPage) &&
                this.currentPage !== GUEST_CART_PAGE_API_NAME &&
                !(
                    this.oldCurrentPage === GUEST_CHECKOUT_PAGE_API_NAME &&
                    this.currentPage === GUEST_ORDER_CONFIRMATION_PAGE_API_NAME
                )
            ) {
                this.updateCartQuantity();
            }
        }
    }

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper}`;
    }

    get showComponent() {
        return !this.isLoaded &&
            UTILS.isGuest &&
            !IS.arrayIncludes(HIDDEN_ON_PAGES, this.currentPage);
    }

    get getQuantity() {
        return IS.numeric(this.quantity) && this.quantity > 0
            ? this.quantity > 999 ? `+999` : this.quantity
            : null;
    }

    get getTitle() {
        return UTILS.prepareLabel(LABELS.buttonTitle, [LABELS.itemLabel]);
    }

    // LIFECYCLES
    connectedCallback() {
        if (this.showComponent) {
            let quantity = null;
            if (IS.stringNotEmpty(this.quantityType)) {
                if (this.quantityType === TOTAL_ITEMS_IN_CART) {
                    quantity = STORAGE.getGuestCartIconItems();
                } else if (this.quantityType === TOTAL_PRODUCTS_IN_CART) {
                    quantity = STORAGE.getGuestCartIconProducts();
                }
            }
            if (IS.numeric(+quantity)) {
                this.quantity = +quantity;
            }

            this.guestCartId = STORAGE.getGuestCartId();
            DISPATCHER.registerListener(this, COMPONENT_NAME, UPDATE_CART, this.updateCartQuantity);

            if (this.currentPage !== GUEST_CART_PAGE_API_NAME) {
                this.updateCartQuantity();
            }
        }
    }

    renderedCallback() {
        if (this.isFirstRender) {
            this.isFirstRender = false;
            this.addCustomCssStyles();
        }
    }

    disconnectedCallback() {
        DISPATCHER.unregisterListener(COMPONENT_NAME, UPDATE_CART, this.updateCartQuantity);
    }

    // METHODS

    addCustomCssStyles() {
        if (this.showComponent) {
            let styleText = `
                commerce_builder-cart-badge commerce_cart-badge .commerce_cart-badge_badge,
                commerce_builder-cart-badge commerce_cart-badge .cart-container {
                    visibility: hidden;
                    opacity: 0;
                }

                .${this.wrapper} {
                    --b2b-guest-cart-icon-button-width: ${this.buttonWidth}px;
                    --b2b-guest-cart-icon-icon-color: ${this.iconColor};
                    --b2b-guest-cart-icon-icon-color-hover: ${this.iconColorHover};
                    --b2b-guest-cart-icon-quantity-color: ${this.quantityColor};
                    --b2b-guest-cart-icon-quantity-background-color: ${this.quantityBackgroundColor};
                }
            `;

            UTILS.addCustomCssStyles(this.template, styleText);
        }

    }

    async updateCartQuantity(event) {
        if (this.isLoading) {
            return;
        }
        this.isLoading = true;

        let data = null;
        if (IS.objectNotEmpty(event)) {
            data = event;

        } else {
            let response = await UTILS.doRequest(getCartData, {
                effectiveAccountId: this.effectiveAccountId,
                cartId: this.guestCartId
            });

            if (UTILS.responseSuccess(response)) {
                data = UTILS.responseData(response);
            }
        }

        let cartProductsQuantity = null;
        let cartItemsQuantitySum = null;
        if (IS.objectNotEmpty(data)) {
            this.guestCartId = IS.stringNotEmpty(data.cartId) ? data.cartId : null;
            cartProductsQuantity = IS.numeric(+data.cartProductsQuantity)
                ? +data.cartProductsQuantity
                : null;
            cartItemsQuantitySum = IS.numeric(+data.cartItemsQuantitySum)
                ? +data.cartItemsQuantitySum
                : null;
        }

        if (IS.stringNotEmpty(this.guestCartId)) {
            STORAGE.setGuestCartId(this.guestCartId);
        } else {
            STORAGE.clearGuestCartId();
        }

        if (IS.numeric(cartItemsQuantitySum)) {
            STORAGE.setGuestCartIconItems(cartItemsQuantitySum);
        } else {
            STORAGE.clearGuestCartIconItems();
        }

        if (IS.numeric(cartProductsQuantity)) {
            STORAGE.setGuestCartIconProducts(cartProductsQuantity);
        } else {
            STORAGE.clearGuestCartIconProducts();
        }

        let quantity = null;
        if (IS.stringNotEmpty(this.quantityType)) {
            if (this.quantityType === TOTAL_ITEMS_IN_CART) {
                quantity = cartItemsQuantitySum;
            } else if (this.quantityType === TOTAL_PRODUCTS_IN_CART) {
                quantity = cartProductsQuantity;
            }
        }
        this.quantity = quantity;

        this.isLoaded = false;
        this.isLoading = false;
    }

    // HANDLERS
    handleClickButton() {
        if (this.showComponent) {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: UTILS.link(GUEST_CART_ROUTE)
                }
            }, true);
        }
    }

}