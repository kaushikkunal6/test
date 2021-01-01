/***********************************************************************************************
 * @author           srnandan
 * @date             20/March/2018
 * @group            AirBP
 * @description      controller being called from aura component "RelatedTenderLocationLineItems" 
 *                   holds TenderLocation item details for a given country              

 * history
 * 20/March/2018     srnandan  Created AR-2726
 * 27/June/2018      srnandan  Modified AR-3527 Status of lineitem mapped to lineStatus instead of status
 * 23/December/2018  srnandan  Modified AR-4842 Modified methods TenderLocationItemAdapter
 * 21/January/2019   saravan   Modified AR-4911 Added new method getDefaultDelPoint and Modified 
 *                             getPricingResponsibilityId and getPricingResponsibilityName
 * 18/March/2019     saravan   Modified AR-5080 Modified method getLocationItemDetailsForCountry and Modified 
 *                              getCountryDetailTenderLocationItems method
 ****************************************************************************************/
public with sharing class AITM_CountryByTenderLocationItemCtrl {
    
    public final static String OBJECT_NAME = 'AITM_Tender_Location_Line_Item__c';
    public final static String CURRENCY_FIELD_NAME = 'AITM_Currency__c';
    public final static String UOM_FIELD_NAME = 'AITM_Unit_Of_Measure__c';
    public final static String STATUS_FIELD_NAME = 'AITM_Status__c';
    private static final String AIR_TM_LOCATION_MANAGER_PROFILE = 'Air_TMLocation Manager';  
    private static final Set<String> AIR_TM_LABP_LOCATION_MANAGER_PROFILE = new Set<String>{'Air_TMLABPLM','Air_TMLABPLoginLM'};
    
    /**
     * @description returns list collection of TenderLocationSummaryAdapter based on tenderId and filter condition
     * @param tenderId of type Id
     * @param countryName of type string
     * @param filter of type string
     * @return List collection of TenderLocationSummaryAdapter
     */
    public static @AuraEnabled List<TenderLocationItemAdapter> getLocationItemDetailsForCountry(Id tenderId, String countryName, String filter, Integer roundNumber) {
        List<TenderLocationItemAdapter> locationItems = new List<TenderLocationItemAdapter>();
        if (filter == null) {
            String profileName = new AITM_UsersDao().getProfileName(UserInfo.getUserId());
            if(profileName == AIR_TM_LOCATION_MANAGER_PROFILE || AIR_TM_LABP_LOCATION_MANAGER_PROFILE.contains(profileName)) {
               locationItems = getCountryDetailTenderLocationItems(tenderId, countryName, roundNumber, UserInfo.getUserId());
            } else {
                locationItems = getCountryDetailTenderLocationItems(tenderId, countryName, roundNumber, null);
            }
        } else {
            //todo need to discuss on filter logic
        }
        return locationItems;
    }

    /**
     * @description CountryDetails Results initialization adapter for the component
     * @param tenderId of type Id
     * @param countryName of type string
     * @return CountryDetailResultsInitializationAdapter class
     */
    public static @AuraEnabled(cacheable=true) CountryDetailResultsInitializationAdapter initializeCountryDetailResults(Id tenderId, String countryName, Integer roundNumber) {
        return new CountryDetailResultsInitializationAdapter(getLocationItemDetailsForCountry(tenderId, countryName, null, roundNumber), loadCurrencyResultsOption(), loadUomResultsOption(), loadStatusResultsOption());
    }

    /**
     * @description saves the lineitem results to database
     * @param countryDetailLineItemResults of type string
     * @return string the error message if update operation fails
     */
    public static @AuraEnabled String save(String countryDetailLineItemResults) {
        List<TenderLocationItemAdapter> results = (List<TenderLocationItemAdapter>) JSON.deserialize(countryDetailLineItemResults, List<TenderLocationItemAdapter>.class);
        List<AITM_Tender_Location_Line_Item__c> lineItemsToUpdate = new List<AITM_Tender_Location_Line_Item__c>();
        List<AITM_Tender_Location__c> locationStatusToUpdate = new List<AITM_Tender_Location__c>();
        Map<Id, AITM_Tender_Location__c> mapTenderLocation = new Map<Id, AITM_Tender_Location__c>();
        Set<Id> tenderLocationIds = new Set<Id>();
        for (TenderLocationItemAdapter result : results) {
            lineItemsToUpdate.add(result.toTenderLocationLineItem());
            if(!mapTenderLocation.containsKey(result.tenderLocationId)) {
                tenderLocationIds.add(result.tenderLocationId);    
                AITM_Tender_Location__c tenderLocation = new AITM_Tender_Location__c(Id = result.tenderLocationId, AITM_Status__c = result.lineStatus, AITM_Include_In_Revised_Offer__c = result.includeRevisedOffer);
                mapTenderLocation.put(result.tenderLocationId, tenderLocation);
            } else {
                if(result.lineStatus == 'Awaiting price') {
                    AITM_Tender_Location__c tenderLocation = mapTenderLocation.get(result.tenderLocationId);
                    tenderLocation.AITM_Status__c = 'Awaiting price';
                    mapTenderLocation.put(result.tenderLocationId, tenderLocation);
                }
            }
                                    
        }
        
        locationStatusToUpdate.addAll(mapTenderLocation.values());

        String errorMessage = '';
        try {
            Database.update(lineItemsToUpdate);
            Database.update(locationStatusToUpdate);
        } catch (DmlException dmlError) {
            for (Integer i = 0; i < dmlError.getNumDml(); i++) {
                errorMessage = 'Update failed :' + dmlError.getDmlMessage(i);
            }
        }

        return errorMessage;
    }

    /**
     * @description loads currency picklist value options
     * @param null
     * @return List collection of string
     */
    private static List<String> loadCurrencyResultsOption() {
        return getPickValues(OBJECT_NAME,CURRENCY_FIELD_NAME);
    }

    /**
     * @description loads unit of measure picklist value options
     * @param null
     * @return List collection of string
     */
    private static List<String> loadUomResultsOption() {
        return getPickValues(OBJECT_NAME,UOM_FIELD_NAME);
    }

    /**
     * @description loads status picklist value options
     * @param null
     * @return List collection of string
     */
    private static List<String> loadStatusResultsOption() {
        return getPickValues(OBJECT_NAME,STATUS_FIELD_NAME);
    }

    /**
     * @description returns list collection of picklist values for field of sobject
     * @param objectName of type string
     * @param fieldName of type string
     * @return List collection of string
     */
    @TestVisible
    private static List<String> getPickValues(String objectName, String fieldName){ 
        List<SelectOption> selectOptions = AITM_BaseUtils.getPickValues(objectName, fieldName, NULL);
        List<String> stringValues = new List<String>();
        for(SelectOption so : selectOptions){
            stringValues.add(so.getValue());
        }
        return stringValues;
    }

    /**
     * @description gets tender locations item details for a given tender and country
     * @param tenderId of type Id
     * @param countryName of type string
     * @param userId of type Id
     * @return List collection of TenderLocationSummaryAdapter
     */
    private static List<TenderLocationItemAdapter> getCountryDetailTenderLocationItems(Id tenderId, String countryName, Integer roundNumber, Id userId) {
        List<TenderLocationItemAdapter> locationItems = new List<TenderLocationItemAdapter>();
        for(AITM_Tender_Location_Line_Item__c tenderLocationItem : new AITM_LocationsDao().getTenderLocationsWithLineItemsDetailsByCountry(tenderId, countryName, roundNumber, userId)) {
            locationItems.add(new TenderLocationItemAdapter(tenderLocationItem));
        }
        return locationItems;
    }
    
    /**
     * @description class holds the results of controls to be shown for the component
     */    
    public class CountryDetailResultsInitializationAdapter {
        public @AuraEnabled List<TenderLocationItemAdapter> results;
        public @AuraEnabled List<String> optionsCurrency;
        public @AuraEnabled List<String> optionsUom;
        public @AuraEnabled List<String> optionsStatus;

        /**
         * @description overloaded constructor
         * @param results list collection of TenderLocationItemAdapter
         * @param optionsCurrency list collection of string
         * @param optionsUom list collection of string
         */    
        public CountryDetailResultsInitializationAdapter(List<TenderLocationItemAdapter> results, List<String> optionsCurrency, List<String> optionsUom, List<String> optionsStatus) {
            this.results = results;
            this.optionsCurrency = optionsCurrency;
            this.optionsUom = optionsUom;
            this.optionsStatus = optionsStatus;
        }
    }

    /**
     * @description adapter class for tenderlocationitem by country
     */
    public class TenderLocationItemAdapter {
        public @AuraEnabled String recordId;
        public @AuraEnabled String locationIdentificator;
        public @AuraEnabled String locationName;
        public @AuraEnabled String locationId;
        public @AuraEnabled String tenderLocationId;
        public @AuraEnabled String customer;
        public @AuraEnabled String customerId;
        public @AuraEnabled String locationManager;
        public @AuraEnabled String locationManagerId;        
        public @AuraEnabled String deliveryPointId;
        public @AuraEnabled String deliveryPointName;
        public @AuraEnabled Decimal volumeUSG;
        public @AuraEnabled Decimal offeredVolumeUSG;
        public @AuraEnabled String pricingBasis;
        public @AuraEnabled String pricingBasisId;
        public @AuraEnabled String lastTenderResult;
        public @AuraEnabled Decimal currentDiff;
        public @AuraEnabled String currentUom;
        public @AuraEnabled String currentCurr;
        public @AuraEnabled String uom;
        public @AuraEnabled String curr;
        public @AuraEnabled Decimal previousRoundDiff;
        public @AuraEnabled Decimal newDiff;
        public @AuraEnabled String status;
        public @AuraEnabled String lineStatus;
        public @AuraEnabled Decimal round;
        public @AuraEnabled Decimal currentRound;
        public @AuraEnabled Boolean includeRevisedOffer;
        public @AuraEnabled String country;
        public @AuraEnabled AITM_Tender_Location_Line_Item__c tlli;

        /**
         * @description overloaded constructor assigns values to variables
         * @param originalRecord of AITM_Tender_Location_Line_Item__c
         */
        public TenderLocationItemAdapter(AITM_Tender_Location_Line_Item__c originalRecord) {
            this.recordId = originalRecord.Id;
            this.locationIdentificator = originalRecord.AITM_Tender_Location__r.AITM_IATA_ICAO__c;
            this.locationId = originalRecord.AITM_Location__c;
            this.tenderLocationId = originalRecord.AITM_Tender_Location__c;
            this.locationName = originalRecord.AITM_Location__r.Name;
            this.customerId = originalRecord.AITM_Account__c;
            this.customer = originalRecord.AITM_Account__r.Name;
            this.deliveryPointId = originalRecord.AITM_Location_Delivery_Point__c;
            this.deliveryPointName = getDefaultDelPoint(originalRecord);
            this.locationManagerId = getPricingResponsibilityId(originalRecord);
            this.locationManager = getPricingResponsibilityName(originalRecord);
            this.lineStatus = originalRecord.AITM_Status__c;
            this.status = originalRecord.AITM_Tender_Location__r.AITM_Status__c;
            this.includeRevisedOffer = originalRecord.AITM_Tender_Location__r.AITM_Include_In_Revised_Offer__c;
            this.volumeUSG = (originalRecord.AITM_Requested_Volume_USG__c!=null?(originalRecord.AITM_Requested_Volume_USG__c).round(System.RoundingMode.HALF_UP):null);
            this.offeredVolumeUSG = (originalRecord.AITM_Offered_Volume__c!=null?(originalRecord.AITM_Offered_Volume__c).round(System.RoundingMode.HALF_UP):null);
            this.pricingBasisId = originalRecord.AITM_Pricing_Basis__c;
            this.pricingBasis = originalRecord.AITM_Pricing_Basis__r.Name;
            this.currentDiff = originalRecord.AITM_History_Line_Item__r.AITM_Offered_Differential__c;
            this.currentUom = originalRecord.AITM_History_Line_Item__r.AITM_Unit_Of_Measure__c;
            this.currentCurr = originalRecord.AITM_History_Line_Item__r.AITM_Currency__c;
            this.uom = originalRecord.AITM_Unit_Of_Measure__c;
            this.curr = originalRecord.AITM_Currency__c;
            this.previousRoundDiff = originalRecord.AITM_Previous_Round_Differential__c;
            this.newDiff = originalRecord.AITM_Offered_Differential__c;
            this.round = originalRecord.AITM_Round__c;
            this.currentRound = originalRecord.AITM_Current_Round__c;
            this.country = originalRecord.AITM_Location__r.AITM_Country__c;
            this.tlli = originalRecord;
        }

        /**
         * @description gets Pricing Responsibility Id
         * @param originalRecord of AITM_Tender_Location_Line_Item__c
         * @return Id
         */
        public Id getPricingResponsibilityId(AITM_Tender_Location_Line_Item__c originalRecord) {
            Id responsibilityId;
            if(originalRecord.AITM_Tender__r.AITM_Tender_Sector__c == 'CA' && (originalRecord.AITM_Location_Delivery_Point__r.AITM_Default_Delivery_Point__c == originalRecord.AITM_Tender__r.AITM_Tender_Sector__c || originalRecord.AITM_Location_Delivery_Point__r.AITM_Default_Delivery_Point__c == 'BOTH')) {
                responsibilityId = (originalRecord.AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__c != null ? originalRecord.AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__c : originalRecord.AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c != null ? originalRecord.AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c : null);
            } else if(originalRecord.AITM_Tender__r.AITM_Tender_Sector__c == 'GA' && (originalRecord.AITM_Location_Delivery_Point__r.AITM_Default_Delivery_Point__c == originalRecord.AITM_Tender__r.AITM_Tender_Sector__c || originalRecord.AITM_Location_Delivery_Point__r.AITM_Default_Delivery_Point__c == 'BOTH')) {
                responsibilityId = (originalRecord.AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__c != null ? originalRecord.AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__c : originalRecord.AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c != null ? originalRecord.AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c : null);
            } else{
                responsibilityId = originalRecord.AITM_Pricer_No_Default_Delivery_Points__c;
            }
            return responsibilityId;
        }

        /**
         * @description gets Pricing Responsibility Name
         * @param originalRecord of AITM_Tender_Location_Line_Item__c
         * @return String
         */
        public String getPricingResponsibilityName(AITM_Tender_Location_Line_Item__c originalRecord) {
            String responsibilityName;
            if(originalRecord.AITM_Tender__r.AITM_Tender_Sector__c == 'CA' && (originalRecord.AITM_Location_Delivery_Point__r.AITM_Default_Delivery_Point__c == originalRecord.AITM_Tender__r.AITM_Tender_Sector__c || originalRecord.AITM_Location_Delivery_Point__r.AITM_Default_Delivery_Point__c == 'BOTH')) {
                responsibilityName = (originalRecord.AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__c != null ? originalRecord.AITM_Location_Delivery_Point__r.AITM_CA_Pricing_Responsibility1__r.Name : originalRecord.AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c != null ? originalRecord.AITM_Location_Delivery_Point__r.AITM_Location_Manager1__r.Name : null);
            } else if(originalRecord.AITM_Tender__r.AITM_Tender_Sector__c == 'GA' && (originalRecord.AITM_Location_Delivery_Point__r.AITM_Default_Delivery_Point__c == originalRecord.AITM_Tender__r.AITM_Tender_Sector__c || originalRecord.AITM_Location_Delivery_Point__r.AITM_Default_Delivery_Point__c == 'BOTH')) {
                responsibilityName = (originalRecord.AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__c != null ? originalRecord.AITM_Location_Delivery_Point__r.AITM_GA_Pricing_Responsibility1__r.Name : originalRecord.AITM_Location_Delivery_Point__r.AITM_Location_Manager1__c != null ? originalRecord.AITM_Location_Delivery_Point__r.AITM_Location_Manager1__r.Name : null);
            } else{
                responsibilityName = originalRecord.AITM_Pricer_No_Default_Delivery_Points__r.Name;
            }
            return responsibilityName;
        }
        
        /**
         * @description gets DefaultDelPoint Name
         * @param originalRecord of AITM_Tender_Location_Line_Item__c
         * @return String
         */
        public String getDefaultDelPoint(AITM_Tender_Location_Line_Item__c originalRecord) {
            String defaultDelPoint;
            
            if (originalRecord.AITM_Delivery_Point_Info__c != 'Select') {
                defaultDelPoint = originalRecord.AITM_Delivery_Point_Info__c;
            } else {
                defaultDelPoint = 'None';
            }
            return defaultDelPoint;
            
        }

        /**
         * @description overloaded constructor assigns values to variables
         * @param originalRecord of AITM_Tender_Location_Line_Item__c
         * @return AITM_Tender_Location_Line_Item__c
         */
        public AITM_Tender_Location_Line_Item__c toTenderLocationLineItem() {
            return new AITM_Tender_Location_Line_Item__c(
                Id = this.recordId,
                AITM_Unit_Of_Measure__c = (this.uom != '--') ? this.uom : null,
                AITM_Currency__c = (this.curr != '--') ? this.curr : null,
                AITM_Offered_Differential__c = (this.newDiff != null) ? this.newDiff : null,
                AITM_Status__c = (this.lineStatus != '--') ? this.lineStatus : 'Awaiting price'
            );
        }
    }
    
    /**
     * @description class holds the results of controls to be shown for the component
     */    
    public class CountrySummaryDetailResultsInitializationAdapter {
        public @AuraEnabled Map<String, List<TenderLocationItemAdapter>> results;
        public @AuraEnabled List<String> optionsCurrency;
        public @AuraEnabled List<String> optionsUom;
        public @AuraEnabled List<String> optionsStatus;

        /**
         * @description overloaded constructor
         * @param results list collection of TenderLocationItemAdapter
         * @param optionsCurrency list collection of string
         * @param optionsUom list collection of string
         */    
        public CountrySummaryDetailResultsInitializationAdapter(Map<String, List<TenderLocationItemAdapter>> results, List<String> optionsCurrency, List<String> optionsUom, List<String> optionsStatus) {
            this.results = results;
            this.optionsCurrency = optionsCurrency;
            this.optionsUom = optionsUom;
            this.optionsStatus = optionsStatus;
        }
    }
    
     /**
     * @description CountryDetails Results initialization adapter for the component
     * @param tenderId of type Id
     * @param countryName of type string
     * @return CountryDetailResultsInitializationAdapter class
     */
    public static @AuraEnabled(cacheable=true) CountrySummaryDetailResultsInitializationAdapter initializeSummaryCountryDetailResults(Id tenderId, String countryName, Integer roundNumber) {
        List<TenderLocationItemAdapter> lines = getLocationItemDetailsForCountry(tenderId, countryName, null, roundNumber);
        return new CountrySummaryDetailResultsInitializationAdapter(getTLWithLinesBasedOnCountry(lines), loadCurrencyResultsOption(), loadUomResultsOption(), loadStatusResultsOption());
    }
    
    /**
     * @description adapter class for tenderlocation by country
     */
    public class TenderLocationAdapter {
        public @AuraEnabled String recordId;
        public @AuraEnabled String locationIdentificator;
        public @AuraEnabled String locationName;
        public @AuraEnabled String locationId;
        public @AuraEnabled String tenderLocationId;
        public @AuraEnabled String customer;
        public @AuraEnabled String customerId;
        public @AuraEnabled String status;
        public @AuraEnabled String country;
        public @AuraEnabled List<TenderLocationItemAdapter> tlliApapter;

        /**
         * @description overloaded constructor assigns values to variables
         * @param originalRecord of TenderLocationItemAdapter
         */
        public TenderLocationAdapter(TenderLocationItemAdapter originalRecord) {
            this.recordId = originalRecord.recordId;
            this.locationIdentificator = originalRecord.locationIdentificator;
            this.locationId = originalRecord.locationId;
            this.tenderLocationId = originalRecord.tenderLocationId;
            this.locationName = originalRecord.locationName;
            this.customerId = originalRecord.customerId;
            this.customer = originalRecord.customer;
            this.status = originalRecord.status;
            this.country = originalRecord.country;
            this.tlliApapter = new List<TenderLocationItemAdapter>();
        }
    }
    
    /**
     * @description returns Map<String,List<TenderLocationItemAdapter>> collection of getTLWithLinesBasedOnCountry based on locationItems
     * @param locationItems of type List<TenderLocationItemAdapter>
     * @return Map<String, List<TenderLocationItemAdapter>> collection
     */
    public static @AuraEnabled Map<String, List<TenderLocationItemAdapter>> getTLWithLinesBasedOnCountry(List<TenderLocationItemAdapter> locationItems) {
        Map<String, List<TenderLocationItemAdapter>> tenderLocationAdapter = new Map<String, List<TenderLocationItemAdapter>>();
        Set<String> uniqueLocationIdentifiers = new Set<String>();
        for(TenderLocationItemAdapter line: locationItems){
            if(!uniqueLocationIdentifiers.contains(line.locationIdentificator)){
                tenderLocationAdapter.put(line.locationIdentificator, new List<TenderLocationItemAdapter>());
                uniqueLocationIdentifiers.add(line.locationIdentificator);
            }
            tenderLocationAdapter.get(line.locationIdentificator).add(line);
        }
        return tenderLocationAdapter;
    }
}