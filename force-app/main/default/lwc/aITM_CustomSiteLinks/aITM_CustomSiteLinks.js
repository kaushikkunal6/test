import { LightningElement, wire, track } from 'lwc';
import getCustomLinks from '@salesforce/apex/AITM_CustomSiteLinks.getCustomLinks';

export default class AITM_CustomSiteLinks extends LightningElement {
    @track sitelinks = [];
    @track error;

    @wire(getCustomLinks)
    wiredCustomLinks({ error, data }) {
        if (data) {
            for(let key in data) {
                // Preventing unexcepted data
                if (data.hasOwnProperty(key)) { // Filtering the data in the loop
                    this.sitelinks.push({key: key, value: data[key]});
                }
            }
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.sitelinks = undefined;
        }
    }
}