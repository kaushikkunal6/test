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
                    component.set("v.tenderLocations", returnValue);
                    component.set("v.selectedLocationId", null);
                    component.set("v.searchLocked", false);
                    component.set("v.validationError", false);
                }
            }
        });
        $A.enqueueAction(action);
    },

    search : function(component, helper, event) {
        var searchTerm = component.get("v.searchTerm");

        if (searchTerm && searchTerm.length > 1) {
            var action = component.get("c.searchLocations");
            action.setParams({
                "tenderId": component.get("v.recordId"),
                "key": searchTerm
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
        component.set("v.locations", result);
    },

    selectLocation : function(component, event) {
        this.lockSearch(component);
        var selectedElement = event.currentTarget;
        component.set("v.selectedLocationId", selectedElement.id);
        component.set("v.locations", null);
        component.set("v.searchTerm", selectedElement.getAttribute("data-label"));
    },

    showDetails : function(component, event) {
        var componentToToggleId = event.getSource().get("v.name");
        if (componentToToggleId) {
            var componentToToggle = component.find(componentToToggleId);
            $A.util.toggleClass(componentToToggle, "display-none");
        }
    },

    resetVolume : function(component, event) {
        var volumeToResetId = event.getSource().get("v.name").replace("adHocVolume", "");
        var isSetToAdHoc = event.getSource().get("v.value");
        
        if (isSetToAdHoc && volumeToResetId) {
            var tenderLocations = component.get("v.tenderLocations");
            for (var index = 0; index < tenderLocations.length; index++) {
                if (tenderLocations[index].accountId === volumeToResetId) {
                    tenderLocations[index].volume = 0;
                }
            }

            component.set("v.tenderLocations", tenderLocations);
        }
    },

    save : function(component) {
        if (this.locationsValid(component)) {
            this.upsertLocations(component);
        } else {
            component.set("v.validationError", true);
        }
    },

    saveAndNew : function(component) {
        if (this.locationsValid(component)) {
            this.upsertLocations(component);
            this.doInit(component);
            this.reset(component);
            this.resetSearchTerm(component);
            this.refreshView();
        } else {
            component.set("v.validationError", true);
        }
    },

    locationsValid : function(component) {
        component.set("v.validationError", false);
        var tenderLocations = component.get("v.tenderLocations");
        for (var index = 0; index < tenderLocations.length; index++) {
            if (!tenderLocations[index].isSelected || (tenderLocations[index].volume || tenderLocations[index].adHocVolume)) {
                continue;
            } else {
                return false;
            }
        }
        return true;
    },

    upsertLocations : function(component) {
        var tenderLocations = component.get("v.tenderLocations");
        var locationId = component.get("v.selectedLocationId");
        for (var index = 0; index < tenderLocations.length; index++) {
            tenderLocations[index].locationId = locationId;
        }

        var action = component.get("c.saveTenderLocations");
        action.setParams({
            "jsonLocations": JSON.stringify(tenderLocations),
            "tenderId": component.get("v.recordId")
        });
        action.setCallback(this, function(response){});
        $A.enqueueAction(action);        
    },
    
    saveAndClose : function(component) {
        if (this.locationsValid(component)) {
            this.upsertLocations(component);
            this.close(component);
        } else {
            component.set("v.validationError", true);
        }
    },

    close : function() {
        this.refreshView();
        this.closeModalWindow();
    },

    refreshView : function() {
        $A.get('e.force:refreshView').fire();
    },

    closeModalWindow : function() {
        //var dismissActionPanel = $A.get("e.force:closeQuickAction");
        //dismissActionPanel.fire();
        //$A.get("e.c:AITM_ClosePathQuickAction").fire();
        var closeAction = $A.get("e.c:AITM_ClosePathQuickAction");
        closeAction.fire();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },

    reset : function(component, backspaceClicked) {
        component.set("v.locations", null);
        component.set("v.selectedLocationId", null);
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
    } 
})