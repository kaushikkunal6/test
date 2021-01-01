({ 
    doInit : function(component) {
        this.getFilterOptions(component);
    },

    getFilterOptions : function(component) {
        var action = component.get("c.getFilterOptions");

        action.setParams({
            "tenderId": component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (returnValue) {
                    component.set("v.filterOptions", returnValue);
                    component.set("v.selectedFilter", returnValue[0].accountId);
                }
            }
        });
        $A.enqueueAction(action);
    },
	
    onFilterChange: function(component) {
  	  var selectFilter = component.find('filter');
      var selectFilterValue = selectFilter.get("v.value");  
      component.set("v.selectedFilter", selectFilterValue);
  	},
    
    generate : function(component) {
        var action = component.get("c.attachOfferDocuments");
        var helper = this;
        this.toggleSpinner(component);

        action.setParams({
            "tenderId": component.get("v.recordId"),
            "accountId": component.get("v.selectedFilter")
        });

        action.setCallback(this, function(response) {
            helper.refreshView();
            helper.showToast('success', 'Success!', $A.get("$Label.c.AITM_ContractPDFGenerationSuccess"));
            helper.toggleSpinner(component);
            helper.close();
        });
        $A.enqueueAction(action);
    },
    
    generateContractAfterRefresh : function(component) {
        var action = component.get("c.refreshAndGenerateContract");
        var helper = this;
        this.toggleSpinner(component);

        action.setParams({
            "tenderId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
			this.checkStateForContract(component, helper); 
        });
        $A.enqueueAction(action);
    },
   
   checkStateForContract: function(component, helper) {
      this.checkForContractTFRecords(component, helper);
      var self = this;
      var setIntervalState = window.setInterval(
          $A.getCallback(function() {
              self.checkForContractTFRecords(component, helper, setIntervalState);
          }), 2000
      );
   },
   
   checkForContractTFRecords: function(component, helper, setIntervalState) {
       var action = component.get("c.checkForContract");
       if (action) {
           action.setCallback(this, function(response) {
               var state = response.getState();
               if (component.isValid() && state === "SUCCESS") {
                   var result = response.getReturnValue();
                   if (result.indexOf("DONE") > -1) {
                       if(result == 'DONE'){
                           helper.refreshView();
                           //helper.showToast('success', 'Success!', $A.get("$Label.c.AITM_ContractPDFGenerationSuccess"));
                           helper.toggleSpinner(component);
                           helper.generate(component);
                           helper.close();
                       }
                   }
               }
           });
           $A.enqueueAction(action);
       } else {
           clearInterval(setIntervalState);
       }
   },
	
   showToast : function(type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": message
        });
        
        toastEvent.fire(); 
    },

    refreshView : function() {
        $A.get('e.force:refreshView').fire();
    },

    toggleSpinner : function(component) {
        var spinner = component.find("loaderSpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },

    close : function() {
        $A.get("e.c:AITM_ClosePathQuickAction").fire();
    }
})