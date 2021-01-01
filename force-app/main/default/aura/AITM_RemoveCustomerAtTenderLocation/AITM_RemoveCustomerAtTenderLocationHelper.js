({
    doInit : function(component) {
        this.loadLocationDetails(component);
    },
    
    loadLocationDetails : function(component) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getRemoveCurrentTenderAccount");
        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(response.getReturnValue() == ''){
                component.set("v.customerRemove", true);
            }
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.tenderLocationWrapper", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    showDetails : function(component, event) {
        var items = [];
        var componentToToggleId = event.getSource().get("v.name");
        if(componentToToggleId != null) {
            component.set("v.isWarningMsg", true);
        }
        items.push({
            'Id': componentToToggleId
        });
        component.set("v.customerToRemove", componentToToggleId);
        if (componentToToggleId) {
            
            var componentToToggle = component.find(componentToToggleId);
            $A.util.toggleClass(componentToToggle, "display-none");
        }
    },
    
    deleteAndClose : function(component, event) {
            this.deleteRecords(component);
            this.close(component);
    },
    
    deleteRecords: function(component) {
            var selected = component.get('v.customerToRemove');
            var tenderLocations = component.get("v.tenderLocationWrapper");
            var action = component.get("c.deleteRecords");
            action.setParams({
                "jsonLocations": JSON.stringify(tenderLocations)
            });
       
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
             if (response.getReturnValue() != null) {
                    this.showToast('error', 'Record can not be deleted.' + response.getReturnValue());      
                } 
                this.showCustomerRemovedSuccess('Success',  response.getReturnValue());
                 this.closeModalWindow();
                $A.get('e.force:refreshView').fire();
                component.set("v.removeConfirmation", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    showCustomerRemovedSuccess : function(response){
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
    title: "Success!",
    message: "Customer(s) were removed to the Tender Location",
    type: "success"
    });
    toastEvent.fire();
  },

    locationsValid : function(component) {
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

    close : function() {
        this.closeModalWindow();
        this.refreshView();
    },

    refreshView : function() {
        $A.get('e.force:refreshView').fire();
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
    closeModalWindow : function() {
        var closeAction = $A.get("e.c:AITM_ClosePathQuickAction");
        closeAction.fire();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },

    toggleSaveLock : function(component) {
        component.set("v.saveLocked", !component.get("v.saveLocked"));
    }
})