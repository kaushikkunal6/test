({
  	doInit: function(component) {
  	  this.getTenderLocation(component);
      this.populatePicklistValues(component);
      this.getFieldsAccess(component); 
  	},

    populatePicklistValues: function(component) {
      let auraIdToFieldName = component.get('v.auraIdToFieldName');
      if(typeof auraIdToFieldName != 'undefined'){
        this.getPicklistValues(component, 'AITM_Tender_Location__c', auraIdToFieldName);
      }
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
            let tenderLocation = actionResult.getReturnValue();
            component.set("v.tenderLocation", tenderLocation);
            this.setIsCurrentRound(component, tenderLocation);
            this.getRounds(component, tenderLocation.AITM_Round__c);
          }     
       }); 

      $A.enqueueAction(action);  
    },

    setIsCurrentRound: function(component, tenderLocation) {
      var isCurrentRound = false;

      if(tenderLocation.AITM_Round__c == tenderLocation.AITM_Current_Round__c){
        isCurrentRound = true;
      }
      component.set('v.isCurrentRound', isCurrentRound);
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

    onRoundChange: function(component) {
      var recordId = component.get("v.recordId");
      var select = component.find('rounds');
      var roundNumber = select.get("v.value").slice(6);
      var action = component.get("c.getTenderLocationForRound");

      action.setParams({
          "tenderLocationId": recordId,
          "roundNumber": roundNumber
      });

      action.setCallback(this, function(actionResult) {
          var state = actionResult.getState();
          if (state === 'SUCCESS'){
            component.set("v.tenderLocation", actionResult.getReturnValue());
            this.setIsCurrentRound(component, actionResult.getReturnValue());
          }else{
            console.log(actionResult.getError());
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

    getPicklistValues: function(component, targetObject, auraIdToFieldName){
      
        var action = component.get("c.getPickValues");

        action.setParams({
            "objectName": targetObject,
            "auraIdToFieldName": auraIdToFieldName
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
              this.pupulatePicklists(component, response.getReturnValue())
            }else{
              console.log(response.getError());
            }
            
        });

        $A.enqueueAction(action);   
    },

    pupulatePicklists: function(component, auraIdToValues){
      for(var auraId in auraIdToValues){
          var select = component.find(auraId);
          var value = select.get('v.value');
          var picklistValues = auraIdToValues[auraId];
          var options = [];
          for(var i = 0; i<picklistValues.length; i++){
              var option = {
                  value: picklistValues[i],
              }
              if(picklistValues[i] == value){
                  option['selected'] = "true";
              }
              options.push(option);
          }
          if (options.length > 0) {
              select.set('v.options', options)
          }
      }
    },

    getRounds : function(component, selectedRound) {
        var action = component.get("c.getRoundsOptions");
        var tenderLocationId = component.get("v.recordId");

        action.setParams({
            "tenderLocationId": tenderLocationId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                
                if(returnValue) {
                	component.set("v.roundOptions", returnValue);
                	component.find('rounds').set("v.value", returnValue[0]);
                }
                if(component.find('rounds').get("v.value") != 'undefined') {
                	this.onRoundChange(component);
                }
            } else {
                  showErrors(response);
             }
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

    toggleSpinner: function(component) {
      var spinner = component.find("tenderLocationFeedbackSpinner");
      $A.util.toggleClass(spinner, "slds-hide");
    },

    showFormButtons: function(component){
        this.addClass(component, 'toggle-text-block', 'slds-hide');
        this.removeClass(component, 'toggle-edit-block', 'slds-hide');
        this.removeClass(component, 'form-element', 'slds-has-divider--bottom');
    },

    toggleSection: function(component, event) {
      let sectionId = event.currentTarget.getAttribute('aria-controls');
      
      let sectionContainer = component.find(sectionId + '-container');
      let sectionIcon = component.find(sectionId + '-icon');

      let sectionButton = document.getElementById(sectionId + '-button');
      let sectionContent = document.getElementById(sectionId);

      let wantsToClose = $A.util.hasClass(sectionContainer, "slds-is-open");

      if(wantsToClose){
        sectionButton.setAttribute('aria-expanded', false);
        sectionContent.setAttribute('aria-hidden', true);
      }else{
        sectionButton.setAttribute('aria-expanded', true);
        sectionContent.setAttribute('aria-hidden', false);
      }

      if($A.util.hasClass(sectionIcon, 'rotate-left')){
        $A.util.toggleClass(sectionIcon, 'rotate-down');
      }else{
        $A.util.toggleClass(sectionIcon, 'rotate-left');
      }

      $A.util.toggleClass(sectionContainer, "slds-is-open");

    }

})