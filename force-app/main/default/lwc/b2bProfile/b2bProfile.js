import { LightningElement, track } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

// METHODS
import getProfileInfo from '@salesforce/apex/B2BUserProfilesController.getProfileInfo';
import resetUserPassword from '@salesforce/apex/B2BUserProfilesController.resetUserPassword';

const LABELS = {
    loading: 'Loading',
    loadError: 'User data could not be loaded',
    edit: 'Edit',
    name: 'Name',
    email: 'Email',
    phone: 'Phone',
    password: 'Password',
    resetPassword: 'Reset Password',
    resetPasswordSuccess: 'Password reset email has been sent to your email',
    resetPasswordError: `Couldn't send you a password reset email`,
    yourBalanceDarleyDollars : 'Your Balance Darley Dollars',
    emailChange: 'For security purposes, you must verify this email address change. You will receive an email at this new address with details on confirming the change.'
};

export default class B2bProfile extends LightningElement {
    @track isLoading = true;
    @track showFatalError = false;
    @track fatalErrorMessage = null;
    @track labels = LABELS;

    @track user = {
        userId: UTILS.userId,
        firstName: null,
        lastName: null,
        name: null,
        email: null,
        title: null,
        phone: null,
        showDarleyDollars: false,
        totalDarleyDollars: null,
    };

    @track showEmailModal = false;

    // LIFECYCLES
    connectedCallback() {
        this.getInitialData();
    }

    // METHODS
    async getInitialData() {
        if (!IS.stringNotEmpty(this.user.userId)) {
            return;
        }

        let response = await UTILS.doRequest(getProfileInfo, {
            userId: this.user.userId
        });

        if (UTILS.responseSuccess(response)) {
            let data = UTILS.responseData(response);
            this.parseResponse(data);
        } else {
            this.fatalErrorMessage = LABELS.loadError;
            this.showFatalError = true;
        }

        this.isLoading = false;
    }

    parseResponse(data) {
        if (IS.objectNotEmpty(data)) {
            this.user.firstName = IS.stringNotEmpty(data.firstName) ? data.firstName : null;
            this.user.lastName = IS.stringNotEmpty(data.lastName) ? data.lastName : null;
            this.user.name = IS.stringNotEmpty(data.name) ? data.name : null;
            this.user.email = IS.stringNotEmpty(data.email) ? data.email : null;
            this.user.title = IS.stringNotEmpty(data.title) ? data.title : null;
            this.user.phone = IS.stringNotEmpty(data.phone) ? data.phone : null;
            this.user.totalDarleyDollars = IS.numeric(data.totalDarleyDollars)
                ? data.totalDarleyDollars
                : null;

            this.user.showDarleyDollars = !IS.true(data.optoutFromDarleyDollars)
                && IS.numeric(this.user.totalDarleyDollars)
                    ? true
                    : false;
        }
    }

    // HANDLERS
    handleClickEdit() {
        if (this.isLoading || !IS.stringNotEmpty(this.user.userId)) {
            return;
        }
        this.isLoading = true;

        let user = JSON.parse(JSON.stringify(this.user));
        let component = this.template.querySelector('c-b2b-user-upsert');
        if (component && IS.objectNotEmpty(user)) {
            component.open({
                mode: 'edit',
                user,
                profileComponent: true
            });
        }
    }

    handleCloseUserUpsert(event) {
        if (IS.objectNotEmpty(event.detail) && IS.true(event.detail.update)) {
            this.getInitialData();
        } else {
            this.isLoading = false;
        }
    }

    async handleClickResetPassword(event) {
        event.preventDefault();

        if (
            this.isLoading
            || !IS.objectNotEmpty(this.user)
            || !IS.stringNotEmpty(this.user.userId)
        ) {
            return
        }

        this.isLoading = true;
        let response = await UTILS.doRequest(resetUserPassword, {
            userId: this.user.userId,
        });
        if (UTILS.responseSuccess(response)) {
            UTILS.showToast('success', LABELS.resetPasswordSuccess);
        } else {
            UTILS.showToast('error', LABELS.resetPasswordError);
        }
        this.isLoading = false;
    }

    handleClickModalCancel() {
        this.showEmailModal = false;
    }

    handleShowEmailModal() {
        this.showEmailModal = true;
    }

}