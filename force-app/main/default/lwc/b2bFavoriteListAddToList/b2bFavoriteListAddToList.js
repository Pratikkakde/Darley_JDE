import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ProductAdapter } from 'commerce/productApi';
import { UTILS, IS } from 'c/b2bUtils';

// METHODS
import getFavoriteList from '@salesforce/apex/B2BFavoriteListController.getFavoriteList';
import addFavoriteListItem from '@salesforce/apex/B2BFavoriteListAddController.addFavoriteListItem';

// LABELS
const LABELS = {
    loading: 'Loading',
    addToList: 'Add to List',
    item: 'item',
    items: 'items',
    modalTitle: 'Add To List',
    cancel: 'Cancel',
    add: 'Add',
    createList: 'Create a list',
    listName: 'List Name',
    requiredField: 'Enter a list name.',
    existingList: 'Add to existing list',
    favoriteLists: 'Favorite Lists',
    selectAList: 'Select a list',
    defaultName: 'My Favorite List',
    addSuccess: 'Added to list "{0}"',
    addAlreadyExist: 'The item was already in the list',
    addListFull: 'The list is full (max 100 items). Please clear the list to add your favorites.',
    addError: 'Failed to add to a list. Try again later.',
};

const MAX_LENGTH = {
    listName: 80,
};

const OBJECT_API_NAME = 'Product2';
const VARIATION_PARENT = 'VariationParent';
const CREATE = 'create';
const EXIST = 'exist';
const ALREADY_EXIST = 'ALREADY_EXIST';
const LIST_FULL = 'You reached your limit of Items (100).';

export default class B2bFavoriteListAddToCart extends LightningElement {
    @wire(CurrentPageReference)
    currentPageReferenceExecute(currentPageReference) {
        if (
            IS.objectNotEmpty(currentPageReference)
            && IS.objectNotEmpty(currentPageReference.attributes)
            && IS.stringNotEmpty(currentPageReference.attributes.objectApiName)
            && currentPageReference.attributes.objectApiName === OBJECT_API_NAME
            && IS.stringNotEmpty(currentPageReference.attributes.recordId)
        ) {
            this.productId = currentPageReference.attributes.recordId;
        }
    };

    @wire(ProductAdapter, {
        productId: '$productId',
    })
    productAdapterExecute({ data, error }) {
        if (IS.stringNotEmpty(this.productId) && (data || error)) {
            if (IS.objectNotEmpty(data)) {
                this.parseProduct(data);
            }
            this.isProductAdapterLoaded = true;
        }
    }

    @track labels = LABELS;
    @track maxLength = MAX_LENGTH;
    @track isLoading = true;
    @track isProductAdapterLoaded = false;
    @track isUpdateLoading = false;
    @track isModalLoading = false;
    @track isFirstRender = true;
    @track customCssContainer = UTILS.customCssContainer;
    @track productId = null;
    @track productClass = null;
    @track name = null;
    @track image = null;
    @track effectiveAccountId = null;
    @track type = null;
    @track listName = null;
    @track listNameWasBlur = false;
    @track listId = null;
    @track listOptions = [];
    @track listOptionsRequired = true;

    @track bulkIds = [];

    // GETTERS
    get showButton() {
        return !UTILS.isGuest;
    }

    get isButtonDisabled() {
        return this.isLoading
            || this.isUpdateLoading
            || !this.isProductAdapterLoaded
            || !IS.stringNotEmpty(this.productId)
            || !IS.stringNotEmpty(this.effectiveAccountId)
            || this.isParentProduct;
    }

    get isParentProduct() {
        return IS.stringNotEmpty(this.productClass)
            && this.productClass === VARIATION_PARENT;
    }

    get isListNameDisabled() {
        return this.isButtonDisabled
            || this.isModalLoading
            || this.type !== CREATE;
    }

    get isListsExist() {
        return !this.isLoading
            && IS.arrayNotEmpty(this.listOptions);
    }

    get isListOptionsDisabled() {
        return this.isButtonDisabled
            || this.isModalLoading
            || this.type !== EXIST;
    }

    get submitDisabled() {
        if (
            !this.isButtonDisabled
            && (
                (this.type === CREATE && IS.stringNotEmpty(this.listName))
                || (this.type === EXIST && IS.stringNotEmpty(this.listId))
            )
        ) {
            return false;
        }
        return true;
    }

    get getCurrentListName() {
        if (IS.stringNotEmpty(this.listId)) {
            return this.listOptions.filter((item) => item.value === this.listId)[0].name;
        }
        return null;
    }

    // LIFECYCLES
    async connectedCallback() {
        this.effectiveAccountId = await UTILS.getEffectiveAccountId();
        this.getInitialData();
    }

    renderedCallback() {
        if (this.isFirstRender) {
            this.isFirstRender = false;
            this.addCustomCssStyles();
        }
    }

    // METHODS
    addCustomCssStyles() {
        let styleText = `
            @media (max-width: 479.98px) {
                commerce_data_provider-product-data-provider commerce_builder-purchase-options .quantity-list-action {
                    margin-bottom: 0;
                }
            }

            commerce_builder-purchase-options .commerce_builder-purchaseOptions_purchaseOptions.quantity-rule {
                display: none;
            }

            commerce_product_details-add-to-cart-button .slds-button {
                padding: 0 10px;
            }

            commerce-quantity-selector {
                margin-right: 16px !important;
            }

            commerce-quantity-selector .number-input__decrement-button,
            commerce-quantity-selector .number-input__increment-button {
                padding-left: 6px !important;
                padding-right: 6px !important;
            }

            commerce-quantity-selector input.commerce-numberInput_numberInput {
                width: 70px !important;
                padding-left: 6px;
                padding-right: 6px;
            }

            .b2b-favorite-list-add-to-list__form lightning-input {
                margin-bottom: 0;
            }

            .b2b-favorite-list-add-to-list__form lightning-input .slds-form-element__label,
            .b2b-favorite-list-add-to-list__form lightning-input .slds-input,
            .b2b-favorite-list-add-to-list__form c-b2b-select .b2b-select__label {
                font-size: 12px;
            }

            .b2b-favorite-list-add-to-list__form lightning-input .slds-input[disabled] {
                color: var(--b2b-colorDisabledDark);
            }

            .b2b-favorite-list-add-to-list__form c-b2b-select option {
                font-size: 14px;
            }
        `;

        UTILS.addCustomCssStyles(this.template, styleText);
    }

    async getInitialData() {
        let response = await UTILS.doRequest(getFavoriteList, {
            effectiveAccountId: this.effectiveAccountId,
        });

        if (UTILS.responseSuccess(response)) {
            this.parseResponse(UTILS.responseData(response));
        }
        this.isLoading = false;
    }

    parseResponse(data) {
        let result = [];
        if (IS.arrayNotEmpty(data)) {

            // Sort by Created Date
            data.sort((a, b) => {
                if (a.createdDate < b.createdDate) return 1;
                else if (a.createdDate > b.createdDate) return -1;
                return 0;
            });

            // Generate options
            data.forEach((item) => {
                if (
                    IS.stringNotEmpty(item.id)
                    && IS.stringNotEmpty(item.name)
                ) {
                    let countOfRecords = IS.integer(item.countOfRecords) ? item.countOfRecords : 0;
                    let itemLabel = countOfRecords === 1 ? LABELS.item : LABELS.items;
                    result.push({
                        value: item.id,
                        label: `${item.name} (${countOfRecords} ${itemLabel})`,
                        count: countOfRecords,
                        name: item.name
                    });
                }
            });
        }
        this.listOptions = result;
    }

    parseProduct(data) {
        if (IS.objectNotEmpty(data)) {
            if (IS.objectNotEmpty(data.fields)) {
                this.name = IS.stringNotEmpty(data.fields.Name) ? data.fields.Name : null;
                this.sku = IS.stringNotEmpty(data.fields.StockKeepingUnit) ? data.fields.StockKeepingUnit : null;
            }

            if (
                IS.objectNotEmpty(data.defaultImage)
                && IS.stringNotEmpty(data.defaultImage.url)
            ) {
                this.image = UTILS.cmsImage(data.defaultImage.url);
            }

            if (IS.stringNotEmpty(data.productClass)) {
                this.productClass = data.productClass;
            }
        }
    }

    // HANDLERS
    handleClickAddToList() {
        let modal = this.template.querySelector('c-b2b-modal');
        if (!this.isButtonDisabled && modal) {
            modal.open({
                id: this.productId,
                title: LABELS.modalTitle,
                buttonsAlign: 'right',
                closeLabel: LABELS.cancel,
                submitLabel: LABELS.add,
            });
        }

        setTimeout(() => {
            this.handleChangeType({
                target: {
                    value: CREATE
                }
            });
        }, 0);

        setTimeout(() => {
            this.handleChangeListName({
                target: {
                    value: LABELS.defaultName
                }
            });
        }, 0);

        setTimeout(() => {
            if (IS.arrayNotEmpty(this.listOptions) && this.listOptions.length === 1) {
                this.listId = this.listOptions[0].value;
            }
        }, 0);
    }

    handleBlurListName(event) {
        this.listNameWasBlur = true;

        let value = UTILS.prepareString(event.target.value);
        if (IS.stringNotEmpty(value)) {
            value = value.trim();
        }

        this.listName = value;
        event.target.value = value;
        if (event.target.reportValidity) {
            event.target.reportValidity();
        }
    }

    handleChangeListName(event) {
        let value = UTILS.prepareString(event.target.value);
        this.listName = value;
        event.target.value = value;
        if (this.listNameWasBlur && event.target.reportValidity) {
            event.target.reportValidity();
        }
    }

    handleChangeType(event) {
        let type = event.target.value === EXIST ? EXIST : CREATE;
        let listName = this.template.querySelector('lightning-input[data-name="listName"]');
        if (
            listName
            && type !== CREATE
            && !IS.stringNotEmpty(this.listName)
        ) {
            listName.value = LABELS.defaultName;
            this.listName = LABELS.defaultName;
            listName.setCustomValidity('');
            listName.reportValidity();
        }
        this.type = type;
    }

    handleChangeList(event) {
        this.listId = event.detail.value;
    }

    handleCloseModal() {
        this.type = CREATE;
        this.listName = LABELS.defaultName;
        this.listId = null;
    }

    async handleSubmitModal() {
        let modal = this.template.querySelector('c-b2b-modal');
        if (
            !modal
            || this.submitDisabled
            || !IS.stringNotEmpty(this.effectiveAccountId)
        ) {
            return;
        }

        this.isModalLoading = true;

        let response = await UTILS.doRequest(addFavoriteListItem, {
            favoriteListId: this.type === EXIST ? this.listId : null,
            favoriteListName: this.type === CREATE ? this.listName : this.getCurrentListName,
            effectiveAccountId: this.effectiveAccountId,
            productId: this.productId,
        });

        let hideModal = false;
        if (UTILS.responseSuccess(response)) {
            UTILS.showToast('success', UTILS.prepareLabel(
                LABELS.addSuccess,
                [this.type === EXIST ? this.getCurrentListName : this.listName]
            ));
            hideModal = true;

        } else if (
            IS.stringNotEmpty(response.responseData)
            && IS.stringIncludes(response.responseData, LIST_FULL)
        ) {
            UTILS.showToast('error', LABELS.addListFull);

        } else if (
            IS.stringNotEmpty(response.responseMessage)
            && response.responseMessage === ALREADY_EXIST
        ) {
            UTILS.showToast('warning', LABELS.addAlreadyExist);

        } else {
            UTILS.showToast('error', LABELS.addError);
            hideModal = true;
        }

        if (hideModal) {
            await this.getInitialData();
            modal.hide();
            this.handleCloseModal();
        }
        this.isModalLoading = false;
    }

}