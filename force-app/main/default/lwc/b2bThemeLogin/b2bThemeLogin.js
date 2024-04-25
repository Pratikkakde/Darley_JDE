import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

/**
* @slot themeHeader
* @slot themeFooter
*/

const CSS_PREFIX = 'theme-login';

export default class B2bThemeLogin extends LightningElement {

    // BACKGROUND
    @api showBackgroundImage = false;
    @api backgroundImage = null;
    @api backgroundColor = null;
    @api background = null;

    // CONTAINER
    @api containerMaxWidth = null;
    @api containerBackgroundColor = null;
    @api containerHorizontalPosition = null;
    @api containerVerticalPosition = null;
    @api containerHorizontalPadding = null;
    @api containerVerticalPadding = null;
    @api containerHorizontalPaddingMobile = null;
    @api containerVerticalPaddingMobile = null;
    @api containerBorderWidth = null;
    @api containerBorderRadius = null;
    @api containerBorderColor = null;
    @api containerBoxShadow = null;

    @track isFirstRender = true;
    @track customCssContainer = UTILS.customCssContainer;

    // GETTERS
    get getBackgroundImage() {
        return UTILS.cmsLink(this.backgroundImage);
    }

    get getPathName() {
        return window.location.pathname.replace('/', '');
    }

    get getThemeSelector() {
        return `[data-theme="theme-login"][data-path="${this.getPathName}"]`;
    }

    // LIFECYCLES
    renderedCallback() {
        if (this.isFirstRender) {
            this.isFirstRender = false;
            this.addCustomCssStyles();
        }

        this._resizeEventListenerFunction = this.resizeEventListenerFunction.bind(this);
        window.addEventListener('resize', this._resizeEventListenerFunction);
    }

    // METHODS
    resizeEventListenerFunction() {
        this.addCustomCssStyles();
    }

    addCustomCssStyles() {
        let styleText = `
            ${this.getThemeSelector} {
                ${UTILS.generateCssVar(CSS_PREFIX, 'background-color', this.backgroundColor)}
                ${UTILS.generateCssVar(CSS_PREFIX, 'container-max-width',
                    IS.integer(this.containerMaxWidth)
                        ? `${this.containerMaxWidth}px`
                        : ''
                )}
                ${UTILS.generateCssVar(CSS_PREFIX, 'container-background-color', this.containerBackgroundColor)}
                ${UTILS.generateCssVar(CSS_PREFIX, 'container-horizontal-position', UTILS.justifyContent(this.containerHorizontalPosition))}
                ${UTILS.generateCssVar(CSS_PREFIX, 'container-vertical-position', UTILS.alignItems(this.containerVerticalPosition))}
                ${UTILS.generateCssVar(CSS_PREFIX, 'container-horizontal-padding', this.containerHorizontalPadding)}
                ${UTILS.generateCssVar(CSS_PREFIX, 'container-vertical-padding', this.containerVerticalPadding)}
                ${UTILS.generateCssVar(CSS_PREFIX, 'container-horizontal-padding-mobile', this.containerHorizontalPaddingMobile)}
                ${UTILS.generateCssVar(CSS_PREFIX, 'container-vertical-padding-mobile', this.containerVerticalPaddingMobile)}
                ${UTILS.generateCssVar(CSS_PREFIX, 'container-border-width', 
                    IS.integer(this.containerBorderWidth)
                        ? `${this.containerBorderWidth}px`
                        : ''
                )}
                ${UTILS.generateCssVar(CSS_PREFIX, 'container-border-radius',
                    IS.integer(this.containerBorderRadius)
                        ? `${this.containerBorderRadius}px`
                        : ''
                )}
                ${UTILS.generateCssVar(CSS_PREFIX, 'container-border-color', this.containerBorderColor)}
                ${UTILS.generateCssVar(CSS_PREFIX, 'container-box-shadow', this.containerBoxShadow)}
                ${UTILS.generateCssVar(CSS_PREFIX, '1vh', `${window.innerHeight * 0.01}px`)}
                --dxp-c-component-wrapper-spacer-size: 28px;
            }

            ${this.getThemeSelector} community_layout-section {
                padding: 0;
            }

            /* CONTAIENR */
            ${this.getThemeSelector} .comm-login-form__container,
            ${this.getThemeSelector} .comm-forgot-password__container {
                min-width: unset;
                min-height: unset;
                padding: 0;
                border: 0;
                box-shadow: unset;
            }

            /* TITLE */
            ${this.getThemeSelector} .b2b-theme-login__title,
            ${this.getThemeSelector} community_login-check-email .comm-check-email__title,
            ${this.getThemeSelector} community_login-forgot-password .comm-forgot-password__title {
                padding: 0 0 1rem 0;
                font-size: 24px;
                line-height: 1.3;
                font-weight: 700;
                text-transform: uppercase;
                color: rgba(79, 76, 77, 1);
            }

            ${this.getThemeSelector} .b2b-theme-login__title {
                text-align: center;
            }

            /* BUTTON */
            ${this.getThemeSelector} .slds-button.slds-button_brand {
                font-size: 1rem;
                line-height: 43px;
                border-color: var(--b2b-color-black);
                background-color: var(--b2b-color-black);
                transition: color 0.1s, border-color 0.1s, background-color 0.1s;
            }

            ${this.getThemeSelector} .slds-button.slds-button_brand:hover,
            ${this.getThemeSelector} .slds-button.slds-button_brand:focus,
            ${this.getThemeSelector} .slds-button.slds-button_brand:active {
                border-color: var(--dxp-g-brand-1);
                background-color: var(--dxp-g-brand-1);
            }

            ${this.getThemeSelector} .slds-button.slds-button_neutral {
                border: 0 !important;
                line-height: 1.2;
                text-transform: none;
                background-color: transparent !important;
                transition: color 0.1s;
            }

            ${this.getThemeSelector} .slds-button.slds-button_neutral:hover,
            ${this.getThemeSelector} .slds-button.slds-button_neutral:focus,
            ${this.getThemeSelector} .slds-button.slds-button_neutral:active {
                text-decoration: underline;
                color: var(--dxp-g-brand-1);
            }

            /* ACTION */
            ${this.getThemeSelector} .b2b-theme-login__action,
            ${this.getThemeSelector} community_login-login-form .comm-login-form__forgot-password,
            ${this.getThemeSelector} community_login-login-form .comm-login-form__self-register {
                font-weight: 700;
                text-decoration: underline !important;
            }

            ${this.getThemeSelector} .b2b-theme-login__action {
                text-align: center;
            }

            /* LOGIN FORM */
            [data-path="login"] c-b2b-company-logo {
                margin-bottom: 20px;
            }

            ${this.getThemeSelector} community_login-login-error {
                display: block;
                margin-bottom: 20px;
            }

            ${this.getThemeSelector} community_login-login-error lightning-formatted-rich-text {
                display: block;
                text-align: center;
            }

            ${this.getThemeSelector} community_login-login-form .slds-form_compound {
                margin-bottom: 20px;
            }

            ${this.getThemeSelector} community_login-login-form .slds-form_compound lightning-input .slds-form-element__label {
                font-size: 12px;
            }

            ${this.getThemeSelector} community_login-login-form .slds-form_compound lightning-input:last-child {
                margin-bottom: 0;
            }

            ${this.getThemeSelector} community_login-login-form .slds-form_compound + .slds-form-element {
                margin: 0 !important;
            }

            ${this.getThemeSelector} community_login-login-form .comm-login-form__container div.slds-border_top:last-child {
                margin: 0;
                padding-top: 20px;
                border: 0;
            }

            /* LOGIN CHECK EMAIL */
            ${this.getThemeSelector} community_login-check-email .comm-check-email__container {
                min-width: unset;
                padding: 0;
                border: 0;
                box-shadow: none;
            }

            ${this.getThemeSelector} community_login-check-email p.slds-p-bottom_small {
                margin-bottom: 20px;
                padding: 0;
                text-align: center;
            }

            ${this.getThemeSelector} community_login-check-email .slds-form-element.slds-m-top_small,
            ${this.getThemeSelector} community_login-check-email .slds-form-element.slds-m-bottom_large {
                margin: 0;
            }

            /* FORGOT PASSWORD*/
            [data-path="ForgotPassword"] c-b2b-company-logo {
                margin-bottom: 20px;
            }

            ${this.getThemeSelector} .b2b-theme-login__text,
            ${this.getThemeSelector} community_login-forgot-password .comm-forgot-password__container lightning-formatted-text {
                display: block;
                margin-bottom: 20px;
                padding: 0;
                font-size: 12px;
                line-height: 1.3;
                text-align: center;
                color: var(--b2b-color-text);
            }

            ${this.getThemeSelector} .community_builder-outputRichText_outputRichText-host {
                overflow: unset;
            }

            ${this.getThemeSelector} community_login-forgot-password .slds-form-element__control .comm-forgot-password__username-input {
                padding-top: 0;
                margin-bottom: 20px;
            }

            ${this.getThemeSelector} community_login-forgot-password .slds-form-element:not(lightning-input) {
                display: flex;
                flex-direction: column;
                align-items: center;
                grid-row-gap: 1rem;
                margin-top: 0;
                margin-bottom: 0;
            }

            ${this.getThemeSelector} community_login-forgot-password lightning-input .slds-form-element__label {
                font-size: 12px;
            }

            ${this.getThemeSelector} community_login-forgot-password .comm-forgot-password__cancel-button {
                order: 2;
                width: auto;
                margin: 0;
                padding: 0;
                font-size: 14px;
                font-weight: 700;
                text-decoration-line: underline !important;
                color: var(--b2b-color-text) !important;
                box-shadow: unset !important;
                transition: color 0.1s !important;
            }

            ${this.getThemeSelector} community_login-forgot-password .comm-forgot-password__cancel-button:hover,
            ${this.getThemeSelector} community_login-forgot-password .comm-forgot-password__cancel-button:focus {
                color: var(--b2b-color-primary) !important;
            }

            ${this.getThemeSelector} community_login-forgot-password .comm-forgot-password__submit-button {
                order: 1;
                width: 100%;
            }

            /* CHECK PASSWORD*/
            [data-path="CheckPasswordResetEmail"] c-b2b-company-logo {
                margin-bottom: 20px;
            }

            [data-path="CheckPasswordResetEmail"] community_builder-html-editor .b2b-theme-login__text {
                margin-bottom: 30px !important;
                font-size: 14px !important;
                line-height: 1.5 !important;
            }

            [data-path="CheckPasswordResetEmail"] community_builder-html-editor .b2b-theme-login__text {
                margin-bottom: 30px !important;
                font-size: 14px !important;
                line-height: 1.5 !important;
            }

            [data-path="CheckPasswordResetEmail"] community_builder-html-editor .b2b-theme-login__text a {
                font-weight: 600;
                text-decoration: underline;
            }
        `;

        // BACKGROUND IMAGE
        if (this.showBackgroundImage && this.getBackgroundImage) {
            styleText += `
                ${this.getThemeSelector} {
                    --b2b-theme-login-background: url('${this.getBackgroundImage}');
                }
            `;
        } else {
            styleText += `
                ${this.getThemeSelector} {
                    ${UTILS.generateCssVar(CSS_PREFIX, 'background', this.background)}
                }
            `;
        }

        UTILS.addCustomCssStyles(this.template, styleText);
    }

}