import { LightningElement, track, wire } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import USER_OBJECT from '@salesforce/schema/User';
import ENHANCED_VERSION_FIELD from '@salesforce/schema/User.AITM_SBC_Enhanced_Version__c';
import TOGGLE_LABEL from '@salesforce/label/c.AITM_TLToggleEnhancedLabel';
import { getRecord, updateRecord, getFieldValue } from 'lightning/uiRecordApi';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { fireEvent } from 'c/pubsub';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

export default class AITM_ToggleTenderLocationViewPage extends LightningElement {
    userObject = USER_OBJECT;

    @track isSpinnerVisible;

    @track loggedInUserId = USER_ID;

    @track selectedToggleValue;

    @wire(CurrentPageReference) pageRef;

    labels = {
        TOGGLE_LABEL,
    }

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [ENHANCED_VERSION_FIELD],
      }) wireuser({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.selectedToggleValue = getFieldValue(data, ENHANCED_VERSION_FIELD);
        }
    }

    handleChange(event){ 
        if(event.target.name == 'checkbox-toggle-18'){
            this.toggleSpinner(true);
            const fields = {};
            fields.Id = this.loggedInUserId;
            var toggleKey = event.target.checked;
            fields[ENHANCED_VERSION_FIELD.fieldApiName] = toggleKey;
            const recordInput = { fields };

            updateRecord(recordInput)
            .then(() => {
                if(toggleKey)
                    this.refreshAura();                      
                else    
                    this.refreshParent();
            })
            .catch((error) => {
            })
            .finally(() => {
                this.toggleSpinner(false);
            });
        }
    }  
    
    toggleSpinner(isVisible) {
        this.isSpinnerVisible = isVisible;
    }

    refreshAura(){
        this.dispatchEvent(new CustomEvent('refreshaura'));
    }

    refreshParent(){
    }
}