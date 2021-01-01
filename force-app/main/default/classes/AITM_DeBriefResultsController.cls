/***************************************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            IBM
 * @description      Controller class for AITM_DeBriefResults aura component 

 * history
 * 01/December/2017  George       Created
 * 10/June/2018      srnandan     Modified - AR-3165 Added auraenabled variables startDate and endDate
 *                                and added comments at method and class level as per coding standards
 * 11/June/2018      srnandan     Modified - AR-3192 Added auraenabled variables deliveryPoint 
 *                                and deliveryPointIdentifier
 * 06/July/2018      Shweta       Modified AR-3698 and AR-3591 In the wrapper class DeBriefResultsAdapter added one variable public @AuraEnabled String requestvolumeUOM
                                                               In the overloaded construtor added this.requestvolumeUOM = originalRecord.AITM_Requested_Volume_UoM__c;
 * 31/July/2018      Shweta       Modified DeBriefResultsAdapter to round off the awarded value in the debrief results.                                                              
 * 03/December/2018  srnandan     Modified - AR-4726 Added condition to check internal code and assign interncal code if present to iata for display                                                               
 * 04/December/2018  srnandan     Modified - AR-4630 Added methods and classes for default tenderlocationlineitem to retain tender result value from debrief
 * 04/December/2018  srnandan     Modified - AR-4500 Modified method toTenderLocationLineItem to populate WinningDifferential value based on pricingBasis type
 * 04/December/2018  Anusha       Modified - AR-4637 Modified method to get current value if pricing basis is type C
 * 06/December/2018  srnandan     Modified - AR-4630 Removed methods and classes for default tender location line item
 * 11/December/2018  srnandan     Modified - AR-4624 modified the assignment deliverypoint to AITM_Delivery_Point_External_Name__c
 * 04/January/2019   srnandan     Modified - getBaseLocations to filter based on user login
 * 14/Februray/2019  Shweta       Modified - AR-4841 Updated the code to for the calaculation of the awarded value for BG,BR and LB results 
 * 28/March/2019     Ravi         Modified - AR-5114 Updated the DeBriefResultsAdapter to populate Internal Code from Delivery Point
 * 30/July/2019      srnandan     Modified - Code refactored to remove unnecessary variables country and customerid, filter criteria for profiles moved to locationsdao
 ****************************************************************************************************/
public with sharing class AITM_DeBriefResultsController {

    public final static Set<String> AWARDED_VOLUME_TENDER_RESULTS = new Set<String>{
        'BG',
        'BR',
        'LB'
    };
    
    private final static Set<String> DEBRIEF_STAGES = new Set<String>{
        'DEBRIEF',
        'CLOSED'
    };

    private final static Set<String> TENDER_RESULTS_OPTIONS = new Set<String>{
        '--',
        'BG',
        'BR',
        'LB',
        'MI',
        'MIX'
    };

    private static final ID ID_TLLI_RECORD_TYPE_DEBRIEF = Schema.SObjectType.AITM_Tender_Location_Line_Item__c.getRecordTypeInfosByName().get('De-brief').getRecordTypeId();
    private static final String CURRENT_USER_PROFILE = new AITM_UsersDao().getProfileName(UserInfo.getUserId());
    private static final Boolean ISADMIN = AITM_BaseUtils.checkRunningUserIsSystemAdministrator();

    /**
     * @description returns DeBriefResultsAdapter wrapper class for given tender and filter criteria
     * @param tenderId of type Id
     * @param filter of type string
     * @return List<DeBriefResultsAdapter>
     */
    public static @AuraEnabled List<DeBriefResultsAdapter> loadDeBriefDetails(Id tenderId, String filter) {
        List<DeBriefResultsAdapter> deBriefResults = new List<DeBriefResultsAdapter>();
        if (filter == null) {
            deBriefResults = getBaseTenderLocations(tenderId);
        } else {
            AITM_RelatedRecordsHolderController.FilterOption parsedFilter = parseFilter(filter);
            if (parsedFilter.isSelectiveFilter()) {
                deBriefResults = getFilteredTenderLocations(tenderId, parsedFilter);
            } else {
                deBriefResults = getFilteredTenderLocations(tenderId, parsedFilter, true);
            }
        }
        return deBriefResults;
    }
    
    /**
     * @description inilializes Debrief results
     * @param tenderId of type Id
     * @return DeBriefResultsInitializationAdapter
     */
    public static @AuraEnabled DeBriefResultsInitializationAdapter initializeDeBriefResults(Id tenderId) {
        return new DeBriefResultsInitializationAdapter(loadDeBriefDetails(tenderId, null), loadDeBriefEditable(tenderId), loadDeBriefResultsOption());
    }
    
    /**
     * @description saves the debriefResults
     * @param deBriefResults of type String
     * @return String
     */
    public static @AuraEnabled String save(String deBriefResults) {
        List<DeBriefResultsAdapter> results = (List<DeBriefResultsAdapter>) JSON.deserialize(deBriefResults, List<DeBriefResultsAdapter>.class);
        List<AITM_Tender_Location_Line_Item__c> lineItemsToUpdate = new List<AITM_Tender_Location_Line_Item__c>();
        for (DeBriefResultsAdapter result : results) {
            lineItemsToUpdate.add(result.toTenderLocationLineItem());
        }
        String errorMessage = '';
        try {
            Database.update(lineItemsToUpdate);
        } catch (DmlException dmlError) {
            errorMessage = dmlError.getMessage();
        }

        return errorMessage;
    }
    
    /**
     * @description saves the debriefResults with multiple tllis
     * @param deBriefResults of type String
     * @return String
     */
    public static @AuraEnabled String saveWithMultiple(String deBriefResults, String resultToUpdate) {
        List<DeBriefResultsAdapter> results = (List<DeBriefResultsAdapter>) JSON.deserialize(deBriefResults, List<DeBriefResultsAdapter>.class);
        List<AITM_Tender_Location_Line_Item__c> lineItemsToUpdate = new List<AITM_Tender_Location_Line_Item__c>();
        for (DeBriefResultsAdapter result : results) {
            lineItemsToUpdate.add(result.toTenderLocationLineItemWithMultipleUpdate(resultToUpdate));
        }
        String errorMessage = '';
        try {
            Database.update(lineItemsToUpdate);
        } catch (DmlException dmlError) {
            errorMessage = dmlError.getMessage();
        }

        return errorMessage;
    }
    
    /**
     * @description returns true if DEBRIEF_STAGES contains for a given tender
     * @param tenderId of type Id
     * @return Boolean
     */
    private static Boolean loadDeBriefEditable(Id tenderId) {
        AITM_Tender__c tenderFromScope = new AITM_TenderDao().getTender(tenderId);
        return DEBRIEF_STAGES.contains(tenderFromScope.AITM_Stage__c.toUpperCase());
    }

    /**
     * @description returns DeBriefResultsOption
     * @param null
     * @return List<String>
     */
    private static List<String> loadDeBriefResultsOption() {
        return new List<String>(TENDER_RESULTS_OPTIONS);
    }

    /**
     * @description parses FilterOption from the JSON String
     * @param filterJSON of type String
     * @return AITM_RelatedRecordsHolderController.FilterOption
     */
    private static AITM_RelatedRecordsHolderController.FilterOption parseFilter(String filterJSON) {
        if (filterJSON.contains('locationManagerId')) {
            return (AITM_RelatedTenderLocationsHolderCntrl.LocationManagerFilterOption) JSON.deserialize(filterJSON, AITM_RelatedTenderLocationsHolderCntrl.LocationManagerFilterOption.class);
        } else if (filterJSON.contains('Locations With Volume Mismatch')) {
            return (AITM_DeBriefHolderController.LocationsVolumeMismatchOption) JSON.deserialize(filterJSON, AITM_DeBriefHolderController.LocationsVolumeMismatchOption.class);
        } else if (filterJSON.contains('Locations with Quotes')) {
            return (AITM_DeBriefHolderController.LocationsWithQuotesOption) JSON.deserialize(filterJSON, AITM_DeBriefHolderController.LocationsWithQuotesOption.class);
        } else if (filterJSON.contains('Locations without Quotes')) {
            return (AITM_DeBriefHolderController.LocationsWithoutQuotesOption) JSON.deserialize(filterJSON, AITM_DeBriefHolderController.LocationsWithoutQuotesOption.class);
        } else if (filterJSON.contains('Locations with specific volumes')) {
            return (AITM_DeBriefHolderController.LocationsWithSpecificVolumes) JSON.deserialize(filterJSON, AITM_DeBriefHolderController.LocationsWithSpecificVolumes.class);
        } else if (filterJSON.contains('Locations with AdHoc Volume')) {
            return (AITM_DeBriefHolderController.LocationAdHocOption) JSON.deserialize(filterJSON, AITM_DeBriefHolderController.LocationAdHocOption.class);
        } else if (filterJSON.contains('Business Gained')) {
            return (AITM_DeBriefHolderController.BusinessGainedLocationsFilterOption) JSON.deserialize(filterJSON, AITM_DeBriefHolderController.BusinessGainedLocationsFilterOption.class);
        } else if (filterJSON.contains('Business Retained')) {
            return (AITM_DeBriefHolderController.BusinessRetainedLocationsFilterOption) JSON.deserialize(filterJSON, AITM_DeBriefHolderController.BusinessRetainedLocationsFilterOption.class);
        } else if (filterJSON.contains('Business Lost')) {
            return (AITM_DeBriefHolderController.BusinessLostLocationsFilterOption) JSON.deserialize(filterJSON, AITM_DeBriefHolderController.BusinessLostLocationsFilterOption.class);
        } else if (filterJSON.contains('Market Info')) {
            return (AITM_DeBriefHolderController.MarketInfoLocationsFilterOption) JSON.deserialize(filterJSON, AITM_DeBriefHolderController.MarketInfoLocationsFilterOption.class);
        }
        return (AITM_RelatedRecordsHolderController.FilterOption) JSON.deserialize(filterJSON, AITM_RelatedRecordsHolderController.FilterOption.class);
    }

    /**
     * @description gets base tender locations for a given tender
     * @param tenderId of type Id
     * @return List<DeBriefResultsAdapter>
     */
    private static List<DeBriefResultsAdapter> getBaseTenderLocations(Id tenderId) {
        List<DeBriefResultsAdapter> deBriefResults = new List<DeBriefResultsAdapter>();
        for(AITM_Tender_Location_Line_Item__c tenderLocation : new AITM_LocationsDao().getTenderLocationLineItemsForDebriefResults(tenderId, null, ID_TLLI_RECORD_TYPE_DEBRIEF, CURRENT_USER_PROFILE)) {
            deBriefResults.add(new DeBriefResultsAdapter(tenderLocation));
        }
        return deBriefResults;
    }
    
    /**
     * @description gets filtered tender locations for a given tender and filter options
     * @param tenderId of type Id
     * @param parsedFilter of type AITM_RelatedRecordsHolderController.FilterOption
     * @return List<DeBriefResultsAdapter>
     */
    @TestVisible
    private static List<DeBriefResultsAdapter> getFilteredTenderLocations(Id tenderId, AITM_RelatedRecordsHolderController.FilterOption parsedFilter) {
        List<DeBriefResultsAdapter> deBriefResults = new List<DeBriefResultsAdapter>();
        for(AITM_Tender_Location_Line_Item__c tenderLocation : new AITM_LocationsDao().getTenderLocationLineItemsForDebriefResults(tenderId, parsedFilter.getCriteria(), ID_TLLI_RECORD_TYPE_DEBRIEF, CURRENT_USER_PROFILE)) {
            deBriefResults.add(new DeBriefResultsAdapter(tenderLocation));
        }
        return deBriefResults;
    }

    /**
     * @description gets filtered tender locations for a given tender and filter options
     * @param tenderId of type Id
     * @param parsedFilter of type AITM_RelatedRecordsHolderController.FilterOption
     * @param selectivityFlag of type Boolean
     * @return List<DeBriefResultsAdapter>
     */
    @TestVisible
    private static List<DeBriefResultsAdapter> getFilteredTenderLocations(Id tenderId, AITM_RelatedRecordsHolderController.FilterOption parsedFilter, Boolean selectivityFlag) {
        List<DeBriefResultsAdapter> deBriefResults = new List<DeBriefResultsAdapter>();
        for(AITM_Tender_Location_Line_Item__c tenderLocation : new AITM_LocationsDao().getTenderLocationLineItemsForDebriefResults(tenderId, null, ID_TLLI_RECORD_TYPE_DEBRIEF, CURRENT_USER_PROFILE)) {
            if (parsedFilter.isPassedFilter(tenderLocation)) {
                deBriefResults.add(new DeBriefResultsAdapter(tenderLocation));
            }
        }
        return deBriefResults;
    }

    /**
     * @description Wrapper class for DeBriefResultsInitializationAdapter
     */
    public class DeBriefResultsInitializationAdapter {
        public @AuraEnabled List<DeBriefResultsAdapter> results;
        public @AuraEnabled Boolean editable;
        public @AuraEnabled List<String> options;

        /**
         * @description overloaded constructor
         * @param results of type List<DeBriefResultsAdapter>
         * @param editable of type Boolean
         * @param options of type List<String>
         */
        public DeBriefResultsInitializationAdapter(List<DeBriefResultsAdapter> results, Boolean editable, List<String> options) {
            this.results = results;
            this.editable = editable;
            this.options = options;
        }
    }
    
    /**
     * @description Wrapper class for DeBriefResultsAdapter
     */
    public class DeBriefResultsAdapter {
        public @AuraEnabled String recordId;
        public @AuraEnabled String recordOldId;
        public @AuraEnabled String GRN;
        public @AuraEnabled String customer;
        public @AuraEnabled String locationIdentificator;
        public @AuraEnabled String locationName;
        public @AuraEnabled String locationId;
        public @AuraEnabled Decimal awardedVolume;
        public @AuraEnabled Decimal differential;
        public @AuraEnabled Decimal currentValue;
        public @AuraEnabled String pricingBasis;
        public @AuraEnabled String pricingBasisType;
        public @AuraEnabled String locationCurrency;
        public @AuraEnabled String measure;
        public @AuraEnabled String lastTenderResult;
        public @AuraEnabled String result;
        public @AuraEnabled Decimal offeredVolume;
        public @AuraEnabled Date startDate;
        public @AuraEnabled Date endDate;
        public @AuraEnabled String deliveryPoint;
        public @AuraEnabled String deliveryPointIdentifier;
        public @AuraEnabled String requestvolumeUOM;
        public @AuraEnabled Boolean isSelected;
        
        /**
         * @description overloaded constructor
         * @param originalRecord of type AITM_Tender_Location_Line_Item__c
         */
        public DeBriefResultsAdapter(AITM_Tender_Location_Line_Item__c originalRecord) {
            this.recordId = originalRecord.Id;
            this.recordOldId = originalRecord.AITM_Previous_TLLI_Id__c;
            this.GRN = originalRecord.AITM_Account__r.AITM_GRN__c;
            this.customer = originalRecord.AITM_Account__r.Name;
            this.locationIdentificator = (originalRecord.AITM_Location__r.AITM_Internal_code__c != null ? originalRecord.AITM_Location__r.AITM_Internal_code__c : originalRecord.AITM_Location__r.AITM_IATA_ICAO__c);
            this.locationName = originalRecord.AITM_Location__r.Name;
            this.locationId = originalRecord.AITM_Location__c;
            if( originalRecord.AITM_Tender_Result__c == 'BG' || originalRecord.AITM_Tender_Result__c =='BR'){
                this.awardedVolume = originalRecord.AITM_Awarded_Volume__c; 
            }else{
                this.awardedVolume = 0;
            }                     
            if(originalRecord.AITM_Pricing_Basis__r.AITM_Type__c == 'C' && originalRecord.AITM_Current_Value__c != null) {
                this.differential = originalRecord.AITM_Current_Value__c;
            }
            else{
                 this.differential = originalRecord.AITM_Offered_Differential__c;  
            }
            this.currentValue = originalRecord.AITM_Current_Value__c;
            this.pricingBasis = originalRecord.AITM_Pricing_Basis__r.Name;
            this.pricingBasisType = originalRecord.AITM_Pricing_Basis__r.AITM_Type__c;
            this.locationCurrency = originalRecord.AITM_Currency__c;
            this.measure = originalRecord.AITM_Unit_Of_Measure__c;
            this.lastTenderResult = (originalRecord.AITM_History_Line_Item__r != null ? '' : originalRecord.AITM_History_Line_Item__r.AITM_Last_Tender_Result__c);
            this.result = originalRecord.AITM_Tender_Result__c;
            if(originalRecord.AITM_Offered_Volume__c != null){
                this.offeredVolume = (originalRecord.AITM_Offered_Volume__c).round(system.roundingMode.HALF_UP);
            }else{
                this.offeredVolume = 0;
            }
            this.startDate = originalRecord.AITM_Start_Date__c;
            this.endDate = originalRecord.AITM_End_Date__c;
            this.deliveryPoint = originalRecord.AITM_Location_Delivery_Point__r.AITM_Delivery_Point_External_Name__c;
            this.deliveryPointIdentifier = originalRecord.AITM_Location_Delivery_Point__c;
            this.requestvolumeUOM = originalRecord.AITM_Requested_Volume_UoM__c;
            this.isSelected = false;
        }

        /**
         * @description return TenderLocationLineItem record
         * @param null
         * @return AITM_Tender_Location_Line_Item__c
         */
        public AITM_Tender_Location_Line_Item__c toTenderLocationLineItem() {
            return new AITM_Tender_Location_Line_Item__c(
                Id = this.recordId,
                AITM_Tender_Result__c = (this.result != '--') ? this.result : null,
                AITM_Awarded_Volume__c = AITM_DeBriefResultsController.AWARDED_VOLUME_TENDER_RESULTS.contains(this.result) ? this.offeredVolume : 0,
                AITM_Winning_Differential__c =  (AITM_DeBriefResultsController.AWARDED_VOLUME_TENDER_RESULTS.contains(this.result) && this.pricingBasisType == 'D') ? this.differential : this.currentValue
            );
        }
        
        /**
         * @description return TenderLocationLineItem record
         * @param null
         * @return AITM_Tender_Location_Line_Item__c
         */
        public AITM_Tender_Location_Line_Item__c toTenderLocationLineItemWithMultipleUpdate(String resultToUpdate) {
            return new AITM_Tender_Location_Line_Item__c(
                Id = this.recordId,
                AITM_Tender_Result__c = (resultToUpdate != '--') ? resultToUpdate : null,
                AITM_Awarded_Volume__c = AITM_DeBriefResultsController.AWARDED_VOLUME_TENDER_RESULTS.contains(resultToUpdate) ? this.offeredVolume : 0,
                AITM_Winning_Differential__c =  (AITM_DeBriefResultsController.AWARDED_VOLUME_TENDER_RESULTS.contains(resultToUpdate) && this.pricingBasisType == 'D') ? this.differential : this.currentValue
            );
        }
    }
}