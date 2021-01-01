({
    doInit : function(component) {
       
        this.loadLocationsDetails(component);
       
    },
    canceEditForm: function(component, event) {
      this.hideEditBlock(component);
      this.addClass(component, 'form-element', 'slds-has-divider--bottom');
    },
    hideEditBlock: function(component){
        this.removeClass(component, 'toggle-text-block', 'slds-hide');
        this.addClass(component, 'toggle-edit-block', 'slds-hide');
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
    
     saveFormValues: function(component, event) {
      this.toggleSpinner(component);
      this.updateRecord(component);
      this.hideEditBlock(component);
      this.addClass(component, 'form-element', 'slds-has-divider--bottom');
    },
    hideEditBlock: function(component){
        this.removeClass(component, 'toggle-text-block', 'slds-hide');
        this.addClass(component, 'toggle-edit-block', 'slds-hide');
    },
    updateRecord: function(component) {
        var newServiceLevel = component.find("SelectedCustomerServiceLevel");
        var latest = newServiceLevel.get("v.value");
        
        var tenderLocation = component.get('v.tenderLocation');
       // alert(tenderLocation.AITM_LM_Comments__c);
        
        
        //var approveCheckBoc = event.target.checked;
        var whetherUpdated = component.get("v.approveChecked");
        //alert(whetherUpdated);
        var action = component.get("c.updateTenderLocation");       
        
        
       
        
        action.setParams({
            "tenderLocation": tenderLocation,
            //"approveCheckBoc" :approveCheckBoc,
            "latest":latest,
            
            "whetherUpdated":whetherUpdated
            
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //this.showToast('success', 'Record updated!');
                
            }else{
                //this.showErrors(response);
            }
            //this.toggleSpinner(component);
            window.location.reload(); 
        });

        $A.enqueueAction(action);
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
      var spinner = component.find("tenderLocationUpdateSpinner");
      $A.util.toggleClass(spinner, "slds-hide");
    },
    toggleToEdit: function(component){
        this.toggleClass(component, 'toggle-text-block', 'slds-hide');
        this.toggleClass(component, 'toggle-edit-block', 'slds-hide');
        this.toggleClass(component, 'form-element', 'slds-has-divider--bottom');
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
    
     toggleSection: function(component,event) {
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

    },
    

    loadLocationsDetails : function(component) {
        var tenderLocationId = component.get("v.recordId");
        var action = component.get("c.getLocations");
        action.setParams({
            "tenderLocationId": tenderLocationId
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
           var result = response.getReturnValue();
            if(result!=null){
           component.set("v.tenderLocation", result[0]);
            }
           
            
               
                          
                    
                
            
        });
        $A.enqueueAction(action);
    },
    
    refreshView: function() {
    $A.get("e.force:refreshView").fire();
  },
    
    showFormButtons: function(component){
        this.addClass(component, 'toggle-text-block', 'slds-hide');
        this.removeClass(component, 'toggle-edit-block', 'slds-hide');
        this.removeClass(component, 'form-element', 'slds-has-divider--bottom');
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
})