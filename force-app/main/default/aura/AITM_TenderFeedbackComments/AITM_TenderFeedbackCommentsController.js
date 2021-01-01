({
    init:function(component,event,helper){
        helper.selectPickVal(component,event, helper);
        helper.selectQualityVal(component,event, helper);
        helper.fetchTenderHelper(component,event,helper);
        helper.selectLevelpickVal(component, event, helper);
        helper.selectCurrencypickVal(component, event, helper);
        helper.selectUOMpickVal(component, event, helper);
         
         
    },
    handleFilterEvent : function(component, event, helper) {
        helper.handleFilterEvent(component, event);
    },

    
    navigateToSObject : function(component, event, helper) {
        helper.handleViewSObject(component, event);
    },
    handleSave : function(component, event, helper) {
        helper.handleSaveSObject(component, event);
    },
    showtooltip : function(component, event, helper) {
        var hoverRowLineId = event.currentTarget.getAttribute("data-target");
        component.set("v.hoverRow", parseInt(event.target.dataset.index));
        component.set("v.hoverRowLineId",hoverRowLineId);
        var items = component.find("hover");
        var currentIndex = parseInt(event.target.dataset.index);
    },
    hidetooltip : function(component, event, helper) {
        component.set("v.hoverRowLineId","");
        var items = component.find("hover");
        component.set("v.hoverRow",-1);
    },
    handleRefreshTableEvent: function(component, event, helper) {
        helper.fetchTenderHelper(component,event,false);
    },    
    captureChange : function(component, event, helper) {
        var fieldId = event.getSource().getLocalId();
        var index = event.getSource().get("v.name"),
            RowItemList = component.get("v.tenderLocationList"),
            currentrow = RowItemList[index],
            selected = event.getSource().get("v.value");
        var tenderlocId = event.getSource().get("v.id");
        if(fieldId == 'AMComments'){
            currentrow.AITM_Comments__c = selected;
        }
        if(fieldId == 'LMComments'){
            currentrow.AITM_LM_Comments__c = selected;
        }
        if(fieldId == 'Bidders'){
            if(selected != null)
            currentrow.AITM_Number_Of_Bidders__c = selected;
        }
        if(fieldId == 'position'){
            if(selected != null)
            currentrow.AITM_Position__c = selected;
        }
        if(fieldId == 'estimated'){
            currentrow.AITM_Leading_Bid__c = selected;
        }
        if(fieldId == 'distance'){
            currentrow.AITM_Distance_from_Leading_Bid2__c = selected;
        }
        currentrow.Id = tenderlocId;
        currentrow.AITM_Is_Current_Round__c = 'true';
        RowItemList.splice(index, 1, currentrow);
        component.set("v.tenderLocationListToUpdate",RowItemList);
    },
    capturePicklistChange : function(component, event, helper) {
        var fieldId = event.getSource().getLocalId();
        var index = event.getSource().get("v.tabindex"),
            RowItemList = component.get("v.tenderLocationList"),
            currentrow = RowItemList[index],
            selected = event.getSource().get("v.value");
        var tenderlocId = event.getSource().get("v.name");
        if(fieldId == 'levelOfInterest'){
            currentrow.AITM_Level_Of_Interest__c = selected;
        }
        if(fieldId == 'Currency'){
            currentrow.AITM_Leading_Bid_Currency__c = selected;
        }
        if(fieldId == 'UOM'){
            currentrow.AITM_Unit_Of_Measure__c = selected;
        }
        currentrow.Id = tenderlocId;
        currentrow.AITM_Is_Current_Round__c = 'true';
        RowItemList.splice(index, 1, currentrow);
        component.set("v.tenderLocationListToUpdate",RowItemList);
    },
    
})