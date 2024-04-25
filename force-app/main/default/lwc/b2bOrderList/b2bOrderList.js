import { LightningElement, track, api } from 'lwc';
import { UTILS } from 'c/b2bUtils';
import { NavigationMixin } from 'lightning/navigation';

import _getOrdersSummary from '@salesforce/apex/B2BOrdersSummaryController.getOrdersSummary';
import _initializeFilter from '@salesforce/apex/B2BOrdersSummaryController.initializeFilter';
import _orderOverViewCallout from '@salesforce/apex/calloutOrderStatus.orderOverViewCallout';

// TODO: Update Labels
import ORDERS from '@salesforce/label/c.B2B_Orders';
import SEARCH_PLACEHOLDER from '@salesforce/label/c.B2B_Search';
import STATUS_PLACEHOLDER from '@salesforce/label/c.B2B_Status';
import DATE_FROM from '@salesforce/label/c.B2B_Order_Date_From';
import DATE_TO from '@salesforce/label/c.B2B_Order_Date_To';
import CLEAR_ALL from '@salesforce/label/c.B2B_Clear_All';
import ORDER_NUMBER from '@salesforce/label/c.B2B_Order_Number';
import PO_NUMBER from '@salesforce/label/c.B2B_PO_Number';
import ORDER_DATE from '@salesforce/label/c.B2B_Ordered_Date';
import ORDER_STATUS from '@salesforce/label/c.B2B_Order_Status';
import TOTAL from '@salesforce/label/c.B2B_Total';
import SORT from '@salesforce/label/c.B2B_Sort_By';
import EMPTY_FIELD from '@salesforce/label/c.B2B_Empty_Field';
import ERROR_MESSAGE from '@salesforce/label/c.B2B_Error_Message';
import ORDER_ASC from '@salesforce/label/c.B2B_Order_Action_ASC';
import ORDER_DESC from '@salesforce/label/c.B2B_Order_Action_DESC';

const LABELS = {
    ORDERS,
    SEARCH_PLACEHOLDER,
    STATUS_PLACEHOLDER,
    DATE_FROM,
    DATE_TO,
    CLEAR_ALL,
    ORDER_NUMBER,
    PO_NUMBER,
    ORDER_DATE,
    ORDER_STATUS,
    TOTAL,
    SORT,
    EMPTY_FIELD
};

const COMPONENT_NAME = 'b2b-order-list';

const TABLE_COLUMNS = [
    { field: 'OrderNumber', label: ORDER_NUMBER, sort: true, type: 'link' },
    { field: 'PoNumber', label: PO_NUMBER, sort: true, type: 'string' },
    { field: 'OrderedDate', label: ORDER_DATE, sort: true, type: 'date' },
    { field: 'StoreStatus__c', label: ORDER_STATUS, sort: true, type: 'string' },
    { field: 'B2BGrandTotal__c', label: TOTAL, sort: true, type: 'currency' }
];

const TABLE_MOBILE_HEADER = [
    { field: 'OrderNumber', type: 'link' },
    { field: 'StoreStatus__c', type: 'string' }
];

const TABLE_MOBILE_BODY = [
    { field: 'PoNumber', label: PO_NUMBER, type: 'string' },
    { field: 'OrderedDate', label: ORDER_DATE, type: 'date' },
    { field: 'B2BGrandTotal__c', label: TOTAL, type: 'currency' }
];

const ORDER_ACTIONS = [{ value: 'ASC', label: ORDER_ASC }, { value: 'DESC', label: ORDER_DESC }];
const RECORDS_ON_PAGE = 10;
const DATA_REGEX = /^\d{4}\-(0[1-9]|1[012])\-(0[1-9]|[12][0-9]|3[01])$/;

export default class B2bOrderList extends NavigationMixin(LightningElement) {
    @api recordsOnPage = null;
    @track effectiveAccountId = null;

    @track labels = LABELS;

    @track tableOrdersHeaders = [];
    @track list = [];
   
    @track listMobile = [];
    @track listView = [];
  
    @track listMobileView = [];
    @track statusOptions = [];
    @track subAccountOptions = [];

    @track search = null;
    @track dateFrom = null;
    @track dateTo = null;
    @track status = null;
    @track subAccount = null;
    @track currentPage = null;
    @track maxPage = null;

    @track lastSortField = 'OrderedDate';
    @track lastSortOrder = 'DESC';

    @track isLoading = true;
    @track isFirstRender = true;
    @track hasFullSpinner = true;

    @track UpdatedOrderStatusList = [];

    // GETTERS
    get isPaginationDisabled() {
        return this.isLoading;
    }

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

    get isSubAccountVisible() {
        return this.subAccountOptions && this.subAccountOptions.length > 1;
    }

    // LIFECYCLES
    async connectedCallback() {
        this.effectiveAccountId = await UTILS.getEffectiveAccountId();
        this.subAccount = this.effectiveAccountId;
        this.generateTableHeaders(TABLE_COLUMNS);
        this.initializeFilter();
    }

    renderedCallback() {
        if (this.isFirstRender) {
            this.addCustomCssStyles();
            this.isFirstRender = false;
        }
    }

    // METHODS
    addCustomCssStyles() {
        const style = document.createElement('style');

        let customCssStyles = `

            .clear-btn button:active,
            .clear-btn button:focus {
                border: unset;
                box-shadow: none;
            }

            .sort-and-clear-section .slds-form-element__label {
                display: none;
            }

            .search input,
            .status-field-select input {
                height: 2.125rem;
            }

            .list-date-from input,
            .list-date-to input {
                height: 2.125rem;
            }

            .clear-btn .slds-button {
                color: #3297F0;
            }

            @media(max-width: 767.98px) {

                .search input {
                    height: 2rem;
                }

                .list-date-from input,
                .list-date-to input {
                    min-width: calc(100% - 0.75rem);
                    height: 2rem;
                    padding-bottom: 0.375rem;
                    padding-top: 0.375rem;
                }
                
                .sort-and-clear-section .slds-form-element__label {
                    display: block;
                }

            }
        `;

        style.innerText = customCssStyles.replace(/ +(?= )|\n/g, '');
        this.template.querySelector('.custom-css-container').appendChild(style);
    }

    generateTableHeaders(TABLE_COLUMNS) {
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

        this.tableOrdersHeaders = result;
    }

    initializeFilter() {
        _initializeFilter({
            filter: this.prepareFilterData()
        })
        .then((response) => {
            this.statusOptions = response.storeStatusOptions;
            this.statusOptions.forEach((status, index) => {
                status.id = `status-${index}`;
                status.cssClasses = (index === 0)
                    ? 'slds-button sort-button sort-button-click'
                    : 'slds-button sort-button'
            });
            this.setDefaultStatus();

            this.subAccountOptions = response.subAccountOptions;
            this.subAccountOptions.forEach((account, index) => {
                account.id = `status-${index}`;
                account.cssClasses = (index === 0)
                    ? 'slds-button sort-button sort-button-click'
                    : 'slds-button sort-button'
            });

            this.setDefaultSubAccount();
            this.initPagination(response.orders, true);
            this.parseList(response.orders);
            //console.log('response.orders:',response.orders);
        })
        .catch((error) => {
            //console.error(error);
            UTILS.showToast( 'error', ERROR_MESSAGE);
        })
        .finally(() => {
            this.hasFullSpinner = true;
            this.isLoading = false;
        });
    }

    getList(resetCurrentPage, currentQueue) {
        _getOrdersSummary({
            filter: this.prepareFilterData()
        })
        .then((response) => {
            //console.log('getList() response', response);
            if (this.checkRequestQueue(currentQueue)) {
                this.initPagination(response, resetCurrentPage);
                this.parseList(response);
            }
        })
        .catch((error) => {
            if (this.checkRequestQueue(currentQueue)) {
                //console.error(error);
                UTILS.showToast('error', ERROR_MESSAGE);
            }
        })
        .finally(() => {
            if (this.checkRequestQueue(currentQueue)) {
                this.hasFullSpinner = true;
                this.isLoading = false;
            }
        });
    }

    checkRequestQueue(currentQueue) {
        return (currentQueue && currentQueue === this.requestQueue) || !currentQueue;
    }

    setDefaultSubAccount() {
        this.subAccount = this.subAccountOptions[0] ? this.subAccountOptions[0].value : null;
    }

    setDefaultStatus() {
        this.status = this.statusOptions[0] ? this.statusOptions[0].value : null;
    }

    initPagination(orders, resetCurrentPage) {
        this.maxPage = (orders.length != 0 && orders.length > this.getRecordsOnPage())
            ? (Math.ceil(orders.length / this.getRecordsOnPage()))
            : 1;
        this.currentPage = resetCurrentPage ? 1 : this.currentPage || null;
    }

    prepareFilterData() {
        return {
            status: this.status || null,
            sortValue: this.lastSortField || null,
            sortType: this.lastSortOrder || null,
            search: this.search || null,
            dateTo: this.dateTo || null,
            dateFrom: this.dateFrom || null,
            accountId: this.subAccount
        };
    }

    parseList(list) {
        let result = [];
        let mobileResult = [];
        //console.log('list and list.length:= ', list , list.length);
        if (list && list.length) {
            result = this.getDesktopTableItems(list);
            mobileResult = this.getMobileTableItems(list);
        }

        this.list = result;
        this.listMobile = mobileResult;

        this.getVisibleTableData();
        //console.log('In parseList function - this.list', this.list);
        //console.log('Result in parseList()', result);
    }

    getVisibleTableData() {
        let OrderSummIdList =[];
        let begin = (this.currentPage - 1) * this.getRecordsOnPage();
        let end = parseInt(begin) + parseInt(this.getRecordsOnPage());

        this.listView = this.list.slice(begin, end);
        this.listMobileView = this.listMobile.slice(begin, end);
        //console.log('In getVisibleTableData Function - this.listView', this.listView);
        OrderSummIdList = this.getOrderSummaryIds(this.listView);

        //console.log('OrderSummIdList: ', OrderSummIdList);

    }

    //for Testing 
    getOrderSummaryIds(ListOnPage){
        this.UpdatedOrderStatusList = [];
        //console.log('ListOnPage: ', ListOnPage);
        
        let pageList = JSON.parse(JSON.stringify(ListOnPage));
        
        //console.log('Stringify', JSON.parse(JSON.stringify(ListOnPage)));
        
        let getUrl = [];
        let extractedIds = [];
        let resultString = [];
        //let getUrls = [];
        


       for(let i = 0 ; i < pageList.length ; i++){
        getUrl.push(pageList[i].data[0].url);

       }

       for(let i = 0 ; i <  getUrl.length ; i++){
        let parts = getUrl[i].split('/');
        extractedIds.push(parts[parts.length - 1]);
       }

       //console.log('getUrl  ===>', getUrl );
       //console.log('extractedIds  ===>', extractedIds );

       //need to review this
       for(let i = 0 ; i <  extractedIds.length ; i++){
        _orderOverViewCallout({
                orderSummaryIds: extractedIds[i]
            })
            .then((result) => {
                //console.log('OrderStatus Callout Class called Successfully');
                //console.log(result);
                if(result !== ''){
                    resultString = result.split(',');
                    this.UpdatedOrderStatusList.push({label: parseInt(resultString[0]),value: resultString[1]})
                }
            })
            .catch((error) => {
                //console.log(error);
            });
       }
       //console.log('listView --->',this.listView);
       //console.log('UpdatedOrderStatusList --->',this.UpdatedOrderStatusList);
      
       setTimeout(() => {
        this.updateOrderStatus(this.listView, this.UpdatedOrderStatusList);
    }, 5000);
    //console.log('listView --->',this.listView);
       return extractedIds;
    }

    updateOrderStatus(listView, updatedstatus){
        //console.log('updateOrderStatus called --->');
        //console.log('listView --->',listView);
        //console.log('updatedstatus --->',updatedstatus);

        listView.forEach((item1) => {
            let item2 = updatedstatus.find((item2) => item1.data[0].label == item2.label);
            if (item2) {
               //console.log('listView array modifying');
               item1.data[3].label = item2.value;
               
           }
         });
        
        //console.log('listView --->',this.listView);
    }

    getDesktopTableItems(list) {
        //console.log('getDesktopTableItems (List):', list);
        let result = [];

        list.forEach((item, itemIndex) => {
            if (item.OrderNumber) {
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

                            if (column.field === 'PoNumber') {
                                formattedItem.label = item[column.field] ? item[column.field] : EMPTY_FIELD;
                            } else {
                                formattedItem.label = item[column.field];
                            }
                            break;
                        case 'link':
                            formattedItem.isLink = true;
                            formattedItem.label = item[column.field];
                            formattedItem.url = this.getOrderSummaryLink(item.Id);
                            break;
                        case 'date':
                            formattedItem.isDateUTC = true;
                            formattedItem.label = item[column.field];
                            break;
                        case 'currency':
                            formattedItem.isCurrency = true;
                            formattedItem.label = item[column.field];
                            formattedItem.currencyCode = item.currencyIsoCode || UTILS.currencyIsoCode;
                            break;
                    }

                    row.data.push(formattedItem);
                    
                });
                // console.log('row' , row);
                result.push(row);
            }
        });
        //console.log('Result 2' , result);
        return result;
    }

    getMobileTableItems(list) {
        let mobileResult = [];

        list.forEach((item, itemIndex) => {
            if (item.OrderNumber) {
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
                            headerItem.url = this.getOrderSummaryLink(item.Id);
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

                            if (mobileBodyItem.field === 'PoNumber') {
                                bodyItem.value = item[mobileBodyItem.field] ? item[mobileBodyItem.field] : EMPTY_FIELD;
                            } else {
                                bodyItem.value = item[mobileBodyItem.field];
                            }
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
                            bodyItem.currencyCode = item.currencyIsoCode || UTILS.currencyIsoCode;
                            break;
                    }

                    mobileItem.itemBody.push(bodyItem);
                });

                mobileResult.push(mobileItem);
            }
        });

        return mobileResult;
    }

    getValidDate() {
        let dateFrom = this.template.querySelector('.list-date-from');
        let dateTo = this.template.querySelector('.list-date-to');

        if (dateFrom && dateTo) {
            if (
                this.dateFrom && DATA_REGEX.test(this.dateFrom) && dateFrom.checkValidity() &&
                this.dateTo && DATA_REGEX.test(this.dateTo) && dateTo.checkValidity() &&
                this.dateFrom < this.dateTo
            ) {
                return true;

            } else if (
                this.dateFrom && DATA_REGEX.test(this.dateFrom) && dateFrom.checkValidity() &&
                this.dateTo && DATA_REGEX.test(this.dateTo) && dateTo.checkValidity() &&
                this.dateFrom === this.dateTo
            ) {
                return true;

            } else if (
                this.dateFrom && DATA_REGEX.test(this.dateFrom) && dateFrom.checkValidity() &&
                (!this.dateTo || !DATA_REGEX.test(this.dateTo) || !dateTo.checkValidity())
            ) {
                return true;

            } else if (
                this.dateTo && DATA_REGEX.test(this.dateTo) && dateTo.checkValidity() &&
                (!this.dateFrom || !DATA_REGEX.test(this.dateFrom) || !dateFrom.checkValidity())
            ) {
                return true;

            } else if (!this.dateFrom && !this.dateTo) {
                return true;
            }
        }
        return false;
    }

    getRecordsOnPage() {
        return this.recordsOnPage || RECORDS_ON_PAGE;
    }

    getOrderSummaryLink(orderSummaryId) {
        return this.subAccount === this.effectiveAccountId
            ? `${UTILS.communityBasePath}/OrderSummary/${orderSummaryId}`
            : `${UTILS.communityBasePath}/order-summary?recordId=${orderSummaryId}`;
    }

    sortFieldProcessing(fieldName) {
        let field = fieldName;
        let lastField = null;

        this.lastSortField = fieldName;
        this.isLoading = true;

        this.tableOrdersHeaders.forEach(item => {
            if (item.isOrder) {
                lastField = item.field;
            }
        });

        this.tableOrdersHeaders.forEach(item => {
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

    // HANDLERS
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

    handleFieldSubAccountChange(event) {
        this.subAccount = event.target.value;

        this.isLoading = true;
        this.getList(true);

        this.subAccountOptions.forEach(item => {
            item.cssClasses = (item.value === this.subAccount)
                ? 'slds-button sort-button sort-button-click'
                : 'slds-button sort-button';
        });
    }

    handleFieldStatusChange(event) {
        this.status = event.target.value;

        this.isLoading = true;
        this.getList(true);

        this.statusOptions.forEach(item => {
            item.cssClasses = (item.value === this.status)
                ? 'slds-button sort-button sort-button-click'
                : 'slds-button sort-button';
        });
    }

    handleChangeDateFrom(event) {
        if (this.dateFrom !== event.target.value) {
            this.dateFrom = event.target.value;
            let dateTo = this.template.querySelector('.list-date-to');

            setTimeout(() => {
                if (this.getValidDate()) {
                    this.isLoading = true;
                    this.getList(true);
                }
            }, 0);
        }
    }

    handleChangeDateTo(event) {
        if (this.dateTo !== event.target.value) {
            this.dateTo = event.target.value;
            let dateFrom = this.template.querySelector('.list-date-from');
            
            setTimeout(() => {
                if (this.getValidDate()) {
                    this.isLoading = true;
                    this.getList(true);
                }
            }, 0);
        }
    }

    handleClearAll() {
        this.search = null;
        this.setDefaultSubAccount();
        this.setDefaultStatus();
        this.dateFrom = null;
        this.dateTo = null;

        let dateFrom = this.template.querySelector('.list-date-from');
        let dateTo = this.template.querySelector('.list-date-to');

        if (dateFrom && dateTo) {
            dateFrom.value = '';
            dateTo.value = '';
            dateFrom.reportValidity();
            dateTo.reportValidity();
        }

        setTimeout(() => {
            this.isLoading = true;
            this.getList(true);
        }, 0);

        this.statusOptions.forEach((status, index) => {
            status.cssClasses = (index === 0)
                ? 'slds-button sort-button sort-button-click'
                : 'slds-button sort-button';
        });

        this.subAccountOptions.forEach((account, index) => {
            account.cssClasses = (index === 0)
                ? 'slds-button sort-button sort-button-click'
                : 'slds-button sort-button';
        });
    }

    handleSortClick(event) {
        this.sortFieldProcessing(event.detail);
    }

    handleSortFieldChange(event) {
        this.sortFieldProcessing(event.target.value);
    }

    handleSortOrderChange() {
        this.sortFieldProcessing(this.lastSortField);
    }

    handleChangePage(event) {
        let page = event.detail;

        if (page) {
            this.currentPage = page;
            this.getVisibleTableData();
        }
    }

    handleClickOrderTitle(event) {
        let id = event.detail;

        if (!id) return;

        this.listMobileView.forEach(item => {
            if (item.id === id) {
                item.showDetails = !item.showDetails;
            }
        });
    }

}