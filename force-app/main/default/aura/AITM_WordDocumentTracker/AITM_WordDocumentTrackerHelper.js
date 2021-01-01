({
  download: function (component, event, helper) {
    var selectStartDate = component.find("startDateInput");
    var currentStartDate = selectStartDate.get("v.value");    
    if (currentStartDate == "") {      
      this.showToast("error", "Please select the date in the From Date");
        //alert("Please select the date in the From Date");
    }

    var selectEndDate = component.find("endDateInput");
    var currentEndDate = selectEndDate.get("v.value");
    if (currentEndDate == "") {
      this.showToast("error", "Please select the date in To Date");
    }
      
      if(currentStartDate > currentEndDate) {
          this.showToast("error", "Please enter a date in From Date less than the in To Date");
      }
      selectStartDate.set("v.value","");
      selectEndDate.set("v.value","");

    var action = component.get("c.fetchDoc");
    action.setParams({
      StartDate: currentStartDate,
      EndDate: currentEndDate,
    });
      
    
    action.setCallback(this, function (response) {
      //store state of response

      var state = response.getState();
      if (component.isValid() && state === "SUCCESS") {
        var returnValue = response.getReturnValue();
        component.set("v.ListOfDoc", returnValue);
        var stockdata = component.get("v.ListOfDoc");
        var csv = this.convertArrayOfObjectsToCSV(component, stockdata);
        if (csv == null) {
          return;
        }
        var hiddenElement = document.createElement("a");
        hiddenElement.href = "data:text/csv;charset=utf-8," + encodeURI(csv);
        hiddenElement.target = "_self"; //

        hiddenElement.download =
          "WordData" + Date.now().toString().replaceAll(":", "_") + ".csv"; // CSV file Name* you can change it.[only name not .csv]
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
        //document.body.removeChild(hiddenElement);

        this.showToast("info", "File is ready to download.");
      }
    });
    $A.enqueueAction(action);
  },

  convertArrayOfObjectsToCSV: function (component, objectRecords) {
    var csvStringResult, counter, key1, columnDivider, lineDivider;
    if (objectRecords == null || !objectRecords.length) {
      return null;
    }
    columnDivider = ",";
    lineDivider = "\n";
    key1 = [
      "Tender Name",
      "Tender Sector",
      "GRN",
      "Customer Name",
      "Document Title",
      "Owner",
      "Date",
      "Time",
    ];

    csvStringResult = "";
    csvStringResult += key1.join(columnDivider);
    csvStringResult += lineDivider;
    for (var i = 0; i < objectRecords.length; i++) {
      counter = 0;
      for (var sTempkey in key1) {
        var skey = key1[sTempkey];
        if (counter > 0) {
          csvStringResult += columnDivider;
        }
        if (skey == "Document Title") {
          var value =
            objectRecords[i].DocumentTitle != null
              ? '"' + objectRecords[i].DocumentTitle + '"'
              : "";
          csvStringResult += value;
        }
        if (skey == "Date") {
          var value =
            objectRecords[i].CreatedDate != null
              ? '"' + objectRecords[i].CreatedDate + '"'
              : "";
          csvStringResult += value;
        }
        if (skey == "Time") {
          var value =
            objectRecords[i].CreatedTime != null
              ? '"' + objectRecords[i].CreatedTime + '"'
              : "";
          csvStringResult += value;
        }
        if (skey == "Tender Name") {
          var value =
            objectRecords[i].TenderName != null
              ? '"' + objectRecords[i].TenderName + '"'
              : "";
          csvStringResult += value;
        }
        if (skey == "Tender Sector") {
          var value =
            objectRecords[i].TenderSector != null
              ? '"' + objectRecords[i].TenderSector + '"'
              : "";
          csvStringResult += value;
        }
        if (skey == "Owner") {
          var value =
            objectRecords[i].Owner != null
              ? '"' + objectRecords[i].Owner + '"'
              : "";
          csvStringResult += value;
        }
        if (skey == "Customer Name") {
          var value =
            objectRecords[i].CustomerName != null
              ? '"' + objectRecords[i].CustomerName + '"'
              : "";
          csvStringResult += value;
        }
        if (skey == "GRN") {
          var value =
            objectRecords[i].GRN != null
              ? '"' + objectRecords[i].GRN + '"'
              : "";
          csvStringResult += value;
        }

        counter++;
      }
      csvStringResult += lineDivider;
    }
    return csvStringResult;
  },

  showToast: function (type, message) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      type: type,
      message: message,
      mode: "pester",
      duration: 500,
    });
    toastEvent.fire();
  },
});