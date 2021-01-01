({
	doInit : function(component, helper) {
		this.getSummaryValues(component);
	},

	getSummaryValues: function(component) {
		var tender = component.get("v.tender");
		if(tender != null){
			var action = component.get("c.getTenderSummaryValues");

			action.setParams({
				"tender": tender
			});
			action.setStorable();
			action.setCallback(this, function(actionResult) {
				var state = actionResult.getState();
				if (state === 'SUCCESS'){
					var result = actionResult.getReturnValue();
					component.set("v.locationSummaryValues", result);
				}
			}); 

			$A.enqueueAction(action);  
		}
	},

})