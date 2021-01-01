({
    doInit : function(component) {
        this.loadLocationDetails(component);
    },
    
    loadLocationDetails : function(component) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getAddCurrentTenderAccount");
        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(response.getReturnValue() == ''){
                component.set("v.customerAddFlag", true);
            }
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.tenderLocationWrapper", response.getReturnValue());
                component.set("v.validationError", false);
            }
        });
        $A.enqueueAction(action);
    },

    showDetails : function(component, event) {
        var items = [];
        var componentToToggleId = event.getSource().get("v.value");
        
        items.push({
            'Id': componentToToggleId
        });
        component.set("v.customerToAdd", componentToToggleId);
        
        if (componentToToggleId) {
            var componentToToggle = component.find("accountId");
            $A.util.toggleClass(componentToToggle, "display-none");
        }
    },

    resetVolume : function(component, event) {
        
        var volumeToResetId = event.getSource().get("v.name");
        var isSetToAdHoc = event.getSource().get("v.value");
        //var volumeToResetId = event.getSource().get("v.value");
        //var checkVolume = component.find("adHocVolume");
        //var isSetToAdHoc = checkVolume.get("v.checked");
        
        if (isSetToAdHoc && volumeToResetId) {
            var tenderLocations = component.get("v.tenderLocationWrapper");
            for (var index = 0; index < tenderLocations.length; index++) {
                if (tenderLocations[index].accountId === volumeToResetId) {
                    tenderLocations[index].volume = 0;
                }
            }

            component.set("v.tenderLocationWrapper", tenderLocations);
        }
    },
    
    saveAndClose : function(component) {
        if (this.locationsValid(component)) {
            this.saveTenderAccountWithRelatedData(component);
            this.close(component);
        } else {
            component.set("v.validationError", true);
        }
    },

    locationsValid : function(component) {
        component.set("v.validationError", false);
        var tenderLocations = component.get("v.tenderLocationWrapper");
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
            var tenderLocations = component.get("v.tenderLocationWrapper");
            var action = component.get("c.saveTenderAccountWithRelatedData");
            action.setParams({
                "jsonLocations": JSON.stringify(tenderLocations)
            });
            action.setCallback(this, function(response){
                self.toggleSaveLock(component);
                this.showCustomerAddedSuccess('Success',  response.getReturnValue());
                //this.close(component);
            });
            $A.enqueueAction(action);
        }
    },
    
    showCustomerAddedSuccess : function(response){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
        title: "Success!",
        message: "Customer(s) were added to the Tender Location",
        type: "success"
        });
        toastEvent.fire();
    },

    close : function() {
        this.showCustomerAddedSuccess();
        this.refreshView();
        this.closeModalWindow();
    },
    
    refreshView : function() {
        var refreshAction = $A.get('e.force:refreshView');
        refreshAction.fire();
    },
    
    closeModalWindow : function() {
        var closeAction = $A.get("e.force:closeQuickAction");
        console.log('closeAction', closeAction);
        closeAction.fire();
        var dismissActionPanel = $A.get("e.c:AITM_ClosePathQuickAction"); 
        dismissActionPanel.fire();
    },
    
    toggleSaveLock : function(component) {
        component.set("v.saveLocked", !component.get("v.saveLocked"));
    }
})