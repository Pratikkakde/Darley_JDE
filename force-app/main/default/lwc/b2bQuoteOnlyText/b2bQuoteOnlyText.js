import {LightningElement, track, wire} from 'lwc';

import _thereAreQuoteOnlyProducts from "@salesforce/apex/B2BValidateCartProductsController.thereAreQuoteOnlyProducts";

import { CartItemsAdapter } from 'commerce/cartApi';
import { UTILS } from 'c/b2bUtils';

export default class B2bQuoteOnlyText extends LightningElement {
    @track customCssContainer = UTILS.customCssContainer;
    @track cartItemsSize = 0;
    showQuoteOnlyText = null;

    @wire(CartItemsAdapter)
    async cartItemsChange({ data, error }) {
        if (data && data.cartItems && data.cartSummary && data.cartSummary.cartId) {
            if (this.cartItemsSize !== data.cartItems.length) {
                this.cartItemsSize = data.cartItems.length;
                this.showQuoteOnlyText = await _thereAreQuoteOnlyProducts({currentCartId: data.cartSummary.cartId});

                if (!this.showQuoteOnlyText) {
                    this.addCustomCssStyles()
                }
            }
        } else if (error) {
            this.showQuoteOnlyText = false;
            console.log(error);
        }
    }

    addCustomCssStyles() {
        let styleText = `
            commerce_builder-checkout-button button.slds-button_brand.commerce_cart-checkoutButton_checkoutButton {
                pointer-events: auto !important;
                border-color: rgb(35, 31, 32) !important;
                background-color: rgb(35, 31, 32) !important;
            }
            
            commerce_builder-checkout-button button.slds-button_brand.commerce_cart-checkoutButton_checkoutButton:hover {
                border-color: rgb(218, 41, 28) !important;
                background-color: rgb(218, 41, 28) !important;
            }
        `;

        UTILS.addCustomCssStyles(this.template, styleText);
    }

}