import { LightningElement, api,track } from 'lwc';
import clonequote from '@salesforce/apex/Quote_Clone.clonequote';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class CloneQuote extends LightningElement {
    @api recordId;
    @track qulist ;
    handleClick(){
        clonequote({quoteId:this.recordId}
            )
        .then(result =>{
            this.qulist = result;
        })
        .catch(error =>{
            this.errorMsg = error;
        })
    }
    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
      }
      

   
}