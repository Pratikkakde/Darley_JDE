import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

import upsertFavoriteList from '@salesforce/apex/B2BFavoriteListController.upsertFavoriteList';

const LABELS = {
    loading: 'Loading',
    subtitle: 'Name your list',
    listName: 'List Name',
    defaultName: 'My Favorite List',
    requiredField: 'Enter a list name.',
    addTitle: 'Create a list',
    editTitle: 'Rename list',
    addSuccess: 'Created List "{0}"',
    editSuccess: 'List renamed to "{0}"',
    addError: 'Something went wrong. Please try again or contact us at edarleycustomerservice@darley.com',
    editError: 'Something went wrong. Please try again or contact us at edarleycustomerservice@darley.com',
    closeLabel: 'Cancel',
    submitLabel: 'Save',
};

const CLOSE_EVENT = 'close';
const ADD = 'add';
const EDIT = 'edit';

const MAX_LENGTH = {
    listName: 80,
};

export default class B2bFavoriteListUpsert extends LightningElement {
    @api effectiveAccountId = null;

    @track labels = LABELS;
    @track maxLength = MAX_LENGTH;
    @track isModalLoading = false;
    @track mode = ADD;

    @track listId = null;
    @track listName = null;

    // GETTERS
    get getModalTitle() {
        return this.mode === ADD
            ? LABELS.addTitle
            : LABELS.editTitle;
    }

    get showSubtitle() {
        return this.mode === ADD;
    }

    // METHODS
    formValidity() {
        let element = this.template.querySelector(`[data-name="listName"]`);
        if (element) {
            if (this.mode === ADD) {
                return element.reportValidity()
                    && IS.stringNotEmpty(this.listName)
                    && IS.stringNotEmpty(this.listName.trim());

            } else if (this.mode === EDIT) {
                return element.reportValidity()
                    && IS.stringNotEmpty(this.listId)
                    && IS.stringNotEmpty(this.listName)
                    && IS.stringNotEmpty(this.listName.trim());
            }
        }
        return false;
    }

    hideModal() {
        let modal = this.template.querySelector('c-b2b-modal');
        if (modal) {
            modal.hide();
            this.listId = null;
            this.listName = null;
        }
    }

    // HANDLERS
    handleChangeFormElement(event) {
        let name = event.target.name;
        let value = event.target.value;

        if (IS.stringNotEmpty(name)) {
            value = UTILS.prepareString(value);
            this[name] = value;
            event.target.value = value;
            if (this[`${name}WasBlur`]) {
                event.target.reportValidity();
            }
        }
    }

    handleCloseModal() {
        this.listId = null;
        this.listName = null;
        UTILS.dispatchEvent(this, CLOSE_EVENT, {});
    }

    async handleSubmitModal(event) {
        if (
            !IS.objectNotEmpty(event.detail)
            || this.isModalLoading
            || !this.formValidity()
        ) {
            return;
        }

        this.isModalLoading = true;

        let response = await UTILS.doRequest(upsertFavoriteList, {
            favoriteListId: this.listId,
            favoriteListName: this.listName.trim(),
            effectiveAccountId: this.effectiveAccountId
        });

        if (UTILS.responseSuccess(response)) {
            UTILS.showToast('success', this.mode === ADD
                ? UTILS.prepareLabel(LABELS.addSuccess, [this.listName])
                : UTILS.prepareLabel(LABELS.editSuccess, [this.listName])
            );
            UTILS.dispatchEvent(this, CLOSE_EVENT, {
                update: true,
                mode: this.mode,
                listId: this.listId,
                listName: this.listName
            });
            this.hideModal();
        } else {
            UTILS.showToast('error', this.mode === ADD ? LABELS.addError : LABELS.editError);
        }
        this.isModalLoading = false;
    }

    // API's
    @api
    open(detail) {
        let modal = this.template.querySelector('c-b2b-modal');
        if (
            modal
            && IS.objectNotEmpty(detail)
            && IS.stringNotEmpty(detail.mode)
            && (
                detail.mode === ADD
                || (
                    detail.mode === EDIT
                    && IS.stringNotEmpty(detail.listId)
                    && IS.stringNotEmpty(detail.listName)
                )
            )
        ) {
            this.mode = detail.mode;

            if (this.mode === ADD) {
                this.listName = LABELS.defaultName;

            } else if (this.mode === EDIT) {
                this.listId = detail.listId;
                this.listName = detail.listName;
            }

            modal.open({
                mode: this.mode,
                title: this.getModalTitle,
                buttonsAlign: 'full_width',
                closeLabel: LABELS.closeLabel,
                submitLabel: LABELS.submitLabel,
            });
        }
    }

}