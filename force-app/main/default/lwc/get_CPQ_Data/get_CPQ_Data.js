import { LightningElement, api} from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getcpqDataJs from '@salesforce/apex/GetCPQdataContro.updateTheBidLIneAndTracWithQuoteAndLIne';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class Get_CPQ_Data extends LightningElement {
@api recordId;
    handleClick(){
            this.showNotification();

      getcpqDataJs({idBidTracker:this.recordId});
   this.dispatchEvent(new CloseActionScreenEvent());



    }
    closeModal() {

           this.dispatchEvent(new CloseActionScreenEvent());

    }
showNotification() {
        console.log('IN Show notify');


        console.log('IN show notify else');

        const evtt = new ShowToastEvent({
            title: "Success",
            message: "Record Saved Successfully",
            variant: "success",
        });
        this.dispatchEvent(evtt);

    }

 


}