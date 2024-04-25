import { LightningElement, track } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';
  
import validateCartProducts from '@salesforce/apex/B2BValidateCartProductsController.validateCartProducts';

export default class B2bValidateCartProducts extends LightningElement {

    @track isLoading = false;
    @track sessionContext = {};

    // LIFECYCLES
    async connectedCallback() {
        this.sessionContext = await UTILS.getSessionContext();
        await this.init();
    }

    async init() {
        this.isLoading = true;
        if (
            IS.objectNotEmpty(this.sessionContext)
            && IS.stringNotEmpty(this.sessionContext.userId)
            && IS.stringNotEmpty(this.sessionContext.effectiveAccountId)
            && IS.true(this.sessionContext.isLoggedIn)
        ) {
            let response = await UTILS.doRequest(validateCartProducts, {
                effectiveAccountId: this.sessionContext.effectiveAccountId
            });
            if (UTILS.responseSuccess(response)) {
                let data = response.responseData;
                if(data && IS.arrayNotEmpty(data)){
                    data.forEach(element => {
                        UTILS.deleteItemFromCartLWR(element.Id);
                    });
                }else{
                    UTILS.refreshCartLWR();
                }
            }
        };
        this.isLoading = false;
    }
    
}