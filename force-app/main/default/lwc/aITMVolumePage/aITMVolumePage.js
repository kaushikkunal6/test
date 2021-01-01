import { LightningElement, api, track, wire } from 'lwc';
import LINE_ITEM_OBJECT from '@salesforce/schema/AITM_Tender_Location_Line_Item__c';
import { Toast } from 'c/sharedUtils';
import SUCCESSMESSAGE from '@salesforce/label/c.AITM_LocationItemSuccessMessage';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

export default class AITMVolumePage  extends NavigationMixin(LightningElement) {

    @api isInDebriefStage;
    
    @track location;

    @track loading = true;

    @track isSaveDisabled = true;

    @api applyOverlayScreen;

    @api
    get lineId() {
        return this.getAttribute('lineId');
    }

    set lineId(value) {
        this.setAttribute('lineId', value);
    }

    @api
    get doPartialRefresh() {
        return this.getAttribute('doPartialRefresh');
    }

    set doPartialRefresh(value) {
        this.setAttribute('doPartialRefresh', value);
        this.refreshSubTabsMethod();
    }
	
	@wire(CurrentPageReference) pageRef;

    tenderLocLineItemObject = LINE_ITEM_OBJECT;
    
    toggleSpinner(isVisible) {
        this.loading = isVisible;
    }

    handleSubmit(event) {
        event.preventDefault();
        const fee = event.detail.fields;       
        this.toggleSpinner(true);
        this.template.querySelector('lightning-record-edit-form').submit(fee);        
    }

    refreshSubTabsMethod(){
        updateRecord(
                        {fields: 
                                { 
                                    Id: this.lineId 
                                }
                        }
                    );
    }

    handleSuccess(event){
        const refreshparent = new CustomEvent('refreshparent', 
                                            {detail:
                                                this.lineId
                                            });
        this.dispatchEvent(refreshparent);
        fireEvent(this.pageRef, 'refreshparent', this.lineId);
        this.toggleSpinner(false);
    }

    handleError(event){
        this.toggleSpinner(false);
        Toast.showError(this, event.detail);
    }

    onFirstKeyUp(event){
        this.isSaveDisabled = false;
    }

    handleOnLoad(event) {
        this.toggleSpinner(false);
    }

    connectedCallback() {
        registerListener('overlayevent', this.callBackMethod, this);
    }

    callBackMethod(payload){
        this.applyOverlayScreen = payload;
        if(this.applyOverlayScreen)
            this.template.querySelector('.formBody')
            .classList
            .add('marginAroundVolumeCSS');
    }

    disconnectedCallback(){
        unregisterAllListeners(this);
    }

    renderedCallback() {
        if(this.applyOverlayScreen)
            this.template.querySelector('.formBody')
            .classList
            .add('marginAroundVolumeCSS');
    }
}