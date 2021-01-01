({ 
    COMPONENT_NAME : "DeBriefHolder",

    doInit : function(component) {
        this.getFilterOptions(component);
    },

    onFilterChange : function(component) {
        this.onFilterChangeBase(component, this.COMPONENT_NAME);
    },

    search : function(component) {
        var helper = this;
        this.searchBase(component, this.COMPONENT_NAME, helper, function(searchTerm, helper){
            helper.fireSearchEvent(searchTerm);}, 
            function(component, helper){
            helper.onFilterChange(component);}
        );
    },

    getFilterOptions : function(component) {
        this.getFilterOptionsBase(component, this.COMPONENT_NAME);
    },

    fireFiltersEvent : function(component, filter) {
        var tenderId = component.get("v.recordId");

        var evt = $A.get("e.c:AITM_RelatedRecordsFilterEvent");
        evt.setParams({
            "filter": filter,
            "tenderId": tenderId
        }); 
        evt.fire(); 
    },

    fireSearchEvent : function(searchTerm) {
        var evt = $A.get("e.c:AITM_RelatedRecordsSearchEvent");
        evt.setParams({
            "searchTerm": searchTerm
        }); 
        evt.fire();
    },

    resetFilterOption : function(component) {
        component.set("v.selectedFilter", "All Locations");
    }
})