import { LightningElement, track } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

// METHODS
import getCreditCards from '@salesforce/apex/B2BCreditCardsController.getCreditCards';
import deleteCreditCardFromCustomer from '@salesforce/apex/B2BCreditCardsController.deleteCreditCardFromCustomer';
import makeCardDefault from '@salesforce/apex/B2BCreditCardsController.makeCardDefault';

// LABELS
import Close from '@salesforce/label/c.B2B_Close';
import Cancel from '@salesforce/label/c.B2B_Cancel';
import Confirm from '@salesforce/label/c.B2B_Confirm';
import Payment_Methods from '@salesforce/label/c.B2B_Payment_Methods';
import Add_credit_card from '@salesforce/label/c.B2B_Add_credit_card';
import Add_Your_Card from '@salesforce/label/c.B2B_Add_Your_Card';
import Click_to_add_a_new_Credit_Card from '@salesforce/label/c.B2B_Click_to_add_a_new_Credit_Card';
import The_card_was_successfully_saved_as_the_default_card from '@salesforce/label/c.B2B_The_card_was_successfully_saved_as_the_default_card';
import Failed_to_save_the_card_as_the_default from '@salesforce/label/c.B2B_Failed_to_save_the_card_as_the_default';
import The_credit_card_has_been_successfully_deleted from '@salesforce/label/c.B2B_The_credit_card_has_been_successfully_deleted';
import The_credit_card_could_not_be_deleted_Try_again_later from '@salesforce/label/c.B2B_The_credit_card_could_not_be_deleted_Try_again_later';
import Are_you_sure_you_want_to_delete from '@salesforce/label/c.B2B_Are_you_sure_you_want_to_delete';
import ending_in from '@salesforce/label/c.B2B_ending_in';

const COMPONENT_NAME = 'b2b-payment-management';
const SUCCESS = 'success';

const ADD = 'add';
const DELETE = 'delete';

const LABELS = {
    loading: 'Loading',
    close: Close,
    cancel: Cancel,
    confirm: Confirm,
    title: Payment_Methods,
    addCreditCard: Add_credit_card,
    addYourCard: Add_Your_Card,
    clickToAddCreditCard: Click_to_add_a_new_Credit_Card,
    setDefaultCardSuccess: The_card_was_successfully_saved_as_the_default_card,
    setDefaultCardError: Failed_to_save_the_card_as_the_default,
    deleteCreditCardSuccess: The_credit_card_has_been_successfully_deleted,
    deleteCreditCardError: The_credit_card_could_not_be_deleted_Try_again_later,
    areYouSureYouWantToDelete: Are_you_sure_you_want_to_delete,
    endingIn: ending_in,
    deleteCard: 'Delete Card',
};

export default class B2bPaymentManagement extends LightningElement {
    @track isLoading = true;
    @track labels = LABELS;
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);

    @track list = [];
    @track modal = {
        show: false,
        paymentMethodId: null,
        type: null,
        cardType: null,
        cardNumber: null,
    };

    publicKey = null;
    publicExponent = null;

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper}`;
    }

    get isModalTypeDelete() {
        return this.modal.type === DELETE;
    }

    get isModalTypeAdd() {
        return this.modal.type === ADD;
    }

    // LIFECYCLES
    connectedCallback() {
        this.getInitialData();
    }

    // METHODS
    getInitialData() {
        this.isLoading = true;

        getCreditCards()
            .then((response) => {
                let data = UTILS.responseData(response);
                this.parseResponse(data);
                this.isLoading = false;
            })
            .catch((error) => {
                console.error(error);
                this.isLoading = false;
            });
    }

    parseResponse(data) {
        let list = [];
        if (data) {
            data.cards.forEach((item) => {
                let newItem = {
                    cardName: IS.stringNotEmpty(item.cardName) ? item.cardName : null,
                    paymentMethodId: IS.stringNotEmpty(item.paymentMethodId) ? item.paymentMethodId : null,
                    cardNumber: IS.stringNotEmpty(item.cardNumber) ? item.cardNumber : null,
                    cardType: IS.stringNotEmpty(item.cardType) ? item.cardType : null,
                    expiryMonth: IS.stringNotEmpty(item.expiryMonth) ? item.expiryMonth : null,
                    expiryYear: IS.stringNotEmpty(item.expiryYear) ? item.expiryYear : null,
                    isDefault: item.isDefault ? true : false
                };
                if (newItem.paymentMethodId &&
                    newItem.cardNumber &&
                    newItem.cardType &&
                    newItem.paymentMethodId
                ) {
                    list.push(newItem);
                }
            });
        }
        this.list = list;
        this.publicKey = data.publicKey;
        this.publicExponent = data.publicExponent;
    }

    closeModal() {
        this.modal.show = false;
        this.modal.paymentMethodId = null;
        this.modal.type = null;
        this.modal.cardType = null;
        this.modal.cardNumber = null;
    }

    // HANDLERS
    handleClickAddCreditCard() {
        this.modal.type = ADD;
        this.modal.show = true;
    }

    handleClickDelete(event) {
        let paymentMethodId = event.detail;
        if (!IS.stringNotEmpty(paymentMethodId)) return;

        this.modal.type = DELETE;
        this.modal.paymentMethodId = paymentMethodId;
        this.list.forEach((item) => {
            if (paymentMethodId === item.paymentMethodId) {
                this.modal.cardType = item.cardType;
                this.modal.cardNumber = item.cardNumber;
            }
        });
        this.modal.show = true;
    }

    async handleClickDefault(event) {
        let paymentMethodId = event.detail;
        if (!IS.stringNotEmpty(paymentMethodId)) return;

        this.isLoading = true;

        await makeCardDefault({
            cardId: paymentMethodId
        })
            .then((response) => {
                if (UTILS.responseSuccess(response)) {
                    UTILS.showToast('success', LABELS.setDefaultCardSuccess);
                }
            })
            .catch((error) => {
                console.error(error);
                UTILS.showToast('error', LABELS.setDefaultCardError);
            });

        this.getInitialData();
    }

    handleClickModalClose() {
        this.closeModal();
    }

    async handleClickModalDelete() {
        if (!IS.stringNotEmpty(this.modal.paymentMethodId)) return;

        this.isLoading = true;

        await deleteCreditCardFromCustomer({
            cardId: this.modal.paymentMethodId
        })
            .then((response) => {
                if (UTILS.responseSuccess(response)) {
                    UTILS.showToast('success', LABELS.deleteCreditCardSuccess);
                }
            })
            .catch((error) => {
                console.error(error);
                UTILS.showToast('error', LABELS.deleteCreditCardError);
            });

        this.getInitialData();
        this.closeModal();
    }

    handleChangeAddCard(event) {
        this.isLoading = true;
        this.getInitialData(); 
        this.closeModal();
    }
}