import { LightningElement, api, track, wire } from 'lwc';
import { registerListener, unregisterAllListeners ,fireEvent} from 'c/pubsub';
import { NavigationMixin, CurrentPageReference} from 'lightning/navigation';
import AITM_AVIATIONFIRSTBPImg from '@salesforce/resourceUrl/AITM_AviationFirstBPImg';
import AITM_AVIATIONSECONDBPImg from '@salesforce/resourceUrl/AITM_AviationSecondBPImg';
import AITM_AVIATIONTHIRDBPImg from '@salesforce/resourceUrl/AITM_AviationThirdBPImg';
import AITM_AVIATIONFOURTHBPImg from '@salesforce/resourceUrl/AITM_AviationFourthBPImg';
import getPictures from '@salesforce/apex/AITM_TenderLocationService.getPictures';
import roundData from '@salesforce/apex/AITM_TenderLocationService.getRound';

export default class AITM_SplitterSummaryByCountry extends LightningElement {

    @wire(CurrentPageReference) pageRef;
 
    @track aviationFirstBPImg = AITM_AVIATIONFIRSTBPImg;
    @track aviationSecondBPImg = AITM_AVIATIONSECONDBPImg;
    @track aviationThirdBPImg = AITM_AVIATIONTHIRDBPImg;
    @track aviationFourthBPImg = AITM_AVIATIONFOURTHBPImg;

    toggleRight;

    urls;

    pictures;

    showLeft = false;

    header = 'Personalised Images';

    description = 'Displaying the personalised images as set by the Logged In User';

    @track loading = true;

    @track displayImages = true;

    @track displayTabs = false;

    @track selectedLineId;

    @track holdLastSelectedTab;

    @api tenderLocId;

    @api
    get lineId() {
        return this.getAttribute('lineId');
    }

    set lineId(value) {
        this.setAttribute('lineId', value);
    }

    @api
    recordId;

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

    get slicedRound(){
        return this.selectedRound.slice(6);
    }

    connectedCallback() {
        registerListener('refreshsummaryrightpanel', this.callBackMethod, this);
        registerListener('refreshtoggle', this.callBackAuraMethod, this);
        registerListener('selectedtab', this.maintainTabState, this);
        registerListener('dummyrefreshright',this.dummyRefreshRight, this)

        const { pathname } = new URL(window.location.href);

        if (pathname.includes('AITM_SBC')) {
            const queryString = window.location.search;
            const urlParams = new URLSearchParams(queryString);
            const product = urlParams.get('tenderId')
            const parts = queryString.split(`AITM_Tender__c%2F`)[1].substring(0,18);
            this.tenderId = parts;
            this.calculateLeft();
        }
    }

    dummyRefreshRight(){
        this.template.querySelector('c-a-i-t-m-_-tender-location-summary-custom-tabs').lineId(this.lineId);
    }

    maintainTabState(payload){
        this.holdLastSelectedTab = payload;
    }

    calculateLeft(){
        if(this.tenderId){
            roundData({
                tenderId: this.tenderId,
            })
            .then((result) => {
                this.selectedRound = result;
            })
            .catch((error) => {
            })
            .finally(() => {
                this.showLeft =  (this.tenderId && this.selectedRound) ? true : false;
                this.toggleSpinner(false);
            });
        }
    }

    renderedCallback(){
        this.toggleRight = false;
        let playStyle = document.createElement('style');
        playStyle.innerHTML = `.slds-carousel__autoplay{
            display: none;
        }`;
        document.head.appendChild(playStyle);
        let headerTabStyle = document.createElement('style');
        headerTabStyle.innerHTML = `header.flexipageHeader.slds-page-header.uiBlock.oneAnchorHeader{
            display: none !important;
            opacity: none !important;
        }`;
        document.head.appendChild(headerTabStyle);
    }

    get calculateLineId(){
        return this.selectedLineId ? true : false;
    }

    disconnectedCallback(){
        unregisterAllListeners(this);
    }

    callBackAuraMethod(payload){
        this.dispatchEvent(new CustomEvent('refreshtoggle'));
    }

    @wire(getPictures)
    wiredPictures(pictures) {
        this.pictures = pictures;
        if (pictures.data) {
            const files = pictures.data;
            if (Array.isArray(files) && files.length) {
                this.urls = files.map(
                    (file) =>
                        '/sfc/servlet.shepherd/version/download/' + file.Id
                );
            } else {
                this.urls = null;
            }
        }
    }

    toggleSpinner(isVisible) {
        this.loading = isVisible;
    }

    callBackMethod(payload){
        if(payload){
            this.selectedLineId = payload[0].lineId; 
            this.lineId = payload[0].lineId;
            this.tenderLocId = payload[0].tenderLocId;
        }
        else{
            this.selectedLineId = '';
            this.tenderLocId ='';
        }
    }
}