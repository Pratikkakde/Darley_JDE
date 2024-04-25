import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

// METHODS
import getFeaturedBrands from '@salesforce/apex/B2BFeaturedBrandsController.getFeaturedBrands';

// LABELS
const LABELS = {
    title: 'Featured Brands',
};

const MAX_LIST_ITEMS = 15;

export default class B2bFeaturedBrands extends LightningElement {
    @track effectiveAccountId = null;
    @track isLoading = true;
    @track labels = LABELS;
    @track list = [];
    @track showArrows = true;
    @track showSlicks = true;

    // GETTERS
    get showComponent() {
        return !this.isLoading
            && IS.arrayNotEmpty(this.list);
    }

    // LIFECYCLES
    async connectedCallback() {
        this.effectiveAccountId = await UTILS.getEffectiveAccountId();
        this.getInitialData();
    }

    // METHODS
    async getInitialData() {
        if (!IS.stringNotEmpty(this.effectiveAccountId)) {
            return;
        }

        let response = await UTILS.doRequest(getFeaturedBrands, {
            effectiveAccountId:  this.effectiveAccountId
        });

        if (UTILS.responseSuccess(response)) {
           this.parseData(UTILS.responseData(response));
        }

        this.isLoading = false;
    }

    parseData(data) {
        let result = [];
        if (IS.arrayNotEmpty(data)) {
            data.forEach((item) => {
                if (
                    IS.stringNotEmpty(item.categoryId)
                    && IS.stringNotEmpty(item.categoryName)
                    && IS.stringNotEmpty(item.image)
                ) {
                    let image = IS.stringNotEmpty(item.image)
                        && !IS.stringIncludes(item.image, '/default-product-image.')
                            ? UTILS.cmsImage(item.image)
                            : null;

                    result.push({
                        id: item.categoryId,
                        title: item.categoryName,
                        image,
                        link: UTILS.link(`/category/${item.categoryId}`)
                    });
                }
            });
        }
        this.list = result.slice(0, MAX_LIST_ITEMS);
    }

}