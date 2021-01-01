({
    
    validateAccountDetails : function(component, event) {
        var accountId = component.get("v.selectedGroupId");
		var selectedElement = event.getSource().get("v.name");
        var action = component.get("c.validateTenderAccountWithRelatedData");
        action.setParams({
            "accountId": accountId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (returnValue.length > 0) {
                    component.set("v.validationMessage", true);
                    component.set("v.invalidaccount",returnValue);
                }else {
                    component.set("v.validationMessage", false);
                    this.saveTenderAccountWithRelatedData(component);
                     if(selectedElement === "Save") {
                        this.close(component);
                     } 
                } 
            }
        });
        $A.enqueueAction(action);
    },

    search : function(component, helper, event) {
        var searchTerm = component.get("v.searchTerm");

        if (searchTerm && searchTerm.length > 1) {
            var action = component.get("c.searchGroups");
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
        component.set("v.groups", result);
        
    },

    selectGroup : function(component, event) {
        this.lockSearch(component);
        var selectedElement = event.currentTarget;
        component.set("v.selectedGroupId", selectedElement.id);
        component.set("v.groups", null);
        component.set("v.searchTerm", selectedElement.getAttribute("data-label"));
    },

   

     saveTenderAccountWithRelatedData : function(component) {
        if (!component.get("v.saveLocked")) {
            var self = this;
            self.toggleSaveLock(component);
            var accountId = component.get("v.selectedGroupId");
            var groupname = component.get("v.groups");
             var action = component.get("c.saveTenderAccountWithRelatedData");
            action.setParams({
                "accountId": accountId,
                "tenderId": component.get("v.recordId"),
                
            });
            action.setCallback(this, function(response){
                self.toggleSaveLock(component);
            });
            $A.enqueueAction(action);
        }
    },
    
  saveAndClose : function(component, event) {
        
            this.validateAccountDetails(component, event);
        
    },

    close : function() {
        this.refreshView();
        this.closeModalWindow();
    },

    refreshView : function() {
        $A.get('e.force:refreshView').fire();
    },

    closeModalWindow : function() {
        $A.get("e.c:AITM_ClosePathQuickAction").fire();
    },

    reset : function(component, backspaceClicked) {
        component.set("v.groups", null);
        component.set("v.selectedGroupId", null);
		
    },

    resetSearchTerm : function(component) {
        component.set("v.searchTerm", null);
        component.find("groupsInput").set("v.value", null);
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