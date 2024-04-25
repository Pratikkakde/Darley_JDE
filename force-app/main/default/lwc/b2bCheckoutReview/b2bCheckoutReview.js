import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

//LABELS
import reviewItems from '@salesforce/label/c.B2B_Review_items';
import editCart from '@salesforce/label/c.B2B_Edit_cart';
import editCartTitle from '@salesforce/label/c.B2B_Click_to_go_to_the_art';
import sku from '@salesforce/label/c.B2B_SKU_Number';
import quantity from '@salesforce/label/c.B2B_Quantity';

// STATIC RESOURCE
import b2bImages from '@salesforce/resourceUrl/b2bImages';

const CURRENCY_ISO_CODE = 'USD';

const LABELS = {
    reviewItems: reviewItems,
    editCart: editCart,
    editCartTitle: editCartTitle,
    sku: sku,
    quantity: quantity
};

export default class B2bCheckoutReview extends LightningElement {
    @api recordId = null;
    @api products = [];
    @api isCartSecondary = false;
    @api showSubscription = false;
    @api isLoading;

    @track labels = LABELS;

    get getTitleLabel() {
        return 'Your Order';
    }

    get getCartLink() {
        return UTILS.link(`/cart`);
    }

    get getProductsOptions() {
        let result = [];
        if (IS.arrayNotEmpty(this.products)) {
            this.products.forEach((item) => {
                let newItem = {
                    id: IS.stringNotEmpty(item.id) ? item.id : null,
                    link: UTILS.link(`/product/${item.id}`),
                    image: IS.stringNotEmpty(item.image) ? (IS.url(item.image) ? item.image : 'shop/sfsites/c' + item.image) : null,
                    name: IS.stringNotEmpty(item.name) ? item.name : null,
                    title: null,
                    sku: IS.stringNotEmpty(item.sku) ? item.sku : null,
                    productVariant: IS.arrayNotEmpty(item.productVariant) ? item.productVariant : null,
                    price: IS.numeric(item.price) ? item.price : null,
                    originalPrice: IS.numeric(item.originalPrice) ? item.originalPrice : null,
                    currencyIsoCode: IS.numeric(item.currencyIsoCode) ? item.currencyIsoCode : CURRENCY_ISO_CODE,
                    quantity: IS.integer(item.quantity) ? item.quantity : null,
                };

                if (IS.stringNotEmpty(newItem.name)) {
                    newItem.title = `Click to open "${newItem.name}" Details`;
                } else {
                    newItem.title = 'Click to open Product Details';
                }

                if (
                    IS.stringNotEmpty(newItem.image)
                    && newItem.image.indexOf('default-product-image.svg') !== -1
                ) {
                    newItem.image = `${b2bImages}/default-product-image-light.png`;
                }

                if (
                    IS.stringNotEmpty(newItem.id) &&
                    IS.stringNotEmpty(newItem.name)
                ) {
                    result.push(newItem);
                }
            });
        }
        return result;
    }

//To use subscription functionality uncomment this part
//     handleSubscriptionValidity(event) {
//         UTILS.dispatchEvent(this, 'subscriptionvalidity', event.detail);
//     }
//-----------------------------------------------------
}