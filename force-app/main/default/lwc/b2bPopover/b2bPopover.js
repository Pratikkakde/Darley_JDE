import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

const LABELS = {
    buttonCloseTitle: 'Close',
};

const COMPONENT_NAME = 'b2b-popover';
const POPOVER_WIDTH_DEFAULT = 300;
const POPOVER_HEIGHT_DEFAULT = 200;
const NUBBIN_WIDTH = 23;
const LEFT = 'left';
const CENTER = 'center';
const RIGHT = 'right';
const TOP = 'top';
const BOTTOM = 'bottom';

export default class B2bPopover extends LightningElement {
    @api label = null;
    @api title = null;

    @track labels = LABELS;
    @track isFirstRender = true;
    @track customCssContainer = UTILS.customCssContainer;
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);
    @track componentId = UTILS.random.componentId();
    @track wrapperId = UTILS.wrapperId(COMPONENT_NAME, this.componentId);

    @track inFocus = false;
    @track open = false;

    @track client = {
        width: null,
        height: null
    };

    @track buttonTrigger = {
        width: null,
        height: null,
        top: null,
        right: null,
        bottom : null,
        left: null
    };

    @track popover = {
        width: null,
        height: null,
        top: null,
        right: null,
        bottom : null,
        left: null
    };

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper} ${this.wrapperId}`;
    }

    get showPopover() {
        return this.open;
    }

    get horizontalAlign() {
        let result = CENTER;

        let fitsLeft = false;
        if (this.buttonTrigger.left + this.buttonTrigger.width / 2 >= this.popover.width / 2) {
            fitsLeft = true;
        }

        let fitsRight = false;
        if (this.client.width - this.buttonTrigger.right + this.buttonTrigger.width / 2 >= this.popover.width / 2) {
            fitsRight = true;
        }

        if (!fitsLeft && fitsRight) {
            result = RIGHT;
        } else if (fitsLeft && !fitsRight) {
            result = LEFT;
        }

        if (
            result === RIGHT &&
            this.client.width < 337 &&
            ((this.client.width / 2) - (this.buttonTrigger.width * 2 / 3) <= this.buttonTrigger.left)
        ) {
            result = CENTER;
        }

        return result;
    }

    get verticalAlign() {
        let result = BOTTOM;

        let fitsTop = false;
        if (this.buttonTrigger.top >= this.popover.height + NUBBIN_WIDTH / 2) {
            fitsTop = true;
        }

        let fitsBottom = false;
        if (this.client.height - this.buttonTrigger.bottom >= this.popover.height + NUBBIN_WIDTH / 2) {
            fitsBottom = true;
        }

        if (fitsTop && !fitsBottom) {
            result = TOP;
        }

        return result;
    }

    get popoverClass() {
        let verticalAlign = this.verticalAlign === BOTTOM ? 'top' : 'bottom';
        let horizontalAlign = '';
        if (this.horizontalAlign === RIGHT) {
            horizontalAlign = '-left';
        } else if (this.horizontalAlign === LEFT) {
            horizontalAlign = '-right';
        }
        return `slds-popover slds-nubbin_${verticalAlign}${horizontalAlign}`;
    }

    get shiftWidth() {
        let leftFitWidth = this.buttonTrigger.right;
        let rigthFitWidth = this.client.width - this.buttonTrigger.left;

        if (this.horizontalAlign === RIGHT && rigthFitWidth - 16 < POPOVER_WIDTH_DEFAULT) {
            return POPOVER_WIDTH_DEFAULT - rigthFitWidth + 18;
            
        } else if (this.horizontalAlign === LEFT && leftFitWidth - 16 < POPOVER_WIDTH_DEFAULT) {
            return POPOVER_WIDTH_DEFAULT - leftFitWidth + 18;
        }

        return 0;
    }

    get showHeader() {
        return IS.stringNotEmpty(this.title);
    }

    // LIFECYCLES
    renderedCallback() {
        if (this.isFirstRender) {
            this.isFirstRender = false;

            this._resizeEventListenerFunction = this.resizeEventListenerFunction.bind(this);
            window.addEventListener('resize', this._resizeEventListenerFunction);

            this._scrollEventListenerFunction = this.scrollEventListenerFunction.bind(this);
            window.addEventListener('scroll', this._scrollEventListenerFunction);

            this._clickEventListenerFunction = this.clickEventListenerFunction.bind(this);
            window.addEventListener('click', this._clickEventListenerFunction);

            this.calculatePosition();
            this.addCustomCssStyles();
        }
    }

    disconnectedCallback() {
        window.removeEventListener('resize', this._resizeEventListenerFunction, false);
        window.removeEventListener('scroll', this._scrollEventListenerFunction, false);
        window.removeEventListener('click', this._clickEventListenerFunction, false);
    }

    // METHODS
    resizeEventListenerFunction() {
        this.calculatePosition();
        this.addCustomCssStyles();
    }

    scrollEventListenerFunction() {
        this.calculatePosition();
        this.addCustomCssStyles();
    }

    clickEventListenerFunction() {
        if (!this.inFocus && this.open) {
            this.handleClickButtonClose();
        }
        this.inFocus = false;

        this.calculatePosition();
        this.addCustomCssStyles();
    }

    addCustomCssStyles() {
        let top = `calc(100% + ${NUBBIN_WIDTH / 2}px)`;

        if (this.verticalAlign === TOP) {
            top = `calc(-${this.popover.height}px - ${NUBBIN_WIDTH / 2}px)`;
        }

        let left = 'unset';
        let right = 'unset';
        let transform = 'unset';

        if (this.horizontalAlign === RIGHT) {
            left = this.shiftWidth ? `-${this.shiftWidth}px` : '0';

        } else if (this.horizontalAlign === CENTER) {
            left = '50%';
            transform = 'translateX(-50%)';

        } else if (this.horizontalAlign === LEFT) {
            right = this.shiftWidth ? `-${this.shiftWidth}px` : '0';
        }

        let styleText = `
            .${this.wrapper}.${this.wrapperId} {
                --b2b-popover-width: ${POPOVER_WIDTH_DEFAULT}px;
                --b2b-popover-positionTop: ${top};
                --b2b-popover-positionLeft: ${left};
                --b2b-popover-positionRight: ${right};
                --b2b-popover-positionTransform: ${transform};
                --b2b-popover-shift: ${this.shiftWidth ? `${this.shiftWidth}px` : '0'};
                --b2b-popover-shiftNubbin: ${this.buttonTrigger.width / 2 + this.shiftWidth}px;
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

    calculatePosition() {
        // CLIENT
        this.client.width = window.innerWidth;
        this.client.height = window.innerHeight;

        // BUTTON TRIGGER
        let buttonTrigger = this.template.querySelector('[aria-haspopup]');
        if (buttonTrigger) {
            let coords = buttonTrigger.getBoundingClientRect();
            this.buttonTrigger.width = coords.width;
            this.buttonTrigger.height = coords.height;
            this.buttonTrigger.top = coords.top;
            this.buttonTrigger.right = coords.right;
            this.buttonTrigger.bottom = coords.bottom;
            this.buttonTrigger.left = coords.left;
        }

        // POPOVER
        this.popover.width = POPOVER_WIDTH_DEFAULT;
        this.popover.height = POPOVER_HEIGHT_DEFAULT;
        let popover = this.template.querySelector('[role="dialog"]');
        if (popover) {
            let coords = popover.getBoundingClientRect();
            this.popover.width = coords.width;
            this.popover.height = coords.height;
        }
    }

    // HANDLERS
    async handleClickButtonTrigger() {
        await setTimeout(() => {
            if (!this.open) {
                this.open = true;
            } else {
                this.handleClickButtonClose();
            }
        }, 0);

        await setTimeout(() => {
            if (this.open) {
                this.calculatePosition();
                this.addCustomCssStyles();
            }
        }, 0);
    }

    handleClickButtonClose() {
        this.open = false;
    }

    handleClickWrapper() {
        this.inFocus = true;
    }

}