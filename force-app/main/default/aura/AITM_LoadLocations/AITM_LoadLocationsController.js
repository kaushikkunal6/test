({
    save : function(component, event, helper) {
        helper.save(component);
    },

    preventDefault : function(component, event, helper) {
        helper.preventDefault(event);
    },

    loadFiles : function(component, event, helper) {
        helper.loadFiles(component, event);
    },

    close : function(component, event, helper) {
        helper.closeModalWindow();
    }
})