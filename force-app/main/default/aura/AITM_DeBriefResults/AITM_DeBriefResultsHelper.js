({
    doInit : function(component) {
        this.initializeDeBriefResults(component);
    },

    initializeDeBriefResults : function(component) {
        var pageSize = component.get("v.pageSize");
        var tenderId = component.get("v.recordId");
        var action = component.get("c.initializeDeBriefResults");
        action.setParams({
            "tenderId": tenderId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                component.set("v.deBriefEditable", returnValue.editable);
                component.set("v.deBriefResultsOption", returnValue.options);
                component.set("v.deBriefResults", returnValue.results);
                component.set("v.totalSize", component.get("v.deBriefResults").length);
				component.set("v.start",0);
				component.set("v.end",pageSize-1);
				var paginationList = [];
				for(var i = 0; i< pageSize; i++) {
					paginationList.push(response.getReturnValue()[i]);
				}
				component.set("v.paginationList", paginationList);
                var checkvalue = component.find("selectAll").get("v.checked");
                var retrieveData = JSON.parse(localStorage.getItem('localStr'));
                localStorage.clear();

                if(checkvalue){
                    var items = [];
                    for(var i = 0; i< returnValue.results.length; i++) {
                        returnValue.results[i].isSelected = true;
                        items.push(returnValue.results[i]);
                        component.set("v.deBriefResults", items);
                    }
                }
                else if(retrieveData != null)
                {
                    var items = [];
                    for(var i = 0; i< retrieveData.length; i++) {
                        if(retrieveData[i].isSelected == true){
                            returnValue.results[i].isSelected = true;
                        }
                        items.push(returnValue.results[i]);
                        component.set("v.deBriefResults", items);
                    }
                    
                }
                
                this.onSelectChange(component);
                this.disableSpinner(component);
            }

        });
        $A.enqueueAction(action);
    },

    loadDeBriefDetails : function(component, tenderId, filter, searchTerm) {
        var pageSize = component.get("v.pageSize");
        var action = component.get("c.loadDeBriefDetails");
        action.setParams({
            "tenderId": tenderId,
            "filter": filter
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                
                if (searchTerm && searchTerm.length) {
                    this.filterResults(component, returnValue, searchTerm);
                } else {
                    component.set("v.deBriefResults", returnValue);
                    component.set("v.totalSize", component.get("v.deBriefResults").length);
                    component.set("v.start",0);
                    component.set("v.end",pageSize-1);
                    var paginationList = [];
                    for(var i = 0; i< pageSize; i++) {
                        paginationList.push(response.getReturnValue()[i]);
                    }
                    component.set("v.paginationList", paginationList);
                }
                this.disableSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },

    handleFilterEvent : function(component, event) {
        this.toggleSpinner(component);
        component.set("v.selectedFilter", event.getParam("filter"));
        this.loadDeBriefDetails(component, event.getParam("tenderId"), event.getParam("filter"), null);
    },
    
    resultToUpdateOnTlli : function(component, event, helper) {
        this.toggleSpinner(component);
        var resultToUpdate = component.get("v.selectedResult");
        var tlliList = component.get("v.deBriefResults");
        var isSelectAll = component.find("selectAll").get("v.checked");
         
        var selectedTlliList = [];
        
        if(isSelectAll){
            selectedTlliList = tlliList;
        }
        else{
            var k = 0;
            for (var i=0; i<tlliList.length; i++){
                var c = tlliList[i];
                if(tlliList[i].isSelected) {
                    selectedTlliList[k] = tlliList[i];
                    k++; 
                }    
            }
        }
        
        if(selectedTlliList.length > 0 && resultToUpdate != '--'){
            selectedTlliList = selectedTlliList.filter(function( element ) {
                return element !== undefined;
            });
            var action = component.get("c.saveWithMultiple");
            action.setParams({
                "deBriefResults": JSON.stringify(selectedTlliList),
                "resultToUpdate": resultToUpdate
            });
            localStorage.setItem('localStr',JSON.stringify(tlliList));
            action.setCallback(this, function(result){
                var state = result.getState();
                if (component.isValid() && state === "SUCCESS"){
                    var returnValue = result.getReturnValue();
                    if (returnValue && returnValue.length > 0) {
                        this.showToast("error", "Error During Save", returnValue);
                    } else {
                        this.showToast("success", "Success!", "Records saved");
                       $A.get('e.force:refreshView').fire();
                     
                       
                    }
    
                    this.disableSpinner(component);
                }
            });
            $A.enqueueAction(action);
        }else{
            this.disableSpinner(component);
        }
    },

    handleSearchEvent : function(component, event) {
        this.toggleSpinner(component);
        var searchTerm = event.getParam("searchTerm");
        var tenderId = component.get("v.recordId");
        var selectedFilter = component.get("v.selectedFilter");

        if (searchTerm.length) {
            this.loadDeBriefDetails(component, tenderId, selectedFilter, searchTerm);
        }
    },
    
    handleSave : function(component) {
        this.toggleSpinner(component);
        var deBriefResults = component.get("v.paginationList");
        deBriefResults = deBriefResults.filter(function( element ) {
            return element !== undefined;
        });
        var action = component.get("c.save");
        action.setParams({
            "deBriefResults": JSON.stringify(deBriefResults)
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (returnValue && returnValue.length > 0) {
                    this.showToast("error", "Error During Save", returnValue);
                } else {
                    this.showToast("success", "Success!", "Records saved");
                    $A.get('e.force:refreshView').fire();
                }

                this.disableSpinner(component);
            }

        });
        $A.enqueueAction(action);        
    },

    handleViewSObject : function(component, event) {
        var target = event.target || event.srcElement;
        var recordId = target.getAttribute("data-recordid");
        var evt = $A.get("e.force:navigateToSObject");
        evt.setParams({
           "recordId": recordId,
           "slideDevName": "detail"
        });
        evt.fire();
    },

    filterResults : function(component, allResults, searchTerm) {
        var pageSize = component.get("v.pageSize");
        var filteredLocations = [];
        if(searchTerm != null){
            searchTerm = searchTerm.toLowerCase();
            for (var index = 0; index < allResults.length; index++) {
                if (this.containsIgnoreCase(allResults[index].GRN, searchTerm)
                 || this.containsIgnoreCase(allResults[index].locationName, searchTerm)
                 || this.containsIgnoreCase(allResults[index].customer, searchTerm)
                 || this.containsIgnoreCase(allResults[index].locationIdentificator, searchTerm)) {
                    filteredLocations.push(allResults[index]);
                }
            }
        } else {
            for (var index = 0; index < allLocations.length; index++) {
                filteredLocations.push(allLocations[index]);
            }
        }
        component.set("v.deBriefResults", filteredLocations);
        component.set("v.totalSize", component.get("v.deBriefResults").length);
        component.set("v.start",0);
        component.set("v.end",pageSize-1);
        var paginationList = [];
        for(var i = 0; i< pageSize; i++) {
            paginationList.push(filteredLocations[i]);
        }
        component.set("v.paginationList", paginationList);
    },

    preventDefault : function(event) {
        event.stopPropagation();
        event.preventDefault();
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

    containsIgnoreCase : function(source, searchTerm) {
        return source && source.toLowerCase().indexOf(searchTerm) > -1;
    },

    toggleSpinner : function(component) {
        var spinner = component.find("relatedDebriefSpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },

    disableSpinner : function(component) {
        var spinner = component.find("relatedDebriefSpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    
    onSelectChange : function(component) {
        this.toggleSpinner(component);
        var selected = component.find("selectItem").get("v.value");
		var paginationList = [];
		var oppList = component.get("v.deBriefResults");
		for(var i= 0; i< selected; i++) {
			paginationList.push(oppList[i]);
		}
		component.set("v.paginationList", paginationList);
        this.disableSpinner(component);
    },
    
    previousPageRecords : function(component) {
        this.toggleSpinner(component);
        var oppList = component.get("v.deBriefResults");
        var end = component.get("v.end");
        var start = component.get("v.start");
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
        var counter = 0;
        for(var i = start - pageSize; i < start; i++) {
            if(i > -1) {
                paginationList.push(oppList[i]);
                counter ++;
            } else {
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.start",start);
        component.set("v.end",end);
        component.set("v.paginationList", paginationList);
        this.disableSpinner(component);
    },
    
    nextPageRecords : function(component) {
        this.toggleSpinner(component);
        var oppList = component.get("v.deBriefResults");
        var end = component.get("v.end");
        var start = component.get("v.start");
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
        var counter = 0;
        for(var i = end+1; i< end+pageSize + 1; i++) {
            if(oppList.length > end) {
                paginationList.push(oppList[i]);
                counter ++ ;
            }
        }
        start = start + counter;
        end = end + counter
        component.set("v.start",start);
        component.set("v.end",end);
        component.set("v.paginationList", paginationList);
        this.disableSpinner(component);
    },
    
    lastPageRecords : function(component) {
        this.toggleSpinner(component);
        var oppList = component.get("v.deBriefResults");
        var pageSize = component.get("v.pageSize");
        var totalSize = component.get("v.totalSize");
        var paginationList = [];
        for(var i = totalSize-pageSize + 1; i< totalSize; i++) {
            paginationList.push(oppList[i]);
        }
        component.set("v.paginationList", paginationList);
        this.disableSpinner(component);
    },
    
    firstPageRecords : function(component) {
        
        var oppList = component.get("v.deBriefResults");
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
        for(var i=0; i< pageSize; i++) {
            paginationList.push(oppList[i]);
        }
        component.set("v.paginationList", paginationList);
        this.disableSpinner(component);
    }
})