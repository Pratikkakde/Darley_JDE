import { LightningElement, track, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { UTILS, IS } from 'c/b2bUtils';

const FIELDS = [
    'Product2.B2BBrandName__c',
    'Product2.B2BBrandUrl__c'
];

export default class B2bProductBrandName extends LightningElement {
    @api recordId = null;
    @api useAsLink = false;
    @api labelFontSize = null;

    @track isFirstRender = true;
    @track customCssContainer = UTILS.customCssContainer;
    @track brandLabel = null;
    @track brandLink = null;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wireRec({ error, data }) {
        if (
            IS.objectNotEmpty(data)
            && IS.objectNotEmpty(data.fields)
            && IS.objectNotEmpty(data.fields.B2BBrandName__c)
            && IS.objectNotEmpty(data.fields.B2BBrandUrl__c)
        ) {
            if (IS.stringNotEmpty(data.fields.B2BBrandName__c.value)) {
                this.brandLabel = data.fields.B2BBrandName__c.value;
            }
            if (IS.stringNotEmpty(data.fields.B2BBrandUrl__c.value)) {
                this.brandLink = data.fields.B2BBrandUrl__c.value;
            }
        }
    }

    // GETTERS

    get showComponent() {
        return IS.stringNotEmpty(this.brandLabel);
    }

    get showAsLink() {
        return IS.true(this.useAsLink) && IS.stringNotEmpty(this.brandLink);
    }

    // LIFECYCLES

    renderedCallback() {
        if (this.isFirstRender) {
            this.isFirstRender = false;
            this.addCustomCssStyles();
        }
    }

    // METHODS

    addCustomCssStyles() {
        UTILS.addCustomCssStyles(this.template, `
            c-b2b-product-brand-name {
                ${UTILS.generateCssVar('product-brand-name', 'font-size', this.labelFontSize)}
            }
        `);
    }

}