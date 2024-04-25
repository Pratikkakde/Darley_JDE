import { LightningElement, api  } from 'lwc';
import makeCallout from '@salesforce/apex/CalloutRestAPiRetriveAB.makeCallout';
import { updateRecord } from 'lightning/uiRecordApi';
import { RefreshEvent } from 'lightning/refresh';


export default class Integrationcmp extends LightningElement {
    @api recordId;
  
    connectedCallback() {
      this.callout();
      }
    
      callout() {
        makeCallout({ recordId: this.recordId })
          .then(result => {
            // Handle successful response
            console.log('makeCallout class executed');
            this.forceRefresh();
          })
          .catch(error => {
            // Handle error
          });
      }

      updateRecordView() {

        setTimeout(() => {
          this.dispatchEvent(new CloseActionScreenEvent());
          updateRecord({ fields: { Id: this.recordId }})
          console.log('updateRecordView function executed');
        }, 4000); 
      }

       // $A.get("e.force:refreshView").fire();
       forceRefresh() {
         // refresh the standard Detail list
         setTimeout(() => {
           this.dispatchEvent(new RefreshEvent()); 
         }, 5000);   
      }

    //   updateRecordView() {
    //     setTimeout(() => {
    //          eval("$A.get('e.force:refreshView').fire();");
    //     }, 4000); 
    //  }

}