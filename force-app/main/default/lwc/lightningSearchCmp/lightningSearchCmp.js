import { LightningElement, api, wire, track } from 'lwc';
import searchXlat from '@salesforce/apex/SearchComponentLwc.searchXlat';
import searchPartNumber from '@salesforce/apex/SearchComponentLwc.searchPartNumber';
import serachEmail from '@salesforce/apex/SearchComponentLwc.serachEmail';
import searchLead from '@salesforce/apex/SearchComponentLwc.searchLead';
import searchAccount from '@salesforce/apex/SearchComponentLwc.searchAccount';
import updateSupplierCleanup from '@salesforce/apex/SearchComponentLwc.updateSupplierCleanup';
import { updateRecord } from 'lightning/uiRecordApi';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import SUPPLIER_XLAT_FIELD from '@salesforce/schema/Supplier_Cleanup__c.Supplier_XLAT__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { RefreshEvent } from 'lightning/refresh';







export default class LightningSearchCmp extends LightningElement {
  parentName = '';
  @track ParentNameList = [];
  partNumber = '';
  partNumberList = [];
  email = '';
  emailList = [];
  lead = '';
  Account = '';
  leadList = [];
  accountList = [];
  parentClickedId;
  xlatRecord = false;  // display the xlatatble 
  bidRecord = false;//// display the paertnumber table
  emailRecord = false;   //// display the Email table
  leadRecord = false //display the lead table
  accountRecord = false; // display the Account table 
  partNumberClickedId;
  showXlatInput = false;   // on click of button shows the Xlat input field
  showPartNumberInput = false; // on click of button shows the partnumber input field  
  showEmailInput = false; // on click of button shows the Email input field
  showLeadInput = false; // on click of button shows the lead input field
  showAccountInput = false; // on click of button shows the account input field
  @api recordId;
  @track field1Value;
  @track field2Value;

  @track field3Value; //contains Supplier_Status__c
  xlatId;
  leadId;
  timer;

  showcmp = false;// if status is new or pending then only show the table
  showCheckbox = false; // shows the checkbox for xlatTable
  showUpdateButton = false; // button to update the record of supplier cleanup from xlattable

  showLeadCheckbox = false; // shows the checkbox for LeadTable
  showLeadUpdateButton = false //button to update the record of supplier cleanup from Lead





  handleXlat() {
    this.showXlatInput = true;
    this.bidRecord = false;
    this.showPartNumberInput = false;
    this.showEmailInput = false;
    this.emailRecord = false
    this.showLeadInput = false;
    this.leadRecord = false;
    this.accountRecord = false;
    this.showAccountInput = false;

  }

  handlePartNumber() {
    this.showPartNumberInput = true;
    this.showXlatInput = false;
    this.xlatRecord = false;
    this.showEmailInput = false;
    this.emailRecord = false
    this.showUpdateButton = false;
    this.bidRecord = false;
    this.showLeadInput = false;
    this.leadRecord = false;
    this.accountRecord = false;
    this.showAccountInput = false;
  }

  handleEmail() {
    this.showPartNumberInput = false;
    this.showXlatInput = false;
    this.showLeadInput = false;
    this.showEmailInput = true;
    this.xlatRecord = false;
    this.showUpdateButton = false;
    this.bidRecord = false;
    this.leadRecord = false;
    this.accountRecord = false;
    this.showAccountInput = false;
  }

  handleLead() {
    this.showPartNumberInput = false;
    this.showXlatInput = false;
    this.showEmailInput = false;
    this.xlatRecord = false;
    this.showUpdateButton = false;
    this.bidRecord = false;
    this.emailRecord = false;
    this.showLeadInput = true;
    this.accountRecord = false;
    this.showAccountInput = false;
    console.log('handlelead')
    console.log('emailRecord' + this.emailRecord)

  }

  handleAccount() {
    this.showPartNumberInput = false;
    this.showXlatInput = false;
    this.showEmailInput = false;
    this.xlatRecord = false;
    this.showUpdateButton = false;
    this.bidRecord = false;
    this.emailRecord = false;
    this.showLeadInput = false;
    this.showAccountInput = true;
    this.leadRecord = false;

  }

  handleKeyChange(event) {

window.clearTimeout(this.timer);
console.log('clear',this.timer)

    this.parentName = event.target.value;
    

    if (this.parentName != '') {
      this.xlatRecord = true;
      this.bidRecord = false;
    
   this.timer= setTimeout(() => {
      this.getXlatdata();
    }, 500);
    console.log('timer',this.timer)
    }
    else {
      this.xlatRecord = false;
    }
  }

 getXlatdata(){
  searchXlat({strXlatName: this.parentName})
.then(data =>{
  console.log('xlatData', data);
  this.ParentNameList = data;
  console.log('ParentNameList', JSON.parse(JSON.stringify(this.ParentNameList)));

})
.catch(error =>{
  console.log('Error', error);
})
  
 }
  

  // Manufacturer part Number data 
  handlePartNumbersearch(event) {
    window.clearTimeout(this.timer);
     console.log('clear',this.timer)
    this.partNumber = event.target.value;
    if (this.partNumber != '') {
      this.bidRecord = true;
      this.xlatRecord = false;
      this.emailRecord = false;
      this.timer= setTimeout(() => {
        this.getPartNumber();
      }, 500);
      console.log('timer',this.timer)
    }
    else {
      this.bidRecord = false;
    }
    console.log('partnumber', this.partNumber);
  }
//get manufacturer part number
 getPartNumber(){
 searchPartNumber({ strPartNumber: this.partNumber })
 .then(data =>{
    console.log('partnumberData',data);
    let uniqueArray = data.reduce((accumulator, current) => {

      if (!accumulator[current.Supplier_Part_Number__c]) {

        accumulator[current.Supplier_Part_Number__c] = current;

      }

      return accumulator;

    }, {});



    uniqueArray = Object.values(uniqueArray);

    console.log(uniqueArray);

   
      this.partNumberList = uniqueArray;
 })
 .catch(error =>{
  console.log('error',error);
 })
}
 
  //-----------------------------lead.......................
  handleLeadSearch(event) {
    console.log('inlead')
     window.clearTimeout(this.timer)
    this.lead = event.target.value;
    if (this.lead != '') {
     
      this.bidRecord = false;
      this.xlatRecord = false;
      this.emailRecord = false;
      this.leadRecord = true;
      this.accountRecord = false;
      this.timer = setTimeout(() => {
        this.getLead()
      }, 500);
      console.log('inleadif')
    }
    else {
      console.log('inleadlelse')

      this.leadRecord = false;
    }
    console.log('lead', this.lead);
  }
//get all the lead data 
  getLead(){
    searchLead({strLeads:this.lead })
    .then(data =>{
      console.log('leadData',data)
      this.leadList = data;
       console.log('leadlist', JSON.parse(JSON.stringify(this.leadList)));
    })
    .catch(error =>{
      console.log('error',error)
    })
  }

  

  //.........Account................................//

  handleAccountSearch(event) {
    console.log('inAccount')
    window.clearTimeout(this.timer)
    this.Account = event.target.value;
    if (this.Account != '') {
      this.bidRecord = false;
      this.xlatRecord = false;
      this.emailRecord = false;
      this.accountRecord = true;
      this.leadRecord = false;
      console.log('inaccountif')
      this.timer = this.timer = setTimeout(() => {
        this.getAccount()
      }, 500);
      console.log('inacc')
    }
    else {
      console.log('inaccountelse')

      this.accountRecord = false;
    
    }
    console.log('account', this.Account);
  }
//geyaccount data 
  getAccount(){
    searchAccount({strAccounts: this.Account})
    .then(data =>{
      console.log('data',data);
      this.accountList = data;
      console.log('accountList', JSON.parse(JSON.stringify(this.accountList)));

    })
    .catch(error =>{
      console.log('error',error);
    })
  }



  //.....................Email...........................//

  handleEmailSearch(event) {
    console.log('inemail')
     window.clearTimeout(this.timer)
    this.email = event.target.value;
    if (this.email != '') {
      this.bidRecord = false;
      this.xlatRecord = false;
      this.emailRecord = true;
      console.log('inemailif')
    }
    else {
      console.log('inemailelse')

      this.emailRecord = false;
      this.timer = setTimeout(() => {
        this.getEmail()
      }, 500);
    }
    console.log('email', this.email);
  }
  //get email
getEmail(){
  serachEmail({emails: this.email})
  .then(data =>{
    this.emailList = data;
  })
  .catch(error =>{
    console.log('Error', error);
  })
}
 
 

  fields = ['supplier_cleanup__c.Status__c', 'supplier_cleanup__c.Supplier_Status__c'];

  @wire(getRecord, { recordId: '$recordId', fields: '$fields' })
  wiredRecord({ error, data }) {
    if (data) {
      // Get the field values from the record data
      //this.field1Value = data.fields.ObjectApiName__c.Field1__c.value;
      this.field1Value = data.fields.Status__c.value;
      console.log('Status Value',this.field1Value);
      this.field2Value = data.fields.Supplier_Status__c.value;

      console.log('field1Value', this.field1Value);
      console.log('field2Value', this.field2Value);

      if (this.field2Value == 'Lead Exist') {
        this.showCheckbox = false;
        this.showLeadCheckbox = false;
        this.xlatId = null;
        // this.dispatchEvent(new RefreshEvent());
        console.log(' this.xlatId', this.xlatId)
      }
      if (this.field2Value == 'Account Exist') {
        this.showCheckbox = false;
        this.showLeadCheckbox = false;
      }
      if (this.field2Value == 'New Supplier') {
        this.showCheckbox = false;
        this.showLeadCheckbox = false;
      }


      if (this.field1Value == 'New' || this.field1Value == 'Pending') {
        // this.field2Value = data.fields.ObjectApiName__c.Field2__c.value;
        this.showcmp = true;
      }
      else {
        this.showcmp = false;
      }
    }
    else if (error) {
      this.showcmp = false;
      // Handle error if needed
      console.log('error---', error);
    }
    console.log('this.showcmp', this.showcmp);

  }
  //   handleSingleCheckboxSelect(event) {
  //     const boxes = this.template.querySelectorAll('lightning-input[data-key="singleSelectColumnCheckbox"]');

  //     boxes.forEach(box => box.checked = event.target.name === box.name);
  //     console.log('boxes',boxes);
  // }
  // handleSingleCheckboxSelect(event) {
  //   const boxes = Array.from(this.template.querySelectorAll('lightning-input[data-key="singleSelectColumnCheckbox"]'));

  //   boxes.forEach(box => (box.checked = event.target.name === box.name));
  //   console.log('boxes', boxes);
  //   console.log('boxes --', JSON.parse(JSON.stringify(boxes)));

  // }

  // handleSingleCheckboxSelect(event) {
  //   const clickedCheckbox = event.target;
  //  console.log('clickedCheckbox',clickedCheckbox);
  //   console.log('event.target',event.target.checked)

  //   const boxes = this.template.querySelectorAll('lightning-input[data-key="singleSelectColumnCheckbox"]');

  //   boxes.forEach(box => {
  //     if (box !== clickedCheckbox) {
  //       box.checked = false; // Uncheck all checkboxes except the clicked one
  //     }
  //   });

  //   console.log('boxes', boxes);
  // }

  handleSingleCheckboxSelect(event) {
    this.showUpdateButton = false;

    this.xlatId = event.target.dataset.id;
    const names = event.target.dataset.id1;
    console.log('xlatId', this.xlatId);
    console.log('names', names);

    const boxes = this.template.querySelectorAll('lightning-input[data-key="singleSelectColumnCheckbox"]');

    boxes.forEach(box => {
      box.checked = box.dataset.id === this.xlatId;
    });

  }


  selectXlat(event) {
    console.log('clicked');
    console.log('this.xlatId--', this.xlatId)
    updateSupplierCleanup({ recordIds: this.recordId, xlatIds: this.xlatId, leadIds: this.leadId })
      .then(result => {
        this.xlatRecord = false;
        this.showXlatInput = false;

        this.dispatchEvent(new RefreshEvent());
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Success',
            message: 'Record updated successfully',
            variant: 'success'
          })
        );

        console.log('result', result)
      })

      .catch(error => {
        console.log('error', error)

      })
  }

  //For Lead Checkbox 
  handleLeadCheckboxSelect(event) {
    this.showLeadUpdateButton = true;
    this.leadId = event.target.dataset.id;
    const name = event.target.dataset.id1;

    console.log('Lead ID ', this.leadId);
    console.log('Lead Names', name);

    const boxes = this.template.querySelectorAll('lightning-input[data-key="singleLeadSelectColumnCheckbox"]');

    boxes.forEach(box => {
      box.checked = box.dataset.id === this.leadId;
    });

  }

  selectLead(event) {
    console.log('clicked');
    console.log('this.leadId--', this.leadId)
    updateSupplierCleanup({ recordIds: this.recordId, xlatIds: this.xlatId, leadIds: this.leadId })
      .then(result => {
        this.leadRecord = false;
        this.showLeadInput = false;

        this.dispatchEvent(new RefreshEvent());
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Success',
            message: 'Record updated successfully',
            variant: 'success'
          })
        );

        console.log('result', result)
      })

      .catch(error => {
        console.log('error', error)

      })
  }

  // handleUpdate() {
  //   // Get the current value of the "Supplier_XLAT__c" field
  //   const currentDescription = getFieldValue(this.record, SUPPLIER_XLAT_FIELD);
  //   console.log('currentDescription', currentDescription);

  //   // Calculate the new value you want to set
  //   const newDescription = this.xlatId; // Replace this with your desired new description
  //   console.log('newDescription', newDescription);

  //   // Perform the update using the updateRecord function
  //   const fields = {};
  //   fields[SUPPLIER_XLAT_FIELD.fieldApiName] = newDescription;

  //   const recordInput = { fields };
  //   console.log('recordInput', JSON.parse(JSON.stringify(recordInput)));

  //   updateRecord(recordInput)
  //     .then((updatedRecord) => {
  //       // Log the updated record to verify the new value
  //       console.log('Updated record:', updatedRecord);

  //       // Record is updated successfully
  //       this.dispatchEvent(
  //         new ShowToastEvent({
  //           title: 'Success',
  //           message: 'Record updated successfully',
  //           variant: 'success'
  //         })
  //       );
  //     })
  //     .catch((error) => {
  //       // Handle error if the record update fails
  //       console.error('Error updating record:', error);
  //       this.dispatchEvent(
  //         new ShowToastEvent({
  //           title: 'Error',
  //           message: 'Error updating record',
  //           variant: 'error'
  //         })
  //       );
  //     });
  // }

}