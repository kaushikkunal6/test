({
    doInit : function(component, event, helper) {
        helper.doInit(component);
    },
    canceEditForm: function(component, event, helper) {
		helper.canceEditForm(component);
	},
    saveFormValues: function(component, event, helper) {
		helper.saveFormValues(component, event);
	},
    checkedTheBox: function(component, event, helper) {
		   component.set("v.approveChecked",true);              
            helper.toggleToEdit(component,event);
        
	},
    
    
    showFormButtons: function(component, event, helper){
      helper.showFormButtons(component);
    },
     toggleSection: function(component, event, helper) {
	  helper.toggleSection(component,event);
	},
    	toggleToEdit: function(component, event, helper) {
	  helper.toggleToEdit(component);
	},
    
})