({
	init : function(component, event, helper) {
        var action = component.get("c.getRecordTypeIdbyName");
        action.setParams({
            "objectName": 'Contact',
            "strRecordTypeName": 'General Contact'
        });
    	action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.recordTypeId",response.getReturnValue()); 
            }
            else {
                console.log("Failed with state: " + state);
            }
    	});
    	$A.enqueueAction(action);
	}
})