import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

// METHODS
import createPaymentMethod from '@salesforce/apex/B2BCreditCardsController.createPaymentMethod';

// LABELS
import B2B_Add_Card_Form_Loading from '@salesforce/label/c.B2B_Add_Card_Form_Loading';
import B2B_Add_Card_Form_Cancel from '@salesforce/label/c.B2B_Add_Card_Form_Cancel';
import B2B_Add_Card_Form_Save from '@salesforce/label/c.B2B_Add_Card_Form_Save';
import B2B_Add_Card_Form_Add_Success from '@salesforce/label/c.B2B_Add_Card_Form_Add_Success';
import B2B_Add_Card_Form_Add_Error from '@salesforce/label/c.B2B_Add_Card_Form_Add_Error';

const CLOSE_EVENT = 'close';
const REFRESH_EVENT = 'refresh';

export default class B2bAddCardForm extends LightningElement {
    @api publicKey = null;
    @api publicExponent = null;

    @track labels = {
        loading: B2B_Add_Card_Form_Loading,
        cancel: B2B_Add_Card_Form_Cancel,
        save: B2B_Add_Card_Form_Save,
        addSuccess: B2B_Add_Card_Form_Add_Success,
        addError: B2B_Add_Card_Form_Add_Error,
    };

    @track isLoading = false;

    // HANDLERS
    handleClickClose() {
        let component = this.template.querySelector('c-b2b-form-credit-card');
        if (component) {
            UTILS.dispatchEvent(this, CLOSE_EVENT);
            component.resetForm();
        }
    }

    async handleClickSave() {
        let component = this.template.querySelector('c-b2b-form-credit-card');
        if (!component || !component.reportValidity()) {
            return;
        }

        this.isLoading = true;
        let data = component.collectData();

        if (IS.objectNotEmpty(data)) {
            let response = await UTILS.doRequest(createPaymentMethod, {
                card: {
                    cardName : data.name,
                    cardType : data.type,
                    cardNumber : UTILS.encodeMessage(data.number, this.publicKey, this.publicExponent),
                    expiryMonth : UTILS.encodeMessage(data.month, this.publicKey, this.publicExponent),
                    expiryYear  : UTILS.encodeMessage(data.year, this.publicKey, this.publicExponent),
                    cvc : UTILS.encodeMessage(data.cvv, this.publicKey, this.publicExponent),
                    isDefault : data.isDefault
                }
            });
            
            if (UTILS.responseSuccess(response)) {
                UTILS.showToast('success', this.labels.addSuccess);
                UTILS.dispatchEvent(this, REFRESH_EVENT);
            } else {
                UTILS.showToast('error', this.labels.addError);
            }
        }
        this.isLoading = false;
    }

}