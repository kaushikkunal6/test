({
	init : function(component, event, helper) {
		helper.getStateData(component);
        helper.initializeCurrentState(component);
        helper.toggleMarkButton(component);
	},

	tapped : function(component, event, helper) {
		helper.tapped(component, event);
        helper.fireCurrentStageEvent(component.get("v.chosenElementName"));
	},

	buttonConfirm : function(component, event, helper) {
		helper.buttonConfirm(component);
	},

	buttonShowMoreInfoListener : function(component, event, helper) {
		helper.buttonShowMoreInfoListener(component);
	},

	closeCustomerCreationDialog : function(component, event, helper) {
		helper.closeCustomerCreationDialog(component);
	},
	
	handleForceChangeStage : function(component, event, helper) {
		helper.handleForceChangeStage(component);
	},
})