import { LightningElement, track, api , wire} from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { Toast } from 'c/sharedUtils';
import { registerListener, unregisterAllListeners ,fireEvent} from 'c/pubsub';
import saveLine from '@salesforce/apex/AITM_TenderLocationNewOffer.updateDeliveryRecords';
import getDeliveryData from '@salesforce/apex/AITM_TenderLocationService.getDeliveryRecords';

export default class AITM_DeliveryModal extends LightningElement {
    
    @track displayModal = true;

    deliveryPoints = [];

    deliveryRecordId;

    refreshTable;

    isChecked = false;

    @wire(CurrentPageReference) pageRef;

    @api
    get lineId() {
        return this.getAttribute('lineId');
    }

    set lineId(value) {
        this.setAttribute('lineId', value);
    }

    @api
    get locationId() {
        return this.getAttribute('locationId');
    }

    set locationId(value) {
        this.setAttribute('locationId', value);
    }

    @track loading = true;


    handleSaved(event){
        this.toggleSpinner(true);
        saveLine({
            deliveryRecordId: this.deliveryRecordId,
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

    @wire(getDeliveryData, {
        locationId: '$locationId',
    })
    
    wiredDeliveries(result){
        this.refreshTable = result;
        if (result.data) {
            this.deliveryPoints = result.data;
        }
            this.hideModal = false;
            this.toggleSpinner(false);
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

    handleSelectedDelivery(event){
        this.deliveryRecordId = event.currentTarget.dataset.del;
    }
}