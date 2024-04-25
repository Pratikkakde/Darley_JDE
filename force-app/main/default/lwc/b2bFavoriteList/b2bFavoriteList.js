import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

// METHODS
import getFavoriteList from '@salesforce/apex/B2BFavoriteListController.getFavoriteList';

const LABELS = {
    loading: 'Loading',
    loadingError: 'Failed to get favorite lists. Try again later.',
    title: 'Favorite Lists',
    createList: '+ Create List',
    emptyMessageTitle: 'No lists yet',
    emptyMessageText: 'Create lists of the products that you want to remember',
    listName: 'List Name',
    item: 'item',
    items: 'items',
};

const COMPONENT_NAME = 'b2b-favorite-list';
const ADD = 'add';
const EDIT = 'edit';

export default class B2bFavoriteList extends LightningElement {
    @api itemsOnPage = null;
    @api showOriginalPrice = false;

    @track labels = LABELS;
    @track isLoading = true;
    @track isUpdateLoading = false;
    @track isFirstRender = true;
    @track effectiveAccountId = null;
    @track customCssContainer = UTILS.customCssContainer;
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);

    @track isFatalError = false;
    @track fatalErrorMessage = null;
    @track listId = null;
    @track listOptions = [];

    // GETTERS
    get showPanel() {
        return !this.isLoading
            && !this.isFatalError
            && IS.arrayNotEmpty(this.listOptions);
    }

    get showEmptyMessage() {
        return !this.isLoading
            && !this.isFatalError
            && !IS.arrayNotEmpty(this.listOptions);
    }

    get isCreateListDisabled() {
        return this.isLoading
            || this.isFatalError
            || this.isUpdateLoading
            || UTILS.isGuest;
    }

    get getListName() {
        let result = null;
        if (IS.arrayNotEmpty(this.listOptions)) {
            this.listOptions.forEach((item) => {
                if (item.value === this.listId) {
                    result = item.name;
                }
            });
        }
        return result;
    }

    get isListOptionsDisabled() {
        return this.isUpdateLoading;
    }

    get showFavoriteListDetail() {
        return !this.isLoading
            && !this.isFatalError
            && IS.stringNotEmpty(this.listId);
    }

    // LIFECYCLES
    async connectedCallback() {
        this.effectiveAccountId = await UTILS.getEffectiveAccountId();
        this.getInitialData(true);
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
            .b2b-favorite-list__panel lightning-combobox .slds-form-element__label {
                padding: 0;
                font-size: 12px;
            }
            
            .b2b-favorite-list__panel lightning-combobox .slds-combobox__input {
                font-size: 12px;
            }

            c-b2b-favorite-list lightning-combobox .slds-combobox__input {
                border-radius: 0;
            }

            c-b2b-favorite-list lightning-combobox .slds-combobox__input:focus,
            c-b2b-favorite-list lightning-combobox .slds-combobox__input:active {
                border-color: rgba(237, 27, 45, 1);
                box-shadow: 0 0 3px rgba(237, 27, 45, 1);
            }

            /* B2B FAVORITE LIST DETAIL */

            c-b2b-favorite-list-detail .b2b-favorite-list-detail__sort lightning-combobox {
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 0 !important;
                margin: 0 !important;
            }

            c-b2b-favorite-list-detail .b2b-favorite-list-detail__sort lightning-combobox .slds-form-element__label {
                max-width: 100%;
                white-space: nowrap;
                z-index: unset;
            }

            c-b2b-favorite-list-detail .b2b-favorite-list-detail__sort lightning-combobox .slds-form-element__control {
                padding: 0;
            }

            c-b2b-favorite-list-detail .b2b-favorite-list-detail__sort lightning-combobox .slds-combobox__input {
                font-size: 0.75rem;
            }

            @media screen and (max-width: 574.98px) {

                c-b2b-favorite-list-detail .b2b-favorite-list-detail__sort lightning-combobox {
                    display: block;
                }

                c-b2b-favorite-list-detail .b2b-favorite-list-detail__sort lightning-combobox .slds-form-element__label {
                    font-size: 0.75rem;
                }

            }

            /* B2B FAVORITE LIST ITEM */

            c-b2b-favorite-list-item .b2b-favorite-list-item__actions lightning-button-icon .slds-button__icon {
                width: 1rem;
                height: 1rem;
            }

            c-b2b-favorite-list-item + c-b2b-favorite-list-item {
                border-top: 1px solid #DDDBDA;
            }

            c-b2b-favorite-list-item .b2b-favorite-list-item__actions .slds-button {
                font-size: 14px;
            }

            c-b2b-favorite-list-item .b2b-favorite-list-item__actions .slds-button:not(.slds-button_outline-brand) {
                text-decoration: underline;
            }

            c-b2b-favorite-list-item .b2b-favorite-list-item__actions .slds-button.slds-button_outline-brand {
                padding-left: 14px;
                padding-right: 14px;
                line-height: 38px;
            }

            /* B2B MODAL */
            c-b2b-modal .slds-modal__footer .slds-button {
                font-size: 13px;
                font-weight: 600;
                line-height: 38px;
            }
        `;

        UTILS.addCustomCssStyles(this.template, styleText);
    }

    async getInitialData(setNewestList) {
        let response = await UTILS.doRequest(getFavoriteList, {
            effectiveAccountId: this.effectiveAccountId,
        });

        if (UTILS.responseSuccess(response)) {
            this.parseResponse(UTILS.responseData(response), setNewestList);
        } else {
            this.fatalErrorMessage = LABELS.loadingError;
            this.isFatalError = true;
        }
        this.isLoading = false;
    }

    parseResponse(data, setNewestList) {
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

        let isSelectedListExist = false;
        if (IS.arrayNotEmpty(this.listOptions) && IS.stringNotEmpty(this.listId)) {
            this.listOptions.forEach((item) => {
                if (item.value === this.listId) {
                    isSelectedListExist = true;
                }
            });
        }

        if (IS.arrayNotEmpty(this.listOptions)) {
            if (
                setNewestList
                || (!isSelectedListExist && IS.stringNotEmpty(this.listId))
            ) {
                this.listId = this.listOptions[0].value;
            }
        }
    }

    // HANDLERS
    handleClickCreateList(event) {
        event.preventDefault();
        if (!this.isCreateListDisabled) {
            let component = this.template.querySelector('c-b2b-favorite-list-upsert');
            if (component) {
                this.isUpdateLoading = true;
                component.open({
                    mode: ADD
                });
            }
        }
    }

    async handleCloseFavoriteListUpsert(event) {
        if (
            IS.objectNotEmpty(event.detail)
            && IS.true(event.detail.update)
            && IS.stringNotEmpty(event.detail.mode)
        ) {
            await this.getInitialData(event.detail.mode === ADD);
        }
        this.isUpdateLoading = false;
    }

    handleChangeList(event) {
        this.listId = event.target.value;
    }

    handleLoading(event) {
        this.isUpdateLoading = IS.true(event.detail) ? true : false;
    }

    handleUpdateName(event) {
        if (
            IS.objectNotEmpty(event.detail)
            && IS.stringNotEmpty(event.detail.listId)
            && IS.stringNotEmpty(event.detail.listName)
        ) {
            let newListOptions = [];
            this.listOptions.forEach((item) => {
                let newItem = JSON.parse(JSON.stringify(item));
                if (newItem.value === event.detail.listId) {
                    newItem.name = event.detail.listName;
                    let itemLabel = newItem.count === 1 ? LABELS.item : LABELS.items;
                    newItem.label = `${newItem.name} (${newItem.count} ${itemLabel})`;
                }
                newListOptions.push(newItem);
            });
            this.listOptions = newListOptions;
        }
    }

    handleUpdateCount(event) {
        if (
            IS.objectNotEmpty(event.detail)
            && IS.stringNotEmpty(event.detail.listId)
            && IS.integer(event.detail.length)
        ) {
            let newListOptions = [];
            this.listOptions.forEach((item) => {
                let newItem = JSON.parse(JSON.stringify(item));
                if (newItem.value === event.detail.listId) {
                    newItem.count = event.detail.length;
                    let itemLabel = newItem.count === 1 ? LABELS.item : LABELS.items;
                    newItem.label = `${newItem.name} (${newItem.count} ${itemLabel})`;
                }
                newListOptions.push(newItem);
            });
            this.listOptions = newListOptions;
        }
    }

    handleUpdateLists(event) {
        if (
            IS.objectNotEmpty(event.detail)
            && IS.stringNotEmpty(event.detail.listId)
        ) {
            this.listOptions = this.listOptions.filter((item) => item.value !== event.detail.listId);
            if (IS.arrayNotEmpty(this.listOptions)) {
                this.listId = this.listOptions[0].value;
            } else {
                this.listId = null;
            }
        }
        this.isUpdateLoading = false;
    }

}