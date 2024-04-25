import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Openpumpcmp  extends NavigationMixin(LightningElement){
    @api recordId;

    nextButton(){
     this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
              
                apiName: 'Pump_page'
            },
            state: {
                c__recordId:this.recordId
            }
        }).then(() => {
            location.reload();
        }).catch(error => {
            console.error('Error navigating to page:', error);
        });
    
}
}