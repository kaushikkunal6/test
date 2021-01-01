({
	doInit : function(component, event, helper) {
		helper.doInit(component);
	},
    
    onFilterChange : function(component, event, helper) {
        
        helper.onFilterChange(component, event);
    },
    
    taxesonly : function(component, event, helper) {
        component.set("v.OperationSelection", event.getSource().get("v.value"));
        component.set("v.isButtonValue", true);
    },
    
    additionalnotesonly : function(component, event, helper) {
        component.set("v.OperationSelection", event.getSource().get("v.value"));
        component.set("v.isButtonValue", true);
    },
    
    taxesandnotes : function(component, event, helper) {
        component.set("v.OperationSelection", event.getSource().get("v.value"));
        component.set("v.isButtonValue", true);
    },

    Refresh : function(component, event, helper){
        var filter = component.get("v.selectedFilter");
        var values = component.get("v.selectedOptions");
        if((filter == 'All Locations') || (values != '')){
            helper.processing(component, event);
        }else{
            
            //this.showToasts("error", "Please select values to initiate the refresh.");
           //alert('Please select values to initiate the refresh.');
            component.set("v.validationError",true);
        }
    },
    showToasts: function(type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: message,
            mode: "pester",
            duration: 500
        }); 
        toastEvent.fire();  
    },

    close : function(component, event, helper){
        component.set("v.isModalOpen", false);
        component.find("overlayLib").notifyClose();
    }
})