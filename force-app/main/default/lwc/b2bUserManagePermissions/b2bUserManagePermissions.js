import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

import getDelegatedPermissions from '@salesforce/apex/B2BUserManagementController.getDelegatedPermissions';
import getPermissionSetAssignment from '@salesforce/apex/B2BUserManagementController.getPermissionSetAssignment';
import editPermissionSets from '@salesforce/apex/B2BUserManagementController.editPermissionSets';

const LABELS = {
    loading: 'Loading',
    close: 'Close',
    title: 'Manage Permissions',
    subtitle: 'Select which permissions to assign',
    available: 'Available',
    selected: 'Selected',
    modalClose: 'Cancel',
    modalSubmit: 'Save',
    getPermissionsError: 'Failed to get a list of permissions. Try again later.',
    saveSuccess: 'Permissions were updated successfully',
    saveError: 'Permissions could not be updated. Try again later.',
};

const CLOSE_EVENT = 'close';

export default class B2bUserManagePermissions extends LightningElement {
    @track labels = LABELS;
    @track isUpdateLoading = false;
    @track show = false;
    @track userId = null;
    @track delegated = [];
    @track assigned = [];
    @track options = [];
    @track value = [];

    // METHODS
    showModal() {
        this.show = true;
        document.body.style.overflowY = 'hidden';
    }

    hideModal() {
        this.show = false;
        this.userId = null;
        this.delegated = [];
        this.assigned = [];
        this.options = [];
        this.value = [];
        document.body.style.overflowY = 'auto';
    }

    getInitialData() {
        Promise.all([
            getDelegatedPermissions({ userId: this.userId }),
            getPermissionSetAssignment({ userId: this.userId }),
        ])
            .then((responses) => {
                if (
                    IS.arrayNotEmpty(responses)
                    && responses.length === 2
                    && UTILS.responseSuccess(responses[0])
                    && UTILS.responseSuccess(responses[1])
                ) {
                    this.parseDelegated(responses[0].responseData);
                    this.parseAssigned(responses[1].responseData);
                } else {
                    throw responses;
                }
                this.isUpdateLoading = false;
            })
            .catch((error) => {
                console.error(error);
                UTILS.showToast('error', LABELS.getPermissionsError);
                this.isUpdateLoading = false;
            });
    }

    parseDelegated(data) {
        let options = [];
        if (IS.arrayNotEmpty(data)) {
            data.forEach((item) => {
                if (
                    IS.objectNotEmpty(item)
                    && IS.objectNotEmpty(item.PermissionSet)
                    && IS.stringNotEmpty(item.PermissionSet.Id)
                    && IS.stringNotEmpty(item.PermissionSet.Label)
                ) {
                    let newItem = {
                        value: item.PermissionSet.Id,
                        label: item.PermissionSet.Label
                    };
                    this.delegated.push(item.PermissionSet.Id);
                    options.push(newItem);
                }
            });
        }
        this.options = options;
    }

    parseAssigned(data) {
        if (IS.arrayNotEmpty(data)) {
            data.forEach((item) => {
                if (
                    IS.objectNotEmpty(item)
                    && IS.objectNotEmpty(item.PermissionSet)
                    && IS.stringNotEmpty(item.PermissionSet.Id)
                ) {
                    this.assigned.push(item.PermissionSet.Id);
                    this.value.push(item.PermissionSet.Id);
                }
            });
        }
    }

    // HANDLERS
    handleChangeListbox(event) {
        this.value = event.detail.value;
    }

    handleClickModalClose() {
        this.hideModal();
        UTILS.dispatchEvent(this, CLOSE_EVENT, {});
    }

    async handleClickModalSubmit() {
        if (this.isUpdateLoading) {
            return;
        }
        this.isUpdateLoading = true;

        let newPermssionIds = [].concat(this.value);
        let deletePermssionIds = [];
        this.assigned.forEach((item) => {
            if (
                !IS.arrayIncludes(this.value, item)
                && IS.arrayIncludes(this.delegated, item)
                && !IS.arrayIncludes(deletePermssionIds, item)
            ) {
                deletePermssionIds.push(item);
            }
            if (
                !IS.arrayIncludes(this.delegated, item)
                && !IS.arrayIncludes(newPermssionIds, item)
            ) {
                newPermssionIds.push(item);
            }
        });

        let response = await UTILS.doRequest(editPermissionSets, {
            userId: this.userId,
            newPermssionIds,
            deletePermssionIds
        });

        if (UTILS.responseSuccess(response)) {
            this.hideModal();
            UTILS.showToast('success', LABELS.saveSuccess);
            UTILS.dispatchEvent(this, CLOSE_EVENT, {});
        } else {
            UTILS.showToast(
                'error',
                IS.stringNotEmpty(response.responseMessage)
                    ? response.responseMessage
                    : LABELS.saveError,
                { duration: 5 }
            );
        }

        this.isUpdateLoading = false;
    }

    // API's
    @api
    open(detail) {
        if (IS.objectNotEmpty(detail) && IS.stringNotEmpty(detail.userId)) {
            this.isUpdateLoading = true;
            this.userId = detail.userId;
            this.showModal();
            this.getInitialData();
        }
    }

}