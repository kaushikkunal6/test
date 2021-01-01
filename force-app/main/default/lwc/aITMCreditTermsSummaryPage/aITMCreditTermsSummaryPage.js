import { LightningElement, api, track, wire } from 'lwc';
import LINE_ITEM_OBJECT from '@salesforce/schema/AITM_Tender_Location_Line_Item__c';
import { Toast } from 'c/sharedUtils';
import SUCCESSMESSAGE from '@salesforce/label/c.AITM_LocationItemSuccessMessage';
import { getRecord, updateRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

export default class AITMCreditTermsPage extends NavigationMixin(LightningElement) {

    @api isInDebriefStage;
    
    @track location;

    @track loading = true;

    @track selLineId;

    @track isSaveDisabled = true;

    tenderLocLineItemObject = LINE_ITEM_OBJECT;

    @api applyOverlayScreen;
    
    @api
    get lineId() {
        return this.getAttribute('lineId');
    }

    set lineId(value) {
        this.setAttribute('lineId', value);
        this.selLineId = this.lineId;
        this.handleReset();
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
        getRecordNotifyChange(
            [
                {
                    recordId: this.selLineId
                }
            ]
        );
        this.handleReset();
    }

    handleSuccess(event){
        const refreshparent = new CustomEvent('refreshparent', 
                                            {detail:
                                                this.lineId
                                            });
        this.dispatchEvent(refreshparent);
        fireEvent(this.pageRef, 'refreshparent', this.lineId);
        this.isSaveDisabled = true;
        this.toggleSpinner(false);
    }

    handleError(event){
        Toast.showError(this, event.detail);
        this.toggleSpinner(false);
    }

    onFirstKeyUp(event){
        this.isSaveDisabled = false;
    }

    handleOnLoad(event) {
        this.toggleSpinner(false);
    }

    connectedCallback() {
        registerListener('overlayevent', this.callBackMethod, this);
        registerListener('dummyrefreshchild', this.refreshSubTabsMethod, this);
    }

    callBackMethod(payload){
        this.applyOverlayScreen = payload;
        if(this.applyOverlayScreen)
            this.template.querySelector('.formBody')
            .classList
            .add('marginAroundCreditCSS');
    }

    disconnectedCallback(){
        unregisterAllListeners(this);
    }

    renderedCallback() {
        if(this.applyOverlayScreen)
            this.template.querySelector('.formBody')
            .classList
            .add('marginAroundCreditCSS');
    }

    handleReset() {
        if(this.lineId && !this.isSaveDisabled){
            this.isSaveDisabled = true;
            const inputFields = this.template.querySelectorAll(
                'lightning-input-field'
            );
            if (inputFields) {
                inputFields.forEach(field => {
                    field.reset();
                });
            }
        }
    }
}