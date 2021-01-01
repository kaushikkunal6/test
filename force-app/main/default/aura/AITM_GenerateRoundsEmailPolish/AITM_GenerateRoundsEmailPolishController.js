({
  doInit: function(component, event, helper) {
    helper.doInit(component);
  },

  attach: function(component, event, helper) {
    helper.attach(component, event);
  },

  closeModel: function(component, event, helper) {
    component.set("v.isOpen", false);
  },

  save: function(component, event, helper) {
    helper.saveBidsInByDate(component);
  }
});