import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

// LABELS
import B2B_Pagination_Go_To_Previous from '@salesforce/label/c.B2B_Pagination_Go_To_Previous';
import B2B_Pagination_Go_To_Page from '@salesforce/label/c.B2B_Pagination_Go_To_Page';
import B2B_Pagination_Go_To_Next from '@salesforce/label/c.B2B_Pagination_Go_To_Next';

const LABELS = {
    goToPrevious: B2B_Pagination_Go_To_Previous,
    goToPage: B2B_Pagination_Go_To_Page,
    goToNext: B2B_Pagination_Go_To_Next,
    separator: '...',
};

const CHANGE_EVENT = 'change';

export default class B2bPagination extends LightningElement {
    @api currentPage = null;
    @api maxPage = null;
    @api disabled = false;

    @track labels = LABELS;

    // GETTERS
    get getMaxPage() {
        return IS.integer(this.maxPage) ? this.maxPage : null;
    }

    get showComponent() {
        return IS.integer(this.getMaxPage) &&
            this.getMaxPage > 1;
    }

    get getPreviousButtonDisabled() {
        return IS.integer(this.currentPage) &&
            this.currentPage === 1 || 
            IS.true(this.disabled);
    }

    get getPreviousButtonTitle() {
        return !this.getPreviousButtonDisabled
            ? LABELS.goToPrevious
            : null;
    }

    get getFirstButtonActive() {
        return IS.integer(this.currentPage) &&
            this.currentPage === 1;
    }

    get getFirstButtonTitle() {
        return !(this.getFirstButtonActive || this.disabled)
            ? UTILS.prepareLabel(LABELS.goToPage, ['1'])
            : null;
    }

    get showPreviousSeparator() {
        return IS.integer(this.getRangeFirstNumber) &&
            this.getRangeFirstNumber > 2;
    }

    get getRangeFirstNumber() {
        if (IS.integer(this.currentPage) && IS.integer(this.getMaxPage)) {
            if (this.getMaxPage <= 7) {
                return 2;

            } else if (this.currentPage <= 4) {
                return 2;

            } else if (this.currentPage > (this.getMaxPage - 3)) {
                return this.getMaxPage - 4;

            } else {
                return this.currentPage - 1;
            }
        }
        return null;
    }

    get getRangeLastNumber() {
        if (IS.integer(this.currentPage) && IS.integer(this.getMaxPage)) {
            if (this.getMaxPage <= 7) {
                return this.getMaxPage - 1;

            } else if (this.currentPage <= 4) {
                return 5;

            } else if (this.currentPage >= (this.getMaxPage - 3)) {
                return this.getMaxPage - 1;

            } else {
                return this.currentPage + 1;
            }
        }
        return null;
    }

    get getRangeOptions() {
        let result = [];
        if (IS.integer(this.getMaxPage) && this.getMaxPage === 2) return result;

        if (
            IS.integer(this.getMaxPage) &&
            IS.integer(this.currentPage) &&
            IS.integer(this.getRangeFirstNumber) &&
            IS.integer(this.getRangeLastNumber)
        ) {
            for (let i = this.getRangeFirstNumber; i <= this.getRangeLastNumber; i++) {
                if (i !== 1 && i !== this.getMaxPage) {
                    let newItem = {
                        number: i,
                        disabled: IS.true(this.disabled) ? true : null,
                        title: !(i === this.currentPage || IS.true(this.disabled))
                            ? UTILS.prepareLabel(LABELS.goToPage, [i])
                            : null,
                        active: i === this.currentPage,
                    };
                    result.push(newItem);
                }
            }
        }
        return result;
    }

    get showNextSeparator() {
        return IS.integer(this.getRangeLastNumber) &&
            IS.integer(this.getMaxPage) &&
            this.getRangeLastNumber < (this.getMaxPage - 1);
    }

    get getLastButtonActive() {
        return IS.integer(this.currentPage) &&
            IS.integer(this.getMaxPage) &&
            this.currentPage === this.getMaxPage;
    }

    get getLastButtonTitle() {
        return !(this.getLastButtonActive || this.disabled)
            ? UTILS.prepareLabel(LABELS.goToPage, [this.getMaxPage])
            : null;
    }

    get getNextButtonDisabled() {
        return IS.integer(this.currentPage) &&
            IS.integer(this.getMaxPage) &&
            this.currentPage === this.getMaxPage || 
            IS.true(this.disabled);
    }

    get getNextButtonTitle() {
        return !this.getNextButtonDisabled
            ? LABELS.goToNext 
            : null;
    }

    // METHODS
    changePage(pageNumber) {
        if (!this.disabled) {
            UTILS.dispatchEvent(this, CHANGE_EVENT, pageNumber);
        }
    }

    // HANDLERS
    handleClickToPrevious() {
        if (
            !IS.true(this.disabled) &&
            IS.integer(this.currentPage) &&
            this.currentPage > 1
        ) {
            this.changePage(this.currentPage - 1);
        }
    }

    handleClickToNext() {
        if (
            !IS.true(this.disabled) &&
            IS.integer(this.currentPage) &&
            IS.integer(this.getMaxPage) &&
            this.currentPage < this.getMaxPage
        ) {
            this.changePage(this.currentPage + 1);
        }
    }

    handleClickToButton(event) {
        if (
            !IS.true(this.disabled) &&
            IS.integer(this.getMaxPage) &&
            IS.integer(this.currentPage) &&
            IS.stringNotEmpty(event.target.dataset.number)
        ) {
            let number = +event.target.dataset.number;
            if (
                IS.integer(number) &&
                number >= 1 &&
                number <= this.getMaxPage &&
                number != this.currentPage
            ) {
                this.changePage(number);
            }
        }
    }

}