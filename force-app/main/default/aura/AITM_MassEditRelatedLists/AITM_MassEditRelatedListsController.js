({
       doInit: function(component, event, helper) {
           
         var action = component.get("c.getLayout");

        var params = {
            "recordId": component.get("v.recordId"),
            "sObjectName": component.get("v.sObjectName"),
         //   "sessionID":component.get("v.mySessionID")
        };

        action.setParams(params);
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
               // console.log(a.getReturnValue());
                component.set("v.layout", a.getReturnValue());
                component.set("v.isGlobalActionsCardVisible",true);
            }else if (state === "ERROR") {
                var errors = a.getError();
                //helper.showToast(component,event,'Error','Error preventing to load ...','error');
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showToast(component,event,'Error',errors[0].message,'error');
                        component.set("v.loadErrorMessage",errors[0].message);
                        if (errors[0].message.includes("endpoint"))
                        	$A.util.removeClass(component.find("createRemoteSiteCard"), "slds-hide");
                        else
                        	$A.util.removeClass(component.find("unknownErrorCard"), "slds-hide");
                    }
                } else {
                    helper.showToast(component,event,'Unknown Error','Unknown Error','error');
                    component.set("v.loadErrorMessage",'Unkown Error...');
                    
                }
            }   
            var loadingCard = component.find("loadingCard");
            $A.util.addClass(loadingCard, "slds-hide"); 
        });

        $A.enqueueAction(action);    
        component.set("v.loadStep","Waiting answer from metadata api...");    
     //   }, false);     
             

    },
    
    cleanChatter: function(component,event,helper){
        	$A.createComponent(
			 component.get("v.namespace.prefix")+":MassEditRLDeleteChatterPostsModal",
			 {
					 "aura:id": "MassEditRLDeleteChatterPostsModal",
			 },
			 function(newCmp, status, errorMessage){
					 //Add the new button to the body array
					 if (status === "SUCCESS") {
							 var targetCmp = component.find('modalArea');
							 var body = targetCmp.get("v.body");
							 body.push(newCmp);
							 targetCmp.set("v.body", body);
					 }
			 }
		 );  
    },
    
    editLayout: function(component, event, helper) {
       var layoutId=component.get("v.layout.layoutId");
       var objectId=component.get("v.layout.objectId");
       var myDomain=component.get("v.myDomain"); 
       var layoutPath='layouteditor/layoutEditor.apexp?type='+objectId+'&lid='+layoutId;  
       var lightningLink='https://'+myDomain+'.lightning.force.com/one/one.app#/setup/ObjectManager/';
       lightningLink+=objectId+'/PageLayouts/page?address='+encodeURIComponent('/'+layoutPath);  
       helper.newTabToURL(lightningLink); 
    },
    
    editObjectFields: function(component, event, helper) {
       var objectId=component.get("v.layout.objectId");
       var myDomain=component.get("v.myDomain"); 
       var editObjectLink='https://'+myDomain+'.lightning.force.com/one/one.app#/setup/ObjectManager/';
       editObjectLink+=objectId+'/FieldsAndRelationships/view'; 
       helper.newTabToURL(editObjectLink); 
    },
    
   about: function(component, event, helper) {
     		$A.createComponent(
			 component.get("v.namespace.prefix")+":MassEditRLAboutModal",
			 {
					 "aura:id": "About Modal",
			 },
			 function(newCmp, status, errorMessage){
					 //Add the new button to the body array
					 if (status === "SUCCESS") {
							 var targetCmp = component.find('modalArea');
							 var body = targetCmp.get("v.body");
							 body.push(newCmp);
							 targetCmp.set("v.body", body);
					 }
			 }
		 );  
   }    
    
    
})