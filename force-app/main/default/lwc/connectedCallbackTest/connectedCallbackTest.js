import { LightningElement } from 'lwc';

export default class ConnectedCallbackTest extends LightningElement {
    constructor() {
        super();
        console.log('***constructor method on LWC executed');
    }

    connectedCallback(){
        console.log('***connectedCallBack method on LWC executed');
    }

    disconnectedCallback() {
        console.log('***disconnectedCallback method on LWC executed');
    }

    errorCallback(error, stack) {
        console.log('***errorCallback method on LWC executed');
        this.error = error;
    }
}