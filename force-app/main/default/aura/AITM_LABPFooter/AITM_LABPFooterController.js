({
	init : function(component, event, helper) {
    var today = $A.localizationService.formatDate(new Date(), "YYYY");
    component.set('v.today', today);
	}
})