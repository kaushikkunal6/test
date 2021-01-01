({
	doInit: function(component, event, helper) {
		helper.doInit(component); 
	},

	saveFormValues: function(component, event, helper) {
		helper.saveFormValues(component, event);
	},

	canceEditForm: function(component, event, helper) {
		helper.canceEditForm(component);
	},

	toggleToEdit: function(component, event, helper) {
	  helper.toggleToEdit(component);
	},

    hideEditBlock: function(component, event, helper){
      helper.hideEditBlock(component);
    },

    toggleSection: function(component, event, helper){
      helper.toggleSection(component, event);
    },

    showFormButtons: function(component, event, helper){
      helper.showFormButtons(component);
    },

    onRoundChange : function(component, event, helper) {
        helper.onRoundChange(component);
    },

})