import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

// LABELS
import B2B_Quick_Order_Search_Product_Placeholder from '@salesforce/label/c.B2B_Quick_Order_Search_Product_Placeholder';
import B2B_Quick_Order_Search_Product_Not_Found from '@salesforce/label/c.B2B_Quick_Order_Search_Product_Not_Found';
import B2B_Quick_Order_Search_Product_Sku_Label from '@salesforce/label/c.B2B_Quick_Order_Search_Product_Sku_Label';

const LABELS = {
    placeholder: B2B_Quick_Order_Search_Product_Placeholder,
    notFound: B2B_Quick_Order_Search_Product_Not_Found,
    skuLabel: B2B_Quick_Order_Search_Product_Sku_Label,
};

const COMPONENT_NAME = 'b2b-quick-order-search-product';
const CHANGE_EVENT = 'change';
const SELECT_EVENT = 'select';

export default class B2bQuickOrderSearchProduct extends LightningElement {
    @api itemId = null;
    @api isUpdateLoading = false;
    @api search = null;
    @api options = [];
    @api productId = null;
    @api productName = null;
    @api productSku = null;
    @api disabled = null;

    @track wrapper = UTILS.wrapper(COMPONENT_NAME);
    @track labels = LABELS;

    @track isShowOptions = false;
    @track isSearchFocusing = false;

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper}`;
    }

    get getSearchClass() {
        let result = 'slds-form-element';
        if (this.showError) {
            result += ' slds-has-error';
        }
        return result;
    }

    get isSearchValueValid() {
        let result = UTILS.prepareString(this.search);
        if (IS.stringNotEmpty(result)) {
            result = result.trim();
        }
        return IS.stringNotEmpty(result);
    }

    get showForm() {
        return !IS.stringNotEmpty(this.productId);
    }

    get showView() {
        return IS.stringNotEmpty(this.productId) &&
            IS.stringNotEmpty(this.productName) &&
            IS.stringNotEmpty(this.productSku);
    }

    get showError() {
        return !this.isUpdateLoading &&
            this.isSearchValueValid &&
            IS.arrayEmpty(this.options);
    }

    get showDropdown() {
        return !this.isUpdateLoading &&
            this.isSearchFocusing &&
            this.isSearchValueValid &&
            IS.arrayNotEmpty(this.options);
    }

    // HANDLERS
    handleFocusSearch() {
        this.isSearchFocusing = true;
    }

    handleFocusoutSearch() {
        this.isShowOptions = false;
        this.isSearchFocusing = false;
    }

    handleChangeSearch(event) {
        UTILS.dispatchEvent(this, CHANGE_EVENT, {
            itemId: this.itemId,
            value: event.target.value,
        });
    }

    handleClickDropdownItem(event) {
        if (IS.stringNotEmpty(event.currentTarget.dataset.id)) {
            this.isShowOptions = false;
            this.isSearchFocusing = false;

            UTILS.dispatchEvent(this, SELECT_EVENT, {
                itemId: this.itemId,
                selectedId: event.currentTarget.dataset.id,
            });
        }
    }

}