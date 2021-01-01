({
   getStateData : function(component) {
      let getCurrentTenderStage = component.get("c.getStagesForTender");
      getCurrentTenderStage.setParams({"tenderId" : component.get("v.recordId")});
      getCurrentTenderStage.setCallback(this, function(response) {
         let stageSeparator = response.getReturnValue();
         if(stageSeparator) {
            component.set("v.completedTenderStages", stageSeparator.completedTenderStages);
            component.set("v.currentTenderStage", stageSeparator.currentTenderStage);
            component.set("v.lastChosenElementName", stageSeparator.currentTenderStage);
            component.set("v.chosenElementName", stageSeparator.currentTenderStage);
            component.set("v.uncompletedTenderStages", stageSeparator.uncompletedTenderStages);

            this.fireCurrentStageEvent(component.get("v.chosenElementName"));

         }
      });
      $A.enqueueAction(getCurrentTenderStage);
   },

    initializeCurrentState : function(component) {
        component.set("v.showMoreInfoForStage", true);
        this.fireCurrentStageEvent(component.get("v.chosenElementName"));
    },

    toggleMarkButton : function(component) {
        var action = component.get("c.toggleMarkStageButton");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (returnValue) {
                    component.set("v.disableButtonConfirm", returnValue);
                }
            }
        });
        $A.enqueueAction(action);
    },

   tapped : function(component, event) {
      let lastActiveButtonId = component.get("v.lastChosenElementName");
      if (lastActiveButtonId) {
         let lastActiveButton = document.getElementById(lastActiveButtonId);
         lastActiveButton.className = lastActiveButton.className.replace(" active actiiveAction", "");
      }

      let markAsActiveButton = document.getElementById("markButton");
      if(event.target.id == component.get("v.currentTenderStage") && event.target.id != "Closed") {
         markAsActiveButton.className = markAsActiveButton.className.replace(" active", "");
         markAsActiveButton.className += " current";
         component.set("v.buttonConfirmName", "Mark Stage as Complete");
      } 
      else {
         markAsActiveButton.className = markAsActiveButton.className.replace(" current", "");
         markAsActiveButton.className += " active";
         component.set("v.buttonConfirmName", "Mark as Current Stage");
      }

      component.set("v.lastChosenElementName", event.target.id);
      component.set("v.chosenElementName", event.target.id);
      let chosenElement = document.getElementById(event.target.id);
      chosenElement.className += " active actiiveAction";
   },

   fireCurrentStageEvent : function(stage) {
      var evt = $A.get("e.c:AITM_CustomTenderSendStageEvent");
      evt.setParams({
         "chosenStage" : stage
      }); 
      evt.fire();
   },

   buttonConfirm : function(component) {
      let chosenStageName = component.get("v.chosenElementName");
      if(chosenStageName) {
         if(component.get("v.buttonConfirmName").indexOf("Mark Stage as Complete") > -1) {
            let setCurrentStageAsCompletedAction = component.get("c.setStageAsCompleted");
            setCurrentStageAsCompletedAction.setParams({"tenderId" : component.get("v.recordId")});
            setCurrentStageAsCompletedAction.setCallback(this, function(response) {
               if(response) {
                  if (response.getReturnValue() == 'OK') {
                     this.sendStageCompletedEvent(component);
                  }
                  this.showErrorToast(response.getReturnValue());
               }
            });
            $A.enqueueAction(setCurrentStageAsCompletedAction);
         } 
         else {
            let setStageAction = component.get("c.setStageForTender");
            setStageAction.setParams({"tenderId" : component.get("v.recordId"), "stage" : component.get("v.chosenElementName")});
            setStageAction.setCallback(this, function(response) {
               if(response) {
                  if (response.getReturnValue() == 'OK') {
                     this.sendStageCompletedEvent(component);
                  }
                  this.showErrorToast(response.getReturnValue());
               }
            });
            $A.enqueueAction(setStageAction);
         } 

         let markAsActiveButton = document.getElementById("markButton");
         markAsActiveButton.className = markAsActiveButton.className.replace(" active", "");
         markAsActiveButton.className += " current";
         component.set("v.buttonConfirmName", "Mark Stage as Complete");
         this.getStateData(component);
      }
   },

   showErrorToast : function(toastMessage) {
      var title = toastMessage == "OK" ? "Success" : "Error!";
      var errorToastEvent = $A.get("e.force:showToast");
      errorToastEvent.setParams({
         "title" : title,
         "message" : toastMessage == "OK" ? "Stage Changed" : toastMessage,
         "type": toastMessage == "OK" ? "success" : "error"
      });
      errorToastEvent.fire();
   },

   buttonShowMoreInfoListener : function(component) {
      let isMoreInfoComponentDisplays = component.get("v.showMoreInfoForStage");
      component.set("v.showMoreInfoForStage", isMoreInfoComponentDisplays ? false : true);
      this.fireCurrentStageEvent(component.get("{!v.chosenElementName}"));
   },

   sendStageCompletedEvent : function(component) {
      var eventToSend = $A.get("e.c:AITM_CustomTenderPathStageCompleted");
      eventToSend.setParams({
         "currentStage" : component.get("v.currentTenderStage")[0],
         "tenderId" : component.get("v.recordId")
      }); 
      eventToSend.fire();
   },

   handleForceChangeStage : function(component) {
      this.buttonConfirm(component);
   },
})