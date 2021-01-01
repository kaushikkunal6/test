/***********************************************************************************************
 * @author           srnandan
 * @date             20/March/2018
 * @group            AirBP
 * @description      controller being called from aura component "RelatedTenderLocationsByCountry" 
 *                   holds TenderLocation details countrywise              

 * history
 * 20/March/2018  srnandan  Created AR-2726
 * 20/April/2018  srnandan  added constant AIR_TM_LOCATION_MANAGER_PROFILE and 
 *                          conditional call to getCountrySummaryTenderLocations based on lm profile   
 * 25/July/2018   Saravana  AR- 3895 Created UOM conversion UNIT_OF_MEASURE_TO_USG_FACTORS 
 * 25/July/2018   Saravana  AR-3895 Modifed the method TenderLocationSummaryAdapter to handle UOM conversion and OfferedVolume = NULL
 * 25/July/2018   Saravana  AR-3895 Modifed the SOQL in 2 methods getTenderLocationsSummaryByCountr. Added the field AITM_Tender__r.AITM_Unit_Of_Measure__c in the query.
 * 25/July/2018   Saravan   AR-3895 Modifed getCountrySummaryTenderLocations  to handle Null for TOTALOFFEREDVOLUME and UOM Conversion for summaryLocationAdapter.totalVolumeUSG 
 * 22/August/2018 Sgane     AR-4147 Modified getCountrySummaryTenderLocations to make the all country toUpperCase and to handle Not represented and Priced locations.
 * 09/Januray/2019 srnandan Added constant AIR_TM_LABP_LOCATION_MANAGER_PROFILE and modified getLocationSummaryDetails for LABP Location Manager profile 
 * 17/March/2019   srnandan  AR-5087 Modified method getCountrySummaryTenderLocations and TenderLocationSummaryAdapter null check for countryname
 * 27/March/2019     Ravi         Modified - AR-5111 updated MT conversion 
 *************************************************************************************/
public with sharing class AITM_RelatedTenderLocationsSummaryCtrl {
    
    private static final String STATUS_AWAITING_PRICE = 'Awaiting price';
    private static final String STATUS_PRICED = 'Priced';
    private static final String AIR_TM_LOCATION_MANAGER_PROFILE = 'Air_TMLocation Manager';  
    private static final Set<String> AIR_TM_LABP_LOCATION_MANAGER_PROFILE = new Set<String>{'Air_TMLABPLM','Air_TMLABPLoginLM'};
    private static final Set<String> AIR_TM_LABP_DUAL_MANAGER_PROFILE = new Set<String>{'Air_TMLABP','Air_TMLABPLogin'};
    
    /**
     * @description returns list collection of TenderLocationSummaryAdapter based on tenderId and filter condition
     * @param tenderId of type Id
     * @param filter of type string
     * @return List collection of TenderLocationSummaryAdapter
     */
    public static @AuraEnabled(cacheable=true) List<TenderLocationSummaryAdapter> getLocationSummaryDetails(Id tenderId, String filter, Integer roundNumber) {
        List<TenderLocationSummaryAdapter> locations = new List<TenderLocationSummaryAdapter>();
        if (filter == null) {
            String profileName = new AITM_UsersDao().getProfileName(UserInfo.getUserId());            
            if(profileName == AIR_TM_LOCATION_MANAGER_PROFILE || AIR_TM_LABP_LOCATION_MANAGER_PROFILE.contains(profileName)) {
                locations = getCountrySummaryTenderLocations(tenderId, roundNumber, UserInfo.getUserId());
             }else {
                   if(AIR_TM_LABP_DUAL_MANAGER_PROFILE.contains(profileName)){
                      AITM_Tender__c t = [Select OwnerId from AITM_Tender__c where Id = :tenderId];
                          if(t.ownerId == UserInfo.getUserId()){
                               locations = getCountrySummaryLABPAMOwnerTenderLocations(tenderId, roundNumber, UserInfo.getUserId());
                          } else{  
                               locations = getCountrySummaryLABPNonOwnerTenderLocations(tenderId, roundNumber, UserInfo.getUserId());
                            }
                   } 
                      else { 
                           locations = getCountrySummaryTenderLocations(tenderId, roundNumber, null);
                      }
               } 
            
            
        } 
        return locations;
    }

    /**
     * @description gets tender locations details countrywise for a given tender
     * @param tenderId of type Id
     * @return List collection of TenderLocationSummaryAdapter
     */
    private static List<TenderLocationSummaryAdapter> getCountrySummaryTenderLocations(Id tenderId, Integer roundNumber, Id userId) {
        List<TenderLocationSummaryAdapter> locations = new List<TenderLocationSummaryAdapter>();
        Map<String,TenderLocationSummaryAdapter> mapLocations = new Map<String,TenderLocationSummaryAdapter>();
        for(AggregateResult tenderLocation : new AITM_LocationsDao().getTenderLocationsSummaryByCountry(tenderId, roundNumber, userId)) {
            string countryName = (tenderLocation.get('COUNTRY') != null ? string.valueOf(tenderLocation.get('COUNTRY')).toUpperCase() : '');
            if(!mapLocations.containsKey(countryName)) {
                mapLocations.put(countryName,new TenderLocationSummaryAdapter(tenderLocation));
            }else {
            TenderLocationSummaryAdapter summaryLocationAdapter = mapLocations.get(countryName);
            summaryLocationAdapter.totalNumberOfLocations = summaryLocationAdapter.totalNumberOfLocations + integer.valueOf(tenderLocation.get('TOTALNUMBEROFLOCATIONS'));
            summaryLocationAdapter.totalVolumeUSG = Math.round((summaryLocationAdapter.totalVolumeUSG + (decimal)tenderLocation.get('TOTALREQUESTEDVOLUMEUSG') * summaryLocationAdapter.UNIT_OF_MEASURE_TO_USG_FACTORS.get(summaryLocationAdapter.uom)).setScale(2)); 
            
            if(summaryLocationAdapter.totalOfferedVolumeUSG != null && tenderLocation.get('TOTALOFFEREDVOLUME') != null){
               summaryLocationAdapter.totalOfferedVolumeUSG = Math.round((summaryLocationAdapter.totalOfferedVolumeUSG + (decimal)tenderLocation.get('TOTALOFFEREDVOLUME')).setScale(2));
            } 
            if(summaryLocationAdapter.totalOfferedVolumeUSG == null && tenderLocation.get('TOTALOFFEREDVOLUME') != null){
               summaryLocationAdapter.totalOfferedVolumeUSG = Math.round(((decimal)tenderLocation.get('TOTALOFFEREDVOLUME')).setScale(2));
            }

            
            if(string.valueOf(tenderLocation.get('STATUS')) == STATUS_AWAITING_PRICE) {
                summaryLocationAdapter.status = STATUS_AWAITING_PRICE;
            }else if ((string.valueOf(tenderLocation.get('STATUS')) == STATUS_PRICED) && (summaryLocationAdapter.STATUS != STATUS_AWAITING_PRICE)){
                summaryLocationAdapter.status = STATUS_PRICED;
             }

                mapLocations.put(countryName,summaryLocationAdapter);
            }
            
        }
        locations.addAll(mapLocations.values());
        return locations;
    }

    /**
     * @description gets tender locations details countrywise for a given tender
     * @param tenderId of type Id
     * @return List collection of TenderLocationSummaryAdapter
     */
    private static List<TenderLocationSummaryAdapter> getCountrySummaryLABPAMOwnerTenderLocations(Id tenderId, Integer roundNumber, Id userId) {
       // List<TenderLocationSummaryAdapter> locations = new List<TenderLocationSummaryAdapter>();
        //Map<String,TenderLocationSummaryAdapter> mapLocations = new Map<String,TenderLocationSummaryAdapter>();
        List<AggregateResult> tenderLocations = new AITM_LocationsDao().getTenderLocationsSummaryByCountry(tenderId, roundNumber);
        List<TenderLocationSummaryAdapter> showTenderLocations =  getCountryNames(tenderLocations);
        return showTenderLocations;
    }

    /**
     * @description gets tender locations details countrywise for a given tender
     * @param tenderLocations of type List of the aggregate result
     * @return List collection of TenderLocationSummaryAdapter
     */

    private static List<TenderLocationSummaryAdapter> getCountryNames(List<AggregateResult> tenderLocations) {
        List<TenderLocationSummaryAdapter> locations = new List<TenderLocationSummaryAdapter>();
        Map<String,TenderLocationSummaryAdapter> mapLocations = new Map<String,TenderLocationSummaryAdapter>();

        for(AggregateResult tenderLocation : tenderLocations ) {
            string countryName = (tenderLocation.get('COUNTRY') != null ? string.valueOf(tenderLocation.get('COUNTRY')).toUpperCase() : '');
            if(!mapLocations.containsKey(countryName)) {
                mapLocations.put(countryName,new TenderLocationSummaryAdapter(tenderLocation));
            }else {
            TenderLocationSummaryAdapter summaryLocationAdapter = mapLocations.get(countryName);
            summaryLocationAdapter.totalNumberOfLocations = summaryLocationAdapter.totalNumberOfLocations + integer.valueOf(tenderLocation.get('TOTALNUMBEROFLOCATIONS'));
            summaryLocationAdapter.totalVolumeUSG = Math.round((summaryLocationAdapter.totalVolumeUSG + (decimal)tenderLocation.get('TOTALREQUESTEDVOLUMEUSG') * summaryLocationAdapter.UNIT_OF_MEASURE_TO_USG_FACTORS.get(summaryLocationAdapter.uom)).setScale(2)); 
            
            if(summaryLocationAdapter.totalOfferedVolumeUSG != null && tenderLocation.get('TOTALOFFEREDVOLUME') != null){
               summaryLocationAdapter.totalOfferedVolumeUSG = Math.round((summaryLocationAdapter.totalOfferedVolumeUSG + (decimal)tenderLocation.get('TOTALOFFEREDVOLUME')).setScale(2));
            } 
            if(summaryLocationAdapter.totalOfferedVolumeUSG == null && tenderLocation.get('TOTALOFFEREDVOLUME') != null){
               summaryLocationAdapter.totalOfferedVolumeUSG = Math.round(((decimal)tenderLocation.get('TOTALOFFEREDVOLUME')).setScale(2));
            }     

            
            if(string.valueOf(tenderLocation.get('STATUS')) == STATUS_AWAITING_PRICE) {
                summaryLocationAdapter.status = STATUS_AWAITING_PRICE;
            }else if ((string.valueOf(tenderLocation.get('STATUS')) == STATUS_PRICED) && (summaryLocationAdapter.STATUS != STATUS_AWAITING_PRICE)){
                summaryLocationAdapter.status = STATUS_PRICED;
             }

                mapLocations.put(countryName,summaryLocationAdapter);
            }
            
        }
        locations.addAll(mapLocations.values());
        return locations;
    }
        
        
       
    /**
     * @description gets tender locations details countrywise for a given tender
     * @param tenderId of type Id
     * @return List collection of TenderLocationSummaryAdapter
     */
    private static List<TenderLocationSummaryAdapter> getCountrySummaryLABPNonOwnerTenderLocations(Id tenderId, Integer roundNumber, Id userId) {

        List<AggregateResult> tenderLocations = new AITM_LocationsDao().getTenderLocationsSummaryByCountryLABPNONOWNER(tenderId, roundNumber,userId);
        List<TenderLocationSummaryAdapter> showTenderLocations =  getCountryNames(tenderLocations);
        return showTenderLocations;
    }
        
    
    /**
     * @description adapter class for tenderlocation summary
     */
    public class TenderLocationSummaryAdapter {
        public @AuraEnabled String country;
        public @AuraEnabled Integer totalNumberOfLocations;
        public @AuraEnabled Decimal totalVolumeUSG;
        public @AuraEnabled Decimal totalOfferedVolumeUSG;
        public @AuraEnabled String locationManager;
        public @AuraEnabled String locationManagerId;
        public @AuraEnabled String status;
		
		/*
         * @description to handle UOM comversion when the tender is created with any UOM. 
         */
         public @AuraEnabled String uom;
        public final Map<String, Double> UNIT_OF_MEASURE_TO_USG_FACTORS = new Map<String, Double>{
           'USG' => 1,
           'LT' => 0.264172,
           'MT' => 330.215,
           'CM' => 264.1721,
           'KG' => 0.33
       };

        /**
         * @description overloaded constructor assigns values to variables
         * @param originalRecord of AggregateResult
         */
        public TenderLocationSummaryAdapter(AggregateResult originalRecord) {
            this.country = (originalRecord.get('COUNTRY') != null ? string.valueOf(originalRecord.get('COUNTRY')) : '');
            this.locationManager = string.valueOf(originalRecord.get('LOCATIONMANAGER'));
            this.locationManagerId = string.valueOf(originalRecord.get('LOCATIONMANAGERID'));
			this.totalNumberOfLocations = integer.valueOf(originalRecord.get('TOTALNUMBEROFLOCATIONS'));
            this.uom = string.valueOf(originalRecord.get('UOM'));
            this.totalVolumeUSG = (originalRecord.get('TOTALREQUESTEDVOLUMEUSG')!= null ?((decimal)originalRecord.get('TOTALREQUESTEDVOLUMEUSG')* this.UNIT_OF_MEASURE_TO_USG_FACTORS.get(uom)).round(System.RoundingMode.HALF_UP):null);
            this.totalOfferedVolumeUSG = (originalRecord.get('TOTALOFFEREDVOLUME') != null ? ((decimal)originalRecord.get('TOTALOFFEREDVOLUME')).round(System.RoundingMode.HALF_UP) : null);
            this.status = string.valueOf(originalRecord.get('STATUS'));
        }
    }
}