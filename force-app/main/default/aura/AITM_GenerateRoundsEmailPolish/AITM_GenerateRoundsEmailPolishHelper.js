({
  doInit: function(component) {
    component.set("v.isOpen", true);
    //this.generate(component);
  },

  attach: function(component, event) {
    var tenderId = component.get("v.recordId");
    if (event && event.getParam("emailBody")) {
      var action = component.get("c.attachEmail");
      var dataObject = {
        tenderId: tenderId,
        emailDTO: event.getParam("emailBody")
      };
      action.setParams({
        emailDTOWithTenderId: JSON.stringify(dataObject)
      });

      action.setCallback(this, function(response) {
        var state = response.getState();
        if (component.isValid() && state === "SUCCESS") {
          this.showToast(
            "success",
            "Success!",
            $A.get("$Label.c.AITM_GenerateFeedbackEmailSuccess")
          );
          this.refreshView();
          this.closeModalWindow();
          this.updateStageChange(component, event);
          //this.sendForceChangeStageEvent();
        }
      });
      $A.enqueueAction(action);
    }
  },
  saveBidsInByDate: function(component) {
    var tenderId = component.get("v.recordId");
    var selectNewDate = component.find("NewBidsDateInput");
    var newDate = selectNewDate.get("v.value");
    var action = component.get("c.updateBidsInByDate");
    action.setParams({
      tenderId: tenderId,
      newDate: newDate
    });

    action.setCallback(this, function(response) {
      var state = response.getState();
      if (component.isValid() && state === "SUCCESS") {
        var returnValue = response.getReturnValue();
        if (returnValue == "1") {
          this.showToast(
            "error",
            "error",
            "Please enter a date greater than the current date"
          );
          component.set("v.isOpen", false);
          this.closeModalWindow();
        } else {
          this.showToast(
            "Success",
            "Success",
            "The date has been successfully updated"
          );
          component.set("v.isOpen", false);

          this.generate(component);
        }
      }
    });
    $A.enqueueAction(action);
  },

  updateStageChange: function(component, event) {
    var tenderId = component.get("v.recordId");
    var action = component.get("c.updateTenderChange");
    action.setParams({
      tenderId: tenderId
    });

    action.setCallback(this, function(response) {
      var state = response.getState();
      if (component.isValid() && state === "SUCCESS") {
        var returnValue = response.getReturnValue();
        if (returnValue) {
          this.sendForceChangeStageEvent();
        }
      }
    });
    $A.enqueueAction(action);
  },

  generate: function(component) {
    var tenderId = component.get("v.recordId");
    var action = component.get("c.generate");
    action.setParams({
      tenderId: tenderId,
      locationType: "Polish"
    });

    action.setCallback(this, function(response) {
      var state = response.getState();
      if (component.isValid() && state === "SUCCESS") {
        var returnValue = response.getReturnValue();
        this.createEmailGeneratorComponent(component, returnValue);
      } else if (state == "ERROR") {
        let responseErrors = response.getError();
        let errorMessage = this.getErrorMessage(responseErrors);
        this.closeModalWindow();
        this.showToast("warning", "Warning", errorMessage);
      } else {
        this.closeModalWindow();
      }
    });
    $A.enqueueAction(action);
  },

  getErrorMessage: function(responseErrors) {
    let message = "Unknown error";

    if (
      responseErrors &&
      Array.isArray(responseErrors) &&
      responseErrors.length > 0
    ) {
      message = responseErrors[0].message;
    }

    return message;
  },

  createEmailGeneratorComponent: function(component, emailDTOInstance) {
    var container = component.find("EmailGeneratorHolder");
    $A.createComponent(
      "c:AITM_EmailGenerator",
      { emailDTO: emailDTOInstance },
      function(cmp) {
        container.set("v.body", [cmp]);
      }
    );
  },

  showToast: function(type, title, message) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: title,
      type: type,
      message: message
    });

    toastEvent.fire();
  },

  refreshView: function() {
    $A.get("e.force:refreshView").fire();
  },

  closeModalWindow: function() {
    $A.get("e.c:AITM_ClosePathQuickAction").fire();
  },

  sendForceChangeStageEvent: function() {
    $A.get("e.c:AITM_ForceChangeStageEvent").fire();
  }
});