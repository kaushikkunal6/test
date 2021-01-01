import { LightningElement, track, api , wire} from 'lwc';
import TFTAB_TITLE from '@salesforce/label/c.AITM_TFTabTitle';
import LOCATIONTAB_TITLE from '@salesforce/label/c.AITM_LocationTabTitle';
import PRICETAB_TITLE from '@salesforce/label/c.AITM_PriceTabTitle';
import VOLUMETAB_TITLE from '@salesforce/label/c.AITM_VolumeTabTitle';
import CREDITTERMS_TITLE from '@salesforce/label/c.AITM_CreditTermsTitle';
import MORE_TITLE from '@salesforce/label/c.AITM_MoreTitle';
import DELIVERYPOINTTAB_TITLE from '@salesforce/label/c.AITM_DeliveryTabTitle';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { fireEvent } from 'c/pubsub';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { getRecord, updateRecord, getFieldValue } from 'lightning/uiRecordApi';
import STAGE_FIELD from '@salesforce/schema/AITM_Tender_Location__c.AITM_Stage__c';
import DEBRIEF_STAGE from '@salesforce/label/c.AITM_DebriefStage';

const TENDER_FIELDS = [STAGE_FIELD];

export default class AITM_TenderLocationCustomTabs extends NavigationMixin(LightningElement) {
    labels = {
        MORE_TITLE,
        TFTAB_TITLE,
        PRICETAB_TITLE,
        VOLUMETAB_TITLE,
        CREDITTERMS_TITLE,
        LOCATIONTAB_TITLE,
        DELIVERYPOINTTAB_TITLE,
    };

    @track showDefaultTab = true;

    @api applyOverlayScreen;

    @api currentTab;

    @api calledViaRefresh;

    @track tenderStage;

    isInDebrief;

    @track doPartialRefresh = true;

    @api
    get recordId() {
        return this.getAttribute('recordId');
    }

    set recordId(value) {
        this.setAttribute('recordId', value);
    }

    @api
    get holdLastSelectedTab() {
        return this.getAttribute('holdLastSelectedTab');
    }

    set holdLastSelectedTab(value) {
        this.setAttribute('holdLastSelectedTab', value);
    }

    @api
    get calledViaAuraRefresh() {
        return this.getAttribute('calledViaAuraRefresh');
    }

    set calledViaAuraRefresh(value) {
        this.setAttribute('calledViaAuraRefresh', value);
    }

    @api
    get lineId() {
        return this.getAttribute('lineId');
    }

    set lineId(value) {
        this.setAttribute('lineId', value);
        this.handleRefreshSubTabs();
    }

    @api
    close() {
        this.unregisterKeydownListener();
        this.template.querySelector('.overlay').
            classList.
            remove('maxWidthCSS');
            this.template.querySelector('.overlay').
            classList.
            add('minWidthCSS');
        this.showDefaultTab = true;
        this.applyOverlayScreen = false;
        const overlayevent = new CustomEvent('overlayevent', {applyOverlayScreen:this.applyOverlayScreen});
        this.dispatchEvent(overlayevent);
        fireEvent(this.pageRef, 'overlayevent', this.applyOverlayScreen);
        this.maintainCurrentTab();
    }

    @api
    open() {
        this.registerKeyDownListener();
    }

    @wire(CurrentPageReference) pageRef;

    handleCloseButtonClick() {
        this.close();
    }

    handleKeyDown = (event) => {
        if (event.key === 'Escape') this.close();
    }

    registerKeyDownListener() {
        window.addEventListener('keydown', this.handleKeyDown);
    }

    unregisterKeydownListener() {
        window.removeEventListener('keydown', this.handleKeyDown);
    }
   
    connectedCallback() {
        registerListener('refreshparent', this.callBackMethod, this);
    }

    renderedCallback() {
        this.maintainCurrentTab();
        this.calledViaAuraRefresh = this.calledViaAuraRefresh ? false : this.calledViaAuraRefresh;
    }

    callBackMethod(payload){
        this.calledViaRefresh = true;
        this.lineId = payload;
        const refreshaura = new CustomEvent('refreshaura', 
                                                { 
                                                    detail: this.lineId
                                                }
                                            );
        this.dispatchEvent(refreshaura);
    }

    handleChange(event){
        if(this.calledViaAuraRefresh != "true"){
            const value = event.target.value;
            const selectedtab = new CustomEvent('selectedtab', 
                                                    { 
                                                        detail: { value }
                                                    }
                                                );
            this.dispatchEvent(selectedtab);
        }
    }

    maintainCurrentTab(){ 
        if(this.holdLastSelectedTab)
            this.template.querySelector('lightning-tabset').activeTabValue = this.holdLastSelectedTab;
        this.calledViaRefresh = false;
    }

    openNav(event) {
        this.registerKeyDownListener();
        this.showDefaultTab = false;       
        this.template.querySelector('.overlay').
            classList.
            add('maxWidthCSS');
        this.applyOverlayScreen = true;
        const overlayevent = new CustomEvent('overlayevent', {
            applyOverlayScreen: this.applyOverlayScreen,
            tendorLocationId: this.recordId,
        });
        this.dispatchEvent(overlayevent);
        fireEvent(this.pageRef, 'overlayevent', this.applyOverlayScreen);
    }

    closeNav(event) {
        this.template.querySelector('.overlay').
            classList.
            remove('maxWidthCSS');
        this.showDefaultTab = true;
        this.applyOverlayScreen = false;
        const overlayevent = new CustomEvent('overlayevent', {applyOverlayScreen:this.applyOverlayScreen});
        this.dispatchEvent(overlayevent);
        fireEvent(this.pageRef, 'overlayevent', this.applyOverlayScreen);
    }

    handleScrollTop(){
        var scrollOptions = {
            left: 0,
            top: 0,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    }

    handleAuraRecordChange(){ 
        this.dispatchEvent(new CustomEvent('recordChange'));
    }

    handleRefreshSubTabs(){ 
        this.doPartialRefresh = true;
        this.dispatchEvent(new CustomEvent('refreshchild'));
    }

    @wire(getRecord, { recordId: '$recordId', fields: TENDER_FIELDS })
    wiredLine({ data }) {
        if (data) {
            this.tenderStage = getFieldValue(data, STAGE_FIELD);
            this.sendDebrief();
        }
    }
    
    sendDebrief(){
        this.isInDebrief = (this.tenderStage == DEBRIEF_STAGE) ? true : false;
        const debriefevent = new CustomEvent('debriefevent', 
                                                {   
                                                    detail: this.isInDebrief
                                                }
                                            );
        this.dispatchEvent(debriefevent);
        fireEvent(this.pageRef, 'debriefevent', this.isInDebrief);
    }
}