import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

// LABELS
import B2B_Product_Card_Loading from '@salesforce/label/c.B2B_Product_Card_Loading';
import B2B_Product_Card_Link_Title from '@salesforce/label/c.B2B_Product_Card_Link_Title';
import B2B_Product_Card_Sku from '@salesforce/label/c.B2B_Product_Card_Sku';
import B2B_Product_Card_Add_To_Cart from '@salesforce/label/c.B2B_Product_Card_Add_To_Cart';
import B2B_Product_Card_View_Options from '@salesforce/label/c.B2B_Product_Card_View_Options';
import B2B_Product_Card_Price_Unavailable from '@salesforce/label/c.B2B_Product_Card_Price_Unavailable';

const LABELS = {
    loading: B2B_Product_Card_Loading,
    linkTitle: B2B_Product_Card_Link_Title,
    sku: B2B_Product_Card_Sku,
    addToCart: B2B_Product_Card_Add_To_Cart,
    viewOptions: B2B_Product_Card_View_Options,
    priceUnavailable: B2B_Product_Card_Price_Unavailable,
};

const ACTION = 'action';
const LIST_OF_TARGETS = ['_self', '_blank'];

export default class B2bProductCard extends LightningElement {
    @api product = null;
    @api linkTarget = null;
    @api featuredProduct = null;

    @track labels = LABELS;

    // GETTERS
    get showComponent() {
        return IS.objectNotEmpty(this.product)
            && IS.stringNotEmpty(this.product.id)
            && IS.stringNotEmpty(this.product.name);
    }

    get getLink() {
        return this.showComponent
            ? UTILS.link(`/product/${this.product.id}`)
            : null;
    }

    get getTitle() {
        return this.showComponent
            ? UTILS.prepareLabel(LABELS.linkTitle, [this.product.name])
            : null;
    }

    get getLinkTarget() {
        return this.showComponent
            && IS.stringNotEmpty(this.linkTarget)
            && IS.arrayIncludes(LIST_OF_TARGETS, this.linkTarget)
                ? this.linkTarget
                : LIST_OF_TARGETS[0];
    }

    get getImage() {
        return this.showComponent
            && IS.stringNotEmpty(this.product.image)
                ? UTILS.cmsImage(this.product.image)
                : null;
    }

    get getName() {
        return this.showComponent
            ? this.product.name
            : null;
    }

    get getSku() {
        return this.showComponent
            && IS.false(this.product.isParent)
            && IS.stringNotEmpty(this.product.sku)
                ? this.product.sku
                : null;
    }

    get showPrice() {
        return this.showComponent
            && IS.false(this.product.isParent)
            && IS.numeric(this.product.price);
    }

    get showPriceUnavailable() {
        if (this.featuredProduct && this.product.isQuoteOnly) {
            return false
        }

        return IS.false(this.product.isParent)
            && IS.false(this.showPrice);
    }

    get getPrice() {
        return this.showPrice
            ? this.product.price
            : null;
    }

    get getCurrencyIsoCode() {
        return this.showPrice
            && IS.stringNotEmpty(this.product.currencyIsoCode)
                ? this.product.currencyIsoCode
                : UTILS.currencyIsoCode;
    }

    get getButtonLabel() {
        return this.showComponent
            && IS.true(this.product.isParent)
                ? LABELS.viewOptions
                : LABELS.addToCart;
    }

    get isButtonDisabled() {
        if (IS.true(this.product.isLoading)) {
            return true;
        }

        if (this.featuredProduct && this.product.isQuoteOnly) {
            return false;
        }

        return IS.true(this.product.isParent)
            || this.showPrice
                ? null
                : true;
    }

    // HANDLERS
    handleClickButton() {
        UTILS.dispatchEvent(this, ACTION, JSON.parse(JSON.stringify(this.product)));
    }

}