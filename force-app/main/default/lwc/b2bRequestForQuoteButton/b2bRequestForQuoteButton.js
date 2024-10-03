import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { UTILS, IS } from 'c/b2bUtils';

import isRequestQuoteEnabled from '@salesforce/apex/B2BRequestForQuoteController.isRequestQuoteEnabled';

const LABELS = {
    requestForQuote: 'Request for Quote',
};

const REQUEST_FOR_QUOTE_ROUTE = 'request-for-quote';

export default class B2bRequestForQuoteButton extends NavigationMixin(LightningElement) {
    @track labels = LABELS;
    @track isLoading = false;
    @track sessionContext = {};
    @track isRequestForQuoteAvailable = false;

    communityURL;

    // LIFECYCLES
    async connectedCallback() {
        this.sessionContext = await UTILS.getSessionContext();
        await this.getInitialData();
    }

    async getInitialData() {
        if (this.isLoading) {
            this.clickEventListenerFunction();
            return;
        }

        this.isLoading = true;
        let isRequestForQuoteAvailable = false;
        if (
            IS.objectNotEmpty(this.sessionContext)
            && IS.stringNotEmpty(this.sessionContext.userId)
            && IS.stringNotEmpty(this.sessionContext.effectiveAccountId)
            && IS.true(this.sessionContext.isLoggedIn)
        ) {
            let response = await UTILS.doRequest(isRequestQuoteEnabled, {
                effectiveAccountId: this.sessionContext.effectiveAccountId
            });
            if (UTILS.responseSuccess(response)) {
                isRequestForQuoteAvailable = IS.true(response.responseData.isCartAvailable) ? true : false;
                this.communityURL = response.responseData.communityURL;
            }
        }

        this.isRequestForQuoteAvailable = isRequestForQuoteAvailable;
        this.isLoading = false;
    }

    // HANDLERS
    handleClickButton(event) {
        if (this.isLoading) {
            event.preventDefault();
        } else if (this.communityURL) {
            window.open(this.communityURL + REQUEST_FOR_QUOTE_ROUTE, '_self');
        }
    }

}