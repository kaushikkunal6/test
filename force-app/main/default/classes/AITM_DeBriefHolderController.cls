public with sharing class AITM_DeBriefHolderController {

    private static Map<String, AITM_RelatedRecordsHolderController.FilterOption> FILTERS_FOR_DEBRIEF;
    private @testVisible static String LOCATION_MANAGER_FIELD_API_NAME = 'AITM_Location_Manager__c';

    public static List<AITM_RelatedRecordsHolderController.FilterOption> getFilterOptions(Id tenderId) {
        return getFiltersForLocation(tenderId).values();
    }
    
    public static AITM_RelatedRecordsHolderController.FilterOption getFilter(String selectedFilter, Id tenderId) {
        return getFiltersForLocation(tenderId).get(selectedFilter);
    }

    private static Map<String,AITM_RelatedRecordsHolderController.FilterOption> getFiltersForLocation(Id tenderId) {
        if (FILTERS_FOR_DEBRIEF == null) {
            initializeFiltersForLocation(tenderId);
        }
        return FILTERS_FOR_DEBRIEF;
    }

    private static void initializeFiltersForLocation(Id tenderId) {
        FILTERS_FOR_DEBRIEF = new Map<String,AITM_RelatedRecordsHolderController.FilterOption>{
            'All Locations' => new AITM_RelatedRecordsHolderController.FilterOption('All Locations', false),
            'Locations With Volume Mismatch' => new LocationsVolumeMismatchOption('Locations With Volume Mismatch', false),
            'Locations with Quotes' => new LocationsWithQuotesOption('Locations with Quotes', false),
            'Locations without Quotes' => new LocationsWithoutQuotesOption('Locations without Quotes', false),
            'Locations with specific volumes' => new LocationsWithSpecificVolumes('Locations with specific volumes', false),
            'Locations with AdHoc Volume' => new LocationAdHocOption('Locations with AdHoc Volume', false),
            'Business Gained' => new BusinessGainedLocationsFilterOption('Business Gained', false),
            'Business Retained' => new BusinessRetainedLocationsFilterOption('Business Retained', false),
            'Business Lost' => new BusinessLostLocationsFilterOption('Business Lost', false),
            'Market Info' => new MarketInfoLocationsFilterOption('Market Info', false)
        };
        loadLocationManagerOptions(tenderId);
    }

    private static void loadLocationManagerOptions(Id tenderId) {
        for (AITM_Tender_Location__c tenderLocation : new AITM_LocationsDao().getTenderLocations(tenderId)) {
            String locationManagerName = tenderLocation.AITM_Location_Manager__r.Name;
            Id locationManagerId = tenderLocation.AITM_Location_Manager__c;
            FILTERS_FOR_DEBRIEF.put(locationManagerName, new AITM_RelatedTenderLocationsHolderCntrl.LocationManagerFilterOption(locationManagerName, locationManagerId));
        }
    }

    public class LocationsVolumeMismatchOption extends AITM_RelatedRecordsHolderController.FilterOption {
        public @AuraEnabled String name;
        public @AuraEnabled Boolean disabled;

        public LocationsVolumeMismatchOption(String name, Boolean disabled) {
            super(name, false);
            this.name = name;
            this.disabled = disabled;
        }

        public override Boolean isSelectiveFilter() {
            return false;
        }

        public override Boolean isPassedFilter(Object o) {
            AITM_Tender_Location_Line_Item__c lineItem = (AITM_Tender_Location_Line_Item__c) o;
            Boolean result = false;
            if (lineItem.AITM_Percentage_Volume_Offered__c < 100) {
                result = true;
            }
            return result;
        }
    }   

    public class LocationsWithQuotesOption extends AITM_RelatedRecordsHolderController.FilterOption {
        public @AuraEnabled String name;
        public @AuraEnabled Boolean disabled;

        public LocationsWithQuotesOption(String name, Boolean disabled) {
            super(name, false);
            this.name = name;
            this.disabled = disabled;
        }

        public override Boolean isSelectiveFilter() {
            return false;
        }

        public override Boolean isPassedFilter(Object o) {
            AITM_Tender_Location_Line_Item__c lineItem = (AITM_Tender_Location_Line_Item__c) o;
            Boolean result = true;

            if (lineItem.AITM_Offered_Differential__c == null) {
                result = false;
            }
            
            return result;
        }
    }

    public class LocationsWithoutQuotesOption extends AITM_RelatedRecordsHolderController.FilterOption {
        public @AuraEnabled String name;
        public @AuraEnabled Boolean disabled;

        public LocationsWithoutQuotesOption(String name, Boolean disabled) {
            super(name, false);
            this.name = name;
            this.disabled = disabled;
        }

        public override Boolean isSelectiveFilter() {
            return false;
        }

        public override Boolean isPassedFilter(Object o) {
            AITM_Tender_Location_Line_Item__c lineItem = (AITM_Tender_Location_Line_Item__c) o;
            Boolean result = true;

            if (lineItem.AITM_Offered_Differential__c != null) {
                result = false;
            }

            return result;
        }
    }

    public class LocationsWithSpecificVolumes extends AITM_RelatedRecordsHolderController.FilterOption {
        public @AuraEnabled String name;
        public @AuraEnabled Boolean disabled;

        public LocationsWithSpecificVolumes(String name, Boolean disabled) {
            super(name, false);
            this.name = name;
            this.disabled = disabled;
        }

        public override Boolean isSelectiveFilter() {
            return false;
        }

        public override Boolean isPassedFilter(Object o) {
            AITM_Tender_Location_Line_Item__c lineItem = (AITM_Tender_Location_Line_Item__c) o;
            Boolean result = true;

            if (lineItem.AITM_Offered_Volume__c == lineItem.AITM_Requested_Volume_USG__c) {
                result = false;
            }

            return result;
        }
    }

    public class LocationAdHocOption extends AITM_RelatedRecordsHolderController.FilterOption {
        public @AuraEnabled String name;
        public @AuraEnabled Boolean disabled;

        public LocationAdHocOption(String name, Boolean disabled) {
            super(name, false);
            this.name = name;
            this.disabled = disabled;
        }

        public override Boolean isSelectiveFilter() {
            return false;
        }

        public override Boolean isPassedFilter(Object o) {
            AITM_Tender_Location_Line_Item__c lineItem = (AITM_Tender_Location_Line_Item__c) o;
            return lineItem.AITM_Ad_hoc_Volume__c;
        }
    }

    public class BusinessGainedLocationsFilterOption extends AITM_RelatedRecordsHolderController.FilterOption {
        public @AuraEnabled String name;
        public @AuraEnabled Boolean disabled;

        public BusinessGainedLocationsFilterOption(String name, Boolean disabled) {
            super(name, false);
            this.name = name;
            this.disabled = disabled;
        }

        public override Boolean isSelectiveFilter() {
            return false;
        }

        public override Boolean isPassedFilter(Object o) {
            AITM_Tender_Location_Line_Item__c lineItem = (AITM_Tender_Location_Line_Item__c) o;
            Boolean result = false;
            if(lineItem.AITM_Tender_Result__c == 'BG'){
                result = true;
            }
            return result;
        }
    }

    public class BusinessRetainedLocationsFilterOption extends AITM_RelatedRecordsHolderController.FilterOption {
        public @AuraEnabled String name;
        public @AuraEnabled Boolean disabled;

        public BusinessRetainedLocationsFilterOption(String name, Boolean disabled) {
            super(name, false);
            this.name = name;
            this.disabled = disabled;
        }

        public override Boolean isSelectiveFilter() {
            return false;
        }

        public override Boolean isPassedFilter(Object o) {
            AITM_Tender_Location_Line_Item__c lineItem = (AITM_Tender_Location_Line_Item__c) o;
            Boolean result = false;
            if(lineItem.AITM_Tender_Result__c == 'BR'){
                result = true;
            }
            return result;
        }
    }

    public class BusinessLostLocationsFilterOption extends AITM_RelatedRecordsHolderController.FilterOption {
        public @AuraEnabled String name;
        public @AuraEnabled Boolean disabled;

        public BusinessLostLocationsFilterOption(String name, Boolean disabled) {
            super(name, false);
            this.name = name;
            this.disabled = disabled;
        }

        public override Boolean isSelectiveFilter() {
            return false;
        }

        public override Boolean isPassedFilter(Object o) {
            AITM_Tender_Location_Line_Item__c lineItem = (AITM_Tender_Location_Line_Item__c) o;
            Boolean result = false;
            if(lineItem.AITM_Tender_Result__c == 'LB'){
                result = true;
            }
            return result;
        }
    }

    public class MarketInfoLocationsFilterOption extends AITM_RelatedRecordsHolderController.FilterOption {
        public @AuraEnabled String name;
        public @AuraEnabled Boolean disabled;

        public MarketInfoLocationsFilterOption(String name, Boolean disabled) {
            super(name, false);
            this.name = name;
            this.disabled = disabled;
        }

        public override Boolean isSelectiveFilter() {
            return false;
        }

        public override Boolean isPassedFilter(Object o) {
            AITM_Tender_Location_Line_Item__c lineItem = (AITM_Tender_Location_Line_Item__c) o;
            Boolean result = false;
            if(lineItem.AITM_Tender_Result__c == 'MI' || lineItem.AITM_Tender_Result__c == 'MIX'){
                result = true;
            }
            return result;
        }
    }
}