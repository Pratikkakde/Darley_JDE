import {LightningElement, track, wire} from 'lwc';
import _initCheckoutButton from '@salesforce/apex/B2BCheckoutController.initCheckoutButton';
import { UTILS } from 'c/b2bUtils';

import proceedToCheckout from '@salesforce/label/c.B2B_Proceed_to_Checkout';
import { CartItemsAdapter } from 'commerce/cartApi';

const LABELS = {
    proceedToCheckout: proceedToCheckout,
};
export default class B2BCheckoutButton extends LightningElement {

    @track labels = LABELS;
    @track isLoading = false;
    @track isButtonAvailable = false;

    @track sessionContext;
    @track isButtonDisabled = true;
    @track cartItemsSize = 0;
    communityURL;

    @wire(CartItemsAdapter)
    async cartItemsChange({ data, error }) {
        if (data && data.cartItems && data.cartSummary && data.cartSummary.cartId) {
            if (this.cartItemsSize !== data.cartItems.length) {
                this.cartItemsSize = data.cartItems.length;
                await this.initData(data.cartSummary.cartId, data.cartSummary.accountId);
            }
        } else if (error) {
            console.log(error);
        }
    }

    clickOnProceed(event) {
        if (this.isLoading || this.isButtonDisabled) {
            event.preventDefault();
        } else if (this.communityURL) {
            window.open(this.communityURL + '/checkout', '_self');
        }
    }

    async initData(cartId, accountId) {
        this.isLoading = true;
        let initResponse = await UTILS.doRequest(_initCheckoutButton, {
            'effectiveAccountId': accountId,
            'cartId': cartId
        });

        if (UTILS.responseSuccess(initResponse)) {
            this.isButtonAvailable = initResponse.responseData.isButtonAvailable;
            this.communityURL = initResponse.responseData.communityURL;
            this.isButtonDisabled = initResponse.responseData.isButtonDisabled;
        }
        this.isLoading = false;
    }

}