({ 
    COMPONENT_NAME : "RelatedTenderLocationsHolder",

    doInit : function(component) {
        this.getBidsInBy(component);
        this.getFilterOptions(component);
        this.getRounds(component);
        this.displaySummaryByCountry(component);
        this.getTenderOldOrNew(component);
        this.fetchCurrentUser(component);
    },
	
    getTenderOldOrNew : function(component) {
        var tenderId = component.get("v.recordId");
        var action = component.get("c.getTenderOldOrNew");
        action.setParams({
            "tenderId": tenderId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (returnValue) {
                    component.set("v.NewTaxesTender", returnValue.AITM_Select_to_Apply_Old_Taxes_and_Fees__c);
                }
            }
        });
        $A.enqueueAction(action);
    },


    onFilterChange : function(component) {
        this.onFilterChangeBase(component, this.COMPONENT_NAME);
    },
    
    deleteRound : function(component){
        var tenderId = component.get("v.recordId");
        var roundNumber = component.get("v.selectedRound").slice(6);
        if(roundNumber!='1'){
        var action = component.get("c.deleteRounds");
        action.setParams({
            "tenderId": tenderId,
            "currentRoundNumber": roundNumber 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                     this.showToast("success", "Success! Selected Round Deleted", "Deleted the round");
                     $A.get('e.force:refreshView').fire(); 

            }
        });
           $A.enqueueAction(action);
          }
          else{
            this.showToast("error", "Error! Round 1 Can't be deleted", "Round 1 can't be deleted");
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

    search : function(component) {
        var helper = this;
        this.searchBase(component, this.COMPONENT_NAME, helper, function(searchTerm, helper) {
            helper.fireSearchEvent(searchTerm);
        }, function(component, helper) {
            helper.onFilterChange(component);
        });
    },

    getBidsInBy : function(component) {
        var tenderId = component.get("v.recordId");
        var action = component.get("c.getBidsInBy");
        action.setParams({
            "tenderId": tenderId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (returnValue) {
                    component.set("v.bidsInBy", returnValue);
                }
            }
        });
        $A.enqueueAction(action);
    },

    getFilterOptions : function(component) {
        this.getFilterOptionsBase(component, this.COMPONENT_NAME);
    },

    getRounds : function(component) {
        var action = component.get("c.getRoundsOptions");
        var tenderId = component.get("v.recordId");
        var selectedFilter = component.get("v.selectedFilter");

        action.setParams({
            "tenderId": tenderId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (returnValue) {
                    component.set("v.roundOptions", returnValue);
                    component.set("v.selectedRound", returnValue[0]);
                }
            }
        });
        $A.enqueueAction(action);
    },

    fireFiltersEvent : function(component, filter) {
        var tenderId = component.get("v.recordId");
        var roundNumber = component.get("v.selectedRound").slice(6);

        var evt = $A.get("e.c:AITM_RelatedRecordsFilterEvent");
        evt.setParams({
            "filter": filter,
            "roundNumber": roundNumber,
            "tenderId": tenderId
        }); 
        evt.fire(); 
    },

    fireSearchEvent : function(searchTerm) {
        var evt = $A.get("e.c:AITM_RelatedRecordsSearchEvent");
        evt.setParams({
            "searchTerm": searchTerm
        }); 
        evt.fire();
    },

    resetFilterOption : function(component) {
        component.set("v.selectedFilter", component.get("v.selectedFilter"));
        this.getRounds(component);
    },

    displaySummaryByCountry: function(component) {
        var action = component.get("c.getDisplaySummaryByCountry");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (returnValue) {
                    component.set("v.displaySummaryByCountry",returnValue);
                }
            }
        });
        $A.enqueueAction(action);
    },
	
	generateRefreshTaxes:function(component,event,helper){
        var tenderId = component.get("v.recordId");
        var action = component.get("c.getTenderOldOrNew");
        action.setParams({
            "tenderId": tenderId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();  
                var tenderStage = returnValue.AITM_Stage__c;
                var numberOfLocations = returnValue.AITM_Number_Of_Locations__c;
                var refreshBatchRunning = returnValue.AITM_Refresh_Batch_Running__c;
                if(tenderStage == "Debrief" || tenderStage == "Closed"){         
                   this.showToast("error", "Please move back to 'Feedback and Negotiation' stage or any prior stages to Refresh T&Fs and then proceed to Debrief");          
                }else if(numberOfLocations == 0){
                    this.showToast("error", "There are no locations in the tender. Please add locations before refreshing taxes and fees");         
                }else if(refreshBatchRunning){
                    this.showToast("error", "A batch of refresh is currently under process, please try again later");
                }else{
                    this.createComponent(component,"c:AITM_RefreshTaxes");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    createComponent : function(component, componentName) {
        var modalBody;
        this.closePopup(component);
        var self = this;
        $A.createComponent(componentName, 
            {recordId: component.get("v.recordId")},
             function(content, status) {
                if (status === "SUCCESS") {
                    modalBody = content;
                    component.find('overlayLib').showCustomModal({
                        body: modalBody, 
                        showCloseButton: true,
                        cssClass: "mymodal",
                        closeCallback: function() {
                            //alert('You closed the alert!');
                        }
                    }).then(function (overlay) {
                        self.closePopup(component);
                        component.set('v.overlayPanel', overlay);
                    });
                }
        });
    },
    
    closePopup : function(component) {
        var overlay1 = component.get('v.overlayPanel');
        setTimeout(function() {
            if (overlay1) { 
                overlay1.close();
            } 
        }, 200);
    },
    
    fetchCurrentUser : function(component) {
		var action = component.get("c.fetchCurrentUserDetails");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.toggleView", storeResponse.AITM_SBC_Enhanced_Version__c);
                component.set("v.doPartialRefresh", true);
            }
        });
        $A.enqueueAction(action);
	}
})