import { LightningElement, track, api } from 'lwc';
import { UTILS, IS, STORAGE } from 'c/b2bUtils';

// STATIC RESOURCE
import b2bImages from '@salesforce/resourceUrl/b2bImages';

// METHODS
import getNavigationMenuItems from '@salesforce/apex/B2BFooterController.getNavigationMenuItems';

// LABELS
import B2B_Footer_Menu_Column1_Name from '@salesforce/label/c.B2B_Footer_Menu_Column1_Name';
import B2B_Footer_Menu_Column2_Name from '@salesforce/label/c.B2B_Footer_Menu_Column2_Name';
import B2B_Footer_Menu_Column3_Name from '@salesforce/label/c.B2B_Footer_Menu_Column3_Name';
import B2B_Footer_Menu_Column4_Name from '@salesforce/label/c.B2B_Footer_Menu_Column4_Name';
import B2B_Footer_Phone from '@salesforce/label/c.B2B_Footer_Phone';
import B2B_Footer_Fax from '@salesforce/label/c.B2B_Footer_Fax';
import B2B_Footer_Company_Name from '@salesforce/label/c.B2B_Footer_Company_Name';
import B2B_Footer_Logo_Title from '@salesforce/label/c.B2B_Footer_Logo_Title';
import B2B_Footer_Address_Title from '@salesforce/label/c.B2B_Footer_Address_Title';
import B2B_Footer_Email_Title from '@salesforce/label/c.B2B_Footer_Email_Title';
import B2B_Footer_Phone_Title from '@salesforce/label/c.B2B_Footer_Phone_Title';
import B2B_Footer_Short_Tittle from '@salesforce/label/c.B2B_Short_About_Us_Tittle';
import B2B_Footer_Short_Text from '@salesforce/label/c.B2B_Short_About_Us_Text';


const LABELS = {
    menuTitle1: B2B_Footer_Menu_Column1_Name,
    menuTitle2: B2B_Footer_Menu_Column2_Name,
    menuTitle3: B2B_Footer_Menu_Column3_Name,
    menuTitle4: B2B_Footer_Menu_Column4_Name,
    phone: B2B_Footer_Phone,
    fax: B2B_Footer_Fax,
    companyName: B2B_Footer_Company_Name,
    logoTitle: B2B_Footer_Logo_Title,
    addressTitle: B2B_Footer_Address_Title,
    emailTitle: B2B_Footer_Email_Title,
    phoneTitle: B2B_Footer_Phone_Title,
    shortAboutUsTittle :B2B_Footer_Short_Tittle,
    shortAboutUsText :B2B_Footer_Short_Text,
};

const COMPONENT_NAME = 'b2b-footer';

export default class B2bFooter extends LightningElement {
    // MENU
    @api menuColumn1Label = null;
    @api menuColumn1ApiName = null;
    @api menuColumn2Label = null;
    @api menuColumn2ApiName = null;
    @api menuColumn4Label = null;
    @api menuColumn4ApiName = null;
    @api menuColumn3Label = null;
    @api menuColumnLabel = null;

    // COMPANY
    @api companyStreetLine1 = null;
    @api companyStreetLine2 = null;
    @api companyEmail = null;
    @api companyPhone = null;
    @api companyFax = null;

    // SOCIAL
    @api socialLabel1 = null;
    @api socialValue1 = null;
    @api socialLabel2 = null;
    @api socialValue2 = null;
    @api socialLabel3 = null;
    @api socialValue3 = null;
    @api socialLabel4 = null;
    @api socialValue4 = null;
    @api socialLabel5 = null;
    @api socialValue5 = null;
    @api socialLabel6 = null;
    @api socialValue6 = null;

    // COPYRIGHT
    @api copyrightLabel = null;

    // VARIABLES
    @track isFirstRender = true;
    @track labels = LABELS;
    @track customCssContainer = UTILS.customCssContainer;
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);

    @track menuTitle1 = null;
    @track menuColumn1 = [];
    @track menuTitle2 = null;
    @track menuColumn2 = [];
    @track menuTitle4 = null;
    @track menuColumn4 = [];

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper}`;
    }

    get getLogo() {
        return `${b2bImages}/footer-logo.png`;
    }

    get getLogoLink() {
        return UTILS.link('/');
    }

    get getMenuTitle3() {
        return IS.stringNotEmpty(this.menuColumn3Label)
            ? this.menuColumn3Label
            : LABELS.menuTitle3;
    }

   
    get showCompanyStreet() {
        return IS.stringNotEmpty(this.companyStreetLine1)
            || IS.stringNotEmpty(this.companyStreetLine2);
    }

    get getCompanyAddressLink() {
        return this.showCompanyStreet
            ? `https://www.google.com/maps/search/${[this.companyStreetLine1, this.companyStreetLine2].join(',')}/`
            : null;
    }

    get getCompanyEmailLink() {
        return IS.stringNotEmpty(this.companyEmail)
            ? `mailto:${this.companyEmail}`
            : null;
    }

    get getCompanyPhoneLink() {
        return IS.stringNotEmpty(this.companyPhone)
            ? `tel:${this.companyPhone}`
            : null;
    }

    get getCopyrightLabel() {
        return IS.stringNotEmpty(this.copyrightLabel)
            ? UTILS.prepareLabel(this.copyrightLabel, [new Date().getFullYear()])
            : null;
    }

    get socialOptions() {
        let result = [];
        for (let i = 1; i <= 6; i++) {
            let newItem = {
                label: IS.stringNotEmpty(this['socialLabel' + i]) ? this['socialLabel' + i] : null,
                value: IS.stringNotEmpty(this['socialValue' + i]) ? this['socialValue' + i] : null,
                icon: null,
                title: null,
                class: null
            };
            if (newItem.label && newItem.value) {
                newItem.icon = `${newItem.label.toLowerCase()}`;
                newItem.title = `${newItem.label}`;
                newItem.class = `b2b-social__${newItem.label.toLowerCase()}`;
                result.push(newItem);
            }
        }
        return result;
    }

    // LIFECYCLES
    connectedCallback() {
        this.loadLocalStorageMenu();
        this.getInitialData();
    }

    renderedCallback() {
        if (this.isFirstRender) {
            this.isFirstRender = false;
            this.addCustomCssStyles();
        }
    }

    // METHODS
    loadLocalStorageMenu() {
        let footerMenu = STORAGE.getFooterMenu();
        if (IS.objectNotEmpty(footerMenu)) {
            if (IS.stringNotEmpty(this.menuColumn1ApiName)) {
                this.menuTitle1 = footerMenu.menuTitle1 || null;
                this.menuColumn1 = footerMenu.menuColumn1 || [];
            }

            if (IS.stringNotEmpty(this.menuColumn2ApiName)) {
                this.menuTitle2 = footerMenu.menuTitle2 || null;
                this.menuColumn2 = footerMenu.menuColumn2 || [];
            }
            
            if (IS.stringNotEmpty(this.menuColumn4ApiName)) {
                this.menuTitle4 = footerMenu.menuTitle4 || null;
            }
        }
    }

    addCustomCssStyles() {
        let styleText = `
            .${this.wrapper} .b2b-social__item c-b2b-icon .b2b-icon-social__wrapper {
                --b2b-icon-width: 20px;
            }

            .${this.wrapper} c-b2b-icon svg {
                fill:rgba(237, 27, 45, 1);
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

    async getInitialData() {
        if (!(
            IS.stringNotEmpty(this.menuColumn1ApiName)
            || IS.stringNotEmpty(this.menuColumn2ApiName)
            || IS.stringNotEmpty(this.menuColumn4ApiName)
        )) return;
        let response = await UTILS.doRequest(getNavigationMenuItems, {
            menuLabel1: this.menuColumn1ApiName,
            menuLabel2: this.menuColumn2ApiName,
            menuLabel4: this.menuColumn4ApiName
        });
        let data = UTILS.responseData(response);
        this.parseResponse(data);
        this.parseMenuData(data);
    }

    parseMenuData(data){
       data.forEach(item => {
            if(item.label == this.menuColumn4ApiName){
                if (IS.arrayNotEmpty(item.options)) {
                    item.options.forEach(option => option.value = UTILS.link(option.value));
                }
                this.menuColumn4 = item.options;
            }
       });
    }

    parseResponse(data) {
        if (IS.arrayNotEmpty(data)) {
            let j = 0;
            for (let i = 0; i <=1; i++) {
                if (IS.objectNotEmpty(data[j]) && IS.stringNotEmpty(this[`menuColumn${i + 1}ApiName`])) {
                    this[`menuTitle${i + 1}`] = IS.stringNotEmpty(this[`menuColumn${i + 1}Label`])
                        ? this[`menuColumn${i + 1}Label`]
                        : IS.stringNotEmpty(data[j].label)
                            ? data[j].label
                            : null;

                    this[`menuColumn${i + 1}`] = this.parseOptions(data[j].options).map((item) => {
                        item.value = UTILS.link(item.value);
                        return item;
                    });
                    j = j + 1;
                }
            }
        }

        STORAGE.setFooterMenu({
            menuTitle1: this.menuTitle1,
            menuColumn1: this.menuColumn1,
            menuTitle2: this.menuTitle2,
            menuColumn2: this.menuColumn2,
            menuTitle4: this.menuTitle4,
            menuColumn4: this.menuColumn4,
        });

    }

    parseOptions(array){
        let result = [];
        if (IS.arrayNotEmpty(array)) {
            array.forEach((item) => {
                if (
                    IS.stringNotEmpty(item.label) &&
                    IS.stringNotEmpty(item.value)
                ) {
                    result.push({
                        label: item.label,
                        value: item.value,
                        target: item.target, 
                    });
                }
            });
        }
        return result;
    }


}