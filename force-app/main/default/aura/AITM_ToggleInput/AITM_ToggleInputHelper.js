({
doInit: function(component, event) {
    var value = component.get('v.value');

    if(typeof value == 'undefined'){
        this.updateValue(component, event);
    }

    component.set('v.isAfterInit', true);

},

updateValue: function(component, event) {
    var object = this.getObject(component);
    var targetFieldName = component.get('v.targetFieldName');
    var type = component.get('v.type');
    var value = this.getRecordValue(component, event);

    if(typeof object != 'undefined' && typeof targetFieldName != 'undefined'){
        var fieldNameArray = targetFieldName.split('.');
        if(fieldNameArray.length > 1){
            value = this.getValueRecursively(object, fieldNameArray, null);
        }else{
            value = object[targetFieldName];
        }
        component.set('v.targetId', object.Id);
    }else{
        value = component.get('v.name');
    }
    component.set('v.oldValue',value);
    component.set('v.value', value);
    this.getPicklistValues(component);
},

getValueRecursively: function(object, fieldNameArray, depth){
    depth = (depth == null) ? 0 : depth; 
    let fieldName = fieldNameArray[depth];
    if(typeof object[fieldName] === 'object'){
        depth++;
        return this.getValueRecursively(object[fieldName], fieldNameArray, depth);
    }
    return object[fieldName];
},

editValue: function(component, event, askConfirmation){
    var type = component.get('v.type');
    var targetFieldName = component.get('v.targetFieldName');
    var value = this.getRecordValue(component, event);
    var oldValue =  component.get('v.oldValue');
    var isAfterInit = component.get('v.isAfterInit');
    var defaultValue = component.get('v.defaultValue');
	if(type === 'date' && (targetFieldName === 'AITM_Start_Date__c' || targetFieldName === 'AITM_End_Date__c')){
        this.editValueForDates(component, event);
    }
    if(askConfirmation == true && typeof defaultValue != 'undefined' && oldValue == defaultValue && value != defaultValue){
        this.toggleClass(component, 'change-from-default-modal', 'slds-hide');
        return;
    }

    if(isAfterInit){
        if(!Array.isArray(value) && !Array.isArray(oldValue)){
            this.updateElementValue(component, event);
        }else{
            this.toggleToEdit(component);
        }
    }
},
editValueForDates: function(component, event){
        var value = this.getRecordValue(component, event);
        var oldValue =  component.get('v.oldValue');
        var isAfterInit = component.get('v.isAfterInit');
        var targetFieldName = component.get('v.targetFieldName');
        var lineItemId = component.get('v.lineItemId');
        var action = component.get("c.getTenderLocationLineItemBySetOfIds");
        action.setParams({
            "recordId": lineItemId
        });
        action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            var returnValue = response.getReturnValue();
            if (returnValue != null && returnValue[0] != null){
                var startDate = returnValue[0].AITM_Start_Date__c;
                var endDate = returnValue[0].AITM_End_Date__c;
                if(targetFieldName === 'AITM_End_Date__c' && new Date(startDate) >= new Date(value)){
                    this.showToast('error', 'End Date cannot be before Start Date. Please review the dates.');
                    return;
                }else if(targetFieldName === 'AITM_Start_Date__c' && new Date(value) >= new Date(endDate)){
                    this.showToast('error', 'Start Date cannot be after the End Date. Please review the dates.');
                    return;
                }else{
                    if(isAfterInit){
                        if(!Array.isArray(value) && !Array.isArray(oldValue)){
                            this.updateElementValue(component, event);
                        }else{
                            this.toggleToEdit(component);
                        }
                    }
                }
            }
        }
    });
    $A.enqueueAction(action);
},

saveChangeFromDefaultModal: function(component, event){
    this.editValue(component, event, false);
    this.toggleClass(component, 'change-from-default-modal', 'slds-hide');
},

closeChangeFromDefaultModal: function(component){
    var oldValue =  component.get('v.oldValue');
    this.toggleClass(component, 'change-from-default-modal', 'slds-hide');
    component.set('v.value', oldValue);
},

getPicklistValues: function(component){
    var select = component.find("picklist-element");
    if(typeof select != 'undefined'){

        var action = component.get("c.getPickValues");
        var targetObject = component.get("v.targetObject");
        var targetFieldName = component.get("v.targetFieldName");
        var value = component.get('v.value');
        action.setParams({
            "objectName": targetObject,
            "fieldName": targetFieldName
        });

        action.setStorable();

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                var options = [];
                options.push({label:"---None --",
                value:""});
                for(var i = 0; i<returnValue.length; i++){
                    var option = {
                        value: returnValue[i],
                    }
                    if(returnValue[i] == value){
                        option['selected'] = "true";
                    }
                    options.push(option);
                }
                if (returnValue) {
                    select.set('v.options', options)
                }
            }
            
        });

        $A.enqueueAction(action);   
    }
},

updateElementValue: function(component, event) {
    var recordValue = this.getRecordValue(component, event);
    var recordOldValue = component.get("v.oldValue");
    var isAfterInit = component.get('v.isAfterInit');

    if(isAfterInit && recordOldValue != recordValue  && typeof recordValue != 'undefined'){
        var value = (recordValue != null) ? recordValue.toString() : recordValue;
        this.updateRecord(component, value);
    }else{
        if(!$A.util.hasClass(component.find("toggle-edit-block"), 'hide') ){
            this.toggleToEdit(component);
        }
    }
}, 

updateRecord: function(component, recordValue) {
    var action = component.get("c.updateRecord");
    var fieldLabel = component.get('v.name');

    action.setParams({
        "objectName": component.get('v.targetObject'),
        "recordId": component.get('v.targetId'),
        "fieldName": component.get('v.targetFieldName'),
        "value": recordValue
    });

    action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            var returnValue = response.getReturnValue();
            if (returnValue) {
                var compEvents = component.getEvent("AITM_RefreshTableEvent");
                compEvents.fire();
                if(!$A.util.hasClass(component.find("toggle-edit-block"), 'hide') ){
                    this.toggleToEdit(component);
                }
                
                $A.get('e.force:refreshView').fire();
            }
        }else{
            this.showErrors(response);
        }
        
    });

    $A.enqueueAction(action);
},

getRecordValue: function(component, event) {
    var type = component.get("v.type");
    var recordValue;

    if(typeof type == 'undefined'){
        type = 'text';
    }
    if(type == "select"){
        recordValue = component.find("picklist-element").get('v.value');
    }else if(type == "date"){
        recordValue = component.get('v.dateValue');
    }else{
        if( typeof event != 'undefined' && 
            typeof event.currentTarget != 'undefined' && 
            typeof event.currentTarget.value != 'undefined'){
            recordValue = event.currentTarget.value;
        }else{
            recordValue = component.get('v.value');
        }
    }
    return recordValue;
},

getObject: function(component) {
    var targetObject = component.get('v.targetObject');
    var object = {};
    if(targetObject == 'AITM_Tender_Location_Line_Item__c'){
        object = component.get('v.lineItem');
    }else if(targetObject == 'AITM_Tender_Location__c'){
        object = component.get('v.tenderLocation');
    }
    return object;
},

toggleToEdit: function(component){
    if(component.get('v.isEditable')){
        this.toggleClass(component, 'toggle-text-block', 'hide');
        this.toggleClass(component, 'toggle-edit-block', 'hide');
    }
},

toggleClass: function(component, elementAuraId, toggleClass) {
    var element = component.find(elementAuraId);
    if(Array.isArray(element)){
        for(var i=0; i<element.length; i++){
        $A.util.toggleClass(element[i], toggleClass);
        }
    }else{
        $A.util.toggleClass(element, toggleClass);
    } 
},

showErrors: function(response){
    var errors = response.getError()[0];
        if(typeof errors.pageErrors != 'undefined' && errors.pageErrors.length > 0){
        for(var i=0; i<errors.pageErrors.length; i++){
            this.showToast('error', errors.pageErrors[i].message);
        }
    }
},

showToast: function(type, message) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        type: type,
        message: message,
        mode: "pester",
        duration: 500
    }); 
    toastEvent.fire();  
},

getUpdatedLineItem: function(component, event, helper) {
    var lineItemId = component.get('v.lineItemId');
    var action = component.get("c.getDebriefLineItemRecords");

    action.setParams({
        "recordId": lineItemId
    });
    action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            var returnValue = response.getReturnValue();
            if (returnValue != null && returnValue[0] != null){
                var stage = returnValue[0].AITM_Tender__r.AITM_Stage__c;
                component.set("v.currentStage", stage);
                
                var debriefLineItemId = returnValue[0].Id;
                component.set("v.debrieflineItemId", debriefLineItemId);
                
                this.handleViewSObject(component, event);
            }else {
                this.handleViewSObject(component, event)
            }
        }else{
            this.showErrors(response);
        }
    });
    $A.enqueueAction(action);
},

handleViewSObject : function(component, event) {
    var recordId;
    var target = event.target || event.srcElement;
    var stage = component.get('v.currentStage');
    if(stage == null || stage == 'undefined' || stage != 'Debrief'){
        recordId = target.getAttribute("data-recordid");
    }else{
        recordId = component.get('v.debrieflineItemId');
    }
    var evt = $A.get("e.force:navigateToSObject");
    evt.setParams({
        "recordId": recordId
    });
    evt.fire();
},

preventDefault : function(event) {
    event.stopPropagation();
    event.preventDefault();
},


open:function(component, event){
    component.set("v.isOpen",true);
        var lineItem = component.get('v.lineItem');
        var action = component.get('c.getDeliveryRecords');    
        action.setParams({
    "lineItemRecord":  lineItem
    
    });
    action.setCallback(this, function(response) {
    var state = response.getState();
    if (state === "SUCCESS") {
        if (response.getReturnValue() != '') {
        component.set("v.deliveryPoints",response.getReturnValue());

        }
    }
    });
    $A.enqueueAction(action);
},

close:function(component, event){
    component.set("v.isOpen",false);

},
updateSelected: function(component,event,helper) {
    var newId = component.get('v.deliveryId');  
    var lineItem = component.get('v.lineItemId') ;   
    var action = component.get('c.updateDeliveryRecords');
        
    action.setParams({
        "deliveryRecordId": newId,
        "lineItemId" :lineItem
        
     });

     action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
        if (response.getReturnValue() != '') {
            this.showToast('error',  response.getReturnValue());
        }
        else{
            this.close(component,event);

        }
        $A.get('e.force:refreshView').fire();
        }
    });
    $A.enqueueAction(action);
    }

})