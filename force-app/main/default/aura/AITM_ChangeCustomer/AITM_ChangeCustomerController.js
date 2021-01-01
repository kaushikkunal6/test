({
    doInit : function(component, event, helper) {
        helper.doInit(component);
    },
    
    filterSelect : function(component, event, helper) {
    	helper.filterSelect(component, event);
    },
    
    search : function(component, event, helper) {
        helper.search(component, helper, event);
    },
	
    selectCustomer : function(component, event, helper) {             
        helper.selectCustomer(component, event);  
    },

    save : function(component, event, helper) {         
        helper.saveAndClose(component)
    },

    close : function(component, event, helper) {
        helper.close();
    },
})