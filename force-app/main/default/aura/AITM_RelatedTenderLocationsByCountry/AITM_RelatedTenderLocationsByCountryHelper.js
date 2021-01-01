({
    doInit : function(component) {
        var selectedRound = component.get("v.selectedRound").slice(6);
        this.loadLocationDetails(component, component.get("v.recordId"), null, null, selectedRound);
    },

    loadLocationDetails : function(component, tenderId, filter, searchTerm, roundNumber) {
        var action = component.get("c.getLocationSummaryDetails");
       
        action.setParams({
            "tenderId": tenderId,
            "filter": filter,
            "roundNumber": roundNumber
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                component.set("v.locations", returnValue, null);
                this.disableSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },

    handleRoundEvent : function(component, event) {
        this.toggleSpinner(component);
        component.set("v.selectedRound", event.getParam("roundNumber"));
        this.loadLocationDetails(component, event.getParam("tenderId"), null, null, event.getParam("roundNumber"));
    },

    handleFilterEvent : function(component, event) {
        this.toggleSpinner(component);
        this.loadLocationDetails(component, event.getParam("tenderId"), null, null, event.getParam("roundNumber"));
    },

    handleViewSObject : function(component, event) {
        var target = event.target || event.srcElement;
        var recordId = target.getAttribute("data-recordid");
        var evt = $A.get("e.force:navigateToSObject");
        evt.setParams({
           "recordId": recordId,
           "slideDevName": "detail"
        });
        evt.fire();
    },

    handleChangeStageEvent : function(component, event) {
        this.refreshView();
    },

    preventDefault : function(event) {
        event.stopPropagation();
        event.preventDefault();
    },

    containsIgnoreCase : function(source, searchTerm) {
        return source && source.toLowerCase().indexOf(searchTerm) > -1;
    },

    toggleSpinner : function(component) {
        var spinner = component.find("relatedLocationSpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        component.set("v.showSpinner", false);
    },

    disableSpinner : function(component) {
        var spinner = component.find("relatedLocationSpinner");
        component.set("v.showSpinner", false);
        $A.util.addClass(spinner, "slds-hide");
    },

    refreshView : function() {
        $A.get('e.force:refreshView').fire();
    },

})