import { LightningElement, track } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

// METHODS
import getCommunityMembers from '@salesforce/apex/B2BUserManagementController.getCommunityMembers';
import resetUserPassword from '@salesforce/apex/B2BUserManagementController.resetUserPassword';
import activateUser from '@salesforce/apex/B2BUserManagementController.activateUser';

const LABELS = {
    loading: 'Loading',
    close: 'Close',
    title: 'Users',
    search: 'Search',
    all: 'All',
    allCount: 'All ({0})',
    active: 'Active',
    inactive: 'Inactive',
    sortBy: 'Sort By',
    sortNameAsc: 'Name (Ascending)',
    sortNameDesc: 'Name (Descending)',
    loadingError: 'The list of users could not be retrieved. Try again later.',
    accessError: `Unfortunately, you don't have permissions to view this list. Please get in touch with your Account administrator.`,
    addUser: 'Add user',
    resetPasswordSuccess: 'Password reset email has been sent to your email',
    resetPasswordError: `Couldn't send you a password reset email`,
    activateSuccess: 'The user has been successfully activated',
    activateError: 'The user has not been activated. Try again later.',
    deactivateModalTitle: 'Deactivate User?',
    deactivateModalMessage: `Deactivated user can't login or reset their passwords. You can activate this user at any time.`,
    deactivateModalClose: 'Cancel',
    deactivateModalSubmit: 'Deactivate',
    deactivateSuccess: 'The user has been successfully deactivated',
    deactivateError: 'The user has not been deactivated. Try again later.',
};

const COMPONENT_NAME = 'b2b-user-management';
const NOT_HAVE_PERMISSION = 'NOT_HAVE_PERMISSION';
const ASC = 'ASC';
const SORT_NAME_ASC = 'name_ASC';
const SORT_NAME_DESC = 'name_DESC';
const DEFAULT_SORT = SORT_NAME_ASC;
const ALL = 'all';
const ACTIVE = 'active';
const INACTIVE = 'inactive';
const DEFAULT_STATUS = ALL;

export default class B2bUserManagement extends LightningElement {
    @track effectiveAccountId = null;
    @track labels = LABELS;
    @track isLoading = true;
    @track isUpdateLoading = false;
    @track isFirstRender = true;
    @track customCssContainer = UTILS.customCssContainer;
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);

    @track showFatalError = false;
    @track errorMessage = false;
    @track list = [];
    @track search = null;
    @track sort = DEFAULT_SORT;
    @track sortOptions = [
        {
            value: SORT_NAME_ASC,
            label: LABELS.sortNameAsc
        },
        {
            value: SORT_NAME_DESC,
            label: LABELS.sortNameDesc
        },
    ];
    @track status = DEFAULT_STATUS;

    @track deactivateModal = {
        show: false,
        user: null,
    };

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper}`;
    }

    get isPaneldisabled() {
        return this.isLoading
            || this.isUpdateLoading
            || !IS.arrayNotEmpty(this.list);
    }

    get statusOptions() {
        let result = [
            {
                value: ALL,
                class: null,
                label: IS.arrayNotEmpty(this.list)
                    ? UTILS.prepareLabel(LABELS.allCount, [this.list.length])
                    : LABELS.all
            },
            {
                value: ACTIVE,
                class: null,
                label: LABELS.active
            },
            {
                value: INACTIVE,
                class: null,
                label: LABELS.inactive
            }
        ];
        result.forEach((item) => {
            item.class = item.value === this.status
                ? 'slds-button slds-button_brand'
                : 'slds-button slds-button_neutral';
        });
        return result;
    }

    get getList() {
        let result = [];
        this.list.forEach((item) => {
            let flags = [];

            // SERACH
            if (
                !IS.stringNotEmpty(this.search)
                || (
                    IS.stringNotEmpty(this.search)
                    && IS.stringIncludes(item.name.toLowerCase(), this.search.toLowerCase())
                )
            ) {
                flags.push(true);
            } else {
                flags.push(false);
            }

            // STATUS
            if (
                this.status === ALL
                || (this.status === ACTIVE && IS.true(item.isActive))
                || (this.status === INACTIVE && !IS.true(item.isActive))
            ) {
                flags.push(true);
            } else {
                flags.push(false);
            }

            if (!IS.arrayIncludes(flags, false)) {
                result.push(item);
            }
        });

        result.sort((a, b) => {
            let field = this.sort.split('_')[0];
            let order = this.sort.split('_')[1];
            if (a[field] < b[field]) return order === ASC ? -1 : 1;
            if (a[field] > b[field]) return order === ASC ? 1 : -1;
            return 0;
        });

        return result;
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
            /* LIGHTNING INPUT */
            .b2b-user-management__wrapper lightning-input .slds-input {
                font-size: 13px;
            }

            /* LIGHTNING COMBOBOX */
            .b2b-user-management__wrapper lightning-combobox .slds-form-element__label {
                display: block;
                flex-basis: unset;
                float: unset;
                max-width: 100%;
                margin-right: 0.5rem;
                padding-right: 0;
                font-size: 12px;
                white-space: nowrap;
            }

            .b2b-user-management__wrapper lightning-combobox .slds-form-element__control {
                padding-left: 0;
            }

            .b2b-user-management__wrapper lightning-combobox .slds-combobox__input {
                font-size: 12px;
                border-radius: 0;
            }

            .b2b-user-management__wrapper lightning-combobox .slds-combobox__input:focus {
                border-color: var(--dxp-g-brand);
                -webkit-box-shadow: 0 0 3px var(--dxp-g-brand);
                box-shadow: 0 0 3px var(--dxp-g-brand);
            }

            /* B2B USER CARD */

            c-b2b-user-card lightning-button-menu .slds-dropdown {
                border-radius: 0;
            }

            c-b2b-user-card lightning-button-menu .slds-dropdown .slds-dropdown__item a {
                font-weight: 500;
            }

            c-b2b-user-card .b2b-user-card__action-menu .slds-button_icon:hover .slds-button__icon {
                fill: var(--dxp-g-brand);
            }

            /* B2B USER MANAGE PERMISSIONS */
            c-b2b-user-manage-permissions lightning-dual-listbox .slds-dueling-list__options {
                border-radius: 0;
            }
        `;
        UTILS.addCustomCssStyles(this.template, styleText);
    }

    async getInitialData() {
        let response = await UTILS.doRequest(getCommunityMembers, {});
        let data = UTILS.responseData(response);

        if (UTILS.responseSuccess(response)) {
            this.parseResonse(data);

        } else if (
            IS.stringNotEmpty(response.responseData)
            && response.responseData === NOT_HAVE_PERMISSION
        ) {
            this.errorMessage = IS.stringNotEmpty(response.responseMessage)
                ? response.responseMessage
                : LABELS.accessError;
            this.showFatalError = true;

        } else {
            this.errorMessage = LABELS.loadingError;
            this.showFatalError = true;
        }

        this.isLoading = false;
    }

    parseResonse(data) {
        let list = [];
        if (IS.arrayNotEmpty(data)) {
            data.forEach((item) => {
                let newItem = {
                    userId: IS.stringNotEmpty(item.userId) ? item.userId : null,
                    isCurrentUser: IS.true(item.isCurrentUser) ? true : false,
                    accountId: IS.stringNotEmpty(item.accountId) ? item.accountId : null,
                    contactId: IS.stringNotEmpty(item.contactId) ? item.contactId : null,
                    isActive: IS.true(item.isActive) ? true : false,
                    photoUrl: IS.stringNotEmpty(item.photoUrl) ? item.photoUrl : null,
                    username: IS.stringNotEmpty(item.username) ? item.username : null,
                    firstName: IS.stringNotEmpty(item.firstName) ? item.firstName : null,
                    lastName: IS.stringNotEmpty(item.lastName) ? item.lastName : null,
                    name: [],
                    email: IS.stringNotEmpty(item.email) ? item.email : null,
                    title: IS.stringNotEmpty(item.title) ? item.title : null,
                    phone: IS.stringNotEmpty(item.phone) ? item.phone : null,
                };

                if (IS.stringNotEmpty(newItem.firstName)) {
                    newItem.name.push(newItem.firstName);
                }

                if (IS.stringNotEmpty(newItem.lastName)) {
                    newItem.name.push(newItem.lastName);
                }

                newItem.name = newItem.name.join(' ');

                if (
                    IS.stringNotEmpty(newItem.photoUrl)
                    && IS.stringIncludes(newItem.photoUrl, '/vforcesite/')
                ) {
                    newItem.photoUrl = `${newItem.photoUrl.replace('/vforcesite/', '/')}`;
                }

                if (
                    IS.stringNotEmpty(newItem.photoUrl)
                    && IS.stringIncludes(newItem.photoUrl, '/005/')
                ) {
                    newItem.photoUrl = null;
                }

                if (
                    IS.stringNotEmpty(newItem.userId)
                    && IS.stringNotEmpty(newItem.accountId)
                    && IS.stringNotEmpty(newItem.contactId)
                    && IS.stringNotEmpty(newItem.lastName)
                    && IS.stringNotEmpty(newItem.email)
                ) {
                    list.push(newItem);
                }
            });
        }
        this.list = list;
    }

    // HANDLERS
    handleChangeSearch(event) {
        let value = event.target.value;
        if (!this.isUpdateLoading) {
            this.search = value;
        }
    }
    
    handleChangeSort(event) {
        let value = event.target.value;
        if (!this.isUpdateLoading && IS.stringNotEmpty(value)) {
            this.sort = value;
        }
    }

    handleClickStatus(event) {
        let value = event.target.dataset.value;
        if (!this.isUpdateLoading && IS.stringNotEmpty(value)) {
            this.status = value;
        }
    }

    handleClickAdd() {
        let component = this.template.querySelector('c-b2b-user-upsert');
        if (!this.isUpdateLoading && component) {
            this.isUpdateLoading = true;
            component.open({
                mode: 'add',
                user: null
            });
        }
    }

    handleClickEdit(event) {
        let user = event.detail;
        let component = this.template.querySelector('c-b2b-user-upsert');
        if (!this.isUpdateLoading && component && IS.objectNotEmpty(user)) {
            this.isUpdateLoading = true;
            component.open({
                mode: 'edit',
                user
            });
        }
    }

    async handleCloseUserUpsert(event) {
        if (IS.objectNotEmpty(event.detail) && IS.true(event.detail.update)) {
            await this.getInitialData();
        }
        this.isUpdateLoading = false;
    }

    async handleClickActivate(event) {
        let user = event.detail;
        if (
            !this.isUpdateLoading
            && IS.objectNotEmpty(user)
            && IS.stringNotEmpty(user.userId)
        ) {
            // DEACTIVATE
            if (IS.true(user.isActive)) {
                this.isUpdateLoading = true;
                document.body.style.overflowY = 'hidden';
                this.deactivateModal.user = user;
                this.deactivateModal.show = true;

            // ACTIVATE
            } else {
                this.isUpdateLoading = true;
                let response = await UTILS.doRequest(activateUser, { 
                    userId: user.userId,
                    active: true
                 });
                if (UTILS.responseSuccess(response)) {
                    UTILS.showToast('success', LABELS.activateSuccess);
                } else {
                    UTILS.showToast('error', LABELS.activateError);
                }
                await this.getInitialData();
                this.isUpdateLoading = false;
            }
        }
    }

    handleClickDeactivateModalClose() {
        document.body.style.overflowY = 'auto';
        this.deactivateModal.show = false;
        this.deactivateModal.user = null;
        this.isUpdateLoading = false;
    }

    async handleClickDeactivateModalSubmit() {
        document.body.style.overflowY = 'auto';
        this.deactivateModal.show = false;

        if (
            IS.objectNotEmpty(this.deactivateModal.user)
            && IS.stringNotEmpty(this.deactivateModal.user.userId)
        ) {
            let response = await UTILS.doRequest(activateUser, { 
                userId: this.deactivateModal.user.userId,
                active: false
             });
            if (UTILS.responseSuccess(response)) {
                UTILS.showToast('success', LABELS.deactivateSuccess);
            } else {
                UTILS.showToast('error', LABELS.deactivateError);
            }
        }
        this.deactivateModal.user = null;
        await this.getInitialData();
        this.isUpdateLoading = false;
    }

    async handleClickResetPassword(event) {
        let user = event.detail;
        if (
            !this.isUpdateLoading
            && IS.objectNotEmpty(user)
            && IS.stringNotEmpty(user.userId)
        ) {
            this.isUpdateLoading = true;
            let response = await UTILS.doRequest(resetUserPassword, {
                userId: user.userId,
            });
            if (UTILS.responseSuccess(response)) {
                UTILS.showToast('success', LABELS.resetPasswordSuccess);
            } else {
                UTILS.showToast('error', LABELS.resetPasswordError);
            }
            this.isUpdateLoading = false;
        }
    }

    handleClickManagePermissions(event) {
        let user = event.detail;
        let component = this.template.querySelector('c-b2b-user-manage-permissions');
        if (!this.isUpdateLoading && component && IS.objectNotEmpty(user)) {
            this.isUpdateLoading = true;
            component.open({
                userId: user.userId
            });
        }
    }

    handleCloseManagePermissions() {
        this.isUpdateLoading = false;
    }

}