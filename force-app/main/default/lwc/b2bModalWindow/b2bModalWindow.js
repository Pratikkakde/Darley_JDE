import { LightningElement, api } from "lwc";

export default class B2BModalWindow extends LightningElement {
    @api showModal = false;
    @api modalHeading = "Modal Header";
    @api isHeaderVisible = false;
    @api isFooterVisible = false;
    @api modalWidth = "width: 50%;";
    @api isCloseVisible = false;
    closeLabel = "Close";

    constructor() {
        super();

        window.addEventListener("keyup", this.closeModalByEscKey.bind(this));
        this.template.addEventListener("closemodalwindow", this.closeModal.bind(this));
        this.template.addEventListener("openmodalwindow", this.openModal.bind(this));
    }

    disconnectedCallback() {
        window.removeEventListener("keyup", this.closeModalByEscKey.bind(this), false);
    }

    @api
    openModal() {
        this.showModal = true;
    }

    @api
    closeModal() {
        this.showModal = false;
        this.dispatchEvent(new CustomEvent('modalwindowclosed'));
    }

    closeModalByEscKey(event) {
        if (!this.isCloseVisible) {
            return;
        }

        if (event.keyCode === 27) {
            this.closeModal();
            window.removeEventListener("keyup", this.closeModalByEscKey.bind(this), false);
        }
    }

}