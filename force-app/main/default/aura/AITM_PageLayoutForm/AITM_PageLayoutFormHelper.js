({
	retrievePageLayout : function(component, helper) {
		var action = component.get("c.getPageLayoutMetadata");
        var pageLayoutName = component.get("v.pageLayoutName");
        var recordId = component.get("v.recordId");
        
      	let newFieldsArray = [];
        let newLabelsArray = [];
        let fieldNamesString = component.get("v.fields");
        if(fieldNamesString !== null && fieldNamesString !== undefined){
            let fieldsArray = fieldNamesString.split(",");
            for(let field of fieldsArray){
                field = field.trim();
                newFieldsArray.push(field);
            }
            component.set("v.fieldNames", newFieldsArray);
        }
        let sectionArray = component.get("v.labels");
        if(sectionArray !== null && sectionArray !== undefined){
            let labelsArray = sectionArray.split(",");
            for(let label of labelsArray){
                label = label.trim();
                newLabelsArray.push(label);
            }
            component.set("v.labelNames", newLabelsArray);
        }
        var fieldsArray = newFieldsArray;
        var sectionsArray = newLabelsArray;
        var actionParams = {
            "pageLayoutName" : pageLayoutName,
            "fieldsArray"    :fieldsArray
        };

        action.setParams(actionParams);
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if (component.isValid() && state === "SUCCESS") {
                var pageLayout = response.getReturnValue();
                component.set("v.pageLayout", pageLayout);
            }
        });
        $A.enqueueAction(action);
	},

	handleOnSuccess : function(component, event, helper) {
		var payload = event.getParams().response;
        var toastEvent = $A.get("e.force:showToast");
        var recordURL = '/' + payload.id;
        toastEvent.setParams({
        	message: "success",
            messageTemplate: 'The {0} was saved successfully.',
            messageTemplateData: [{
                url: recordURL,
                label: 'record',
            }],
            type: 'success'
        });
        toastEvent.fire();
        // Set the record id so that future saves will update the created record
        // if no record id was initially specified.
        component.set('v.recordId', payload.id);
        this.close(component);
	},
    close : function() {
        this.refreshView();
        this.closeModalWindow();
    },

    refreshView : function() {
        var refreshView = $A.get('e.force:refreshView');
        refreshView.fire();
    },

    closeModalWindow : function() {
        var closeAction = $A.get("e.force:closeQuickAction");
        closeAction.fire();
    },
    
    handleError : function(component, event, helper) {
        component.set("v.showSpinner",false);
        var message = '';
        var errors = event.getParams();
        
        var errormessages = errors.output;

        if ($A.util.isEmpty(errormessages.errors) === false) {
            if (errormessages.errors.length > 0) {
                for (var j = 0; errormessages.errors.length > j; j++) {
                    var fielderror = errormessages.errors[j];
                    if (fielderror.errorCode === 'DUPLICATES_DETECTED') {
                        message += 'Looks like this might be a duplicate. Click on the “Return to Search” button to find this contact';
                    }
                    else {
                        message += fielderror.errorCode + ' (' + fielderror.field + ') : ' + fielderror.message;
                    }
                }
            }
        }

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "error",
            "title": "Error on Save!",
            "message": message
        });
        toastEvent.fire();
    }
})