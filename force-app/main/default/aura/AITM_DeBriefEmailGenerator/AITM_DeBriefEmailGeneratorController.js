({
    doInit : function(component, event, helper) {
        helper.doInit(component);
    },

    attach : function(component, event, helper) {
        helper.attach(component, event);
    },
    
    //Kunal-->
    closeModel: function(component, event, helper) { 
        component.set("v.isOpen", false);
    },
    
    Generate : function(component, event, helper) {
        //var checkValue = event.getSource("refreshTFCheckbox").get("v.checked");
        var checkValue = component.find("refreshTFCheckbox").get("v.checked");
        
        if(!checkValue) {
            helper.generate(component);
            component.set("v.isOpen", false);
        }else {
            component.set("v.isOpen", false);
            helper.getTFFromMasterData(component, event, helper);
        }
    }		
    //Kunal<--   
})