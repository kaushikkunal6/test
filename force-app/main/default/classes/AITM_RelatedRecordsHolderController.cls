public with sharing class AITM_RelatedRecordsHolderController {
    private static final Map<String, String> COMPONENT_NAMES = new Map<String, String>{
        'RelatedLocations' => 'RelatedTenderLocationsHolder',
        'Debrief' => 'DeBriefHolder'
    };

    public static @AuraEnabled List<FilterOption> getFilterOptions(String componentName, Id tenderId) {
        if (componentName == COMPONENT_NAMES.get('RelatedLocations')) {
            return AITM_RelatedTenderLocationsHolderCntrl.getFilterOptions(tenderId);
        } else if (componentName == COMPONENT_NAMES.get('Debrief')) {
            return AITM_DeBriefHolderController.getFilterOptions(tenderId);
        }
        return null;
    }

    public static @AuraEnabled FilterOption getFilter(String componentName, String selectedFilter, Id tenderId) {
        if (componentName == COMPONENT_NAMES.get('RelatedLocations')) {
            return AITM_RelatedTenderLocationsHolderCntrl.getFilter(selectedFilter, tenderId);
        } else if (componentName == COMPONENT_NAMES.get('Debrief')) {
            return AITM_DeBriefHolderController.getFilter(selectedFilter, tenderId);
        }
        return null;
    }

    public virtual class FilterOption {
        public @AuraEnabled String name;
        public @AuraEnabled Boolean disabled;

        public FilterOption(String name, Boolean disabled) {
            this.name = name;
            this.disabled = disabled;
        }

        public virtual List<String> getCriteria() {
            return new List<String>{};
        }
        
        public virtual Boolean isSelectiveFilter() {
            return false;
        }

        public virtual Boolean isPassedFilter(Object o) {
            return true;
        }
    }
}