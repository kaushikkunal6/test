({
	doInit : function(component, event, helper) {
		helper.doInit(component, event);	
	},

	handleUpdateTenderEvent : function(component, event, helper) {
		helper.showFormControls(component);
	},

	saveFormValues : function(component, event, helper) {
		helper.updateRecord(component, event);
	},

	cancelEditForm : function(component, event, helper) {
		helper.cancelEditForm(component);
	},

})