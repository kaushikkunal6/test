({
    doInit : function(component) {
        this.getTenderAvailableForEmailSending(component);
    },

    updateTender : function(component) {
        var tenderId = component.get("v.recordId");
        var action = component.get("c.updateTenderAfterEmailSent");
        action.setParams({
            "tenderId": tenderId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                this.refreshView();
                this.closeModalWindow();
                this.showToast("success", "Success!", "Message sent");
            }
        });
        $A.enqueueAction(action);
    },

    getTenderAvailableForEmailSending : function(component) {
        var tenderId = component.get("v.recordId");
        var action = component.get("c.getTenderAvailableForEmailSending");
        action.setParams({
            "tenderId": tenderId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (returnValue) {
                    component.set("v.errorMessage", returnValue);
                    component.set("v.tenderValid", false);
                    this.showToast("error", "Error", returnValue);
                    this.closeModalWindow();
                } else {
                    component.set("v.tenderValid", true);
                    this.getEmail(component);
                }
            }
        });
        $A.enqueueAction(action);
    },

    getEmail : function(component) {
        var tenderId = component.get("v.recordId");
        var action = component.get("c.getEmail");
        action.setParams({
            "tenderId": tenderId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (returnValue.emailAttachments.length) {
                    this.createEmailGeneratorComponent(component, returnValue);
                } else {
                    this.showToast("error", "Error", "In order to send offer you need to generate it first");
                    this.closeModalWindow();
                }
            } else {
                this.closeModalWindow();
            }
        });
        $A.enqueueAction(action);
    },

    createEmailGeneratorComponent : function(component, emailDTOInstance) {
        var container = component.find("EmailGeneratorHolder");
        $A.createComponent("c:AITM_EmailGenerator",
            {emailDTO: emailDTOInstance},
            function(cmp) {
                container.set("v.body", [cmp]);
            });
    },

    showToast : function(type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": message
        });
        
        toastEvent.fire(); 
    },

    refreshView : function() {
        $A.get('e.force:refreshView').fire();
    },

    closeModalWindow : function() {
        $A.get("e.c:AITM_ClosePathQuickAction").fire();
    },
})