import { LightningElement, track } from 'lwc';
import { UTILS, IS, STORAGE } from 'c/b2bUtils';

// METHODS
import getInitialGuestCart from '@salesforce/apex/B2BGuestCartController.getInitialGuestCart';
import clearGuestCart from '@salesforce/apex/B2BGuestCartController.clearGuestCart';

const LABELS = {
    addSuccess: 'Your products from the guest card have been successfully added'
};

export default class B2bGuestCartMerge extends LightningElement {
    @track effectiveAccountId = null;
    @track guestCartId = null;
    @track products = {};

    // LIFECYCLES
    async connectedCallback() {
        this.effectiveAccountId = await UTILS.getEffectiveAccountId();
        this.guestCartId = STORAGE.getGuestCartId();
        this.getInitialData();
    }

    // METHODS
    async getInitialData() {
        if (
            !UTILS.isGuest
            && IS.stringNotEmpty(this.effectiveAccountId)
            && IS.stringNotEmpty(this.guestCartId)
        ) {
            let response = await UTILS.doRequest(getInitialGuestCart, {
                cartId: this.guestCartId,
                effectiveAccountId: this.effectiveAccountId,
                sortOrder: null,
                fieldSet: null
            });
            if (UTILS.responseSuccess(response)) {
                this.parseResponse(UTILS.responseData(response));
                this.addProducts();
            }
        }
    }

    parseResponse(data) {
        if (
            IS.objectNotEmpty(data)
            && IS.arrayNotEmpty(data.items)
        ) {
            data.items.forEach((item) => {
                if (
                    IS.stringNotEmpty(item.productId)
                    && IS.integer(item.quantity)
                ) {
                    this.products[item.productId] = item.quantity;
                }
            });
        }
    }

    async addProducts() {
        if (IS.objectNotEmpty(this.products)) {
            let response = await UTILS.addItemsToCart(this.products);
            if (UTILS.responseSuccess(response)) {
                await UTILS.doRequest(clearGuestCart, {
                    cartId: this.guestCartId,
                    effectiveAccountId: this.effectiveAccountId,
                });
                UTILS.showToast('success', LABELS.addSuccess);
            }
        }
        STORAGE.clearGuestCartId();
        STORAGE.clearGuestCartIconItems();
        STORAGE.clearGuestCartIconProducts();
    }

}