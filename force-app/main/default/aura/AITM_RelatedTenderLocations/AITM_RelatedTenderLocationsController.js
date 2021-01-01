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

    handleSearchEvent : function(component, event, helper) {
        helper.handleSearchEvent(component, event);
    },

    handleChangeStageEvent : function(component, event, helper) {
        helper.handleChangeStageEvent(component, event);
    },

    navigateToSObject : function(component, event, helper) {
        helper.preventDefault(event);
        helper.handleViewSObject(component, event);
    },

    onTabFocused : function(component, event, helper) {
        helper.onTabFocused(component, event);
    },
})