({
  doInit: function (component, event, helper) {
    helper.doInit(component);
  },

  handleLoad: function (component, event, helper) {
    helper.handleLoad(component, event);
  },
  
  removeAttachment: function (component, event, helper) {
    var index = event.target.dataset.index;
    helper.removeAttachment(component, index,helper);
  },

  close: function (component, event, helper) {
    helper.closeModalWindow();
  },

  send: function (component, event, helper) {
    helper.sendEmail(component, event);
  },
});