({
  doInit: function(component){
    this.getPicklistValues(component, 'picklist-tender-location-status', 'AITM_Tender_Location__c', 'AITM_Status__c');
    this.getTableData(component, true);
  },
    /* getOldTaxFeeFlag it's a common function 
     * to decide Old/New fucntionality of Apply all Taxes and Fees should apply
     * based on the AITM_Select_to_Apply_Old_Taxes_and_Fees__c Flag on the Tender */
    getOldTaxFeeFlag: function(component, event){
        var recordId = component.get("v.recordId");
        var action = component.get("c.getTenderDetails");
		action.setParams({
            "recordId" : recordId
        });
        action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
              var returnValue = response.getReturnValue();
              component.set('v.isOldTaxFeeFlag', returnValue);
              if(returnValue == true){
                  	this.handleTaxesAndFeesFilters(component, event);
                  }
              else{
                      this.handleNewTaxesAndFees(component, event);
                  }
          }
            
        });
        $A.enqueueAction(action);
    },
    
    updateUnApproveTenderLocation: function(component,event) {
      var tenderLocation = component.get("v.tenderLocation");
      var action = component.get("c.updatetenderLocation");
      //this.showSpinner(component); 
      action.setParams({
          "tenderLocation": tenderLocation
      });
      action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
              
              //if (!result[0].AITM_Is_Straddled__c) {
                  //this.showToast('Success', 'The tender location is priced now');
              window.location.reload(); 
                  //component.set("v.isCheckedStraddle", result[0].AITM_Is_Straddled__c);
//component.find("straddle-taxes-fees").set("v.disabled", true);
              
              
          }
      });
      $A.enqueueAction(action);
  },
    
  getTableData: function(component, getTableMetadata) {
    var recordId = component.get("v.recordId");
    var action = component.get("c.getTableData");
    this.showSpinner(component); 
    action.setParams({
      "tenderLocationId": recordId
    });
    action.setCallback(this, function(actionResult) {
      var state = actionResult.getState();
      if (state === 'SUCCESS') {
        var result = actionResult.getReturnValue();
        component.set("v.tenderLocation", result.tenderLocation[0]);
        component.set("v.tenderLocationStatus", result.tenderLocation[0].AITM_Status__c);
        component.set("v.lineItems", result.lineItems);
        component.set("v.lineItemAcc",result.acc);
        component.set("v.isLocationStraddled", result.tenderLocation[0].AITM_Is_Straddled__c);
        component.set("v.isOldTender", result.lineItems[0].AITM_Old_Taxes_Fees_Flag__c);
          var isOldTender = component.get("v.isOldTender");
          if(!isOldTender){
              component.set("v.productDefault", result.lineItems[0].AITM_Product_Default__c);
              component.set("v.deliveryType", result.lineItems[0].AITM_Delivery_Method__c);
              component.set("v.deliveryPoint", result.lineItems[0].AITM_Delivery_Point_Info__c);
              component.set("v.accountClassification", result.lineItems[0].AITM_Account__r.AITM_Account_Classification__c);
              var isApplyAll = component.get("v.isApplyAll");
              var listOfItems = component.get("v.lineItems");
              var productDefault = component.get("v.productDefault");
              var deliveryType = component.get("v.deliveryType");
              var deliveryPoint = component.get("v.deliveryPoint");
              var accountClassification = component.get("v.accountClassification");
                if(result.lineItems.length > 1) {
                  for (var key = 0; key < listOfItems.length; key++) {
                      var product = listOfItems[key].AITM_Product_Default__c;
                      var delType = listOfItems[key].AITM_Delivery_Method__c;
                      var delPoint = listOfItems[key].AITM_Delivery_Point_Info__c;
                      var accClassify = listOfItems[key].AITM_Account__r.AITM_Account_Classification__c;
                      if((productDefault !== product) || (deliveryType !== delType) || (deliveryPoint !== delPoint) || (accountClassification != accClassify)){
                          component.find("Apply-to-all-taxes-fees").set("v.disabled", true);
                          component.set("v.applyToAllTaxesCheck",false);
                          break;
                      }
                      else{
                          component.find("Apply-to-all-taxes-fees").set("v.disabled", false);
                      }
                  }
               }
              if(result.lineItems.length < 1 || result.lineItems.length == '1'){
                  component.set("v.applyToAllTaxesCheck",false);
                  component.find("Apply-to-all-taxes-fees").set("v.disabled", true);
              }
      	}
        var isLocationStraddled = component.get("v.isLocationStraddled");
        if(isLocationStraddled){
            component.set("v.isCheckedStraddle", true);
        } else{
            //component.find("straddle-taxes-fees").set("v.disabled", true);
		    component.set("v.isCheckedStraddle", result.tenderLocation[0].AITM_Is_Straddled__c);
        }
        if(result.lineItems.length < 1 || result.lineItems.length == '1'){
            component.set("v.isCheckedStraddle", false);
            //component.find("straddle-taxes-fees").set("v.disabled", true);
        }
        if(getTableMetadata == true) {
          this.getTableMetadata(component);
          this.getFieldsAccess(component);
        }
      } 
      this.hideSpinner(component);
    }); 
    $A.enqueueAction(action);  
  },
    
  updateUnStraddledLineItem: function(component,event,helper) {
      var recordId = component.get("v.recordId");
      var action = component.get("c.updateLocationAndLineItemToUnStraddled");
      this.showSpinner(component); 
      action.setParams({
          "locationId": recordId
      });
      action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
              var result = response.getReturnValue();
              if (!result[0].AITM_Is_Straddled__c) {
                  this.showToast('Success', 'You have successfully un-straddled Taxes and Fees. Henceforth, straddling checkbox will be disabled for this location.');
                  component.set("v.isCheckedStraddle", result[0].AITM_Is_Straddled__c);
                  //component.find("straddle-taxes-fees").set("v.disabled", true);
              }
              $A.get('e.force:refreshView').fire();
          }
      });
      $A.enqueueAction(action);
  },

  getTableMetadata: function(component){
    var action = component.get("c.getTableMetadata");
    action.setStorable();
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
          var returnValue = response.getReturnValue();
          component.set('v.tableMetadata', returnValue);
      }   
    });
    $A.enqueueAction(action);   
  },

  changeTenderLocationStatus: function(component){
    var tenderLocation = component.get('v.tenderLocation');
    var statusComponent = component.find('picklist-tender-location-status');
    var status = statusComponent.get('v.value');
    var statusOld = component.get('v.tenderLocationStatus');
    var recordId = component.get("v.recordId");
    this.showSpinner(component);

    if(statusOld != status){
      var action = component.get("c.getTableData");
      action.setParams({"tenderLocationId": recordId});
      action.setCallback(this, function(actionResult) {
        var state = actionResult.getState();
        if (state === 'SUCCESS'){
          var result = actionResult.getReturnValue();
          component.set("v.tenderLocation", result.tenderLocation[0]);
          component.set("v.tenderLocationStatus", result.tenderLocation[0].AITM_Status__c)
          component.set("v.lineItems", result.lineItems);
          component.set("v.lineItemAcc",result.acc);
          if(status == this.getStatus(component, 'priced') && !this.isAllMandatoryInformationProvided(component)){
            $A.get('e.force:refreshView').fire();
          } else {
            this.updateRecord(component, 'AITM_Tender_Location__c', tenderLocation.Id, 'AITM_Status__c', status, statusOld);
          }
        } 
        this.hideSpinner(component);
      }); 
      $A.enqueueAction(action);  
    }
    this.toggleToEdit(component);
  },

  updateRecord: function(component, objectName, recordId, fieldName, value, valueOld) {
    this.showSpinner(component);
    var action = component.get("c.updateRecord");
    var lineItems = component.get("v.lineItems");
    action.setParams({
      "objectName": objectName,
      "recordId": recordId,
      "fieldName": fieldName,
      "value": value,
      "lineItems": lineItems
    });

    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
          this.afterRecordUpdate(component,objectName, recordId, fieldName, value, response);
      }else{
        this.afterRecordUpdateFail(component,objectName, recordId, fieldName, value, valueOld, response);
        this.showErrors(response);
      }
      this.hideSpinner(component);
    });
    $A.enqueueAction(action);
  },

  afterRecordUpdate: function(component, objectName, recordId, fieldName, value, response) {
    if(objectName == 'AITM_Tender_Location__c'){
      this.adterTenderLocationUpdate(component, recordId, fieldName, value, response);
    }
  },

  afterRecordUpdateFail: function(component, objectName, recordId, fieldName, value, valueOld, response) {
    if(objectName == 'AITM_Tender_Location__c'){
      this.adterTenderLocationUpdateFail(component, recordId, fieldName, value, response);
    }
  },

  adterTenderLocationUpdate: function(component, recordId, fieldName, value, response) {
    var tenderLocation = response.getReturnValue();
    component.set('v.tenderLocation', tenderLocation);
    component.set('v.tenderLocationStatus', tenderLocation.AITM_Status__c);
    $A.get('e.force:refreshView').fire();
  },

  adterTenderLocationUpdateFail: function(component, recordId, fieldName, value, valueOld, response) {
    component.set('v.tenderLocationStatus', valueOld);
  },

  isAllMandatoryInformationProvided: function(component){
    var lineItems = component.get('v.lineItems');
    var tenderLocation = component.get('v.tenderLocation');
    var result = true;
    var lineItemsErrors = [];
    /*var tenderLocationErrors = [];

    if(typeof tenderLocation != 'undefined'){
      if(tenderLocation.AITM_Taxes_Fees__c == null){
        tenderLocationErrors.push('Taxes & Fees');
        result = false;
      }
    }else{
      result = false;
    }*/

    if(typeof lineItems != 'undefined') {
      for(var i=0; i<lineItems.length; i++) {
		  
		if(lineItems[i].AITM_Start_Date__c == null) {
          lineItemsErrors.push('Start Date');
          result = false;
        }    
        
        if(lineItems[i].AITM_End_Date__c == null) {
          lineItemsErrors.push('End Date');
          result = false;
        } 
		
        if(lineItems[i].AITM_Pricing_Basis__c == null) {
          lineItemsErrors.push('pricing basis'); 
          result = false;
        }

        if(lineItems[i].AITM_Pricing_Basis__c != null && lineItems[i].AITM_Pricing_Basis__r.AITM_Type__c =='C' && lineItems[i].AITM_Current_Value__c == null){
         lineItemsErrors.push('Current Value');
          result = false;
        }

        if(lineItems[i].AITM_Pricing_Basis__c != null && lineItems[i].AITM_Pricing_Basis__r.AITM_Type__c =='D' && lineItems[i].AITM_Offered_Differential__c == null){
         
          lineItemsErrors.push('Offered Differential');
          result = false;
        }

        if(lineItems[i].AITM_Location_Delivery_Point__c == null) {
          lineItemsErrors.push('delivery point');
          result = false;
        }

        if(lineItems[i].AITM_Currency__c == null) {
          lineItemsErrors.push('currency');
          result = false;
        }

        if(lineItems[i].AITM_Unit_Of_Measure__c == null) {
          lineItemsErrors.push('unit of measure');
          result = false;
        }
          
        /*  
        if(lineItems[i].AITM_Credit_Days__c == null) {
          lineItemsErrors.push('Credit Days');
          result = false;
        }  
          
        if(lineItems[i].AITM_Exchange__c == null) {
          lineItemsErrors.push('Exchange');
          result = false;
        } 
        
        if(lineItems[i].AITM_Invoice_Frequency__c == null) {
          lineItemsErrors.push('Invoice Frequency');
          result = false;
        }
                  
          
        if(lineItems[i].AITM_Rebate__c != null && lineItems[i].AITM_Duration__c == null) {
          lineItemsErrors.push('Duration');
          result = false;
        }  
          
        if(lineItems[i].AITM_Rebate__c != null && lineItems[i].AITM_Quantity__c == null) {
          lineItemsErrors.push('Quantity');
          result = false;
        } */
      }
    } else {
      result = false;
    }

    if (lineItemsErrors.length > 0) {
      lineItemsErrors = lineItemsErrors.filter(function(item, pos, self) {
        return self.indexOf(item) == pos;
      });
      this.showToast('error', 'Please fill in field(s): ' + lineItemsErrors.join(', ') + ' for all Tender Location Items');
    }
      if(typeof tenderLocation != 'undefined' && lineItemsErrors.length == 0 ){
      if(tenderLocation.AITM_Approve_the_Service_Level__c == false && tenderLocation.AITM_Status__c =='Awaiting price'){
        //tenderLocationErrors.push('Taxes & Fees');
        component.set("v.customerServiceLevel",tenderLocation.AITM_Customer_Service_Level__c);
       component.set("v.locationServiceLevel",tenderLocation.AITM_Location_Default_Service_Level__c);   
        component.set("v.isConformApprove",true);
        result = false;
      }
    }else{
      result = false;
    }  

   /* if (tenderLocationErrors.length > 0) {
      tenderLocationErrors = tenderLocationErrors.filter(function(item, pos, self) {
        return self.indexOf(item) == pos;
      });
      this.showToast('error', 'Please fill in field(s): ' + tenderLocationErrors.join(', ') + ' for Tender Location');
    }*/
    return result;
  },

  showErrors: function(response){
    var errors = response.getError()[0];
    if(typeof errors.pageErrors != 'undefined' && errors.pageErrors.length > 0) {
      for(var i=0; i<errors.pageErrors.length; i++) {
        this.showToast('error', errors.pageErrors[i].message);
      }
    }
  },

  showSuccess : function(response){
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
    title: "Success!",
    message: "Pricing Basis updated for all customers",
    type: "success"
    });
    toastEvent.fire();
  },

  showTaxesSuccess : function(response){
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
    title: "Success!",
    message: "Taxes and Fees updated for all customers",
    type: "success"
    });
    toastEvent.fire();
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

  openModel: function(component, event, helper) {
    component.set("v.isOpen", true);
  },
  openModel_TnF: function(component, event, helper) {
    component.set("v.isOpen_TnF", true);
  },

  closeModel: function(component, event, helper) { 
    component.set("v.isOpen", false);
    component.set("v.isOpen_TnF", false);
    component.set("v.applyToAllTaxesCheck",false);
    component.set("v.tenderLocation.AITM_Apply_to_all__c", false);
    component.set("v.isConfirmUnStraddle", false);
  },

  getStatus: function(component, statusName) {
    var status = component.get('v.tenderLocationStatuses');
    return (typeof status[statusName] != 'undefined') ? status[statusName] : null;
  },

  getPicklistValues: function(component, auraId, targetObject, targetFieldName){
    var select = component.find(auraId);

    var action = component.get("c.getPickValues");
    var targetObject = targetObject;
    var targetFieldName = targetFieldName;
    var value = select.get('v.value');
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
  },

  toggleToEdit: function(component){
    this.toggleClass(component, 'toggle-text-block', 'hide');
    this.toggleClass(component, 'toggle-edit-block', 'hide');
  },

  hideEditBlock: function(component){
    this.removeClass(component, 'toggle-text-block', 'hide');
    this.addClass(component, 'toggle-edit-block', 'hide');
  },


  toggleClass: function(component, auraId, toggleClass) {
    var element = component.find(auraId);
    if(Array.isArray(element)){
      for(var i=0; i<element.length; i++){
        $A.util.toggleClass(element[i], toggleClass);
      }
    }else{
        $A.util.toggleClass(element, toggleClass);
    } 
  },

  removeClass: function(component, auraId, toggleClass) {
    var element = component.find(auraId);
    if (Array.isArray(element)){
      for(var i=0; i<element.length; i++){
        $A.util.removeClass(element[i], toggleClass);
      }
    } else{
        $A.util.removeClass(element, toggleClass);
    } 
  },

  addClass: function(component, auraId, toggleClass) {
    var element = component.find(auraId);
    if(Array.isArray(element)){
      for(var i=0; i<element.length; i++){
        $A.util.addClass(element[i], toggleClass);
      }
    }else{
        $A.util.addClass(element, toggleClass);
    } 
  },  

  norevision: function(component, event){
    var tenderLocation = component.get('v.tenderLocation');
    var checkbox = event.getSource();
    var value = checkbox.get("v.value");
    this.updateRecord(component, 'AITM_Tender_Location__c', tenderLocation.Id, 'AITM_No_Revision__c', value, null);
  },

  deleteSelectedHelper: function(component, event, deleteRecordsIds) {
    var action = component.get('c.deleteRecords');
    action.setParams({
      "lstRecordId": deleteRecordsIds
    });

    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        if (response.getReturnValue() != '') {
          this.showToast('error', 'Record can not be deleted.' + response.getReturnValue());      
        } else {
		  var isLocationStraddled = component.get("v.isLocationStraddled");
          if(isLocationStraddled){
             this.updateUnStraddledLineItem(component,event,helper);
          }
        }
        $A.get('e.force:refreshView').fire();
      }
    });
    $A.enqueueAction(action);
  },

  cloneSelectedHelper: function(component,event,helper) {
    var cloneNewId = component.get("v.cloneId");      
    var action = component.get('c.cloneRecords');
      
    action.setParams({
      "cloneRecordId": cloneNewId  
    });

    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        if (response.getReturnValue() != '') {
          this.showToast('error',  response.getReturnValue());
        }
        var isLocationStraddled = component.get("v.isLocationStraddled");
        if(isLocationStraddled){
           this.updateUnStraddledLineItem(component,event,helper);
        }
		$A.get('e.force:refreshView').fire();
      }
    });
    $A.enqueueAction(action);
  },
  newIncludeInRevised:function(component,event,reviseRecordsIds) {
    var tenderLocation = component.get('v.tenderLocation');
    var checkbox = event.getSource();
    var value = checkbox.get("v.value");
    var action = component.get("c.getIdsForRevision");
    action.setParams({
      "Ids":reviseRecordsIds
    });
    action.setCallback(this, function(actionResult) {
      var state = actionResult.getState();
      if (state === 'SUCCESS'){
          var result = actionResult.getReturnValue();     
          this.updateSelectedRecords(component, 'AITM_Tender_Location__c', tenderLocation.Id, 'AITM_Include_In_Revised_Offer__c', value, null,result);
      }
    });
    $A.enqueueAction(action);
  },

  updateSelectedRecords: function(component, objectName, recordId, fieldName, value, valueOld,LineItemIds) {
    this.showSpinner(component);
    var action = component.get("c.updateRecord");
    action.setParams({
      "objectName": objectName,
      "recordId": recordId,
      "fieldName": fieldName,
      "value": value,
      "lineItems": LineItemIds
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
          this.afterRecordUpdate(component,objectName, recordId, fieldName, value, response);
      }else{
        this.afterRecordUpdateFail(component,objectName, recordId, fieldName, value, valueOld, response);
        this.showErrors(response);
      }
      this.hideSpinner(component);
    });
    $A.enqueueAction(action);
  },

  handleFilters: function(component, event){       
    var action = component.get("c.updateTenderLocationPricingBasis");
    var tenderLocation = component.get('v.tenderLocation');
    action.setParams({
    "tenderLocation" : tenderLocation});
    action.setCallback(this, function(response){
    var state = response.getState();
    if(state == 'SUCCESS') {
      $A.get('e.force:refreshView').fire();
        this.showSuccess(state);
        component.set("v.isOpen", false);
      }
    });
    $A.enqueueAction(action);
  },

  handleTaxesAndFeesFilters: function(component, event){       
    var action = component.get("c.updateTaxesandFeesToAllTLLI");
    var tenderLocation = component.get('v.tenderLocation');
    action.setParams({
    "tenderLocation" : tenderLocation});
    action.setCallback(this, function(response){
    var state = response.getState();
    if(state == 'SUCCESS') {
      $A.get('e.force:refreshView').fire();
        this.showTaxesSuccess(state);
		component.set("v.isOpen_TnF", false);
      }
    });
    $A.enqueueAction(action);
  },
	/* To apply New format of Taxes & Fees should apply for New Tender */
    handleNewTaxesAndFees: function(component, event){ 
    var action = component.get("c.ApplyToAllTaxesFeesMethod");
    var tenderLocation = component.get('v.tenderLocation');
    action.setParams({
    "tenderLocation" : tenderLocation});
    action.setCallback(this, function(response){
    var state = response.getState();
    if(state == 'SUCCESS') {
      $A.get('e.force:refreshView').fire();
        this.showTaxesSuccess(state);
        component.set("v.isOpen_TnF", false);
      }
    });
    $A.enqueueAction(action);
  },
    
  getFieldsAccess: function(component) {
    var action = component.get("c.getFieldsAccess");
    var tenderLocation = component.get('v.tenderLocation');

    action.setParams({
        "objectName": "AITM_Tender_Location__c",
        "tenderLocationId" : tenderLocation.Id
    });
    action.setCallback(this, function(actionResult) {
        var state = actionResult.getState();
        if (state === 'SUCCESS'){
            var result = actionResult.getReturnValue();
            component.set("v.fieldsAccess", result);
        } 
        
      }); 
    $A.enqueueAction(action);  
  },

  showSpinner : function(component) {
    var spinner = component.find("tenderLocationNewOfferSpinner");
    $A.util.removeClass(spinner, "slds-hide");
  },

  hideSpinner : function(component) {
    var spinner = component.find("tenderLocationNewOfferSpinner");
    $A.util.addClass(spinner, "slds-hide");
  }
})