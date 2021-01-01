({
    doInit : function(component) {
        this.generate(component);
    },

    generate : function(component) {
        var tenderId = component.get("v.recordId");
        var action = component.get("c.generate");
        action.setParams({
            "tenderId": tenderId,
            "locationType": 'Non Polish'
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                this.createEmailGeneratorComponent(component, returnValue);
            } else {
                this.closeModalWindow();
            }
        });
        $A.enqueueAction(action);
    },

    postNotificationToChatter : function(component) {
        var action = component.get("c.postToChatter");

        action.setParams({
            "tenderId": component.get("v.recordId"),
            "locationType": 'Non Polish'
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                this.showToast("success", "Success!", $A.get("$Label.c.AITM_InvitationEmailSendSuccess"));
                this.refreshView();
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