({
  doInit: function (component) {
    var action = component.get("c.getProfileInfo");
    action.setParams({
      arecordId: component.get("v.recordId"),
    });
    action.setCallback(this, function (a) {
      var returnValue = a.getReturnValue();
      if (returnValue) {
        console.log("reached1");
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
          relatedListId: "AttachedContentDocuments",
          parentRecordId: component.get("v.recordId"),
        });
        relatedListEvent.fire();
      } else {
        //alert(+returnValue);
        this.relatedList(component);
      }
    });
    $A.enqueueAction(action);
  },
  relatedList: function (component) {
    var action = component.get("c.getContentDocs");
    action.setParams({
      arecordId: component.get("v.recordId"),
    });
    action.setCallback(this, function (a) {
      component.set("v.contentFiles", a.getReturnValue());
      component.set("v.cardTitle", "Files (" + a.getReturnValue().length + ")");
    });
    $A.enqueueAction(action);
  },

  previewFile: function (component, event) {
    var target = event.target || event.srcElement;
    var recordId = target.getAttribute("data-recordid");

    $A.get("e.lightning:openFiles").fire({
      recordIds: [recordId],
    });
  },
});