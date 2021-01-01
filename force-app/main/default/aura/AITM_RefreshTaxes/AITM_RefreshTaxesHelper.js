({
    doInit : function(component) {
      component.set("v.isModalOpen",true);
      this.getFilterOptions(component);
      this.getMultiSelectData(component);
        
        
	  },
    
    onFilterChange: function(component) {
        
        var selectFilter = component.find('filter');
        var selectFilterValue = selectFilter.get("v.value");  
        component.set("v.selectedFilter", selectFilterValue);
        var selectedOption = component.get("v.selectedFilter");
        if(selectedOption == 'All Locations'){
          component.set("v.msoptions", '');
          var childComponent = component.find('child');
          childComponent.updateFilter();
        }else if(selectedOption == 'Location(s)'){
          var locationNames = component.get("v.LocationNames");                         
          component.set("v.msoptions", locationNames);
          var childComponent = component.find('child');
          childComponent.updateFilter();
        }else if(selectedOption == 'Location Manager(s)'){
          var managerNames = component.get("v.LocationManagerNames");           
          component.set("v.msoptions", managerNames);
          var childComponent = component.find('child');
          childComponent.updateFilter();
        }else if(selectedOption == 'Countries'){
          var countryNames = component.get("v.LocationCountryNames");
          component.set("v.msoptions", countryNames);
          var childComponent = component.find('child');
          childComponent.updateFilter();
        }
    },

    getFilterOptions: function(component) {
      var filters = [];
      var action = component.get("c.getFilterOptions");
      action.setCallback(this, function(response) {
        var state = response.getState();
        if (component.isValid() && state === "SUCCESS") {
          var returnValue = response.getReturnValue();
          if (returnValue) {
            for (var i = 0; i < returnValue.length; i++) {
              var name = JSON.stringify(returnValue[i]);
              filters.push((name.replace("\"", "")).replace("\"", ""));
            }
            component.set("v.selectedFilter", filters[0]);
            component.set("v.filterOptions", filters);
          }
        }
      });
      $A.enqueueAction(action);
    },

    getMultiSelectData: function(component) {
      var locationName = [];
      var tenderId = component.get("v.recordId");
      var action = component.get("c.getMultiSelectData");
      action.setParams({
        "tenderId": tenderId
      });
      action.setCallback(this, function(response) {
        var state = response.getState();
        if (component.isValid() && state === "SUCCESS") {
            
          var result = response.getReturnValue();             
          if (result) {
            component.set("v.LocationNames", result.locationNames);
              
            component.set("v.LocationManagerNames", result.managerNames);
              
            component.set("v.LocationCountryNames", result.countryNames);
          }
          var locations = component.get("v.LocationNames");
          component.set("v.msoptions", locations);
        }
      });
      $A.enqueueAction(action);
    },

    Refresh : function (component, event, Values){
      var tenderId = component.get("v.recordId");
      var OperationSelection = component.get("v.OperationSelection");
      var selectedOption = component.get("v.selectedFilter");
      var ignoreManualAdjusted = component.find("ignoreManualAdjusted").get("v.checked");
      var action = component.get("c.processingRefresh");
      action.setParams({
        "tenderId": tenderId,
        "OperationSelection": OperationSelection,
        "selectedOption": selectedOption,
        "selectedValues": Values,
        "ignoreManualAdjusted" : ignoreManualAdjusted
      });
      action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
            this.showToast();
            component.set("v.isModalOpen", false); 
            component.find("overlayLib").notifyClose();  
            this.getBatchJobStatus(component, response.getReturnValue());
          }
      });
      $A.enqueueAction(action);
    },

    getBatchJobStatus : function(component,jobId){
      var jobID = jobId;
      var interval = setInterval($A.getCallback(function () {
        var jobStatus = component.get("c.getBatchJobStatus");
        if(jobStatus != null){
            jobStatus.setParams({ jobID : jobID});
            jobStatus.setCallback(this, function(jobStatusResponse){
                var state = jobStatus.getState();
                if (state === "SUCCESS"){
                    var job = jobStatusResponse.getReturnValue();
                    component.set('v.apexJob',job);
                    //WRITE LOGIC TO UPDATE THE TENDER FIELD USED FOR INFORMATION BAR INFO.

                    var processedPercent = 0;
                    if(job.JobItemsProcessed != 0){
                        processedPercent = (job.JobItemsProcessed / job.TotalJobItems) * 100;
                    }
                    var progress = component.get('v.progress');
                    component.set('v.progress', progress === 100 ? clearInterval(interval) :  processedPercent);
                }
            });
            $A.enqueueAction(jobStatus);
        }
      }), 2000);
    },
    
    processing : function (component, event){
      var Values = [];
      var selectedValues = component.get("v.selectedOptions");
      for (var i = 0; i < selectedValues.length; i++) {
          var name = JSON.stringify(selectedValues[i].Name);
          Values.push((name.replace("\"", "")).replace("\"", ""));
      }
      if(Values != null){
          this.Refresh(component, event, Values);
      }
    },

    showToast: function() {
      var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "success",
            "title": "Success!",
            "message": "The Refresh is initiated."
        });
        toastEvent.fire();
    },
})