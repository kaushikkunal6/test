({
    doInit : function(component, event, helper) {
      
	},
    
	handleNextSelectedLineEvent : function(component, event, helper) { 
       var partialRefresh = event.getParam("hasPartialRefresh");
        if(!partialRefresh){ 
        	component.set("v.forceRefresh", false);
            var selectedLineGetFromEvent = event.getParam("selectedLineId");
            component.set("v.selLineId" , selectedLineGetFromEvent); 
            component.set("v.forceRefresh", true);
            component.set("v.calledViaAuraRefresh", true);
            component.set("v.valuesUpdatedViaAura", true);
        }
    },
    
    injectedFromLWC: function(component, event) {
        var lineId = component.get("v.selLineId");
        var compEvent = $A.get("e.c:AITM_PartialRefreshEvent");
            compEvent.setParams({
                "recordByEvent" : lineId,
            });  
            compEvent.fire();
	},
    
    holdLastSelectedTabState: function(component, event){
        component.set("v.holdLastSelectedTab",event.getParam('value'));
    }
})