import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { UTILS, IS } from 'c/b2bUtils';

// METHODS
import parseUploadedCSV from '@salesforce/apex/B2BQuickOrderController.parseUploadedCSV';
import getSampleFileLink from '@salesforce/apex/B2BQuickOrderController.getSampleFileLink';
import submitQuickOrder from '@salesforce/apex/B2BQuickOrderController.submitQuickOrder';

// LABELS
import B2B_Quick_Order_Uploader_Loading from '@salesforce/label/c.B2B_Quick_Order_Uploader_Loading';
import B2B_Quick_Order_Uploader_Title from '@salesforce/label/c.B2B_Quick_Order_Uploader_Title';
import B2B_Quick_Order_Uploader_Template_Label from '@salesforce/label/c.B2B_Quick_Order_Uploader_Template_Label';
import B2B_Quick_Order_Uploader_Template_Link from '@salesforce/label/c.B2B_Quick_Order_Uploader_Template_Link';
import B2B_Quick_Order_Uploader_Error_Title from '@salesforce/label/c.B2B_Quick_Order_Uploader_Error_Title';
import B2B_Quick_Order_Uploader_Error_Message from '@salesforce/label/c.B2B_Quick_Order_Uploader_Error_Message';
import B2B_Quick_Order_Uploader_Close from '@salesforce/label/c.B2B_Quick_Order_Uploader_Close';
import B2B_Quick_Order_Uploader_Modal_Title from '@salesforce/label/c.B2B_Quick_Order_Uploader_Modal_Title';
import B2B_Quick_Order_Uploader_Page_Size_Prefix from '@salesforce/label/c.B2B_Quick_Order_Uploader_Page_Size_Prefix';
import B2B_Quick_Order_Uploader_Page_Size_Sufix from '@salesforce/label/c.B2B_Quick_Order_Uploader_Page_Size_Sufix';
import B2B_Quick_Order_Uploader_Show_Issue from '@salesforce/label/c.B2B_Quick_Order_Uploader_Show_Issue';
import B2B_Quick_Order_Uploader_No_Records_To_Display from '@salesforce/label/c.B2B_Quick_Order_Uploader_No_Records_To_Display';
import B2B_Quick_Order_Uploader_Showing_Empty from '@salesforce/label/c.B2B_Quick_Order_Uploader_Showing_Empty';
import B2B_Quick_Order_Uploader_Showing_Exists from '@salesforce/label/c.B2B_Quick_Order_Uploader_Showing_Exists';
import B2B_Quick_Order_Uploader_Modal_Submit from '@salesforce/label/c.B2B_Quick_Order_Uploader_Modal_Submit';
import B2B_Quick_Order_Uploader_Th_Sku from '@salesforce/label/c.B2B_Quick_Order_Uploader_Th_Sku';
import B2B_Quick_Order_Uploader_Th_Product_Name from '@salesforce/label/c.B2B_Quick_Order_Uploader_Th_Product_Name';
import B2B_Quick_Order_Uploader_Th_Requested_Qty from '@salesforce/label/c.B2B_Quick_Order_Uploader_Th_Requested_Qty';
import B2B_Quick_Order_Uploader_Th_Recommended_Qty from '@salesforce/label/c.B2B_Quick_Order_Uploader_Th_Recommended_Qty';
import B2B_Quick_Order_Uploader_Modal_Success_Title from '@salesforce/label/c.B2B_Quick_Order_Uploader_Modal_Success_Title';
import B2B_Quick_Order_Uploader_Modal_Success_View_Cart from '@salesforce/label/c.B2B_Quick_Order_Uploader_Modal_Success_View_Cart';
import B2B_Quick_Order_Uploader_Modal_Success_Continue_Shopping from '@salesforce/label/c.B2B_Quick_Order_Uploader_Modal_Success_Continue_Shopping';
import B2B_Quick_Order_Uploader_Add_Product_Error from '@salesforce/label/c.B2B_Quick_Order_Uploader_Add_Product_Error';

const LABELS = {
    loading: B2B_Quick_Order_Uploader_Loading,
    title: B2B_Quick_Order_Uploader_Title,
    templateLabel: B2B_Quick_Order_Uploader_Template_Label,
    templateLink: B2B_Quick_Order_Uploader_Template_Link,
    errorTitle: B2B_Quick_Order_Uploader_Error_Title,
    errorMessage: B2B_Quick_Order_Uploader_Error_Message,
    close: B2B_Quick_Order_Uploader_Close,
    modalTitle: B2B_Quick_Order_Uploader_Modal_Title,
    pageSizePrefix: B2B_Quick_Order_Uploader_Page_Size_Prefix,
    pageSizeSufix: B2B_Quick_Order_Uploader_Page_Size_Sufix,
    showIssue: B2B_Quick_Order_Uploader_Show_Issue,
    noRecordsToDisplay: B2B_Quick_Order_Uploader_No_Records_To_Display,
    showingEmpty: B2B_Quick_Order_Uploader_Showing_Empty,
    showingExists: B2B_Quick_Order_Uploader_Showing_Exists,
    modalSubmit: B2B_Quick_Order_Uploader_Modal_Submit,
    thSku: B2B_Quick_Order_Uploader_Th_Sku,
    thProductName: B2B_Quick_Order_Uploader_Th_Product_Name,
    thRequestedQty: B2B_Quick_Order_Uploader_Th_Requested_Qty,
    thRecommendedQty: B2B_Quick_Order_Uploader_Th_Recommended_Qty,
    modalSuccessTitle: B2B_Quick_Order_Uploader_Modal_Success_Title,
    modalSuccessViewCart: B2B_Quick_Order_Uploader_Modal_Success_View_Cart,
    modalSuccessContinueShopping: B2B_Quick_Order_Uploader_Modal_Success_Continue_Shopping,
    addProductError: B2B_Quick_Order_Uploader_Add_Product_Error,
};

const COMPONENT_NAME = 'b2b-quick-order-uploader';
const SUCCESS = 'success';
const WARNING = 'warning';
const ERROR = 'error';

export default class B2bQuickOrderUploader extends NavigationMixin(LightningElement) {
    @api templateDocumentId = null;
    
    @track effectiveAccountId = null;
    @track isUpdateLoading = false;
    @track isAddingLoading = false;
    @track isFirstRender = true;
    @track customCssContainer = UTILS.customCssContainer;
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);
    @track labels = LABELS;

    @track templateLink = null;
    @track showError = false;
    @track errorMessage = null;
    @track showIssue = false;
    @track showModal = false;
    @track list = [];
    @track pageSize = '10';
    @track pageSizeRequired = true;
    @track pageSizeOptions = [
        { value: '10', label: '10' },
        { value: '30', label: '30' },
        { value: '50', label: '50' }
    ];
    @track currentPage = null;
    @track cartId = null;
    @track showSuccessModal = false;

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper}`;
    }

    get showComponent() {
        return !UTILS.isGuest;
    }

    get getErrorMessage() {
        return IS.stringNotEmpty(this.errorMessage)
            ? this.errorMessage
            : LABELS.errorMessage;
    }

    get getPageSizeDisabled() {
        return this.isUpdateLoading ||
            this.isAddingLoading ||
            !IS.arrayNotEmpty(this.list);
    }

    get getIssueCount() {
        let result = 0;
        if (IS.arrayNotEmpty(this.list)) {
            this.list.forEach((item) => {
                if (item.status === WARNING || item.status === ERROR) {
                    result += 1;
                }
            });
        }
        return result;
    }

    get getSuccessCount() {
        let result = 0;
        if (IS.arrayNotEmpty(this.list)) {
            this.list.forEach((item) => {
                if (item.status === SUCCESS || item.status === WARNING) {
                    result += 1;
                }
            });
        }
        return result;
    }

    get getShowIssueLabel() {
        return `${LABELS.showIssue}${this.getIssueCount > 0 ? ` (${this.getIssueCount})` : ''}`;
    }

    get getShowIssueDisabled() {
        return this.getIssueCount > 0 &&
            !this.isUpdateLoading &&
            !this.isAddingLoading
                ? null
                : true;
    }

    get getFilteredList() {
        let result = [];
        this.list.forEach((item) => {
            let isValid = true;
            if (IS.true(this.showIssue) && item.status === SUCCESS) {
                isValid = false;
            }
            if (isValid) {
                result.push(item);
            }
        });
        return result;
    }

    get displayedList() {
        let pageSize = IS.integer(+this.pageSize) ? +this.pageSize : 10;

        if (
            IS.arrayNotEmpty(this.getFilteredList) &&
            IS.integer(this.currentPage) &&
            IS.integer(pageSize)
        ) {
            let start = this.currentPage * pageSize - pageSize;
            let finish = (this.currentPage - 1) * pageSize + pageSize;
            return this.getFilteredList.slice(start, finish);
        }
        return this.getFilteredList;
    }

    get getShowingLabel() {
        let pageSize = IS.integer(+this.pageSize) ? +this.pageSize : 10;
        if (
            IS.arrayNotEmpty(this.getFilteredList) &&
            IS.integer(this.currentPage) &&
            IS.integer(pageSize)
        ) {
            let start = this.currentPage * pageSize - pageSize + 1;
            let finish = (this.currentPage - 1) * pageSize + pageSize;
            if (finish > this.getFilteredList.length) {
                finish = this.getFilteredList.length;
            }
            return UTILS.prepareLabel(
                LABELS.showingExists,
                [start, finish, this.getFilteredList.length]
            );
        }
        return LABELS.showingEmpty;
    }

    get getMaxPage() {
        let maxPage = 1;
        let pageSize = IS.integer(+this.pageSize) ? +this.pageSize : 10;

        if (IS.arrayNotEmpty(this.getFilteredList) && IS.integer(pageSize)) {
            maxPage = Math.ceil(this.getFilteredList.length / pageSize);
        }

        return maxPage;
    }

    get isModalSubmitDisabled() {
        return this.isUpdateLoading ||
            this.isAddingLoading ||
            !IS.arrayNotEmpty(this.list) ||
            this.getSuccessCount === 0;
    }

    // LIFECYCLES
    async connectedCallback() {
        this.effectiveAccountId = await UTILS.getEffectiveAccountId();
        this.getInitialData();
    }

    renderedCallback() {
        if (this.isFirstRender) {
            this.isFirstRender = false;
            this.addCustomCssStyles();
        }
    }

    // METHODS
    addCustomCssStyles() {
        let styleText = `
            /* QUICK ORDER PAGE */
            body[class*="comm-page-quickorder"] .b2b-layout__content .ui-widget + .ui-widget {
                margin-top: 2rem;
            }

            /* FORM */
            .${COMPONENT_NAME}__form lightning-input,
            .${COMPONENT_NAME}__form lightning-input .slds-form-element__control,
            .${COMPONENT_NAME}__form lightning-input .slds-file-selector.slds-file-selector_files,
            .${COMPONENT_NAME}__form lightning-input lightning-primitive-file-droppable-zone,
            .${COMPONENT_NAME}__form lightning-input lightning-primitive-file-droppable-zone slot,
            .${COMPONENT_NAME}__form lightning-input lightning-primitive-file-droppable-zone slot .slds-file-selector__body {
                display: flex;
                align-items: center;
                justify-content: center;
                width: 100%;
                height: 100%;
            }

            .${COMPONENT_NAME}__form lightning-input .slds-form-element__label {
                display: none;
            }

            .${COMPONENT_NAME}__form lightning-input .slds-file-selector__button.slds-button {
                font-size: 13px;
                font-weight: 600;
                text-transform: none;
            }

            .${COMPONENT_NAME}__form lightning-input lightning-primitive-file-droppable-zone {
                padding: 0;
            }

            .${COMPONENT_NAME}__form lightning-input lightning-primitive-file-droppable-zone slot .slds-file-selector__body {
                display: flex;
                align-items: center;
                justify-content: center;
                flex-direction: column;
                grid-row-gap: 1rem;
            }

            /* PAGE SIZE */
            .${COMPONENT_NAME}__page-size .b2b-select__select {
                width: 70px;
                font-size: 14px;
            }

            /* SHOW ISSUE */
            .${COMPONENT_NAME}__show-issue lightning-input .slds-checkbox_on,
            .${COMPONENT_NAME}__show-issue lightning-input .slds-checkbox_off {
                display: none !important;
            }

            /* TABLE */
            .${COMPONENT_NAME}__table lightning-helptext {
                display: inline-block;
                margin-left: 4px;
                transform: translateY(1px);
            }

            .${COMPONENT_NAME}__table lightning-helptext .slds-form-element__icon {
                padding-top: 0;
            }

            .${COMPONENT_NAME}__table lightning-helptext .slds-button {
                border: 0;
                box-shadow: unset !important;
            }

            .${COMPONENT_NAME}__table lightning-helptext .slds-button__icon,
            .${COMPONENT_NAME}__table lightning-helptext .slds-button_icon:hover .slds-button__icon {
                fill: var(--b2b-colorText);
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

    async getInitialData() {
        if (IS.stringNotEmpty(this.templateDocumentId)) {
            let response = await UTILS.doRequest(getSampleFileLink, {
                documentId: this.templateDocumentId
            });
            if (
                UTILS.responseSuccess(response) &&
                IS.stringNotEmpty(response.responseData)
            ) {
                this.templateLink = response.responseData;
            } else {
                console.error(response);
            }
        }
    }

    parseResponse(data) {
        let list = [];
        if (IS.arrayNotEmpty(data)) {
            data.forEach((item, index) => {
                let newItem = {
                    componentId: `${index}`,
                    id: IS.stringNotEmpty(item.id) ? item.id : null,
                    status: null,
                    isSuccess: false,
                    isWarning: false,
                    isError: false,
                    sku: IS.stringNotEmpty(item.sku) ? item.sku : null,
                    name: IS.stringNotEmpty(item.name) ? item.name : null,
                    link: null,
                    requestedQty: '—',
                    recommendedQty: '—',
                    message: null,
                    tooltip: null,
                    expanded: false,
                };

                if (IS.stringNotEmpty(newItem.id)) {
                    newItem.link = UTILS.link(`/product/${newItem.id}`);
                }

                // SUCCESS
                if (
                    IS.stringNotEmpty(item.status) &&
                    item.status === SUCCESS &&
                    IS.numeric(item.quantity) &&
                    IS.numeric(item.finalQuantity) &&
                    item.quantity === item.finalQuantity
                ) {
                    newItem.status = SUCCESS;
                    newItem.isSuccess = true;
                    newItem.requestedQty = IS.numeric(item.quantity) ? item.quantity : '—';
                    newItem.recommendedQty = item.finalQuantity;
                }

                // WARNING
                if (
                    IS.stringNotEmpty(item.status) &&
                    item.status === WARNING &&
                    IS.stringNotEmpty(item.qtyTooltip)
                ) {

                    newItem.status = WARNING;
                    newItem.isWarning = true;
                    newItem.requestedQty = IS.numeric(item.quantity) ? item.quantity : '—';
                    newItem.recommendedQty = item.finalQuantity;
                    newItem.tooltip = item.qtyTooltip;
                }

                // ERROR
                if (
                    IS.stringNotEmpty(item.status) &&
                    item.status === ERROR &&
                    IS.stringNotEmpty(item.errorMsg)
                ) {
                    newItem.status = ERROR;
                    newItem.isError = true;
                    newItem.message = item.errorMsg;
                }

                if (
                    IS.stringNotEmpty(newItem.status) &&
                    IS.stringNotEmpty(newItem.sku) &&
                    IS.stringNotEmpty(newItem.name) &&
                    (
                        IS.stringNotEmpty(newItem.id) &&
                        (newItem.status === SUCCESS || newItem.status === WARNING)
                    ) ||
                    (
                        !IS.stringNotEmpty(newItem.id) &&
                        newItem.status === ERROR
                    )
                ) {
                    list.push(newItem);
                }
            });
        }

        this.list = list;
    }

    displayModal() {
        window.document.body.style.overflowY = 'hidden';
        this.currentPage = 1;
        this.showModal = true;
    }

    displaySuccessModal() {
        if (IS.stringNotEmpty(this.cartId)) {
            window.document.body.style.overflowY = 'hidden';
            this.showSuccessModal = true;
        }
    }

    resetMobileListExpanded() {
        if (IS.arrayNotEmpty(this.list)) {
            this.list.forEach((item) => {
                item.expanded = false;
            });
        }
    }

    navigateTo(url) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: { url }
        });
    }

    // HANDLERS
    handleClickTemplateLink(event) {
        event.preventDefault();
        if (IS.stringNotEmpty(this.templateLink)) {
            window.open(this.templateLink);
        }
    }

    async handleChangeUpload(event) {
        if (event.detail && event.detail.files && event.detail.files[0]) {
            let file = event.detail.files[0];

            if (file) {
                this.isUpdateLoading = true;
                this.showError = false;
                this.errorMessage = null;
    
                let fileBlob = new Blob(
                    [new Uint8Array(await file.arrayBuffer())],
                    {type: file.type }
                );
    
                let fileText = null;
                await fileBlob.text().then((text) => {
                    fileText = text;
                });
    
                if (IS.stringNotEmpty(fileText)) {
                    let response = await UTILS.doRequest(parseUploadedCSV, {
                        accountId: this.effectiveAccountId,
                        documentBody: fileText
                    });
                    let data = UTILS.responseData(response);
                    
                    if (UTILS.responseSuccess(response) && IS.arrayNotEmpty(data)) {
                        this.parseResponse(data);
                        this.displayModal();
                    } else {
                        if (IS.stringNotEmpty(response.responseMessage)) {
                            this.errorMessage = response.responseMessage;
                        }
                        if (response.responseData) {
                            console.error(response.responseData);
                        }
                        this.showError = true;
                    }
                }
            }
        }
        this.isUpdateLoading = false;
    }

    handleChangePageSize(event) {
        this.currentPage = 1;
        this.resetMobileListExpanded();
        this.pageSize = IS.stringNotEmpty(event.detail.value)
            ? event.detail.value
            : '10';
    }

    handleChangeShowIssue(event) {
        this.currentPage = 1;
        this.resetMobileListExpanded();
        this.showIssue = IS.true(event.target.checked) ? true : false;
    }
    
    handleChangePagination(event) {
        this.resetMobileListExpanded();
        this.currentPage = IS.integer(event.detail)
            ? event.detail
            : 1;
    }

    handleClickModalClose() {
        this.showModal = false;
        this.list = [];
        this.currentPage = 1;
        window.document.body.style.overflowY = 'auto';
    }

    handleExpandMobileItem(event) {
        let componentId = event.detail.componentId;
        if (
            IS.stringNotEmpty(componentId) &&
            IS.arrayNotEmpty(this.list)
        ) {
            this.list.forEach((item) => {
                if (item.componentId === componentId) {
                    item.expanded = !item.expanded;
                }
            });
        }
    }

    async handleClickModalSubmit() {
        if (
            this.isUpdateLoading ||
            this.isAddingLoading ||
            this.getSuccessCount === 0
        ) {
            return;
        }
        
        let products = [];
        this.list.forEach((item) => {
            if (item.status === SUCCESS || item.status === WARNING) {
                products.push({
                    id: item.id,
                    finalQuantity: item.recommendedQty,
                });
            }
        });

        if (!IS.arrayNotEmpty(products)) {
            return;
        }

        this.isAddingLoading = true;

        let response = await UTILS.doRequest(submitQuickOrder, {
            effectiveAccountId: this.effectiveAccountId,
            products: JSON.stringify(products)
        });
        let data = UTILS.responseData(response);

        if (UTILS.responseSuccess(response) && IS.objectNotEmpty(data)) {
            this.cartId = IS.stringNotEmpty(data.cartId) ? data.cartId : null;
            UTILS.updateCartQuantityLWR(data.cartItemId, data.cartItemQuantity);
            this.handleClickModalClose();
            this.displaySuccessModal();
        } else {
            UTILS.showToast('error', LABELS.addProductError);
            console.error(response);
        }
        this.isAddingLoading = false;
    }

    handleClickSuccessModalClose() {
        this.showSuccessModal = false;
        window.document.body.style.overflowY = 'auto';
        this.cartId = null;
    }

    handleClickModalViewCart() {
        UTILS.navigateTo(`/cart`);
        this.handleClickSuccessModalClose();
    }

}