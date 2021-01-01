import { LightningElement, api, track } from 'lwc';
import updateLOIData from '@salesforce/apex/AITM_TenderLocationService.updateAllLinesWithMasterLOI';
import TENDER_LOCATION_OBJECT from '@salesforce/schema/AITM_Tender_Location__c';
import { Toast } from 'c/sharedUtils';
import TLSUCCESSMESSAGE from '@salesforce/label/c.AITM_TenderLocationSuccessMessage';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import AITM_AM_Comments_Label from '@salesforce/label/c.AITM_AM_Comments_Label';
import AITM_LM_Comments_Label from '@salesforce/label/c.AITM_LM_Comments_Label';
import AITM_Level_Of_Interest_Label from '@salesforce/label/c.AITM_Level_Of_Interest_Label';
import AITM_LocDefaultSerLev_Label from '@salesforce/label/c.AITM_Location_Default_Service_Level_Label';
import AITM_Gross_Profit_USD_Label from '@salesforce/label/c.AITM_Gross_Profit_USD_Label';
import AITM_Customer_Service_Level_Label from '@salesforce/label/c.AITM_Customer_Service_Level_Label';
import AITM_Aircraft_Type_Label from '@salesforce/label/c.AITM_Aircraft_Type_Label';
import AITM_Service_Level_Approval_Label from '@salesforce/label/c.AITM_Service_Level_Approval_Label';
import AITM_Volume_USG_Label from '@salesforce/label/c.AITM_Volume_USG_Label';
import AITM_Working_Cap_USD_Label from '@salesforce/label/c.AITM_Working_Cap_USD_Label';
import AITM_ROWC_Label from '@salesforce/label/c.AITM_ROWC_Label';
import AITM_Estimated_Leading_Diff_Label from '@salesforce/label/c.AITM_Estimated_Leading_Diff_Label';
import AITM_Currency_UOM_Label from '@salesforce/label/c.AITM_Currency_UOM_Label';
import AITM_Bidders_Label from '@salesforce/label/c.AITM_Bidders_Label';
import AITM_Position_Label from '@salesforce/label/c.AITM_Position_Label';
import AITM_Bid_Expiry_Date_Label from '@salesforce/label/c.AITM_Bid_Expiry_Date';

export default class AITMTLFieldsPage extends LightningElement {
    labels = {
        AITM_AM_Comments_Label,
        AITM_LM_Comments_Label,
        AITM_Level_Of_Interest_Label,
		AITM_Gross_Profit_USD_Label,
        AITM_LocDefaultSerLev_Label,
		AITM_Aircraft_Type_Label,
		AITM_Customer_Service_Level_Label,
		AITM_Service_Level_Approval_Label,
		AITM_Volume_USG_Label,
		AITM_Working_Cap_USD_Label,
		AITM_Estimated_Leading_Diff_Label,
		AITM_ROWC_Label,
		AITM_Currency_UOM_Label,
		AITM_Bidders_Label,
        AITM_Position_Label,
        AITM_Bid_Expiry_Date_Label,
    };

    @api recordId;

    @track location;

    @track loading = true;

    @track isSaveDisabled = true;

    @track priorLevelOfInterest;

    tenderLocObject = TENDER_LOCATION_OBJECT;
    
    toggleSpinner(isVisible) {
        this.loading = isVisible;
    }

    handleSubmit(event) {
        event.preventDefault();
        const tenderLoc = event.detail.fields;       
        this.toggleSpinner(true);
        this.template.querySelector('lightning-record-edit-form').submit(tenderLoc);        
    }

    handleSuccess(event){
        //Toast.showSuccess(this, TLSUCCESSMESSAGE);
        this.priorLevelOfInterest = this.template.querySelector("[data-field='AITM_Level_Of_Interest__c']").value;
        this.updateLOIOnSave();
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
        this.loading = false;
    } 

    handleOnLoad(event){ 
        this.toggleSpinner(false);
    }

    updateLOIOnSave(){
        updateLOIData({
            locId: this.recordId,
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
}