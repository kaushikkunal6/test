({
	doInit : function(component, event) {
		this.getTender(component);
	},

	getTender: function(component) {
		var recordId = component.get("v.recordId");
		var action = component.get("c.getTender");

		action.setParams({
			"tenderId": recordId
		});

		action.setCallback(this, function(actionResult) {
			var state = actionResult.getState();
			if (state === 'SUCCESS'){
				var result = actionResult.getReturnValue();
				component.set("v.tender", result);
				component.set("v.tenderOrigin", result);
				$A.get('e.force:refreshView').fire();
			} 
		}); 

		$A.enqueueAction(action);  
	},

	updateRecord: function(component, event) {
		var tender = component.get('v.tender');
		var action = component.get("c.saveTender");
		action.setParams({
			"tender": tender
		});

		action.setCallback(this, function(actionResult) {
			var state = actionResult.getState();
			if (state === 'SUCCESS'){
				component.set('v.tenderOrigin', tender);
				this.showToast('success', 'Value saved!');
				$A.get('e.force:refreshView').fire();
			}
		}); 
		$A.enqueueAction(action);
	},

	cancelEditForm: function(component){
		this.hideFormControls(component);
		this.resetTenderToOrigin(component);
	},

	showFormControls: function(component){
        var formControls = component.find('de-brief-form-controls');
        if($A.util.hasClass(formControls, 'slds-hide')){
        	$A.util.removeClass(formControls, 'slds-hide');
        }
	},

	hideFormControls: function(component){
        var formControls = component.find('de-brief-form-controls');
        if(!$A.util.hasClass(formControls, 'slds-hide')){
        	$A.util.addClass(formControls, 'slds-hide');
        }
	},

	resetTenderToOrigin : function(component) {
		component.set('v.tender', component.get('v.tenderOrigin'));
    	$A.get('e.force:refreshView').fire();
	},

    showToast: function(type, message) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
          type: type,
          message: message,
          mode: "pester",
          duration: 500
      }); 
      toastEvent.fire();  
    },
    
})