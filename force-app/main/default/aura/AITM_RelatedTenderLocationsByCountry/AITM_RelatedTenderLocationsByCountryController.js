({
    doInit : function(component, event, helper) {
        helper.doInit(component);
    },

    handleRoundEvent : function(component, event, helper) {
        helper.handleRoundEvent(component, event);
    },

    handleFilterEvent : function(component, event, helper) {
        helper.handleFilterEvent(component, event);
    },
    
    handleChangeStageEvent : function(component, event, helper) {
        helper.handleChangeStageEvent(component, event);
    },

    navigateToSObject : function(component, event, helper) {
        helper.preventDefault(event);
        helper.handleViewSObject(component, event);
    },

    showCountryWiseLineItems: function(component, event, helper) {
        component.set("v.location",null);
        var selectedItem = event.currentTarget;
        var country = selectedItem.dataset.country;
        var location = selectedItem.dataset.location;    
        component.set("v.selectedCountry",country);
        component.set("v.location",location);
    }
})