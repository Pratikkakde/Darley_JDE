import { LightningElement, api } from 'lwc';

export default class B2bPaymentItem extends LightningElement {
    @api payment = null;
    @api showDate = false;

    // GETTERS
    get showComponent() {
        return this.payment && this.payment.id && this.payment.name;
    }

    get getShowDate() {
        return this.showComponent && this.showDate && this.payment.month && this.payment.year;
    }

}