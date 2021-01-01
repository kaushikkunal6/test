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
              component.set("v.selectedCustomerFilter", returnValue[0].tenderAccountId);
              component.set("v.selectedCustomerName", returnValue[0].name);
              component.set("v.selectedLeadAffiliate", returnValue[0].accountId);
              component.set("v.tenderName", returnValue[0].tenderName);
              component.set("v.reseller", returnValue[0].reseller);
              component.set("v.selectedBSpokeTemplate", returnValue[0].bSpokeTemplate);
              component.set("v.oldTaxFeeFlag", returnValue[0].oldTaxFeeFlag);
              component.set("v.labpUrl", returnValue[0].labpUrl);
              component.set("v.grnNumber", returnValue[0].grn);
            }
          }
        });
        $A.enqueueAction(action);
    },
	
    onFilterChange: function(component) {
  	  var selectFilter = component.find('filter');
      var selectFilterValue = selectFilter.get("v.value"); 
      component.set("v.selectedCustomerFilter", selectFilterValue);
      var accountOptions = component.get("v.filterOptions");
     
      for(var item in accountOptions) {
          if(accountOptions[item].tenderAccountId == selectFilterValue) {
              component.set("v.reseller", accountOptions[item].reseller);
              component.set("v.selectedLeadAffiliate", accountOptions[item].accountId);
              component.set("v.selectedCustomerName", accountOptions[item].name);
              component.set("v.selectedBSpokeTemplate", accountOptions[item].bSpokeTemplate);
              component.set("v.labpUrl", accountOptions[item].labpUrl);	  
              component.set("v.grnNumber", accountOptions[item].grn);	  
              break;
          }
      }  
  	},
    
    generate : function(component, event, helper) {
        var tenderId = component.get("v.recordId"); 
        var tenderName = component.get("v.tenderName");
        var customerName = component.get("v.selectedCustomerName");
        var customerId = component.get("v.selectedCustomerFilter");
        var selectBSpoke = component.get("v.selectedBSpokeTemplate");
        var selectAffiliate = component.get("v.selectedLeadAffiliate");
        var reseller = component.get("v.reseller");
        var action = component.get("c.attachOfferDocuments");
        var optionSelection = component.get("v.contractSelection");
        var oldTaxFeeFlag = component.get("v.oldTaxFeeFlag");
        var labpUrl = component.get("v.labpUrl");
        var grnNumber = component.get("v.grnNumber");
        var isWordDoc = component.get("v.isWordDoc");
		
        var helper = this;
        this.toggleSpinner(component);

        action.setParams({
          "tenderId": tenderId,
          "selectedCustomerId":customerId,
          "tenderName":tenderName,
          "selectedCustomerName":customerName,
          "selectedAffiliate":selectAffiliate,
          "bspokeTemplate":selectBSpoke,
          "reseller":reseller,
          "contractSelection":optionSelection,
          "oldTaxFeeFlag":oldTaxFeeFlag,
          "grnNumber":grnNumber,
          "isWordDoc":isWordDoc
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
      		if (component.isValid() && state === "SUCCESS") {
        		var returnValue = response.getReturnValue(); 
                var congaURL1 = $A.get("$Label.c.AITM_CongaButtonURLPatch1");
                if(returnValue) {
            		var workspaceAPI = component.find("workspace");
                    var urlEvent = $A.get("e.force:navigateToURL");
                 if(labpUrl != '') {
                    this.congaForLABP(component, event, returnValue);
                 } else {
                    urlEvent.setParams({
                        "url": congaURL1 + returnValue
                    });
                 }   
                 
                 urlEvent.fire();
                 workspaceAPI.getFocusedTabInfo().then(function(response) {
                     var focusedTabId = response.tabId;
                     console.log(focusedTabId);
                     this.checkState(component, helper, fileNameShort);
                     //Closing old one
                     workspaceAPI.closeTab({tabId: focusedTabId});
                 })
                 .catch(function(error) {
                     console.log(error);
                 });
		            helper.refreshView();
        		    helper.showToast('success', 'Success!', $A.get("$Label.c.AITM_ContractPDFGenerationSuccess"));        
              }
            }  
            helper.toggleSpinner(component);
            helper.close();
        });
        $A.enqueueAction(action);
    },
	
    congaForLABP: function (component, event, urlParam) {	
        var labpUrl = component.get("v.labpUrl");	
        var navService = component.find("nav-service");	
        var pageReference = {	
            type: 'standard__webPage',	
            attributes: {	
                url : labpUrl + "/apex/AITM_OpenCongaForLABP?" + urlParam	
            }	
        };	
        event.preventDefault();	
        navService.navigate(pageReference);	
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
    },
    
    generatePopUp: function(component, event, helper) {
        var checkValue = false;
        var isOldTender = component.get('v.oldTaxFeeFlag');
        /*if(!isOldTender){
            checkValue = component.get("v.isRefreshForWord");
        }*/
        if(isOldTender || (!checkValue)){
            this.generate(component, event, helper);
        } else {
            this.generateCongaContractWithRefresh(component, event, helper);
        }
    },
    
    generateCongaContractWithRefresh: function(component, event, helper) {
    var action = component.get("c.generateCongaContractWithRefresh");
    var helper = this;
    this.toggleSpinner(component);

    action.setParams({
      "tenderId": component.get("v.recordId")
    });
    action.setCallback(this, function(response) {
        this.checkStateForCongaContract(component, event, helper);
    });
    $A.enqueueAction(action);
  },
    
  checkStateForCongaContract: function(component, event, helper) {
    helper.checkForCongaContract(component, event, helper);
    var self = this;
    var setIntervalState = window.setInterval(
      $A.getCallback(function() {
        self.checkForCongaContract(component, event, helper, setIntervalState);
      }), 2000
    );
  },
    
  checkForCongaContract: function(component, event, helper, setIntervalState) {
    var action = component.get("c.checkForCongaContract");
    if (action) {
      action.setCallback(this, function(response) {
        var state = response.getState();
  
        if (component.isValid() && state === "SUCCESS") {
          var result = response.getReturnValue();
          if (result) {
            if (result.indexOf("DONE") > -1) {
                if(result == 'DONE'){
                    helper.generate(component, event, helper);
                }
            }
          }
        }
      });
      $A.enqueueAction(action);
    } else {
      clearInterval(setIntervalState);
    }
  }
})