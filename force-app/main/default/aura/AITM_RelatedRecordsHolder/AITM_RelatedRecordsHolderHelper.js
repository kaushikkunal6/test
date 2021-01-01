({
    onFilterChangeBase : function(component, componentName) {
        var selectedFilter = component.get("v.selectedFilter");
        var helper = this;
        helper.getFilterBase(component, this.COMPONENT_NAME, selectedFilter);
    },

    searchBase : function(component, componentName, helper, searchCallback, clearCallback) {
        var searchTerm = component.get("v.searchTerm");
        if (searchTerm && searchTerm.length > 1) {
            component.set("v.searchTermEntered", true);
            searchCallback(searchTerm, helper);
        } else {
            if (component.get("v.searchTermEntered")) {
                clearCallback(component, helper);
                component.set("v.searchTermEntered", false);
            }
        }
    },

    getFilterOptionsBase : function(component, componentName) {
        var action = component.get("c.getFilterOptions");
        var tenderId = component.get("v.recordId");
        action.setParams({
            "componentName": componentName,
            "tenderId": tenderId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (returnValue) {
                    component.set("v.filterOptions", returnValue);
                    component.set("v.selectedFilter", returnValue[0]);
                }
            }
        });
        $A.enqueueAction(action);
    },

    getFilterBase : function(component, componentName, selectedFilter) {
        var action = component.get("c.getFilter");
        var tenderId = component.get("v.recordId");
        action.setParams({
            "componentName": componentName,
            "selectedFilter": selectedFilter,
            "tenderId": tenderId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                this.fireFiltersEvent(component, JSON.stringify(returnValue));
            }
        });
        $A.enqueueAction(action);
    }
})