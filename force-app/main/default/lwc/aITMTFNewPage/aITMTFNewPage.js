import { LightningElement, track, api, wire } from 'lwc';
import getTaxesAndFeesData from '@salesforce/apex/AITM_TenderLocationService.getTaxesAndFees';
import getCurrencyData from '@salesforce/apex/AITM_MassEditRLCtrl.getListOfCurrency';
import { refreshApex } from '@salesforce/apex';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import saveTaxesAndFeesData from '@salesforce/apex/AITM_TenderLocationService.saveTaxesAndFees';
import LINE_ITEM_OBJECT from '@salesforce/schema/AITM_Tender_Location_Line_Item__c';
import TENDER_LOC_TF_CONFIGURATION_OBJECT from '@salesforce/schema/AITM_Tender_Location_Taxes_and_Fees__c';
import ALERT_MESSAGE_1_LABEL from '@salesforce/label/c.AITM_TF_Alert_1';
import ALERT_MESSAGE_2_LABEL from '@salesforce/label/c.AITM_TF_Alert_2';
import ALERT_MESSAGE_3_LABEL from '@salesforce/label/c.AITM_TF_Alert_3';
import ALERT_MESSAGE_4_LABEL from '@salesforce/label/c.AITM_TF_Alert_4';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import FUELTYPEFIELD from '@salesforce/schema/AITM_Tender_Location_Taxes_and_Fees__c.AITM_Fuel_Type_Code__c';
import CONDANDCOMPFIELD from '@salesforce/schema/AITM_Tender_Location_Taxes_and_Fees__c.AITM_COMP_COND__c';
import FEE_OBJECT from '@salesforce/schema/AITM_Tender_Location_Taxes_and_Fees__c';
import { Toast } from 'c/sharedUtils';
import DUPLICATETAXLABEL from '@salesforce/label/c.AITM_DuplicateTaxLabel';
import CURRENCYVALIDATIONLABEL from '@salesforce/label/c.AITM_CurrencyValidationLabel';
import SUCCESSMESSAGE from '@salesforce/label/c.AITM_LocationItemSuccessMessage';
import TFERRORLABEL from '@salesforce/label/c.AITM_TFTendersPreValidationErrorLabel';
import AdditionalNotesErrorLabel from '@salesforce/label/c.AITM_TFAdditionalNotesLabel';
import TFSUCCESSMESSAGE from '@salesforce/label/c.AITM_TFSuccessMessage';
import COMP_COND_HELPTEXT from '@salesforce/label/c.AITM_COMPCONDHelpText';
import AITM_Add_Notes_Label from '@salesforce/label/c.AITM_Add_Notes_Label';
import AITM_TF_Notes_Label from '@salesforce/label/c.AITM_TF_Notes_Label';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class AITMTFPage extends NavigationMixin(LightningElement) {
    labels = {
        ALERT_MESSAGE_1_LABEL,
        ALERT_MESSAGE_2_LABEL,
        ALERT_MESSAGE_3_LABEL,
        ALERT_MESSAGE_4_LABEL,
        COMP_COND_HELPTEXT,
        DUPLICATETAXLABEL,
        CURRENCYVALIDATIONLABEL,
        TFERRORLABEL,
        AITM_Add_Notes_Label,
        AITM_TF_Notes_Label,
    };

    @track notes;

    @track taxesNotes;

    @track includeTFContract;

    @track includeNotesContract;

    @track currencies;

    @track taxesAndFees;

    @track currentIndex;

    @track displayToolTip;

    @track selectedContent;

    @track selectedFeeId;

    @track top;

    @track left;

    @track loading;

    @track showNameToolTip;

    @track showCompTooltip;

    @track index = 0;

    @track boolIsError = false;

    @track disableTdElement;

    @track deleteVisible = false;

    @track currencyISOCodeValues;

    @track existingTaxesAndFees;

    isInDebriefStage;

    redVariant;

    newFees = [];

    selectedUpdatedFees = [];

    updatedFees = [];

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
    
    tenderLocLineItemObject = LINE_ITEM_OBJECT;

    refreshTable;

    fee = {
        Name: 'Test',
        Tender_Location_Line_Item_Id__c: this.lineId,
        key: ''
    }

    get taxesAndFees() {
        return this.taxesAndFees ? this.taxesAndFees.reverse() : [];
    }

    @wire(CurrentPageReference) pageRef;

    @wire(getObjectInfo, { objectApiName: TENDER_LOC_TF_CONFIGURATION_OBJECT })
    tenderLocTFConfigObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$tenderLocTFConfigObjectInfo.data.defaultRecordTypeId',
        fieldApiName: CONDANDCOMPFIELD
    })
    compCondValues;

    @wire(getPicklistValues, {
        recordTypeId: '$tenderLocTFConfigObjectInfo.data.defaultRecordTypeId',
        fieldApiName: FUELTYPEFIELD,
    })
    fuelTypeValues;

    @wire(getTaxesAndFeesData, {
        lineId: '$lineId',
        sObjectname: 'AITM_Tender_Location_Taxes_and_Fees__c'
    })
    wiredTaxesAndFees(result) {
        this.refreshTable = result;
        if (result.data) {
            this.taxesAndFees = [];
            result.data.forEach(fee => {
                this.taxesAndFees.push({
                    Key: this.taxesAndFees.length + 1,
                    Name: fee.Name,
                    Id: fee.Id,
                    Short_AITM_Compulsory_Conditional__c: (this.truncateString(fee.AITM_Compulsory_Conditional__c, 4)),
                    AITM_Fuel_Type__c: fee.AITM_Fuel_Type__c,
                    AITM_Value__c: fee.AITM_Value__c,
                    AITM_COMP_COND__c: fee.AITM_COMP_COND__c,
                    AITM_Rectified_Display_Currency__c: (this.rectifyCurrency(fee.AITM_Display_Currency__c)),
                    AITM_Display_Currency__c: fee.AITM_Display_Currency__c,
                    AITM_Unit_of_measure__c: fee.AITM_Unit_of_measure__c,
                    Tender_Location_Line_Item_Id__c: fee.Tender_Location_Line_Item_Id__c,
                    AITM_Select_to_Apply_in_Contract__c: fee.AITM_Select_to_Apply_in_Contract__c,
                    AITM_Compulsory_Conditional__c: fee.AITM_Compulsory_Conditional__c,
                    AITM_Manually_Saved_Tax__c: fee.AITM_Manually_Saved_Tax__c,
                    visibleDelete: false,
                    isFreezed: true,
                    isNew: false,
                });
            });
            this.existingTaxesAndFees = this.taxesAndFees;
        } else if (result.error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'ERROR',
                    message: result.error,
                    variant: 'error',
                }),
            );
            this.taxesAndFees = null;
        }
    }

    @wire(getCurrencyData)
    wiredCurrencyData(result) {
        if (result.data) {
            this.currencies = result.data;
        }
    };

    get currencyOptions() {
        let arr = [];
        const currencies = [];
        currencies.push({ label: 'USD', value: 'USD'});
        currencies.push({ label: 'USX', value: 'USX'});
        currencies.push({ label: 'EUR', value: 'EUR'});
        currencies.push({ label: 'EUX', value: 'EUX'});
        for (let i = 0; i < this.currencies.length; i += 1) {
            if(!(this.currencies[i] == 'EUR' 
                || this.currencies[i] == 'USX'
                || this.currencies[i] == 'USD'
                || this.currencies[i] == 'EUX'
            ))
                currencies.push({ label: this.currencies[i], value: this.currencies[i] });
        }
        return currencies;
    }

    get boxClass() {
        return `top:${this.top}px; left:${this.left - 500}px`;
    }

    rectifyCurrency(str) {
        if (str)
            return str;
        return '';
    }

    truncateString(str, num) {
        if (str && str.length <= num)
            return str
        return str.slice(0, num) + '.';
    }

    hitServer(){ 
        refreshApex(this.refreshTable);      
    }

    handleOnLoad(event) {
        var record = event.detail.records;
        var objectfields = record[this.lineId].fields;
        this.notes = objectfields.AITM_Additional_Notes_Taxes_and_Fees__c.value;
        this.taxesNotes = objectfields.AITM_Taxes_Fees__c.value;
    }

    handleChange(event) {
        this.redVariant = (this.redVariant != 'destructive') ? 'destructive' : this.redVariant;
        if (event.target.name == 'AITM_Additional_Notes_Taxes_and_Fees__c')
            this.notes = this.template.querySelector('.textAreaCSS').value;
        else if (event.target.name == 'AITM_Taxes_Fees__c')
            this.taxesNotes = event.detail.value;
    }

    showToolTip(event) {
        this.selectedContent = event.currentTarget.getAttribute("data-target");
        this.selectedFeeId = event.currentTarget.dataset.id;
        this.currentIndex = parseInt(event.target.dataset.index);
        this.displayToolTip = true;
        this.left = event.clientX;
        this.top = event.clientY;
        if (this.currentIndex == 1) {
            this.template.querySelector('.name')
                .classList
                .add('tooltip');
            this.showNameToolTip = true;
        }
    }

    hideToolTip(event) {
        this.selectedContent = [];
        this.displayToolTip = false;
        this.selectedFeeId = '';
        this.left = '';
        this.top = '';
        this.template.querySelector('.name')
            .classList
            .remove('tooltip');
        this.showNameToolTip = false;
        this.showCompToolTip = false;
    }

    get hasToolTip() {
        return (this.currentIndex == '1') ? true : false;
    }

    addTaxesAndFees(event) {
        let feeWithoutId = this.taxesAndFees.findIndex(fee => (!fee.Name));
        this.taxesAndFees.unshift({
            Tender_Location_Line_Item_Id__c: this.lineId,
            AITM_Select_to_Apply_in_Contract__c: true,
            visibleDelete: true,
            isFreezed: false,
            isNew: true,
            AITM_Manually_Saved_Tax__c: true,
			AITM_Record_Type_Name__c: 'Default',
        });
        var count = 0;
        this.redVariant = (this.redVariant != 'destructive') ? 'destructive' : this.redVariant;
        this.shuffleIndexing();
        Array.from(this.template.querySelectorAll('lightning-input')).forEach((elem) => {
            const lightningInput = elem;
            if (lightningInput.isNew)
                lightningInput.classList.add('customValueCSS');
        });
        if (this.applyOverlayScreen) {
            this.template.querySelectorAll('.overlayDynamicNameCSS').forEach((element) => {
                element.classList.add('overlayNameCSS');
            });
        }
    }

    connectedCallback() {
        refreshApex(this.refreshTable);
        this.loading = false;
        registerListener('overlayevent', this.callBackMethod, this);
        registerListener('refreshparent', this.callBackDelMethod, this);
        registerListener('debriefevent', this.callBackDebriefMethod, this);
    }

    callBackDebriefMethod(payload) {
        this.isInDebriefStage = payload;
    }

    callBackDelMethod(payload) {
        refreshApex(this.refreshTable);
    }

    refreshSubTabsMethod(){
        updateRecord({
                        fields: 
                                { 
                                    Id: this.lineId 
                                }
                        }
                    ).then(() => {
                        refreshApex(this.refreshTable);                        
                    });       
    }

    callBackMethod(payload) {
        this.applyOverlayScreen = payload;
        if (!this.applyOverlayScreen) {
            this.template.querySelectorAll('.dynamicTDCSS').forEach((element) => {
                element.classList.remove('overlayMinWidthCSS');
            });
            this.template.querySelectorAll('.overlayDynamicNameCSS').forEach((element) => {
                element.classList.remove('overlayNameCSS');
            });
        }
        if (this.applyOverlayScreen) {
            this.template.querySelector('.formBody')
                .classList
                .add('marginAroundCSS');
            this.template.querySelector('.alertCSS')
                .classList
                .add('aletOverlayCSS');
            this.template.querySelectorAll('.slds-table tr').forEach((element) => {
                element.classList.remove('inputHeightCSS');
            });
            this.template.querySelectorAll('.inputWidthCSS').forEach((element) => {
                element.classList.remove('feeNameCSS');
            });
        }
        if (this.applyOverlayScreen) {
            this.template.querySelector('.formBody')
                .classList
                .add('marginAroundCSS');
            this.template.querySelectorAll('.dynamicTDCSS').forEach((element) => {
                element.classList.add('overlayMinWidthCSS');
            });
            this.template.querySelectorAll('.overlayDynamicNameCSS').forEach((element) => {
                element.classList.add('overlayNameCSS');
            });
            this.template.querySelectorAll('.slds-table tr').forEach((element) => {
                element.classList.remove('inputHeightCSS');
            });
            this.template.querySelectorAll('.inputWidthCSS').forEach((element) => {
                element.classList.remove('feeNameCSS');
            });
            this.template.querySelectorAll('input').forEach((element) => {
                if (element.name == 'Name') {
                    element.classList.remove('freezedCSS');
                    element.classList.remove('feeNameCSS');
                }
                if (element.name == 'AITM_Compulsory_Conditional__c' || element.name == 'AITM_Fuel_Type__c') {
                    element.classList.remove('compCSS');
                    element.classList.remove('freezedCSS');
                }
                if (element.name == 'value') {
                    element.classList.remove('customCSSForFreezed');
                    element.classList.remove('customValueCSS');
                }
                if (element.name == 'AITM_Unit_of_measure__c' || element.name == 'CurrencyIsoCode') {
                    element.classList.remove('freezedCSS');
                }
            });
        }
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = `.slds-table thead th{
            background: white;
            border-bottom: 1px solid rgb(221, 219, 218);
            bottom: 13px;
        }`;
        this.template.querySelector('.slds-table').appendChild(style);

        this.template.querySelector('.slds-button')
            .classList
            .add('greenIconCSS');
        this.template.querySelectorAll('.slds-textarea').forEach((element) => {
            element.classList.add('textAreaHeigtCSS');
        });

        if (this.applyOverlayScreen) {
            this.template.querySelector('.formBody')
                .classList
                .add('marginAroundCSS');
            this.template.querySelectorAll('.slds-table tr').forEach((element) => {
                element.classList.remove('inputHeightCSS');
            });
            this.template.querySelectorAll('.inputWidthCSS').forEach((element) => {
                element.classList.remove('feeNameCSS');
            });
            this.template.querySelectorAll('input').forEach((element) => {
                if (element.name == 'Name') {
                    element.classList.remove('freezedCSS');
                    element.classList.remove('feeNameCSS');
                }
                if (element.name == 'AITM_Compulsory_Conditional__c' || element.name == 'AITM_Fuel_Type__c') {
                    element.classList.remove('compCSS');
                    element.classList.remove('freezedCSS');
                }
                if (element.name == 'value') {
                    element.classList.remove('customCSSForFreezed');
                    element.classList.remove('customValueCSS');
                }
                if (element.name == 'AITM_Unit_of_measure__c' || element.name == 'CurrencyIsoCode') {
                    element.classList.remove('freezedCSS');
                }
            });
        }
        else {
            this.template.querySelectorAll('.slds-table tr').forEach((element) => {
                element.classList.add('inputHeightCSS');
            });
            this.template.querySelectorAll('.inputWidthCSS').forEach((element) => {
                element.classList.add('feeNameCSS');
            });
            this.template.querySelectorAll('.slds-table th, .slds-table td').forEach((element) => {
                element.classList.add('cellSpacingCSS');
            });
            this.template.querySelectorAll('input').forEach((element) => {
                if (element.name == 'Name') {
                    element.classList.add('feeNameCSS');
                    element.classList.add('freezedCSS');
                }
                if (element.name == 'AITM_Compulsory_Conditional__c' || element.name == 'AITM_Fuel_Type__c') {
                    element.classList.add('compCSS');
                    element.classList.add('freezedCSS');
                }
                if (element.name == 'value') {
                    element.classList.add('customCSSForFreezed');
                    element.classList.add('customValueCSS');
                }
                if (element.name == 'AITM_Unit_of_measure__c' || element.name == 'CurrencyIsoCode') {
                    element.classList.add('freezedCSS');
                    element.classList.add('compCSS');
                }
            });
        }
    }

    saveTaxesAndFees(event) {
        this.newFees = [];
        this.updatedFees = [];
        this.boolIsError = false;
        this.selectedUpdatedFees = [];
        const vformEle = this.template.querySelectorAll('.mandatoryField');
        vformEle.forEach((element) => {
            if (!element.value) {
                this.boolIsError = true;
                element.classList.add('slds-has-error');
            } else {
                element.classList.remove('slds-has-error');
            }
        });

        if (!this.boolIsError)
            this.checkUOMAndCurrencyValidation();

        if (!this.boolIsError)
            this.duplicateTaxesAndFees();

        if (!this.boolIsError) {
            this.toggleSpinner(true);
            this.updateCurrencyAsBlank();
            this.taxesAndFees.forEach((elem) => {
                const lightningInput = elem;
                if (lightningInput.isNew)
                    this.newFees.push(lightningInput);
                else
                    this.updatedFees.push(lightningInput);
            });
            this.filterUpdatedFees();
            this.includeTFContract = this.template.querySelector("[data-field='AITM_Include_Taxes_and_Fees_in_Contract__c']").value;
            this.includeNotesContract = this.template.querySelector("[data-field='AITM_Include_Notes_in_Contract__c']").value;
                saveTaxesAndFeesData({
                    updatedFees: this.selectedUpdatedFees,
                    newFees: this.newFees,
                    lineId: this.lineId,
                    notes: this.notes,
                    taxesNotes: this.taxesNotes,
                    includeTFContract: this.includeTFContract,
                    includeNotesContract: this.includeNotesContract,
                })
                    .then((result) => {
                    })
                    .catch((error) => {
                        var errorMsg = TFERRORLABEL;
                        var showAddNotesError = false;
                        const errorArr = Array.isArray(error) ? error : [error];
                        for (let i = 0; i < errorArr.length; i += 1) {
                            if (errorArr[i].body.message.includes(TFERRORLABEL)) {
                                showAddNotesError = true;
                                break;
                            }
                        }
                        if (showAddNotesError)
                            Toast.showError(this, AdditionalNotesErrorLabel);
                        else
                            Toast.showError(this, error);
                    })
                    .finally(() => {
                        this.redVariant = '';
                        this.toggleSpinner(false);
                        refreshApex(this.refreshTable);
                    });
        }
    }

    toggleSpinner(isVisible) {
        this.loading = isVisible;
    }

    feeValueChanged(event) {
        this.taxesAndFees = this.taxesAndFees.map(item => {
            var temp = Object.assign({}, item);
            if (temp.Id === event.target.id.split('-')[0]) {
                this.redVariant = (this.redVariant != 'destructive') ? 'destructive' : this.redVariant;
                if (event.target.name == 'value')
                    temp.AITM_Value__c = event.target.value;
                else if (event.target.name == 'AITM_Select_to_Apply_in_Contract__c')
                    temp.AITM_Select_to_Apply_in_Contract__c = event.target.checked;
            }
            return temp;
        });
    }

    newFeeChanged(event) {
        this.taxesAndFees = this.taxesAndFees.map(item => {
            var temp = Object.assign({}, item);
            if (temp.isNew && (event.target.accessKey == temp.Key)) {
                temp.Name = event.target.name == 'Name' ? event.target.value : temp.Name;
                temp.AITM_Compulsory_Conditional__c = event.target.name == 'AITM_COMP_COND__c' ? event.target.value : temp.AITM_COMP_COND__c;
                temp.AITM_COMP_COND__c = event.target.name == 'AITM_COMP_COND__c' ? event.target.value : temp.AITM_COMP_COND__c;
                temp.AITM_Fuel_Type__c = event.target.name == 'AITM_Fuel_Type__c' ? event.target.value : temp.AITM_Fuel_Type__c;
                temp.AITM_Unit_of_measure__c = event.target.name == 'AITM_Unit_of_measure__c' ? event.target.value : temp.AITM_Unit_of_measure__c;
                temp.AITM_Display_Currency__c = event.target.name == 'CurrencyIsoCode' ? event.target.value : temp.AITM_Display_Currency__c;
                temp.AITM_Select_to_Apply_in_Contract__c = event.target.name == 'AITM_Select_to_Apply_in_Contract__c' ? event.target.checked : temp.AITM_Select_to_Apply_in_Contract__c;
                temp.AITM_Value__c = event.target.name == 'AITM_Value__c' ? event.target.value : temp.AITM_Value__c;
            }
            return temp;
        });
    }

    updateCurrencyAsBlank() {
        this.taxesAndFees = this.taxesAndFees.map(item => {
            var temp = Object.assign({}, item);
            if (temp.isNew && temp.AITM_Unit_of_measure__c && temp.AITM_Display_Currency__c && temp.AITM_Unit_of_measure__c.includes('%')) {
                temp.AITM_Display_Currency__c;
            }
            return temp;
        });
    }

    checkUOMAndCurrencyValidation() {
        for (let i = 0; i < this.taxesAndFees.length; i += 1) {
            if (this.taxesAndFees[i].isNew
                && !this.taxesAndFees[i].AITM_Display_Currency__c
                && !this.taxesAndFees[i].AITM_Unit_of_measure__c.includes('%')
            ) {
                this.boolIsError = true;
                Toast.showError(this, CURRENCYVALIDATIONLABEL);
            }
        }
    }

    filterUpdatedFees() {
        for (let i = 0; i < this.existingTaxesAndFees.length; i += 1) {
            for (let j = 0; j < this.updatedFees.length; j += 1) {
                if (this.existingTaxesAndFees[i].Id == this.updatedFees[j].Id
                    && this.existingTaxesAndFees[i].isFreezed && this.updatedFees[j].isFreezed
                    && (this.taxesAndFees[j].AITM_Select_to_Apply_in_Contract__c != this.existingTaxesAndFees[i].AITM_Select_to_Apply_in_Contract__c
                        ||
                        this.taxesAndFees[j].AITM_Value__c != this.existingTaxesAndFees[i].AITM_Value__c
                    )
                ){
                    this.updatedFees[j].AITM_Manually_Saved_Tax__c = true;
                    this.selectedUpdatedFees.push(this.updatedFees[j]);
                }
            }
        }
    }

    duplicateTaxesAndFees() {
        for (let i = 0; i < this.existingTaxesAndFees.length; i += 1) {
            for (let j = 0; j < this.taxesAndFees.length; j += 1) {
                if (this.taxesAndFees[j].isNew
                    &&
                    (
                        (
                            this.taxesAndFees[j].AITM_Unit_of_measure__c.includes('%')
                            &&
                            this.taxesAndFees[i].AITM_Unit_of_measure__c.includes('%')
                        )
                        ||
                        (
                            this.taxesAndFees[j].AITM_Unit_of_measure__c == this.existingTaxesAndFees[i].AITM_Unit_of_measure__c
                            && this.taxesAndFees[j].AITM_Display_Currency__c == this.existingTaxesAndFees[i].AITM_Display_Currency__c
                        )
                    )
                    && this.taxesAndFees[j].AITM_Fuel_Type__c == this.existingTaxesAndFees[i].AITM_Fuel_Type__c
                    && this.taxesAndFees[j].Name == this.existingTaxesAndFees[i].Name
                    && this.taxesAndFees[j].AITM_Compulsory_Conditional__c == this.existingTaxesAndFees[i].AITM_Compulsory_Conditional__c) {
                    this.boolIsError = true;
                    Toast.showError(this, DUPLICATETAXLABEL);
                }
            }
        }
    }

    updateCurrencyAsBlank() {
        this.taxesAndFees = this.taxesAndFees.map(item => {
            var temp = Object.assign({}, item);
            if (temp.isNew && temp.AITM_Unit_of_measure__c && temp.AITM_Unit_of_measure__c.includes('%')) {
                temp.AITM_Display_Currency__c = '';
            }
            return temp;
        });
    }

    refreshTimeline(event) {
        const buttonIcon = event.target.querySelector('.slds-button__icon');
        buttonIcon.classList.add('refreshRotate');
        return refreshApex(this.refreshTable)
            .then((result) => {
                buttonIcon.classList.remove('refreshRotate');
                this.toggleSpinner(false);
            });
    }

    removeFee(event) {
        let taxesAndFees = this.taxesAndFees;
        let feeIndex;
        for (let i = 0; i < taxesAndFees.length; i++) {
            if (event.target.accessKey == taxesAndFees[i].Key)
                feeIndex = i;
        }
        taxesAndFees.splice(feeIndex, 1);
        this.shuffleIndexing();
    }

    shuffleIndexing() {
        var count = 0;
        this.taxesAndFees = this.taxesAndFees.map(item => {
            var temp = Object.assign({}, item);
            temp.Key = count;
            count++;
            return temp;
        });
    }
}