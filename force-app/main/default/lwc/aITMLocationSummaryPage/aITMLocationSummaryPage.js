import { LightningElement, api, track, wire } from 'lwc';
import LINE_ITEM_OBJECT from '@salesforce/schema/AITM_Tender_Location_Line_Item__c';
import { Toast } from 'c/sharedUtils';
import SUCCESSMESSAGE from '@salesforce/label/c.AITM_LocationItemSuccessMessage';
import { getRecord, updateRecord, getRecordNotifyChange, getFieldValue } from 'lightning/uiRecordApi';
import { registerListener, unregisterAllListeners ,fireEvent} from 'c/pubsub';
import { NavigationMixin, CurrentPageReference} from 'lightning/navigation';
import LOCATION_NAME_FIELD from '@salesforce/schema/AITM_Tender_Location__c.AITM_Location__r.Name';
import AITM_LOCATION_LABEL from '@salesforce/label/c.AITM_Location_Label';

export default class AITMLocationPage extends NavigationMixin(LightningElement) {
    labels ={
        AITM_LOCATION_LABEL,
    };

    @api isInDebriefStage;
    
    @track location;

    @track locationName;

    @track selLineId;

    @track loading = true;

    @track isSaveDisabled = true;

    @api applyOverlayScreen;
	
    @wire(CurrentPageReference) pageRef;

    tenderLocLineItemObject = LINE_ITEM_OBJECT;

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

    handleOnLoad(event){
        var record = event.detail.records; 
        var objectfields = record[this.lineId].fields;
        this.location = objectfields.AITM_Location__c.value;
        this.toggleSpinner(false);
    }

    @wire(getRecord, {
        recordId: '$tenderLocId',
        fields: [LOCATION_NAME_FIELD],
      }) wireuser({ error, data }) {
        if (error) {
          this.error = error;
        } else if (data) {
          this.locationName = getFieldValue(data, LOCATION_NAME_FIELD);
        }
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

    connectedCallback() {
        registerListener('overlayevent', this.callBackMethod, this);
        registerListener('dummyrefreshchild', this.refreshSubTabsMethod, this);
    }

    callBackMethod(payload){
        this.applyOverlayScreen = payload;
        if(this.applyOverlayScreen)
            this.template.querySelector('.formBody')
            .classList
            .add('marginAroundLocationCSS');
    }

    disconnectedCallback(){
        unregisterAllListeners(this);
    }

    renderedCallback() {
        if(this.applyOverlayScreen)
            this.template.querySelector('.formBody')
            .classList
            .add('marginAroundLocationCSS');
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