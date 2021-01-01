({

doInit : function(component, event, helper) {       
  helper.doInit(component);
},
updateUnApproveTenderLocation: function(component,event,helper){
      component.set("v.isConformApprove", false);
        helper.updateUnApproveTenderLocation(component, event, helper);
    },
closeApprovalConfirmBox: function(component, event, helper){
    component.set("v.isConformApprove", false);
    window.location.reload();
    
},    

onClone:function(component,event,helper){
  var selected = event.getSource().get("v.text");
  component.set("v.cloneId",selected); 
  },
  cloneSelected: function(component, event, helper) {
    helper.cloneSelectedHelper(component, event,helper);
  },
  
  deleteSelected: function(component, event, helper) {
  var delId = [];
  var getAllId = component.find("boxPack");
  if(! Array.isArray(getAllId)){
    if (getAllId.get("v.value") == true) {
      delId.push(getAllId.get("v.text"));
    }
  }else{
    for (var i = 0; i < getAllId.length; i++) {
      if (getAllId[i].get("v.value") == true) {
        delId.push(getAllId[i].get("v.text"));
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
  helper.getTableData(component, false);
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
}
})