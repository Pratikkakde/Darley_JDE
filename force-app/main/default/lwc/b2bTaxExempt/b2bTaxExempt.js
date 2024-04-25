import {LightningElement, api} from 'lwc';

import CertCapture from '@salesforce/resourceUrl/B2BAvalaraCertCapture';
import {loadScript} from "lightning/platformResourceLoader";
import _generateToken from '@salesforce/apex/B2BCheckoutController.getAvalaraEcommerceToken';
import { UTILS, IS } from 'c/b2bUtils';

const DEFAULT_SHIPZONE = 'Kentucky';

export default class B2bTaxExempt extends LightningElement {
    avalaraToken = null;

    async connectedCallback() {
        await loadScript(this, CertCapture);
        await this.generateToken();
        await this.initCert();
    }

    async generateToken() {
        const customerCode = IS.objectNotEmpty(this.customerTaxInformation) && IS.stringNotEmpty(this.customerTaxInformation.avalaraCustomerCode) ? this.customerTaxInformation.avalaraCustomerCode : null;
        const generateTokenDataResponse = await _generateToken({avalaraCustomerCode:customerCode});
        let avalaraTokenResponse = UTILS.responseData(generateTokenDataResponse);
        this.avalaraToken = UTILS.responseSuccess(generateTokenDataResponse) && IS.objectNotEmpty(avalaraTokenResponse) && IS.stringNotEmpty(avalaraTokenResponse.token) ? avalaraTokenResponse.token : null;
    }

    @api customerTaxInformation;
    @api customerInformation;
    @api customerInfo;
    avalaraCustomerCode;
    @api isNewAvalaraCustomer;
    @api customerNumber;
    @api initCert() {
        let certForm = this.template.querySelector('.b2b-cert-form-container');
        let shipZone = DEFAULT_SHIPZONE;
        if (certForm) {
            GenCert.init(
                certForm,
                {
                    token: this.avalaraToken,
                    edit_purchaser: true,
                    onCertSuccess: () => {
                        this.closeModal();
                    },
                    onUpload: () => {
                        this.closeModal();
                    },
                    onSaveCustomer: () => {
                        this.sendCustomerNumber();
                    }
                },
            );
            //Create Customer and assign contact info automatically when loading Ecom SDK
            
            GenCert.setCustomerNumber(this.avalaraCustomerCode);

            if(IS.objectNotEmpty(this.customerTaxInformation) && IS.objectNotEmpty(this.customerTaxInformation.customerInfo)) {
                GenCert.setCustomerData(this.customerTaxInformation.customerInfo);
            }

            shipZone = IS.objectNotEmpty(this.customerTaxInformation) && IS.stringNotEmpty(this.customerTaxInformation.shipZone) ? this.customerTaxInformation.shipZone : shipZone;
            GenCert.setShipZone(shipZone);
            GenCert.show();
        }
    }

    sendCustomerNumber() {
        this.customerNumber = GenCert.getCustomerNumber();
        if(IS.objectNotEmpty(this.customerTaxInformation) && IS.true(this.customerTaxInformation.isNewAvalaraCustomer) && IS.stringNotEmpty(this.customerTaxInformation.avalaraCustomerCode)) {
            this.dispatchEvent(new CustomEvent('savecustomer',{detail:this.customerTaxInformation.avalaraCustomerCode}));
        }
    }

    closeModal() {
        this.dispatchEvent(new CustomEvent('closetaxexemptmodal',{detail:this.customerNumber}));
    }
}