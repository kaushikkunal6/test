import { LightningElement, api, track, wire } from 'lwc';
import LINE_ITEM_OBJECT from '@salesforce/schema/AITM_Tender_Location_Line_Item__c';
import TENDER_LOC_OBJECT from '@salesforce/schema/AITM_Tender_Location__c';
import { Toast } from 'c/sharedUtils';
import SUCCESSMESSAGE from '@salesforce/label/c.AITM_LocationItemSuccessMessage';
import { getRecord, updateRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import INCLUDEREVISEOFFER_FIELD from '@salesforce/schema/AITM_Tender_Location__c.AITM_Include_In_Revised_Offer__c';
import ROUND_FIELD from '@salesforce/schema/AITM_Tender_Location__c.AITM_Round__c';
import ID_FIELD from '@salesforce/schema/AITM_Tender_Location__c.Id';
import { refreshApex } from '@salesforce/apex';
import AITM_EXCHANGE_LABEL from '@salesforce/label/c.AITM_Exchange_Label';
import AITM_REBATE_LABEL from '@salesforce/label/c.AITM_Rebate_Label';
import AITM_CURRENT_VALUE_LABEL from '@salesforce/label/c.AITM_Current_Value_Label';
import AITM_DIFFERENTIAL_LABEL from '@salesforce/label/c.AITM_Differential_Label';

export default class AITMPricePage extends NavigationMixin(LightningElement) {
    labels = {
        AITM_EXCHANGE_LABEL,
        AITM_REBATE_LABEL,
        AITM_CURRENT_VALUE_LABEL,
        AITM_DIFFERENTIAL_LABEL,
    };

    @api recordId;

    @track location;

    @api isInDebriefStage;

    refreshTable;

    @track loading;

    @api applyOverlayScreen;

    @track isSaveDisabled = true;

    tenderLocLineItemObject = LINE_ITEM_OBJECT;

    tenderLocObject = TENDER_LOC_OBJECT;

    @track userEmailAddress = '';

    @track offer;

    @track tenLocId;

    @track selLineId;

    @track tenderOffer = true;

    @track round;

    @api
    get tenderLocId() {
        return this.getAttribute('tenderLocId');
    }

    set tenderLocId(value) {
        this.setAttribute('tenderLocId', value);
        this.tenLocId = this.tenderLocId;
    }

    @api
    get doPartialRefresh() {
        return this.getAttribute('doPartialRefresh');
    }

    set doPartialRefresh(value) {
        this.setAttribute('doPartialRefresh', value);
        this.refreshSubTabsMethod();
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

    @wire(getRecord, {
        recordId: '$tenLocId',
        fields: [
            INCLUDEREVISEOFFER_FIELD, ROUND_FIELD,
        ],
    })   
    wiredRecord(result) {
        this.refreshTable = result;
        if (result.error) {
            Toast.showError(this, result.error);
        } else if (result.data) {
            this.offer = Boolean(result.data.fields[INCLUDEREVISEOFFER_FIELD.fieldApiName].value);
            this.round = result.data.fields[ROUND_FIELD.fieldApiName].value;
        }
    }

    updateTender() {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.tenderLocId;
        fields[INCLUDEREVISEOFFER_FIELD.fieldApiName] = Boolean(this.offer);
        const recordInput = { fields };
        return updateRecord(recordInput)
            .then(() => {
            })
            .catch(error => Toast.showError(this, error))
            .finally(() => {
                this.toggleSpinner(false);
                return refreshApex(this.refreshTable);
            });
    }

    @wire(CurrentPageReference) pageRef;
    
    get isOfferDisabled(){ 
        return this.round == 1 ? true : false;
    }

    get offerVal(){ 
        return this.offer;
    }

    toggleSpinner(isVisible) {
        this.loading = isVisible;
    }

    handleSubmit(event) {
        event.preventDefault();
        const fee = event.detail.fields;       
        this.toggleSpinner(true);
        this.updateTender();
        this.template.querySelector('lightning-record-edit-form').submit(fee);        
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
        this.toggleSpinner(false);
        Toast.showError(this, event.detail);   
    }

    onFirstKeyUp(event){
        this.isSaveDisabled = false;
        if(event.target.name === 'Offer')
            this.offer = event.target.checked;
    }

    handleOnLoad(event) {
        this.toggleSpinner(false);
    }

    connectedCallback() {
        registerListener('overlayevent', this.callBackMethod, this);
        registerListener('dummyrefreshchild', this.refreshSubTabsMethod, this);
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

    form(){
        return this.template.querySelector('lightning-record-edit-form');
    }

    callBackMethod(payload){
        this.applyOverlayScreen = payload;
        if(this.applyOverlayScreen)
            this.setStyle();
    }

    disconnectedCallback(){
        unregisterAllListeners(this);
    }

    renderedCallback() {
        if(this.applyOverlayScreen)
            this.setStyle();
            this.template.querySelector('.customLabelApplyCss').setAttribute('style', `
                color: var(--lwc-colorTextLabel,rgb(62, 62, 60));
                font-size: 0.75rem;`
            );
    }

    setStyle() {
        this.bodyItem.setAttribute('style', `margin-top: 30px; margin-left:250px;margin-right:250px;`);
    }

    get bodyItem() {
        return this.template.querySelector('.priceBody');
    }

    handleReset() {
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