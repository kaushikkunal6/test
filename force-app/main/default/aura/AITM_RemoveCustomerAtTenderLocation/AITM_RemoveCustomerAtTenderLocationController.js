({
    doInit : function(component, event, helper) {
        helper.doInit(component);
    }, 

    delete : function(component, event, helper) {
        //helper.deleteAndClose(component, event);
        component.set('v.ispopupWindow', true);
       var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
    },
   
    closeModal:function(component,event,helper){    
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
     helper.close();
    },
 
    handleOK : function(component, event, helper) {
        helper.deleteAndClose(component, event);
    },

    showDetails : function(component, event, helper) {
        helper.showDetails(component, event);
    },

    close : function(component, event, helper) {
        helper.close();
    },
})