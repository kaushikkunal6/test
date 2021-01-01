({
    doInit : function(component, event, helper) {
        helper.doInit(component);
    },

    search : function(component, event, helper) {
        helper.search(component, helper, event);
    },

    selectCustomer : function(component, event, helper) {             
        helper.selectCustomer(component, event);  
    },

    showDetails : function(component, event, helper) {
        helper.showDetails(component, event);
    },

    toggleAllLocationDetails : function(component, event, helper) {
        helper.toggleAllLocationDetails(component);
    }, 

    resetAllVolume : function(component, event, helper) {
        helper.resetAllVolume(component);
    },

    resetVolume : function(component, event, helper) {
        helper.resetVolume(component, event);
    }, 

    save : function(component, event, helper) {         
        helper.saveAndClose(component,event);
    },

    saveAndNew : function(component, event, helper) {
        helper.saveAndNew(component,event);
    },

    close : function(component, event, helper) {
        helper.close();
    },
})