import { LightningElement, api, track, wire } from 'lwc';
import LINE_ITEM_OBJECT from '@salesforce/schema/AITM_Tender_Location_Line_Item__c';
import LI_Density_FIELD from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Density__c';
import PRODUCT_DEFAULT_FIELD from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Product_Default__c';
import RISK_RATING_FIELD from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Credit_Rating__c';
import Exchange_FIELD from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Exchange__c';
import MEASURE_RATING_FIELD from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Measure__c';
import DELIVERY_METHOD_FIELD from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Location_Delivery_Point__r.Name';
import CREDIT_DAYS_FIELD from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Credit_Days__c';
import INVOICE_FREQUENCY_FIELD from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Invoice_Frequency__c';
import CREDIT_DAYS_INVOICE_FREQUENCY_LABEL from '@salesforce/label/c.AITM_CreditDays_Frequency';
import PRODUCT_DENSITY_LABEL from '@salesforce/label/c.AITM_Product_Density';
import RISK_RATING_LABEL from '@salesforce/label/c.AITM_Risk_Rating';
import MEASURE_LABEL from '@salesforce/label/c.AITM_Measure';
import LASTTENDER_LABEL from '@salesforce/label/c.AITM_LastTender';
import EXCHANGE_LABEL from '@salesforce/label/c.AITM_Exchange';
import AITM_RiskRatingCodeLabel from '@salesforce/label/c.AITM_RiskRatingCodeLabel';
import AITM_CreditDaysCodeLabel from '@salesforce/label/c.AITM_CreditDaysCodeLabel';
import AITM_ExchangeCodeLabel from '@salesforce/label/c.AITM_ExchangeCodeLabel';
import AITM_MeasureColorCodeLabel from '@salesforce/label/c.AITM_MeasureColorCodeLabel';
import AITM_DeliveryMethodColorCodeLabel from '@salesforce/label/c.AITM_DeliveryMethodColorCodeLabel';
import AITM_ProductDensityColorCodeLabel from '@salesforce/label/c.AITM_ProductDensityColorCodeLabel';
import AITM_LastTenderColorCodeLabel from '@salesforce/label/c.AITM_LastTenderColorCodeLabel';
import DELIVERY_METHOD_LABEL from '@salesforce/label/c.AITM_Delivery_Method';
import getWrapperTLRelFields from '@salesforce/apex/AITM_TenderLocationService.getWrapperTLLIFields';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { Toast } from 'c/sharedUtils';
import SUCCESSMESSAGE from '@salesforce/label/c.AITM_LocationItemSuccessMessage';
import COLORCODE from '@salesforce/label/c.AITM_RedColorLabel';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

export default class AITM_TenderLocationRecordEditPage extends LightningElement {

    tenderLocLineItemObject = LINE_ITEM_OBJECT;

    @track concatenatedProductDensity;

    @track refreshTable;

    @track tfWrapperRelatedFields;

    @api recordId;

    @wire(CurrentPageReference) pageRef;
    
    labels = {        
        MEASURE_LABEL,
        EXCHANGE_LABEL,
        LASTTENDER_LABEL,
        RISK_RATING_LABEL,
        PRODUCT_DENSITY_LABEL,
        DELIVERY_METHOD_LABEL,
        CREDIT_DAYS_INVOICE_FREQUENCY_LABEL,
      }

    fields = {
        LI_Density_FIELD,
        PRODUCT_DEFAULT_FIELD,
        Exchange_FIELD,
        MEASURE_RATING_FIELD,
        DELIVERY_METHOD_FIELD,
        CREDIT_DAYS_FIELD,
        INVOICE_FREQUENCY_FIELD,
    }

    handleOnLoad(event){
        var record = event.detail.records; 
        var objectfields = record[this.lineId].fields;
        this.notes = objectfields.AITM_Additional_Notes_Taxes_and_Fees__c.value;
    }

    @wire(getWrapperTLRelFields, { 
        locId: '$recordId',  
        sObjectname: 'AITM_Tender_Location_Line_Item__c'
    })
    wiredHighestLI(result) {
        this.refreshTable = result;
        if (result.data) {
            this.tfWrapperRelatedFields = result.data;
        } else if (result.error) {
            this.dispatchEvent(
                new ShowToastEvent({
                  title: 'ERROR',
                  message: result.error,
                  variant: 'error',
                }),
              );
            this.tfWrapperRelatedFields = null;
        }
    } 

    renderedCallback() {
        this.setColorCode();
    }

    setColorCode() {
        if(this.tfWrapperRelatedFields){
            var data = this.tfWrapperRelatedFields.colorCodes;

            this.template.querySelectorAll('div').forEach((element) => {
                element.classList.remove('redCSS');
            });

            for (let key in data) {
                if(key == AITM_LastTenderColorCodeLabel && data[key] == COLORCODE)
                    this.template.querySelector('.applyRedForLastTender')
                    .classList
                    .add('redCSS');
                if(key == AITM_ProductDensityColorCodeLabel && data[key] == COLORCODE)
                    this.template.querySelector('.applyRedForProductDensity')
                    .classList
                    .add('redCSS'); 
                if(key == AITM_DeliveryMethodColorCodeLabel && data[key] == COLORCODE)
                    this.template.querySelector('.applyRedForDeliveryMethod')
                    .classList
                    .add('redCSS');
                if(key == AITM_MeasureColorCodeLabel && data[key] == COLORCODE)
                    this.template.querySelector('.applyRedForMeasure')
                    .classList
                    .add('redCSS');
                if(key == AITM_RiskRatingCodeLabel && data[key] == COLORCODE)
                    this.template.querySelector('.applyRedForRiskRating')
                    .classList
                    .add('redCSS'); 
                if(key == AITM_ExchangeCodeLabel && data[key] == COLORCODE)
                    this.template.querySelector('.applyRedForExchange')
                    .classList
                    .add('redCSS'); 
                if(key == AITM_CreditDaysCodeLabel && data[key] == COLORCODE)    
                    this.template.querySelector('.applyRedForCreditDaysFrequency')
                    .classList
                    .add('redCSS');
            }
        }        
        this.template.querySelectorAll('lightning-formatted-text').forEach((element) => {
            element.classList.add('fontFamilyCSS');
          });
    }  

    connectedCallback() {
        refreshApex(this.refreshTable);
        registerListener('refreshparent', this.callBackMethod, this);
    }

    callBackMethod(payload){
        refreshApex(this.refreshTable);
    }

    get delPointName() {       
        return (this.tfWrapperRelatedFields && this.tfWrapperRelatedFields.record.AITM_Delivery_Method__c) ? this.tfWrapperRelatedFields.record.AITM_Delivery_Method__c : '';
    }

    get density() {
        return (this.tfWrapperRelatedFields && this.tfWrapperRelatedFields.record.AITM_Density__c) ? this.tfWrapperRelatedFields.record.AITM_Density__c : '';
    }

    get creditDays() {
        return (this.tfWrapperRelatedFields && this.tfWrapperRelatedFields.record.AITM_Credit_Days__c) ? this.tfWrapperRelatedFields.record.AITM_Credit_Days__c : '';
    }

    get invoiceFrequency() {
        return (this.tfWrapperRelatedFields && this.tfWrapperRelatedFields.record.AITM_Invoice_Frequency__c) ? this.tfWrapperRelatedFields.record.AITM_Invoice_Frequency__c : '';
    }

    get productDefault(){ 
        return (this.tfWrapperRelatedFields && this.tfWrapperRelatedFields.record.AITM_Product_Default__c) ? this.tfWrapperRelatedFields.record.AITM_Product_Default__c : '';
    }

    get measure(){ 
        return (this.tfWrapperRelatedFields && this.tfWrapperRelatedFields.record.AITM_Measure__c) ? this.tfWrapperRelatedFields.record.AITM_Measure__c : '';
    }

    get exchange(){ 
        return (this.tfWrapperRelatedFields && this.tfWrapperRelatedFields.record.AITM_Exchange__c) ? this.tfWrapperRelatedFields.record.AITM_Exchange__c : '';
    }

    get creditRating(){ 
        return (this.tfWrapperRelatedFields && this.tfWrapperRelatedFields.record.AITM_Credit_Rating__c) ? this.tfWrapperRelatedFields.record.AITM_Credit_Rating__c : '';
    }

    get lastTender(){ 
        return (this.tfWrapperRelatedFields && this.tfWrapperRelatedFields.record.AITM_Last_Tender_Result__c) ? this.tfWrapperRelatedFields.record.AITM_Last_Tender_Result__c : '';
    }

    get uom(){ 
        return (this.tfWrapperRelatedFields && this.tfWrapperRelatedFields.record.AITM_Unit_Of_Measure__c) ? this.tfWrapperRelatedFields.record.AITM_Unit_Of_Measure__c : '';
    }

    get currency(){ 
        return (this.tfWrapperRelatedFields && this.tfWrapperRelatedFields.record.AITM_Currency__c) ? this.tfWrapperRelatedFields.record.AITM_Currency__c : '';
    }

    get offeredDiff(){ 
        return (this.tfWrapperRelatedFields && this.tfWrapperRelatedFields.record.AITM_Offered_Differential__c) ? this.tfWrapperRelatedFields.record.AITM_Offered_Differential__c : '';
    }
}