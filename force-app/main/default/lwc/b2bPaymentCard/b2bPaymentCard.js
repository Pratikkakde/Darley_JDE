import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

//LABELS
import Delete from '@salesforce/label/c.B2B_Delete';
import Click_to_Delete_Cart from '@salesforce/label/c.B2B_Click_to_Delete_Cart';
import Set_as_Default from '@salesforce/label/c.B2B_Set_as_Default';
import Click_to_Set_as_Default from '@salesforce/label/c.B2B_Click_to_Set_as_Default';
import Credit_Card_ending_in from '@salesforce/label/c.B2B_Credit_Card_ending_in';

const COMPONENT_NAME = 'b2b-payment-card';

const LABELS = {
    delete: Delete,
    clickToDeleteCart: Click_to_Delete_Cart,
    setAsDefault: Set_as_Default,
    clickToSetAsDefault: Click_to_Set_as_Default,
    credit_Card_ending_in: Credit_Card_ending_in
};

export default class B2bPaymentCard extends LightningElement {
    @api card = {};

    @track labels = LABELS;
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper}`;
    }

    get cardNickName() {
        return IS.objectProperty(this.card, 'cardName') &&
        IS.stringNotEmpty(this.card.cardName)
            ? this.card.cardName
            : null;
    }

    get name() {
        return IS.objectProperty(this.card, 'cardType') &&
            IS.stringNotEmpty(this.card.cardType)
                ? this.card.cardType
                : null;
    }

    get type() {
        return IS.stringNotEmpty(this.name)
            ? this.name.toLowerCase()
            : null;
    }

    get isDefault() {
        return IS.objectProperty(this.card, 'isDefault')
            ? this.card.isDefault
            : false;
    }

    get cardNumber() {
        return IS.objectProperty(this.card, 'cardNumber') &&
            IS.stringNotEmpty(this.card.cardNumber)
                ? `${this.labels.credit_Card_ending_in} ${this.card.cardNumber}`
                : null;
    }

    get cardDate() {
        return IS.objectProperty(this.card, 'expiryMonth') &&
            IS.objectProperty(this.card, 'expiryYear') &&
            IS.stringNotEmpty(this.card.expiryMonth) &&
            IS.stringNotEmpty(this.card.expiryYear)
                ? `${this.card.expiryMonth}/${this.card.expiryYear}`
                : null;
    }

    // METHODS
    executeEvent(eventName) {
        let paymentMethodId = IS.objectProperty(this.card, 'paymentMethodId')
            ? this.card.paymentMethodId
            : null;

        if (!IS.stringNotEmpty(paymentMethodId)) return;

        this.dispatchEvent(
            new CustomEvent(eventName, { detail: paymentMethodId })
        );
    }

    // HANDLERS
    handleClickDelete() {
        this.executeEvent('delete');
    }
    
    handleClickSetAsDefault() {
        this.executeEvent('default');
    }

}