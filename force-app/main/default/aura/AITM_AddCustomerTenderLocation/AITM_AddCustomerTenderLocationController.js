({
    doInit : function(component, event, helper) {
        helper.doInit(component);
    }, 

    save : function(component, event, helper) {
        helper.saveAndClose(component, event);
    },

    showDetails : function(component, event, helper) {
        helper.showDetails(component, event);
    },

    resetVolume : function(component, event, helper) {
        helper.resetVolume(component, event);
    },

    close : function(component, event, helper) {
        helper.close();
    },
})