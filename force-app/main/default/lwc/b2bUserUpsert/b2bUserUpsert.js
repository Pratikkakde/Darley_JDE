import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

import addNewUser from '@salesforce/apex/B2BUserUpsertController.addNewUser';
import editUser from '@salesforce/apex/B2BUserUpsertController.editUser';

const LABELS = {
    loading: 'Loading',
    close: 'Close',
    newUser: 'New User',
    editUser: 'Edit User',
    modalClose: 'Cancel',
    modalSubmit: 'Save',
    requiredField: 'Complete this field.',
    invalidFormat: 'You have entered an invalid format',
    basicInfo: 'Basic Information',
    firstName: 'First Name',
    lastName: 'Last Name',
    email: 'Email',
    title: 'Title',
    phone: 'Phone',
    addSuccess: 'User successfully added',
    addError: 'User has not been added. Try again later.',
    editSuccess: 'User has been successfully updated',
    editError: 'User has not been updated. Try again later.',
    duplicateError: 'A user with this email already exists'
};

const CLOSE_EVENT = 'close';
const ADD = 'add';
const EDIT = 'edit';
const DUPLICATE_USERNAME = 'DUPLICATE_USERNAME';
const SHOW_WARNING = 'showemailmodal';

const MAX_LENGTH = {
    firstName: 40,
    lastName: 40,
    email: 80,
    title: 80,
    phone: 40,
};

export default class B2bUserUpsert extends LightningElement {
    @track labels = LABELS;
    @track maxLength = MAX_LENGTH;
    @track isUpdateLoading = false;
    @track show = false;
    @track mode = ADD;

    @track userId = null;
    @track accountId = null;
    @track firstName = null;
    @track lastName = null;
    @track email = null;
    @track title = null;
    @track phone = null;
    @track isActive = false;
    profileComponent = false;
    showEmailWarning = false;
    previousEmail = null; 

    // GETTERS
    get showComponent() {
        return this.show;
    }

    get getModalTitle() {
        return this.mode === ADD
            ? LABELS.newUser
            : LABELS.editUser;
    }

    // LIFECYCLES
    async connectedCallback() {
        this.accountId = await UTILS.getEffectiveAccountId();
    }

    // METHODS
    showModal() {
        this.show = true;
        document.body.style.overflowY = 'hidden';
    }

    async hideModal() {
        this.show = false;
        this.userId = null;
        this.accountId = await UTILS.getEffectiveAccountId();
        this.firstName = null;
        this.lastName = null;
        this.email = null;
        this.title = null;
        this.phone = null;
        this.isActive = false;
        document.body.style.overflowY = 'auto';
    }

    formValidity() {
        let isValid = true;
        let fields = ['firstName', 'lastName', 'email'];

        if (IS.arrayNotEmpty(fields)) {
            // VALUES VALIDATION
            fields.forEach((item) => {
                if (!IS.stringNotEmpty(this[item])) {
                    isValid = false;
                }
                if (item === 'phone' && !IS.phoneNumber(this[item])) {
                    isValid = false;
                }
                if (item === 'email' && !IS.email(this[item])) {
                    isValid = false;
                }
            });
    
            // FORM VALIDATION
            fields.forEach(async (item) => {
                await setTimeout(() => {
                    let element = this.template.querySelector(`[data-name="${item}"]`);
                    if (element && !element.reportValidity()) {
                        isValid = false;
                    }
                }, 0);
            });
        }

        return isValid;
    }

    // HANDLERS
    handleChangeFormElement(event) {
        let name = event.target.name;
        let value = event.target.value;

        if (IS.stringNotEmpty(name)) {
            value = UTILS.prepareString(value);

            if (name === 'phone') {
                value = IS.stringNotEmpty(value)
                    ? value.replace(/[^0-9\+\-\.\(\) ]/, '')
                    : value;
                if (this[`${name}WasBlur`]) {
                    if (IS.stringEmpty(value) || IS.null(value)) {
                        event.target.setCustomValidity(LABELS.requiredField);
                    } else if (!IS.phoneNumber(value)) {
                        event.target.setCustomValidity(LABELS.invalidFormat);
                    } else {
                        event.target.setCustomValidity('');
                    }
                }
            }

            if (name === 'email') {
                if (this[`${name}WasBlur`]) {
                    if (IS.stringEmpty(value) || IS.null(value)) {
                        event.target.setCustomValidity(LABELS.requiredField);
                    } else if (!IS.email(value)) {
                        event.target.setCustomValidity(LABELS.invalidFormat);
                    } else {
                        event.target.setCustomValidity('');
                    }
                }
                this.showEmailWarning = this.previousEmail != value && this.profileComponent == true ? true : false;
            }

            this[name] = value;
            event.target.value = value;
            if (this[`${name}WasBlur`]) {
                event.target.reportValidity();
            }
        }
    }

    handleClickModalClose() {
        this.hideModal();
        UTILS.dispatchEvent(this, CLOSE_EVENT, {});
        this.showEmailWarning = false;
    }

    async handleClickModalSubmit() {
        if (this.isUpdateLoading || !this.formValidity()) {
            return;
        }

        this.isUpdateLoading = true;

        let userInfo = {
            userId: IS.stringNotEmpty(this.userId) ? this.userId : null,
            accountId: IS.stringNotEmpty(this.accountId) ? this.accountId : null,
            firstName: IS.stringNotEmpty(this.firstName) ? this.firstName : null,
            lastName: IS.stringNotEmpty(this.lastName) ? this.lastName : null,
            email: IS.stringNotEmpty(this.email) ? this.email : null,
            title: IS.stringNotEmpty(this.title) ? this.title : null,
            phone: IS.stringNotEmpty(this.phone) ? this.phone : null,
            isActive: IS.true(this.isActive) ? true : false,
        };

        let response = null;

        if (this.mode === ADD) {
            userInfo.isActive = true;
            response = await UTILS.doRequest(addNewUser, {
                userInfo: JSON.stringify(userInfo)
            });

        } else if (this.mode === EDIT) {
            response = await UTILS.doRequest(editUser, { 
                userInfo: JSON.stringify(userInfo)
            });
        }

        if (UTILS.responseSuccess(response)) {
            if(this.showEmailWarning == true) {
                UTILS.dispatchEvent(this, SHOW_WARNING, {});
            } else {
                UTILS.showToast('success', this.mode === ADD ? LABELS.addSuccess : LABELS.editSuccess);
            }
            this.hideModal();
            this.isUpdateLoading = false;
            UTILS.dispatchEvent(this, CLOSE_EVENT, { update: true });

        } else if (
            IS.stringNotEmpty(response.responseData)
            && response.responseData === DUPLICATE_USERNAME
        ) {
            UTILS.showToast('error', 
                LABELS.duplicateError
            );
            this.isUpdateLoading = false;
        } else {
            UTILS.showToast('error', this.mode === ADD ? LABELS.addError : LABELS.editError);
        }
        this.isUpdateLoading = false;
        this.showEmailWarning = false;
    }

    // API's
    @api
    open(detail) {
        if (
            IS.objectNotEmpty(detail)
            && IS.stringNotEmpty(detail.mode)
            && (
                detail.mode === ADD
                || (
                    detail.mode === EDIT
                    && IS.objectNotEmpty(detail.user)
                    && IS.stringNotEmpty(detail.user.userId)
                    && IS.stringNotEmpty(detail.user.lastName)
                    && IS.stringNotEmpty(detail.user.email)
                )
            )
        ) {
            this.mode = detail.mode;

            if (this.mode === EDIT) {
                this.userId = detail.user.userId;
                this.accountId = IS.stringNotEmpty(detail.user.accountId) ? detail.user.accountId : null;
                this.firstName = IS.stringNotEmpty(detail.user.firstName) ? detail.user.firstName : null;
                this.lastName = detail.user.lastName;
                this.email = detail.user.email;
                this.previousEmail = detail.user.email;
                this.title = IS.stringNotEmpty(detail.user.title) ? detail.user.title : null;
                this.phone = IS.stringNotEmpty(detail.user.phone) ? detail.user.phone : null;
                this.isActive = IS.true(detail.user.isActive) ? true : false;
            }

            this.showModal();

            if(detail.profileComponent){
                this.profileComponent = true;
            }
        }
    }
}