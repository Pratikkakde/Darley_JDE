import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

// LABELS
import B2B_Guest_Cart_Item_Click_To_Open_Detail from '@salesforce/label/c.B2B_Guest_Cart_Item_Click_To_Open_Detail';
import B2B_Guest_Cart_Item_Click_To_Delete from '@salesforce/label/c.B2B_Guest_Cart_Item_Click_To_Delete';
import B2B_Guest_Cart_Item_Not_Available from '@salesforce/label/c.B2B_Guest_Cart_Item_Not_Available';
import B2B_Guest_Cart_Item_Sku from '@salesforce/label/c.B2B_Guest_Cart_Item_Sku';
import B2B_Guest_Cart_Item_Price_Per_Unit from '@salesforce/label/c.B2B_Guest_Cart_Item_Price_Per_Unit';
import B2B_Guest_Cart_Item_Qty from '@salesforce/label/c.B2B_Guest_Cart_Item_Qty';
import B2B_Guest_Cart_Item_Cart_Item_Unavailable from '@salesforce/label/c.B2B_Guest_Cart_Item_Cart_Item_Unavailable';
import B2B_Guest_Cart_Item_Item_Label from '@salesforce/label/c.B2B_Guest_Cart_Item_Item_Label';
import B2B_Guest_Cart_Item_Saved from '@salesforce/label/c.B2B_Guest_Cart_Item_Saved';
import B2B_Guest_Cart_Item_Rule_Min_Text from '@salesforce/label/c.B2B_Guest_Cart_Item_Rule_Min_Text';
import B2B_Guest_Cart_Item_Rule_Max_Text from '@salesforce/label/c.B2B_Guest_Cart_Item_Rule_Max_Text';
import B2B_Guest_Cart_Item_Rule_Increment_Text from '@salesforce/label/c.B2B_Guest_Cart_Item_Rule_Increment_Text';
import B2B_Guest_Cart_Item_Promotions_Label from '@salesforce/label/c.B2B_Guest_Cart_Item_Promotions_Label';
import B2B_Guest_Cart_Item_Promotions_Title from '@salesforce/label/c.B2B_Guest_Cart_Item_Promotions_Title';
import B2B_Guest_Cart_Item_Terms_Title from '@salesforce/label/c.B2B_Guest_Cart_Item_Terms_Title';
import B2B_Guest_Cart_Item_Delete from '@salesforce/label/c.B2B_Guest_Cart_Item_Delete';

const LABELS = {
    clickToOpenDetail: B2B_Guest_Cart_Item_Click_To_Open_Detail,
    clickToDelete: B2B_Guest_Cart_Item_Click_To_Delete,
    na: B2B_Guest_Cart_Item_Not_Available,
    sku: B2B_Guest_Cart_Item_Sku,
    pricePerUnit: B2B_Guest_Cart_Item_Price_Per_Unit,
    qty: B2B_Guest_Cart_Item_Qty,
    cartItemUnavailable: B2B_Guest_Cart_Item_Cart_Item_Unavailable,
    itemLabel: B2B_Guest_Cart_Item_Item_Label,
    saved: B2B_Guest_Cart_Item_Saved,
    ruleMinText: B2B_Guest_Cart_Item_Rule_Min_Text,
    ruleMaxText: B2B_Guest_Cart_Item_Rule_Max_Text,
    ruleIncrementText: B2B_Guest_Cart_Item_Rule_Increment_Text,
    promotionsLabel: B2B_Guest_Cart_Item_Promotions_Label,
    promotionsTitle: B2B_Guest_Cart_Item_Promotions_Title,
    termsTitle: B2B_Guest_Cart_Item_Terms_Title,
    delete: B2B_Guest_Cart_Item_Delete
};

const COMPONENT_NAME = 'b2b-guest-cart-item';
const CHANGEQUANTITY_EVENT = 'changequantity';
const REMOVE_EVENT = 'remove';

export default class B2bGuestCartItem extends LightningElement {
    @api isUpdating = false;
    @api product = null;
    @api currencyIsoCode = null;

    @track labels = LABELS;
    @track customCssContainer = UTILS.customCssContainer;
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);
    @track editable = true;
    @track required = true;
    @track oldQuantity = null;
    @track showTermsAndConditions = false;

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper}`;
    }

    get showComponent() {
        return IS.objectNotEmpty(this.product) &&
            IS.stringNotEmpty(this.product.id);
    }

    get productId() {
        return this.showComponent ? this.product.id : null;
    }

    get href() {
        return this.showComponent ? UTILS.link(`/product/${this.product.id}`) : null;
    }

    get title() {
        return UTILS.prepareLabel(LABELS.clickToOpenDetail, [this.name]);
    }

    get name() {
        if (this.showComponent && IS.stringNotEmpty(this.product.name)) {
            return this.product.name;
        }
        return null;
    }

    get image() {
        if (this.showComponent && IS.stringNotEmpty(this.product.image)) {
            return UTILS.cmsImage(this.product.image);
        }
        return null;
    }

    get sku() {
        return this.showComponent &&
            IS.stringNotEmpty(this.product.sku)
                ? this.product.sku
                : LABELS.na;
    }

    get showPrice() {
        return IS.numeric(this.price);
    }

    get price() {
        if (this.showComponent && IS.numeric(this.product.price)) {
            return this.product.price;
        }
        return null;
    }

    get showPriceOriginal() {
        return IS.numeric(this.priceOriginal);
    }

    get priceOriginal() {
        if (this.showComponent && IS.numeric(this.product.priceOriginal)) {
            return this.product.priceOriginal;
        }
        return null;
    }

    get variationOptions() {
        let result = [];
        if (this.showComponent && IS.arrayNotEmpty(this.product.variations)) {
            result = UTILS.parseOptions(this.product.variations);
        }
        return result;
    }

    get fieldsOptions() {
        let result = [];
        if (this.showComponent && IS.arrayNotEmpty(this.product.fields)) {
            result = UTILS.parseOptions(this.product.fields);
        }
        return result;
    }

    get quantity() {
        if (this.showComponent && IS.numeric(this.product.quantity)) {
            return this.product.quantity;
        }
        return null;
    }

    get isQuantityRuleExists() {
        if (
            this.showComponent &&
            IS.objectNotEmpty(this.product.quantityRule) &&
            (
                IS.numeric(this.product.quantityRule.min) ||
                IS.numeric(this.product.quantityRule.max) ||
                IS.numeric(this.product.quantityRule.increment)
            )
        ) {
            return true;
        }
        return false;
    }

    get isQuantityDisabled() {
        return this.isUpdating ||
            !this.isAvailable;
    }

    get min() {
        if (this.isQuantityRuleExists && IS.numeric(this.product.quantityRule.min)) {
            return this.product.quantityRule.min;
        }
        return null;
    }

    get max() {
        if (this.isQuantityRuleExists && IS.numeric(this.product.quantityRule.max)) {
            return this.product.quantityRule.max;
        }
        return null;
    }

    get increment() {
        if (this.isQuantityRuleExists && IS.numeric(this.product.quantityRule.increment)) {
            return this.product.quantityRule.increment;
        }
        return null;
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

    get showPromotion() {
        return IS.true(this.product.showPromotion);
    }

    get discountAmount() {
        return this.product.discountAmount * -1;
    }

    get showSubtotalOriginal() {
        return IS.numeric(this.subtotalOriginal)
            && this.showSubtotal
            && this.subtotal !== this.subtotalOriginal;
    }

    get subtotalOriginal() {
        if (this.showComponent && IS.numeric(this.product.subtotalOriginal)) {
            return this.product.subtotalOriginal;
        }
        return null;
    }

    get showSubtotal() {
        return IS.numeric(this.subtotal);
    }

    get subtotal() {
        if (this.showComponent && IS.numeric(this.product.subtotal)) {
            return this.product.subtotal;
        }
        return null;
    }

    get getUnavailableMessage() {
        return UTILS.prepareLabel(LABELS.cartItemUnavailable, [LABELS.itemLabel]);
    }

    get getRemoveTitle() {
        return UTILS.prepareLabel(LABELS.clickToDelete, [this.name]);
    }

    get isAvailable() {
        return this.showComponent && IS.true(this.product.isAvailable);
    }

    // LIFECYCLES
    connectedCallback() {
        this.oldQuantity = this.quantity;
    }

    // HANDLERS
    handleChangeQuantity(event) {
        let quantity = event.detail.value;
        if (
            IS.stringNotEmpty(this.productId) &&
            IS.integer(quantity) &&
            quantity !== this.oldQuantity
        ) {
            UTILS.dispatchEvent(this, CHANGEQUANTITY_EVENT, {
                id: this.productId,
                quantity,
                oldQuantity: this.oldQuantity,
            });
            this.oldQuantity = quantity;
        }
    }

    handleClickRemove() {
        if (IS.stringNotEmpty(this.productId)) {
            UTILS.dispatchEvent(this, REMOVE_EVENT, {
                id: this.productId
            });
        }
    }

    handleExpandTermsAndConditions() {
        this.showTermsAndConditions = !this.showTermsAndConditions;
    }

}