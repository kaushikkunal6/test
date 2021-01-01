({
    doInit : function(component, event, helper) {
        helper.doInit(component);
    },

    handleRoundEvent : function(component, event, helper) {
        helper.handleRoundEvent(component, event);
    },

    handleFilterEvent : function(component, event, helper) {
        helper.handleFilterEvent(component, event);
    },
    
    handleChangeStageEvent : function(component, event, helper) {
        helper.handleChangeStageEvent(component, event);
    },

    navigateToSObject : function(component, event, helper) {
        helper.preventDefault(event);
        helper.handleViewSObject(component, event);
    },

    handleSave : function(component, event, helper) {
        helper.handleSave(component);
    },

    changeRevisedOfferLocation: function(component, event, helper) {
        helper.changeRevisedOfferLocation(component, event);
    }
})