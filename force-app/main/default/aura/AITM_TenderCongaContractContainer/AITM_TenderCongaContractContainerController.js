({
    doInit : function(component, event, helper) {
        helper.doInit(component);
    },

    onFilterChange : function(component, event, helper) {
        helper.onFilterChange(component);
    },

    generate : function(component, event, helper) {
        helper.generatePopUp(component, event, helper);
        /*var checkValue = false;
        var isOldTender = component.get('v.oldTaxFeeFlag');
        if(!isOldTender){
            checkValue = component.find("refreshcheckbox").get("v.checked");
        }
        if(isOldTender || (!checkValue)){
            helper.generate(component, event, helper);
        } else {
            helper.generateCongaContractWithRefresh(component, event, helper);
        }*/
    },
    
    checkIsWordBeforeGenerate : function(component, event, helper) {
        var wordCheckValue = false;
        var checkValue = false;
        var isOldTender = component.get('v.oldTaxFeeFlag');
        if(!isOldTender){
            /*checkValue = component.find("refreshcheckbox").get("v.checked");
            component.set("v.isRefreshForWord", checkValue);*/
            wordCheckValue = component.find("wordcheckbox").get("v.checked");
            component.set("v.isWordDoc", wordCheckValue);
        }
        if(wordCheckValue){
            component.set("v.isShowOffer", false);
            component.set("v.isWordPopUp", true);
        }else{
            helper.generatePopUp(component, event, helper);
        }
    },
    
    closeIsWordPopUp : function(component, event, helper) {
        component.set("v.isWordPopUp", false);
        component.set("v.isButtonValue", false);
        component.set("v.isShowOffer", true);
    },

    close : function(component, event, helper) {
        helper.close();
    },

    showTaxesCheckBox : function(component, event, helper) {
        component.set("v.contractSelection", event.getSource().get("v.value"));
        component.set("v.isTenderOld", false);
        component.set("v.isButtonValue", true);  
    },

    hideTaxesCheckBox : function(component, event, helper) {
        component.set("v.contractSelection", event.getSource().get("v.value"));
        component.set("v.isTenderOld", true);
        component.set("v.isButtonValue", true);  
    },
})