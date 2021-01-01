({
	updateTender: function(component, event) {
		var compEvent = component.getEvent("updateTenderEvent");
		compEvent.fire();
	},
})