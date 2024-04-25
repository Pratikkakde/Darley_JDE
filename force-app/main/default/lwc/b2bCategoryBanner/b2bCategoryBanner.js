import { LightningElement, track, api, wire } from 'lwc';
import { UTILS, IS, DISPATCHER } from 'c/b2bUtils';

import { ProductCategoryAdapter } from 'commerce/productApi';

const CATEGORY_PAGE = 'category_page';
const CHANGE_VIEW = 'change_view';

export default class B2bCategoryBanner extends LightningElement {
    @api recordId = null;
    @api showCategoryBanner = false;
    @api categoryBannerHeight = null;

    @track isFirstRender = true;
    @track customCssContainer = UTILS.customCssContainer;

    @track showProducts = false;
    @track isEventDone = false;
    @track name = null;
    @track bannerImage = null;

    @wire(ProductCategoryAdapter, { 'categoryId': '$recordId' })
    async wiredProductCategoryAdapter(result) {
        if (IS.objectNotEmpty(result.data)) {
            if (
                IS.objectNotEmpty(result.data.bannerImage)
                && IS.stringNotEmpty(result.data.bannerImage.url)
            ) {
                this.bannerImage = UTILS.cmsImage(result.data.bannerImage.url);
            }

            if (
                IS.objectNotEmpty(result.data.fields)
                && IS.stringNotEmpty(result.data.fields.Name)
            ) {
                this.name = result.data.fields.Name;
            }
        }
    }

    // GETTERS
    get showComponent() {
        return this.showCategoryBanner
            && this.isEventDone
            && !this.showProducts
            && IS.stringNotEmpty(this.bannerImage);
    }

    // LIFECYCLE
    connectedCallback() {
        DISPATCHER.registerListener(this, CATEGORY_PAGE, CHANGE_VIEW, this.updateShowProducts);
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
            c-b2b-category-banner {
                ${UTILS.generateCssVar('category-banner', 'height', IS.numeric(this.categoryBannerHeight)
                    ? this.categoryBannerHeight + 'px'
                    : ''
                )}
            }
        `;

        if (UTILS.isBuilder()) {
            styleText += `
                .manual.webruntimedesign-regionWrapper_regionWrapper + webruntimedesign-drop-region + webruntimedesign-component-wrapper community_layout-section:first-child {
                    padding: 0 !important;
                }

                .manual.webruntimedesign-regionWrapper_regionWrapper + webruntimedesign-drop-region + webruntimedesign-component-wrapper community_layout-section:first-child .community_layout-section_section {
                    max-width: 100% !important;
                }
            `;
        } else {
            styleText += `
                community_layout-section:first-child {
                    padding: 0 !important;
                }

                community_layout-section:first-child .community_layout-section_section {
                    max-width: 100% !important;
                }
            `;
        }
        UTILS.addCustomCssStyles(this.template, styleText);
    }

    updateShowProducts(data) {
        this.isEventDone = true;
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