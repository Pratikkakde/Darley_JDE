import { LightningElement, track, api, wire } from 'lwc';
import { UTILS, IS, DISPATCHER, STORAGE } from 'c/b2bUtils';
import { ProductAdapter } from 'commerce/productApi';

// LABELS
import B2B_Guest_Add_To_Cart_Input_Label from '@salesforce/label/c.B2B_Guest_Add_To_Cart_Input_Label';
import B2B_Guest_Add_To_Cart_Button_Label from '@salesforce/label/c.B2B_Guest_Add_To_Cart_Button_Label';
import B2B_Guest_Add_To_Cart_Rule_Min_Text from '@salesforce/label/c.B2B_Guest_Add_To_Cart_Rule_Min_Text';
import B2B_Guest_Add_To_Cart_Rule_Max_Text from '@salesforce/label/c.B2B_Guest_Add_To_Cart_Rule_Max_Text';
import B2B_Guest_Add_To_Cart_Rule_Increment_Text from '@salesforce/label/c.B2B_Guest_Add_To_Cart_Rule_Increment_Text';
import B2B_Guest_Add_To_Cart_Adding_Success from '@salesforce/label/c.B2B_Guest_Add_To_Cart_Adding_Success';
import B2B_Guest_Add_To_Cart_Adding_Warning from '@salesforce/label/c.B2B_Guest_Add_To_Cart_Adding_Warning';
import B2B_Guest_Add_To_Cart_Adding_Error from '@salesforce/label/c.B2B_Guest_Add_To_Cart_Adding_Error';
import B2B_Guest_Add_To_Cart_Adding_Limit from '@salesforce/label/c.B2B_Guest_Add_To_Cart_Adding_Limit';

const LABELS = {
    inputLabel: B2B_Guest_Add_To_Cart_Input_Label,
    buttonLabel: B2B_Guest_Add_To_Cart_Button_Label,
    ruleMinText: B2B_Guest_Add_To_Cart_Rule_Min_Text,
    ruleMaxText: B2B_Guest_Add_To_Cart_Rule_Max_Text,
    ruleIncrementText: B2B_Guest_Add_To_Cart_Rule_Increment_Text,
    addingSuccess: B2B_Guest_Add_To_Cart_Adding_Success,
    addingWarning: B2B_Guest_Add_To_Cart_Adding_Warning,
    addingError: B2B_Guest_Add_To_Cart_Adding_Error,
    addingLimt: B2B_Guest_Add_To_Cart_Adding_Limit,
};

// METHODS
import getProductQtyDetails from '@salesforce/apex/B2BGuestCartController.getProductQtyDetails';
import addToCart from '@salesforce/apex/B2BGuestCartController.addToCart';

const COMPONENT_NAME = 'b2b-guest-add-to-cart';
const GUEST_CART_ICON_ID = 'b2b-guest-cart-icon';
const UPDATE_CART = 'update_cart';
const VARIATION_PARENT = 'VariationParent';

export default class B2bGuestAddToCart extends LightningElement {
    @api recordId = null;

    @wire(ProductAdapter, {'productId': '$recordId'})
    async wiredProductAdapter(result) {
        if (
            IS.objectNotEmpty(result.data)
            && IS.stringNotEmpty(result.data.productClass)
        ) {
            this.productClass = result.data.productClass;
        }
    }

    @track productClass = null;
    @track effectiveAccountId = null;
    @track isLoading = true;
    @track isUpdateLoading = false;
    @track isFirstRender = true;
    @track labels = LABELS;
    @track customCssContainer = UTILS.customCssContainer;
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);
    @track editable = true;
    @track required = true;
    @track increment = null;
    @track min = null;
    @track max = null;
    @track quantity = null;

    // GETTERS
    get showComponent() {
        return UTILS.isGuest;
    }

    get ruletext() {
        let result = [];
        if (IS.numeric(this.min)) {
            result.push(UTILS.prepareLabel(LABELS.ruleMinText, [this.min]));
        }
        if (IS.numeric(this.max)) {
            result.push(UTILS.prepareLabel(LABELS.ruleMaxText, [this.max]));
        }
        if (IS.numeric(this.increment)) {
            result.push(UTILS.prepareLabel(LABELS.ruleIncrementText, [this.increment]));
        }
        return IS.arrayNotEmpty(result) ? result.join('\r\n') : null;
    }

    get isParent() {
        return IS.stringNotEmpty(this.productClass)
            && this.productClass === VARIATION_PARENT;
    }

    get isQuantityDisabled() {
        return !IS.stringNotEmpty(this.productClass)
            || this.isParent
            || this.isLoading
            || this.isUpdateLoading;
    }

    get isQuantityValid() {
        let min = IS.numeric(this.min) ? this.min : UTILS.quantityMin;
        let max = IS.numeric(this.max) ? this.max : UTILS.quantityMax;
        return IS.numeric(this.quantity) &&
            this.quantity >= min &&
            this.quantity <= max;
    }

    get isAddToCartDisabled() {
        return !IS.stringNotEmpty(this.productClass)
            || this.isParent
            || this.isQuantityDisabled
            || !this.isQuantityValid
            || !IS.numeric(this.quantity);
    }

    // LIFECYCLE
    async connectedCallback() {
        this.effectiveAccountId = await UTILS.getEffectiveAccountId();
        if (this.showComponent) {
            this.getInitialData();
        }
    }

    renderedCallback() {
        if (this.isFirstRender) {
            this.isFirstRender = false;
            this.addCustomCssStyles();
        }
    }

    // METHODS
    addCustomCssStyles() {
        if (this.showComponent) {
            let styleText = `
                /* Hide standart "Add to Cart" form */
                c-b2b-wrapper-sidebar .b2b-wrapper-sidebar__sidebar c-b2b-guest-add-to-cart + c-b2b-wrapper-sidebar {
                    display: none !important;
                }

                commerce_builder-purchase-options div.commerce_builder-purchaseOptions_purchaseOptions.quantity-list-container {
                    display: none !important;
                }

                /* FRONT QUANTITY */
                c-b2b-quantity .slds-required {
                    display: none;
                }

                .${COMPONENT_NAME}__button .slds-button {
                    padding-left: 32px;
                    padding-right: 32px;
                    line-height: 38px;
                    transition: color 0.1s, border-color 0.1s, background-color 0.1s;
                }
            `;

            UTILS.addCustomCssStyles(this.template, styleText);
        }
    }

    async getInitialData() {
        let response = await UTILS.doRequest(getProductQtyDetails, {
            productIds: [this.recordId]
        });
        let data = UTILS.responseData(response);

        if (IS.arrayNotEmpty(data) && data.length === 1) {
            this.parseResponse(data[0]);
        } else {
            this.parseResponse(null);
        }
        this.isLoading = false;
    }

    parseResponse(data) {
        if (IS.objectNotEmpty(data)) {
            if (IS.objectNotEmpty(data.qtyRule)) {
                this.min = IS.numeric(data.qtyRule.min)
                    ? data.qtyRule.min
                    : null;
                this.max = IS.numeric(data.qtyRule.max)
                    ? data.qtyRule.max
                    : null;
                this.increment = IS.numeric(data.qtyRule.inc)
                    ? data.qtyRule.inc
                    : null;
            }
        }
        this.quantity = IS.numeric(this.min) ? this.min : 1;
    }

    // HANDLERS
    handleChangeQuantity(event) {
        this.quantity = event.detail.value;
    }

    async handleClickAddToCart() {
        if (
            !this.showComponent ||
            this.isAddToCartDisabled
        ) return;

        this.isUpdateLoading = true;

        let cartId = STORAGE.getGuestCartId();
        let response = await UTILS.doRequest(addToCart, {
            productInfo: JSON.stringify({
                productId: this.recordId,
                quantity: this.quantity,
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
        this.isUpdateLoading = false;
    }

}