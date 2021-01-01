({
	doInit : function(component, undefined, helper) {
		// get info rom pagereference?
		let pageRef = component.get("v.pageReference");
		component.set("v.recordId", pageRef.state.c__recordId);
		helper.reload(component);

		var action = component.get("c.sayMyName");
		action.setParams({
			recordId: component.get("v.recordId")
		});

		action.setCallback(this, function (a) {
			var state = a.getState();
			if (state === "SUCCESS") {
				console.log(a);
				var rs = JSON.parse(a.getReturnValue());
				component.set("v.recordName", rs.recordName);
				component.set("v.sObjectName", rs.objectType);

			} else if (state === "ERROR") {
				let appEvent = $A.get("e.c:AITM_HandleCallbackErrorEvent");
				appEvent.setParams({
					"errors": a.getError()
				});
				appEvent.fire();
			}
		});
		$A.enqueueAction(action);
	},

	stopProp : function(component, event) {
		event.stopPropagation();
	},

	navToRecord : function(component, event, helper) {
		helper.nav(component, component.get("v.recordId"));
	},

	navToUser: function (component, event, helper) {
		helper.nav(component, event.target.id);
	},

	delete : function(component, event, helper) {
		//console.log("deleting");
		//	global static void deletePerm(id UserOrGroupID, id recordId){

		let action = component.get("c.deletePerm");
		action.setParams({
			"UserOrGroupID" : event.target.id,
			"recordId" : component.get("v.recordId")
		});
		action.setCallback(this, function(a){
			let state = a.getState();
			if (state === "SUCCESS") {
				helper.reload(component);
			} else if (state === "ERROR") {
				//console.log("error:");
				//console.log(a.getError());
				let appEvent = $A.get("e.c:AITM_HandleCallbackErrorEvent");
				appEvent.setParams({
					"errors" : a.getError()
				});
				appEvent.fire();
			}
		});
		$A.enqueueAction(action);
	},

	setRead : function(component, event, helper) {
		//console.log("read clicked");
		let id = event.target.id;
		helper.commonUpsert(component, id, "Read");
	},

	setReadWrite : function(component, event, helper) {
		//console.log("readWrite clicked");
		let id = event.target.id;
		helper.commonUpsert(component, id, "Edit");
	},

	search : function(component, undefined, helper){
		let searchString = component.find("search").get("v.value").trim().replace(/\*/g).toLowerCase();

		if (searchString.length<=2){
			component.set("v.results", []);
			return; //too short to search
		}

		let searchTimeout = component.get('v.searchTimeout');


		let searchObject = component.find("searchPicklist").get("v.value");
		//console.log(searchString);
		//console.log(searchObject);
		let action= component.get("c.doSOSL");
		action.setParams({
			"searchString" : searchString,
			"objectType" : searchObject
		});

		action.setCallback(this, function(a){
			let state = a.getState();
			if (state === "SUCCESS") {
				let result = JSON.parse(a.getReturnValue());
				//console.log(result);
				//cleanup for userTypes
				if (searchObject === 'User' || searchObject === 'user' ){
					let correctedResults = [];
					for (let u of result){
						u.Type = helper.translateTypes(u.UserType);
						correctedResults.push(u);
						//console.log(u);
						component.set("v.results", correctedResults);
					}
				} else {
					component.set("v.results", result);
				}
			}  else if (state === "ERROR") {
				let appEvent = $A.get("e.c:AITM_HandleCallbackErrorEvent");
				appEvent.setParams({
					"errors" : a.getError()
				});
				appEvent.fire();
			}
		});

		if (searchTimeout) {
			clearTimeout(searchTimeout);
		}

		searchTimeout = window.setTimeout(
			$A.getCallback(() => {
				// Send search request
				$A.enqueueAction(action);
				// Clear timeout
				component.set('v.searchTimeout', null);
			}),
			300 // Wait for 300 ms before sending search request
		);

		component.set('v.searchTimeout', searchTimeout);

	}
})