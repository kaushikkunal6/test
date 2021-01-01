({
  doInit: function (component) {
    var emailDTO = component.get("v.emailDTO");
    this.unwrapAddresses(component, emailDTO);
    this.unwrapSubject(component, emailDTO);
    this.unwrapBodies(component, emailDTO);
    this.unwrapAttachments(component, emailDTO);
  },
  
  removeAttachment: function (component, index, helper) {
    var lines = component.get("v.attachments");
    lines.splice(index, 1);
    component.set("v.attachments", lines);
  },

  handleLoad: function (component, event) {
    var emailObject = event.getParam("emailBody");
    if (emailObject.to) {
      var toAddresses = "";
      for (var index = 0; index < emailObject.to.length; index++) {
        toAddresses += emailObject.to[index] + ";";
      }
      component.set("v.toAddress", toAddresses);
    }
    component.set("v.subject", emailObject.subject);
    component.set("v.attributes", event.getParam("attachments"));
  },

  sendEmail: function (component, event) {
    var emailDTO = this.wrapEmailDTO(component);
    var disabling = event.getSource();
    disabling.set("v.disabled", true);
    var action = component.get("c.sendEmailMessage");
    action.setParams({
      dto: JSON.stringify(emailDTO),
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      var result = response.getReturnValue();
      if (component.isValid() && state === "SUCCESS") {
        if (result != "") {
          this.showToast("Error", "", result);
          disabling.set("v.disabled", false);
        } else {
          this.fireEmailSentEvent(emailDTO);
        }
      }
    });
    $A.enqueueAction(action);
  },

  showToast: function (type, title, message) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: title,
      type: type,
      duration: " 7000",
      message: message,
    });

    toastEvent.fire();
  },

  fireEmailSentEvent: function (emailDTO) {
    var emailSentEvent = $A.get("e.c:AITM_EmailGeneratorSent");
    emailSentEvent.setParams({
      emailBody: emailDTO,
    });
    emailSentEvent.fire();
  },

  closeModalWindow: function () {
    $A.get("e.c:AITM_ClosePathQuickAction").fire();
  },

  unwrapAddresses: function (component, emailDTO) {
    var toAddresses = "";
    var ccAddresses = "";

    if (emailDTO.emailAddresses) {
      for (var i = 0; i < emailDTO.emailAddresses.length; i++) {
        if (emailDTO.emailAddresses[i].isTo) {
          if (toAddresses) {
            toAddresses =
              toAddresses + ";" + emailDTO.emailAddresses[i].targetEmail;
          } else {
            toAddresses = emailDTO.emailAddresses[i].targetEmail;
          }
        } else {
          if (ccAddresses) {
            ccAddresses =
              ccAddresses + ";" + emailDTO.emailAddresses[i].targetEmail;
          } else {
            ccAddresses = emailDTO.emailAddresses[i].targetEmail;
          }
        }
      }
    }
    component.set("v.toAddress", toAddresses);
    component.set("v.ccAddresses", ccAddresses);
  },

  unwrapSubject: function (component, emailDTO) {
    component.set("v.subject", emailDTO.subject);
  },

  unwrapBodies: function (component, emailDTO) {
    component.set("v.bodies", emailDTO.emailBodies);
  },

  unwrapAttachments: function (component, emailDTO) {
    if (emailDTO.emailAttachments) {
      component.set("v.attachments", emailDTO.emailAttachments);
    }
  },

  wrapEmailDTO: function (component) {
    var addresses = this.getAddresses(component);
    var subject = component.get("v.subject");
    var emailBodies = component.get("v.bodies");
    var emailDTO = component.get("v.emailDTO");
    var attachments = component.get("v.attachments");

    emailDTO.emailAddresses = addresses;
    emailDTO.subject = subject;
    emailDTO.emailBodies = emailBodies;
    emailDTO.emailAttachments = attachments;
    return emailDTO;
  },

  getAddresses: function (component) {
    var result = [];
    var toAddresses = component.get("v.toAddress").split(";").filter(Boolean);
    var ccAddresses = component.get("v.ccAddresses").split(";").filter(Boolean);

    for (var i = 0; i < toAddresses.length; i++) {
      result.push({ isTo: true, targetEmail: toAddresses[i] });
    }

    for (var i = 0; i < ccAddresses.length; i++) {
      result.push({ isTo: false, targetEmail: ccAddresses[i] });
    }

    return result;
  },
});