import { LightningElement, api, track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import TOGGLE_LABEL from '@salesforce/label/c.AITM_TLToggleEnhancedLabel';

export default class AITM_RedirectToSummaryByCountry extends NavigationMixin(LightningElement) {
    labels = {
        TOGGLE_LABEL,
    }

    @track loading = true;

    tab_page_reference;

    @track toggle = false;

    @api
    get isToggleEnabled() {
        return this.getAttribute('isToggleEnabled');
    }

    set isToggleEnabled(value) {
        this.setAttribute('isToggleEnabled', value);
        this.toggle = this.isToggleEnabled;
    }

    @api
    get selectedRound() {
        return this.getAttribute('selectedRound');
    }

    set selectedRound(value) {
        this.setAttribute('selectedRound', value);
    }

    @api
    get tenderId() {
        return this.getAttribute('tenderId');
    }

    set tenderId(value) {
        this.setAttribute('tenderId', value);
    }

    connectedCallback(){
    }

    renderedCallback(){
        if(this.toggle === 'true'){
            this.navigateToTab();
        }
    }

    navigateToTab() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'AITM_SBC',
            },
        }); 
    }
}