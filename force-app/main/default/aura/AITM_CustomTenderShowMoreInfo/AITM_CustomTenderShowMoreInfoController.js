({
	init : function(component, event, helper) {
		helper.getDefaultValuesForCheckboxes(component);
	},

    handleCurrentStage : function(component, event, helper) {
        helper.handleCurrentStage(component, event);
    },

    produceCustomerEmailChangeState : function(component, event, helper) {
    	helper.produceCustomerEmailChangeState(component, event);
    },

    setCheckBoxFeedbackToDeBrief : function(component, event, helper) {
    	helper.setCheckBoxFeedbackToDeBrief(component, event);
    },

    closePopup : function(component, event, helper) {
    	helper.closePopup(component);
    },

    addCustomer : function(component, event, helper) {
    	helper.createComponent(component, 'c:AITM_AddCustomer');
    },
	
    addGroup : function(component, event, helper) {
    	helper.createComponent(component, 'c:AITM_AddGroup');
    },
    
    addLocation : function(component, event, helper) {
    	helper.createComponent(component, 'c:AITM_AddLocations');
    },

    uploadLocation : function(component, event, helper) {
    	helper.createComponent(component, 'c:AITM_LoadLocations');
    },

    chasePrices : function(component, event, helper) {
    	helper.createComponent(component, 'c:AITM_TenderInvitationEmailGenerator');
    },
    
    chasePolishPrices : function(component, event, helper) {
        helper.createComponent(component, 'c:AITM_TenderInvitationEmailGeneratorPolish');
    },

    generateOffer : function(component, event, helper) {
        component.set('v.isReportButton', false);
    	helper.createComponent(component, 'c:AITM_TenderOfferContainer');
    },
    
    generateCongaOffer : function(component, event, helper) {
    	helper.createComponent(component, 'c:AITM_TenderCongaOfferContainer');
    },

    sendOffer : function(component, event, helper) {
    	helper.createComponent(component, 'c:AITM_GenerateOfferButton');
    },

    sendFeedback : function(component, event, helper) {
    	helper.createComponent(component, 'c:AITM_GenerateRoundsEmail');
    },

    sendFeedbackPolish : function(component, event, helper) {
        helper.createComponent(component, 'c:AITM_GenerateRoundsEmailPolish');
    },

    sendDeBriefEmail : function(component, event, helper) {
    	helper.createComponent(component, 'c:AITM_DeBriefEmailGenerator');
    },

    sendDeBriefEmailPolish : function(component, event, helper) {
        helper.createComponent(component, 'c:AITM_DeBriefEmailGeneratorPolish');
    },

    generateContract : function(component, event, helper) {
    	helper.createComponent(component, 'c:AITM_TenderContractContainer');
    },
	
    generateCongaContract : function(component, event, helper) {
    	helper.createComponent(component, 'c:AITM_TenderCongaContractContainer');
    },
    
    sendContract : function(component, event, helper) {
    	helper.createComponent(component, 'c:AITM_GenerateContractEmailButton');
    },

    sendWithCongaSign : function(component, event, helper) {
    	helper.launchCongaSign(component);
    },

    downloadExcelFile: function(component, event, helper) {
       //helper.downloadExcelFile(component);		        
       var isOldTender = component.get('v.isTenderOld');
       if(isOldTender){
           helper.downloadExcelFile(component);
       }else{
           component.set('v.isReportButton', true);
           helper.createComponent(component, 'c:AITM_TenderOfferContainer');
       }
    }		    
})