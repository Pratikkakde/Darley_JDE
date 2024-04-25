import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { UTILS, IS, STORAGE } from 'c/b2bUtils';

// METHODS
import getMyAccountMenuItem from '@salesforce/apex/B2BMyAccountMenuController.getMyAccountMenuItem';

// LABELS
import B2B_My_Account_Menu_Title from '@salesforce/label/c.B2B_My_Account_Menu_Title';

const LABELS = {
    title: B2B_My_Account_Menu_Title
};

const COMPONENT_NAME = 'b2b-my-account-menu';
const DEFAULT_ICON = 'utility:record';
const CONTACT_US_ROUTE = '/contact-us';

export default class B2bMyAccountMenu extends NavigationMixin(LightningElement) {
    @api menuApiName = null;
    @api menuTitle = null;
    
    @track effectiveAccountId = null;
    @track isFirstRender = true;
    @track labels = LABELS;
    @track customCssContainer = UTILS.customCssContainer;
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);

    @track menuOptions = [];

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper}`;
    }

    get getMenuTitle() {
        return IS.stringNotEmpty(this.menuTitle)
            ? this.menuTitle
            : LABELS.title;
    }

    // LIFECYCLES
    async connectedCallback() {
        this.effectiveAccountId = await UTILS.getEffectiveAccountId();
        let menuOptions = STORAGE.getMyAccountMenu();
        if (IS.arrayNotEmpty(menuOptions)) {
            this.menuOptions = menuOptions;
            this.updateActivePage();
        }
        this.getInitialData();
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
            .b2b-my-account-menu__item lightning-icon svg {
                fill: var(--dxp-g-root-contrast);
                transition: fill 0.1s;
            }

            .b2b-my-account-menu__item-active lightning-icon svg,
            .b2b-my-account-menu__item:hover lightning-icon svg {
                fill: rgba(237, 27, 45, 1);
            }
        `;

        // Hide "My Account Menu" for Guest Users
        if (
            UTILS.isGuest
            && IS.stringIncludes(window.location.pathname, CONTACT_US_ROUTE)
        ) {
            styleText += `
                .b2b-layout__row {
                    display: block !important;
                }

                .b2b-layout__sidebar {
                    display: none !important;
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

    async getInitialData() {
        if (!IS.stringNotEmpty(this.menuApiName)) return;

        let response = await UTILS.doRequest(getMyAccountMenuItem, {
            menuLabel: this.menuApiName
        });
        let data = UTILS.responseData(response);

        if (UTILS.responseSuccess(response)) {
            this.parseResponse(data);
            this.updateActivePage();
        } else {
            console.error(response);
        }
    }

    parseResponse(data) {
        let menuOptions = [];
        if (IS.arrayNotEmpty(data)) {
            data.forEach((item) => {
                if (
                    IS.stringNotEmpty(item.label)
                    && IS.stringNotEmpty(item.url)
                ) {
                    menuOptions.push({
                        value: IS.stringNotEmpty(item.url)
                            ? UTILS.link(item.url)
                            : null,
                        pageApiName: IS.stringNotEmpty(item.pageApiName)
                            ? item.pageApiName
                            : null,
                        label: item.label,
                        icon: item.iconName || DEFAULT_ICON,
                        itemClass: 'b2b-my-account-menu__item',
                    });
                }
            });
        }
        STORAGE.setMyAccountMenu(menuOptions);
        this.menuOptions = menuOptions;
    }

    updateActivePage() {
        if (IS.arrayNotEmpty(this.menuOptions)) {
            this.menuOptions.forEach((item) => {
                let itemClass = 'b2b-my-account-menu__item';
                let link = item.value;

                [UTILS.communityBasePath, '/home', '/Home', '/Default'].forEach((stringToReplace) => {
                    if (IS.stringIncludes(link, stringToReplace)) {
                        link = link.replace(stringToReplace, '');
                    }
                });

                if (
                    IS.stringIncludes(window.location.href, link)
                    && IS.stringIncludes(item.value, link)
                    || (
                        IS.stringIncludes(item.value, '-account')
                        && IS.stringIncludes(window.location.href, '/account')
                    )
                ) {
                    itemClass += ' b2b-my-account-menu__item-active';
                }
                item.itemClass = itemClass;
            });
        }
        STORAGE.setMyAccountMenu(this.menuOptions);
    }

    // HANDLERS
    handleClickMenuItem(event) {
        let pageApiName = event.currentTarget.dataset.pageapiname;
        if (IS.stringNotEmpty(pageApiName)) {
            event.preventDefault();
            if (IS.stringIncludes(pageApiName, 'OrderSummaryList')) {
                this[NavigationMixin.Navigate]({
                    type: 'standard__objectPage',
                    attributes: {
                        objectApiName: 'OrderSummary',
                        actionName: 'list'
                    },
                    state: {
                        filterName: 'Default'
                    }
                });
            } else if (IS.stringIncludes(pageApiName, 'Account_Detail__c')) {
                UTILS.navigateTo(`/account/${this.effectiveAccountId}`);
            } else {
                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        name: pageApiName
                    },
                });
            }
        }
    }

}