({
    doInit : function(component) {
        //Kunal
        this.generate(component);
    },

    attach : function(component, event) {
        var tenderId = component.get("v.recordId");
        if (event && event.getParam("emailBody")) {
            var action = component.get("c.attachEmail");
            var dataObject = {"tenderId": tenderId, "emailDTO": event.getParam("emailBody")};
            action.setParams({
                "emailDTOWithTenderId": JSON.stringify(dataObject),
                "locationType":'Polish'
            });

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    this.sendAirportsEmail(component);
                }
            });
            $A.enqueueAction(action);
        }
    },

    sendAirportsEmail : function(component) {
        var tenderId = component.get("v.recordId");
        var action = component.get("c.notifyAirports");
        action.setParams({
            "tenderId": tenderId,
            "locationType": 'Polish'
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                this.showToast("success", "Success!", $A.get("$Label.c.AITM_GenerateDeBriefEmailSuccess"));
                this.updateDebriefEmailSent(component);
                this.refreshView();
                this.closeModalWindow();
            }

        });
        $A.enqueueAction(action);        
    },
	
    updateDebriefEmailSent : function(component) {
        var tenderId = component.get("v.recordId");
        var action = component.get("c.updateDebriefEmailSent");
        action.setParams({
            "tenderId": tenderId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
        });
        $A.enqueueAction(action);
    },
    
    generate : function(component) {
        var tenderId = component.get("v.recordId");
        var action = component.get("c.generate");
        action.setParams({
            "tenderId": tenderId,
            "locationType": 'Polish'
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
    
    getTender : function(component) {
        var tenderId = component.get("v.recordId");
        var action = component.get("c.getTenderData");
        action.setParams({
            "tenderId": tenderId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if(returnValue){
                    component.set("v.isOpen", false);
                    this.generate(component);
                } else{
                    component.set("v.isOpen", true);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    //Kunal
    getTFFromMasterData : function(component, event, helper) {
        var tenderId = component.get("v.recordId");
        var action = component.get("c.upsertNewTaxAndFee");
        action.setParams({
            "tenderId": tenderId,
            "locationType": 'Polish'
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                this.generate(component);
            }
        });
        $A.enqueueAction(action);
    },	
    //Kunal
})