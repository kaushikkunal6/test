({
    doInit : function(component, event, helper) {
        helper.doInit(component);
    },

    handleFilterEvent : function(component, event, helper) {
        helper.handleFilterEvent(component, event);
    },

    handleSearchEvent : function(component, event, helper) {
        helper.handleSearchEvent(component, event);
    },

    handleSave : function(component, event, helper) {
        helper.handleSave(component);
    },
    
    handleSelectAll: function(component, event, helper) {
        var checkvalue = component.find("selectAll").get("v.checked");
        var checkResult = component.find("checkResult");
        if(checkResult != undefined && checkvalue == true){
            for(var i=0; i<checkResult.length; i++){
                checkResult[i].set("v.checked",true);
                component.set("v.isMultipleOptionDisabled", false);
            }
        }
        else{
            if(checkResult != undefined){
                for(var i=0; i<checkResult.length; i++){
                    checkResult[i].set("v.checked",false);
                    component.set("v.isMultipleOptionDisabled", true);
                    var temp = component.get("v.deBriefResultsOption")[0];
                    component.set("v.selectedResult",temp);
                }
            }
        }
    },
    
    handleSelectAllCheckbox: function(component, event, helper) {
        var selectAllValue = component.find("selectAll");
        var checkResult = component.find("checkResult");
        var selectedLegth = [];
        
        for(var i=0; i<checkResult.length; i++){
            if(checkResult[i].get("v.checked")){
               selectedLegth.push(checkResult[i]);
            }
        }
        if(selectedLegth.length == checkResult.length){
            component.find("selectAll").set("v.checked", true);
            component.set("v.isMultipleOptionDisabled", false);
        }else{ 
            component.find("selectAll").set("v.checked", false);
        }
        
        if(selectedLegth.length > 0){
            component.set("v.isMultipleOptionDisabled", false);
        }else{
            component.set("v.isMultipleOptionDisabled", true);
            var temp = component.get("v.deBriefResultsOption")[0];
                    component.set("v.selectedResult",temp);
        }
    },
    
    onResultChange : function(component, event, helper) {
        var resultToUpdate = component.get("v.selectedResult");
        if(resultToUpdate != '--'){
            helper.resultToUpdateOnTlli(component, event, helper);
        }
	},

    navigateToSObject : function(component, event, helper) {
        helper.preventDefault(event);
        helper.handleViewSObject(component, event);
    },
    
    selectChange : function(component, event, helper) {
		helper.onSelectChange(component);
	},
    
    first : function(component, event, helper) {
        helper.firstPageRecords(component);
    },
    
    last : function(component, event, helper) {
        helper.lastPageRecords(component);
    },
    
    next : function(component, event, helper) {
        helper.nextPageRecords(component);
    },
    
    previous : function(component, event, helper) {
       helper.previousPageRecords(component);
    }
})