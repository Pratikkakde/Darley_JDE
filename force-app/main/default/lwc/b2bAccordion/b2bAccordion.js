import { LightningElement, api } from 'lwc';
import { UTILS } from 'c/b2bUtils';

export default class B2bAccordion extends LightningElement {
    @api componentId = null;
    @api show = false;

    // HANDLERS
    handleClickHeader() {
        UTILS.dispatchEvent(this, 'expand', {
            componentId: this.componentId
        });
    }

}