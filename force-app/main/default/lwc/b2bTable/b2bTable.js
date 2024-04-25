import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { UTILS, IS } from 'c/b2bUtils'; 

import NO_ITEMS_TO_DISPLAY from '@salesforce/label/c.B2B_No_items_to_display';
import EMPTY_FIELD from '@salesforce/label/c.B2B_Empty_Field';

export default class B2bTable extends NavigationMixin(LightningElement) {
    @api tableHeaders = [];
    @api tableData = [];
    @api tableViewData = [];
    @api tableViewMobileData = [];
    @api isLoading = false;
    @api noItemsLabel = NO_ITEMS_TO_DISPLAY;
    @api emptyField = EMPTY_FIELD;

    @track isFirstRender = true;

    // LIFECYCLES
    renderedCallback() {
        if (this.isFirstRender) {
            this.isFirstRender = false;
            this.addCustomCssStyles();
        }
    }

    // METHODS
    addCustomCssStyles() {
        let styleText = `
            .list-th-action lightning-icon svg.slds-icon {
                display: none;
            }

            .list__action.list__is-order lightning-icon svg.slds-icon {
                fill: #706E6B;
                display: block;
            }

            @media (max-width: 767.98px) {

                .b2b-quantity__wrapper .slds-form-element__control {
                    width: 100%;
                }
                
                .b2b-quantity__wrapper .slds-button {
                    width: 20%;
                }
            
                .b2b-quantity__wrapper .slds-input {
                    width: 100%;
                }
            }
        `;

        styleText = UTILS.prepareString(styleText);
        if (IS.stringNotEmpty(styleText)) {
            let styleElement = document.createElement('style');
            styleElement.innerText = styleText;
            let parenNode = this.template.querySelector(`.${UTILS.customCssContainer}`);
            if (parenNode) {
                while (parenNode.firstChild) {
                    parenNode.removeChild(parenNode.firstChild);
                }
                parenNode.appendChild(styleElement);
            }
        }
    }

    navigateToUrl(url) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: { url }
        });
    }

    @api
    validateInputs(items) {
        let isValid = true;

        if (!IS.arrayNotEmpty(items)) {
            return isValid;
        }

        items.forEach(searchElement => {
            let inputFields = this.template.querySelectorAll(searchElement);
            inputFields.forEach(inputField => {
                if(!inputField.checkValidity()) {
                    inputField.reportValidity();
                    isValid = false;
                }
            });
        });

        return isValid;
    }

    // HANDLERS
    handleHeaderSortClick(event) {
        if (this.isLoading) return;
        UTILS.dispatchEvent(this, 'sorted', event.currentTarget.dataset.field);
    }

    handleLinkClick(event) {
        this.navigateToUrl(event.target.dataset.url);
    }

    handleArrowButtonClick(event) {
        if (this.isLoading) return;
        UTILS.dispatchEvent(this, 'expand', event.currentTarget.dataset.id);
    }

    handleCheckboxClick(event) {
        if (this.isLoading) return;
        UTILS.dispatchEvent(this, 'checkbox', {
            id: event.currentTarget.dataset.id,
            action: event.target.checked
        });
    }

    handlePicklistChange(event) {
        if (this.isLoading) return;
        UTILS.dispatchEvent(this, 'picklist', {
           id: event.currentTarget.dataset.id,
           value: event.currentTarget.value
        });
    }

    handlePicklistQuantity(event) {
        if (this.isLoading) return;
        UTILS.dispatchEvent(this, 'quantity', {
           id: event.currentTarget.dataset.id,
           value: event.currentTarget.value
        });
    }

    handleButtonClick(event) {
        if (this.isLoading) return;
        UTILS.dispatchEvent(this, 'buttonclick', {
            id: event.target.dataset.id,
            action: event.target.dataset.action
        });
    }

}