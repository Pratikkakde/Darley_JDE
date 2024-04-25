import { LightningElement, track, api } from 'lwc';
import { effectiveAccount } from 'commerce/effectiveAccountApi';
import { loadEffectiveAccounts } from 'commerce/effectiveAccountApiInternal';
import { Store, StoreAdapter } from 'experience/store';

/**
* @slot testregion
*/

export default class B2bTest extends LightningElement {

    @track testVar2 = 'testVar2';

    @api
    get testVar1() {
        return 'testVar1';
    }

    get testVar3() {
        return 'testVar3';
    }

    connectedCallback() {
        console.log('effectiveAccount', effectiveAccount);
        console.log('effectiveAccount', effectiveAccount.accountId);
        console.log('loadEffectiveAccounts', loadEffectiveAccounts);
        // console.log('Store', Store); // Class
        // console.log('StoreAdapter', StoreAdapter); // Class
        // console.log('getState', getState);
        // StoreAdapter()
        //     .then((result) => {
        //         console.log('result', result);
        //     })
        //     .catch((err) => {
        //         console.log('err', err);
        //     });
        loadEffectiveAccounts()
            .then((result) => {
                console.log('result', result);
            })
            .catch((err) => {
                console.log('err', err);
            });
    }

    handleCloseAlert() {
        console.log('handleCloseAlert()');
    }
}