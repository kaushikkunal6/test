({

	doInit : function(component) {
		component.find('navService').navigate({
			type: 'standard__component',
			attributes: {
				componentName: 'c__AITM_LightningSharing'
			},
			state: {
				"c__recordId": component.get('v.recordId')
			}
		});
	}

})