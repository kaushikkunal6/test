({
    doInit : function(component) {
        this.loadLocationDetails(component);
    },

    loadLocationDetails : function(component) {
        var tenderId = component.get("v.recordId");
        var action = component.get("c.getTenderLocations");
        action.setParams({
            "tenderId": tenderId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (returnValue) {
                    component.set("v.tenderLocationLineItems", returnValue);
                    component.set("v.allLocationOption", returnValue[0]);
                    component.set("v.selectedCustomerId", null);
                    component.set("v.searchLocked", false);
                    component.set("v.validationError", false);
                }
            }
        });
        $A.enqueueAction(action);
    },

    validateAccountDetails : function(component, event) {
        var accountId = component.get("v.selectedCustomerId");
		var selectedElement = event.getSource().get("v.name");
        var action = component.get("c.validateTenderAccountWithRelatedData");
        action.setParams({
            "accountId": accountId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (returnValue) {
                    component.set("v.validationMessage", false);
                    this.saveTenderAccountWithRelatedData(component);
                     if(selectedElement === "Save") {
                        this.close(component);
                     } else if (selectedElement === "SaveAndNew") {
                        this.doInit(component);
                        this.reset(component);
                        this.resetSearchTerm(component);
                        this.refreshView();
                     }
                } else {
                    component.set("v.validationMessage", true);
                  }
            }
        });
        $A.enqueueAction(action);
    },

    search : function(component, helper, event) {
        var searchTerm = component.get("v.searchTerm");

        if (searchTerm && searchTerm.length > 1) {
            var action = component.get("c.searchCustomers");
            action.setParams({
                "key": searchTerm,
                "tenderId": component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    var returnValue = response.getReturnValue();
                    if (returnValue) {
                        helper.handleSearchResults(returnValue, component);
                    } else {
                        helper.reset(component);
                    }
                }
            });
            $A.enqueueAction(action);     
        } else {
            helper.reset(component);
        }

        if (component.get("v.searchLocked")) {
            this.unlockSearch(component);
        }
    },

    handleSearchResults : function(result, component) {
        component.set("v.customers", result);
    },

    selectCustomer : function(component, event) {
        this.lockSearch(component);
        var selectedElement = event.currentTarget;
        component.set("v.selectedCustomerId", selectedElement.id);
        component.set("v.customers", null);
        component.set("v.searchTerm", selectedElement.getAttribute("data-label"));
    },

    showDetails : function(component, event) {
        var componentToToggleId = event.getSource().get("v.name");
        if (componentToToggleId) {
            var componentToToggle = component.find(componentToToggleId);
            $A.util.toggleClass(componentToToggle, "display-none");
        }
    },

    toggleAllLocationDetails : function(component) {
        var allLocationOption = component.get("v.allLocationOption");
        component.set("v.allLocationDetailsVisible", allLocationOption.isSelected);
    },

    resetVolume : function(component, event) {
        var volumeToResetId = event.getSource().get("v.name").replace("adHocVolume", "");
        var isSetToAdHoc = event.getSource().get("v.value");
        
        if (isSetToAdHoc && volumeToResetId) {
            var tenderLocations = component.get("v.tenderLocationLineItems");
            for (var index = 0; index < tenderLocations.length; index++) {
                if (tenderLocations[index].accountId === volumeToResetId) {
                    tenderLocations[index].volume = 0;
                }
            }

            component.set("v.tenderLocationLineItems", tenderLocations);
        }
    },

    resetAllVolume : function(component) {
        //var allLocationsOption = component.get("v.allLocationOption.volume");
        //allLocationOption.volume = 0;
        component.set("v.allLocationOption.volume", 0);
    },

    save : function(component) {
        if (this.locationsValid(component)) {
            this.saveTenderAccountWithRelatedData(component);
        } else {
            component.set("v.validationError", true);
        }
    },

    saveAndNew : function(component, event) {
        if(this.locationsValid(component)){
            this.validateAccountDetails(component,event);
        } else {
        component.set("v.validationError", true);
        }
    },

    locationsValid : function(component) {
        component.set("v.validationError", false);
        var tenderLocations = component.get("v.tenderLocationLineItems");
        for (var index = 0; index < tenderLocations.length; index++) {
            if (!tenderLocations[index].isSelected || (tenderLocations[index].volume || tenderLocations[index].adHocVolume)) {
                continue;
            } else {
                return false;
            }
        }
        return true;
    },

    saveTenderAccountWithRelatedData : function(component) {
        if (!component.get("v.saveLocked")) {
            var self = this;
            self.toggleSaveLock(component);
            var allLocationOption = component.get("v.allLocationOption");
            var tenderLocations = component.get("v.tenderLocationLineItems");
            var accountId = component.get("v.selectedCustomerId");
            for (var index = 0; index < tenderLocations.length; index++) {
                var tenderLocation = tenderLocations[index];
				if (allLocationOption.isSelectedAll) {
					tenderLocations[index].isSelected = true;
					tenderLocations[index].volume = allLocationOption.volume;
					tenderLocations[index].adHocVolume = allLocationOption.adHocVolume;
					tenderLocations[index].startDate = allLocationOption.startDate;
					tenderLocations[index].endDate = allLocationOption.endDate;
				} else {
					if(tenderLocation.isSelected){
					  tenderLocations[index].isSelected = true;
					  tenderLocations[index].volume = tenderLocation.volume;
					  tenderLocations[index].adHocVolume = tenderLocation.adHocVolume;
					  tenderLocations[index].startDate = tenderLocation.startDate;
					  tenderLocations[index].endDate = tenderLocation.endDate;
					}
				}
                tenderLocations[index].accountId = accountId;
            }

            var action = component.get("c.saveTenderAccountWithRelatedData");
            action.setParams({
                "jsonLocations": JSON.stringify(tenderLocations),
                "accountId": accountId,
                "tenderId": component.get("v.recordId")
            });
            action.setCallback(this, function(response){
                self.toggleSaveLock(component);
            });
            $A.enqueueAction(action);
        }
    },
    
    saveAndClose : function(component, event) {
        if (this.locationsValid(component)){
            this.validateAccountDetails(component, event);
        } else {
            component.set("v.validationError", true);
        }
    },

    close : function() {
        this.refreshView();
        this.closeModalWindow();
    },

    refreshView : function() {
        var refreshView = $A.get('e.force:refreshView');
        refreshView.fire();
    },

    closeModalWindow : function() {
        var closeAction = $A.get("e.force:closeQuickAction");
        closeAction.fire();
        var dismissActionPanel = $A.get("e.c:AITM_ClosePathQuickAction"); 
        dismissActionPanel.fire();
    },

    reset : function(component, backspaceClicked) {
        component.set("v.customers", null);
        component.set("v.selectedCustomerId", null);
		component.set("v.validationError", false);
    },

    resetSearchTerm : function(component) {
        component.set("v.searchTerm", null);
        component.find("locationsInput").set("v.value", null);
    },

    lockSearch : function(component) {
        component.set("v.searchLocked", true);
    },

    unlockSearch : function(component) {
        component.set("v.searchLocked", false);
    },

    toggleSaveLock : function(component) {
        component.set("v.saveLocked", !component.get("v.saveLocked"));
    }
})