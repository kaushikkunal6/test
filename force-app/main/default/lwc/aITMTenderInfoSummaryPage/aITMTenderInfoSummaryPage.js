import { LightningElement, api, track, wire } from 'lwc';
import TENDER_OBJECT from '@salesforce/schema/AITM_Tender__c';
import { Toast } from 'c/sharedUtils';
import SUCCESSMESSAGE from '@salesforce/label/c.AITM_LocationItemSuccessMessage';
import { getRecord, updateRecord, getFieldValue, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { registerListener, unregisterAllListeners ,fireEvent} from 'c/pubsub';
import { NavigationMixin, CurrentPageReference} from 'lightning/navigation';
import TENDER_FIELD from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Tender__c';

export default class AITMLocationPage extends NavigationMixin(LightningElement) {

    @api isInDebriefStage;
    
    @track location;

    @track tenderId;

    @track locationName;

    @track loading = true;

    @track isSaveDisabled = true;

    @api applyOverlayScreen;
	
    @wire(CurrentPageReference) pageRef;

    tenderObject = TENDER_OBJECT;

    @api
    get tenderLocId() {
        return this.getAttribute('tenderLocId');
    }

    set tenderLocId(value) {
        this.setAttribute('tenderLocId', value);
    }

    @api
    get lineId() {
        return this.getAttribute('lineId');
    }

    set lineId(value) {
        this.setAttribute('lineId', value);
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

    handleOnLoad(event){
        this.toggleSpinner(false);
    }
    
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
        if(this.tenderId){
            getRecordNotifyChange(
                [
                    {
                        recordId: this.tenderId
                    }
                ]
            );
            this.handleReset();
        }
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

    connectedCallback() {
        registerListener('overlayevent', this.callBackMethod, this);
        registerListener('dummyrefreshchild', this.refreshSubTabsMethod, this);
    }

    callBackMethod(payload){
        this.applyOverlayScreen = payload;
        if(this.applyOverlayScreen)
            this.template.querySelector('.formBody')
            .classList
            .add('marginAroundInfoCSS');
    }

    disconnectedCallback(){
        unregisterAllListeners(this);
    }

    renderedCallback() {
        if(this.applyOverlayScreen)
            this.template.querySelector('.formBody')
            .classList
            .add('marginAroundInfoCSS');
    }

    @wire(getRecord, { recordId: '$lineId', fields: TENDER_FIELD })
    wiredTenderLoc({ data }) {
        if (data) {
            this.tenderId = getFieldValue(data, TENDER_FIELD);
        }
    }

    handleReset() {
        if(this.lineId){
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