import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

const LABELS = {
    closeButtonTitle: 'Close',
};

const DEFAULT_ICON_NAME = 'warning';
const CLOSE_EVENT = 'close';
const BASE = 'base';
const SUCCESS = 'success';
const WARNING = 'warning';
const ERROR = 'error';
const OFFLINE = 'offline';
const INFO = 'info';

const VARIANT_OPTIONS = [BASE, SUCCESS, WARNING, ERROR, OFFLINE, INFO];

export default class B2bAlert extends LightningElement {
    @api show = false;
    @api variant = null;
    @api icon = null;
    @api message = null;
    @api richtext = null;
    @api showCloseButton = false;

    @track open = true;
    @track labels = LABELS;

    // GETTERS
    get showComponent() {
        return this.show && this.open;
    }

    get getVariant() {
        if (
            IS.stringNotEmpty(this.variant)
            && IS.arrayIncludes(VARIANT_OPTIONS, this.variant.toLowerCase())
        ) {
            return this.variant.toLowerCase();
        }
        return VARIANT_OPTIONS[0];
    }

    get getWrapperClass() {
        return `b2b-alert__wrapper slds-notify slds-notify_alert slds-alert_${this.getVariant}`;
    }

    get showIcon() {
        return IS.utilityIcon(this.icon);
    }

    get getIconName() {
        if (this.showIcon) {
            return `utility:${this.icon}`;
        }
        return `utility:${DEFAULT_ICON_NAME}`;
    }

    get showRichtext() {
        return IS.stringNotEmpty(this.richtext);
    }

    // HANDLERS
    handleClickButtonClose(event) {
        this.open = false;
        UTILS.dispatchEvent(this, CLOSE_EVENT, JSON.parse(JSON.stringify(event.target.dataset)));
    }

}