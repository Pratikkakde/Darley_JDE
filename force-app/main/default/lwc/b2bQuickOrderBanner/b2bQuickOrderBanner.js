import {LightningElement, api, track} from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';
// import b2b_quick_order_title from '@salesforce/label/c.B2B_Quick_order_title';
import b2b_quick_order_button from '@salesforce/label/c.B2B_Quick_order_button';
import b2b_if_you_know_the_product_name_or_SKU_number_of_the_products_you_want_to_order from '@salesforce/label/c.B2B_If_you_know_the_product_name_or_SKU_number_of_the_products_you_want_to_order';
import isGuest from '@salesforce/user/isGuest';

const COMPONENT_NAME = 'b2b-quick-order';

export default class B2BQuickOrderBanner extends LightningElement {

    // title = b2b_quick_order_title;
    title = 'Quick Order';
    buttonLabel = b2b_quick_order_button;
    bannerBody = b2b_if_you_know_the_product_name_or_SKU_number_of_the_products_you_want_to_order;

    // BACKGROUND
    @api showBackgroundImage = false;
    @api backgroundImage = null;
    @api backgroundColor = null;
    @api backgroundMinHeight = null;
    @api bannerNavigateTo = null;

    // CONTAINER
    @api containerMaxWidth = null;
    @api containerColor = null;
    @api containerHorizontalPosition = null;
    @api containerVerticalPosition = null;
    @api containerBorderRadius = null;

    // TITLE
    @api showTitle = false;
    @api titleColor = null;
    @api titleAlign = null;
    @api titleSize = null;

    @track isFirstRender = true;
    @track customCssContainer = UTILS.customCssContainer;
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);
    @track wrapperId = UTILS.wrapperId(COMPONENT_NAME);

    isGuestUser = isGuest;

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper} ${this.wrapperId}`;
    }

    get getBackgroundImage() {
        return UTILS.cmsLink(this.backgroundImage);
    }

    get getShowTitle() {
        return this.showTitle && IS.stringNotEmpty(this.title);
    }

    get getButtonLink() {
        return UTILS.link(this.bannerNavigateTo);
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
        let containerHorizontalPosition = UTILS.justifyContent(this.containerHorizontalPosition) || 'center';
        let containerVerticalPosition = UTILS.alignItems(this.containerVerticalPosition) || 'center';
        let titleAlign = UTILS.textAlign(this.titleAlign) || 'center';

        let styleText = `
            .${this.wrapper}.${this.wrapperId} {
                min-height: ${this.backgroundMinHeight || '300px'};
                background-color: ${IS.stringNotEmpty(this.backgroundColor)
                    ? `${this.backgroundColor} !important;`
                    : 'transparent'};
                justify-content: ${containerHorizontalPosition};
                align-items: ${containerVerticalPosition};
            }
            .${this.wrapper}.${this.wrapperId} .${COMPONENT_NAME}__container {
                max-width: ${this.containerMaxWidth || 600 }px;
                ${this.containerBorderRadius || this.containerBorderRadius == 0 ? `border-radius: ${this.containerBorderRadius}px;` : ''}
                ${this.containerColor ? `background-color: ${this.containerColor};` : ''}
            }
            .${this.wrapper}.${this.wrapperId} .${COMPONENT_NAME}__title {
                ${this.titleColor ? `color: ${this.titleColor};` : ''}
                text-align: ${titleAlign};
                font-size: ${this.titleSize || '3rem'};
            }
            @media (max-width: 767.98px) {
                .${this.wrapper}.${this.wrapperId} .${COMPONENT_NAME}__title {
                    font-size: 2rem;
                }
            }
        `;
        
        // BACKGROUND IMAGE
        if (this.showBackgroundImage && this.getBackgroundImage) {
            styleText += `
                .${this.wrapper}.${this.wrapperId} {
                    background-image: url('${this.getBackgroundImage}');
                    background-position: center center;
                    background-repeat: no-repeat;
                    background-size: cover;
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