import { LightningElement, track } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

// METHODS
import getProfileInfo from '@salesforce/apex/B2BUserProfilesController.getProfileInfo';
import deleteProfilePhoto from '@salesforce/apex/B2BUserProfilesController.deleteProfilePhoto';
import setProfilePhoto from '@salesforce/apex/B2BUserProfilesController.setProfilePhoto';

const LABELS = {
    loading: 'Loading',
    close: 'Close',
    modalTitle: 'Update Photo',
    modalClose: 'Cancel',
    modalSubmit: 'Save',
    newPhotoAlt: 'New photo',
    photoLabel: 'Current Photo:',
    uploadInfo: 'You can upload a JPG, GIF or PNG file. Maximum file size is 16 MB.',
    remove: 'Remove',
    deletePhotoSuccess: 'The photo was successfully deleted',
    deletePhotoError: 'The photo was not deleted. Try again later.',
    uploadError: 'Unable to process the photo',
    saveSuccess: 'The photo was saved successfully',
    saveError: 'The photo was not saved. Try again later.',
};

export default class B2bProfilePhoto extends LightningElement {
    @track isLoading = true;
    @track isUpdateLoading = false;
    @track labels = LABELS;
    @track userId = UTILS.userId;
    @track name = null;
    @track photoAccept = '.jpg,.png,.gif';
    @track photoUrl = null;
    @track newPhoto = {
        data: null,
        name: null,
        type: null
    };
    @track modalShow = false;

    // GETTERS
    get submitButtonDisabled() {
        return this.isLoading
            || this.isUpdateLoading
            || !IS.stringNotEmpty(this.newPhoto.data);
    }

    // LIFECYCLES
    connectedCallback() {
        this.getInitialData();
    }

    // METHODS
    async getInitialData() {
        if (!IS.stringNotEmpty(this.userId)) {
            return;
        }

        let response = await UTILS.doRequest(getProfileInfo, {
            userId: this.userId
        });

        if (UTILS.responseSuccess(response)) {
            this.parseResponse(UTILS.responseData(response));
        }

        this.isLoading = false;
    }

    parseResponse(data) {
        if (IS.objectNotEmpty(data)) {
            this.name = IS.stringNotEmpty(data.name) ? data.name : null;
            this.photoUrl = IS.stringNotEmpty(data.mediumPhotoUrl)
                && !IS.stringIncludes(data.mediumPhotoUrl, 'default_profile')
                && !IS.stringIncludes(data.mediumPhotoUrl, '/005/')
                    ? data.mediumPhotoUrl
                    : null;
        }
    }

    showModal() {
        this.modalShow = true;
        document.body.style.overflowY = 'hidden';
    }

    hideModal() {
        this.modalShow = false;
        document.body.style.overflowY = 'auto';
        this.resetNewPhoto();
    }

    resetNewPhoto() {
        this.newPhoto.data = null;
        this.newPhoto.name = null;
        this.newPhoto.type = null;
    }

    // HANDLERS
    handleClickUpdateButton() {
        if (this.isLoading || this.isUpdateLoading) {
            return;
        }
        this.showModal();
    }

    handleClickModalClose() {
        if (this.isLoading || this.isUpdateLoading) {
            return;
        }
        this.hideModal();
    }

    async handleClickRemovePhoto(event) {
        event.preventDefault();
        if (this.isLoading || this.isUpdateLoading) {
            return;
        }

        if (!IS.stringNotEmpty(this.newPhoto.data)) {
            this.isUpdateLoading = true;
    
            let response = await UTILS.doRequest(deleteProfilePhoto, {
                userId: this.userId
            });
    
            if (UTILS.responseSuccess(response)) {
                UTILS.showToast('success', LABELS.deletePhotoSuccess);
                this.photoUrl = null;
            } else {
                UTILS.showToast('error', LABELS.deletePhotoError);
            }
        }
        this.resetNewPhoto();
        this.isUpdateLoading = false;
    }

    async handleChangeUpload(event) {
        if (event.detail && event.detail.files && event.detail.files[0]) {
            let file = event.detail.files[0];
            if (
                file
                && IS.arrayIncludes(['image/jpeg', 'image/png', 'image/gif'], file.type)
                && file.size < 16000000 // ~ 16 MB
            ) {
                this.isUpdateLoading = true;
                let response = await UTILS.readFile(file);
                if (UTILS.responseSuccess(response)) {
                    this.newPhoto.data = response.responseData;
                    this.newPhoto.name = file.name;
                    this.newPhoto.type = file.type;
                } else {
                    this.resetNewPhoto();
                    UTILS.showToast('error', LABELS.uploadError);
                }
            }
        }
        this.isUpdateLoading = false;
    }

    async handleClickModalSubmit() {
        if (
            this.isUpdateLoading
            || !IS.stringNotEmpty(this.userId)
            || !IS.stringNotEmpty(this.newPhoto.data)
        ) {
            return;
        }

        this.isUpdateLoading = true;
        let base64Data = encodeURIComponent(this.newPhoto.data.split('base64,')[1]);
        let response = await UTILS.doRequest(setProfilePhoto, {
            userId: this.userId,
            base64Data,
            mimeType: this.newPhoto.type,
            fileName: this.newPhoto.name,
        });

        if (UTILS.responseSuccess(response)) {
            UTILS.showToast('success', LABELS.saveSuccess);
            this.photoUrl = this.newPhoto.data;
            this.hideModal();
        } else {
            UTILS.showToast('error', LABELS.saveError);
        }
        this.isUpdateLoading = false;
    }

}