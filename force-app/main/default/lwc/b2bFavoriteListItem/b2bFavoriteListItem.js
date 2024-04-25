import { LightningElement, track, api, wire } from 'lwc';
import { ProductAdapter, ProductPricingAdapter } from 'commerce/productApi';
import { UTILS, IS } from 'c/b2bUtils';

// METHODS
import deleteFavoriteListItems from '@salesforce/apex/B2BFavoriteListDetailController.deleteFavoriteListItems';

const LABELS = {
    loading: 'Loading',
    sku: 'SKU',
    priceUnavailable: 'Price Unavailable',
    clickToOpen: 'Click to open "{0}" details',
    itemUnavailable: 'This item is no longer available. Click {0} to remove the item.',
    itemCannotAdded: 'This item cannot be added to the cart.',
    addProductSuccess: 'The product was added to your cart.',
    addProductError: 'The product was not added to the cart. Try again later.',
    limitExceeded: 'The cart is full (max 500 items). Please checkout before adding more items.',
    removeSuccess: 'The product was successfully removed',
    removeError: 'The product has not been removed',
    deleteTitle: 'Delete "{0}"?',
    cancel: 'Cancel',
    delete: 'Delete',
    addToCart: 'Add to Cart',
    quoteInfoMessage: 'Add to the cart, then request a quote for pricing',
};

const VARIATION_PARENT = 'VariationParent';
const AVAILABLE_EVENT = 'available';
const UPDATE_LOADING_EVENT = 'updateloading';
const REMOVE_EVENT = 'remove';
const LIMIT_EXCEEDED = 'LIMIT_EXCEEDED';

export default class B2bFavoriteListItem extends LightningElement {
    @api isUpdateLoading = false;
    @api item = null;
    @api showOriginalPrice = false;

    @track isFirstRender = true;
    @track labels = LABELS;
    @track isProductAdapterLoaded = false;
    @track isProductPricingAdapterLoaded = false;
    @track isModalLoading = false;

    @track innerWidth = window.innerWidth;
    @track productClass = null;
    @track image = null;
    @track name = null;
    @track sku = null;
    @track variationAttributeSet = [];
    @track quantity = UTILS.quantityMin;
    @track currencyIsoCode = UTILS.currencyIsoCode;
    @track unitPrice = null;
    @track listPrice = null;

    // GETTERS
    get isMobileView() {
        return IS.numeric(this.innerWidth) && this.innerWidth < 768;
    }

    get isLoaded() {
        return this.isProductAdapterLoaded
            && this.isProductPricingAdapterLoaded;
    }

    get showSpinner() {
        return !this.isLoaded
            || this.item.isUpdateLoading;
    }
    
    get isParent() {
        return IS.stringNotEmpty(this.productClass)
            && this.productClass === VARIATION_PARENT;
    }

    get getName() {
        return IS.stringNotEmpty(this.name) ? this.name : this.item.productName;
    }

    get getProductLink() {
        return UTILS.link(`/product/${this.item.productId}`);
    }

    get getProductTitle() {
        return UTILS.prepareLabel(LABELS.clickToOpen, [this.getName]);
    }

    get showPrice() {
        return this.isLoaded
            && this.item.isAvailable
            && !this.item.isQuoteOnly
            && (
                IS.numeric(this.unitPrice)
                || (this.showOriginalPrice && IS.numeric(this.listPrice))
            );
    }

    get showPriceUnavailable() {
        return this.isLoaded
            && this.item.isAvailable
            && !this.item.isQuoteOnly
            && !this.showPrice;
    }

    get isRemoveButtonDisabled() {
        return this.isUpdateLoading
            || !this.isLoaded
            || this.item.isUpdateLoading;
    }

    get isAddToCartButtonDisabled() {
        return this.isUpdateLoading
            || !this.isLoaded
            || this.item.isUpdateLoading
            || (!this.item.isAvailable && !this.item.isQuoteOnly)
            || this.isParent;
    }

    get showItemInfo() {
        return this.item.isAvailable
            && this.item.isQuoteOnly
            && !this.isParent;
    }

    get showItemError() {
        return !this.item.isAvailable
            || this.isParent;
    }

    get getItemUnavailableLabel() {
        return UTILS.prepareLabel(LABELS.itemUnavailable,
            this.isMobileView ? [LABELS.delete] : ['X']
        );
    }

    get getItemErrorMessage() {
        return this.showItemError && !this.item.isAvailable
            ? this.getItemUnavailableLabel
            : LABELS.itemCannotAdded;
    }

    // WIRES
    @wire(ProductAdapter, {
        // effectiveAccountId: '$effectiveAccountId', // Not supported
        // Added automatically when requested 
        productId: '$item.productId',
        // fields: ['Name', 'StockKeepingUnit'], // Not supported
        // excludeAttributeSetInfo: true, // Not supported
        // excludeEntitlementDetails: true, // Not supported
        // excludeFields: true, // Not supported
        // excludeMedia: true, // Not supported
        // excludePrimaryProductCategory: true, // Not supported
        // excludeProductSellingModels: true, // Not supported
        // excludeQuantityRule: true, // Not supported
        // excludeVariationInfo: true, // Not supported
    })
    productAdapterExecute({ data, error }) {
        if (IS.stringNotEmpty(this.item.productId) && (data || error)) {
            if (IS.objectNotEmpty(data)) {
                this.parseProduct(data);

            } else if (error) {
                UTILS.dispatchEvent(this, AVAILABLE_EVENT, {
                    id: this.item.id,
                    isAvailable: false
                });
            }
            this.isProductAdapterLoaded = true;
        }
    }

    @wire(ProductPricingAdapter, {
        // effectiveAccountId: '$effectiveAccountId', // Not supported
        // Added automatically when requested 
        productId: '$item.productId',
    })
    productPricingAdapterExecute({ data, error }) {
        if (IS.stringNotEmpty(this.item.productId) && (data || error)) {
            if (IS.objectNotEmpty(data)) {
                this.parseProductPricing(data);
            }
            this.isProductPricingAdapterLoaded = true;
        }
    }

    // LIFECYCLES
    renderedCallback() {
        if (this.isFirstRender) {
            this.isFirstRender = false;

            this._resizeEventListenerFunction = this.resizeEventListenerFunction.bind(this);
            window.addEventListener('resize', this._resizeEventListenerFunction);
        }
    }

    disconnectedCallback() {
        window.removeEventListener('resize', this._resizeEventListenerFunction, false);
    }

    // METHODS
    parseProduct(data) {
        if (IS.objectNotEmpty(data)) {
            this.productClass = IS.stringNotEmpty(data.productClass) ? data.productClass : null;

            if (IS.objectNotEmpty(data.defaultImage)) {
                this.image = IS.stringNotEmpty(data.defaultImage.url)
                    ? UTILS.cmsImage(data.defaultImage.url)
                    : null;
            }

            if (IS.objectNotEmpty(data.fields)) {
                this.name = IS.stringNotEmpty(data.fields.Name) ? data.fields.Name : null;
                this.sku = IS.stringNotEmpty(data.fields.StockKeepingUnit) ? data.fields.StockKeepingUnit : null;
            }

            if (
                IS.objectNotEmpty(data.purchaseQuantityRule)
                && IS.stringNotEmpty(data.purchaseQuantityRule.minimum)
                && IS.numeric(+data.purchaseQuantityRule.minimum)
            ) {
                this.quantity = +data.purchaseQuantityRule.minimum;
            }

            if (
                IS.objectNotEmpty(data.variationAttributeSet)
                && IS.objectNotEmpty(data.variationAttributeSet.attributes)
                && IS.stringNotEmpty(data.variationAttributeSet.developerName)
                && IS.objectNotEmpty(data.attributeSetInfo)
                && IS.objectProperty(data.attributeSetInfo, data.variationAttributeSet.developerName)
                && IS.objectNotEmpty(data.attributeSetInfo[data.variationAttributeSet.developerName].attributeInfo)
            ) {
                let attributeInfo = data.attributeSetInfo[data.variationAttributeSet.developerName].attributeInfo;
                let attributes = data.variationAttributeSet.attributes;
                for (let key in attributes) {
                    if (
                        IS.objectProperty(attributeInfo, key)
                        && IS.stringNotEmpty(attributeInfo[key].label)
                        && IS.stringNotEmpty(attributes[key])
                    ) {
                        this.variationAttributeSet.push({
                            label: attributeInfo[key].label,
                            value: attributes[key],
                        });
                    }
                }
            }
        }
    }

    parseProductPricing(data) {
        if (IS.objectNotEmpty(data)) {
            this.currencyIsoCode = IS.stringNotEmpty(data.currencyIsoCode) ? data.currencyIsoCode : UTILS.currencyIsoCode;
            this.unitPrice = IS.stringNotEmpty(data.unitPrice) && IS.numeric(+data.unitPrice)
                ? +data.unitPrice
                : null;
            this.listPrice = IS.stringNotEmpty(data.listPrice) && IS.numeric(+data.listPrice)
                ? +data.listPrice
                : null;
        }
    }

    resizeEventListenerFunction() {
        this.innerWidth = window.innerWidth;
    }

    // HANDLERS
    handleClickRemove() {
        let modal = this.template.querySelector('c-b2b-modal');
        if (this.isRemoveButtonDisabled || !modal) {
            return;
        }

        UTILS.dispatchEvent(this, UPDATE_LOADING_EVENT, {
            id: this.item.id,
            isUpdateLoading: true
        });

        modal.open({
            id: this.item.id,
            title: UTILS.prepareLabel(LABELS.deleteTitle, [this.getName]),
            buttonsAlign: 'full_width',
            closeLabel: LABELS.cancel,
            submitLabel: LABELS.delete,
        });
    }

    handleCloseModal() {
        UTILS.dispatchEvent(this, UPDATE_LOADING_EVENT, {
            id: this.item.id,
            isUpdateLoading: false
        });

        this.isModalLoading = false;
    }

    async handleSubmitModal(event) {
        let modal = this.template.querySelector('c-b2b-modal');
        if (
            modal
            && !this.isModalLoading
            && IS.objectNotEmpty(event.detail)
            && IS.stringNotEmpty(event.detail.id)
        ) {
            this.isModalLoading = true;

            let response = await UTILS.doRequest(deleteFavoriteListItems, {
                favoriteListItemIds: [event.detail.id]
            });
    
            if (UTILS.responseSuccess(response)) {
                UTILS.showToast('success',  LABELS.removeSuccess);
                UTILS.dispatchEvent(this, REMOVE_EVENT, {
                    id: event.detail.id,
                });

            } else {
                UTILS.showToast('error', LABELS.removeError);
            }
            modal.hide();
        }
        this.handleCloseModal();
    }

    async handleClickAdd() {
        if (this.isAddToCartButtonDisabled) {
            return;
        }

        UTILS.dispatchEvent(this, UPDATE_LOADING_EVENT, {
            id: this.item.id,
            isUpdateLoading: true
        });

        let response = await UTILS.addItemToCart2(this.item.productId, this.quantity);
        let data = UTILS.responseData(response);

        if (
            UTILS.responseSuccess(response)
            && IS.objectNotEmpty(data)
            && IS.stringNotEmpty(data.cartId)
            && IS.stringNotEmpty(data.cartItemId)
        ) {
            UTILS.showToast('success', LABELS.addProductSuccess);
        } else {
            if (IS.stringIncludes(JSON.stringify(response.responseData), LIMIT_EXCEEDED)) {
                UTILS.showToast('error', LABELS.limitExceeded);
            } else {
                UTILS.showToast('error', IS.stringNotEmpty(response.responseMessage)
                    ? response.responseMessage
                    : LABELS.addProductError
                );
            }
        }
        
        UTILS.dispatchEvent(this, UPDATE_LOADING_EVENT, {
            id: this.item.id,
            isUpdateLoading: false
        });
    }

}