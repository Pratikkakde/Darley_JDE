import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

// METHODS
import getProductDetails from '@salesforce/apex/B2BProductDetailPageController.getProductDetails';

// LABELS
import B2B_Product_Support_Faq_Title from '@salesforce/label/c.B2B_Product_Support_Faq_Title';
import B2B_Product_Support_Articles_Title from '@salesforce/label/c.B2B_Product_Support_Articles_Title';
import B2B_Product_Support_Documents_Title from '@salesforce/label/c.B2B_Product_Support_Documents_Title';
import B2B_Product_Support_Shipping_Title from '@salesforce/label/c.B2B_Product_Support_Shipping_Title';

const LABELS = {
    faqTitle: B2B_Product_Support_Faq_Title,
    articlesTitle: B2B_Product_Support_Articles_Title,
    documentsTitle: B2B_Product_Support_Documents_Title,
    shippingTitle: B2B_Product_Support_Shipping_Title,
};

export default class B2bProductSupport extends LightningElement {
    @api recordId = null;

    // FAQ
    @api showFaqSection = false;
    @api showFaqTitle = false;
    @api faqTitle = null;
    @api faqAnchor = null;

    // ARTICLES
    @api showArticlesSection = false;
    @api showArticlesTitle = false;
    @api articlesTitle = null;
    @api articlesAnchor = null;

    // DOCUMENTS
    @api showDocumentsSection = false;
    @api showDocumentsTitle = false;
    @api documentsTitle = null;
    @api documentsAnchor = null;

    // SHIPPING
    @api showShippingSection = false;
    @api showShippingTitle = false;
    @api shippingTitle = null;
    @api shippingAnchor = null;

    @track effectiveAccountId = null;
    @track isLoading = true;
    @track faq = null;
    @track articles = null;
    @track documents = [];
    @track shipping = null;

    // GETTERS
    get getShowFaqSection() {
        return IS.true(this.showFaqSection) && IS.stringNotEmpty(this.faq);
    }

    get getFaqTitle() {
        return IS.stringNotEmpty(this.faqTitle)
            ? this.faqTitle
            : LABELS.faqTitle;
    }

    get getShowArticlesSection() {
        return IS.true(this.showArticlesSection) && IS.stringNotEmpty(this.articles);
    }

    get getArticlesTitle() {
        return IS.stringNotEmpty(this.articlesTitle)
            ? this.articlesTitle
            : LABELS.articlesTitle;
    }

    get getShowDocumentsSection() {
        return IS.true(this.showDocumentsSection) && IS.arrayNotEmpty(this.documents);
    }

    get getDocumentsTitle() {
        return IS.stringNotEmpty(this.documentsTitle)
            ? this.documentsTitle
            : LABELS.documentsTitle;
    }

    get getShowShippingSection() {
        return IS.true(this.showShippingSection) && IS.stringNotEmpty(this.shipping);
    }

    get getShippingTitle() {
        return IS.stringNotEmpty(this.shippingTitle)
            ? this.shippingTitle
            : LABELS.shippingTitle;
    }

    // LIFECYCLES
    async connectedCallback() {
        this.effectiveAccountId = await UTILS.getEffectiveAccountId();
        this.getInitialData();
    }

    // METHODS
    async getInitialData() {
        if (!IS.stringNotEmpty(this.recordId)) {
            return;
        }

        let response = await UTILS.doRequest(getProductDetails, {
            productId: this.recordId
        });

        if (UTILS.responseSuccess(response)) {
            this.parseResponse(UTILS.responseData(response));
            this.executeScroll();
        }

        this.isLoading = false;
    }

    parseResponse(data) {
        if (IS.objectNotEmpty(data)) {
            this.faq = IS.stringNotEmpty(data.faq) ? data.faq : null;
            this.articles = IS.stringNotEmpty(data.articles) ? data.articles : null;
            this.shipping = IS.stringNotEmpty(data.shippindDetails) ? data.shippindDetails : null;

            let documents = [];
            if (IS.arrayNotEmpty(data.attachments)) {
                data.attachments.forEach((item) => {
                    if (
                        IS.stringNotEmpty(item.fileName)
                        && IS.stringNotEmpty(item.fileUrl)
                    ) {
                        documents.push({
                            label: item.fileName,
                            link: UTILS.link(item.fileUrl)
                        });
                    }
                });
            }
            this.documents = documents;
        }
    }

    executeScroll() {
        setTimeout(() => {
            let hash = window.location.hash;
            if (IS.stringNotEmpty(hash)) {
                let element = this.template.querySelector(`[anchor-id="${hash.slice(1).toLowerCase()}"]`);
                if (element && this[`getShow${hash.slice(1, 2).toUpperCase()}${hash.slice(2).toLowerCase()}Section`]) {
                    element.scrollIntoView();
                }
            }
        }, 100);
    }

}