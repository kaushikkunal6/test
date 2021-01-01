({
    doInit : function(component, event, helper) {
        helper.doInit(component);
    },
    
    save:function(component, event, helper) {         
        helper.saveAndClose(component);
    },  
    
    selectStartDate : function(component, event, helper) {
       helper.selectStartDate(component)
    },

    selectEndDate : function(component, event, helper) {
       helper.selectEndDate(component)
    },
       
    close : function(component, event, helper) {
        helper.close();
    },
    
})