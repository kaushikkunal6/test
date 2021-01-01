import { LightningElement, api, track, wire} from 'lwc';
import getLocationData from '@salesforce/apex/AITM_RelatedTenderLocationsSummaryCtrl.getLocationSummaryDetails';
import cloneSelectedLines from '@salesforce/apex/AITM_TenderLocationNewOffer.cloneRecords';
import deleteSelectedLines from '@salesforce/apex/AITM_TenderLocationNewOffer.deleteRecords';
import saveUpdatedLines from '@salesforce/apex/AITM_TenderLocationNewOffer.saveLines';
import doRevisionForSelectedLines from '@salesforce/apex/AITM_TenderLocationNewOffer.updateRecord';
import doPricingForSelectedLines from '@salesforce/apex/AITM_TenderLocationNewOffer.updateTenderLocationPricingBasis';
import doApplyTFForSelectedLines from '@salesforce/apex/AITM_TenderLocationNewOffer.ApplyToAllTaxesFeesMethod';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { refreshApex } from '@salesforce/apex';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { fireEvent } from 'c/pubsub';
import { Toast } from 'c/sharedUtils';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

export default class AITMLeftSummaryPage extends LightningElement {
    @track refreshTable;

    @track loading = true;

    @track locations = []; 

    @track updatedLines = [];

    @track tenderLocIds = [];

    noLineSelected = true;

    isRightSideDisabled = true;

    isApplyAllTFDisabled = true;

    toggleView = false;

    clickedCountry;

    slicedRound;

    lineIds = [];

    tickedOnes = [];

    tickedCountries = [];

    countries = [];

    boolIsError = false;

    rightPanelSelectedLineId;

    rightPanelSelectedCountry;

    rightPanelSelectedTenderLocId;

    hasPricingModalEnabled;

    hasApplyAllModalEnabled

    pricingEnabled;

    applyAllEnabled;

    calledViaPartialRefresh = false;

    hasExpandAll = false;

    expandAllEnabled = false;

    @wire(CurrentPageReference) pageRef;

    @api
    get lineId() {
        return this.getAttribute('lineId');
    }

    set lineId(value) {
        this.setAttribute('lineId', value);
    }

    @api
    get tenderId() {
        return this.getAttribute('tenderId');
    }

    set tenderId(value) {
        this.setAttribute('tenderId', value);
    }

    @api
    get selectedRound() {
        return this.getAttribute('selectedRound');
    }

    set selectedRound(value) {
        this.setAttribute('selectedRound', value);
    }

    toggleSpinner(isVisible) {
        this.loading = isVisible;
    }

    connectedCallback() {
        registerListener('passtickedones', this.handleTickedOnes, this);
        registerListener('togglespinner', this.disableToggleSpinner, this);
        registerListener('handlelinechange', this.callBackHandleLineChange, this);
        registerListener('refreshleftparent', this.callBackRefreshParent, this);
        registerListener('refreshsummary', this.refreshSummary, this);
        registerListener('sendrightpanelcountry', this.callBackHighlightForRightPanel, this);
    }

    callBackHighlightForRightPanel(payload){
        this.rightPanelSelectedCountry = payload[0].country;
        if(payload){
            this.rightPanelSelectedLineId = payload[0].lineId;
            this.rightPanelSelectedTenderLocId = payload[0].tenderLocId;
            this.isRightSideDisabled = false;
            this.isApplyAllTFDisabled = payload[0].isApplyAllDisabled;
        }
        this.locations = this.locations.map(item => {
            var temp = Object.assign({}, item);
            if (temp.country == this.rightPanelSelectedCountry)
                temp.hasHighlightedColor = true;
            else
                temp.hasHighlightedColor = false;
            return temp;
        });
    }

    callBackHandleLineChange(payload){
        this.filterSavedLines(payload);
    }

    filterSavedLines(currentUpdatedLine){
        if(!this.tenderLocIds){
            this.tenderLocIds.push(currentUpdatedLine[0].recordId);
        }
        else{
            if(!this.tenderLocIds.includes(currentUpdatedLine[0].recordId))
                this.tenderLocIds.push(currentUpdatedLine[0].recordId);
            else
                this.updatedLines.splice(this.updatedLines.findIndex(ins => ins.recordId === currentUpdatedLine[0].recordId));

        }
        this.updatedLines.push(currentUpdatedLine[0]);
    }

    handleSavedLines(event){
        this.toggleSpinner(true);
        this.boolIsError = false;
        this.validateLines();
        if(!this.boolIsError){
            saveUpdatedLines({
                lines: this.updatedLines,
            })
            .then((result) => {
                this.updatedLines = [];
                this.tenderLocIds = [];
            })
            .catch((error) => {
                Toast.showError(this, error);
            })
            .finally(() => {
                this.markedSelections = [];
                this.tickedOnes = [];
                this.boolIsError = false;
                this.noLineSelected = true;
                this.refreshLocations();
                this.isApplyAllTFDisabled = true;
                this.dummyRefreshRightPanel();
                this.toggleSpinner(false);
            });
        }
    }

    validateLines(){
        var errors = [];
        this.updatedLines.forEach((element) => {
            if (!element.AITM_Start_Date__c || !element.AITM_End_Date__c) {
                this.boolIsError = true;
                errors.push('Start Date or End Date cannot be null. Please review the dates.');
            } 
            else if(element.AITM_Start_Date__c >= element.AITM_End_Date__c) {
                this.boolIsError = true;
                errors.push('Start Date cannot be after the End Date. Please review the dates.');
            }
            else if(element.AITM_Start_Date__c >= element.AITM_End_Date__c) {
                this.boolIsError = true;
                errors.push('End Date cannot be before Start Date. Please review the dates.');
            }
        });
        if(errors.length > 0){
            Toast.showError(this, errors);
            this.toggleSpinner(false);
        }
    }

    dummyRefreshRightPanel(){
        const dummyrefreshchild = new CustomEvent
                                        (
                                            'dummyrefreshchild',
                                                {   
                                                    detail: ''
                                                }
                                        );
        this.dispatchEvent(dummyrefreshchild);
        fireEvent(this.pageRef, 'dummyrefreshchild', '');
    }

    dummyRefreshHighestVolumePage(){
        const refreshparent = new CustomEvent(
                                                'refreshparent', 
                                                        {
                                                            detail: ''
                                                        }
                                            );                                                       
        this.dispatchEvent(refreshparent);
        fireEvent(this.pageRef, 'refreshparent', '');
    }

    callBackRefreshParent(){
        this.calledViaPartialRefresh = true;
        refreshApex(this.refreshTable);
        this.template.querySelector('[data-id="revision-checkbox"]').checked = false;
        this.noLineSelected = true;
        this.markedSelections = [];
        this.isApplyAllTFDisabled = true;
        this.tickedOnes = [];
        this.toggleSpinner(false);
    }

    disconnectedCallback(){
        unregisterAllListeners(this);
    }
    renderedCallback(){
    }

    @wire(getLocationData, {
        tenderId: '$tenderId',
        filter: null,
        roundNumber: '$selectedRound'
    })
    
    wiredLocations(result){
        this.refreshTable = result;
        if (result.data) {
            if(!this.calledViaPartialRefresh)
                this.initializeLocations(result.data);
            else{
                this.callUpdatedLocations(result.data);
            }
            this.calledViaPartialRefresh = false;
            this.toggleSpinner(false);
        }
    }

    initializeLocations(locations){
        this.locations = [];
        let counter = 1;
        let countrySize = locations.length;
        locations.forEach(loc => {
            this.locations.push({
                Key: loc.Id,
                Name: loc.Name,
                recordId: loc.recordId,
                country: loc.country,
                totalNumberOfLocations: loc.totalNumberOfLocations,
                totalVolumeUSG: loc.totalVolumeUSG,
                totalOfferedVolumeUSG: loc.totalOfferedVolumeUSG,
                status: loc.status,
                hasExpandedEnabled: false,
                hasHighlightedColor: false,
                isLastCountry: this.hasReachedLastCountry(countrySize, counter)
            });
            counter += 1;
        });
    }

    hasReachedLastCountry(countrySize, currentSize){
        return (countrySize === currentSize ? true : false);
    }

    callUpdatedLocations(locations){
        var mapOfLocationsData = [];
        for(var key in locations){
            mapOfLocationsData.push(
                {
                    value : locations[key], 
                    key : locations[key].country
                }
            ); 
        }
        this.locations = this.locations.map(item => {
            var temp = Object.assign({}, item);
            var val = mapOfLocationsData.find(function(ins){ return ins.key == item.country });
            temp.status = val.value.status;
            temp.totalNumberOfLocations = val.value.totalNumberOfLocations;
            temp.totalVolumeUSG = val.value.totalVolumeUSG;
            temp.totalOfferedVolumeUSG = val.value.totalOfferedVolumeUSG;
            return temp;
        });
    }

    handleCountryClicks(event){
        var callHideRightPanel = false;
        var callRemoveCollapsedCountry = false;
        this.locations = this.locations.map(item => {
            var temp = Object.assign({}, item);
            if (temp.country == event.currentTarget.dataset.idx)
                temp.hasExpandedEnabled = !temp.hasExpandedEnabled;                
            return temp;
        });
        this.locations.forEach(item => {
            if(!item.hasExpandedEnabled){
                if(this.rightPanelSelectedCountry && event.currentTarget.dataset.idx == this.rightPanelSelectedCountry)
                    callHideRightPanel = true;   
                if(this.tickedOnes && event.currentTarget.dataset.idx == item.country)
                    callRemoveCollapsedCountry = true;
            }                   
        });
        if(callHideRightPanel)
            this.hideRightPanel();
        if(callRemoveCollapsedCountry)
            this.removeCollapsedCountry(event.currentTarget.dataset.idx);
    }

    removeCollapsedCountry(collapsedCountry){
        var linesToRemove = [];
        for (let i = 0; i < this.tickedOnes.length; i++) {
            var splittedVal = this.tickedOnes[i].split('-')[1];
            if(splittedVal == collapsedCountry)
                linesToRemove.push(this.tickedOnes[i]);
        }
        this.tickedOnes = this.tickedOnes.filter((i) => !linesToRemove.includes(i));
        this.calculateFreeze();
    }

    calculateFreeze(){
        this.noLineSelected = this.tickedOnes.length > 0 ? false : true;
    }

    splitCountries(){
        this.countries = [];
        this.markedSelections.forEach(ins => {
            var splittedVal = ins.split('-')[2];
            this.countries.push(
                splittedVal
            );
        });
    }

    handleExpandAllSelection(event){
        this.template.querySelector('[data-id="expand-checkbox"]').checked = event.target.checked;
        this.locations = this.locations.map(item => {
            var temp = Object.assign({}, item);
            temp.hasExpandedEnabled = event.target.checked;
            return temp;
        });
        if(!this.template.querySelector('[data-id="expand-checkbox"]').checked){
            this.noLineSelected = true;
            this.markedSelections = [];
            this.tickedOnes = [];
            this.hideRightPanel();
        }
    }

    handleCheckboxesSelection(event){
        if(event.target.name == 'Pricing_All')
            this.hasPricingModalEnabled = event.target.checked;
        if(event.target.name == 'Apply_All')
            this.hasApplyAllModalEnabled = event.target.checked;
    }

    closeModal(event){
        this.hasApplyAllModalEnabled = false;
        this.hasPricingModalEnabled = false;
        const checkboxElems = Array.from(this.template.querySelectorAll('lightning-input.master-checkbox'));
        checkboxElems.forEach((element) => {
            element.checked = false;
        });
    }

    handleFilters(event){
        this.toggleSpinner(true);
        this.handlePricing();
    }

    hideRightPanel(){
        this.isRightSideDisabled = true;
        const refreshsummaryrightpanel = new CustomEvent
                                                        (
                                                            'refreshsummaryrightpanel',
                                                                {   
                                                                    detail: ''
                                                                }
                                                        );
        this.dispatchEvent(refreshsummaryrightpanel);
        fireEvent(this.pageRef, 'refreshsummaryrightpanel', '');
    }

    refreshExpandAll(){
        const refreshexpand = new CustomEvent
                                        (   
                                            'refreshexpand',
                                                {
                                                    detail: this.hasExpandAll,
                                                }
                                        );
        this.dispatchEvent(refreshexpand);
        fireEvent(this.pageRef, 'refreshexpand', this.hasExpandAll);
    }

    handleNoRevision(event){
        if(event.target.checked){
            this.toggleSpinner(true);
            const handlerevision = new CustomEvent
                                                (   
                                                    'handlerevision',
                                                        {
                                                            detail: this.rightPanelSelectedTenderLocId,
                                                        }
                                                );
            this.dispatchEvent(handlerevision);
            fireEvent(this.pageRef, 'handlerevision', this.rightPanelSelectedTenderLocId);
        }
    }   

    handlePricing(){
        this.toggleSpinner(true);
        var newTenderLocation = [];
        newTenderLocation.push({
            Id : this.rightPanelSelectedTenderLocId,
            'sobjectType' : 'AITM_Tender_Location__c'
        });
        doPricingForSelectedLines({
            tenderLocation: newTenderLocation[0],
        })
        .then((result) => {

        })
        .catch((error) => {
            Toast.showError(this, error);
        })
        .finally(() => {
            this.refreshLocations();
            this.dummyRefreshRightPanel();
            this.markedSelections = [];
            this.tickedOnes = [];
            this.isApplyAllTFDisabled = true;
            this.hasApplyAllModalEnabled = false;
            this.hasPricingModalEnabled = false;
            this.template.querySelector('.pricing-checkbox').checked = false;
            const checkboxElems = Array.from(this.template.querySelectorAll('lightning-input.master-checkbox'));
            checkboxElems.forEach((element) => {
                element.checked = false;
            });
            
            this.toggleSpinner(false);
        });
    }

    handleApplyTF(){
        this.toggleSpinner(true);
        var newTenderLocation = [];
        newTenderLocation.push({
            Id : this.rightPanelSelectedTenderLocId,
            'sobjectType' : 'AITM_Tender_Location__c'
        });
        doApplyTFForSelectedLines({
            tenderLocation: newTenderLocation[0],
        })
        .then((result) => {

        })
        .catch((error) => {
            Toast.showError(this, error);
        })
        .finally(() => {
            this.refreshLocations();
            this.dummyRefreshRightPanel();
            this.markedSelections = [];
            this.tickedOnes = [];
            this.isApplyAllTFDisabled = true;
            this.hasApplyAllModalEnabled = false;
            this.hasPricingModalEnabled = false;
            const checkboxElems = Array.from(this.template.querySelectorAll('lightning-input.master-checkbox'));
            checkboxElems.forEach((element) => {
                element.checked = false;
            });
            this.toggleSpinner(false);
        });
    }

    splitLineIds(){
        this.lineIds = [];
        this.tickedOnes.forEach(line => {
            var splittedVal = line.split('-')[0];
            this.lineIds.push(
                splittedVal
            );
        });
    }

    handleCloning(event){
        this.toggleSpinner(true);
        this.splitLineIds();
        cloneSelectedLines({
            cloneRecordId: this.lineIds,
        })
        .then((result) => {
            if(result)
                Toast.showError(this, result);
        })
        .catch((error) => {
            Toast.showError(this, error);
        })
        .finally(() => {
            this.markedSelections = [];
            this.tickedOnes = [];
            this.noLineSelected = true;
            this.refreshLocations();
            this.isApplyAllTFDisabled = true;
            this.toggleSpinner(false);
        });
    }

    refreshLocations(){
        const refreshlocations = new CustomEvent
                                        (   
                                            'refreshlocations',
                                                {
                                                    detail: '',
                                                }
                                        );
        this.dispatchEvent(refreshlocations);
        fireEvent(this.pageRef, 'refreshlocations', '');
    }

    handleDeletion(event){
        this.toggleSpinner(true);
        this.splitLineIds();
        deleteSelectedLines({
            lstRecordId: this.lineIds,
        })
        .then((result) => {
            if(result)
                Toast.showError(this, result);
        })
        .catch((error) => {
            Toast.showError(this, error);
        })
        .finally(() => {
            this.markedSelections = [];
            this.tickedOnes = [];
            this.noLineSelected = true;
            this.refreshLocations();
            this.isApplyAllTFDisabled = true;
            this.toggleSpinner(false);
        });
    }

    handleTickedOnes(payload){
        if(payload){
            switch (payload[0].operation) {
                case 'add': {
                    if(!this.tickedOnes.includes(payload[0].lineId + '-' + payload[0].country))
                        this.tickedOnes.push(payload[0].lineId + '-' + payload[0].country);
                    break;
                }
                case 'remove': {
                    if(this.tickedOnes.includes(payload[0].lineId + '-' + payload[0].country))                  
                        this.tickedOnes.splice(this.tickedOnes.findIndex(ins => ins === (payload[0].lineId + '-' + payload[0].country)), 1);
                    break;
                }
            }
        }
        this.calculateFreeze();
    }

    disableToggleSpinner(payload){
        this.toggleSpinner(false);
    }
}