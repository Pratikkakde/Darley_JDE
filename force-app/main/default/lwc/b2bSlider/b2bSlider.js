import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

// LABELS
import B2B_Slider_Click_View_Previous from '@salesforce/label/c.B2B_Slider_Click_View_Previous';
import B2B_Slider_Click_View_Next from '@salesforce/label/c.B2B_Slider_Click_View_Next';
import B2B_Slider_Click_View_Other from '@salesforce/label/c.B2B_Slider_Click_View_Other';
import B2B_Slider_Item_To_Replace from '@salesforce/label/c.B2B_Slider_Item_To_Replace';

const LABELS = {
    clickViewPrevious: B2B_Slider_Click_View_Previous,
    clickViewNext: B2B_Slider_Click_View_Next,
    clickViewOther: B2B_Slider_Click_View_Other,
    itemToReplace: B2B_Slider_Item_To_Replace,
};

const COMPONENT_NAME = 'b2b-slider';
const XL_WIDTH = 1200;
const LG_WIDTH = 1024;
const MD_WIDTH = 768;
const XL_COLUMN_COUNT = 5;
const LG_COLUMN_COUNT = 3;
const MD_COLUMN_COUNT = 2;

export default class B2bSlider extends LightningElement {
    @api list = [];
    @api showArrows = false;
    @api showSlicks = false;
    @api gridColumnGap = null; // numeric (pixels)
    @api xlGridColumnGap = null; // numeric (pixels)
    @api lgGridColumnGap = null; // numeric (pixels)
    @api mdGridColumnGap = null; // numeric (pixels)
    @api xlColumnCount = null; // integer
    @api lgColumnCount = null; // integer
    @api mdColumnCount = null; // integer
    @api prevTitleSubstr = null;
    @api nextTitleSubstr = null;
    @api slickTitleSubstr = null;

    @track isFirstRender = true;
    @track labels = LABELS;
    @track customCssContainer = UTILS.customCssContainer;
    @track componentId = UTILS.random.componentId(); 
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);
    @track wrapperId = UTILS.wrapperId(COMPONENT_NAME, this.componentId);
    @track innerWidth = null;
    @track itemIndex = null;

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper} ${this.wrapperId}`;
    }

    get items() {
        this.setInitialParams();
        return IS.arrayNotEmpty(this.list) ? this.list : [];
    }

    get visibleCount() {
        let result = 1;
        if (this.innerWidth >= XL_WIDTH) {
            result = IS.integer(+this.xlColumnCount) && this.xlColumnCount > 0
                ? this.xlColumnCount
                : XL_COLUMN_COUNT;

        } else if (LG_WIDTH <= this.innerWidth && this.innerWidth < XL_WIDTH) {
            result = IS.integer(+this.lgColumnCount) && this.lgColumnCount > 0
                ? this.lgColumnCount
                : LG_COLUMN_COUNT;

        } else if (MD_WIDTH <= this.innerWidth && this.innerWidth < LG_WIDTH) {
            result = IS.integer(+this.mdColumnCount) && this.mdColumnCount > 0
                ? this.mdColumnCount
                : MD_COLUMN_COUNT;
        }
        return result;
    }

    get itemWidth() {
        return Math.round(100 / this.visibleCount * 100) / 100;
    }

    get getContainerWidth() {
        if (IS.arrayNotEmpty(this.list)) {
            if (this.list.length * this.itemWidth > 100) {
                return this.list.length * this.itemWidth;
            }
        }
        return 100;
    }

    get getShowArrows() {
        return this.showArrows && this.list.length > this.visibleCount;
    }

    get isPrevDisabled() {
        return this.itemIndex === 0;
    }

    get getPrevTitle() {
        return !this.isPrevDisabled
            ? UTILS.prepareLabel(
                    LABELS.clickViewPrevious,
                    IS.stringNotEmpty(this.prevTitleSubstr)
                        ? [this.prevTitleSubstr]
                        : [LABELS.itemToReplace]
                )
            : null;
    }

    get isNextDisabled() {
        return this.itemIndex === (this.getSlickOptions.length - 1);
    }

    get getNextTitle() {
        return !this.isNextDisabled
            ? UTILS.prepareLabel(
                    LABELS.clickViewNext,
                    IS.stringNotEmpty(this.nextTitleSubstr)
                        ? [this.nextTitleSubstr]
                        : [LABELS.itemToReplace]
                )
            : null;
    }

    get getShowSlicks() {
        return this.showSlicks &&
            IS.arrayNotEmpty(this.getSlickOptions);
    }

    get getSlickOptions() {
        let result = [];
        if (
            IS.arrayNotEmpty(this.list)
            && this.list.length > this.visibleCount
        ) {
            let page = Math.ceil(this.list.length / this.visibleCount);
            for (let i = 0; i < page; i++) {
                let newItem = {
                    index: i,
                    class: this.itemIndex === i
                        ? `${COMPONENT_NAME}__slick ${COMPONENT_NAME}__slick-active`
                        : `${COMPONENT_NAME}__slick`,
                    title: this.itemIndex !== i
                        ? this.getSlickTitle
                        : null
                };
                result.push(newItem);
            }
        }
        return result;
    }

    get getSlickTitle() {
        return UTILS.prepareLabel(
            LABELS.clickViewOther,
            IS.stringNotEmpty(this.slickTitleSubstr)
                ? [this.slickTitleSubstr]
                : [LABELS.itemToReplace]
        );
    }

    // LIFECYCLES
    renderedCallback() {
        if (this.isFirstRender) {
            this.isFirstRender = false;
            this.innerWidth = window.innerWidth;
            this.addCustomCssStyles();

            this._resizeEventListenerFunction = this.resizeEventListenerFunction.bind(this);
            window.addEventListener('resize', this._resizeEventListenerFunction);
        }
    }

    disconnectedCallback() {
        window.removeEventListener('resize', this._resizeEventListenerFunction, false);
    }

    // METHODS
    resizeEventListenerFunction() {
        this.setInitialParams();
    }

    setInitialParams() {
        setTimeout(() => {
            if (this.itemIndex == null || this.innerWidth != window.innerWidth) {
                this.itemIndex = 0;
            }

            this.innerWidth = window.innerWidth;
            this.addCustomCssStyles();
            this.updateListPosition();
        });
    }

    addCustomCssStyles() {
        let gridColumnGap = IS.numeric(+this.gridColumnGap)
            && +this.gridColumnGap >= 0
                ? +this.gridColumnGap
                : null;

        let xlGridColumnGap = this.innerWidth >= XL_WIDTH
            && IS.numeric(+this.xlGridColumnGap)
                ? `
                    @media (min-width: ${XL_WIDTH}px) {
                        .${this.wrapper}.${this.wrapperId} {
                            --b2b-slider-gridColumnGap: ${this.xlGridColumnGap}px;
                            --b2b-slider-listMargin: -${this.xlGridColumnGap}px;
                        }
                    }
                `
                : '';

        let lgGridColumnGap = LG_WIDTH <= this.innerWidth
            && this.innerWidth < XL_WIDTH
            && IS.numeric(+this.lgGridColumnGap)
                ? `
                    @media (min-width: ${LG_WIDTH}px) and (max-width: ${XL_WIDTH - 0.02}px) {
                        .${this.wrapper}.${this.wrapperId} {
                            --b2b-slider-gridColumnGap: ${this.lgGridColumnGap}px;
                            --b2b-slider-listMargin: -${this.lgGridColumnGap}px;
                        }
                    }
                `
                : '';

        let mdGridColumnGap = MD_WIDTH <= this.innerWidth
            && this.innerWidth < LG_WIDTH
            && IS.numeric(+this.mdGridColumnGap)
                ? `
                    @media (min-width: ${MD_WIDTH}px) and (max-width: ${LG_WIDTH - 0.02}px) {
                        .${this.wrapper}.${this.wrapperId} {
                            --b2b-slider-gridColumnGap: ${this.mdGridColumnGap}px;
                            --b2b-slider-listMargin: -${this.mdGridColumnGap}px;
                        }
                    }
                `
                : '';

        let styleText = `
            /* VARIABLES */
            .${this.wrapper}.${this.wrapperId} {
                --b2b-slider-gridColumnGap: ${
                    IS.numeric(gridColumnGap) ? gridColumnGap : 0
                }px;

                --b2b-slider-listMargin: -${
                    IS.numeric(gridColumnGap) ? gridColumnGap : 0
                }px;

                --b2b-slider-containerWidth: ${
                    IS.numeric(this.getContainerWidth) ? this.getContainerWidth : 100
                }%;

                --b2b-slider-itemWidth: ${
                    IS.numeric(this.itemWidth) ? this.itemWidth : 100
                }%;
            }

            ${xlGridColumnGap}
            ${lgGridColumnGap}
            ${mdGridColumnGap}

            /* ITEM */
            .${this.wrapper}.${this.wrapperId} .b2b-slider__item {
                width: var(--b2b-slider-itemWidth);
                padding: 0 calc(var(--b2b-slider-gridColumnGap) / 2) 0 calc(var(--b2b-slider-gridColumnGap) / 2);
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

    updateListPosition() {
        let container = this.template.querySelector(`.${COMPONENT_NAME}__container`);
        if (!container) return;

        let left = 0;
        if (this.itemIndex == (this.getSlickOptions.length - 1)) {
            left = (this.list.length - this.visibleCount) * this.itemWidth;
        } else {
            left = this.itemIndex * this.visibleCount * this.itemWidth;
        }

        container.setAttribute('style', `left: -${left}%`);
    }

    // HANDLERS
    handleClickSlick(event) {
        let index = +event.target.dataset.index;
        if (IS.integer(index) && index >= 0 && this.itemIndex !== index) {
            this.itemIndex = index;
            this.updateListPosition();
        }
    }

    handleClickPrev() {
        if (this.itemIndex > 0) {
            this.itemIndex -= 1;
            this.updateListPosition();
        }
    }

    handleClickNext() {
        if (this.itemIndex < (this.getSlickOptions.length - 1)) {
            this.itemIndex += 1;
            this.updateListPosition();
        }
    }

}