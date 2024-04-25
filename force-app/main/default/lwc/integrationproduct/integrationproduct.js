import { LightningElement, api } from 'lwc';
import makeCallout from '@salesforce/apex/CalloutToRestProductRetrieve.makeCallout';
import { RefreshEvent } from 'lightning/refresh';

export default class Integrationproduct extends LightningElement {
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

      forceRefresh() {
        // refresh the standard Detail list
        setTimeout(() => {
          this.dispatchEvent(new RefreshEvent()); 
        }, 5000);   
     }

}