({
    doInit : function(component, event, helper) {
        helper.doInit(component);
    },

    onFilterChange : function(component, event, helper) {
        helper.onFilterChange(component);
    },

    search : function(component, event, helper) {
        helper.search(component);
    },

    resetFilterOption : function(component, event, helper) {
    	helper.resetFilterOption(component);
    },
    
    hookUpSBCToggle : function(component, event, helper) {
        component.set("v.doPartialRefresh", false);
    	helper.fetchCurrentUser(component);
    },
    
    showTLLI : function(component, event, helper) {
        component.set("v.showTLLI", true);
        component.set("v.showLocations", false);
        component.set("v.showSummaryCountry", false);
         component.set("v.showFeedback", false);
    },

    showLocations : function(component, event, helper) {
        component.set("v.showLocations", true);
        component.set("v.showTLLI", false);
        component.set("v.showSummaryCountry", false);
         component.set("v.showFeedback", false);
    },

    showSummaryCountry : function(component, event, helper) {
        component.set("v.showSummaryCountry", true);
        component.set("v.showEnhancedSummaryCountry", false);
        component.set("v.showLocations", false);
        component.set("v.showTLLI", false);
        component.set("v.showFeedback", false);
    },
	
	showEnhancedSummaryCountry : function(component, event, helper) {
        component.set("v.showEnhancedSummaryCountry", true);
        component.set("v.showSummaryCountry", false);
        component.set("v.showLocations", false);
        component.set("v.showTLLI", false);
        component.set("v.showFeedback", false);
    },
    showFeedback : function(component, event, helper) {
        component.set("v.showEnhancedSummaryCountry", false);
        component.set("v.showSummaryCountry", false);
        component.set("v.showLocations", false);
        component.set("v.showTLLI", false);
        component.set("v.showFeedback", true);
        
    },
    deleteRound :function(component, event, helper){
        helper.deleteRound(component);
    },
	
    generateRefreshTaxes: function(component, event, helper) {      
        helper.generateRefreshTaxes(component,event,helper);      
    } 
})