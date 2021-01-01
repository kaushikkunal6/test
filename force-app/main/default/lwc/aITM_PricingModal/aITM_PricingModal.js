import { LightningElement, track, api , wire} from 'lwc';
import { Toast } from 'c/sharedUtils';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners ,fireEvent} from 'c/pubsub';
import saveLine from '@salesforce/apex/AITM_TenderLocationNewOffer.updateLineItem';

export default class AITM_PricingModal extends LightningElement {
    @track displayModal = true;

    deliveryPoints = [];

    pricingRecordId;

    refreshTable;

    isChecked = false;

    selectedRecordId;
    
    @track loading = true;

    @wire(CurrentPageReference) pageRef;

    @api
    get lineId() {
        return this.getAttribute('lineId');
    }

    set lineId(value) {
        this.setAttribute('lineId', value);
    }

    handleSaved(event){
        this.toggleSpinner(true);
        saveLine({
            pricingRecordId: this.pricingRecordId.toString(),
            lineItemId: this.lineId
        })
        .then((result) => {
            this.displayModal = false;
            this.refreshSection('Save');
        })
        .catch((error) => {
            Toast.showError(this, error);
        })
        .finally(() => {
            this.toggleSpinner(false);
        });
    }

    closeModal(){
        this.displayModal = false;
        this.refreshSection('Cancel');
    }

    toggleSpinner(isVisible) {
        this.loading = isVisible;
    }

    refreshSection(calledFrom){
        const refreshaftermodal = new CustomEvent(
                                                'refreshaftermodal', 
                                                            {   
                                                                detail: calledFrom                                                              
                                                            }
                                            );
        this.dispatchEvent(refreshaftermodal);
        fireEvent(this.pageRef, 'refreshaftermodal', this.lineId);
    }

    handleValueSelected(event) {
        this.pricingRecordId = event.detail;
    }
}