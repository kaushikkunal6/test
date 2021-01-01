({  
   
     doInit: function(component, event, helper) {
        // Prepare a new record from template
         component.set("v.userInfo", "Default");
        component.find("forceRecord").getNewRecord(
            "AITM_Tender__c", 
            null,      // recordTypeId
            false,     // skip cache?
            $A.getCallback(function() {
                var rec = component.get("v.tenderRecord");
                var error = component.get("v.newError");
                if(error || (rec === null)) {
                    //console.log("Error initializing record template: " + error);
                }
                else {
                    //console.log("Record template initialized: " + rec.apiName);
                }
            })
        );
         
         var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var storeResponse = response.getReturnValue();
              
               // set current user information on userInfo attribute
                if(storeResponse != undefined && storeResponse !='undefined' && storeResponse != null && storeResponse != 'null' ){
                   component.set("v.userInfo", storeResponse.Profile.Name);  
                }
                   
                
                
            }
        });
        $A.enqueueAction(action);
    },
	cancelDialog : function(component, helper) {
        var profileName =  component.get("v.userInfo");;
       
        if(profileName == "Default"){
             
		//if(profileName == 'null'){
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
                var homeEvt = $A.get("e.force:navigateToObjectHome");
            homeEvt.setParams({
             "scope": "AITM_Tender__c",
             "isredirect": true
            });
            homeEvt.fire();
                workspaceAPI.closeTab({tabId: focusedTabId});
              
            })
            .catch(function(error) {
                console.log(error);
            });
            
        }
        else
        {   
            var strUrl = ""+window.location;
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": strUrl,            
            });
            urlEvent.fire();
            
        }
    },
    handleSaveRecord:function(component, event, helper) {
        var level = component.get("v.newtenderRecord.AITM_Customer_Service_Level__c");
                //alert(level);
       var aircraft = component.get("v.newtenderRecord.AITM_Aircraft_Type__c");
                //alert(aircraft);
       if(level != 'Level I' && aircraft === null){
        //alert('Please fill aircraft type');
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message:'Please fill the aircraft type',
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
        var button = component.find('savebuttonid');
       var button1 = component.find('savebuttonid1');
          button.set('v.disabled',false);
          button1.set('v.disabled',false);
            
       }
        else{ 
       var button = component.find('savebuttonid');
       var button1 = component.find('savebuttonid1');
          button.set('v.disabled',false);
          button1.set('v.disabled',false);
         var profileName =  component.get("v.userInfo");;
        
      
       
       if(helper.validateForm(component)) {
         component.find("forceRecord").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                //console.log("Save completed successfully.");
                 
                 var navEvt = $A.get("e.force:navigateToURL");
               if(profileName == "Default"){                   
              	navEvt.setParams({
                  "url": "/lightning/r/AITM_Tender__c/"+saveResult.recordId+"/view",
                });
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({tabId: focusedTabId});
                 navEvt.fire();
                })
                .catch(function(error) {
                   // console.log(error);
                });
                } 
                else{
                    
                   var strUrl = "https://"+window.location.hostname+"/labptendering/s/aitm-tender/"+saveResult.recordId;
                   
                    navEvt.setParams({
                        "url": strUrl,            
                    });
                    navEvt.fire();
        			}
            
         
                
            } else if (saveResult.state === "INCOMPLETE") {
                //console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
              
                //console.log('Problem saving record, error: ' +
                           //JSON.stringify(saveResult.error));
            }   
        })
        );}
        else{
             button.set('v.disabled',false);
             button1.set('v.disabled',false);
        }
        } 
       
    },
     handleSaveAndNewRecord: function(component, event, helper) {
       var profileName =  component.get("v.userInfo");
      
        if(helper.validateForm(component)) {
          component.find("forceRecord").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
               // console.log("Save completed successfully.");
                
                 if(profileName == "Default"){ 
                var homeEvt = $A.get("e.force:navigateToURL");
                homeEvt.setParams({
                 "url": "/lightning/o/AITM_Tender__c/new?count=1"
                });
                
                
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
               homeEvt.fire();
                    workspaceAPI.closeTab({tabId: focusedTabId});
                  
                })
                }
                else{
                    var strUrl = ""+window.location;
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": strUrl,            
                    });
                    urlEvent.fire();
             }
            } else if (saveResult.state === "INCOMPLETE") {
                //.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                //console.log('Problem saving record, error: ' +
                           //JSON.stringify(saveResult.error));
            } else {
                //console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
        })
        );}
        
        
       
    },
    
  
     handleChange : function(component, event, helper) { 
         $A.util.removeClass(component.find("Spinner"), "slds-hide");
            var action = component.get("c.getEndDate");
        action.setParams({
            startDate: component.get("v.newtenderRecord.AITM_Start_Date__c"),
           
        });
        action.setCallback(this, function(response) {
            var edDate = response.getReturnValue();
            component.set("v.newtenderRecord.AITM_End_Date__c", edDate);
        })
        $A.util.addClass(component.find("Spinner"), "slds-hide");
        $A.enqueueAction(action);
            
        },
       
  
})