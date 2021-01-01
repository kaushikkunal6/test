({
    doInit : function(component) {
        var selectedRound = (component.get("v.selectedRound") != null? component.get("v.selectedRound").slice(6) : 1);
        var selectedCountry = component.get("v.selectedCountry");
        this.initializeCountryDetailResults(component, component.get("v.recordId"), selectedCountry, selectedRound);
    },

    initializeCountryDetailResults : function(component, tenderId, countryName, roundNumber) {
        
        var action = component.get("c.initializeCountryDetailResults");
        action.setParams({
            "tenderId": tenderId,
            "countryName": countryName,
            "roundNumber": roundNumber
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                
                component.set("v.tenderLocationCurrencies", returnValue.optionsCurrency);
                component.set("v.tenderLocationUoms", returnValue.optionsUom);
                component.set("v.tenderLocationStatuses", returnValue.optionsStatus);
                component.set("v.locations", returnValue.results);
                this.disableSpinner(component);
            }

        });
        $A.enqueueAction(action);
    },

    loadLocationDetails : function(component, tenderId, selectedCountry, filter, roundNumber) {
        var action = component.get("c.getLocationItemDetailsForCountry");

        action.setParams({
            "tenderId": tenderId,
            "countryName": selectedCountry,
            "filter": filter,
            "roundNumber": roundNumber
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                component.set("v.locations", returnValue, null);
                this.disableSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },

    handleSave : function(component) {
        this.toggleSpinner(component);
        var locationItemResults = component.get("v.locations");
        var action = component.get("c.save");
        action.setParams({
            "countryDetailLineItemResults": JSON.stringify(locationItemResults)
        });
       
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (returnValue && returnValue.length > 0) {
                    this.showErrors(returnValue);
                } else {
                    this.showToast("success", "Success!", "Records saved");
                    component.set("v.location",null);
                    component.set("v.selectedCountry",null);
                    $A.get('e.force:refreshView').fire();
                }

                this.disableSpinner(component);
            }

        });
        $A.enqueueAction(action);        
    },

    showErrors: function(response){
        this.showToast('error', response);
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

    handleRoundEvent : function(component, event) {
        this.toggleSpinner(component);
        component.set("v.selectedFilter", event.getParam("filter"));
        component.set("v.selectedRound", event.getParam("roundNumber"));
        this.clearGetParams();
        var selectedCountry = component.get("v.selectedCountry");
        this.loadLocationDetails(component, event.getParam("tenderId"), selectedCountry, null, event.getParam("roundNumber"));
    },

    handleFilterEvent : function(component, event) {
        this.toggleSpinner(component);
		var selectedCountry = component.get("v.selectedCountry");
        this.loadLocationDetails(component, event.getParam("tenderId"), selectedCountry, null, event.getParam("roundNumber"));
    },

    handleViewSObject : function(component, event) {
        var target = event.target || event.srcElement;
        var recordId = target.getAttribute("data-recordid");
        var evt = $A.get("e.force:navigateToSObject");
        evt.setParams({
           "recordId": recordId,
           "slideDevName": "detail"
        });
        evt.fire();
    },

    handleChangeStageEvent : function(component, event) {
        this.refreshView();
    },

    preventDefault : function(event) {
        event.stopPropagation();
        event.preventDefault();
    },

    containsIgnoreCase : function(source, searchTerm) {
        return source && source.toLowerCase().indexOf(searchTerm) > -1;
    },

    toggleSpinner : function(component) {
        var spinner = component.find("relatedLocationSpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },

    disableSpinner : function(component) {
        var spinner = component.find("relatedLocationSpinner");
        $A.util.addClass(spinner, "slds-hide");
    },

    refreshView : function() {
        $A.get('e.force:refreshView').fire();
    },

    changeRevisedOfferLocation: function(component, event) {
        if(event.getSource) {
            var target = event.getSource(); 
            var targetValue = event.getSource().get("v.value") ;
            var targetText = event.getSource().get("v.text") ;
            var locationItems = component.get('v.locations');
            
            for (var idx = 0; idx < locationItems.length; idx++) {
                
                if (locationItems[idx].locationIdentificator == targetText) {
                    locationItems[idx].includeRevisedOffer = targetValue;
                }
            }   
            component.set("v.locations",locationItems);   
        }
    }
})