import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

import _initFilter from "@salesforce/apex/B2BQuoteManagementController.initFilter";
import _getQuotes from "@salesforce/apex/B2BQuoteManagementController.getQuotes";

import communityBasePath from "@salesforce/community/basePath";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import QUOTES from '@salesforce/label/c.B2B_Quotes';
import SEARCH from '@salesforce/label/c.B2B_Search';
import DATE_FROM from '@salesforce/label/c.B2BRequestedDateFrom';
import DATE_TO from '@salesforce/label/c.B2BRequestedDateTo';

import QUOTE_NUMBER from '@salesforce/label/c.B2B_Quote_Number';
import DATE_REQUESTED from '@salesforce/label/c.B2B_Date_Requested';
import EXPIRATION_DATE from '@salesforce/label/c.B2B_Expiration_Date';
import STATUS from '@salesforce/label/c.B2B_Status';
import TOTAL from '@salesforce/label/c.B2B_Total';
import ORDER_ASC from '@salesforce/label/c.B2B_Order_Action_ASC';
import ORDER_DESC from '@salesforce/label/c.B2B_Order_Action_DESC';
import CLEAR_ALL from '@salesforce/label/c.B2B_Clear_All';
import ERROR_MESSAGE from '@salesforce/label/c.B2B_Error_Message';

const TABLE_COLUMNS = [
    { field: 'Name', label: QUOTE_NUMBER, sort: true, type: 'link' },
    { field: 'DateRequested__c', label: DATE_REQUESTED, sort: true, type: 'date' },
    { field: 'ExpirationDate__c', label: EXPIRATION_DATE, sort: true, type: 'date' },
    { field: 'Status__c', label: STATUS, sort: true, type: 'string' },
    { field: 'Estimated_Quote_Total__c', label: TOTAL, sort: true, type: 'currency' }
];

const TABLE_MOBILE_HEADER = [
    { field: 'Name', type: 'link' },
    { field: 'Status__c', type: 'string' }
];

const TABLE_MOBILE_BODY = [
    { field: 'DateRequested__c', label: DATE_REQUESTED, type: 'date' },
    { field: 'ExpirationDate__c', label: EXPIRATION_DATE, type: 'date' },
    { field: 'Estimated_Quote_Total__c', label: TOTAL, type: 'currency' }
];

const CURRENCY_CODE = 'USD';
const ORDER_ACTIONS = [{ value: 'ASC', label: ORDER_ASC }, { value: 'DESC', label: ORDER_DESC }];
const RECORDS_ON_PAGE = 10;

const COMPONENT_NAME = 'b2b-quote-list-container';

export default class B2BQuoteManagement extends LightningElement {

    LABELS = {
        CLEAR_ALL,
        QUOTES,
        SEARCH,
        DATE_FROM,
        DATE_TO
    }

    @track effectiveAccountId = null;
    @api recordsOnPage;

    @track selectedStatus;
    @track search;
    @track isLoading = true;
    @track hasFullSpinner = true;
    @track dateFrom = null;
    @track dateTo = null;
    @track isFirstRender = true;
    @track customCssContainer = UTILS.customCssContainer;
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);

    statusOptions = [];
    quoteIdForDelete = null;

    get isFullSpinnerRunning() {
        return this.isLoading && this.hasFullSpinner;
    }

    get isDisabledFilter() {
        return this.isLoading && !this.hasFullSpinner;
    }

    get sortFieldOptions() {
        let sortFieldData = [];

        TABLE_COLUMNS.forEach(column => {
            if (column.sort) {
                sortFieldData.push({
                    label: column.label,
                    value: column.field
                });
            }
        });

        return sortFieldData;
    }

    get sortOrderOptions() {
        let sortOrderData = [];

        ORDER_ACTIONS.forEach(order => {
            sortOrderData.push({
                label: order.label,
                value: order.value
            });
        });

        return sortOrderData;
    }

    async connectedCallback() {
        this.effectiveAccountId = await UTILS.getEffectiveAccountId();
        this.generateTableHeaders();
        this.initFilter();
    }

    renderedCallback() {
        if (this.isFirstRender) {
            this.isFirstRender = false;
            this.addCustomCssStyles();
        }
    }

    addCustomCssStyles() {
        let styleText = `
            .${this.wrapper} c-b2b-table .slds-table {
                table-layout: auto !important;
            }

            .${this.wrapper} c-b2b-table .list-table td {
                padding: 6px 12px !important;
            }

            .${this.wrapper} c-b2b-table thead tr th {
                text-align: center !important;
            }

            .${this.wrapper} lightning-input[data-name="dateFrom"] .slds-form-element__label,
            .${this.wrapper} lightning-input[data-name="dateTo"] .slds-form-element__label {
                display: none;
                padding: 0;
                font-size: 12px;
            }

            .${this.wrapper} lightning-input lightning-datepicker .slds-input + lightning-button-icon .slds-button_icon {
                line-height: 1;
                transform: translateY(-3px) !important;
            }
            .${this.wrapper} .slds-button{
                white-space: nowrap !important;
            }

            @media (max-width: 767.98px) {
                .${this.wrapper} lightning-input[data-name="dateFrom"] .slds-form-element__label,
                .${this.wrapper} lightning-input[data-name="dateTo"] .slds-form-element__label {
                    display: block;
                }
            }

            .${this.wrapper} c-b2b-table tbody tr td:not(:last-child) {
                text-align: center !important;
            }

            .${this.wrapper} .b2b-quote-list__panel lightning-input .slds-input:not(:focus) {
                border-color: #DDDBDA;
            }

            .${this.wrapper} .b2b-quote-list__panel lightning-input .slds-input::placeholder {
                font-size: 12px;
                color: #231F20;
            }

            .${this.wrapper} .b2b-quote-list__panel lightning-input .slds-input__icon {
                fill: #706E6B;
            }

            .${this.wrapper} .b2b-quote-list__panel lightning-combobox .slds-combobox__input {
                font-size: 12px;
                color: #231F20;
                border-radius: 0;
            }

            .${this.wrapper} .b2b-quote-list__panel lightning-combobox .slds-combobox__input:not(:focus) {
                border-color: #DDDBDA;
            }

            .${this.wrapper} .b2b-quote-list__panel lightning-combobox .slds-combobox__input:focus {
                border-color: rgb(218, 41, 28);
                box-shadow: 0 0 3px rgb(182, 41, 28);
            }

            .${this.wrapper} .b2b-quote-list__panel lightning-datepicker .slds-input::placeholder {
                font-size: 12px;
                color: #231F20;
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

    async initFilter() {

        let response = await UTILS.doRequest(_initFilter, {
            accountId: this.effectiveAccountId
        });

        if (UTILS.responseSuccess(response)) {
            let data = UTILS.responseData(response);

            if (IS.objectNotEmpty(data)) {
                this.statusOptions = data.statusOptions;
                this.setDefaultStatus();

                this.initPagination(data.quotes, true);
                this.parseList(data.quotes);
            }
        } else {
            console.error(response);
            this.showToast('error', ERROR_MESSAGE);
        }

        this.hasFullSpinner = true;
        this.isLoading = false;
    }

    async getList(resetCurrentPage, currentQueue) {

        let response = await UTILS.doRequest(_getQuotes, {
            filter: this.prepareFilterData(),
            accountId: this.effectiveAccountId
        });

        if (UTILS.responseSuccess(response)) {
            let data = UTILS.responseData(response);

            if (IS.arrayNotEmpty(data)) {
                if (this.checkRequestQueue(currentQueue)) {
                    this.initPagination(data, resetCurrentPage);
                    this.parseList(data);
                }
            } else {
                this.currentPage = null;
                this.maxPage = null;
                this.parseList(data);
            }
        } else {
            if (this.checkRequestQueue(currentQueue)) {
                console.error(error);
                this.showToast('error', ERROR_MESSAGE);
            }
        }

        if (this.checkRequestQueue(currentQueue)) {
            this.hasFullSpinner = true;
            this.isLoading = false;
        }
    }

    handleStatusChange(event) {
        this.selectedStatus = event.target.value;

        this.isLoading = true;
        this.getList(true);

        this.statusOptions.forEach(item => {
            item.cssClasses = (item.value === this.selectedStatus)
                ? 'slds-button sort-button sort-button-click'
                : 'slds-button sort-button';
        });
    }

    async handleDateFromChange(event) {
        if (this.dateFrom !== event.target.value) {
            this.dateFrom = event.target.value;
            await this.updateDatesValidity();

            setTimeout(() => {
                if (this.datesReportValidity()) {
                    this.isLoading = true;
                    this.getList(true);
                }
            }, 0);
        }
    }

    async handleDateToChange(event) {
        if (this.dateTo !== event.target.value) {
            this.dateTo = event.target.value;
            await this.updateDatesValidity();

            setTimeout(() => {
                if (this.datesReportValidity()) {
                    this.isLoading = true;
                    this.getList(true);
                }
            }, 0);
        }
    }

    typeTimer;
    requestQueue;
    handleChangeSearch(event) {
        clearTimeout(this.typeTimer);
        this.search = event.target.value;

        this.isLoading = true;
        this.hasFullSpinner = false;

        let that = this;
        this.typeTimer = setTimeout(function() {
            let currentQueue = Date.now();
            that.requestQueue = currentQueue;
            that.getList(true, currentQueue);
        }, 1000);
    }

    async handleClearAll() {
        this.search = null;
        this.selectedStatus = this.statusOptions[0].value;

        this.dateFrom = null;
        this.dateTo = null;
        await this.updateDatesValidity();

        this.lastSortField = TABLE_COLUMNS[0].field;
        this.lastSortOrder = ORDER_ACTIONS[0].value;
        this.updateTableHeaders();

        this.currentPage = 1;

        this.isUpdateLoading = true;
        this.getList({
            resetCurrentPage: true
        });
    }

    handleSortFieldChange(event) {
        this.sortFieldProcessing(event.target.value);
    }

    handleSortOrderChange() {
        this.sortFieldProcessing(this.lastSortField);
    }

    handleSortClick(event) {
        this.sortFieldProcessing(event.detail);
    }

    handleClickQuoteTitle(event) {
        let id = event.detail;

        if (!id) return;

        this.listMobileView.forEach(item => {
            if (item.id === id) {
                item.showDetails = !item.showDetails;
            }
        });
    }

    handleChangePage(event) {
        let page = event.detail;

        if (page) {
            this.currentPage = page;
            this.getVisibleTableData();
        }
    }

    setDefaultStatus() {
        this.selectedStatus = this.statusOptions[0] ? this.statusOptions[0].value : null;
    }

    prepareFilterData() {
        return {
            status: this.selectedStatus || null,
            sortValue: this.lastSortField || null,
            sortType: this.lastSortOrder || null,
            dateFrom: this.dateFrom || null,
            dateTo: this.dateTo || null,
            search: IS.stringNotEmpty(this.search) ? this.search.trim() : null,
            accountId: this.effectiveAccountId
        };
    }

    checkRequestQueue(currentQueue) {
        return (currentQueue && currentQueue === this.requestQueue) || !currentQueue;
    }

    showToast(type, message) {
        const event = new ShowToastEvent({
            variant: type,
            message: message
        });
        this.dispatchEvent(event);
    }

    datesReportValidity() {
        let dateFrom = this.template.querySelector('[data-name="dateFrom"]');
        let dateTo = this.template.querySelector('[data-name="dateTo"]');

        if (dateFrom && dateTo) {
            if (
                IS.date(this.dateFrom) && dateFrom.checkValidity() &&
                IS.date(this.dateTo) && dateTo.checkValidity() &&
                this.dateFrom < this.dateTo
            ) {
                dateFrom.reportValidity();
                dateTo.reportValidity();
                return true;

            } else if (
                IS.date(this.dateFrom) && dateFrom.checkValidity() &&
                IS.date(this.dateTo) && dateTo.checkValidity() &&
                this.dateFrom === this.dateTo
            ) {
                dateFrom.reportValidity();
                dateTo.reportValidity();
                return true;

            } else if (
                IS.date(this.dateFrom) && dateFrom.checkValidity() &&
                (!IS.date(this.dateTo) || !dateTo.checkValidity())
            ) {
                dateFrom.reportValidity();
                dateTo.reportValidity();
                return true;

            } else if (
                (!IS.date(this.dateFrom) || !dateFrom.checkValidity()) &&
                IS.date(this.dateTo) && dateTo.checkValidity()
            ) {
                dateFrom.reportValidity();
                dateTo.reportValidity();
                return true;

            } else if (!IS.date(this.dateFrom) && !IS.date(this.dateTo)) {
                dateFrom.reportValidity();
                dateTo.reportValidity();
                return true;
            }
        }
        return false;
    }

    async updateDatesValidity() {
        await setTimeout(() => {
            let dateFrom = this.template.querySelector('[data-name="dateFrom"]');
            if (dateFrom) {
                dateFrom.reportValidity();
            }
            let dateTo = this.template.querySelector('[data-name="dateTo"]');
            if (dateTo) {
                dateTo.reportValidity();
            }
        }, 0);
    }

    // B2B Table logic

    @track tableQuotesHeaders = [];
    @track list = [];
    @track listMobile = [];
    @track listView = [];
    @track listMobileView = [];

    currentPage = null;
    maxPage = null;

    lastSortField = 'DateRequested__c';
    lastSortOrder = 'DESC';

    generateTableHeaders() {
        let result = [];

        TABLE_COLUMNS.forEach((item, index) => {
            let headerItem = {
                key: index,
                label: item.label || null,
                class: item.class || null,
                field: item.field || null,
                isSort: item.sort
            };

            if (item.field === this.lastSortField) {
                headerItem.isOrder = true;
                headerItem.order = this.lastSortOrder;
                headerItem.iconName = (this.lastSortOrder === ORDER_ACTIONS[0].value)
                    ? 'utility:arrowdown'
                    : 'utility:arrowup';
                headerItem.orderClass = 'list__action list__is-order';

            } else {
                headerItem.isOrder = false;
                headerItem.order = ORDER_ACTIONS[0].value;
                headerItem.iconName = 'utility:arrowdown';
                headerItem.orderClass = 'list__action';
            }

            if (!item.sort) { headerItem.orderClass += ' no-sort-column'; }

            result.push(headerItem);
        });

        this.tableQuotesHeaders = result;
    }

    updateTableHeaders() {
        let field = this.lastSortField;
        let lastField = null;

        this.tableQuotesHeaders.forEach((item) => {
            if (IS.true(item.isOrder)) {
                lastField = item.field;
            }
        });

        this.tableQuotesHeaders.forEach((item) => {
            if (
                !IS.stringNotEmpty(item.order) ||
                (
                    item.order !== ORDER_ACTIONS[0].value &&
                    item.order !== ORDER_ACTIONS[1].value
                )
            ) {
                item.order = ORDER_ACTIONS[0].value;
            }

            if (item.field === field) {
                item.isOrder = true;
                item.orderClass = 'list__action list__is-order';

                if (field === lastField) {
                    (item.order === ORDER_ACTIONS[0].value)
                        ? item.order = ORDER_ACTIONS[1].value
                        : item.order = ORDER_ACTIONS[0].value;
                }

                this.lastSortOrder = item.order;

            } else {
                item.isOrder = false;
                item.orderClass = 'list__action';
            }

            if (!item.isSort) {
                item.orderClass += ' no-sort-column';
            }

            item.iconName = item.order === ORDER_ACTIONS[0].value
                ? 'utility:down'
                : 'utility:up';
        });
    }

    sortFieldProcessing(fieldName) {
        let field = fieldName;
        let lastField = null;

        this.lastSortField = fieldName;
        this.isLoading = true;
        
        this.tableQuotesHeaders.forEach(item => {
            if (item.isOrder) {
                lastField = item.field;
            }
        });

        this.tableQuotesHeaders.forEach(item => {
            if (!item.order || (item.order !== ORDER_ACTIONS[0].value && item.order !== ORDER_ACTIONS[1].value)) {
                item.order = ORDER_ACTIONS[0].value;
            }

            if (item.field === field) {
                item.isOrder = true;
                item.orderClass = 'list__action list__is-order';

                if (field === lastField) {
                    (item.order === ORDER_ACTIONS[0].value)
                        ? item.order = ORDER_ACTIONS[1].value
                        : item.order = ORDER_ACTIONS[0].value;
                }

                this.lastSortOrder = item.order;

            } else {
                item.isOrder = false;
                item.orderClass = 'list__action';
            }

            if (!item.isSort) { item.orderClass += ' no-sort-column'; }

            (item.order === ORDER_ACTIONS[0].value)
                ? item.iconName = 'utility:arrowdown'
                : item.iconName = 'utility:arrowup';
        });

        this.getList(false);
    }

    initPagination(quotes, resetCurrentPage) {
        this.maxPage = (quotes.length != 0 && quotes.length > this.getRecordsOnPage())
            ? (Math.ceil(quotes.length / this.getRecordsOnPage()))
            : 1;
        this.currentPage = resetCurrentPage ? 1 : this.currentPage || null;
    }

    getRecordsOnPage() {
        return this.recordsOnPage || RECORDS_ON_PAGE;
    }

    parseList(list) {
        let result = [];
        let mobileResult = [];

        if (list && list.length) {
            result = this.getDesktopTableItems(list);
            mobileResult = this.getMobileTableItems(list);
        }

        this.list = result;
        this.listMobile = mobileResult;

        this.getVisibleTableData();
    }

    getDesktopTableItems(list) {
        let result = [];

        list.forEach((item, itemIndex) => {
            if (item.Name) {
                let row = {
                    key: itemIndex,
                    data: []
                };

                TABLE_COLUMNS.forEach((column, columnIndex) => {
                    let formattedItem = {
                        key: `${itemIndex}-${columnIndex}`
                    };

                    switch (column.type) {
                        case 'string':
                            formattedItem.isString = true;
                            formattedItem.label = item[column.field];
                            break;
                        case 'link':
                            formattedItem.isLink = true;
                            formattedItem.label = item[column.field];
                            formattedItem.url = `${communityBasePath}/quote-detail?recordId=${item.Id}`;
                            break;
                        case 'date':
                            formattedItem.isDateUTC = true;
                            formattedItem.label = item[column.field];
                            break;
                        case 'currency':
                            formattedItem.isCurrency = true;
                            formattedItem.label = item[column.field];
                            formattedItem.currencyCode = item.currencyIsoCode || CURRENCY_CODE;
                            break;
                    }

                    row.data.push(formattedItem);
                });

                result.push(row);
            }
        });

        return result;
    }

    getMobileTableItems(list) {
        let mobileResult = [];

        list.forEach((item, itemIndex) => {
            if (item.Name) {
                let mobileItem = {
                    id: item.Id,
                    showDetails: false,
                    itemHeader: [],
                    itemBody: []
                };

                TABLE_MOBILE_HEADER.forEach((mobileHeaderItem, mobileHeaderItemIndex) => {
                    let headerItem = {
                        key: `${itemIndex}-${mobileHeaderItemIndex}`
                    };

                    switch (mobileHeaderItem.type) {
                        case 'string':
                            headerItem.isString = true;
                            headerItem.label = item[mobileHeaderItem.field];
                            break;
                        case 'link':
                            headerItem.isLink = true;
                            headerItem.label = item[mobileHeaderItem.field];
                            headerItem.url = `${communityBasePath}/quote-detail?recordId=${item.Id}`;
                            break;
                    }

                    mobileItem.itemHeader.push(headerItem);
                });

                TABLE_MOBILE_BODY.forEach((mobileBodyItem, mobileBodyItemIndex) => {
                    let bodyItem = {
                        key: `${itemIndex}-${mobileBodyItemIndex}`
                    };

                    switch (mobileBodyItem.type) {
                        case 'string':
                            bodyItem.isString = true;
                            bodyItem.label = mobileBodyItem.label;
                            bodyItem.value = item[mobileBodyItem.field];
                            break;
                        case 'date':
                            bodyItem.isDate = true;
                            bodyItem.label = mobileBodyItem.label;
                            bodyItem.value = item[mobileBodyItem.field];
                            break;
                        case 'currency':
                            bodyItem.isCurrency = true;
                            bodyItem.label = mobileBodyItem.label;
                            bodyItem.value = item[mobileBodyItem.field];
                            bodyItem.currencyCode = item.currencyIsoCode || CURRENCY_CODE;
                            break;
                    }

                    mobileItem.itemBody.push(bodyItem);
                });

                mobileResult.push(mobileItem);
            }
        });

        return mobileResult;
    }

    getVisibleTableData() {
        let begin = (this.currentPage - 1) * this.getRecordsOnPage();
        let end = parseInt(begin) + parseInt(this.getRecordsOnPage());

        this.listView = this.list.slice(begin, end);
        this.listMobileView = this.listMobile.slice(begin, end);
    }

    // #B2B Table logic
}