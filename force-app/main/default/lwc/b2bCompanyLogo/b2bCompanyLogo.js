import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

// LABELS
import B2B_Company_Logo_Alternative_Text from '@salesforce/label/c.B2B_Company_Logo_Alternative_Text';

const LABELS = {
    alternativeText: B2B_Company_Logo_Alternative_Text,
};

const COMPONENT_NAME = 'b2b-company-logo';
const CSS_PREFIX = 'companyLogo';

export default class B2bCompanyLogo extends LightningElement {
    @api showLogo = false;
    @api logoImage = null;
    @api alternativeText = null;
    @api useAsLink = false;
    @api navigateTo = null;
    @api logoMaxWidth = null;
    @api logoMaxHeight = null;
    @api logoAlign = null;
    @api logoMarginBottom = null;

    @track isFirstRender = true;
    @track customCssContainer = UTILS.customCssContainer;
    @track componentId = UTILS.random.componentId();
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);
    @track wrapperId = UTILS.wrapperId(COMPONENT_NAME, this.componentId);

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper} ${this.wrapperId}`;
    }

    get showComponent() {
        return this.showLogo
        && this.getLogoImage;
    }

    get getLogoImage() {
        return UTILS.cmsLink(this.logoImage);
    }

    get getUseAsLink() {
        return this.useAsLink
        && this.getNavigateLink;
    }

    get getNavigateLink() {
        return UTILS.link(this.navigateTo);
    }

    get getAlternativeText() {
        return IS.stringNotEmpty(this.alternativeText)
            ? this.alternativeText
            : LABELS.alternativeText;

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
        let styleText = `
            .${this.wrapper}.${this.wrapperId} {
                ${UTILS.generateCssVar(CSS_PREFIX, 'logoAlign', UTILS.justifyContent(this.logoAlign))}
                ${UTILS.generateCssVar(CSS_PREFIX, 'logoMaxWidth', this.logoMaxWidth)}
                ${UTILS.generateCssVar(CSS_PREFIX, 'logoMaxHeight', this.logoMaxHeight)}
                ${UTILS.generateCssVar(CSS_PREFIX, 'logoMarginBottom', this.logoMarginBottom)}
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

}