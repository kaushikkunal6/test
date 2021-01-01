({
	doInit : function(component) {
   	this.getTenderLocations(component);
	},

  getTenderLocations: function(component) {
    var recordId = component.get("v.recordId");
    var action = component.get("c.getTenderIdByTenderLocationId");
      action.setParams({
          "tenderLocationId": recordId
      });

      action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === 'SUCCESS'){
            var result = response.getReturnValue();
            component.set("v.tenderId", result);
            this.getFilterTenderLocations(component);
        }else{
            console.log(response.getError()[0])
        }
      });
      $A.enqueueAction(action); 
  },

  getFilterTenderLocations : function(component) {
    var result = component.get("v.tenderId");
    var recordId = component.get("v.recordId");
    let locationIdsArr;
      
    if(window.localStorage.getItem(result)) {
    	locationIdsArr = window.localStorage.getItem(result).split(',');    
        if(locationIdsArr.includes(recordId)) {
              var action = component.get("c.getTenderLocations");             
              action.setParams({
                "tenderLocationId": recordId,
                "filteredTenderLocationIds" : "'" + locationIdsArr.join("','") + "'"
              });
              action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === 'SUCCESS'){
                  var responseResult = response.getReturnValue();
                  this.populateValues(component, responseResult);
                }else {
                  console.log(response.getError()[0])  
                }  
              });
          } else{
      		  this.disableButtons(component);
    	  }
    	  $A.enqueueAction(action);
    } else {
        locationIdsArr = [];       
        this.showToast('warning', $A.get("$Label.c.AITM_Next_Back_Buttons_Error_Message"));
    }
  },

  disableButtons : function(component) {
      component.set("v.isFirst", true);
      component.set("v.isLast", true);
      this.showToast('warning', $A.get("$Label.c.AITM_Next_Back_Buttons_Error_Message"));
  },

  populateValues : function(component, tenderLocations) {
  	var recordId = component.get("v.recordId");
  	var currentLocationPositon = this.getCurrentLocationPosition(recordId, tenderLocations);
  	var isFirst = this.isFirst(currentLocationPositon);
  	var isLast = this.isLast(currentLocationPositon, tenderLocations);
  	var next = this.getNextId(currentLocationPositon, tenderLocations, isLast);
  	var back = this.getBackId(currentLocationPositon, tenderLocations, isFirst);

  	if(next !== null) { component.set("v.next", next); }
  	if(back !== null) { component.set("v.back", back); }

  	component.set("v.tenderLocations", tenderLocations);
	  component.set("v.isFirst", isFirst);
	  component.set("v.isLast", isLast);
  },

  getCurrentLocationPosition : function(recordId, tenderLocations) {
		let currentLocationPositon = 0;
		for(var i = 0; i < tenderLocations.length; i++) {
			if(tenderLocations[i].Id == recordId){
				currentLocationPositon = i;
				break;
			}
		}
		return currentLocationPositon;
	},

	isFirst : function(currentLocationPositon) {
		return (currentLocationPositon == 0) ? true : false;
	},

	isLast : function(currentLocationPositon, tenderLocations) {
		return ( currentLocationPositon == (tenderLocations.length - 1) ) ? true : false;
	},

	getNextId : function(currentLocationPositon, tenderLocations, isLast) {
		return (!isLast) ? tenderLocations[currentLocationPositon + 1].Id : null;
	},

	getBackId : function(currentLocationPositon, tenderLocations, isFirst) {
		return (!isFirst) ? tenderLocations[currentLocationPositon - 1].Id : null;
	},

	goBack : function(component) {
		this.navigateToObject(component, component.get('v.back'));
	},

	goNext : function(component) {
		this.navigateToObject(component, component.get('v.next'));
	},

  navigateToObject : function(component, recordId) {
    try{
        var evt = $A.get("e.force:navigateToSObject");
        evt.setParams({
           "recordId": recordId,
           "slideDevName": "detail"
        });
        evt.fire();
    }catch(error){
        this.disableButtons(component);
    }

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

  showToast: function(type, message) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        type: type,
        message: message,
    }); 
    toastEvent.fire();  
  },

})