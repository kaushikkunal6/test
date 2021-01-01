import { LightningElement, api } from 'lwc';

export default class AITM_ToolTip extends LightningElement {
    @api
    get toolTipContent() {
        return this.getAttribute('toolTipContent');
    }

    set toolTipContent(value) {
        this.setAttribute('toolTipContent', value);
    }

    @api
    get toolTipContentSecond() {
        return this.getAttribute('toolTipContentSecond');
    }

    set toolTipContentSecond(value) {
        this.setAttribute('toolTipContentSecond', value);
    }
}