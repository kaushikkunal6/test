({
    qsToEventMap: {
        'startURL'  : 'e.c:AITM_setStartUrl'
    },
	
    togglePanel : function(component,event,secId) {
	  var acc = component.find(secId);
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show'); 
        	$A.util.toggleClass(acc[cmp], 'slds-hide');   
       }
	},
    
    handleLogin: function (component, event, helpler) {
        var usernameField = component.find("username");
        var passwordField = component.find("password");
        var username = component.find("username").get("v.value");
        var password = component.find("password").get("v.value");
        var sfdcUserName = component.find('sfdc_username_container');
        var sfdcPassword = component.find('sfdc_password_container');
        
        var action = component.get("c.login");
        var startUrl = component.get("v.startUrl");
        
        startUrl = decodeURIComponent(startUrl);
        
        action.setParams({username:username, password:password, startUrl:startUrl});
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set("v.errorMessage",rtnValue);
                component.set("v.showError",true);
                if($A.util.isEmpty(username) || $A.util.isUndefined(username)){
            		$A.util.addClass(sfdcUserName, "error");  
        		} else {
            		$A.util.removeClass(sfdcUserName, "error");  
        		}
                if($A.util.isEmpty(password) || $A.util.isUndefined(password)){
                    $A.util.addClass(sfdcPassword, "error");
                }         
                else {
                    $A.util.removeClass(sfdcPassword, "error");
                }
            }
            else {
                //Fire login event for iOS
                try {
                    webkit.messageHandlers.callbackHandler.postMessage("login");
                } catch(err) {}
                
                //Fire login event for Android
                try {
                    LoginPage.login();
                } catch(err) {}
            }
        });
        $A.enqueueAction(action);
    },
    
    getIsUsernamePasswordEnabled : function (component, event, helpler) {
        var action = component.get("c.getIsUsernamePasswordEnabled");
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isUsernamePasswordEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCommunityForgotPasswordUrl : function (component, event, helpler) {
        var action = component.get("c.getForgotPasswordUrl");
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communityForgotPasswordUrl',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
})