({
    handleCurrentStage: function(component, event) {
        component.set("v.currentStage", event.getParam("chosenStage"));
        this.getDefaultValuesForCheckboxes(component);
        //$A.get('e.force:refreshView').fire();
    },

    setCheckBoxFeedbackToDeBrief: function(component, event) {
        let changeFeedbackToDeBriefCheckbox = component.get("v.changeFeedbackToDebrief") ? false : true;
        let setFeedbackCheckboxAction = component.get("c.changeFeedbackToDeBrief");
        setFeedbackCheckboxAction.setParams({
            "tenderId": component.get("v.recordId"),
            "valueToSet": changeFeedbackToDeBriefCheckbox
        });
        setFeedbackCheckboxAction.setCallback(this, function(response) {
            let returnedMessage = response.getReturnValue();
            if (returnedMessage) {
                this.showToast(returnedMessage);
                component.set("v.changeFeedbackToDebrief", changeFeedbackToDeBriefCheckbox);
            }
        });
        $A.enqueueAction(setFeedbackCheckboxAction);
    }, 
   
    downloadExcelFile : function(component) {
       let labpUrl = component.get("v.excelDownloadUrl");
       let reportId = component.get("v.reportID");
        if(labpUrl) {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "https://" + window.location.hostname + $A.get("$Label.c.AITM_ReportURLLABPOfferButton") + '/' + reportId + "/view?fv0=" + component.get("v.recordId")            
            });
            urlEvent.fire();
        } else {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "https://" + window.location.hostname + $A.get("$Label.c.AITM_ReportURLTendering") + '/' + reportId + "/view?fv0=" + component.get("v.recordId")          
            });
            urlEvent.fire();
        }
   },

    getDefaultValuesForCheckboxes: function(component) {
        let getDefaultChekboxesValuesAction = component.get("c.pullDefaultValuesForCheckboxes");
        getDefaultChekboxesValuesAction.setParams({
            "tenderId": component.get("v.recordId")
        });
        getDefaultChekboxesValuesAction.setCallback(this, function(response) {
            let defaultValuesObj = response.getReturnValue();
            if (defaultValuesObj) {
                component.set("v.showButtons", defaultValuesObj.showButtons);
                component.set("v.isGenerateOfferButton", defaultValuesObj.isGenerateOfferButton);
                component.set("v.changeFeedbackToDebrief", defaultValuesObj.feedbackToDebrief);
                component.set("v.showPolish", defaultValuesObj.showPolish);
                component.set("v.showNonPolish", defaultValuesObj.showNonPolish);
                component.set("v.excelDownloadUrl", defaultValuesObj.showDownloadLABPExcel);
                component.set("v.showConga", defaultValuesObj.showConga);
                component.set("v.reportID", defaultValuesObj.reportID);
                component.set("v.taxAndFeeReportID", defaultValuesObj.taxAndFeeReportID);
                component.set("v.isTenderOld", defaultValuesObj.isTenderOld);
                component.set("v.additionalNotesReportID", defaultValuesObj.additionalNotesReportID);
                component.set("v.showReportTOLM", defaultValuesObj.showReportTOLM);
            }
        });
        $A.enqueueAction(getDefaultChekboxesValuesAction);
    },

    createComponent : function(component, componentName) {
        var modalBody;
        this.closePopup(component);
        var self = this;
        $A.createComponent(componentName, 
            {recordId: component.get("v.recordId"),
             isReportButton: component.get("v.isReportButton"),
             excelDownloadUrl : component.get("v.excelDownloadUrl"),
             taxAndFeeReportID : component.get("v.taxAndFeeReportID"),
             additionalNotesReportID : component.get("v.additionalNotesReportID"),
             isTenderOld : component.get("v.isTenderOld")},
            function(content, status) {
                if (status === "SUCCESS") {
                    modalBody = content;
                    component.find('overlayLib').showCustomModal({
                        body: modalBody, 
                        showCloseButton: true,
                        cssClass: "mymodal",
                        closeCallback: function() {}
                    }).then(function (overlay) {
                        self.closePopup(component);
                        component.set('v.overlayPanel', overlay);
                    });
                }
        });
    },
    
    launchCongaSign : function(component) {
        var congaURL = window.location.hostname;
        congaURL = 'https://' + congaURL + '/apex/APXT_CongaSign__apxt_sendForSignature?id=' + component.get('v.recordId');
        var navService = component.find("navService");
        var pageReference = {
            type: 'standard__webPage',
            attributes: {
                url: congaURL
            },
        };
        component.set("v.pageReference", pageReference);
        navService.navigate(pageReference);
    },

    showToast : function(toastMessage) {
        let responseToastEvent = $A.get("e.force:showToast");
        responseToastEvent.setParams({
            "title" : toastMessage,
            "message" : toastMessage == "OK" ? "Value changed" : "Tender Update Error",
            "type": toastMessage == "OK" ? "success" : "error"
        });
        responseToastEvent.fire();
    },

    closePopup : function(component) {
        var overlay = component.get('v.overlayPanel')[0];
        setTimeout(function() {
            if (overlay) { 
                overlay.close();
            } 
        }, 200);
    }
})