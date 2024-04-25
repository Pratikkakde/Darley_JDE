import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { UTILS, IS } from 'c/b2bUtils';

// LABELS
import B2B_Guest_Cart_Total_Title from '@salesforce/label/c.B2B_Guest_Cart_Total_Title';
import B2B_Guest_Cart_Total_Total_Label from '@salesforce/label/c.B2B_Guest_Cart_Total_Total_Label';
import B2B_Guest_Cart_Total_Button_Label from '@salesforce/label/c.B2B_Guest_Cart_Total_Button_Label';

const LABELS = {
    title: B2B_Guest_Cart_Total_Title,
    totalLabel: B2B_Guest_Cart_Total_Total_Label,
    buttonLabel: B2B_Guest_Cart_Total_Button_Label,
    requestForQuote: 'Request for Quote',
};

const COMPONENT_NAME = 'b2b-guest-cart-total';
const LOGIN_ROUTE = '/login';

export default class B2bGuestCartTotal extends NavigationMixin(LightningElement) {
    @api recordId = null;
    @api currencyIsoCode = null;
    @api fields = [];
    @api total = 0;
    @api disabled = false;

    @track labels = LABELS;
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper}`;
    }

    get getFields() {
        let result = [];
        if (IS.arrayNotEmpty(this.fields)) {
            this.fields.forEach((item) => {
                if (
                    IS.stringNotEmpty(item.label) &&
                    IS.numeric(+item.value)
                ) {
                    result.push({
                        label: item.label,
                        value: +item.value,
                        class: `b2b-guest-cart-total__item b2b-guest-cart-total__item_${
                            UTILS.onlyLettersAndNumbers(item.label).toLowerCase()
                        }`
                    });
                }
            });
        }
        return result;
    }

    // HANDLERS
    handleClickProceedToCheckout() {
        if (!this.disabled) {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: { url: LOGIN_ROUTE }
            }, true);
        }
    }

}