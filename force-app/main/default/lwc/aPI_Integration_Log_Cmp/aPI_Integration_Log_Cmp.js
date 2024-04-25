import { LightningElement, api} from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import processData from '@salesforce/apex/IntegrationLogDataController.processData';
import { updateRecord } from 'lightning/uiRecordApi';

export default class API_Integration_Log_Cmp extends LightningElement{
    @api recordId;
    loaded;
    result;


      closeAction() {
        this.callout();
        this.loaded = true;
        //this.updateRecordView();
    }

    
   
      callout() {  
        processData({ recordID: this.recordId })

          .then(result => {
            // Handle successful response
            this.result = result;
            this.loaded = false;
            // this.dispatchEvent(new CloseActionScreenEvent());
            this.updateRecordView();

          })
          .catch(error => {
            // Handle error
          });
          
      }


      updateRecordView() {

        setTimeout(() => {
          this.dispatchEvent(new CloseActionScreenEvent());
          updateRecord({ fields: { Id: this.recordId }})
        }, 1500); 

        // setTimeout(() => {
        //   //eval("$A.get('e.force:refreshView').fire();");
        //   updateRecord({ fields: { Id: this.recordId }})
        //   console.log('force Refresh after 3.5');
        // }, 3500); 
        
     }
}