({
   doInit: function (component) {
     var tenderId = component.get("v.recordId");
         var action = component.get("c.getTenderStage");
        action.setParams({
            "tenderId": tenderId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();                
                if (returnValue != 'Awaiting Price' && returnValue !='Tender Created')
                {    
                    
                    this.showToastMessage("error","Error",'Please navigate to Awaiting Price stage & Mark as current stage to make these changes');
                    this.close(component);
                }else{
                    
                     this.loadTenderAccounts(component);
                     this.loadTenderLocationLineItems(component);
                    
                }
            }
        });
        
        $A.enqueueAction(action);
    },

    loadTenderLocationLineItems : function(component) {
        var action = component.get("c.getTenderLocationLineItems");
        action.setParams({
            "tenderId": component.get("v.recordId")
        });
		
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (returnValue) {
                    component.set("v.tenderLocationLineItems", returnValue);
                }
            }
        });

        $A.enqueueAction(action);     
    },
    
    filterSelect : function(component) {
  	  var selectAccount = component.find('existingCustomerInput');
      var currentAccountId = selectAccount.get("v.value");  
      component.set("v.oldAccountId", currentAccountId);
    },
    
    loadTenderAccounts : function(component) {
        var tenderId = component.get("v.recordId");
        var action = component.get("c.getTenderAccountCustomers");
        action.setParams({
            "tenderId": tenderId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (returnValue) {
                    component.set("v.tenderCustomers", returnValue);
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

    saveTenderAccountWithRelatedData : function(component) {
        if (!component.get("v.saveLocked")) {
            var self = this;
            self.toggleSaveLock(component);
            var tenderId = component.get("v.recordId");
            var selectCustomer = component.find("existingCustomerInput");
            var existingAccountId = selectCustomer.get("v.value");
            component.set("v.oldAccountId", existingAccountId);
            var newAccountId = component.get("v.selectedCustomerId");
            self.updateLineItems(component, newAccountId, existingAccountId, tenderId);
        }
    },
    
    updateLineItems : function(component, accountId, existingAccountId, tenderId) {
        var self = this;
        var tenderLocationLineItems = component.get("v.tenderLocationLineItems");           
        for (var index = 0; index < tenderLocationLineItems.length; index++) {
            if(existingAccountId == tenderLocationLineItems[index].accountId) {
                tenderLocationLineItems[index].accountId = accountId;
            }    
        }
        
        var action = component.get("c.saveTenderAccountWithRelatedData");
        action.setParams({
            "jsonLocations": JSON.stringify(tenderLocationLineItems),
            "accountId": accountId,
            "oldAccountId": existingAccountId,
            "tenderId": tenderId
        });
        action.setCallback(this, function(response){
            self.toggleSaveLock(component);
        });
        
        $A.enqueueAction(action);
    },

    saveAndClose : function(component) {
        this.saveTenderAccountWithRelatedData(component);
        this.close(component);
    },

    close : function() {
        this.refreshView();
        this.closeModalWindow();
    },

    refreshView : function() {
        $A.get('e.force:refreshView').fire();
    },

    closeModalWindow : function() {
         $A.get("e.force:closeQuickAction").fire(); 
    },

    reset : function(component, backspaceClicked) {
        component.set("v.customers", null);
        component.set("v.selectedCustomerId", null);
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