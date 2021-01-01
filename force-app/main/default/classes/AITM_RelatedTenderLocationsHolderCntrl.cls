/*************************************************************************
 * @author         George
 * @date           01/December/2017
 * @group          AirBP
 * @description    controller class for relatedtenderlocationholder lightning component

 * history
 * 01/December/2017  George       Created
 * 01/March/2018     srnandan     Modified - AR-2726 Added constant variable 'PROFILES_WITH_SUMMARYCOUNTRY_TAB_VISIBILITY'
 *                                list of profiles for tab visibility. added method 'getDisplaySummaryByCountry' which returns
 *                                true if user profile matches with the list PROFILES_WITH_SUMMARYCOUNTRY_TAB_VISIBILITY
 *                                added comments at class and method level as per coding standards   
 * 14th/March/2019   Shweta       Modified - AR-5037 - Updated the method delete rounds to delete TLLI records also with round deletion 
 * 10th/April/2019   Shweta       Modified - AR-5123 - Added new filters and updated the existing ones                        
 * 20/May/2020       Kunal        Modified - 178855 Fixed Locations Filter issue for Conga specific
 *************************************************************************/
public with sharing class AITM_RelatedTenderLocationsHolderCntrl {
    
    private static Map<String, AITM_RelatedRecordsHolderController.FilterOption> FILTERS_FOR_LOCATION;
    private static Map<String, AITM_RelatedRecordsHolderController.FilterOption> FILTERS_FOR_LOCATION_FOR_CONGA;
    private @testVisible static String LOCATION_MANAGER_FIELD_API_NAME = 'AITM_Location_Manager__c';
    private @testVisible static String AD_HOC_FIELD_API_NAME = 'AITM_Ad_hoc_Volume__c';
    private static final String STATUS_NOT_REPRESENTED = 'Not Represented';
    private static final Set<String> PROFILES_WITH_SUMMARYCOUNTRY_TAB_VISIBILITY = new Set<String>{'Air_TMLABPLM','Air_TMLocation Manager','Air_TMLocationAdmin','System Administrator'};

    /**
     * @description gets bidinby details for a tender
     * @param tenderId of type Id
     * @return string
     */
    public static @AuraEnabled String getBidsInBy(Id tenderId) {
        AITM_Tender__c result = new AITM_TenderDao().getTender(tenderId);
        if (result.AITM_Bids_In_By__c == null) {
            return 'N/A';
        }
        return result.AITM_Bids_In_By__c.format();
    }
    
    /**
     * @description get Tender is Old Or New
     * @param tenderId of type Id
     * @return AITM_Tender__c
     */
    public static @AuraEnabled AITM_Tender__c getTenderOldOrNew(Id tenderId) {  
        AITM_Tender__c result = new AITM_TenderDao().getTender(tenderId);   
        return result;  
    }

    /**
     * @description returns true if user profile matches with profiles tab visibility
     * @param null
     * @return boolean
     */
    public static @AuraEnabled Boolean getDisplaySummaryByCountry() {
       Boolean displaySummaryByCountry = false;
      String currentUserProfile = new AITM_UsersDao().getProfileName(UserInfo.getUserId());
      if(PROFILES_WITH_SUMMARYCOUNTRY_TAB_VISIBILITY.contains(currentUserProfile)) {
        displaySummaryByCountry = true;
      }
      return displaySummaryByCountry; 
    }

    /**
     * @description gets filter round options list
     * @param tenderId of type Id
     * @return List collection AITM_RelatedRecordsHolderController.FilterOption
     */
    public static @AuraEnabled List<AITM_RelatedRecordsHolderController.FilterOption> getRoundsOptions(Id tenderId) {
        List<AggregateResult> result =  [SELECT Max(AITM_Round__c) maxRound FROM AITM_Tender_Location__c WHERE AITM_Tender__c = :tenderId];
        List<AITM_RelatedRecordsHolderController.FilterOption> roundsOptions = new List<AITM_RelatedRecordsHolderController.FilterOption>();

        if (result[0].get('maxRound') != null) {
            Integer maxRound = Integer.valueOf(result[0].get('maxRound'));
            do {
                roundsOptions.add(new AITM_RelatedRecordsHolderController.FilterOption('Round ' + String.valueOf(maxRound), false));
                maxRound--;
            } while (maxRound != 0);
        } else {
            roundsOptions.add(new AITM_RelatedRecordsHolderController.FilterOption('Round 1', false));
        }
        return roundsOptions;
    }
    
    /**
     * @description gets filter options
     * @param tenderId of type Id
     * @return List collection AITM_RelatedRecordsHolderController.FilterOption
     */
    public static List<AITM_RelatedRecordsHolderController.FilterOption> getFilterOptions(Id tenderId) {
        return getFiltersForLocation(tenderId).values();
    }
    
    /**
     * @description gets filter options for CONGA
     * @param tenderId of type Id
     * @return List collection AITM_RelatedRecordsHolderController.FilterOption
     */
    public static List<AITM_RelatedRecordsHolderController.FilterOption> getFilterOptionsForConga(Id tenderId) {
        return getFiltersForLocationForConga(tenderId).values();
    }
    
    /**
     * @description gets filter
     * @param selectedFilter of type string
     * @return AITM_RelatedRecordsHolderController.FilterOption
     */
    public static AITM_RelatedRecordsHolderController.FilterOption getFilter(String selectedFilter, Id tenderId) {
        return getFiltersForLocation(tenderId).get(selectedFilter);
    }

    /**
     * @description gets filter for location contructor
     * @param tenderId of type Id
     * @return Map
     */
    private static Map<String,AITM_RelatedRecordsHolderController.FilterOption> getFiltersForLocation(Id tenderId) {
        if (FILTERS_FOR_LOCATION == null) {
            initializeFiltersForLocation(tenderId);
        }
        return FILTERS_FOR_LOCATION;
    }
    
    /**
     * @description gets filter for location contructor for CONGA
     * @param tenderId of type Id
     * @return Map
     */
    private static Map<String,AITM_RelatedRecordsHolderController.FilterOption> getFiltersForLocationForConga(Id tenderId) {
        if (FILTERS_FOR_LOCATION_FOR_CONGA == null) {
            initializeFiltersForLocationForConga(tenderId);
        }
        return FILTERS_FOR_LOCATION_FOR_CONGA;
    }

    /**
     * @description overloaded contructor
     * @param tenderId of type Id
     * @return void
     */
    private static void initializeFiltersForLocation(Id tenderId) {
        FILTERS_FOR_LOCATION = new Map<String,AITM_RelatedRecordsHolderController.FilterOption>{
            'All Locations' => new AITM_RelatedRecordsHolderController.FilterOption('All Locations', false),
            'Locations with Awaiting Price' => new AwaitingPriceLocations('Locations with Awaiting Price', false),
            'Locations with Priced' => new PricedLocations('Locations with Priced', false),
            'Locations With Volume Mismatch' => new LocationsVolumeMismatchOption('Locations With Volume Mismatch', false),
            'Represented Locations' => new RepresentedTenderLocations('Represented Locations', false),
            'Non-represented Locations' => new NotRepresentedTenderLocations('Non-represented Locations', false),
            'Locations with Quotes' => new LocationsWithQuotesOption('Locations with Quotes', false),
            'Locations without Quotes' => new LocationsWithoutQuotesOption('Locations without Quotes', false),
            'Locations with Volumes' => new LocationsWithSpecificVolumes('Locations with Volumes', false),
            'Locations with AdHoc Volume' => new LocationAdHocOption('Locations with AdHoc Volume', false),
            'Locations to be included in revised offer' => new LocationsRevisedOffer('Locations to be included in revised offer', false)
        };
        loadLocationManagerOptions(tenderId);
    }
    
    /**
     * @description overloaded contructor for CONGA
     * @param tenderId of type Id
     * @return void
     */
    private static void initializeFiltersForLocationForConga(Id tenderId) {
        FILTERS_FOR_LOCATION_FOR_CONGA = new Map<String,AITM_RelatedRecordsHolderController.FilterOption>{
            'All Locations' => new AITM_RelatedRecordsHolderController.FilterOption('All Locations', false),
            'Locations with Priced' => new PricedLocations('Locations with Priced', false),
            'Represented Locations' => new RepresentedTenderLocations('Represented Locations', false),
            'Non-represented Locations' => new NotRepresentedTenderLocations('Non-represented Locations', false),
            'Locations with Quotes' => new LocationsWithQuotesOption('Locations with Quotes', false),
            'Locations with Volumes' => new LocationsWithSpecificVolumes('Locations with Volumes', false),
            'Locations with AdHoc Volume' => new LocationAdHocOption('Locations with AdHoc Volume', false)
        };
        loadLocationManagerOptions(tenderId);
    }

   /**
    * @description gets filtered tender locations details for a given tender and parsedfilter passed
    * @param tenderId of type Id
    * @param parsedFilter of type AITM_RelatedRecordsHolderController.FilterOption
    * @return List collection of TenderLocationAdapter
    */
    @AuraEnabled
    public Static void deleteRounds(Id tenderId, Decimal currentRoundNumber){
        List<AITM_Tender_Location__c> tenderLocations = [SELECT AITM_Round__c, AITM_Tender__c FROM AITM_Tender_Location__c WHERE AITM_Tender__c =:tenderId AND AITM_Round__c =:currentRoundNumber];
        Map<Id, AITM_Tender_Location__c> tenderLocationMap = new Map<Id, AITM_Tender_Location__c>([SELECT AITM_Round__c, AITM_Tender__c FROM AITM_Tender_Location__c WHERE AITM_Tender__c =:tenderId AND AITM_Round__c =:currentRoundNumber]);
        if(tenderLocations.size() > 0) {
            List<AITM_Tender_Location_Line_Item__c> lineItems = [SELECT Id from AITM_Tender_Location_Line_Item__c where AITM_Tender_Location__c IN : tenderLocationMap.keySet() AND AITM_Round__c =:currentRoundNumber];
            delete lineItems;
            delete tenderLocationMap.values();
        }
        List<AITM_Tender_Location__c> updateLocationsList = new List<AITM_Tender_Location__c>();
        List<AITM_Tender_Location__c> currentLocationsList = [SELECT AITM_Round__c,AITM_Tender__c,AITM_Current_Round__c FROM AITM_Tender_Location__c WHERE AITM_Tender__c =:tenderId];
        for(AITM_Tender_Location__c singleTenderLocation:currentLocationsList) {
            singleTenderLocation.AITM_Current_Round__c = currentRoundNumber - 1;
            updateLocationsList.add(singleTenderLocation);
        }
        AITM_TenderLocationHandler.createTenderlocation = false;
        update updateLocationsList;
    }

    /**
     * @description loads location manager options
     * @param tenderId of type Id
     * @return void
     */
    private static void loadLocationManagerOptions(Id tenderId) {
        for (AITM_Tender_Location__c tenderLocation : new AITM_LocationsDao().getTenderLocations(tenderId)) {
            String locationManagerName = tenderLocation.AITM_Location_Manager__r.Name;
            Id locationManagerId = tenderLocation.AITM_Location_Manager__c;
            if(FILTERS_FOR_LOCATION != null){
                FILTERS_FOR_LOCATION.put(locationManagerName, new LocationManagerFilterOption(locationManagerName, locationManagerId));
            }
            if(FILTERS_FOR_LOCATION_FOR_CONGA != null){
                FILTERS_FOR_LOCATION_FOR_CONGA.put(locationManagerName, new LocationManagerFilterOption(locationManagerName, locationManagerId));
            }
        }
    }

    /**
     * @description class holder location manager filter options
     */
    public inherited sharing class LocationManagerFilterOption extends AITM_RelatedRecordsHolderController.FilterOption {
        public @AuraEnabled String name;
        public @AuraEnabled Boolean disabled;
        public @AuraEnabled Id locationManagerId;

        /**
         * @description overloaded contructor
         * @param locationManagerName of type string
         * @param locationManagerId of type Id
         */
        public LocationManagerFilterOption(String locationManagerName, Id locationManagerId) {
            super(locationManagerName, false);
            this.name = locationManagerName;
            this.disabled = false;
            this.locationManagerId = locationManagerId;
        }

        /**
         * @description gets list of criterias
         * @param null
         * @return List collection of string
         */
        public override List<String> getCriteria() {
            return new List<String> {AITM_RelatedTenderLocationsHolderCntrl.LOCATION_MANAGER_FIELD_API_NAME + ' = \'' + locationManagerId + '\''};
        }

        /**
         * @description returns true
         * @param null
         * @return boolean
         */
        public override Boolean isSelectiveFilter() {
            return true;
        }
    }

    /**
     * @description class holds location volume mismatch options
     */
    public inherited sharing class LocationsVolumeMismatchOption extends AITM_RelatedRecordsHolderController.FilterOption {
        public @AuraEnabled String name;
        public @AuraEnabled Boolean disabled;

        /**
         * @description overloaded contructor
         * @param name of type string
         * @param disabled of type boolean
         */
        public LocationsVolumeMismatchOption(String name, Boolean disabled) {
            super(name, false);
            this.name = name;
            this.disabled = disabled;
        }

        /**
         * @description return false
         * @param null
         * @return boolean
         */
        public override Boolean isSelectiveFilter() {
            return false;
        }

        /**
         * @description return true if lineitem.aitm_percentage_volume_offered is less than 100
         * @param o of type object
         * @return boolean
         */
        public override Boolean isPassedFilter(Object o) {
            AITM_Tender_Location__c tenderLocation = (AITM_Tender_Location__c) o;
            Boolean result = false;
            for (AITM_Tender_Location_Line_Item__c lineItem : tenderLocation.AITM_Tender_Location__r) {
                if (lineItem.AITM_Percentage_Volume_Offered__c < 100) {
                    result = true;
                    break;
                }
            }
            return result;
        }
    }

    /**
     * @description class holds locations with quotes option
     */
    public inherited sharing class LocationsWithQuotesOption extends AITM_RelatedRecordsHolderController.FilterOption {
        public @AuraEnabled String name;
        public @AuraEnabled Boolean disabled;

        /**
         * @description overloaded contructor
         * @param name of type string
         * @param disabled of type boolean
         */
        public LocationsWithQuotesOption(String name, Boolean disabled) {
            super(name, false);
            this.name = name;
            this.disabled = disabled;
        }

        /**
         * @description returns false
         * @param null
         * @return boolean
         */
        public override Boolean isSelectiveFilter() {
            return false;
        }

        /**
         * @description returns false if offered differential of line item is null
         * @param o of type object
         * @return boolean
         */
        public override Boolean isPassedFilter(Object o) {
            AITM_Tender_Location__c tenderLocation = (AITM_Tender_Location__c) o;
            Boolean result = true;
            for (AITM_Tender_Location_Line_Item__c lineItem : tenderLocation.AITM_Tender_Location__r) {
                if (lineItem.AITM_Offered_Differential__c == null) {
                    result = false;
                    break;
                }
            }
            return result;
        }
    }

    /**
     * @description class to hold locations without quotes options
     */
    public inherited sharing class LocationsWithoutQuotesOption extends AITM_RelatedRecordsHolderController.FilterOption {
        public @AuraEnabled String name;
        public @AuraEnabled Boolean disabled;

        /**
         * @description overloaded contructor
         * @param name of type string
         * @param disabled of type boolean
         */
        public LocationsWithoutQuotesOption(String name, Boolean disabled) {
            super(name, false);
            this.name = name;
            this.disabled = disabled;
        }

        /**
         * @description return false
         * @param null
         * @return boolean
         */
        public override Boolean isSelectiveFilter() {
            return false;
        }

        /**
         * @description return false if offered differential line item is not null
         * @param o of type object
         * @return boolean
         */
        public override Boolean isPassedFilter(Object o) {
            AITM_Tender_Location__c tenderLocation = (AITM_Tender_Location__c) o;
            Boolean result = true;
            for (AITM_Tender_Location_Line_Item__c lineItem : tenderLocation.AITM_Tender_Location__r) {
                if (lineItem.AITM_Offered_Differential__c != null) {
                    result = false;
                    break;
                }
            }
            return result;
        }
    }

    /**
     * @description class to hold locations with status as awaiting price
     */
    public inherited sharing class AwaitingPriceLocations extends AITM_RelatedRecordsHolderController.FilterOption {
        public @AuraEnabled String name;
        public @AuraEnabled Boolean disabled;

        /**
         * @description overloaded contructor
         * @param name of type string
         * @param disabled of type boolean
         */
        public AwaitingPriceLocations(String name, Boolean disabled) {
            super(name, false);
            this.name = name;
            this.disabled = disabled;
        }

        /**
         * @description return false
         * @param null
         * @return boolean
         */
        public override Boolean isSelectiveFilter() {
            return false;
        }

        /**
         * @description return true if the status of the tender location is awaiting price
         * @param o of type object
         * @return boolean
         */
      public override Boolean isPassedFilter(Object o) {
            AITM_Tender_Location__c tenderLocation = (AITM_Tender_Location__c) o;
            Boolean result = false;

            if(tenderLocation.AITM_Status__c =='Awaiting price'){
                result = true;
            }
           
            return result;
        }
    }
    
    /**
     * @description class to hold locations with status as priced
     */

    public inherited sharing class PricedLocations extends AITM_RelatedRecordsHolderController.FilterOption {
        public @AuraEnabled String name;
        public @AuraEnabled Boolean disabled;

        /**
         * @description overloaded contructor
         * @param name of type string
         * @param disabled of type boolean
         */
        public PricedLocations(String name, Boolean disabled) {
            super(name, false);
            this.name = name;
            this.disabled = disabled;
        }

        /**
         * @description return false
         * @param null
         * @return boolean
         */
        public override Boolean isSelectiveFilter() {
            return false;
        }

        /**
         * @description return true if the tender location status os priced
         * @param o of type object
         * @return boolean
         */
      public override Boolean isPassedFilter(Object o) {
            AITM_Tender_Location__c tenderLocation = (AITM_Tender_Location__c) o;
            Boolean result = false;

            if(tenderLocation.AITM_Status__c == 'Priced'){
                result = true;
            }
           
            return result;
        }
    }



    /**
     * @description class to hold locations with specific volumes
     */
    public inherited sharing class LocationsWithSpecificVolumes extends AITM_RelatedRecordsHolderController.FilterOption {
        public @AuraEnabled String name;
        public @AuraEnabled Boolean disabled;

        /**
         * @description overloaded constructor
         * @param name of type string
         * @param disabled of type boolean
         */
        public LocationsWithSpecificVolumes(String name, Boolean disabled) {
            super(name, false);
            this.name = name;
            this.disabled = disabled;
        }

        /**
         * @description returns false
         * @param null
         * @return boolean
         */
        public override Boolean isSelectiveFilter() {
            return false;
        }

        /**
         * @description returns false if offeredvolume is equal to requested volume usg
         * @param o of type object
         * @return boolean
         */
        public override Boolean isPassedFilter(Object o) {
            AITM_Tender_Location__c tenderLocation = (AITM_Tender_Location__c) o;
            Boolean result = true;
            for (AITM_Tender_Location_Line_Item__c lineItem : tenderLocation.AITM_Tender_Location__r) {
               if(lineItem.AITM_Offered_Volume__c == 0 || lineItem.AITM_Offered_Volume__c == null) {
                    result = false;
                    break;
                }
            }
            return result;
        }
    }

    /**
     * @description class to hold adhoc location option
     */
    public inherited sharing class LocationAdHocOption extends AITM_RelatedRecordsHolderController.FilterOption {
        public @AuraEnabled String name;
        public @AuraEnabled Boolean disabled;

        /**
         * @description overloaded constructor
         * @param name of type string
         * @param disabled of type boolean
         */
        public LocationAdHocOption(String name, Boolean disabled) {
            super(name, false);
            this.name = name;
            this.disabled = disabled;
        }

        /**
         * @description gets criteria
         * @param null
         * @return List of type string
         */
        public override List<String> getCriteria() {
            return new List<String> {AITM_RelatedTenderLocationsHolderCntrl.AD_HOC_FIELD_API_NAME + ' = true'};
        }

        /**
         * @description returns true
         * @param null
         * @return boolean
         */
        public override Boolean isSelectiveFilter() {
            return true;
        }
    }

    /**
     * @description class to hold revised offer location details
     */
    public inherited sharing class LocationsRevisedOffer extends AITM_RelatedRecordsHolderController.FilterOption {
        public @AuraEnabled String name;
        public @AuraEnabled Boolean disabled;

        /**
         * @description overloaded constructor
         * @param name of type string
         * @param disabled of type boolean
         */
        public LocationsRevisedOffer(String name, Boolean disabled) {
            super(name, false);
            this.name = name;
            this.disabled = disabled;
        }

        /**
         * @description returns false 
         * @param null
         * @return boolean
         */
        public override Boolean isSelectiveFilter() {
            return false;
        }

        /**
         * @description class holds tenderlocation filter details which are represented
         * @param o of type object
         * @return boolean
         */
        public override Boolean isPassedFilter(Object o) {
            AITM_Tender_Location__c tenderLocation = (AITM_Tender_Location__c) o;
            Boolean result = false;

            if(tenderLocation.AITM_Include_In_Revised_Offer__c){
                result = true;
            }

            return result;
        }
    }

    /**
     * @description class holds tenderlocation filter details which are represented
     */
    public inherited sharing class RepresentedTenderLocations extends AITM_RelatedRecordsHolderController.FilterOption {
        public @AuraEnabled String name;
        public @AuraEnabled Boolean disabled;

        /**
         * @description overloaded constructor
         * @param name of type string
         * @param disabled of type boolean
         */
        public RepresentedTenderLocations(String name, Boolean disabled) {
            super(name, false);
            this.name = name;
            this.disabled = disabled;
        }

        /**
         * @description returns false 
         * @param null
         * @return boolean
         */
        public override Boolean isSelectiveFilter() {
            return false;
        }

        /**
         * @description returns true if tenderlocation status is not 'not represented'
         * @param o of type object
         * @return boolean
         */
        public override Boolean isPassedFilter(Object o) {
            AITM_Tender_Location__c tenderLocation = (AITM_Tender_Location__c) o;
            Boolean result = false;

            if(tenderLocation.AITM_Status__c != AITM_RelatedTenderLocationsHolderCntrl.STATUS_NOT_REPRESENTED){
                result = true;
            }

            return result;
        }
    }

    /**
     * @description class holds not represented tender location filter result details
     */
    public inherited sharing class NotRepresentedTenderLocations extends AITM_RelatedRecordsHolderController.FilterOption {
        public @AuraEnabled String name;
        public @AuraEnabled Boolean disabled;

        /**
         * @description overloaded constructor
         * @param name of type string
         * @param disabled of type boolean
         */
        public NotRepresentedTenderLocations(String name, Boolean disabled) {
            super(name, false);
            this.name = name;
            this.disabled = disabled;
        }

        /**
         * @description returns false selectivefilter
         * @param null
         * @return boolean
         */
        public override Boolean isSelectiveFilter() {
            return false;
        }

        /**
         * @description returns true if tenderlocation status is 'not represented'
         * @param o of type object
         * @return boolean
         */
        public override Boolean isPassedFilter(Object o) {
            AITM_Tender_Location__c tenderLocation = (AITM_Tender_Location__c) o;
            Boolean result = false;

            if(tenderLocation.AITM_Status__c == AITM_RelatedTenderLocationsHolderCntrl.STATUS_NOT_REPRESENTED){
                result = true;
            }

            return result;
        }
    }
    
    /**
     * @description returns Current User Details
     * @param null
     * @return User Info
    */
    @AuraEnabled 
    public static User fetchCurrentUserDetails(){
       return [SELECT ID, Name, AITM_SBC_Enhanced_Version__c FROM User WHERE ID =: userInfo.getUserId()];
    }
}