({
	STAGE_TENDER_CREARED : "Tender Created",

	handleChangeStage : function(component, event) {
		if(event.getParam("currentStage") == this.STAGE_TENDER_CREARED) {
			this.createComponent(component, 'c:AITM_TenderInvitationEmailGenerator');
		}
	},

    createComponent : function(component, componentName) {
		var modalBody;
		$A.createComponent(componentName, 
		{recordId: component.get("v.recordId")},
		function(content, status) {
			if (status === "SUCCESS") {
				modalBody = content;
				component.find('componentHolder')
					.showCustomModal({
						body: modalBody, 
						showCloseButton: true,
						cssClass: "mymodal",
						closeCallback: function() {}
					}).then(function (overlay) {
				     	component.set('v.overlayPanel', overlay);
				    });
			}

		});
    },

    closePopup : function(component) {
        var overlay = component.get('v.overlayPanel')[0];
        setTimeout(function() {
            if (overlay) { 
                overlay.close();
            } 
        }, 500);
    },

})