import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

// METHODS
import getOrderData from '@salesforce/apex/B2BOrderConfirmation.getOrderData';
//To use subscription functionality uncomment this part
// import getSubscriptionNumber from '@salesforce/apex/B2BSubscriptionController.getCheckoutSubscriptionNumber';

// LABELS
import B2B_Order_Confirmation_Title from '@salesforce/label/c.B2B_Order_Confirmation_Title';
import B2B_Order_Confirmation_Order_Number from '@salesforce/label/c.B2B_Order_Confirmation_Order_Number';
import B2B_Order_Confirmation_Button_Order from '@salesforce/label/c.B2B_Order_Confirmation_Button_Order';
import B2B_Order_Confirmation_Button_Continue from '@salesforce/label/c.B2B_Order_Confirmation_Button_Continue';

const LABELS = {
    title: B2B_Order_Confirmation_Title,
    orderNumber: B2B_Order_Confirmation_Order_Number,
    buttonContinue: B2B_Order_Confirmation_Button_Continue,
    buttonOrder: B2B_Order_Confirmation_Button_Order,
};

const COMPONENT_NAME = 'b2b-order-confirmation';

export default class B2bOrderConfirmation extends LightningElement {
    @api recordId = null;
    @api showContentImage = false;
    @api contentImage = null;
    @api contentImageMaxWidth = null;
    @api title = null;
    @api titleColor = null;
    @api orderNumberLabel = null;
    @api orderNumberColor = null;
    @api buttonContinueLabel = null;
    @api buttonOrderLabel = null;
    @api showBackgroundImage = false;
    @api backgroundImage = null;
    @api enableSubscriptions = false;
    @api subscriptionNumberLabel = null;

    @track isFirstRender = true;
    @track labels = LABELS;
    @track customCssContainer = UTILS.customCssContainer;
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);
    @track orderNumber = null;
    @track subscriptionNumber = null;
    @track subscriptionId = null;

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper}`;
    }

    get getContentImage() {
        return this.showContentImage
            && IS.stringNotEmpty(this.contentImage)
                ? UTILS.cmsLink(this.contentImage)
                : null;
    }

    get getTile() {
        return IS.stringNotEmpty(this.title)
            ? this.title
            : LABELS.title;
    }

    get getOrderNumberLabel() {
        return IS.stringNotEmpty(this.orderNumberLabel)
            ? this.orderNumberLabel
            : LABELS.orderNumber;
    }

    get getButtonContinueLabel() {
        return IS.stringNotEmpty(this.buttonContinueLabel)
            ? this.buttonContinueLabel
            : LABELS.buttonContinue;
    }

    get getButtonContinueLink() {
        return UTILS.link('/');
    }

    get showButtonOrder() {
        return !UTILS.isGuest
            && IS.stringNotEmpty(this.recordId);
    }

    get getButtonOrderLabel() {
        return IS.stringNotEmpty(this.buttonOrderLabel)
            ? this.buttonOrderLabel
            : LABELS.buttonOrder;
    }

    get getButtonOrderLink() {
        return this.showButtonOrder
            ? UTILS.link(`/OrderSummary/${this.recordId}`)
            : null;
    }

    get getBackgroundImage() {
        return UTILS.cmsLink(this.backgroundImage);
    }

    //To use subscription functionality uncomment this part
    // get getSubscriptionLabel() {
    //     return this.subscriptionNumberLabel;
    // }
    //
    // get getSubscriptionLink() {
    //     return this.subscriptionId
    //         ? UTILS.link(`/subscription?recordId=${this.subscriptionId}`)
    //         : null;
    // }
    //-----------------------------------------------------

    // LIFECYCLES
    async connectedCallback() {
        // UTILS.refreshCartLWR();
        UTILS.scrollToTop();

        if (UTILS.isGuest) {
            let params = UTILS.getUrlParams();
            if (IS.objectNotEmpty(params)) {
                if (IS.stringNotEmpty(params.id)) {
                    this.recordId = params.id;
                } else if (IS.stringNotEmpty(params.recordId)) {
                    this.recordId = params.recordId;
                }
            }
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
            .${this.wrapper} {
                ${UTILS.generateCssVar('orderConfirmation', 'contentImageMaxWidth', this.contentImageMaxWidth)}
                ${UTILS.generateCssVar('orderConfirmation', 'titleColor', this.titleColor)}
                ${UTILS.generateCssVar('orderConfirmation', 'orderNumberColor', this.orderNumberColor)}
            }
        `;

        if (this.showBackgroundImage && IS.stringNotEmpty(this.getBackgroundImage)) {
            styleText += `
                .b2b-theme__body-content {
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

    async getInitialData() {
        if (!IS.stringNotEmpty(this.recordId)) {
            return;
        }

        let response = await UTILS.doRequest(getOrderData, {
            recordId: this.recordId
        });
        let data = UTILS.responseData(response);

        if (UTILS.responseSuccess(response)) {
            this.orderNumber = data;
        } else {
            if (IS.stringNotEmpty(response.responseMessage)) {
                console.error(response.responseMessage);
            }
        }

    //To use subscription functionality uncomment this part
    //     if (this.enableSubscriptions) {
    //         await this.getSubscriptionData();
    //     }
    //-----------------------------------------------------
    }

    //To use subscription functionality uncomment this part
    // async getSubscriptionData() {
    //     if (!IS.stringNotEmpty(this.recordId)) {
    //         return;
    //     }
    //
    //     let response = await UTILS.doRequest(getSubscriptionNumber, {
    //         orderId: this.recordId
    //     });
    //     console.log('--label--', this.subscriptionNumberLabel);
    //     let data = UTILS.responseData(response);
    //     if (UTILS.responseSuccess(response) && data) {
    //         this.subscriptionNumber = data.Name;
    //         this.subscriptionId = data.Id;
    //     } else {
    //         if (IS.stringNotEmpty(response.responseMessage)) {
    //             console.error(response.responseMessage);
    //         }
    //     }
    // }
    //-----------------------------------------------------
}