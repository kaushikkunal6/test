({
	init : function(component, event, helper) {
		helper.retrievePageLayout(component, helper);
	},

	handleOnSuccess : function(component, event, helper) {
		helper.handleOnSuccess(component, event, helper);
	},
    
    close : function(component, event, helper) {
        helper.close();
    },
    
    handleError : function(component, event, helper) {
        helper.handleError();
    }
})