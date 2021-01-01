({
    doInit : function(component, event, helper) {
        helper.doInit(component);
    },
	
    onFilterChange : function(component, event, helper) {
        helper.onFilterChange(component, event);
    },

    generate : function(component, event, helper) {
       var checkValue = false;
       var isOldTender = component.get('v.isTenderOld');
        /*if(!isOldTender){
            checkValue = component.find("refreshcheckbox").get("v.checked");
        }*/
        var isReportButton = component.get('v.isReportButton');
        if(isOldTender || (!checkValue)){
            if(!isReportButton){
                 helper.generate(component);
            }else{
                helper.generateOfferWithoutRefreshTaxfees(component);
            }
        }
        else {
              if(!isReportButton){
                  helper.generateOfferAfterRefresh(component);
              }else {
                  helper.refreshAndGenerateOfferTFReport(component);
              }
        }
    },

    close : function(component, event, helper) {
        helper.close();
    },
    
    copyHardcoreText : function(component, event, helper) {
        var textForCopy = component.find('copy').get("v.value");
        helper.copyTextHelper(component,event,textForCopy);
    },
})