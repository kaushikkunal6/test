({
    doInit : function(component) {
    this.loadCustomersDetails(component);
    },

    loadCustomersDetails : function(component) {
        var tenderLocationId = component.get("v.recordId");
        var action = component.get("c.getCustomers");
        action.setParams({
            "tenderLocationId": tenderLocationId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (returnValue) {
                    component.set("v.customers", returnValue);
                }
            }
        });
        $A.enqueueAction(action);
	}
})