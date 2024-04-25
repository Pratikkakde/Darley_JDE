import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

// METHODS
import getFavoriteListDetail from '@salesforce/apex/B2BFavoriteListDetailController.getFavoriteListDetail';
import deleteFavoriteList from '@salesforce/apex/B2BFavoriteListController.deleteFavoriteList';
import deleteAllFavoriteListItems from '@salesforce/apex/B2BFavoriteListDetailController.deleteAllFavoriteListItems';

const LABELS = {
    loading: 'Loading',
    fatalError: 'Favorite list details not found. Try again later.',
    loadingError: 'Failed to get favorite list details. Try again later.',
    emptyMessageTitle: 'No items on this list yet',
    emptyMessageText: 'Add the products that you want to remember',
    addAllToCart: 'Add All to Cart',
    sortLabel: 'Sort Items By',
    item: 'item',
    items: 'items',
    dateAsc: 'Date Added - Oldest First',
    dateDesc: 'Date Added - Newest First',
    nameAsc: 'Name - A to Z',
    nameDesc: 'Name - Z to A',
    rename: 'Rename',
    cancel: 'Cancel',
    delete: 'Delete',
    deleteTitle: 'Confirm you want to DELETE Favorite list "{0}"?',
    deleteSuccess: 'The list "{0}" was deleted.',
    deleteError: 'The list "{0}" was not deleted.',
    clearList: 'Clear List',
    clearListTitle: 'Remove All items from the list "{0}" ?',
    clearListSuccess: 'The list "{0}" was cleared.',
    clearListError: 'The list "{0}" was not cleared.',
    addAllSuccess: '{0} was added to cart',
    addAllError: `{0} couldn't be added to your cart.`,
    addAllItem: 'Item',
    addAllItems: 'Items',
    addAllUnavailableProductsTitle: `Product Availability`,
    addAllUnavailableProductsInfo: `The items below are unavailable and not added to your shopping cart.`,
    addAllUnavailableProductsLabel: 'Unavailable Products',
    viewCart: 'View Cart',
    continueShopping: 'Continue Shopping',
    limitError: 'The cart is full (max 500 items). Please clear it to add new items.',
};

const EDIT = 'edit';
const ASC = 'ASC';
const DEFAULT_SORT = 'createdDate_DESC';
const LOADING_EVENT = 'loading';
const UPDATE_NAME_EVENT = 'updatename';
const UPDATE_COUNT_EVENT = 'updatecount';
const UPDATE_LISTS_EVENT = 'updatelists';
const MODAL_DELETE = 'modal_delete';
const MODAL_CLEAR = 'modal_clear';
const MODAL_ADD_ALL = 'modal_add_all';
const LIMIT_EXCEEDED = 'LIMIT_EXCEEDED';

export default class B2bFavoriteListDetail extends LightningElement {
    @api isUpdateLoading = false;
    @api itemsOnPage = null;
    @api showOriginalPrice = false;
    @api effectiveAccountId = null;
    @api listName = null;

    @track _listId = null;
    get listId() {
        return this._listId;
    }
    @api
    set listId(value) {
        this._listId = IS.stringNotEmpty(value) ? value : null;
        this.getInitialData();
    }

    @track isLoading = true;
    @track isModalLoading = false;
    @track labels = LABELS;
    @track isFatalError = false;
    @track fatalErrorMessage = null;
    @track sort = DEFAULT_SORT;
    @track sortOptions = [
        { label: LABELS.dateDesc, value: 'createdDate_DESC' },
        { label: LABELS.dateAsc, value: 'createdDate_ASC' },
        { label: LABELS.nameAsc, value: 'productName_ASC' },
        { label: LABELS.nameDesc, value: 'productName_DESC' }
    ];
    @track list = [];
    @track currentPage = 1;
    @track unavailableProducts = [];

    // GETTERS
    get showSpinner() {
        return  this.isLoading
            || this.isUpdateLoading;
    }

    get showEmptyMessage() {
        return !this.isLoading
            && !IS.arrayNotEmpty(this.list);
    }

    get isActionsDisabled() {
        return this.isLoading
            || this.isUpdateLoading;
    }

    get isSortOptionsDisabled() {
        return this.isActionsDisabled
            || !IS.arrayNotEmpty(this.list);
    }

    get isClearDisabled() {
        return this.isActionsDisabled
            || !IS.arrayNotEmpty(this.list);
    }

    get getList() {
        let result = [].concat(this.list);

        result.sort((a, b) => {
            let field = this.sort.split('_')[0];
            let order = this.sort.split('_')[1];
            if (a[field].toLowerCase() < b[field].toLowerCase()) return order === ASC ? -1 : 1;
            if (a[field].toLowerCase() > b[field].toLowerCase()) return order === ASC ? 1 : -1;
            return 0;
        });

        let startIndex = this.currentPage * this.itemsOnPage - this.itemsOnPage;
        let endIndex = this.currentPage * this.itemsOnPage;
        return result.slice(startIndex, endIndex);
    }

    get showPagination() {
        return IS.arrayNotEmpty(this.list)
            && this.list.length > this.itemsOnPage;
    }

    get isPaginationDisabled() {
        return this.isLoading
            || this.isUpdateLoading;
    }

    get maxPage() {
        return Math.ceil(this.list.length / this.itemsOnPage);
    }

    get getAvailableProducts() {
        return this.list.filter((item) => item.isAvailable && item.isPriceAvailable);
    }

    get getAvailableCount() {
        return this.getAvailableProducts.length;
    }

    get getAddAllButtonLabel() {
        let count = this.getAvailableCount;
        let itemLabel = count > 1 ? LABELS.items : LABELS.item;
        return `${LABELS.addAllToCart}${count > 0 ? ` (${count} ${itemLabel})`: ''}`;
    }

    get isAddAllButtonDisabled() {
        return this.isLoading
            || this.isUpdateLoading
            || !IS.integer(this.getAvailableCount)
            || this.getAvailableCount === 0;
    }

    // LIFECYCLES
    async connectedCallback() {
        if (!IS.stringNotEmpty(this.effectiveAccountId)) {
            this.effectiveAccountId = await UTILS.getEffectiveAccountId();
        }
    }

    // METHODS
    async getInitialData() {
        this.isLoading = true;
        this.currentPage = 1;
        this.list = [];
        this.isFatalError = false;
        this.fatalErrorMessage = null;

        // Fatal Error
        if (!IS.stringNotEmpty(this.listId)) {
            this.isFatalError = true;
            this.fatalErrorMessage = LABELS.fatalError;
            this.isLoading = false;
            return;
        }

        let response = await UTILS.doRequest(getFavoriteListDetail, {
            effectiveAccountId: this.effectiveAccountId,
            favoriteListId: this.listId,
        });

        if (UTILS.responseSuccess(response)) {
            this.parseResponse(UTILS.responseData(response));
        } else {
            this.fatalErrorMessage = LABELS.loadingError;
            this.isFatalError = true;
        }
        this.isLoading = false;
    }

    parseResponse(data) {
        let result = [];
        if (IS.arrayNotEmpty(data)) {
            data.forEach((item) => {
                let newItem = {
                    id: IS.stringNotEmpty(item.id) ? item.id : null,
                    productId: IS.stringNotEmpty(item.productId) ? item.productId : null,
                    productName: IS.stringNotEmpty(item.productName) ? item.productName : null,
                    quantity: IS.integer(item.minQuantity) ? item.minQuantity : UTILS.quantityMin,
                    createdDate: IS.stringNotEmpty(item.createdDate) ? item.createdDate : null,
                    isAvailable: IS.true(item.isProductAvailable) ? true : false,
                    isQuoteOnly: IS.true(item.isQuoteOnly) ? true : false,
                    isPriceAvailable: IS.true(item.isPriceAvailable) ? true : false,
                    isLoaded: false,
                    isUpdateLoading: false,
                };

                if (
                    IS.stringNotEmpty(newItem.id)
                    && IS.stringNotEmpty(newItem.productId)
                    && IS.stringNotEmpty(newItem.productName)
                ) {
                    result.push(newItem);
                }
            });
        }
        this.list = result;

        UTILS.dispatchEvent(this, UPDATE_COUNT_EVENT, {
            listId: this.listId,
            length: this.list.length
        });
    }

    // HANDLERS
    handleChangeSort(event) {
        this.sort = event.target.value;
        this.currentPage = 1;
    }

    handleAvailable(event) {
        if (
            IS.objectNotEmpty(event.detail)
            && IS.stringNotEmpty(event.detail.id)
        ) {
            this.list.forEach((item) => {
                if (item.id === event.detail.id) {
                    item.isAvailable = IS.true(event.detail.isAvailable) ? true : false;
                }
            });
        }
    }

    handleUpdateLoading(event) {
        if (
            IS.objectNotEmpty(event.detail)
            && IS.stringNotEmpty(event.detail.id)
        ) {
            let isUpdateLoading = false;
            let visibleItemsIds = this.getList.map((item) => item.id);
            this.list.forEach((item) => {
                if (item.id === event.detail.id) {
                    item.isUpdateLoading = IS.true(event.detail.isUpdateLoading) ? true : false;
                } else if (!IS.arrayIncludes(visibleItemsIds, item.id)) {
                    item.isUpdateLoading = false;
                }
                if (item.isUpdateLoading) {
                    isUpdateLoading = true;
                }
            });
            // UTILS.dispatchEvent(this, LOADING_EVENT, isUpdateLoading);
        }
    }

    handleClickRename(event) {
        event.preventDefault();
        if (
            !this.isUpdateLoading
            && IS.stringNotEmpty(this.listId)
            && IS.stringNotEmpty(this.listName)
        ) {
            
            let component = this.template.querySelector('c-b2b-favorite-list-upsert');
            if (component) {
                UTILS.dispatchEvent(this, LOADING_EVENT, true);
                component.open({
                    mode: EDIT,
                    listId: this.listId,
                    listName: this.listName,
                });
            }
        }
    }

    handleCloseFavoriteListUpsert(event) {
        if (
            IS.objectNotEmpty(event.detail)
            && IS.stringNotEmpty(event.detail.listId)
            && IS.stringNotEmpty(event.detail.listName)
        ) {
            UTILS.dispatchEvent(this, UPDATE_NAME_EVENT, {
                listId: event.detail.listId,
                listName: event.detail.listName,
            });
        }
        UTILS.dispatchEvent(this, LOADING_EVENT, false);
    }

    handleClickDelete(event) {
        event.preventDefault();
        let modal = this.template.querySelector('c-b2b-modal');
        if (this.isActionsDisabled || !modal) {
            return;
        }
        UTILS.dispatchEvent(this, LOADING_EVENT, true);

        modal.open({
            mode: MODAL_DELETE,
            title: UTILS.prepareLabel(LABELS.deleteTitle, [this.listName]),
            buttonsAlign: 'full_width',
            closeLabel: LABELS.cancel,
            submitLabel: LABELS.delete,
        });
    }

    handleClickClear(event) {
        event.preventDefault();
        let modal = this.template.querySelector('c-b2b-modal');
        if (this.isClearDisabled || !modal) {
            return;
        }
        UTILS.dispatchEvent(this, LOADING_EVENT, true);

        modal.open({
            mode: MODAL_CLEAR,
            title: UTILS.prepareLabel(LABELS.clearListTitle, [this.listName]),
            buttonsAlign: 'full_width',
            closeLabel: LABELS.cancel,
            submitLabel: LABELS.clearList,
        });
    }

    handleCloseModal(event) {
        if (
            event.detail
            && IS.stringNotEmpty(event.detail.mode)
            && event.detail.mode === MODAL_ADD_ALL
            && !event.detail.isHeaderClose
        ) {
            UTILS.navigateTo('/cart');
        }
        this.isModalLoading = false;
        this.unavailableProducts = [];
        UTILS.dispatchEvent(this, LOADING_EVENT, false);
    }

    async handleSubmitModal(event) {
        let modal = this.template.querySelector('c-b2b-modal');
        if (
            modal
            && IS.objectNotEmpty(event.detail)
            && IS.stringNotEmpty(event.detail.mode)
        ) {
            this.isModalLoading = true;

            // DELETE LIST
            if (event.detail.mode === MODAL_DELETE) {
                let response = await UTILS.doRequest(deleteFavoriteList, {
                    favoriteListId: this.listId
                });

                if (UTILS.responseSuccess(response)) {
                    UTILS.showToast('success', UTILS.prepareLabel(LABELS.deleteSuccess, [this.listName]));
                    UTILS.dispatchEvent(this, UPDATE_LISTS_EVENT, {
                        listId: this.listId,
                    });
                } else {
                    UTILS.showToast('error', UTILS.prepareLabel(LABELS.deleteError, [this.listName]));
                }

            // CLEAR LIST
            } else if (event.detail.mode === MODAL_CLEAR) {
                let response = await UTILS.doRequest(deleteAllFavoriteListItems, {
                    favoriteListId: this.listId
                });

                if (UTILS.responseSuccess(response)) {
                    UTILS.showToast('success', UTILS.prepareLabel(LABELS.clearListSuccess, [this.listName]));
                    this.list = [];
                    this.currentPage = 1;
                    UTILS.dispatchEvent(this, UPDATE_COUNT_EVENT, {
                        listId: this.listId,
                        length: this.list.length
                    });
                } else {
                    UTILS.showToast('error', UTILS.prepareLabel(LABELS.clearListError, [this.listName]));
                }
            }
            modal.hide();
        }
        this.isModalLoading = false;
        this.unavailableProducts = [];
        UTILS.dispatchEvent(this, LOADING_EVENT, false);
    }

    handleClickRemove(event) {
        if (
            IS.objectNotEmpty(event.detail)
            && IS.stringNotEmpty(event.detail.id)
        ) {
            this.list = this.list.filter((item) => item.id !== event.detail.id);
            if (this.currentPage > this.maxPage) {
                this.currentPage = this.maxPage;
            }

            UTILS.dispatchEvent(this, UPDATE_COUNT_EVENT, {
                listId: this.listId,
                length: this.list.length
            });
        }
    }

    handleChangePagination(event) {
        this.currentPage = IS.integer(event.detail) ? event.detail : 1;
    }

    async handleClickAddAllButton() {
        let modal = this.template.querySelector('c-b2b-modal');
        if (this.isAddAllButtonDisabled || !modal) {
            return;
        }
        UTILS.dispatchEvent(this, LOADING_EVENT, true);

        let products = {};
        this.getAvailableProducts.forEach((item) => {
            products[item.productId] = item.quantity;
        });
        let response = await UTILS.addItemsToCart(products);

        if (UTILS.responseSuccess(response)) {
            if (this.list.length !== this.getAvailableProducts.length) {
                let unavailableProducts = [];
                let availableIds = Object.keys(products);
                this.list.forEach((item) => {
                    if (!IS.arrayIncludes(availableIds, item.productId)) {
                        unavailableProducts.push(item.productName);
                    }
                });
                this.unavailableProducts = unavailableProducts;

                modal.open({
                    mode: MODAL_ADD_ALL,
                    useRedirectToCart: true,
                    title: LABELS.addAllUnavailableProductsTitle,
                    buttonsAlign: 'full_width',
                    closeLabel: LABELS.viewCart,
                    submitLabel: LABELS.continueShopping,
                });
            } else {
                modal.open({
                    mode: MODAL_ADD_ALL,
                    useRedirectToCart: true,
                    title: UTILS.prepareLabel(LABELS.addAllSuccess, [
                        this.getAvailableProducts.length === 1
                            ? LABELS.addAllItem
                            : LABELS.addAllItems
                    ]),
                    buttonsAlign: 'full_width',
                    closeLabel: LABELS.viewCart,
                    submitLabel: LABELS.continueShopping,
                });
            }
        } else {
            if (IS.stringIncludes(JSON.stringify(response.responseData), LIMIT_EXCEEDED)) {
                UTILS.showToast('error', LABELS.limitError);
            } else {
                UTILS.showToast('error', UTILS.prepareLabel(LABELS.addAllError, [
                    this.getAvailableProducts.length === 1
                        ? LABELS.addAllItem
                        : LABELS.addAllItems
                ]));
            }
            modal.hide();
        }
        UTILS.dispatchEvent(this, LOADING_EVENT, false);
    }

}