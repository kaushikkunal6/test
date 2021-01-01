({

doInit : function(component, event, helper) {       
  helper.doInit(component,event);
},
    updateUnApproveTenderLocation: function(component,event,helper){
      component.set("v.isConformApprove", false);
        helper.updateUnApproveTenderLocation(component, event, helper);
    },
closeApprovalConfirmBox: function(component, event, helper){
    component.set("v.isConformApprove", false);
    window.location.reload();
    
},    

 cloneSelected: function(component, event, helper) {
    helper.cloneSelectedHelper(component, event,helper);
 },
  
  deleteSelected: function(component, event, helper) {
      var delId = [];
  var getAllId = component.find("boxPack");
  if(! Array.isArray(getAllId)){
    if (getAllId.get("v.checked") == true) {
      delId.push(getAllId.get("v.value"));
    }
  }else{
    for (var i = 0; i < getAllId.length; i++) {
      if (getAllId[i].get("v.checked") == true) {
        delId.push(getAllId[i].get("v.value"));
      }
      }
    } 
    helper.deleteSelectedHelper(component, event, delId);
  },
  newIncludeInRevisedOffer:function(component,event,helper){
    var revId = [];
    var getRevAllId = component.find("boxPack2");
    if(! Array.isArray(getRevAllId)){
      if (getRevAllId.get("v.value") == true) {
        revId.push(getRevAllId.get("v.text"));
      }
    }else{
      for (var i = 0; i < getRevAllId.length; i++) {
        if (getRevAllId[i].get("v.value") == true) {
          revId.push(getRevAllId[i].get("v.text"));
        }
        }
      } 
      helper.newIncludeInRevised(component, event, revId);
    },
handleRefreshTableEvent: function(component, event, helper) {
  component.set("v.handlePartialRefresh", false);
  helper.getTableData(component,event,false);
},
toggleToEdit: function(component, event, helper) {
  helper.toggleToEdit(component);
},
hideEditBlock: function(component, event, helper){
  helper.hideEditBlock(component);
},
changeTenderLocationStatus: function(component, event, helper){
  helper.changeTenderLocationStatus(component);
},
includeInRevisedOffer: function(component, event, helper){
  helper.includeInRevisedOffer(component, event);
},
norevision: function(component, event, helper){    
  helper.norevision(component, event);
},
handleFilters: function(component, event, helper){    
helper.handleFilters(component, event);
},
    /*Calling handleNewTaxesAndFees fucntion in component to apply Taxes and Fees 
     *  Commented helper.handleNewTaxesAndFees and calling getOldTaxFeeFlag it's a common function 
     * to decide Old/New functionality of Apply all Taxes and Fees should apply
     * based on the AITM_Select_to_Apply_Old_Taxes_and_Fees__c Flag on the Tender */
handleNewTaxesAndFees: function(component, event, helper){
    //helper.handleNewTaxesAndFees(component, event); 
    helper.getOldTaxFeeFlag(component, event);
},
openModel: function(component, event, helper){
  helper.openModel(component, event);
},
openModel_TnF: function(component, event, helper){
  helper.openModel_TnF(component, event);
},
closeModel: function(component, event, helper){
  helper.closeModel(component, event);
},
toggle: function(component, event, helper){
  helper.toggle(component, event);
},
openStraddleModel: function(component, event, helper){
    //var state = component.find("straddle-taxes-fees").get("v.value");
	var state = true;
    if(!state){
        component.set("v.isConfirmUnStraddle", true);
    }
},
closeStraddleConfirmBox: function(component, event, helper){
    component.set("v.isConfirmUnStraddle", false);
    component.set("v.isCheckedStraddle", true);
},
updateUnStraddledLineItem: function(component, event, helper){
  component.set("v.isConfirmUnStraddle", false);
  helper.updateUnStraddledLineItem(component, event, helper);
},
    showHide : function(component, event, helper) {
        let capturedCheckboxName = event.getSource().get("v.value");
  		let selectedCheckBoxes =  component.get("v.selectedCheckBoxes");
  		if(selectedCheckBoxes.indexOf(capturedCheckboxName) > -1){
   			selectedCheckBoxes.splice(selectedCheckBoxes.indexOf(capturedCheckboxName), 1);
        } else {
   			selectedCheckBoxes.push(capturedCheckboxName);
  		}
  		component.set("v.selectedCheckBoxes", selectedCheckBoxes);
        
        if(Array.isArray(selectedCheckBoxes)) {
            component.find("cloneenable").set("v.disabled", !selectedCheckBoxes.length);
        	component.find("deleteenable").set("v.disabled", !selectedCheckBoxes.length);
        }
        //var selected = capturedCheckboxName;
  		component.set("v.cloneId",capturedCheckboxName);    
    },
    handleSplitScreen : function(component, event, helper) {
        var getSelectRecord = event.getSource().get("v.name");
        component.set("v.handlePartialRefresh", true);
        component.set("v.selectedLineId",event.getSource().get("v.name"));
        helper.handleSplitEvent(component, event, getSelectRecord);
    },
    showtooltip : function(component, event, helper) {
        if(event.currentTarget.getAttribute("data-value") == 'AITM_Percentage_Volume_Offered__c'){
            var hoverRowLineId = event.currentTarget.getAttribute("data-target");
            component.set("v.hoverRow", parseInt(event.target.dataset.index));
            component.set("v.hoverRowLineId",hoverRowLineId);
            var items = component.find("hover");
            var currentIndex = parseInt(event.target.dataset.index);
        }
        if(event.currentTarget.getAttribute("data-value") == 'AITM_Pricing_Basis__r.Name'){
            var hoverRowLineIdprice = event.currentTarget.getAttribute("data-target");
            component.set("v.hoverRowPrice", parseInt(event.target.dataset.index));
            component.set("v.hoverRowLineIdPricing",hoverRowLineIdprice);
            var items = component.find("hoverPrice");
            var currentIndex = parseInt(event.target.dataset.index);
        }
        if(event.currentTarget.getAttribute("data-value") == 'AITM_Delivery_Point_Info__c'){
            var hoverRowLineIdprice = event.currentTarget.getAttribute("data-target");
            component.set("v.hoverRowdelpoint", parseInt(event.target.dataset.index));
            component.set("v.hoverRowLineIddelpoint",hoverRowLineIdprice);
            var items = component.find("hoverdelpoint");
            var currentIndex = parseInt(event.target.dataset.index);
        }
    },
	
    hidetooltip : function(component, event, helper) {
        component.set("v.hoverRowLineId","");
        var items = component.find("hover");
        component.set("v.hoverRow",-1);
        component.set("v.hoverRowLineIdPricing","");
        var items = component.find("hoverPrice");
        component.set("v.hoverRowPrice",-1);
         component.set("v.hoverRowLineIddelpoint","");
        var items = component.find("hoverdelpoint");
        component.set("v.hoverRowdelpoint",-1);
    },
    
    handlePartialRefreshFromLWCEvent : function(component, event,helper) {
        var getSelectRecord = event.getSource().get("v.name");   
        component.set("v.handlePartialRefresh", true);
		helper.getTableData(component,event,false);
    }
})