import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import searchContact1 from '@salesforce/apex/contactController.searchContact1';
import Recordtypemethod from '@salesforce/apex/contactController.Recordtypemethod';
import searchContact from '@salesforce/apex/contactController.searchContact';
import getContactRTs from '@salesforce/apex/contactController.getContactRTs';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import FIRSTNAME_FIELD from '@salesforce/schema/Contact.FirstName';
import LASTNAME_FIELD from '@salesforce/schema/Contact.LastName';
import PHONE_FIELD from '@salesforce/schema/Contact.Phone';
import EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import TITLE_FIELD from '@salesforce/schema/Contact.Title';
import RECORDTYPEID_FIELD from '@salesforce/schema/Contact.RecordTypeId';
import ACCOUNTID_FIELD from '@salesforce/schema/Contact.AccountId';
import { createRecord } from 'lightning/uiRecordApi';

export default class ContactRoleButton extends LightningElement {
  searchValue;
  selectedValue;
  contactId;
  contactRecordTypes;
  accountRecordTypeName;
 @track contactRecordTypeId ;
  lastName = '';
  email = '';
  phone = '';
  title = '';
  firstName='';
  @api recordId;

  @track contacts;
  @track error;
  selectedContactID;
  showFields = false;
  loaded = false;
  createContact = false;
  isModalOpen = false;
  data;
  accountId;
  loaded1 = false;
  loaded2 = false;
  showbutton = false;

  closeModal() {
    this.isModalOpen = false;
  }
connectedCallback() {
  setTimeout(() => {
        this.getAccountRecordType();

  }, 500);
}

  //Method for contact recordType
  getContactRecordTypeId() {
    if (this.accountRecordTypeName == 'Customer') {
      let a = this.contactRecordTypes.find(({ Name }) => Name === "Contact");
    this.contactRecordTypeId=a.Id
    console.log('rec', contactRecordTypeId);
    }
    if (this.accountRecordTypeName == 'Exposition Services') {
      let a = this.contactRecordTypes.find(({ Name }) => Name === "Contact");
      this.contactRecordTypeId=a.Id
     console.log('rec', contactRecordTypeId);
     }
     if (this.accountRecordTypeName == 'Equipment Customer') {
      let a = this.contactRecordTypes.find(({ Name }) => Name === "Equipment Contact");
      this.contactRecordTypeId=a.Id
     console.log('rec', contactRecordTypeId);
     }
     if (this.accountRecordTypeName == 'Innovation Customer') {
      let a = this.contactRecordTypes.find(({ Name }) => Name === "Innovation Contact");
      this.contactRecordTypeId=a.Id
     console.log('rec', contactRecordTypeId);
     }
     if (this.accountRecordTypeName == 'IT Account') {
      let a = this.contactRecordTypes.find(({ Name }) => Name === "IT Contacts");
      this.contactRecordTypeId=a.Id
     console.log('rec', contactRecordTypeId);
     }
     if (this.accountRecordTypeName == 'Pump Customer') {
      let a = this.contactRecordTypes.find(({ Name }) => Name === "Pump Contact");
      this.contactRecordTypeId=a.Id
     console.log('rec', contactRecordTypeId);
     }
     if (this.accountRecordTypeName == 'Equipment Vendor') {
      let a = this.contactRecordTypes.find(({ Name }) => Name === "Equipment Contact");
      this.contactRecordTypeId=a.Id
     console.log('rec', contactRecordTypeId);
     }
     if (this.accountRecordTypeName == 'Vendor') {
      let a = this.contactRecordTypes.find(({ Name }) => Name === "Vendor Contact");
      this.contactRecordTypeId=a.Id
     console.log('rec', contactRecordTypeId);
     }
  }

  //Method to get AccountId of Opportunity
  GetAccountId() {
    searchContact({ recordId: this.recordId })

      .then(data => {
        this.data = data;
        this.accountId = data[0].AccountId;
        console.log('contacts', this.contacts);
        this.error = undefined;
      })
      .catch(error => {
        console.log('Errorured:- ', error);
        this.error = error;
        this.data = undefined;
      });
  }
//Showning Data
  @wire(searchContact1, { recordId: '$recordId' })
  
  wiredRecordsMethod({ error, data }) {
    console.log('recordId',this.recordId);
   // this.getAccountRecordType();
    this.getContactRecordType();
    this.GetAccountId();

    if (data) {
      console.log('data', data);
      this.accountId = data[0].AccountId;
      console.log('accountid -: ', this.accountId);
      this.contacts = data;
      console.log('contacts', this.contacts);
      this.error = undefined;
      this.showbutton = false;
      this.loaded1 = false;
    }
    else {
      this.showbutton = true;
    }

  }



  handelEvent(event) {
    const val = event.target.value;

    searchContact1({ searchcon: val, recordId: this.recordId })
      // console.log('searchParam',eventVal);
      .then(data => {
        console.log('data', data);
        this.contacts = data;
        console.log('contacts', this.contacts);
        this.error = undefined;
      })
      .catch(error => {
        console.log('Errorured:- ', error);
        this.error = error;
        this.contacts = undefined;
      });
    this.searchValue = event.target.value;
  }


  SelectContact(event) {
    this.selectedContactID = event.target.value;
    this.showFields = true;
  }

  handleSuccess() {
    console.log('recordId');
this.loaded1=true;

    setTimeout(() => {
      const evt = new ShowToastEvent({
        title: 'ContactRole created succesfully',
        message: 'ContactRole created succesfully',
        variant: 'success',
        mode: 'dismissable'
      });
      this.dispatchEvent(evt);
      this.dispatchEvent(new CloseActionScreenEvent());

    }, 2000);
    setTimeout(() => {
      window.location.reload()
      this.dispatchEvent(new CloseActionScreenEvent());
    }, 3000);
  }


  HandlecreateContact() {
    this.isModalOpen = true;
    this.getContactRecordTypeId();
    console.log('contactRecordTypeId1', this.contactRecordTypeId);
  }



  handleLastNameChange(event) {
   
    this.lastName = event.target.value;
  }
  handleFirstNameChange(event) {
   
    this.firstName = event.target.value;
  }
  handleEmailChange(event) {
    this.email = event.target.value;
  }
  handlePhoneChange(event) {
    this.phone = event.target.value;
  }
  handleTitleChange(event) {
    this.title = event.target.value;
  }



  CreateContact() {
    this.loaded1 = true;
    const fields = {};
    
    fields[FIRSTNAME_FIELD.fieldApiName] = this.firstName;
   fields[LASTNAME_FIELD.fieldApiName] = this.lastName;
    fields[EMAIL_FIELD.fieldApiName] = this.email;
    fields[PHONE_FIELD.fieldApiName] = this.phone;
    fields[TITLE_FIELD.fieldApiName] = this.title;
    fields[ACCOUNTID_FIELD.fieldApiName] = this.accountId;
   fields[RECORDTYPEID_FIELD.fieldApiName] = this.contactRecordTypeId;


    const recordInput = { apiName: CONTACT_OBJECT.objectApiName, fields };
    createRecord(recordInput)
   

      .then(contact => {
        console.log('createRecord');
        //this.contactId = contact.id;
        this.accountId=this.accountId;
        // this.contactRecordTypeId=this.contactRecordTypeId;

        setTimeout(() => {

          const evt = new ShowToastEvent({
            title: 'Contact created succesfully',
            message: 'Contact created succesfully',
            variant: 'success',
            mode: 'dismissable'
          });

          this.dispatchEvent(evt);


        }, 1500);
        setTimeout(() => {

         window.location.reload()

        }, 2500);

      })
      .catch(error => {
        this.loaded1=false;
       // console.log(error.body.message);
       const evt = new ShowToastEvent({
        title: 'Error',
        message: 'Error in creating contact',
        variant: 'Error',
        mode: 'dismissable'
      });

      this.dispatchEvent(evt);
      });
  }


  getContactRecordType() {
    getContactRTs()
      .then((result) => {
        this.contactRecordTypes = result;

        console.log('contactRecordTypes', this.contactRecordTypes);

        this.error = undefined;
      })
      .catch((error) => {
        this.error = error;
        this.contactRecordTypes = undefined;
      });
  }

  getAccountRecordType() {
    Recordtypemethod({ recordId: this.recordId })
      .then((result) => {
        console.log('recordid1',this.recordId);
        this.accountRecordTypeName = result[0].RecordType.Name;
        console.log('accountRecordTypeName', this.accountRecordTypeName);
        this.error = undefined;
      })
      .catch((error) => {
        this.error = error;
        this.account = undefined;
      });
  }


}