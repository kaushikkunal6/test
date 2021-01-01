({
    doInit : function(component) {
        this.loadLocationDetails(component, component.get("v.recordId"), null, null, null);
    },

    loadLocationDetails : function(component, tenderId, filter, searchTerm, roundNumber) {
        var action = component.get("c.getLocationDetails");

        filter = (filter == null && component.get('v.selectedFilter') != null) ? component.get('v.selectedFilter') : filter;

        action.setParams({
            "tenderId": tenderId,
            "filter": filter
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                roundNumber = (roundNumber == null && component.get('v.selectedRound') != null) ? component.get('v.selectedRound') : roundNumber;
                searchTerm = (searchTerm == null && component.get('v.enteredSearchTerm') != null) ? component.get('v.enteredSearchTerm') : searchTerm;

                if(roundNumber == null && returnValue.length){
                    for(var i = 0; i < returnValue.length; i++){
                        roundNumber = (returnValue[i].currentRound > roundNumber) ? returnValue[i].currentRound : roundNumber;
                    }
                }

                if (searchTerm && searchTerm.length) {
                    returnValue = this.filterResults(component, returnValue, searchTerm, roundNumber);
                } else if(roundNumber != null) {
                    returnValue = this.filterResults(component, returnValue, null, roundNumber);
                } else {
                    component.set("v.locations", returnValue, null);
                }
                
                var locationIds = this.getLocationIds(component.get('v.locations'));                
                window.localStorage.setItem(tenderId,locationIds);
             
                this.disableSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },

    isUrlShouldBeUpdated: function(component, countLocations, locations) {
        let tenderId = component.get("v.recordId");
        let tenderIdFromURL = this.getTenderIdFromURL();
        let locationIds = locations;

        if(tenderId != tenderIdFromURL || locationIds != null) {
            return true;
        }

        let countLocationIds = locationIds.length;
        if(countLocationIds != countLocations) {
            return true;
        }
        
        return false;
    },

    handleRoundEvent : function(component, event) {
        this.toggleSpinner(component);
        component.set("v.selectedFilter", event.getParam("filter"));
        component.set("v.selectedRound", event.getParam("roundNumber"));
        this.clearGetParams();
        this.loadLocationDetails(component, event.getParam("tenderId"), event.getParam("filter"), null, event.getParam("roundNumber"));
    },

    handleFilterEvent : function(component, event) {
        this.toggleSpinner(component);
        component.set("v.selectedFilter", event.getParam("filter"));
        this.clearGetParams();
        this.loadLocationDetails(component, event.getParam("tenderId"), event.getParam("filter"), null, event.getParam("roundNumber"));
    },

    handleSearchEvent : function(component, event) {
        this.toggleSpinner(component);
        var searchTerm = event.getParam("searchTerm");
        var tenderId = component.get("v.recordId");
        var selectedFilter = component.get("v.selectedFilter");
        component.set("v.enteredSearchTerm", event.getParam("enteredSearchTerm"));
        if (searchTerm.length) {
            this.clearGetParams();
            this.loadLocationDetails(component, tenderId, selectedFilter, searchTerm, null);
        }
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

    handleChangeStageEvent : function(component, event) {
        this.refreshView();
    },

    filterResults : function(component, allLocations, searchTerm, roundNumber) {
        var filteredLocations = [];
        if(searchTerm != null){
            searchTerm = searchTerm.toLowerCase();

            for (var index = 0; index < allLocations.length; index++) {
                if (this.containsIgnoreCase(allLocations[index].IATA, searchTerm)
                    || this.containsIgnoreCase(allLocations[index].locationName, searchTerm)
                    || this.containsIgnoreCase(allLocations[index].country, searchTerm)
                    || this.containsIgnoreCase(allLocations[index].locationIdentificator, searchTerm)) {
                    if(roundNumber != null){
                        if(allLocations[index].round == roundNumber){
                            filteredLocations.push(allLocations[index]);
                        }
                    }else{
                        filteredLocations.push(allLocations[index]);
                    }

                }
            }
        }else{
            for (var index = 0; index < allLocations.length; index++) {
                if(allLocations[index].round == roundNumber){
                    filteredLocations.push(allLocations[index]);
                }
            }
        }
        component.set("v.locations", filteredLocations);
        return filteredLocations;
    },

    preventDefault : function(event) {
        event.stopPropagation();
        event.preventDefault();
    },

    containsIgnoreCase : function(source, searchTerm) {
        return source && source.toLowerCase().indexOf(searchTerm) > -1;
    },

    toggleSpinner : function(component) {
        var spinner = component.find("relatedLocationSpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },

    disableSpinner : function(component) {
        var spinner = component.find("relatedLocationSpinner");
        $A.util.addClass(spinner, "slds-hide");
    },

    updateUrl : function(component, isCloseAllTabs){
        var locationIds = this.getLocationIds(component.get('v.locations'));
        var isCloseAllTabs = (isCloseAllTabs == null) ? true : isCloseAllTabs;
        if(typeof locationIds != undefined && locationIds != null) {
            var locationIdsParam = (locationIds.length) ?  locationIds.join(",") : '';
            window.history.pushState( {"html" : "", "pageTitle" : ""}, "",
        decodeURIComponent(this.getCurrentUrl()));
        }
    },

    getCurrentUrl : function() {
        var hash = window.location.hash.split("?");
        return window.location.origin + window.location.pathname + hash[0];
    },

    getLocationIds : function(locations) {
        var locationIds = [];
        for(var key in locations){
          locationIds.push(locations[key].recordId);
        }
        return locationIds;
    },

    clearGetParams : function() {
        window.history.pushState(
            {"html" : "", "pageTitle" : ""}, "", 
            this.getCurrentUrl()
        );
    },

    closeAllSubtabs : function(component) {
        var hash = window.location.hash;
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            url:  hash, 
            focus: true
        }).then(function(response) {
            workspaceAPI.getTabInfo({
                tabId: response
            }).then(function(response) {
                if(response.subtabs.length) {
                    for(var i = 0; i < response.subtabs.length; i++){
                        workspaceAPI.closeTab({tabId: response.subtabs[i].tabId});
                    }
                }
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    },

    getUrlParameter : function(paramName) {
        var url = window.location.href;
        paramName = paramName.replace(/[\[\]]/g,"\\$&");
        var regex= new RegExp("[?&]"+ paramName + "(=([^&#]*)|&|#|$)"),
            results = regex.exec(url);
        if(!results) return null;
        if(!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g," "));
    },

    getTenderIdFromURL : function() {
        var hash = window.location.hash.substring(1);
        var hashParams = hash.split('/');
        return hashParams[2];
    },

    refreshView : function() {
        $A.get('e.force:refreshView').fire();
    },

    onTabFocused : function(component, event) {
        if(component.get("v.recordId") == this.getTenderIdFromURL()) {
            this.updateUrl(component, false);
        }
    }

})