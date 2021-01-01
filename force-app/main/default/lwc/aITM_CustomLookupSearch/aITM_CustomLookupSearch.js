import { LightningElement, api, track } from 'lwc';

export default class AITM_CustomLookupSearch extends LightningElement {
    @api childObjectApiName; 
    @api targetFieldApiName; 
    @api fieldLabel;
    @api disabled = false;
    @api value;
    @api required = false;

    @track loading = true;

    handleChange(event) {
        const selectedEvent = new CustomEvent('valueselected', {
            detail: event.detail.value
        });
        this.dispatchEvent(selectedEvent);
    }

    @api isValid() {
        if (this.required) {
            //this.template.querySelector('lightning-input-field').reportValidity();
        }
    }

    toggleSpinner(isVisible) {
        this.loading = isVisible;
    }

    renderedCallback(){
        this.toggleSpinner(false);
    }
}