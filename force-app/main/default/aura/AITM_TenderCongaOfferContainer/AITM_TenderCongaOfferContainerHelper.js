({
  doInit: function(component) {
    this.getFilterOptions(component);
    this.getFilterCustomerOptions(component);
  },

  getFilterOptions: function(component) {
    var action = component.get("c.getFilterOptions");
    var tenderId = component.get("v.recordId");
    action.setParams({
        "tenderId": tenderId
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (component.isValid() && state === "SUCCESS") {
        var returnValue = response.getReturnValue();
        if (returnValue) {
          component.set("v.filterOptions", returnValue);
          component.set("v.selectedFilter", JSON.stringify(returnValue[0].name));
          var getAllLocations = component.get("v.selectedFilter");
          getAllLocations = (getAllLocations.replace("\"", "")).replace("\"", "");
          component.set("v.selectedFilter", getAllLocations);
        }
      }
    });
    $A.enqueueAction(action);
  },
  
  getFilterCustomerOptions: function(component) {
    var action = component.get("c.getFilterCustomerOptions");
    var tenderId = component.get("v.recordId");
    action.setParams({
        "tenderId": tenderId
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (component.isValid() && state === "SUCCESS") {
        var returnValue = response.getReturnValue();
        if (returnValue) {
          component.set("v.filterCustomerOptions", returnValue);
          component.set("v.selectedCustomerFilter", returnValue[0].tenderAccountId);
          component.set("v.selectedCustomerName", returnValue[0].name);
          component.set("v.selectedLeadAffiliate", returnValue[0].accountId);
          component.set("v.tenderName", returnValue[0].tenderName);
          component.set("v.reseller", returnValue[0].reseller);
          component.set("v.selectedBSpokeTemplate", returnValue[0].bSpokeTemplate);
          component.set("v.oldTaxFeeFlag", returnValue[0].oldTaxFeeFlag);
		  component.set("v.grnNumber", returnValue[0].grn);
          component.set("v.labpUrl", returnValue[0].labpUrl);
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
  
  onFilterCustomerChange: function(component) {
  	  var selectFilter = component.find('filterCustomer');
      var selectCustomerFilterValue = selectFilter.get("v.value");
      component.set("v.selectedCustomerFilter", selectCustomerFilterValue);
      var accountOptions = component.get("v.filterCustomerOptions");
      
      for(var item in accountOptions) {
          if(accountOptions[item].tenderAccountId == selectCustomerFilterValue) {
              component.set("v.reseller", accountOptions[item].reseller);
              component.set("v.selectedLeadAffiliate", accountOptions[item].accountId);
              component.set("v.selectedCustomerName", accountOptions[item].name);
              component.set("v.selectedBSpokeTemplate", accountOptions[item].bSpokeTemplate);	
              component.set("v.oldTaxFeeFlag", accountOptions[item].oldTaxFeeFlag);    
              component.set("v.labpUrl", accountOptions[item].labpUrl);
			  component.set("v.grnNumber", accountOptions[item].grn);
              break;
          }
      }
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
            this.generateCongaOfferWithRefresh(component, event, helper);
        }
   },
    
  generateCongaOfferWithRefresh: function(component, event, helper) {
    var action = component.get("c.generateCongaOfferWithRefresh");
    var helper = this;
    this.toggleSpinner(component);

    action.setParams({
      "tenderId": component.get("v.recordId")
    });
    action.setCallback(this, function(response) {
      this.checkStateForCongaOffer(component, event, helper);
    });
    $A.enqueueAction(action);
  },
    
  checkStateForCongaOffer: function(component, event, helper) {
    helper.checkForCongaOffer(component, event, helper);
    var self = this;
    var setIntervalState = window.setInterval(
      $A.getCallback(function() {
        self.checkForCongaOffer(component, event, helper, setIntervalState);
      }), 2000
    );
  },
    
  checkForCongaOffer: function(component, event, helper, setIntervalState) {
    var action = component.get("c.checkForCongaOffer");
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
  },
  
  generate : function(component, event, helper)  {
    var tenderId = component.get("v.recordId"); 
    var action = component.get("c.getFilterQueryDetails");
    var tenderName = component.get("v.tenderName");
    var customerName = component.get("v.selectedCustomerName");
    var customerId = component.get("v.selectedCustomerFilter");
    var selectBSpoke = component.get("v.selectedBSpokeTemplate");
    var selectAffiliate = component.get("v.selectedLeadAffiliate");
    var reseller = component.get("v.reseller");
    var oldTaxFeeFlag = component.get("v.oldTaxFeeFlag");
    var optionSelection = component.get("v.offerSelection");
    var grnNumber = component.get("v.grnNumber");
    var isWordDoc = component.get("v.isWordDoc");
    this.toggleSpinner(component);
    
    action.setParams({
        "filterName": component.get("v.selectedFilter"),
        "tenderId": tenderId,
        "selectedCustomerId":customerId,
        "tenderName":tenderName,
        "selectedCustomerName":customerName,
        "selectedAffiliate":selectAffiliate,
        "bspokeTemplate":selectBSpoke,
        "reseller":reseller,
        "oldTaxFeeFlag":oldTaxFeeFlag,
        "offerSelection":optionSelection,
        "grnNumber":grnNumber,
        "isWordDoc":isWordDoc
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (component.isValid() && state === "SUCCESS") {
        var returnValue = response.getReturnValue();  
        
        if(returnValue) {
          
          this.generateDocuments(component, event, helper, returnValue);
        }
      }
    });
    $A.enqueueAction(action);       
  },
   
  generateDocuments: function(component, event, helper, urlParam) {
	var urlEvent = $A.get("e.force:navigateToURL");
    var congaURL1 = $A.get("$Label.c.AITM_CongaButtonURLPatch1");
    var labpUrl = component.get("v.labpUrl");
    var action = component.get("c.createOfferLegalDocument");
          action.setParams({
              "tenderId": component.get("v.recordId"),
              "isWordDoc":component.get("v.isWordDoc")
          });  
          action.setCallback(this, function(response){
             var state = response.getState();
             
             if(component.isValid() && state === "SUCCESS") {
                 var workspaceAPI = component.find("workspace");
                 if(labpUrl !='') {
                     this.congaForLABP(component, event, urlParam);
                } else {
                  urlEvent.setParams({
                    "url": congaURL1 + urlParam
                });
                }
                 urlEvent.fire();
                 workspaceAPI.getFocusedTabInfo().then(function(response) {
                     var focusedTabId = response.tabId;
                     
                     this.checkState(component, helper, fileNameShort);
                     //Closing old one
                     workspaceAPI.closeTab({tabId: focusedTabId});
                 })
                 .catch(function(error) {
                     
                 });
				 if(labpUrl !='') {	
                     helper.close();	
                     helper.refreshView();	
                 }
             } 
          });    
      $A.enqueueAction(action);       
  },  
    
  checkState: function(component, helper, fileNameShort) {
    this.check(component, helper, fileNameShort);
    var self = this;
    var setIntervalState = window.setInterval(
      $A.getCallback(function() {
        self.check(component, helper, fileNameShort, setIntervalState);
      }), 2000
    );
  },
  
  check: function(component, helper, fileNameShort, setIntervalState) {
    var action = component.get("c.check");
    var tenderId = component.get("v.recordId");  
    action.setParams({
        "tenderId": tenderId,
        "fileName": fileNameShort
    });
    if (action) {
      action.setCallback(this, function(response) {
        var state = response.getState();
  		
        if (component.isValid() && state === "SUCCESS") {
          var result = response.getReturnValue();
 		  	
          if (result) {
            if (result.indexOf("DONE") > -1) {
              helper.showToast('success', 'Success!', $A.get(
                "$Label.c.AITM_OfferPDFGenerationSuccess"));
              helper.toggleSpinner(component);
              helper.close();
              helper.refreshView();
            }
          }
        }
      });
      $A.enqueueAction(action);
    } else {
      clearInterval(setIntervalState);
    }
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
  
  showToast: function(type, title, message) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      "title": title,
      "type": type,
      "message": message
    });

    toastEvent.fire();
  },

  refreshView: function() {
    var refreshView = $A.get('e.force:refreshView');
    refreshView.fire();
  },

  toggleSpinner: function(component) {
    var spinner = component.find("loaderSpinner");
    $A.util.toggleClass(spinner, "slds-hide");
  },

  close: function() {
    var closeAction = $A.get("e.c:AITM_ClosePathQuickAction");
    closeAction.fire();
  }
})