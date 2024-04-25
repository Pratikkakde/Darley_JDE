import { LightningElement, track, api, wire } from 'lwc';
import { UTILS, IS, DISPATCHER } from 'c/b2bUtils';
import { ProductCategoryAdapter } from 'commerce/productApi';

// METHODS
import getCategory from '@salesforce/apex/B2BCategoryLandingController.getCategory';

const LABELS = {
    learnMore: 'Learn More'
};

const CATEGORY_PAGE = 'category_page';
const CHANGE_VIEW = 'change_view';

export default class B2bCategoryInformation extends LightningElement {
    @api recordId = null;
    @api showCategoryInformation = false;
    @api titleColor = null;
    @api titleAlign = null;
    @api descriptionColor = null;
    @api descriptionAlign = null;
    @api additionalDescriptionColor = null;
    @api additionalDescriptionAlign = null;
    @api buttonLabel = null;
    @api buttonVariant = null;
    @api buttonAlign = null;

    @wire(ProductCategoryAdapter, { 'categoryId': '$recordId' })
    async wiredProductCategoryAdapter() {
        this.getInitialData();
    }

    @track isLoading = false;
    @track effectiveAccountId = null;
    @track isFirstRender = true;
    @track customCssContainer = UTILS.customCssContainer;
    @track labels = LABELS;
    @track showProducts = false;

    @track name = null;
    @track description = null;
    @track additionalDescription = null;
    @track image = null;
    @track link = null;

    // GETTERS
    get showComponent() {
        return !this.showProducts
            && this.showCategoryInformation
            && (
                IS.stringNotEmpty(this.description)
                || IS.stringNotEmpty(this.additionalDescription)
            );
    }

    get isImageExists() {
        return IS.stringNotEmpty(this.image);
    }

    get isAdditionalDescriptionExists() {
        return IS.stringNotEmpty(this.additionalDescription);
    }

    get getButtonClass() {
        let result = 'slds-button';
        if (IS.stringNotEmpty(this.buttonVariant) && this.buttonVariant !== 'Base') {
            result += ` slds-button_${this.buttonVariant.toLowerCase()}`;
        }
        return result;
    }

    get getButtonLabel() {
        return IS.stringNotEmpty(this.buttonLabel)
            ? this.buttonLabel
            : LABELS.learnMore;
    }

    // LIFECYCLE
    async connectedCallback() {
        DISPATCHER.registerListener(this, CATEGORY_PAGE, CHANGE_VIEW, this.updateShowProducts);
        this.effectiveAccountId = await UTILS.getEffectiveAccountId();
    }

    renderedCallback() {
        if (this.isFirstRender) {
            this.isFirstRender = false;
            this.addCustomCssStyles();
        }
    }

    disconnectedCallback() {
        DISPATCHER.unregisterListener(CATEGORY_PAGE, CHANGE_VIEW, this.updateShowProducts);
    }

    // METHODS
    addCustomCssStyles() {
        let styleText = `
            c-b2b-category-information {
                ${UTILS.generateCssVar('category-information', 'title-color', this.titleColor)}
                ${UTILS.generateCssVar('category-information', 'title-align',
                    IS.stringNotEmpty(this.titleAlign)
                        ? this.titleAlign.toLowerCase()
                        : this.titleAlign
                )}
                ${UTILS.generateCssVar('category-information', 'description-color', this.descriptionColor)}
                ${UTILS.generateCssVar('category-information', 'description-align',
                    IS.stringNotEmpty(this.descriptionAlign)
                            ? this.descriptionAlign.toLowerCase()
                            : this.descriptionAlign
                )}
                ${UTILS.generateCssVar('category-information', 'additional-description-color', this.additionalDescriptionColor)}
                ${UTILS.generateCssVar('category-information', 'additional-description-align',
                    IS.stringNotEmpty(this.additionalDescriptionAlign)
                            ? this.additionalDescriptionAlign.toLowerCase()
                            : this.additionalDescriptionAlign
                )}
                ${UTILS.generateCssVar('category-information', 'button-align',
                    IS.stringNotEmpty(this.buttonAlign)
                            ? this.buttonAlign.toLowerCase()
                            : this.buttonAlign
                )}
            }
        `;
        UTILS.addCustomCssStyles(this.template, styleText);
    }

    async getInitialData() {
        if (this.isLoading) {
            return;
        }
        this.isLoading = true;

        let response = await UTILS.doRequest(getCategory, {
            effectiveAccountId: this.effectiveAccountId,
            categoryId: this.recordId
        });

        if (UTILS.responseSuccess(response)) {
            this.parseResponse(UTILS.responseData(response));
        } else {
            this.resetValues();
        }

        this.isLoading = false;
    }

    parseResponse(data) {
        if (IS.objectNotEmpty(data)) {
            this.name = IS.stringNotEmpty(data.name) ? data.name : null;
            this.description = IS.stringNotEmpty(data.description) ? data.description : null;
            this.additionalDescription = IS.stringNotEmpty(data.additionalDescription) ? data.additionalDescription : null;
            this.image = IS.stringNotEmpty(data.image)
                && !IS.stringIncludes(data.image, '/default-product-image.')
                    ? UTILS.cmsImage(data.image)
                    : null;
            this.link = IS.stringNotEmpty(data.learnMoreLink) ? UTILS.link(data.learnMoreLink) : null;
        } else {
            this.resetValues();
        }
    }

    resetValues() {
        this.name = null;
        this.description = null;
        this.additionalDescription = null;
        this.image = null;
        this.link = null;
    }

    updateShowProducts(data) {
        if (
            IS.objectNotEmpty(data)
            && IS.boolean(data.showProducts)
        ) {
            this.showProducts = data.showProducts;
        } else {
            this.showProducts = false;
        }
    }

}