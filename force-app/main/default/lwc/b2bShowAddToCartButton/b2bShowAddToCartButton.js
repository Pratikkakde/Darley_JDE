import { LightningElement, track } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

export default class B2bShowAddToCartButton extends LightningElement {
    @track isFirstRender = true;
    @track customCssContainer = UTILS.customCssContainer;

    // LIFECYCLES
    renderedCallback() {
        if (this.isFirstRender) {
            this.isFirstRender = false;
            this.addCustomCssStyles();
        }
    }

    // METHODS
    addCustomCssStyles() {
        if (!IS.true(UTILS.isGuest)) {
            let styleText = `
                commerce_search-product-card commerce_product_details-add-to-cart-button,
                commerce_search-product-card commerce_search-call-to-action-anchor-button,
                commerce_search-product-card .callToActionArea,
                b2b_search_product_card-product-card b2b_buyer_cart-add-to-cart-button,
                b2b_search_product_card-product-card b2b_search_product_card-call-to-action-anchor-button,
                b2b_search_product_card-product-card .callToActionArea {
                    display: flex !important;
                    visibility: visible;
                    opacity: 1;
                }
            `;
            UTILS.addCustomCssStyles(this.template, styleText);
        }
    }

}