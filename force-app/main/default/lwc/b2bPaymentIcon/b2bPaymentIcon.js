import { LightningElement, track, api } from 'lwc';
import { IS } from 'c/b2bUtils';

const COMPONENT_NAME = 'b2b-payment-icon';

const EFT = 'eft';
const CRYPTO = 'crypto';
const DEFAULT = 'default';
const VISA = 'visa';
const MASTERCARD = 'mastercard';
const AMERICANEXPRESS = 'americanexpress';
const DANKORT = 'dankort';
const DINERS = 'diners';
const DINERS_CLUB = 'dinersclub';
const DISCOVER = 'discover';
const JCB = 'jcb';
const MAESTRO = 'maestro';
const UNIONPAY = 'unionpay';
const VISAELECTRON = 'visaelectron';
const ELO = 'elo';
const HIPERCARD = 'hipercard';
const UATP = 'uatp';

export default class B2bPaymentIcon extends LightningElement {
    @api iconName = null;

    @track iconList = [
        EFT, CRYPTO, DEFAULT, VISA, MASTERCARD, AMERICANEXPRESS, DANKORT, DINERS,
        DINERS_CLUB, DISCOVER, JCB, MAESTRO, UNIONPAY, VISAELECTRON, ELO,
        HIPERCARD, UATP
    ];

    // GETTERS
    get getIconName() {
        return IS.stringNotEmpty(this.iconName)
            && this.iconList.indexOf(this.iconName.toLowerCase()) !== -1
                ? this.iconName.toLowerCase()
                : DEFAULT;
    }

    get wrapperClass() {
        return `${COMPONENT_NAME}__wrapper ${COMPONENT_NAME}__${this.getIconName}`;
    }

    get isEft() {
        return this.getIconName === EFT;
    }

    get isCrypto() {
        return this.getIconName === CRYPTO;
    }

    get isDefault() {
        return this.getIconName === DEFAULT;
    }

    get isVisa() {
        return this.getIconName === VISA;
    }

    get isMastercard() {
        return this.getIconName === MASTERCARD;
    }

    get isAmex() {
        return this.getIconName === AMERICANEXPRESS;
    }

    get isDankort() {
        return this.getIconName === DANKORT;
    }

    get isDiners() {
        return this.getIconName === DINERS
            || this.getIconName === DINERS_CLUB;
    }

    get isDiscover() {
        return this.getIconName === DISCOVER;
    }

    get isJcb() {
        return this.getIconName === JCB;
    }

    get isMaestro() {
        return this.getIconName === MAESTRO;
    }

    get isUnionpay() {
        return this.getIconName === UNIONPAY;
    }

    get isVisaelectron() {
        return this.getIconName === VISAELECTRON;
    }

    get isElo() {
        return this.getIconName === ELO;
    }

    get isHipercard() {
        return this.getIconName === HIPERCARD;
    }

    get isUatp() {
        return this.getIconName === UATP;
    }

}