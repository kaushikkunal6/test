import { LightningElement, api, track, wire } from 'lwc';
import TL_OBJECT from '@salesforce/schema/AITM_Tender_Location__c';
import { Toast } from 'c/sharedUtils';
import SUCCESSMESSAGE from '@salesforce/label/c.AITM_LocationItemSuccessMessage';
import { getRecord, updateRecord, getRecordNotifyChange, getFieldValue } from 'lightning/uiRecordApi';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import updateLOIData from '@salesforce/apex/AITM_TenderLocationService.updateAllLinesWithMasterLOI';
import TL_FIELD from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Tender_Location__c';

export default class AITMCreditTermsPage extends NavigationMixin(LightningElement) {

    @api isInDebriefStage;
    
    @track location;

    @track loading = true;

    @track priorLevelOfInterest;

    @track isSaveDisabled = true;

    tenderLocObject = TL_OBJECT;

    @api applyOverlayScreen;

    @track tenLocId;
    
    @api
    get lineId() {
        return this.getAttribute('lineId');
    }

    set lineId(value) {
        this.setAttribute('lineId', value);
    }

    @api
    get tenderLocId() {
        return this.getAttribute('tenderLocId');
    }

    set tenderLocId(value) {
        this.setAttribute('tenderLocId', value);
        this.tenLocId = this.tenderLocId;
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
                    recordId: this.tenLocId
                }
            ]
        );
        this.handleReset();
    }

    handleSuccess(event){
        this.priorLevelOfInterest = this.template.querySelector("[data-field='AITM_Level_Of_Interest__c']").value;
        this.updateLOIOnSave();
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
            .add('marginAroundFeedbackCSS');
    }

    disconnectedCallback(){
        unregisterAllListeners(this);
    }

    renderedCallback() {
        if(this.applyOverlayScreen)
            this.template.querySelector('.formBody')
            .classList
            .add('marginAroundFeedbackCSS');
    }

    updateLOIOnSave(){
        updateLOIData({
            locId: this.tenderLocId,
            selectedLOI: this.priorLevelOfInterest,
        })
        .then((result) => {
        })
        .catch((error) => {
            Toast.showError(this, error);
        })
        .finally(() => {
            this.toggleSpinner(false);
        });
    }

    handleReset() {
        if(this.tenderLocId && !this.isSaveDisabled){
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