import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

const LABELS = {
    userIsActive: 'User is active',
    userIsInactive: 'User is inactive',
    edit: 'Edit',
    activate: 'Activate',
    deactivate: 'Deactivate',
    resetPassword: 'Reset Password',
    managePermissions: 'Manage Permissions',
};

const RESET_PASSWORD = 'reset_password';
const RESET_PASSWORD_EVENT = 'resetpassword';
const MANAGE_PERMISSIONS = 'manage_permissions';
const MANAGE_PERMISSIONS_EVENT = 'managepermissions';
const EDIT_EVENT = 'edit';
const ACTIVATE_EVENT = 'activate';

export default class B2bUserCard extends LightningElement {
    @api user = null;
    @api disabled = null;

    @track labels = LABELS;
    @track resetPassword = RESET_PASSWORD;
    @track managePermissions = MANAGE_PERMISSIONS;

    // GETTERS
    get showComponent() {
        return IS.objectNotEmpty(this.user);
    }

    get getPhoto() {
        return this.showComponent
            && IS.stringNotEmpty(this.user.photoUrl)
                ? this.user.photoUrl
                : null;
    }

    get getName() {
        let result = [];

        if (this.showComponent) {
            if (IS.stringNotEmpty(this.user.firstName)) {
                result.push(this.user.firstName);
            }
            if (IS.stringNotEmpty(this.user.lastName)) {
                result.push(this.user.lastName);
            }
        }

        return IS.arrayNotEmpty(result)
                ? result.join(' ')
                : null;
    }

    get getTitle() {
        return this.showComponent
            && IS.stringNotEmpty(this.user.title)
                ? this.user.title
                : null;
    }

    get showEmail() {
        return this.showComponent
            && IS.stringNotEmpty(this.user.email);
    }

    get getEmailLink() {
        return `mailto:${this.user.email}`;
    }

    get showPhone() {
        return this.showComponent
            && IS.stringNotEmpty(this.user.phone);
    }

    get getPhoneLink() {
        return `tel:${this.user.phone}`;
    }

    get showIsActive() {
        return this.showComponent;
    }

    get isActive() {
        return this.showIsActive
            && this.user.isActive
                ? true
                : false;
    }

    get isActiveTitle() {
        return this.isActive
            ? LABELS.userIsActive
            : LABELS.userIsInactive;
    }

    get showEditAction() {
        return this.showComponent
            && !IS.true(this.user.isCurrentUser);
    }

    get showActivateAction() {
        return this.showComponent
            && !IS.true(this.user.isCurrentUser)
    }

    get activateActionLabel() {
        return this.showActivateAction
            && this.isActive
                ? LABELS.deactivate
                : LABELS.activate
    }

    get showResetPasswordMenuItem() {
        return this.showComponent
            && this.isActive;
    }

    // METHODS
    executeDispatchEvent(name) {
        if (!IS.true(this.disabled)) {
            UTILS.dispatchEvent(this, name, JSON.parse(JSON.stringify(this.user)), {});
        }
    }

    // HANDLERS
    handleClickEdit(event) {
        event.preventDefault();
        this.executeDispatchEvent(EDIT_EVENT);
    }

    handleClickActivate(event) {
        event.preventDefault();
        this.executeDispatchEvent(ACTIVATE_EVENT);
    }

    handleSelectMenuItem(event) {
        let value = event.detail.value;
        if (IS.stringNotEmpty(value)) {
            if (value === RESET_PASSWORD) {
                this.executeDispatchEvent(RESET_PASSWORD_EVENT);
            } else if (value === MANAGE_PERMISSIONS) {
                this.executeDispatchEvent(MANAGE_PERMISSIONS_EVENT);
            }
        }
    }

}