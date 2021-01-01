({
    doInit : function(component, event, helper) {
        helper.doInit(component);
    },

    search : function(component, event, helper) {
        helper.search(component, helper, event);
    },

    selectLocation : function(component, event, helper) {             
       helper.selectLocation(component, event);  
       
    },

    showDetails : function(component, event, helper) {
        helper.showDetails(component, event);
    },

    resetVolume : function(component, event, helper) {
        helper.resetVolume(component, event);
    }, 

    save : function(component, event, helper) {         
        helper.saveAndClose(component)
     },

    saveAndNew : function(component, event, helper) {
        helper.saveAndNew(component);
    },

    close : function(component, event, helper) {
        helper.close();
    },
})