({
    initialize: function(component, event, helper) {
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();    
        component.set('v.isUsernamePasswordEnabled', helper.getIsUsernamePasswordEnabled(component, event, helper));
        component.set("v.communityForgotPasswordUrl", helper.getCommunityForgotPasswordUrl(component, event, helper));
        helper.togglePanel(component,event,'panelOne');
        //this.panelOne(component, event, helper);
    },
    handleLogin: function (component, event, helper) {
        helper.handleLogin(component, event, helper);
    },
    panelOne : function(component, event, helper) {
       helper.togglePanel(component,event,'panelOne');
    },
    onKeyUp: function(component, event, helper){
        //checks for "enter" key
        if (event.getParam('keyCode')===13) {
            helper.handleLogin(component, event, helper);
        }
    },
    handleClearError:function(component,event,helper){
        var comp = event.getSource();
        var sfdcUserName = component.find('sfdc_username_container');
        var sfdcPassword = component.find('sfdc_password_container');
        $A.util.removeClass(sfdcUserName, "error");  
        $A.util.removeClass(sfdcPassword, "error");   
    },
    handleError:function(component,event,helper){
        var comp = event.getSource();
        var sfdcUserName = component.find('sfdc_username_container');
        var sfdcPassword = component.find('sfdc_password_container');
        $A.util.addClass(sfdcUserName, "error");   
        $A.util.addClass(sfdcPassword, "error");   
    },
    setStartUrl: function (component, event, helper) {
        var startUrl = event.getParam('startURL');
        if(startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },
   
    navigateToForgotPassword: function(cmp, event, helper) {
        var forgotPwdUrl = cmp.get("v.communityForgotPasswordUrl");
        if ($A.util.isUndefinedOrNull(forgotPwdUrl)) {
            forgotPwdUrl = cmp.get("v.forgotPasswordUrl");
        }
        var attributes = { url: forgotPwdUrl };
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    },
    
    rememberme: function(cmp, event, helper) {
        
    }
})