({
  doInit: function(component) {
    this.getFilterOptions(component);
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
          component.set("v.selectedFilter", returnValue[0]);
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
    
    generateOfferAfterRefresh: function(component) {
        var action = component.get("c.refreshAndGenerateOffer");
        var helper = this;
        this.toggleSpinner(component);
    
        action.setParams({
          "tenderId": component.get("v.recordId"),
          "selectedFilter": component.get("v.selectedFilter")
        });
        action.setCallback(this, function(response) {
          this.checkStateForTFRecords(component, helper);
        });
        $A.enqueueAction(action);
    },
    
  checkStateForTFRecords: function(component, helper) {
      this.checkForTFRecords(component, helper);
      var self = this;
      var setIntervalState = window.setInterval(
          $A.getCallback(function() {
              self.checkForTFRecords(component, helper, setIntervalState);
          }), 2000
      );
  },
    
  checkForTFRecords: function(component, helper, setIntervalState) {
      var action = component.get("c.checkForTFRecords");
      if (action) {
          action.setCallback(this, function(response) {
              var state = response.getState();
              if (component.isValid() && state === "SUCCESS") {
                  var result = response.getReturnValue();
                  if (result) { 
                      if (result.indexOf("DONE") > -1) {
                          //helper.showToast('success', 'Success!','TF Records refreshed');
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
    
  generate: function(component) {
    var action = component.get("c.attachOfferDocuments");
    var helper = this;
    this.toggleSpinner(component);

    action.setParams({
      "tenderId": component.get("v.recordId"),
      "selectedFilter": component.get("v.selectedFilter")
    });
    action.setCallback(this, function(response) {
      this.checkState(component, helper);
    });
    $A.enqueueAction(action);
  },
      
  checkState: function(component, helper) {
    this.check(component, helper);
    var self = this;
    var setIntervalState = window.setInterval(
      $A.getCallback(function() {
        self.check(component, helper, setIntervalState);
      }), 2000
    );
  },

  check: function(component, helper, setIntervalState) {
    var action = component.get("c.check");
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
    
  close: function() {
    var closeAction = $A.get("e.c:AITM_ClosePathQuickAction");
    closeAction.fire();
  },
    
  refreshAndGenerateOfferTFReport: function(component) {
    var tenderId = component.get("v.recordId");
    var action = component.get("c.refreshAndGenerateRefreshedOfferReport");
    var helper = this;
    this.toggleSpinner(component);
      
    action.setParams({
      "tenderId": tenderId
    });
    action.setCallback(this, function(response) {
        this.checkStateForOfferReport(component, helper);
    });
    $A.enqueueAction(action);
  },
    
  checkStateForOfferReport: function(component, helper) {
    helper.checkForOfferReport(component, helper);
    var self = this;
    var setIntervalState = window.setInterval(
      $A.getCallback(function() {
        self.checkForOfferReport(component, helper, setIntervalState);
      }), 2000
    );
  },

  checkForOfferReport: function(component, helper, setIntervalState) {
    var action = component.get("c.checkForTFRecordsForReport");
    if (action) {
      action.setCallback(this, function(response) {
        var state = response.getState();
  
        if (component.isValid() && state === "SUCCESS") {
          var result = response.getReturnValue();
          if (result) {
            if (result.indexOf("DONE") > -1) {
                this.toggleSpinner(component);
                if(result == 'DONE'){
                    helper.generateOfferWithoutRefreshTaxfees(component);
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
    
  generateOfferWithoutRefreshTaxfees : function(component) {
       let labpUrl = component.get("v.excelDownloadUrl");
       let reportId = component.get("v.taxAndFeeReportID");
       let additionalNotesReportId = component.get("v.additionalNotesReportID");
        if(labpUrl) {
            window.open("https://" + window.location.hostname + $A.get("$Label.c.AITM_ReportURLLABPOfferButton") + '/' + additionalNotesReportId + "/view?fv0=" + component.get("v.recordId"));
			
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "https://" + window.location.hostname + $A.get("$Label.c.AITM_ReportURLLABPOfferButton") + '/' + reportId + "/view?fv0=" + component.get("v.recordId")            
            });
            urlEvent.fire();
        } else {
            var urlEvent1 = $A.get("e.force:navigateToURL");
            urlEvent1.setParams({
                 "url": "https://" + window.location.hostname + $A.get("$Label.c.AITM_ReportURLTendering") + '/' + additionalNotesReportId + "/view?fv0=" + component.get("v.recordId")  
            });
            urlEvent1.fire();
			
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "https://" + window.location.hostname + $A.get("$Label.c.AITM_ReportURLTendering") + '/' + reportId + "/view?fv0=" + component.get("v.recordId")          
            });
            urlEvent.fire();
        }
   },

  copyTextHelper : function(component,event,text) {
        var hiddenInput = document.createElement("input");
        hiddenInput.setAttribute("value", text);
        document.body.appendChild(hiddenInput);
        hiddenInput.select();
        document.execCommand("copy");
        document.body.removeChild(hiddenInput);
        var orignalLabel = event.getSource().get("v.label");
        event.getSource().set("v.iconName" , 'utility:check');
        event.getSource().set("v.label" , 'copied');
        
        setTimeout(function(){ 
            event.getSource().set("v.iconName" , 'utility:copy_to_clipboard'); 
            event.getSource().set("v.label" , orignalLabel);
        }, 700);        
   },
    
    toggleSpinner: function(component) {
    var spinner = component.find("loaderSpinner");
    $A.util.toggleClass(spinner, "slds-hide");
  }
})