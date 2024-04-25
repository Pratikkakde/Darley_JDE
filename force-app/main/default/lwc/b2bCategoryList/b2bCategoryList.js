import { LightningElement, track, api, wire } from 'lwc';
import { UTILS, IS, DISPATCHER } from 'c/b2bUtils';
import { ProductCategoryAdapter } from 'commerce/productApi';

// METHODS
import getChildCategories from '@salesforce/apex/B2BCategoryLandingController.getChildCategories';

const LABELS = {
    allProducts: 'All Products',
};

const CATEGORY_PAGE = 'category_page';
const CHANGE_VIEW = 'change_view';

export default class B2bCategoryList extends LightningElement {
    @api recordId = null;
    @api categoryNameColor = null;
    @api categoryNameColorHover = null;

    @wire(ProductCategoryAdapter, { 'categoryId': '$recordId' })
    async wiredProductCategoryAdapter() {
        let data = sessionStorage.getItem('b2b-category-list-data');
        data = JSON.parse(data);
        if (
            IS.objectNotEmpty(data)
            && IS.stringNotEmpty(data.recordId)
            && this.recordId === data.recordId
            && IS.stringNotEmpty(data.pathname)
            && IS.stringIncludes(data.pathname, this.recordId)
            && IS.stringNotEmpty(window.location.search)
        ) {
            this.showProducts = data.showProducts;
            this.getInitialData(data.showProducts);
        } else {
            this.getInitialData(false);
        }
    }

    @track labels = LABELS;
    @track isLoading = false;
    @track effectiveAccountId = null;
    @track customCssContainer = UTILS.customCssContainer;
    @track list = [];
    @track showProducts = false;

    // GETTERS
    get showComponent() {
        return !this.isLoading
            && !this.showProducts
            && IS.stringNotEmpty(this.recordId)
            && IS.stringNotEmpty(this.effectiveAccountId)
            && IS.arrayNotEmpty(this.list);
    }

    // LIFECYCLE
    async connectedCallback() {
        this.effectiveAccountId = await UTILS.getEffectiveAccountId();
    }

    disconnectedCallback() {
        sessionStorage.setItem('b2b-category-list-data', JSON.stringify({
            recordId: this.recordId,
            showProducts: this.showProducts,
            pathname: window.location.pathname
        }));
    }

    // METHODS
    addCustomCssStyles() {
        let styleText = `
            commerce_builder-breadcrumbs {
                margin-bottom: ${this.showProducts || !this.showComponent ? 16 : 32}px !important;
            }
        
            c-b2b-category-list {
                ${UTILS.generateCssVar('category-list', 'category-name-color', this.categoryNameColor)}
                ${UTILS.generateCssVar('category-list', 'category-name-color-hover', this.categoryNameColorHover)}
            }
        `;
        if (this.showProducts || !this.showComponent) {
            styleText += `
                c-b2b-category-list + commerce_builder-search-results-layout.component-wrapper-spacer {
                    display: block;
                }
            `;
        }
        UTILS.addCustomCssStyles(this.template, styleText);
    }

    async getInitialData(showProducts) {
        if (this.isLoading) {
            return;
        }

        let response = await UTILS.doRequest(getChildCategories, {
            effectiveAccountId: this.effectiveAccountId,
            categoryId: this.recordId
        });
        if (UTILS.responseSuccess(response)) {
            this.parseResponse(UTILS.responseData(response));
        }

        this.showProducts = IS.true(showProducts) ? true : false;
        this.isLoading = false;
        this.addCustomCssStyles();
        this.executeEvent();
    }

    parseResponse(data) {
        let list = [];
        if (IS.arrayNotEmpty(data)) {
            data.forEach((item) => {
                let newItem = {
                    id: IS.stringNotEmpty(item.categoryId) ? item.categoryId : null,
                    name: IS.stringNotEmpty(item.name) ? item.name : null,
                    image: UTILS.cmsImage(item.image),
                    link: IS.stringNotEmpty(item.categoryId) ? `/category/${item.categoryId}` : null
                };
                if (
                    IS.stringNotEmpty(newItem.id)
                    && IS.stringNotEmpty(newItem.name)
                ) {
                    list.push(newItem);
                }
            });
        }
        this.list = list;
    }

    executeEvent() {
        DISPATCHER.fireEvent(CATEGORY_PAGE, CHANGE_VIEW, {
            showProducts: this.showProducts || !this.showComponent
        });
    }

    // HANDLERS
    handleClickShowProducts() {
        this.showProducts = true;
        this.addCustomCssStyles();
        this.executeEvent();
        UTILS.scrollToTop();
    }

}