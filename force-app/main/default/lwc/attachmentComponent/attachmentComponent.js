import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/AttachmentComponentController.uploadFile';
import updateContentVersion from '@salesforce/apex/AttachmentComponentController.updateContentVersion';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import LABEL_FIELD from '@salesforce/schema/ContentVersion.Label__c';
import TITLE_FIELD from '@salesforce/schema/ContentVersion.Title';
import UPLOADTODLA_FIELD from '@salesforce/schema/ContentVersion.Upload_to_DLA__c';
import DELETEATTACHMENT_FIELD from '@salesforce/schema/ContentVersion.Delete_Attachment__c';
import { refreshApex } from '@salesforce/apex';
import CONTENTVERSION_OBJECT from '@salesforce/schema/ContentVersion';
import getAllBidTrackerContentVersions from '@salesforce/apex/AttachmentComponentController.getAllBidTrackerContentVersions';

const COLS = [
    { label: "Title", fieldName: TITLE_FIELD.fieldApiName,
     
     },
    {
        label: "Upload to DLA",
        fieldName: UPLOADTODLA_FIELD.fieldApiName,
        type: "boolean",
        editable: { fieldName: 'uploadDisabled' },
        displayReadOnlyIcon: true
    },
    {
        label: "Delete Attachment",
        fieldName: DELETEATTACHMENT_FIELD.fieldApiName,
        type: "boolean",
        editable: { fieldName: 'dltDisable' },
        displayReadOnlyIcon: true
    },
];

export default class FileUploaderCompLwc extends LightningElement {
    @api recordId;
    columns = COLS;
    uploadtoDla;
    labelPicklist;
    objRecordTypeId;
    comboboxError;
    fileData;
    options;
    showDataTable = false;
    showCombobox = false;
    inputCombobox;
    //isLoading = false;
    combovalue;
    contentVersionListRefresh;
    contentVersionList = [];
    draftValues = [];

    wiredContentVersionResult; // To store the wired result
//get contentVersion Object
    @wire(getObjectInfo, { objectApiName: CONTENTVERSION_OBJECT })
    objectdata({ data, error }) {
        if (data) {
            this.objRecordTypeId = data.defaultRecordTypeId;
        }
    }
  //get whole picklist value
    @wire(getPicklistValues, { fieldApiName: LABEL_FIELD, recordTypeId: '$objRecordTypeId' })
    picklistValues({ data, error }) {
        if (data) {
            this.options = data.values;
        }
    }
    // get all the Existing pdf in the Content version
    @wire(getAllBidTrackerContentVersions, { bidTrackerId: '$recordId' })
    wiredContentVersion(result) {
        this.wiredContentVersionResult = result; // Store the result for refreshApex
        if (result.data) {
            this.contentVersionList = JSON.parse(JSON.stringify(result.data));
            this.showDataTable = result.data.length > 0;
            this.contentVersionList.forEach(ele => {
               
                // ele.Delete_Attachment__c==true?ele.dltDisable=false:ele.dltDisable=true  
                ele.Upload_to_DLA__c==true?ele.uploadDisabled=false:ele.uploadDisabled=true
                
               if(ele.Upload_to_DLA__c == false || (ele.Upload_to_DLA__c == true && ele.Delete_Attachment__c==true ) ){
                ele.dltDisable=false
               }
               else if(ele.Upload_to_DLA__c == true && ele.Delete_Attachment__c== false){
                ele.dltDisable=true
               }
            });
        } else if (result.error) {
            this.showDataTable = false;
            console.error('Error fetching content versions:', result.error);
        }
    }

    openfileUpload(event) {
      
        this.showCombobox = true;
        const file = event.target.files[0];
        var reader = new FileReader();
        reader.onload = () => {
            var base64 = reader.result.split(',')[1];
            this.fileData = {
                'filename': file.name,
                'base64': base64,
                'recordId': this.recordId
            };
        };
        reader.readAsDataURL(file);
    }
   
    handleClick() {
         //this.isLoading =  true;
        this.inputCombobox = this.template.querySelector('.inputCombobox');
        let combovalue = this.inputCombobox.value;
        if (!combovalue) {
            this.inputCombobox.setCustomValidity('Label Field is Mandatory');
        } else {
            this.inputCombobox.setCustomValidity('');
            const { base64, filename, recordId } = this.fileData;
            uploadFile({ base64, filename, recordId, uploadtoDla: this.uploadtoDla, labelPicklist: this.labelPicklist })
                .then(() => {
                    
                    this.fileData = null;
                    this.labelPicklist = '';
                    this.uploadtoDla = false;
                    this.toast(`${filename} uploaded successfully!!`);
                   // this.isLoading = false;
                    return refreshApex(this.wiredContentVersionResult);
                })
                
                .catch(error => {
                    this.toast(`Error uploading file: ${error.body.message}`, 'error');
               // this.isLoading = false;
                });
        }
        this.inputCombobox.reportValidity();
    
       
    }

    toast(title, variant = 'success') {
        const toastEvent = new ShowToastEvent({
            title,
            variant
        });
        this.dispatchEvent(toastEvent);
        this.showCombobox = false;
    }

    handleCheck(event) {
        this.uploadtoDla = event.target.checked;
    }

    handlePicklist(event) {
        this.labelPicklist = event.target.value;
    }

    handleSave(event) {
       
        const updatedFields = event.detail.draftValues;
        updateContentVersion({ conVersions: updatedFields })
            .then(() => {
                this.toast('Records updated successfully');
                return refreshApex(this.wiredContentVersionResult);
            })
            .then(() => {
                this.draftValues = []; // Clear draft values after data is refreshed
            })
            .catch(error => {
                this.toast(`Error updating records: ${error.body.message}`, 'error');
            });
    }
}