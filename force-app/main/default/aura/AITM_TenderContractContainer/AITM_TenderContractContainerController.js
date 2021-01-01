({
    doInit : function(component, event, helper) {
        helper.doInit(component);
    },

    onFilterChange : function(component, event, helper) {
        helper.onFilterChange(component);
    },

    generate : function(component, event, helper) {
        var checkValue = false;
        var oldTenderFlag = component.get('v.isTenderOld');
     	/*if(!oldTenderFlag){
            var checkValue = component.find("refreshcheckbox").get("v.checked");
        }*/
        if(oldTenderFlag || (!checkValue)) {
            helper.generate(component);
        }
        else {
            helper.generateContractAfterRefresh(component);
        }
    },


    close : function(component, event, helper) {
        helper.close();
    }
})