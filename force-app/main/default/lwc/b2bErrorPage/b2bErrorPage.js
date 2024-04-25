import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

// LABELS
import B2B_Error_Page_Title from '@salesforce/label/c.B2B_Error_Page_Title';
import B2B_Error_Page_Subtitle from '@salesforce/label/c.B2B_Error_Page_Subtitle';
import B2B_Error_Page_Description from '@salesforce/label/c.B2B_Error_Page_Description';
import B2B_Error_Page_Button_Label from '@salesforce/label/c.B2B_Error_Page_Button_Label';

const LABELS = {
    title: B2B_Error_Page_Title,
    subtitle: B2B_Error_Page_Subtitle,
    description: B2B_Error_Page_Description,
    buttonLabel: B2B_Error_Page_Button_Label,
};

const COMPONENT_NAME = 'b2b-error-page';
const CSS_PREFIX = 'errorPage';

export default class B2bErrorPage extends LightningElement {
    // BACKGROUND
    @api showBackgroundImage = false;
    @api backgroundImage = null;
    @api backgroundColor = null;

    // CONTAINER
    @api containerMaxWidth = null;
    @api containerColor = null;
    @api containerHorizontalPosition = null;
    @api containerVerticalPosition = null;
    @api containerBorderRadius = null;
    
    // IMAGE
    @api showImage = false;
    @api image = null;
    @api imageMaxWidth = null;
    @api imageAlign = null;

    // TTILE
    @api showTitle = false;
    @api title = null;
    @api titleColor = null;
    @api titleAlign = null;

    // SUTITLE
    @api showSubtitle = false;
    @api subtitle = null;
    @api subtitleColor = null;
    @api subtitleAlign = null;

    // DESCRIPTION
    @api showDescription = false;
    @api description = null;
    @api descriptionColor = null;
    @api descriptionAlign = null;

    // BUTTON
    @api showButton = false;
    @api buttonLabel = null;
    @api buttonNavigateTo = null;
    @api buttonAlign = null;
    @api buttonTextColor = null;
    @api buttonBackgroundColor = null;
    @api buttonTextColorHover = null;
    @api buttonBackgroundColorHover = null;
    @api buttonBorderRadius = null;

    @track isFirstRender = true;
    @track customCssContainer = UTILS.customCssContainer;
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper}`;
    }

    get getBackgroundImage() {
        return UTILS.cmsLink(this.backgroundImage);
    }

    get getImage() {
        return UTILS.cmsLink(this.image);
    }

    get getShowTitle() {
        return this.showTitle && IS.stringNotEmpty(this.getTitle);
    }

    get getTitle() {
        return IS.stringNotEmpty(this.title)
            ? this.title
            : LABELS.title;
    }

    get getShowSubtitle() {
        return this.showSubtitle && IS.stringNotEmpty(this.getSubtitle);
    }

    get getSubtitle() {
        return IS.stringNotEmpty(this.subtitle)
            ? this.subtitle
            : LABELS.subtitle;
    }

    get getShowDescription() {
        return this.showDescription && IS.stringNotEmpty(this.getDescription);
    }

    get getDescription() {
        return IS.stringNotEmpty(this.description)
            ? this.description
            : LABELS.description;
    }

    get getShowButton() {
        return this.showButton
            && IS.stringNotEmpty(this.getButtonLink)
            && IS.stringNotEmpty(this.getButtonLabel);
    }

    get getButtonLink() {
        return UTILS.link(this.buttonNavigateTo);
    }

    get getButtonLabel() {
        return IS.stringNotEmpty(this.buttonLabel)
            ? this.buttonLabel
            : LABELS.buttonLabel;
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
            commerce-layout-site > [name="footer"] .component-wrapper-spacer {
                margin: 0 !important;
            }

            commerce-layout-site > [name="footer"] .interactions-component {
                min-height: 0 !important;
            }

            c-b2b-layout-full-width {
                background-color: ${
                    IS.stringNotEmpty(this.backgroundColor)
                        ? `${this.backgroundColor}`
                        : 'transparent'
                } !important;
            }

            .${this.wrapper} {
                ${UTILS.generateCssVar(
                    CSS_PREFIX,
                    'containerHorizontalPosition',
                    UTILS.justifyContent(this.containerHorizontalPosition)
                )}
                ${UTILS.generateCssVar(
                    CSS_PREFIX,
                    'containerVerticalPosition',
                    UTILS.alignItems(this.containerVerticalPosition)
                )}
    
                ${UTILS.generateCssVar(CSS_PREFIX, 'containerMaxWidth', this.containerMaxWidth)}
                ${UTILS.generateCssVar(CSS_PREFIX, 'containerBorderRadius', this.containerBorderRadius)}
                ${UTILS.generateCssVar(CSS_PREFIX, 'containerColor', this.containerColor)}
                ${UTILS.generateCssVar(CSS_PREFIX, 'imageAlign', UTILS.justifyContent(this.imageAlign))}
                ${UTILS.generateCssVar(CSS_PREFIX, 'imageMaxWidth', this.imageMaxWidth)}
                ${UTILS.generateCssVar(CSS_PREFIX, 'titleAlign', UTILS.textAlign(this.titleAlign))}
                ${UTILS.generateCssVar(CSS_PREFIX, 'titleColor', this.titleColor)}
                ${UTILS.generateCssVar(CSS_PREFIX, 'subtitleAlign', UTILS.textAlign(this.subtitleAlign))}
                ${UTILS.generateCssVar(CSS_PREFIX, 'subtitleColor', this.subtitleColor)}
                ${UTILS.generateCssVar(CSS_PREFIX, 'descriptionAlign', UTILS.textAlign(this.descriptionAlign))}
                ${UTILS.generateCssVar(CSS_PREFIX, 'descriptionColor', this.descriptionColor)}
                ${UTILS.generateCssVar(CSS_PREFIX, 'buttonAlign', UTILS.textAlign(this.buttonAlign))}
            }


            .${COMPONENT_NAME}__button .b2b-button {
                ${this.buttonTextColor ? `color: ${this.buttonTextColor} !important;` : ''}
                ${this.buttonBorderRadius || this.buttonBorderRadius == 0 ? `border-radius: ${this.buttonBorderRadius}px;` : ''}
                ${this.buttonBackgroundColor ? `background-color: ${this.buttonBackgroundColor} !important;` : ''}
            }

            .${COMPONENT_NAME}__button .b2b-button:hover,
            .${COMPONENT_NAME}__button .b2b-button:focus,
            .${COMPONENT_NAME}__button .b2b-button:active {
                ${this.buttonTextColorHover ? `color: ${this.buttonTextColorHover} !important;` : ''}
                ${this.buttonBackgroundColorHover ? `border-color: ${this.buttonBackgroundColorHover} !important;` : ''}
                ${this.buttonBackgroundColorHover ? `background-color: ${this.buttonBackgroundColorHover} !important;` : ''}
            }
        `;

        // BACKGROUND IMAGE
        if (this.showBackgroundImage && this.getBackgroundImage) {
            styleText += `
                commerce-layout-site > .content,
                .commerce-layoutSite_layoutSite.content {
                    background-image: url('${this.getBackgroundImage}');
                    background-position: 80% center;
                    background-repeat: no-repeat;
                    background-size: cover;
                    background-color: var(--b2b-header-background-color, #FFFFFF) !important;
                }
            `;
        }

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