import { IS } from './is';

function Toast() {
    this.showToastEvent = 'showtoastevent';
    this.variantOptions = ['info', 'success', 'warning', 'error'];
    this.modeOptions = ['dismissible', 'pester', 'sticky'];

    this.showToast = (variant, title, options) => {
        let detail = {
            variant: this.variantOptions[0],
            title: null,
            message: null,
            mode: this.modeOptions[0],
            duration: 3 * 1000,
            richtext: null
        };

        // VARIANT
        if (IS.stringNotEmpty(variant)) {
            variant = variant.trim().toLowerCase();
            if (
                IS.stringNotEmpty(variant)
                && IS.arrayIncludes(this.variantOptions, variant)
            ) {
                detail.variant = variant;
            }
        }

        // TITLE
        if (
            IS.stringNotEmpty(title)
            && IS.stringNotEmpty(title.trim())
        ) {
            detail.title = title.trim();
        }

        if (IS.objectNotEmpty(options)) {

            // MESSAGE
            if (
                IS.stringNotEmpty(options.message)
                && IS.stringNotEmpty(options.message.trim())
            ) {
                detail.message = options.message.trim();
            }

            // MODE
            if (IS.stringNotEmpty(options.mode)) {
                let mode = options.mode.trim().toLowerCase();
                if (
                    IS.stringNotEmpty(mode)
                    && IS.arrayIncludes(this.modeOptions, mode)
                ) {
                    detail.mode = mode;
                }
            }

            // DURATION
            if (
                IS.integer(options.duration)
                && options.duration > 0
            ) {
                detail.duration = options.duration * 1000;
            }

            // RICHTEXT
            if (
                IS.stringNotEmpty(options.richtext)
                && IS.stringNotEmpty(options.richtext.trim())
            ) {
                detail.richtext = options.richtext.trim();
            }

        }

        window.dispatchEvent(
            new CustomEvent(this.showToastEvent, { detail })
        );

        return true;
    }
}

const TOAST = new Toast();
export { TOAST };