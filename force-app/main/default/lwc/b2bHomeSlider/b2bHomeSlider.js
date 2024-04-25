// TODO: Add touch swipe to slider (example in Forte DGTL repository)

import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

// LABELS
import B2B_Home_Slider_Button_Preview_Title from '@salesforce/label/c.B2B_Home_Slider_Button_Preview_Title';
import B2B_Home_Slider_Button_Next_Title from '@salesforce/label/c.B2B_Home_Slider_Button_Next_Title';
// SLIDE 1
import B2B_Home_Slider_Title_1 from '@salesforce/label/c.B2B_Home_Slider_Title_1';
import B2B_Home_Slider_Subtitle_1 from '@salesforce/label/c.B2B_Home_Slider_Subtitle_1';
import B2B_Home_Slider_Button_Label_1 from '@salesforce/label/c.B2B_Home_Slider_Button_Label_1';
// SLIDE 2
import B2B_Home_Slider_Title_2 from '@salesforce/label/c.B2B_Home_Slider_Title_2';
import B2B_Home_Slider_Subtitle_2 from '@salesforce/label/c.B2B_Home_Slider_Subtitle_2';
import B2B_Home_Slider_Button_Label_2 from '@salesforce/label/c.B2B_Home_Slider_Button_Label_2';
// SLIDE 3
import B2B_Home_Slider_Title_3 from '@salesforce/label/c.B2B_Home_Slider_Title_3';
import B2B_Home_Slider_Subtitle_3 from '@salesforce/label/c.B2B_Home_Slider_Subtitle_3';
import B2B_Home_Slider_Button_Label_3 from '@salesforce/label/c.B2B_Home_Slider_Button_Label_3';
// SLIDE 4
import B2B_Home_Slider_Title_4 from '@salesforce/label/c.B2B_Home_Slider_Title_4';
import B2B_Home_Slider_Subtitle_4 from '@salesforce/label/c.B2B_Home_Slider_Subtitle_4';
import B2B_Home_Slider_Button_Label_4 from '@salesforce/label/c.B2B_Home_Slider_Button_Label_4';
// SLIDE 5
import B2B_Home_Slider_Title_5 from '@salesforce/label/c.B2B_Home_Slider_Title_5';
import B2B_Home_Slider_Subtitle_5 from '@salesforce/label/c.B2B_Home_Slider_Subtitle_5';
import B2B_Home_Slider_Button_Label_5 from '@salesforce/label/c.B2B_Home_Slider_Button_Label_5';

const LABELS = {
    buttonPrevTitle: B2B_Home_Slider_Button_Preview_Title,
    buttonNextTitle: B2B_Home_Slider_Button_Next_Title,

    // SLIDE 1
    slide1Title: B2B_Home_Slider_Title_1,
    slide1Subtitle: B2B_Home_Slider_Subtitle_1,
    slide1ButtonLabel: B2B_Home_Slider_Button_Label_1,

    // SLIDE 2
    slide2Title: B2B_Home_Slider_Title_2,
    slide2Subtitle: B2B_Home_Slider_Subtitle_2,
    slide2ButtonLabel: B2B_Home_Slider_Button_Label_2,

    // SLIDE 3
    slide3Title: B2B_Home_Slider_Title_3,
    slide3Subtitle: B2B_Home_Slider_Subtitle_3,
    slide3ButtonLabel: B2B_Home_Slider_Button_Label_3,

    // SLIDE 4
    slide4Title: B2B_Home_Slider_Title_4,
    slide4Subtitle: B2B_Home_Slider_Subtitle_4,
    slide4ButtonLabel: B2B_Home_Slider_Button_Label_4,

    // SLIDE 5
    slide5Title: B2B_Home_Slider_Title_5,
    slide5Subtitle: B2B_Home_Slider_Subtitle_5,
    slide5ButtonLabel: B2B_Home_Slider_Button_Label_5,
};

const COMPONENT_NAME = 'b2b-home-slider';
const CSS_PREFIX = 'homeSlider';
const MAX_SLIDES = 5;
const SLIDE_DISPLAY_DURATION = 15000;

export default class B2bHomeSlider extends LightningElement {
    // SLIDER SETTINGS
    @api sliderHeight = null;

    // SLIDE ARROW
    @api showArrowButtons = false;
    @api arrowColor = null;
    @api arrowColorHover = null;

    // SLIDE SLICKS
    @api showSliksButtons = false;
    @api slickColor = null;
    @api slickColorHover = null;
    @api slickColorActive = null;

    // SLIDE 1
    @api slide1ShowSlide = false;
    @api slide1ShowBackgroundImage = false;
    @api slide1BackgroundImage = null;
    @api slide1BackgroundColor = null;
    // SLIDE 1: CONTAINER
    @api slide1ContainerMaxWidth = null;
    @api slide1ContainerColor = null;
    @api slide1ContainerHorizontalPosition = null;
    @api slide1ContainerVerticalPosition = null;
    // SLIDE 1: TITLE
    @api slide1ShowTitle = false;
    @api slide1Title = null;
    @api slide1TitleColor = null;
    @api slide1TitleAlign = null;
    // SLIDE 1: SUBTITLE
    @api slide1ShowSubtitle = false;
    @api slide1Subtitle = null;
    @api slide1SubtitleColor = null;
    @api slide1SubtitleAlign = null;
    // SLIDE 1: BUTTON
    @api slide1ShowButton = false;
    @api slide1ButtonLabel = null;
    @api slide1ButtonNavigateTo = null;
    @api slide1ButtonAlign = null;
    @api slide1ButtonTextColor = null;
    @api slide1ButtonBackgroundColor = null;
    @api slide1ButtonTextColorHover = null;
    @api slide1ButtonBackgroundColorHover = null;

    // SLIDE 2
    @api slide2ShowSlide = false;
    @api slide2ShowBackgroundImage = false;
    @api slide2BackgroundImage = null;
    @api slide2BackgroundColor = null;
    // SLIDE 2: CONTAINER
    @api slide2ContainerMaxWidth = null;
    @api slide2ContainerColor = null;
    @api slide2ContainerHorizontalPosition = null;
    @api slide2ContainerVerticalPosition = null;
    // SLIDE 2: TITLE
    @api slide2ShowTitle = false;
    @api slide2Title = null;
    @api slide2TitleColor = null;
    @api slide2TitleAlign = null;
    // SLIDE 2: SUBTITLE
    @api slide2ShowSubtitle = false;
    @api slide2Subtitle = null;
    @api slide2SubtitleColor = null;
    @api slide2SubtitleAlign = null;
    // SLIDE 2: BUTTON
    @api slide2ShowButton = false;
    @api slide2ButtonLabel = null;
    @api slide2ButtonNavigateTo = null;
    @api slide2ButtonAlign = null;
    @api slide2ButtonTextColor = null;
    @api slide2ButtonBackgroundColor = null;
    @api slide2ButtonTextColorHover = null;
    @api slide2ButtonBackgroundColorHover = null;

    // SLIDE 3
    @api slide3ShowSlide = false;
    @api slide3ShowBackgroundImage = false;
    @api slide3BackgroundImage = null;
    @api slide3BackgroundColor = null;
    // SLIDE 3: CONTAINER
    @api slide3ContainerMaxWidth = null;
    @api slide3ContainerColor = null;
    @api slide3ContainerHorizontalPosition = null;
    @api slide3ContainerVerticalPosition = null;
    // SLIDE 3: TITLE
    @api slide3ShowTitle = false;
    @api slide3Title = null;
    @api slide3TitleColor = null;
    @api slide3TitleAlign = null;
    // SLIDE 3: SUBTITLE
    @api slide3ShowSubtitle = false;
    @api slide3Subtitle = null;
    @api slide3SubtitleColor = null;
    @api slide3SubtitleAlign = null;
    // SLIDE 3: BUTTON
    @api slide3ShowButton = false;
    @api slide3ButtonLabel = null;
    @api slide3ButtonNavigateTo = null;
    @api slide3ButtonAlign = null;
    @api slide3ButtonTextColor = null;
    @api slide3ButtonBackgroundColor = null;
    @api slide3ButtonTextColorHover = null;
    @api slide3ButtonBackgroundColorHover = null;

    // SLIDE 4
    @api slide4ShowSlide = false;
    @api slide4ShowBackgroundImage = false;
    @api slide4BackgroundImage = null;
    @api slide4BackgroundColor = null;
    // SLIDE 4: CONTAINER
    @api slide4ContainerMaxWidth = null;
    @api slide4ContainerColor = null;
    @api slide4ContainerHorizontalPosition = null;
    @api slide4ContainerVerticalPosition = null;
    // SLIDE 4: TITLE
    @api slide4ShowTitle = false;
    @api slide4Title = null;
    @api slide4TitleColor = null;
    @api slide4TitleAlign = null;
    // SLIDE 4: SUBTITLE
    @api slide4ShowSubtitle = false;
    @api slide4Subtitle = null;
    @api slide4SubtitleColor = null;
    @api slide4SubtitleAlign = null;
    // SLIDE 4: BUTTON
    @api slide4ShowButton = false;
    @api slide4ButtonLabel = null;
    @api slide4ButtonNavigateTo = null;
    @api slide4ButtonAlign = null;
    @api slide4ButtonTextColor = null;
    @api slide4ButtonBackgroundColor = null;
    @api slide4ButtonTextColorHover = null;
    @api slide4ButtonBackgroundColorHover = null;

    // SLIDE 5
    @api slide5ShowSlide = false;
    @api slide5ShowBackgroundImage = false;
    @api slide5BackgroundImage = null;
    @api slide5BackgroundColor = null;
    // SLIDE 5: CONTAINER
    @api slide5ContainerMaxWidth = null;
    @api slide5ContainerColor = null;
    @api slide5ContainerHorizontalPosition = null;
    @api slide5ContainerVerticalPosition = null;
    // SLIDE 5: TITLE
    @api slide5ShowTitle = false;
    @api slide5Title = null;
    @api slide5TitleColor = null;
    @api slide5TitleAlign = null;
    // SLIDE 5: SUBTITLE
    @api slide5ShowSubtitle = false;
    @api slide5Subtitle = null;
    @api slide5SubtitleColor = null;
    @api slide5SubtitleAlign = null;
    // SLIDE 5: BUTTON
    @api slide5ShowButton = false;
    @api slide5ButtonLabel = null;
    @api slide5ButtonNavigateTo = null;
    @api slide5ButtonAlign = null;
    @api slide5ButtonTextColor = null;
    @api slide5ButtonBackgroundColor = null;
    @api slide5ButtonTextColorHover = null;
    @api slide5ButtonBackgroundColorHover = null;

    @track isFirstRender = true;
    @track labels = LABELS;
    @track customCssContainer = UTILS.customCssContainer;
    @track componentId = UTILS.random.componentId();
    @track wrapper = UTILS.wrapper(COMPONENT_NAME);
    @track wrapperId = UTILS.wrapperId(COMPONENT_NAME, this.componentId);

    @track list = [];
    @track currentSlide = null;
    @track sliderTimer = null;

    // GETTERS
    get wrapperClass() {
        return `${this.wrapper} ${this.wrapperId}`;
    }

    get showComponent() {
        return IS.arrayNotEmpty(this.list);
    }

    get showNavigateButtons() {
        return this.showComponent
            && IS.true(this.showArrowButtons)
            && this.list.length > 1;
    }

    get showSliсkButtons() {
        return this.showComponent
            && IS.true(this.showSliksButtons)
            && this.slickOptions.length > 1;
    }

    get slickOptions() {
        return this.list.map((item, index) => {
            let newItem = {
                index: index,
                title: item.title,
                class: `${COMPONENT_NAME}__slick`
            };

            if (!IS.stringIncludes(item.class, 'hidden')) {
                newItem.class += ` ${COMPONENT_NAME}__slick-active`;
            }
            return newItem;
        });
    }

    // LIFECYCLES
    connectedCallback() {
        this.getInitialData();
    }

    renderedCallback() {
        if (this.isFirstRender) {
            this.isFirstRender = false;
            this.addCustomCssStyles();
        }
    }

    // METHODS
    getInitialData() {
        let result = [];
        for (let i = 1; i <= MAX_SLIDES; i++) {
            if (IS.true(this[`slide${i}ShowSlide`])) {
                let newItem = {
                    show: IS.true(this[`slide${i}ShowSlide`]) ? true : false,
                    title: this[`slide${i}ShowTitle`]
                        ? IS.stringNotEmpty(this[`slide${i}Title`])
                            ? this[`slide${i}Title`]
                            : LABELS[`slide${i}Title`]
                        : null,

                    subtitle: this[`slide${i}ShowSubtitle`]
                        ? IS.stringNotEmpty(this[`slide${i}Subtitle`])
                            ? this[`slide${i}Subtitle`]
                            : LABELS[`slide${i}Subtitle`]
                        : null,

                    link: this[`slide${i}ShowButton`]
                        && IS.stringNotEmpty(this[`slide${i}ButtonNavigateTo`])
                            ? UTILS.link(this[`slide${i}ButtonNavigateTo`])
                            : null,

                    label: IS.stringNotEmpty(this[`slide${i}ButtonLabel`])
                        ? this[`slide${i}ButtonLabel`]
                        : IS.stringNotEmpty(LABELS[`slide${i}ButtonLabel`])
                            ? LABELS[`slide${i}ButtonLabel`]
                            : null,

                    showButton: false,
                    class: `${COMPONENT_NAME}__item ${COMPONENT_NAME}__item-hidden`
                };

                if (
                    IS.stringNotEmpty(newItem.link)
                    && IS.stringNotEmpty(newItem.label)
                ) {
                    newItem.showButton = true;
                }

                result.push(newItem);
            }
        }
        this.list = result;

        this.setSliderByIndex(0);
        this.setSliderTimer();
    }

    addCustomCssStyles() {
        let styleText = `
            .${this.wrapperId} {
                ${UTILS.generateCssVar(CSS_PREFIX, 'minHeight', this.sliderHeight)}

                /* ARROW */
                ${UTILS.generateCssVar(CSS_PREFIX, 'arrowColor', this.arrowColor)}
                ${UTILS.generateCssVar(CSS_PREFIX, 'arrowColorHover', this.arrowColorHover)}

                /* SLICK */
                ${UTILS.generateCssVar(CSS_PREFIX, 'slickColor', this.slickColor)}
                ${UTILS.generateCssVar(CSS_PREFIX, 'slickColorHover', this.slickColorHover)}
                ${UTILS.generateCssVar(CSS_PREFIX, 'slickColorActive', this.slickColorActive)}
            }
        `;

        let visibleSlide = 1;
        for (let i = 1; i <= MAX_SLIDES; i++) {
            if (IS.true(this[`slide${i}ShowSlide`])) {
                styleText += `
                    .${this.wrapperId} .${COMPONENT_NAME}__item-${visibleSlide} {
                        ${UTILS.generateCssVar(
                            CSS_PREFIX,
                            'containerHorizontalPosition',
                            UTILS.justifyContent(this[`slide${i}ContainerHorizontalPosition`])
                        )}
                        ${UTILS.generateCssVar(
                            CSS_PREFIX,
                            'containerVerticalPosition',
                            UTILS.alignItems(this[`slide${i}ContainerVerticalPosition`])
                        )}
                        ${UTILS.generateCssVar(CSS_PREFIX, 'backgroundColor', this[`slide${i}BackgroundColor`])}
                        ${UTILS.generateCssVar(
                            CSS_PREFIX,
                            'backgroundImage',
                            this[`slide${i}ShowBackgroundImage`] && IS.stringNotEmpty(this[`slide${i}BackgroundImage`])
                                ? `url('${UTILS.cmsLink(this[`slide${i}BackgroundImage`])}')`
                                : null
                        )}
                        ${UTILS.generateCssVar(CSS_PREFIX, 'containerMaxWidth', this[`slide${i}ContainerMaxWidth`])}
                        ${UTILS.generateCssVar(CSS_PREFIX, 'containerColor', this[`slide${i}ContainerColor`])}
                        ${UTILS.generateCssVar(CSS_PREFIX, 'titleAlign', UTILS.textAlign(this[`slide${i}TitleAlign`]))}
                        ${UTILS.generateCssVar(CSS_PREFIX, 'titleColor', this[`slide${i}TitleColor`])}
                        ${UTILS.generateCssVar(CSS_PREFIX, 'subtitleAlign', UTILS.textAlign(this[`slide${i}SubtitleAlign`]))}
                        ${UTILS.generateCssVar(CSS_PREFIX, 'subtitleColor', this[`slide${i}SubtitleColor`])}
                    }

                    ${this[`slide${i}ShowBackgroundImage`] && IS.stringNotEmpty(this[`slide${i}BackgroundImage`])
                        ? `.${this.wrapperId} .${COMPONENT_NAME}__item-${visibleSlide}::before {
                            background-image: url('${UTILS.cmsLink(this[`slide${i}BackgroundImage`])}');
                        }`
                        : ''
                    }

                    .${this.wrapperId} .${COMPONENT_NAME}__item-${visibleSlide} .b2b-home-slider__button-wrapper {
                        ${IS.stringNotEmpty(UTILS.textAlign(this[`slide${i}ButtonAlign`]))
                            ? `text-align: ${UTILS.textAlign(this[`slide${i}ButtonAlign`])};`
                            : ''
                        }
                    }

                    .${this.wrapperId} .${COMPONENT_NAME}__item-${visibleSlide} .b2b-home-slider__button {
                        ${IS.stringNotEmpty(this[`slide${i}ButtonTextColor`])
                            ? `color: ${this[`slide${i}ButtonTextColor`]};`
                            : ''
                        }
                        ${IS.stringNotEmpty(this[`slide${i}ButtonBackgroundColor`])
                            ? `border-color: ${this[`slide${i}ButtonBackgroundColor`]};`
                            : ''
                        }
                        ${IS.stringNotEmpty(this[`slide${i}ButtonBackgroundColor`])
                            ? `background-color: ${this[`slide${i}ButtonBackgroundColor`]};`
                            : ''
                        }
                    }

                    .${this.wrapperId} .${COMPONENT_NAME}__item-${visibleSlide} .b2b-home-slider__button:hover {
                        ${IS.stringNotEmpty(this[`slide${i}ButtonTextColorHover`])
                            ? `color: ${this[`slide${i}ButtonTextColorHover`]};`
                            : ''
                        }
                        ${IS.stringNotEmpty(this[`slide${i}ButtonBackgroundColorHover`])
                            ? `border-color: ${this[`slide${i}ButtonBackgroundColorHover`]};`
                            : ''
                        }
                        ${IS.stringNotEmpty(this[`slide${i}ButtonBackgroundColorHover`])
                            ? `background-color: ${this[`slide${i}ButtonBackgroundColorHover`]};`
                            : ''
                        }
                    }
                `;
                visibleSlide++;
            }
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

    setSliderTimer() {
        if (this.sliderTimer) {
            clearInterval(this.sliderTimer);
        }

        this.sliderTimer = setInterval(() => {
            if ((this.currentSlide + 1) === (this.list.length)) {
                this.setSliderByIndex(0);
            } else {
                this.setSliderByIndex(this.currentSlide + 1);
            }
        }, SLIDE_DISPLAY_DURATION);
    }

    setSliderByIndex(sliderIndex) {
        this.currentSlide = sliderIndex;
        this.list.forEach((item, index) => {
            if (sliderIndex === index) {
                item.class = `${COMPONENT_NAME}__item ${COMPONENT_NAME}__item-${index + 1}`;
            } else {
                item.class = `${COMPONENT_NAME}__item ${COMPONENT_NAME}__item-${index + 1} ${COMPONENT_NAME}__item-hidden`;
            }
        });
    }

    // HANDLERS
    handleClickSlickButton(event) {
        if (
            IS.stringNotEmpty(event.target.dataset.index)
            && IS.integer(+event.target.dataset.index)
        ) {
            this.setSliderByIndex(+event.target.dataset.index);
            this.setSliderTimer();
        }
    }

    handleClickButtonPrev() {
        if (this.currentSlide === 0) {
            this.setSliderByIndex(this.list.length - 1);
        } else {
            this.setSliderByIndex(this.currentSlide - 1);
        }
        this.setSliderTimer();
    }

    handleClickButtonNext() {
        if (this.currentSlide === (this.list.length - 1)) {
            this.setSliderByIndex(0);
        } else {
            this.setSliderByIndex(this.currentSlide + 1);
        }
        this.setSliderTimer();
    }

}