({
    doInit: function(component) {
        this.getTenderLocation(component);
        this.getFieldsAccess(component);
    },
    
    getTenderLocation: function(component) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getTenderLocation");
        
        action.setParams({
            "tenderLocationId": recordId
        });
        
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === 'SUCCESS'){
                component.set("v.tenderLocation", actionResult.getReturnValue());
            }     
        }); 
        
        $A.enqueueAction(action);  
    },
    
    getFieldsAccess: function(component) {
        var action = component.get("c.getFieldsAccess");
        action.setParams({
          "objectName": "AITM_Tender_Location__c"
      });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === 'SUCCESS'){
                var result = actionResult.getReturnValue();
                component.set("v.fieldsAccess", result);
            } 
            
        }); 
        
        $A.enqueueAction(action);  
    },
    
    saveFormValues: function(component, event) {
        this.toggleSpinner(component);
        this.updateRecord(component);
        this.hideEditBlock(component);
        this.addClass(component, 'form-element', 'slds-has-divider--bottom');
    },
    
    canceEditForm: function(component, event) {
        this.hideEditBlock(component);
        this.addClass(component, 'form-element', 'slds-has-divider--bottom');
    },
        
    updateRecord: function(component) {
        var action = component.get("c.updateTenderLocation");
        var tenderLocation = component.get('v.tenderLocation');
        
        action.setParams({
            "tenderLocation": tenderLocation
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.showToast('success', 'Record updated!');
                $A.get('e.force:refreshView').fire();
            }else{
                this.showErrors(response);
            }
            this.toggleSpinner(component);
        });
        
        $A.enqueueAction(action);
    },
    
    toggleToEdit: function(component){
        this.toggleClass(component, 'toggle-text-block', 'slds-hide');
        this.toggleClass(component, 'toggle-edit-block', 'slds-hide');
        this.toggleClass(component, 'form-element', 'slds-has-divider--bottom');
    },
    
    hideEditBlock: function(component){
        this.removeClass(component, 'toggle-text-block', 'slds-hide');
        this.addClass(component, 'toggle-edit-block', 'slds-hide');
    },
    
    toggleClass: function(component, auraId, toggleClass) {
        var element = component.find(auraId);
        if(Array.isArray(element)){
            for(var i=0; i<element.length; i++){
                $A.util.toggleClass(element[i], toggleClass);
            }
        }else{
            $A.util.toggleClass(element, toggleClass);
        } 
    },
    
    removeClass: function(component, auraId, toggleClass) {
        var element = component.find(auraId);
        if(Array.isArray(element)){
            for(var i=0; i<element.length; i++){
                $A.util.removeClass(element[i], toggleClass);
            }
        }else{
            $A.util.removeClass(element, toggleClass);
        } 
    },
    
    addClass: function(component, auraId, toggleClass) {
        var element = component.find(auraId);
        if(Array.isArray(element)){
            for(var i=0; i<element.length; i++){
                $A.util.addClass(element[i], toggleClass);
            }
        }else{
            $A.util.addClass(element, toggleClass);
        } 
    },  
    
    showErrors: function(response){
        var errors = response.getError()[0];
        if(typeof errors.pageErrors != 'undefined' && errors.pageErrors.length > 0){
            for(var i=0; i<errors.pageErrors.length; i++){
                this.showToast('error', errors.pageErrors[i].message);
            }
        }
    },
    
    showToast: function(type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: message,
            mode: "pester",
            duration: 500
        }); 
        toastEvent.fire();  
    },
    
    toggleSpinner : function(component) {
        var spinner = component.find("tenderLocationTaxesFeesSpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    }
    
})