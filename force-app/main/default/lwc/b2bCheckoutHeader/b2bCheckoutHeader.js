import { LightningElement, track } from 'lwc';
import { UTILS, IS, DISPATCHER } from 'c/b2bUtils';

// TODO: Try to use following
// import { CartSummaryAdapter } from 'commerce/cartApi';

const CHECKOUT_PAGE_ID = 'checkout_page';
const UPDATE_CHECKOUT_HEADER_EVENT = 'update_checkout_header';
const CART_ROUTE = '/cart';
const GUEST_CART_ROUTE = '/guest-cart';

export default class B2bCheckoutHeader extends LightningElement {
    @track recordId = null;
    @track isCartSecondary = false;

    // GETTERS
    get getHomeUrl() {
        return UTILS.link('/');
    }

    get getCartUrl() {
        if (UTILS.isGuest) {
            return UTILS.link(GUEST_CART_ROUTE);
        } else {
            if (IS.stringNotEmpty(this.recordId)) {
                return UTILS.link(CART_ROUTE);
            }
        }
        return null;
    }

    get showCartIcon() {
        return IS.stringNotEmpty(this.getCartUrl)
            && IS.false(this.isCartSecondary);
    }

    // LIFECYCLES
    connectedCallback() {
        if (
            !UTILS.isGuest &&
            IS.stringIncludes(window.location.pathname, '/checkout/')
        ) {
            let arr = window.location.pathname.split('/').reverse();
            if (arr[1] === 'checkout') {
                this.recordId = arr[0];
            }
        }
        DISPATCHER.registerListener(this, CHECKOUT_PAGE_ID, UPDATE_CHECKOUT_HEADER_EVENT, this.updateRecordId);
    }

    disconnectedCallback() {
        DISPATCHER.unregisterListener(CHECKOUT_PAGE_ID, UPDATE_CHECKOUT_HEADER_EVENT, this.updateRecordId);
    }

    // METHODS
    updateRecordId(data) {
        this.recordId = IS.stringNotEmpty(data.recordId)
            ? data.recordId
            : null;

        this.isCartSecondary = IS.true(data.isCartSecondary);
    }

}