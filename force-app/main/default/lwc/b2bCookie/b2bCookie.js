import { LightningElement, track, api } from 'lwc';
import { UTILS, IS, STORAGE } from 'c/b2bUtils';

// LABELS
import B2B_Cookie_Close from '@salesforce/label/c.B2B_Cookie_Close';
import B2B_Cookie_Notification_Message from '@salesforce/label/c.B2B_Cookie_Notification_Message';
import B2B_Cookie_Submit_Label from '@salesforce/label/c.B2B_Cookie_Submit_Label';

const LABELS = {
    close: B2B_Cookie_Close,
    notificationMessage: B2B_Cookie_Notification_Message,
    submitLabel: B2B_Cookie_Submit_Label,
};

const COMPONENT_NAME = 'b2b-cookie';
const COOKIE_STORE_ACCEPTED = 'CookieStoreAccepted';
const LEFT = 'Left';
const CENTER = 'Center';
const RIGHT = 'Right';
const TOP = 'Top';
const MIDDLE = 'Middle';
const BOTTOM = 'Bottom';

export default class B2bCookie extends LightningElement {
    @api cookieExpireDays = null;
    @api cookieDelayedDays = null;
    @api submitLabel = null;
    @api privacyPolicyLink = null;
    @api privacyPolicyLabel = null;
    @api companyName = null;
    @api containerMaxWidth = null;
    @api horizontalAlignment = null;
    @api verticalAlignment = null;
    @api buttonAlignment = null;
    @api textColor = null;
    @api backgroundColor = null;

    @track customCssContainer = UTILS.customCssContainer;
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);
    @track labels = LABELS;
    @track isFirstRender = true;
    @track cookieAccepted = false;
    @track cookieDelayed = false;

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper}`;
    }

    get showComponent() {
        return !IS.true(this.cookieAccepted)
            && !IS.true(this.cookieDelayed);
    }

    get getSubmitLabel() {
        return IS.stringNotEmpty(this.submitLabel)
            ? this.submitLabel
            : LABELS.submitLabel;
    }

    get getPrivacyPolicyLink() {
        return UTILS.link(this.privacyPolicyLink);
    }

    get getPrivacyPolicyLabel() {
        return UTILS.prepareLabel(this.privacyPolicyLabel, [
            IS.stringNotEmpty(this.companyName) ? this.companyName : ''
        ]).trim();
    }

    // LIFECYCLE
    connectedCallback() {
        this.getInitialData();
    }

    renderedCallback() {
        if (this.isFirstRender) {
            this.addCustomCssStyles();
            this.isFirstRender = false;
        }
    }

    // METHODS
    addCustomCssStyles() {
        let leftPosition = 'unset';
        let rightPosition = 'unset';
        let horizontalTransform = '0';
        let topPosition = 'unset';
        let bottomPosition = 'unset';
        let verticalTransform = '0';

        let leftTopCorner = '0.3125rem';
        let rightTopCorner = '0.3125rem';
        let rightBottomCorner = '0.3125rem';
        let leftBottomCorner = '0.3125rem';

        if (this.horizontalAlignment === LEFT) {
            leftPosition = '0';
            leftTopCorner = '0';
            leftBottomCorner = '0';

        } else if (this.horizontalAlignment === CENTER) {
            leftPosition = '50%';
            horizontalTransform = '-50%';

        } else if (this.horizontalAlignment === RIGHT) {
            rightPosition = '0';
            rightTopCorner = '0';
            rightBottomCorner = '0';
        }

        if (this.verticalAlignment === TOP) {
            topPosition = '0';
            leftTopCorner = '0';
            rightTopCorner = '0';

        } else if (this.verticalAlignment === MIDDLE) {
            topPosition = '50%';
            verticalTransform = '-50%';

        } else if (this.verticalAlignment === BOTTOM) {
            bottomPosition = '0';
            leftBottomCorner = '0';
            rightBottomCorner = '0';
        }

        let borderRadius = `${leftTopCorner} ${rightTopCorner} ${rightBottomCorner} ${leftBottomCorner}`;
        let buttonAlignment = UTILS.justifyContent(this.buttonAlignment);

        let styleText = `
            .${this.wrapper} {
                ${UTILS.generateCssVar('cookie', 'containerMaxWidth', `${this.containerMaxWidth}`)}
                ${UTILS.generateCssVar('cookie', 'leftPosition', leftPosition)}
                ${UTILS.generateCssVar('cookie', 'rightPosition', rightPosition)}
                ${UTILS.generateCssVar('cookie', 'topPosition', topPosition)}
                ${UTILS.generateCssVar('cookie', 'bottomPosition', bottomPosition)}
                ${UTILS.generateCssVar('cookie', 'transformPosition', `translate(${horizontalTransform}, ${verticalTransform})`)}
                ${UTILS.generateCssVar('cookie', 'textColor', this.textColor)}
                ${UTILS.generateCssVar('cookie', 'backgroundColor', this.backgroundColor)}
                ${UTILS.generateCssVar('cookie', 'borderRadius', borderRadius)}
                ${UTILS.generateCssVar('cookie', 'buttonAlignment', buttonAlignment)}
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

    getInitialData() {
        this.checkCookieAccepted();
        this.checkCookieDelayed();
        if (!IS.true(this.cookieAccepted)) {
            UTILS.setSFCookie(false);
        }
    }

    checkCookieAccepted() {
        let cookieAccepted = false;
        let cookie = UTILS.parseCookie(document.cookie);
        if (
            IS.objectNotEmpty(cookie)
            && IS.objectProperty(cookie, COOKIE_STORE_ACCEPTED)
            && IS.stringNotEmpty(cookie[COOKIE_STORE_ACCEPTED])
        ) {
            cookieAccepted = true;
        }
        this.cookieAccepted = cookieAccepted;
    }
    
    checkCookieDelayed() {
        this.cookieDelayed = STORAGE.getCookieDelay(this.cookieDelayedDays);
    }

    // HANDLERS
    handleClickButton() {
        UTILS.addCookie(COOKIE_STORE_ACCEPTED, true, this.cookieExpireDays);
        UTILS.setSFCookie(true);
        this.checkCookieAccepted();
    }

    handleClickCloseButton() {
        this.cookieDelayed = STORAGE.setCookieDelay(this.cookieDelayedDays);
    }

}