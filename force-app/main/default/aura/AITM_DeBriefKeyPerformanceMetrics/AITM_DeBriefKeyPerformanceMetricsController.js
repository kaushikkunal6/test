({
	doInit : function(component, event, helper) {
		helper.doInit(component);
		helper.updateVariance(component);
	}, 

	updateTender: function(component, event, helper) {
		helper.updateTender(component, event);
	}, 

	updateVariance: function(component, event, helper) {
		helper.updateVariance(component);
	}, 

})