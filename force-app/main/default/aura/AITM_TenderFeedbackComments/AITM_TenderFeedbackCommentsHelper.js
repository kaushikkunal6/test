({
    handleFilterEvent : function(component, event) {
        this.fetchTenderHelper(component,event.getParam("tenderId"),event.getParam("roundNumber"));
    },
   
    fetchTenderHelper : function(component,event,helper) {
        this.toggleSpinner(component);
        var recordId = component.get("v.recordId");
        var roundNumber = component.get("v.selectedRound").slice(6);
        var action = component.get("c.getTenderLocationDetails");
        action.setParams({
            "recordId" : recordId,
            "currentRoundNumber": roundNumber
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var result = response.getReturnValue();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.tenderLocationList",result);
            }
            this.disableSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    toggleSpinner : function(component) {
        var spinner = component.find("tenderLocationSpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
    disableSpinner : function(component) {
        var spinner = component.find("tenderLocationSpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    selectPickVal : function(component,event,helper){
        var recordId = component.get("v.recordId");
        var action = component.get("c.getPickValues");
        action.setParams({
            "objectName" : "AITM_Tender__c",
            "fieldName":"AITM_Last_Look_To_Incumbent__c"
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var incumbentMap = [];
                 incumbentMap.push({key: "None", value: "None"});
                for(var key in result){
                    incumbentMap.push({key: key, value: result[key]});
                }
                component.set("v.incumbentOptions", incumbentMap);
            }
        });
        $A.enqueueAction(action);
    },
    selectQualityVal : function(component,event,helper){
        var recordId = component.get("v.recordId");
        var action = component.get("c.getPickValues");
        action.setParams({
            "objectName" : "AITM_Tender__c",
            "fieldName": "AITM_Quality_Of_Feedback__c"
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var qualityMap = [];
                qualityMap.push({key: "None", value: "None"});
                for(var key in result){
                    qualityMap.push({key: key, value: result[key]});
                }
                component.set("v.qualityOptions", qualityMap);
            }
        });
        $A.enqueueAction(action);
    },
    selectLevelpickVal : function(component,event,helper){
        var recordId = component.get("v.recordId");
        var action = component.get("c.getPickValues");
        action.setParams({
            "objectName" : "AITM_Tender_Location__c",
            "fieldName": "AITM_Level_Of_Interest__c"
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var levelMap = [];
                 levelMap.push({key: "None", value: "None"});
                for(var key in result){	
                    levelMap.push({key: key, value: result[key]});
                }
                
                component.set("v.interestOptions", levelMap);
            }
        });
        $A.enqueueAction(action);
    },
    selectCurrencypickVal : function(component,event,helper){
        var recordId = component.get("v.recordId");
        var action = component.get("c.getPickValues");
        action.setParams({
            "objectName" : "AITM_Tender_Location__c",
            "fieldName": "AITM_Offered_Differential_Currency__c"
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var currencyMap = [];
                for(var key in result){	
                    currencyMap.push({key: key, value: result[key]});
                }
                component.set("v.currencyOptions", currencyMap);
            }
        });
        $A.enqueueAction(action);
    },  
    selectUOMpickVal : function(component,event,helper){
        var recordId = component.get("v.recordId");
        var action = component.get("c.getPickValues");
        action.setParams({
            "objectName" : "AITM_Tender_Location__c",
            "fieldName": "AITM_Offered_Differential_UoM__c"
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var UOMMap = [];
                for(var key in result){	
                    UOMMap.push({key: key, value: result[key]});
                }
                component.set("v.UOMOptions", UOMMap);
            }
        });
        $A.enqueueAction(action);
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
    handleSaveSObject : function(component, event) {
        this.toggleSpinner(component);
        var tenderLocationList = component.get("v.tenderLocationListToUpdate");
        component.find("recordLoaderAuraId").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
            }
        }));
        var action = component.get("c.saveTenderFeedbackComments");
        action.setParams({ 
            "tenderLocationList": JSON.stringify(tenderLocationList)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
				component.set("v.tenderLocationListToUpdate",null);
            }
            else if (state === "ERROR"){}
            $A.get('e.force:refreshView').fire();
            this.disableSpinner(component);
        });
        $A.enqueueAction(action);
       
    },
    
})