({
    validateForm: function(component) {
        var validContact = true;
       
        // Show error messages if required fields are blank
        var allValid = component.find('tender').reduce(function (validFields, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validFields && inputCmp.get('v.validity').valid;
         }, true);
        if (allValid) {
             // Verify we have an account to attach it to
            var tender = component.get("v.tenderRecord");
            if($A.util.isEmpty(tender)) {
                validContact = false;
                //console.log("Quick action context doesn't have a valid contact.");
            }
        return(validContact);
        }
	}
})