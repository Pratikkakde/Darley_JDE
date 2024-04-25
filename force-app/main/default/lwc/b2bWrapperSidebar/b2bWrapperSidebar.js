import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

/**
* @slot sidebar
* @slot content
*/

export default class B2bWrapperSidebar extends LightningElement {
    @track componentName = 'b2b-wrapper-sidebar';
    @track cssPrefix = 'wrapper-sidebar';

    @api componentId = null;
    @api sidebarPosition = null;
    @api sidebarWidth = null;
    @api verticalPadding = null;
    @api horizontalPadding = null;

    @track isFirstRender = true;
    @track customCssContainer = UTILS.customCssContainer;
    @track wrapper = UTILS.wrapper(this.componentName);
    @track wrapperId = UTILS.wrapperId(this.componentName, this.componentId);

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper} ${this.wrapperId}`;
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
        let order = IS.stringNotEmpty(this.sidebarPosition)
            && this.sidebarPosition === 'Right'
                ? '1'
                : '0';

        let styleText = `
            .${this.wrapper}.${this.wrapperId} {
                ${UTILS.generateCssVar(this.cssPrefix, 'sidebar-order', order)}
                ${UTILS.generateCssVar(this.cssPrefix, 'sidebar-width', this.sidebarWidth)}
                ${UTILS.generateCssVar(this.cssPrefix, 'vertical-padding', this.verticalPadding)}
                ${UTILS.generateCssVar(this.cssPrefix, 'horizontal-padding', this.horizontalPadding)}
            }
        `;
        UTILS.addCustomCssStyles(this.template, styleText);
    }

}