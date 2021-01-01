({
    save : function(component) {
        var fileInput = component.find("file-upload").getElement();
        var file = fileInput.files[0];
        this.uploadFile(component, file);
    },

    loadFiles : function(component, e) {
        this.preventDefault(e);
        e.dataTransfer.dropEffect = 'copy';
        var file = e.dataTransfer.files[0];
        this.uploadFile(component, file);
    },

    uploadFile : function(component, file) {
        if (file && (file.type.indexOf('text') > -1 || !file.type)) {
            var fr = new FileReader();
            
            var self = this;
            fr.onload = $A.getCallback(function() {
                var fileContents = fr.result;
                var base64Mark = 'base64,';
                var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
                fileContents = fileContents.substring(dataStart);
           
                self.upload(component, window.atob(fileContents));           
            });
     
            fr.readAsDataURL(file);  
        } else {
            component.set("v.errorMessage", $A.get("$Label.c.AITM_UploadLocationWrongFile"));
        }
    },
        
    upload: function(component, fileContents) {
        var fileContent = fileContents.split(/\r?\n/);
        this.toggleSpinner(component);
        this.validateGRNAndLocationCodes(component, fileContent[0], fileContent);
    },

    validateGRNAndLocationCodes : function(component, firstLine, fileContent) {
        var tenderId = component.get("v.recordId");
        var action = component.get("c.validateGRNCodes");
        action.setParams({
            "tenderId": tenderId,
            "firstLine": firstLine
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if (!result || result.length === 0) {
                this.validateLocationCodesAndLoad(tenderId, component, firstLine, fileContent);
            } else {
                component.set("v.errorMessage", result);
                this.toggleSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },

    validateLocationCodesAndLoad : function(tenderId, component, firstLine, fileContent) {
        var action = component.get("c.validateLocationCodes");
        var codes = this.getLocationCodes(fileContent);
        action.setParams({
            "codes": codes
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if (!result || result.length === 0) {
                //this.load(component, fileContent, firstLine);
                this.loadNew(component, fileContent, firstLine);
                component.set("v.errorMessage", "");
            } else {
                component.set("v.errorMessage", result);
                this.toggleSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },

    getLocationCodes : function(fileContent) {
        var codes = [];

        for (var index = 2; index < fileContent.length; index++) {
            var splittedLine = fileContent[index].split(/\s?\t/);
            if (splittedLine.length > 0) {
                var code = splittedLine[0];
                if (code.indexOf(":") > -1) {
                    codes.push(code.split(":")[0]);
                } else {
                    codes.push(code);
                }
            }
        }

        return codes;
    },

    load : function(component, fileContent, firstLine) {
        var chuckFileContent = "";
        var j = 0;
        var k = 0;
        for (var i = 2; i < fileContent.length; i++) {
            chuckFileContent += fileContent[i] + "\r\n";
            j = j + 1;
            if (i % 50 === 0) {
                k = k + 1;
                this.sendContentToParse(component, chuckFileContent, firstLine);
                chuckFileContent = ''
            }
        }

        if (chuckFileContent.length > 0) {
            component.set("v.recordsProcessed", j);
            this.sendContentToParse(component, chuckFileContent, firstLine);
        }
    },

    sendContentToParse : function(component, fileContent, firstLine) {
        var result = "";
        var tenderId = component.get("v.recordId");
        var action = component.get("c.parse");
        action.setParams({
            "tenderId": tenderId,
            "recordsRaw": fileContent,
            "firstLine": firstLine
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                this.checkState(component);
            }
        });
        $A.enqueueAction(action);
    },

    loadNew : function(component, fileContent, firstLine) {
        var chuckFileContent = "";
        var j = 0;
        var k = 0;
        for (var i = 2; i < fileContent.length; i++) {
            chuckFileContent += fileContent[i] + "\r\n";
            j = j + 1;
        }

        if (chuckFileContent.length > 0) {
            component.set("v.recordsProcessed", j);
            //call apex method which calls batch class
            this.sendContentToBatchParse(component, chuckFileContent, firstLine);
        }
    },

    sendContentToBatchParse : function(component, fileContent, firstLine) {
        var result = "";
        var tenderId = component.get("v.recordId");
        var action = component.get("c.parseBatch");
        action.setParams({
            "tenderId": tenderId,
            "recordsRaw": fileContent,
            "firstLine": firstLine
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                this.checkState(component);
            } else if(state === "ERROR") {
                let errors = response.getError();
                let message = "Unknown error";
                if (errors && Array.isArray(errors) && errors.length > 0) {
         		   message = errors[0].message;
        		}
                this.toggleSpinner(component);
                this.showToast('error', 'Error!', message);    
                this.refreshView();
                this.closeModalWindow();
            }
        });
        $A.enqueueAction(action);
    },

    preventDefault : function(e) {
        e.stopPropagation();
        e.preventDefault();
    },

    refreshView : function() {
        $A.get('e.force:refreshView').fire();
    },

    showToast : function(type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": message
        });
        
        toastEvent.fire(); 
    },

    closeModalWindow : function() {
        $A.get("e.c:AITM_ClosePathQuickAction").fire();
    },

    checkState : function(component) {
        this.check(component);
        
        var self = this;
        var setIntervalState = window.setInterval(
            $A.getCallback(function() { 
                self.check(component, setIntervalState);
            }), 2000
        );      
    },

    check : function(component, setIntervalState) {
        //var action = component.get("c.check");
        var action = component.get("c.checkBatch");
        var numberOfRecords = component.get("v.recordsProcessed");
        if (action) {
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    var result = response.getReturnValue();
                
                    if (result) {
                        if (result.indexOf("DONE") > -1) {
                            if(numberOfRecords > 0) {
                            	this.loadFromStaging(component);    
                            }
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        } else {
            clearInterval(setIntervalState);
        }
    },
    
    loadFromStaging : function(component) {
        var tenderId = component.get("v.recordId");
        var numberOfRecords = component.get("v.recordsProcessed");
        var action = component.get("c.loadFromStaging");
        action.setParams({
            "tenderId": tenderId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var returnValue = response.getReturnValue();
            if (component.isValid() && state === "SUCCESS") { 
                this.toggleSpinner(component);
                if(returnValue == 0) {
                	this.showToast('success', 'Success!', $A.get("$Label.c.AITM_UploadLocationLoadSuccess"));    
                } else {
                    this.showToast('success', 'Success!', 'Few Failures in loading records' + returnValue);    
                }
                this.refreshView();
                this.closeModalWindow();
            }
        });
        $A.enqueueAction(action);
    },

    toggleSpinner : function(component) {
        var spinner = component.find("loaderSpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    }
})