({
	doInit : function(component) {
		this.getTender(component);
		this.updateVariance(component);
	},

	getTender: function(component) {
		var tender = component.get("v.tender");
		if(tender != null){
			var action = component.get("c.getTender");

			action.setParams({
				"tender": tender
			});

			action.setCallback(this, function(actionResult) {
				var state = actionResult.getState();
				if (state === 'SUCCESS'){
					var result = actionResult.getReturnValue();
					component.set("v.tender", result);
				} 
				component.set("v.isAfterInit", true);
			}); 

			$A.enqueueAction(action);  
		}
	},

	updateTender: function(component, event) {
		var compEvent = component.getEvent("updateTenderEvent");
		compEvent.fire();
	},

	updateVariance: function(component) {
		var tender = component.get("v.tender");
		if(tender != null){
			component.set('v.grossProfitVariance', this.getDifference(tender.AITM_Gross_Profit_New_Contract__c, tender.AITM_Gross_Profit_Previous_Contract__c));
			component.set('v.volumeVariance', this.getDifference(tender.AITM_Volume_New_Contract__c, tender.AITM_Volume_Previous_Contract__c));
			component.set('v.workingCapitalVariance', this.getDifference(tender.AITM_Working_Capital_New_Contract__c, tender.AITM_Working_Capital_Previous_Contract__c));
			component.set('v.pricePerfIndexVariance', this.getDifference(tender.AITM_Price_Perf_Index_New_Contract__c, tender.AITM_Price_Perf_Index_Prev_Contract__c));
			component.set('v.rowcVariance', this.getDifference(tender.AITM_ROWC_New_Contract__c, tender.AITM_ROWC_Previous_Contract__c));
		}
		
	},

    getDifference: function(value1, value2) {
        let diff;

        if(value1 == null && value2 == null) {
            diff = 0;
        }else if(value1 == null) {
            diff = value2;
        }else if(value2 == null) {
            diff = value1;
        }else {
            diff = value1 - value2;
        }

        return diff;
    }
})