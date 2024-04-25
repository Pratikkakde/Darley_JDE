import { LightningElement,api } from 'lwc';
import makeCallout from '@salesforce/apex/calloutOrderStatus.makeCallout';
import { RefreshEvent } from 'lightning/refresh';

export default class IntegrationOrderStatusRetrieve extends LightningElement {
    @api recordId;
    
    connectedCallback() {
      this.callout();
       
      }
    
      callout() {
        makeCallout({ OrderRecordId: this.recordId })
          .then(result => {
            // Handle successful response
            console.log('makeCallout class executed');
            this.forceRefresh();
          })
          .catch(error => {
            // Handle error
          });
      }

      forceRefresh() {
        // refresh the standard Detail list
        setTimeout(() => {
          this.dispatchEvent(new RefreshEvent()); 
        }, 5000);   
     }

}