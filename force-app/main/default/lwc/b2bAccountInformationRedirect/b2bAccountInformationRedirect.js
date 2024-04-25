import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { UTILS, IS } from 'c/b2bUtils';

export default class B2bAccountInformationRedirect extends NavigationMixin(LightningElement) {
    @track effectiveAccountId = null;
    @track isFirstRender = true;
    @track customCssContainer = UTILS.customCssContainer;

    // LIFECYCLES
    async connectedCallback() {
        this.effectiveAccountId = await UTILS.getEffectiveAccountId();
        if (IS.stringIncludes(window.location.href, '/account/Home')) {
            UTILS.navigateTo(`/account/${this.effectiveAccountId}`);
        }
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
            dxp_records-detail-panel .slds-card {
                border: 0;
                box-shadow: unset;
            }

            dxp_records-detail-panel .slds-card__header,
            dxp_records-detail-panel .slds-card__body,
            dxp_records-section .dxp_records-section_section.slds-section__content,
            dxp_records-section .slds-form-element {
                padding: 0 !important;
            }
        `;

        UTILS.addCustomCssStyles(this.template, styleText);
    }

}