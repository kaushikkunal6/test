({
	handleForgotPassword: function (component, event, helpler) {
        var checkEmailUrl = component.get("v.checkEmailUrl");
        var actionEmail = component.get("c.forgotPassword");
        var userName = component.find("username");
        component.set("v.emailInput", userName.get("v.value"));
        var email = component.get("v.emailInput");
        actionEmail.setParams({username:email, checkEmailUrl:checkEmailUrl});
        actionEmail.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set("v.errorMessage",rtnValue);
                component.set("v.showError",true);
            }
            else {
                this.deleteCookie("startUrl");
            }
        });
        $A.enqueueAction(actionEmail);
    }
})