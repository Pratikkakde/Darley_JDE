import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { UTILS, IS, STORAGE, DISPATCHER } from 'c/b2bUtils';

// METHODS
import getFeaturedProducts from '@salesforce/apex/B2BFeaturedProductsController.getProducts';
import addToCart from '@salesforce/apex/B2BGuestCartController.addToCart';

// LABELS
import B2B_Featured_Products_Title from '@salesforce/label/c.B2B_Featured_Products_Title';
import B2B_Featured_Products_Add_To_Cart_Success from '@salesforce/label/c.B2B_Featured_Products_Add_To_Cart_Success';
import B2B_Featured_Products_Add_To_Cart_Error from '@salesforce/label/c.B2B_Featured_Products_Add_To_Cart_Error';
import B2B_Guest_Add_To_Cart_Adding_Success from '@salesforce/label/c.B2B_Guest_Add_To_Cart_Adding_Success';
import B2B_Guest_Add_To_Cart_Adding_Warning from '@salesforce/label/c.B2B_Guest_Add_To_Cart_Adding_Warning';
import B2B_Guest_Add_To_Cart_Adding_Error from '@salesforce/label/c.B2B_Guest_Add_To_Cart_Adding_Error';
import B2B_Guest_Add_To_Cart_Adding_Limit from '@salesforce/label/c.B2B_Guest_Add_To_Cart_Adding_Limit';

const LABELS = {
    title: B2B_Featured_Products_Title,
    addToCartSuccess: B2B_Featured_Products_Add_To_Cart_Success,
    addToCartError: B2B_Featured_Products_Add_To_Cart_Error,
    addingSuccess: 'The product was added to your cart.',
    addingWarning: B2B_Guest_Add_To_Cart_Adding_Warning,
    addingError: B2B_Guest_Add_To_Cart_Adding_Error,
    addingLimt: B2B_Guest_Add_To_Cart_Adding_Limit,
};

const MAX_PRODUCTS = 20;
const GUEST_CART_ICON_ID = 'b2b-guest-cart-icon';
const UPDATE_CART = 'update_cart';

export default class B2bFeaturedProducts extends NavigationMixin(LightningElement) {
    @api showSku = null;

    @track effectiveAccountId = null;
    @track isLoading = true;
    @track labels = LABELS;
    @track showArrows = true;
    @track showSlicks = true;
    @track products = [];

    // GETTERS
    get showComponent() {
        return !this.isLoading
            && IS.arrayNotEmpty(this.products);
    }

    // LIFECYCLES
    async connectedCallback() {
        this.effectiveAccountId = await UTILS.getEffectiveAccountId();
        this.getInitialData();
    }

    // METHODS
    async getInitialData() {
        if (!IS.stringNotEmpty(this.effectiveAccountId)) {
            return;
        }

        let response = await UTILS.doRequest(getFeaturedProducts, {
            effectiveAccountId: this.effectiveAccountId,
            isGuest: UTILS.isGuest
        });

        if (UTILS.responseSuccess(response)) {
            this.parseResponse(UTILS.responseData(response));
        }

        this.isLoading = false;
    }

    parseResponse(data) {
        let result = [];
        if (IS.arrayNotEmpty(data)) {
            data.forEach((item) => {
                let newItem = {
                    id: IS.stringNotEmpty(item.id) ? item.id : null,
                    isParent: IS.true(item.isParent) ? true : false,
                    name: IS.stringNotEmpty(item.name) ? item.name : null,
                    minQuantity: IS.numeric(item.minQuantity) ? item.minQuantity : UTILS.quantityMin,
                    sku: IS.true(this.showSku) && IS.stringNotEmpty(item.code)
                        ? item.code
                        : null,
                    image: IS.stringNotEmpty(item.imageUrl) ? item.imageUrl : null,
                    price: IS.false(item.isParent) && IS.numeric(item.price)
                        ? item.price
                        : null,
                    currencyIsoCode: IS.stringNotEmpty(item.currencyIsoCode) ? item.currencyIsoCode : null,
                    isAvailable: !UTILS.isGuest,
                    isLoading: false,
                    isQuoteOnly: IS.true(item.isQuoteOnly) ? true : false
                };

                if (
                    IS.stringNotEmpty(newItem.id) &&
                    IS.stringNotEmpty(newItem.name)
                ) {
                    result.push(newItem);
                }
            });
        }
        this.products = result.slice(0, MAX_PRODUCTS);
    }

    setProductLoading(id, isLoading) {
        if (IS.arrayNotEmpty(this.products)) {
            this.products.forEach((item) => {
                if (item.id === id) {
                    item.isLoading = isLoading;
                }
            });
        }
    }

    // HANDLERS
    async handleClickAction(event) {
        let product = event.detail;
        if (IS.objectNotEmpty(product)) {
            if (product.isParent) {
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: UTILS.link(`/product/${product.id}`)
                    }
                });

            } else if (UTILS.isGuest) {
                if (!IS.true(product.isLoading)) {
                    this.setProductLoading(product.id, true);
                    let cartId = STORAGE.getGuestCartId();
                    let response = await UTILS.doRequest(addToCart, {
                        productInfo: JSON.stringify({
                            productId: product.id,
                            quantity: product.minQuantity,
                            addToQuantity: true,
                            maxQty: null
                        }),
                        effectiveAccountId: this.effectiveAccountId,
                        cartId
                    });

                    if (UTILS.responseSuccess(response)) {
                        let data = UTILS.responseData(response);
                        if (IS.objectNotEmpty(data)) {
                            if (IS.stringNotEmpty(data.guestCartId)) {
                                STORAGE.setGuestCartId(data.guestCartId);
                            }
                            if (data.showWarning) {
                                UTILS.showToast('warning', LABELS.addingWarning);
                            } else {
                                UTILS.showToast('success', LABELS.addingSuccess);
                            }
                        }
                    } else {
                        if (
                            IS.stringNotEmpty(response.responseMessage) &&
                            IS.stringIncludes(response.responseMessage, 'MAX_LIMIT_EXCEEDED')
                        ) {
                            UTILS.showToast('warning', LABELS.addingLimt);
                        } else {
                            console.error(response);
                            UTILS.showToast('error', LABELS.addingError);
                        }
                    }
                    DISPATCHER.fireEvent(GUEST_CART_ICON_ID, UPDATE_CART, null);
                    this.setProductLoading(product.id, false);
                }

            } else {
                if (!IS.true(product.isLoading)) {
                    this.setProductLoading(product.id, true);
                    let response = await UTILS.addItemToCart(product.id, product.minQuantity);
                    if (
                        IS.objectNotEmpty(response)
                        && IS.stringNotEmpty(response.cartId)
                        && IS.stringNotEmpty(response.cartItemId)
                    ) {
                        UTILS.showToast('success', LABELS.addToCartSuccess);
                    } else {
                        UTILS.showToast('error', LABELS.addToCartError);
                    }
                    this.setProductLoading(product.id, false);
                }
            }
        }
    }

}