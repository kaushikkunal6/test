({
    
    doInit : function(component) {
        this.loadLocationLineItemsStartDates(component);
        this.loadLocationLineItemsEndDates(component);
    },
    
    loadLocationLineItemsStartDates : function(component) {
        var tenderId = component.get("v.recordId");
        var action = component.get("c.getTenderLocationLineItemsStartDates");
        action.setParams({
            "tenderId": tenderId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                console.log('tenderLocationStartDates',returnValue);
                if (returnValue) {
                    component.set("v.tenderLocationLineItemsStartdates", returnValue);
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    loadLocationLineItemsEndDates : function(component) {
        var tenderId = component.get("v.recordId");
        var action = component.get("c.getTenderLocationLineItemsEndDates");
        action.setParams({
            "tenderId": tenderId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (returnValue) {
                    component.set("v.tenderLocationLineItemsEnddates", returnValue);
                }
            }
            
        });
        
        $A.enqueueAction(action);
    },

    selectStartDate : function(component) {
        var selectStartDate = component.find('existingStartDateInput');
        var currentStartDate = selectStartDate.get("v.value");  
        component.set("v.oldStartDate", currentStartDate);
    },
    
    selectEndDate : function(component) {
        var selectEnddate = component.find('existingEndDateInput');
        var currentEndDate = selectEnddate.get("v.value");  
        component.set("v.oldEndDate", currentEndDate);
    },

    save : function(component,event,helper) {        
        var tenderId = component.get("v.recordId");
        var selectStartDate = component.find("existingStartDateInput");
        var existingStartDate = selectStartDate.get("v.value");
        component.set("v.oldStartDate",existingStartDate);
        var selectNewStartDate = component.find("startDateInput");
        var newStartDate = selectNewStartDate.get("v.value");
        component.set("v.newStartDate",newStartDate); 
        console.log('newStartDate', newStartDate);
        var selectEndDate = component.find("existingEndDateInput");
        var existingEndDate = selectEndDate.get("v.value");
        component.set("v.oldEndDate",existingEndDate);
        var selectNewEndDate = component.find("endDateInput");
        var newEndDate = selectNewEndDate.get("v.value");
        component.set("v.newEndDate",newEndDate); 
        console.log('newEndDate', newEndDate);
        
        var action = component.get("c.updateLineItems");
        action.setParams({
            "tenderId": tenderId,
            "oldStartDate":existingStartDate,
            "newStartDate":newStartDate,
            "oldEndDate":existingEndDate,
            "newEndDate":newEndDate
        });
        console.log('action',action);
        action.setCallback(this, function(response){
           var state = response.getState();
           console.log('saveresponse',response);
           this.toggleSaveLock(component);
        });

        $A.enqueueAction(action);
    },
      
    toggleSaveLock : function(component) {
        component.set("v.saveLocked", !component.get("v.saveLocked"));
    },

    saveAndClose : function(component) {
        this.save(component);
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
    
})