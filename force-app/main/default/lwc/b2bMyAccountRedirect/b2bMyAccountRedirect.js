import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { UTILS } from 'c/b2bUtils';

export default class B2bMyAccountRedirect extends NavigationMixin(LightningElement) {
    effectiveAccountId = null;
    // LIFECYCLES
    async connectedCallback() {
        this.effectiveAccountId = await UTILS.getEffectiveAccountId();
        UTILS.navigateTo(`/account/${this.effectiveAccountId}`);
    }
}